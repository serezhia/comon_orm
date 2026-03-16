import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Factory signature used by runtime-metadata open helpers.
typedef SqliteRuntimeAdapterFactory =
    SqliteDatabaseAdapter Function({
      required String databasePath,
      required RuntimeSchemaView schema,
    });

/// SQLite `DatabaseAdapter` implementation backed by `sqlite3`.
class SqliteDatabaseAdapter implements DatabaseAdapter {
  /// Creates an adapter from an open SQLite [database] and parsed [schema].
  SqliteDatabaseAdapter({
    required sqlite.Database database,
    required SchemaDocument schema,
  }) : this.fromRuntimeSchema(
         database: database,
         schema: runtimeSchemaViewFromSchemaDocument(schema),
       );

  /// Creates an adapter from an open SQLite [database] and runtime [schema].
  SqliteDatabaseAdapter.fromRuntimeSchema({
    required sqlite.Database database,
    required RuntimeSchemaView schema,
  }) : _database = database,
       _schema = schema;

  /// Creates an adapter from an open SQLite [database] and generated metadata.
  factory SqliteDatabaseAdapter.fromGeneratedSchema({
    required sqlite.Database database,
    required GeneratedRuntimeSchema schema,
  }) {
    return SqliteDatabaseAdapter.fromRuntimeSchema(
      database: database,
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
    );
  }

  /// Opens an in-memory adapter for tests and ephemeral workflows.
  factory SqliteDatabaseAdapter.openInMemory({required SchemaDocument schema}) {
    return SqliteDatabaseAdapter(
      database: sqlite.sqlite3.openInMemory(),
      schema: schema,
    );
  }

  /// Resolves datasource metadata and opens an adapter from a runtime schema.
  static Future<SqliteDatabaseAdapter> openFromRuntimeSchema({
    required RuntimeSchemaView schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    SqliteRuntimeAdapterFactory? adapterFactory,
  }) async {
    final resolvedDatabasePath =
        databasePath ??
        resolver
            .resolveDatasource(
              schema: schema,
              datasourceName: datasourceName,
              expectedProvider: 'sqlite',
              schemaPath: schemaPath,
            )
            .url;

    final SqliteRuntimeAdapterFactory factory =
        adapterFactory ??
        ({required String databasePath, required RuntimeSchemaView schema}) {
          return SqliteDatabaseAdapter.fromRuntimeSchema(
            database: databasePath == ':memory:'
                ? sqlite.sqlite3.openInMemory()
                : sqlite.sqlite3.open(databasePath),
            schema: schema,
          );
        };

    return factory(databasePath: resolvedDatabasePath, schema: schema);
  }

  /// Resolves datasource metadata and opens an adapter from generated metadata.
  static Future<SqliteDatabaseAdapter> openFromGeneratedSchema({
    required GeneratedRuntimeSchema schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    SqliteRuntimeAdapterFactory? adapterFactory,
  }) {
    return openFromRuntimeSchema(
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
      resolver: resolver,
      adapterFactory: adapterFactory,
    );
  }

  final sqlite.Database _database;
  final RuntimeSchemaView _schema;
  int _transactionDepth = 0;
  int _savepointCounter = 0;

  /// Clock used for automatic field values such as `@updatedAt`.
  DateTime Function() now = () => DateTime.now().toUtc();

  /// Closes the underlying SQLite database handle.
  @override
  void close() {
    _database.close();
  }

  /// Releases the underlying SQLite database handle.
  void dispose() {
    close();
  }

  @override
  Future<int> count(CountQuery query) async {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final result = _database.select(
      'SELECT COUNT(*) AS ${_quoteIdentifier('count')} '
      'FROM ${_tableReference(query.model, alias)} '
      'WHERE ${whereClause.sql}',
      whereClause.parameters,
    );
    return result.first['count'] as int;
  }

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) async {
    // Build the window CTE that applies WHERE / ORDER / LIMIT / OFFSET.
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final orderClause = _buildOrderByClause(alias, query.model, query.orderBy);
    final parameters = <Object?>[...whereClause.parameters];

    final innerSql = StringBuffer()
      ..write(
        'SELECT ${_quoteIdentifier(alias)}.* '
        'FROM ${_tableReference(query.model, alias)} '
        'WHERE ${whereClause.sql}',
      );
    if (query.orderBy.isNotEmpty) {
      innerSql.write(' ORDER BY $orderClause');
    }
    if (query.take != null) {
      innerSql.write(' LIMIT ?');
      parameters.add(query.take);
    }
    if (query.skip != null) {
      innerSql.write(' OFFSET ?');
      parameters.add(query.skip);
    }

    final selectExprs = _buildAggregateSelectExprs(
      null,
      query.model,
      query.count,
      query.avg,
      query.sum,
      query.min,
      query.max,
    );

    if (selectExprs.isEmpty) {
      return const AggregateQueryResult();
    }

    const cteName = '_agg';
    final sql =
        'WITH ${_quoteIdentifier(cteName)} AS ($innerSql) '
        'SELECT ${selectExprs.join(', ')} '
        'FROM ${_quoteIdentifier(cteName)}';

    final rows = _database.select(sql, parameters);
    if (rows.isEmpty) {
      return const AggregateQueryResult();
    }

    return _parseAggregateResultRow(
      rows.single,
      query.count,
      query.avg,
      query.sum,
      query.min,
      query.max,
    );
  }

  @override
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) async {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final parameters = <Object?>[...whereClause.parameters];

    // SELECT: grouped fields then aggregate expressions.
    final selectExprs = <String>[
      for (final field in query.by)
        '${_qualifiedField(alias, query.model, field)} AS ${_quoteIdentifier(field)}',
      ..._buildAggregateSelectExprs(
        alias,
        query.model,
        query.count,
        query.avg,
        query.sum,
        query.min,
        query.max,
      ),
    ];

    final groupByClause = query.by
        .map((f) => _qualifiedField(alias, query.model, f))
        .join(', ');

    final sql = StringBuffer()
      ..write(
        'SELECT ${selectExprs.join(', ')} '
        'FROM ${_tableReference(query.model, alias)} '
        'WHERE ${whereClause.sql} '
        'GROUP BY $groupByClause',
      );

    // HAVING clause.
    if (query.having.isNotEmpty) {
      final havingParts = <String>[];
      for (final pred in query.having) {
        final clause = _buildAggregatePredicateClause(alias, query.model, pred);
        havingParts.add('(${clause.sql})');
        parameters.addAll(clause.parameters);
      }
      sql.write(' HAVING ${havingParts.join(' AND ')}');
    }

    // ORDER BY.
    if (query.orderBy.isNotEmpty) {
      final orderClause = _buildGroupByOrderClause(
        alias,
        query.model,
        query.orderBy,
      );
      sql.write(' ORDER BY $orderClause');
    }

    if (query.take != null) {
      sql.write(' LIMIT ?');
      parameters.add(query.take);
    }
    if (query.skip != null) {
      sql.write(' OFFSET ?');
      parameters.add(query.skip);
    }

    final rows = _database.select(sql.toString(), parameters);
    return rows
        .map(
          (row) => GroupByQueryResultRow(
            group: Map<String, Object?>.unmodifiable({
              for (final field in query.by) field: row[field],
            }),
            aggregates: _parseAggregateResultRow(
              row,
              query.count,
              query.avg,
              query.sum,
              query.min,
              query.max,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Map<String, Object?>> create(CreateQuery query) async {
    return transaction((_) async {
      final inserted = _insertRecord(
        query.model,
        _applyAutomaticFieldValues(query.model, query.data, isCreate: true),
      );

      for (final nestedWrite in query.nestedCreates) {
        final parentKeyValues = _extractRequiredRelationKeyValues(
          inserted.record,
          nestedWrite.relation.localKeyFields,
          model: query.model,
          relation: nestedWrite.relation,
          role: 'parent',
        );

        for (final nestedRecord in nestedWrite.records) {
          final directAssignments = <String, Object?>{};
          if (nestedWrite.relation.storageKind ==
              QueryRelationStorageKind.direct) {
            for (
              var index = 0;
              index < nestedWrite.relation.targetKeyFields.length;
              index++
            ) {
              directAssignments[nestedWrite.relation.targetKeyFields[index]] =
                  parentKeyValues[nestedWrite.relation.localKeyFields[index]];
            }
          }
          final childRecord = _insertRecord(nestedWrite.relation.targetModel, {
            ..._applyAutomaticFieldValues(
              nestedWrite.relation.targetModel,
              nestedRecord,
              isCreate: true,
            ),
            ...directAssignments,
          });

          if (nestedWrite.relation.storageKind ==
              QueryRelationStorageKind.implicitManyToMany) {
            final childKeyValues = _extractRequiredRelationKeyValues(
              childRecord.record,
              nestedWrite.relation.targetKeyFields,
              model: nestedWrite.relation.targetModel,
              relation: nestedWrite.relation,
              role: 'child',
            );
            _insertImplicitManyToManyLink(
              sourceModel: query.model,
              relation: nestedWrite.relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: childKeyValues,
            );
          }
        }
      }

      return Map<String, Object?>.unmodifiable(
        _materializeRecord(
          query.model,
          inserted.record,
          include: query.include,
          select: null,
        ),
      );
    });
  }

  @override
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) async {
    _insertImplicitManyToManyLink(
      sourceModel: sourceModel,
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  @override
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) async {
    return _deleteImplicitManyToManyLinks(
      sourceModel: sourceModel,
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) async {
    return transaction((_) async {
      final selected = _selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (selected == null) {
        throw StateError('No record found for delete in ${query.model}.');
      }

      _database.execute(
        'DELETE FROM ${_quoteIdentifier(_mappedTableName(query.model))} '
        'WHERE rowid = ?',
        <Object?>[selected.rowId],
      );

      return Map<String, Object?>.unmodifiable(
        _materializeRecord(
          query.model,
          selected.record,
          include: query.include,
          select: query.select,
        ),
      );
    });
  }

  @override
  Future<int> deleteMany(DeleteManyQuery query) async {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    _database.execute(
      'DELETE FROM ${_quoteIdentifier(_mappedTableName(query.model))} AS ${_quoteIdentifier(alias)} '
      'WHERE ${whereClause.sql}',
      whereClause.parameters,
    );
    return _database.updatedRows;
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) async {
    if (query.distinct.isNotEmpty) {
      final records = await findMany(
        FindManyQuery(
          model: query.model,
          where: query.where,
          orderBy: query.orderBy,
          distinct: query.distinct,
          include: query.include,
          select: query.select,
          skip: query.skip,
          take: 1,
        ),
      );
      if (records.isEmpty) {
        return null;
      }
      return records.first;
    }

    final selected = _selectSingleRow(
      model: query.model,
      where: query.where,
      orderBy: query.orderBy,
      offset: query.skip,
    );
    if (selected == null) {
      return null;
    }

    return Map<String, Object?>.unmodifiable(
      _materializeRecord(
        query.model,
        selected.record,
        include: query.include,
        select: query.select,
      ),
    );
  }

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) async {
    final rows = _selectRows(
      model: query.model,
      where: query.where,
      orderBy: query.orderBy,
      limit: query.distinct.isEmpty ? query.take : null,
      offset: query.distinct.isEmpty ? query.skip : null,
    );

    final records = query.distinct.isEmpty
        ? rows.map((row) => row.record).toList(growable: false)
        : () {
            final distinct = applyDistinctRecords(
              rows.map((row) => row.record),
              query.distinct,
            );
            final skipped = query.skip == null
                ? distinct
                : distinct.skip(query.skip!).toList(growable: false);
            final taken = query.take == null
                ? skipped
                : skipped.take(query.take!).toList(growable: false);
            return List<Map<String, Object?>>.unmodifiable(taken);
          }();

    return records
        .map(
          (record) => Map<String, Object?>.unmodifiable(
            _materializeRecord(
              query.model,
              record,
              include: query.include,
              select: query.select,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) async {
    final selected = _selectSingleRow(
      model: query.model,
      where: query.where,
      orderBy: const <QueryOrderBy>[],
    );
    if (selected == null) {
      return null;
    }

    return Map<String, Object?>.unmodifiable(
      _materializeRecord(
        query.model,
        selected.record,
        include: query.include,
        select: query.select,
      ),
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(DatabaseAdapter tx) action,
  ) async {
    final isRootTransaction = _transactionDepth == 0;
    final savepointName = 'sp_${_savepointCounter++}';

    if (isRootTransaction) {
      _database.execute('BEGIN');
    } else {
      _database.execute('SAVEPOINT ${_quoteIdentifier(savepointName)}');
    }

    _transactionDepth++;
    try {
      final result = await action(this);
      if (isRootTransaction) {
        _database.execute('COMMIT');
      } else {
        _database.execute(
          'RELEASE SAVEPOINT ${_quoteIdentifier(savepointName)}',
        );
      }
      return result;
    } catch (_) {
      if (isRootTransaction) {
        _database.execute('ROLLBACK');
      } else {
        _database.execute(
          'ROLLBACK TO SAVEPOINT ${_quoteIdentifier(savepointName)}',
        );
        _database.execute(
          'RELEASE SAVEPOINT ${_quoteIdentifier(savepointName)}',
        );
      }
      rethrow;
    } finally {
      _transactionDepth--;
    }
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) async {
    return transaction((_) async {
      final selected = _selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (selected == null) {
        throw StateError('No record found for update in ${query.model}.');
      }

      final updateData = _applyAutomaticFieldValues(
        query.model,
        query.data,
        isCreate: false,
      );

      if (updateData.isNotEmpty) {
        final assignments = <String>[];
        final parameters = <Object?>[];
        for (final entry in updateData.entries) {
          assignments.add('${_columnIdentifier(query.model, entry.key)} = ?');
          parameters.add(
            _normalizeValueForStorage(query.model, entry.key, entry.value),
          );
        }
        parameters.add(selected.rowId);
        _database.execute(
          'UPDATE ${_quoteIdentifier(_mappedTableName(query.model))} '
          'SET ${assignments.join(', ')} '
          'WHERE rowid = ?',
          parameters,
        );
      }

      final updated = _selectRowByRowId(query.model, selected.rowId);
      return Map<String, Object?>.unmodifiable(
        _materializeRecord(
          query.model,
          updated.record,
          include: query.include,
          select: query.select,
        ),
      );
    });
  }

  @override
  Future<int> updateMany(UpdateManyQuery query) async {
    final updateData = _applyAutomaticFieldValues(
      query.model,
      query.data,
      isCreate: false,
    );
    if (updateData.isEmpty) {
      return 0;
    }

    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final assignments = <String>[];
    final parameters = <Object?>[];
    for (final entry in updateData.entries) {
      assignments.add('${_columnIdentifier(query.model, entry.key)} = ?');
      parameters.add(
        _normalizeValueForStorage(query.model, entry.key, entry.value),
      );
    }
    parameters.addAll(whereClause.parameters);

    _database.execute(
      'UPDATE ${_quoteIdentifier(_mappedTableName(query.model))} AS ${_quoteIdentifier(alias)} '
      'SET ${assignments.join(', ')} '
      'WHERE ${whereClause.sql}',
      parameters,
    );
    return _database.updatedRows;
  }

  _SelectedRow _selectRowByRowId(String model, int rowId) {
    final query = SqliteQuerySupport.buildSelectRowByRowIdQuery(
      schema: _schema,
      model: model,
      rowId: rowId,
      rowIdColumn: _rowIdColumn,
      quoteIdentifier: _quoteIdentifier,
    );
    final result = _database.select(query.sql, query.parameters);
    if (result.isEmpty) {
      throw StateError('No row found for $model with rowid $rowId.');
    }
    return _resultRowToSelectedRow(model, result, result.first);
  }

  Map<String, Object?> _applyAutomaticFieldValues(
    String model,
    Map<String, Object?> data, {
    required bool isCreate,
  }) {
    return SqliteQuerySupport.applyAutomaticFieldValues(
      model: _schema.findModel(model),
      data: data,
      isCreate: isCreate,
      timestamp: now(),
    );
  }

  List<_SelectedRow> _selectRows({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    int? limit,
    int? offset,
  }) {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final query = SqliteQuerySupport.buildSelectRowsQuery(
      model: model,
      alias: alias,
      where: where,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      rowIdColumn: _rowIdColumn,
      buildWhereClause: (innerModel, innerAlias, predicates) {
        final built = _buildWhereClause(
          context,
          innerModel,
          innerAlias,
          predicates,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      buildOrderByClause: _buildOrderByClause,
      tableReference: _tableReference,
      quoteIdentifier: _quoteIdentifier,
    );

    final result = _database.select(query.sql, query.parameters);
    return result
        .map((row) => _resultRowToSelectedRow(model, result, row))
        .toList(growable: false);
  }

  _SelectedRow? _selectSingleRow({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    int? offset,
  }) {
    final rows = _selectRows(
      model: model,
      where: where,
      orderBy: orderBy,
      limit: 1,
      offset: offset,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.single;
  }

  _SelectedRow _insertRecord(String model, Map<String, Object?> data) {
    final query = SqliteQuerySupport.buildInsertRecordQuery(
      schema: _schema,
      model: model,
      data: data,
      quoteIdentifier: _quoteIdentifier,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    _database.execute(query.sql, query.parameters);
    return _selectRowByRowId(model, _database.lastInsertRowId);
  }

  Map<String, Object?> _materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) {
    final base = SqliteQuerySupport.selectMaterializedRecordFields(
      record: record,
      select: select,
    );

    if (include != null) {
      for (final entry in include.relations.entries) {
        base[entry.key] = _resolveInclude(model, record, entry.value);
      }
    }

    return base;
  }

  Object? _resolveInclude(
    String sourceModel,
    Map<String, Object?> sourceRecord,
    QueryIncludeEntry entry,
  ) {
    if (entry.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      final relatedRows = _selectImplicitManyToManyRows(
        sourceModel: sourceModel,
        sourceRecord: sourceRecord,
        relation: entry.relation,
      );
      final materialized = relatedRows
          .map(
            (row) => Map<String, Object?>.unmodifiable(
              _materializeRecord(
                entry.relation.targetModel,
                row.record,
                include: entry.include,
                select: entry.select,
              ),
            ),
          )
          .toList(growable: false);
      return SqliteQuerySupport.finalizeIncludedRelationResult(
        relation: entry.relation,
        materialized: materialized,
      );
    }

    final wherePredicates =
        SqliteQuerySupport.buildDirectRelationWherePredicates(
          sourceRecord: sourceRecord,
          relation: entry.relation,
        );
    if (wherePredicates == null) {
      return entry.relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
    }

    final relatedRows = _selectRows(
      model: entry.relation.targetModel,
      where: wherePredicates,
      orderBy: const <QueryOrderBy>[],
    );

    final materialized = relatedRows
        .map(
          (row) => Map<String, Object?>.unmodifiable(
            _materializeRecord(
              entry.relation.targetModel,
              row.record,
              include: entry.include,
              select: entry.select,
            ),
          ),
        )
        .toList(growable: false);

    return SqliteQuerySupport.finalizeIncludedRelationResult(
      relation: entry.relation,
      materialized: materialized,
    );
  }

  _SelectedRow _resultRowToSelectedRow(
    String model,
    sqlite.ResultSet result,
    sqlite.Row row,
  ) {
    final record = SqliteQuerySupport.selectedRowRecord(
      schema: _schema,
      model: model,
      columns: result.columnNames,
      valueForColumn: (column) => row[column],
      normalizeValueFromStorage: _normalizeValueFromStorage,
      rowIdColumn: _rowIdColumn,
    );
    return _SelectedRow(rowId: row[_rowIdColumn] as int, record: record);
  }

  _SqlClause _buildWhereClause(
    _SqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    final clause = SqliteQuerySupport.buildWhereClause(
      model: model,
      alias: alias,
      predicates: predicates,
      buildPredicateClause: (innerModel, innerAlias, predicate) {
        final built = _buildPredicateClause(
          context,
          innerModel,
          innerAlias,
          predicate,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
    );
    return _SqlClause(sql: clause.sql, parameters: clause.parameters);
  }

  _SqlClause _buildPredicateClause(
    _SqlBuildContext context,
    String model,
    String alias,
    QueryPredicate predicate,
  ) {
    final clause = SqliteQuerySupport.buildPredicateClause(
      model: model,
      alias: alias,
      predicate: predicate,
      buildWhereClause: (innerModel, innerAlias, predicates) {
        final built = _buildWhereClause(
          context,
          innerModel,
          innerAlias,
          predicates,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      buildRelationClause: (sourceModel, sourceAlias, operator, filter) {
        final built = _buildRelationClause(
          context,
          sourceModel,
          sourceAlias,
          operator,
          filter,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      buildBinaryClause: (innerAlias, field, operator, value, innerModel) {
        final built = _binaryClause(
          innerAlias,
          field,
          operator,
          value,
          innerModel,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      qualifiedField: _qualifiedField,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    return _SqlClause(sql: clause.sql, parameters: clause.parameters);
  }

  _SqlClause _buildRelationClause(
    _SqlBuildContext context,
    String sourceModel,
    String sourceAlias,
    String operator,
    QueryRelationFilter filter,
  ) {
    final clause = SqliteQuerySupport.buildRelationClause(
      sourceModel: sourceModel,
      sourceAlias: sourceAlias,
      operator: operator,
      filter: filter,
      nextAlias: context.nextAlias,
      buildWhereClause: (model, alias, predicates) {
        final built = _buildWhereClause(context, model, alias, predicates);
        return (sql: built.sql, parameters: built.parameters);
      },
      buildImplicitManyToManyRelationClause:
          (sourceModel, sourceAlias, operator, filter) {
            final built = _buildImplicitManyToManyRelationClause(
              context,
              sourceModel,
              sourceAlias,
              operator,
              filter,
            );
            return (sql: built.sql, parameters: built.parameters);
          },
      qualifiedFieldEqualityClause: _qualifiedFieldEqualityClause,
      tableReference: _tableReference,
    );
    return _SqlClause(sql: clause.sql, parameters: clause.parameters);
  }

  void _insertImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) {
    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final query = SqliteQuerySupport.buildInsertImplicitManyToManyLinkQuery(
      relation: relation,
      storage: storage,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
      quoteIdentifier: _quoteIdentifier,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    _database.execute(query.sql, query.parameters);
  }

  int _deleteImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) {
    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final query = SqliteQuerySupport.buildDeleteImplicitManyToManyLinkQuery(
      relation: relation,
      storage: storage,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
      quoteIdentifier: _quoteIdentifier,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    final statement = _database.prepare(query.sql);
    try {
      statement.execute(query.parameters);
      return _database.updatedRows;
    } finally {
      statement.close();
    }
  }

  List<_SelectedRow> _selectImplicitManyToManyRows({
    required String sourceModel,
    required Map<String, Object?> sourceRecord,
    required QueryRelation relation,
  }) {
    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final context = _SqlBuildContext();
    final query = SqliteQuerySupport.buildSelectImplicitManyToManyRowsQuery(
      sourceModel: sourceModel,
      sourceRecord: sourceRecord,
      relation: relation,
      storage: storage,
      rowIdColumn: _rowIdColumn,
      nextAlias: context.nextAlias,
      rawTableReference: _rawTableReference,
      tableReference: _tableReference,
      qualifiedRawField: _qualifiedRawField,
      quoteIdentifier: _quoteIdentifier,
      qualifiedFieldEqualityClause: _qualifiedFieldEqualityClause,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    if (query == null) {
      return const <_SelectedRow>[];
    }

    final result = _database.select(query.sql, query.parameters);
    return result
        .map(
          (row) => _resultRowToSelectedRow(relation.targetModel, result, row),
        )
        .toList(growable: false);
  }

  _SqlClause _buildImplicitManyToManyRelationClause(
    _SqlBuildContext context,
    String sourceModel,
    String sourceAlias,
    String operator,
    QueryRelationFilter filter,
  ) {
    final clause = SqliteQuerySupport.buildImplicitManyToManyRelationClause(
      sourceModel: sourceModel,
      sourceAlias: sourceAlias,
      operator: operator,
      filter: filter,
      nextAlias: context.nextAlias,
      buildWhereClause: (model, alias, predicates) {
        final built = _buildWhereClause(context, model, alias, predicates);
        return (sql: built.sql, parameters: built.parameters);
      },
      implicitManyToManyStorage: _implicitManyToManyStorage,
      qualifiedFieldEqualityClause: _qualifiedFieldEqualityClause,
      tableReference: _tableReference,
      rawTableReference: _rawTableReference,
    );
    return _SqlClause(sql: clause.sql, parameters: clause.parameters);
  }

  RuntimeImplicitManyToManyStorage _implicitManyToManyStorage(
    String sourceModel,
    QueryRelation relation,
  ) {
    return SqliteQuerySupport.resolveImplicitManyToManyStorageOrThrow(
      schema: _schema,
      sourceModel: sourceModel,
      relation: relation,
    );
  }

  Map<String, Object?> _extractRequiredRelationKeyValues(
    Map<String, Object?> record,
    List<String> fields, {
    required String model,
    required QueryRelation relation,
    required String role,
  }) {
    return SqliteQuerySupport.extractRequiredRelationKeyValues(
      record: record,
      fields: fields,
      model: model,
      relation: relation,
      role: role,
    );
  }

  String _qualifiedFieldEqualityClause({
    required String leftAlias,
    required String leftModel,
    required List<String> leftFields,
    bool leftRaw = false,
    required String rightAlias,
    required String rightModel,
    required List<String> rightFields,
    bool rightRaw = false,
  }) {
    return SqliteQuerySupport.buildQualifiedFieldEqualityClause(
      leftAlias: leftAlias,
      leftModel: leftModel,
      leftFields: leftFields,
      leftRaw: leftRaw,
      rightAlias: rightAlias,
      rightModel: rightModel,
      rightFields: rightFields,
      rightRaw: rightRaw,
      qualifiedField: _qualifiedField,
      qualifiedRawField: _qualifiedRawField,
    );
  }

  _SqlClause _binaryClause(
    String alias,
    String field,
    String operator,
    Object? value,
    String model,
  ) {
    final clause = SqliteQuerySupport.buildBinaryClause(
      alias: alias,
      field: field,
      operator: operator,
      value: value,
      model: model,
      qualifiedField: _qualifiedField,
      normalizeValueForStorage: _normalizeValueForStorage,
    );
    return _SqlClause(sql: clause.sql, parameters: clause.parameters);
  }

  /// Returns SQL aggregate expressions for SELECT (without table alias for CTE
  /// context, or with [alias] for grouped queries).
  List<String> _buildAggregateSelectExprs(
    String? alias,
    String model,
    QueryCountSelection count,
    Set<String> avg,
    Set<String> sum,
    Set<String> min,
    Set<String> max,
  ) {
    return SqliteQuerySupport.buildAggregateSelectExprs(
      alias: alias,
      model: model,
      count: count,
      avg: avg,
      sum: sum,
      min: min,
      max: max,
      qualifiedField: _qualifiedField,
      columnIdentifier: _columnIdentifier,
    );
  }

  AggregateQueryResult _parseAggregateResultRow(
    Map<String, Object?> row,
    QueryCountSelection count,
    Set<String> avg,
    Set<String> sum,
    Set<String> min,
    Set<String> max,
  ) {
    return SqliteQuerySupport.parseAggregateResultRow(
      row: row,
      count: count,
      avg: avg,
      sum: sum,
      min: min,
      max: max,
    );
  }

  /// Builds a HAVING predicate clause for a single aggregate predicate.
  _SqlClause _buildAggregatePredicateClause(
    String alias,
    String model,
    QueryAggregatePredicate pred,
  ) {
    return SqliteQuerySupport.buildAggregatePredicateClause<_SqlClause>(
      alias: alias,
      model: model,
      predicate: pred,
      aggregateSqlExpr: _aggregateSqlExpr,
      buildClause: _SqlClause.new,
    );
  }

  /// Builds an SQL aggregate expression (e.g. `COUNT(*)`, `AVG(t0."age")`).
  String _aggregateSqlExpr(
    String alias,
    String model,
    String field,
    QueryAggregateFunction fn,
  ) {
    if (fn == QueryAggregateFunction.count && field == '_all') {
      return 'COUNT(*)';
    }
    final qualField = _qualifiedField(alias, model, field);
    return switch (fn) {
      QueryAggregateFunction.count => 'COUNT($qualField)',
      QueryAggregateFunction.avg => 'AVG($qualField)',
      QueryAggregateFunction.sum => 'SUM($qualField)',
      QueryAggregateFunction.min => 'MIN($qualField)',
      QueryAggregateFunction.max => 'MAX($qualField)',
    };
  }

  /// Builds ORDER BY clause for GROUP BY queries.
  String _buildGroupByOrderClause(
    String alias,
    String model,
    List<GroupByOrderBy> orderBy,
  ) {
    return SqliteQuerySupport.buildGroupByOrderClause(
      alias: alias,
      model: model,
      orderBy: orderBy,
      aggregateSqlExpr: _aggregateSqlExpr,
      qualifiedField: _qualifiedField,
    );
  }

  String _buildOrderByClause(
    String alias,
    String model,
    List<QueryOrderBy> orderBy,
  ) {
    return SqliteQuerySupport.buildOrderByClause(
      alias: alias,
      model: model,
      orderBy: orderBy,
      qualifiedField: _qualifiedField,
    );
  }

  String _rawTableReference(String tableName, String alias) {
    return SqliteQuerySupport.rawTableReference(
      tableName: tableName,
      alias: alias,
      quoteIdentifier: _quoteIdentifier,
    );
  }

  String _qualifiedRawField(String alias, String fieldName) {
    return SqliteQuerySupport.qualifiedRawField(
      alias: alias,
      fieldName: fieldName,
      quoteIdentifier: _quoteIdentifier,
    );
  }

  Object? _normalizeValueForStorage(String model, String field, Object? value) {
    return SqliteQuerySupport.normalizeValueForStorage(
      model: _schema.findModel(model),
      field: field,
      value: value,
    );
  }

  Object? _normalizeValueFromStorage(
    String model,
    String field,
    Object? value,
  ) {
    return SqliteQuerySupport.normalizeValueFromStorage(
      model: _schema.findModel(model),
      field: field,
      value: value,
    );
  }

  String _tableReference(String model, String alias) {
    return SqliteQuerySupport.tableReference(
      schema: _schema,
      model: model,
      alias: alias,
      quoteIdentifier: _quoteIdentifier,
    );
  }

  String _qualifiedField(String alias, String model, String field) {
    return SqliteQuerySupport.qualifiedField(
      schema: _schema,
      alias: alias,
      model: model,
      field: field,
      quoteIdentifier: _quoteIdentifier,
    );
  }

  String _mappedTableName(String model) {
    return SqliteQuerySupport.mappedTableName(schema: _schema, model: model);
  }

  String _columnIdentifier(String model, String field) {
    return SqliteQuerySupport.columnIdentifier(
      schema: _schema,
      model: model,
      field: field,
      quoteIdentifier: _quoteIdentifier,
    );
  }

  String _quoteIdentifier(String identifier) {
    return SqliteQuerySupport.quoteIdentifier(identifier);
  }
}

const String _rowIdColumn = '__rowid__';

class _SqlBuildContext {
  int _aliasCounter = 0;

  String nextAlias() => 't${_aliasCounter++}';
}

class _SqlClause {
  const _SqlClause({required this.sql, required this.parameters});

  final String sql;
  final List<Object?> parameters;
}

class _SelectedRow {
  const _SelectedRow({required this.rowId, required this.record});

  final int rowId;
  final Map<String, Object?> record;
}
