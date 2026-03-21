import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_relation_materializer.dart';
import 'sqlite_sql_builder.dart';
import 'sqlite_transaction.dart';

typedef _SqlBuildContext = SqliteSqlBuildContext;
typedef _SqlClause = SqliteSqlClause;
typedef _SelectedRow = SqliteSelectedRow;
typedef _ImplicitManyToManyBatchRow = SqliteImplicitManyToManyBatchRow;
typedef _RelationKey = SqliteRelationKey;

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
    final database = sqlite.sqlite3.openInMemory();
    _enableForeignKeys(database);
    return SqliteDatabaseAdapter(database: database, schema: schema);
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
          final database = databasePath == ':memory:'
              ? sqlite.sqlite3.openInMemory()
              : sqlite.sqlite3.open(databasePath);
          _enableForeignKeys(database);
          return SqliteDatabaseAdapter.fromRuntimeSchema(
            database: database,
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
  late final SqliteSqlBuilder _sqlBuilder = SqliteSqlBuilder(
    buildRelationClause: _buildRelationClause,
    qualifiedField: _qualifiedField,
    normalizeValueForStorage: _normalizeValueForStorage,
  );
  late final SqliteRelationMaterializer _relationMaterializer =
      SqliteRelationMaterializer(
        recordContainsAllRelationKeyFields: _recordContainsAllRelationKeyFields,
        selectImplicitManyToManyRows: _selectImplicitManyToManyRows,
        selectImplicitManyToManyRowsBatch: _selectImplicitManyToManyRowsBatch,
        selectRows: _selectRows,
      );
  late final SqliteTransactionManager _transactionManager =
      SqliteTransactionManager(
        executeSql: _database.execute,
        quoteIdentifier: _quoteIdentifier,
      );
  List<int>? _sqliteVersionParts;

  static void _enableForeignKeys(sqlite.Database database) {
    database.execute('PRAGMA foreign_keys = ON');
  }

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
  Future<Map<String, Object?>> upsert(UpsertQuery query) async {
    if (!_supportsSqliteFeature(3, 24, 0)) {
      return _transactionalUpsert(query);
    }

    final conflictFields = _resolveUpsertConflictFields(
      query.model,
      query.where,
    );
    final selectorValues = _extractEqualityPredicateValues(
      query.model,
      query.where,
      requiredFields: conflictFields,
    );
    final createData = _mergeUpsertCreateData(
      query.model,
      query.create,
      selectorValues,
    );
    final insertData = _applyAutomaticFieldValues(
      query.model,
      createData,
      isCreate: true,
    );
    final updateData = _applyAutomaticFieldValues(
      query.model,
      query.update,
      isCreate: false,
    );
    final insertEntries = insertData.entries.toList(growable: false);
    if (insertEntries.isEmpty) {
      throw StateError(
        'SQLite upsert for ${query.model} requires insert data.',
      );
    }

    final columns = insertEntries
        .map((entry) => _columnIdentifier(query.model, entry.key))
        .join(', ');
    final insertPlaceholders = List<String>.filled(insertEntries.length, '?');
    final parameters = <Object?>[];
    for (final entry in insertEntries) {
      parameters.add(
        _normalizeValueForStorage(query.model, entry.key, entry.value),
      );
    }

    final assignments = <String>[];
    if (updateData.isEmpty) {
      final noOpField = conflictFields.first;
      assignments.add(
        '${_columnIdentifier(query.model, noOpField)} = excluded.${_columnIdentifier(query.model, noOpField)}',
      );
    } else {
      for (final entry in updateData.entries) {
        assignments.add('${_columnIdentifier(query.model, entry.key)} = ?');
        parameters.add(
          _normalizeValueForStorage(query.model, entry.key, entry.value),
        );
      }
    }

    final conflictTarget = conflictFields
        .map((field) => _columnIdentifier(query.model, field))
        .join(', ');
    final baseSql =
        'INSERT INTO ${_quoteIdentifier(_mappedTableName(query.model))} ($columns) '
        'VALUES (${insertPlaceholders.join(', ')}) '
        'ON CONFLICT ($conflictTarget) DO UPDATE '
        'SET ${assignments.join(', ')}';

    if (_supportsSqliteFeature(3, 35, 0)) {
      final result = _database.select(
        '$baseSql RETURNING rowid AS ${_quoteIdentifier(_rowIdColumn)}, *',
        parameters,
      );
      final selected = _resultRowToSelectedRow(
        query.model,
        result,
        result.single,
      );
      return Map<String, Object?>.unmodifiable(
        _materializeRecord(
          query.model,
          selected.record,
          include: query.include,
          select: query.select,
        ),
      );
    }

    _database.execute(baseSql, parameters);
    final reloadWhere = _buildEqualityPredicates(
      _finalSelectorValues(conflictFields, selectorValues, updateData),
    );
    final selected = _selectSingleRow(
      model: query.model,
      where: reloadWhere,
      orderBy: const <QueryOrderBy>[],
    );
    if (selected == null) {
      throw StateError(
        'SQLite upsert for ${query.model} could not reload the affected record.',
      );
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
  Future<int> createMany(CreateManyQuery query) async {
    if (query.data.isEmpty) {
      return 0;
    }
    if (!_supportsSqliteFeature(3, 7, 11)) {
      return transaction((_) async {
        var count = 0;
        for (final row in query.data) {
          _insertRecord(
            query.model,
            _applyAutomaticFieldValues(query.model, row, isCreate: true),
          );
          count++;
        }
        return count;
      });
    }

    final groupedRows = <String, _CreateManyBatch>{};
    for (final rawRow in query.data) {
      final row = _applyAutomaticFieldValues(
        query.model,
        rawRow,
        isCreate: true,
      );
      final columns = _orderedInsertColumns(query.model, row);
      final key = columns.join('|');
      final batch = groupedRows.putIfAbsent(
        key,
        () => _CreateManyBatch(columns: columns),
      );
      batch.rows.add(row);
    }

    return transaction((_) async {
      var count = 0;
      for (final batch in groupedRows.values) {
        if (batch.columns.isEmpty) {
          for (final _ in batch.rows) {
            _database.execute(
              'INSERT INTO ${_quoteIdentifier(_mappedTableName(query.model))} DEFAULT VALUES',
            );
            count++;
          }
          continue;
        }

        final columnsSql = batch.columns
            .map((column) => _columnIdentifier(query.model, column))
            .join(', ');
        final singleRowPlaceholders =
            '(${List<String>.filled(batch.columns.length, '?').join(', ')})';
        final valuesSql = List<String>.filled(
          batch.rows.length,
          singleRowPlaceholders,
        ).join(', ');
        final parameters = <Object?>[];
        for (final row in batch.rows) {
          for (final column in batch.columns) {
            parameters.add(
              _normalizeValueForStorage(query.model, column, row[column]),
            );
          }
        }

        _database.execute(
          'INSERT INTO ${_quoteIdentifier(_mappedTableName(query.model))} ($columnsSql) '
          'VALUES $valuesSql${_createManySkipDuplicatesClause(query.model, query.skipDuplicates)}',
          parameters,
        );
        count += query.skipDuplicates
            ? _database.updatedRows
            : batch.rows.length;
      }
      return count;
    });
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) async {
    final result = _database.select(sql, parameters);
    return result
        .map((row) => Map<String, Object?>.unmodifiable(row))
        .toList(growable: false);
  }

  @override
  Future<int> rawExecute(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) async {
    _database.execute(sql, parameters);
    return _database.updatedRows;
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) async {
    if (query.includeStrategy == IncludeStrategy.join &&
        query.cursor == null &&
        query.distinct.isEmpty) {
      final records = await findMany(
        FindManyQuery(
          model: query.model,
          where: query.where,
          orderBy: query.orderBy,
          include: query.include,
          select: query.select,
          includeStrategy: query.includeStrategy,
          skip: query.skip,
          take: 1,
        ),
      );
      if (records.isEmpty) {
        return null;
      }
      return records.first;
    }

    if (query.cursor != null || query.distinct.isNotEmpty) {
      final records = await findMany(
        FindManyQuery(
          model: query.model,
          where: query.where,
          cursor: query.cursor,
          orderBy: query.orderBy,
          distinct: query.distinct,
          include: query.include,
          select: query.select,
          includeStrategy: query.includeStrategy,
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
    if (query.distinct.isNotEmpty) {
      return _findManyWithDistinctPushdown(query);
    }

    if (query.cursor != null) {
      return _findManyWithCursor(query);
    }

    if (query.distinct.isEmpty &&
        (query.includeStrategy == null ||
            query.includeStrategy == IncludeStrategy.join)) {
      final joined = _findManyWithSimpleSingularIncludeJoins(query);
      if (joined != null) {
        return joined
            .map(Map<String, Object?>.unmodifiable)
            .toList(growable: false);
      }
    }

    final rows = _selectRows(
      model: query.model,
      where: query.where,
      orderBy: query.orderBy,
      limit: query.distinct.isEmpty ? query.take : null,
      offset: query.distinct.isEmpty ? query.skip : null,
    );

    final List<Map<String, Object?>> rawRecords;
    if (query.distinct.isEmpty) {
      rawRecords = rows.map((row) => row.record).toList(growable: false);
    } else {
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
      rawRecords = List<Map<String, Object?>>.unmodifiable(taken);
    }

    final materialized = query.includeStrategy == IncludeStrategy.perRow
        ? rawRecords
              .map(
                (raw) => _materializeRecord(
                  query.model,
                  raw,
                  include: query.include,
                  select: query.select,
                ),
              )
              .toList(growable: false)
        : _materializeRecordsBatch(
            query.model,
            rawRecords,
            include: query.include,
            select: query.select,
          );
    return materialized
        .map(Map<String, Object?>.unmodifiable)
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> _findManyWithDistinctPushdown(
    FindManyQuery query,
  ) async {
    final cursor = query.cursor;
    final orderBy = cursor == null
        ? query.orderBy
        : _cursorOrderBy(query.model, query.orderBy);
    final forward = cursor == null || query.take == null || query.take! >= 0;

    _SelectedRow? cursorRow;
    if (cursor != null) {
      cursorRow = _selectSingleDistinctRow(
        model: query.model,
        baseWhere: query.where,
        outerWhere: cursor.where,
        distinctFields: query.distinct,
        orderBy: orderBy,
      );
      if (cursorRow == null) {
        return const <Map<String, Object?>>[];
      }
    }

    final rows = _selectDistinctRows(
      model: query.model,
      baseWhere: query.where,
      outerWhere: const <QueryPredicate>[],
      distinctFields: query.distinct,
      orderBy: orderBy,
      additionalOuterWhere: cursorRow == null
          ? null
          : _buildCursorWindowClause(
              query.model,
              orderBy,
              cursorRow.record,
              forward: forward,
            ),
      resultOrderBy: cursor != null && !forward
          ? _reverseOrderBy(orderBy)
          : orderBy,
      limit: cursor == null ? query.take : query.take?.abs(),
      offset: query.skip,
    );

    var rawRecords = rows.map((row) => row.record).toList(growable: false);
    if (cursor != null && !forward) {
      rawRecords = rawRecords.reversed.toList(growable: false);
    }

    final materialized = query.includeStrategy == IncludeStrategy.perRow
        ? rawRecords
              .map(
                (raw) => _materializeRecord(
                  query.model,
                  raw,
                  include: query.include,
                  select: query.select,
                ),
              )
              .toList(growable: false)
        : _materializeRecordsBatch(
            query.model,
            rawRecords,
            include: query.include,
            select: query.select,
          );
    return materialized
        .map(Map<String, Object?>.unmodifiable)
        .toList(growable: false);
  }

  List<Map<String, Object?>>? _findManyWithSimpleSingularIncludeJoins(
    FindManyQuery query,
  ) {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final joins = _simpleSingularIncludeJoins(
      sourceModel: query.model,
      parentAlias: alias,
      include: query.include,
      context: context,
      depth: 1,
    );
    if (joins == null || joins.isEmpty) {
      return null;
    }
    final flatJoins = _flattenSimpleSingularIncludeJoins(joins);

    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final orderClause = _buildOrderByClause(alias, query.model, query.orderBy);
    final sql = StringBuffer()
      ..write(
        'SELECT ${_quoteIdentifier(alias)}.rowid AS ${_quoteIdentifier(_rowIdColumn)}, ${_quoteIdentifier(alias)}.*',
      );
    for (final join in flatJoins) {
      for (final field in _storedFields(join.relation.targetModel)) {
        sql.write(
          ', ${_qualifiedField(join.alias, join.relation.targetModel, field.name)} AS ${_quoteIdentifier(join.columnAlias(field.name))}',
        );
      }
    }
    sql.write(' FROM ${_tableReference(query.model, alias)}');
    for (final join in flatJoins) {
      sql.write(
        ' LEFT JOIN ${_tableReference(join.relation.targetModel, join.alias)} '
        'ON ${_qualifiedField(join.parentAlias, join.sourceModel, join.relation.localKeyField)} = '
        '${_qualifiedField(join.alias, join.relation.targetModel, join.relation.targetKeyField)}',
      );
    }
    sql.write(' WHERE ${whereClause.sql}');

    final parameters = <Object?>[...whereClause.parameters];
    if (orderClause.isNotEmpty) {
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

    final result = _database.select(sql.toString(), parameters);
    return result
        .map(
          (row) => _materializeJoinedFindManyRow(
            query.model,
            row,
            joins: joins,
            select: query.select,
          ),
        )
        .toList(growable: false);
  }

  Future<List<Map<String, Object?>>> _findManyWithCursor(
    FindManyQuery query,
  ) async {
    final cursor = query.cursor;
    if (cursor == null) {
      return findMany(
        FindManyQuery(
          model: query.model,
          where: query.where,
          orderBy: query.orderBy,
          distinct: query.distinct,
          include: query.include,
          select: query.select,
          skip: query.skip,
          take: query.take,
        ),
      );
    }

    final cursorRow = _selectSingleRow(
      model: query.model,
      where: cursor.where,
      orderBy: const <QueryOrderBy>[],
    );
    if (cursorRow == null) {
      return const <Map<String, Object?>>[];
    }

    final orderBy = _cursorOrderBy(query.model, query.orderBy);
    final forward = query.take == null || query.take! >= 0;
    final rows = _selectRows(
      model: query.model,
      where: query.where,
      additionalWhere: _buildCursorWindowClause(
        query.model,
        orderBy,
        cursorRow.record,
        forward: forward,
      ),
      orderBy: forward ? orderBy : _reverseOrderBy(orderBy),
      limit: query.take?.abs(),
      offset: query.skip,
    );

    var rawRecords = rows.map((row) => row.record).toList(growable: false);
    if (!forward) {
      rawRecords = rawRecords.reversed.toList(growable: false);
    }

    return _materializeRecordsBatch(
      query.model,
      rawRecords,
      include: query.include,
      select: query.select,
    ).map(Map<String, Object?>.unmodifiable).toList(growable: false);
  }

  Map<String, Object?> _materializeJoinedFindManyRow(
    String model,
    sqlite.Row row, {
    required List<_SimpleSingularIncludeJoin> joins,
    required QuerySelect? select,
  }) {
    final record = _normalizeBaseJoinedRecord(model, row);
    final base = SqliteQuerySupport.selectMaterializedRecordFields(
      record: record,
      select: select,
    );
    for (final join in joins) {
      base[join.includeKey] = _materializeJoinedIncludeRecord(join, row);
    }
    return base;
  }

  Map<String, Object?> _normalizeBaseJoinedRecord(
    String model,
    sqlite.Row row,
  ) {
    final record = <String, Object?>{};
    for (final field in _storedFields(model)) {
      record[field.name] = _normalizeValueFromStorage(
        model,
        field.name,
        row[field.databaseName],
      );
    }
    return record;
  }

  Map<String, Object?>? _materializeJoinedIncludeRecord(
    _SimpleSingularIncludeJoin join,
    sqlite.Row row,
  ) {
    if (row[join.columnAlias(join.relation.targetKeyField)] == null) {
      return null;
    }

    final record = <String, Object?>{};
    for (final field in _storedFields(join.relation.targetModel)) {
      record[field.name] = _normalizeValueFromStorage(
        join.relation.targetModel,
        field.name,
        row[join.columnAlias(field.name)],
      );
    }

    final selected = SqliteQuerySupport.selectMaterializedRecordFields(
      record: record,
      select: join.entry.select,
    );
    for (final child in join.children) {
      selected[child.includeKey] = _materializeJoinedIncludeRecord(child, row);
    }
    return selected;
  }

  List<_SimpleSingularIncludeJoin>? _simpleSingularIncludeJoins({
    required String sourceModel,
    required String parentAlias,
    required QueryInclude? include,
    required _SqlBuildContext context,
    required int depth,
  }) {
    if (include == null || include.relations.isEmpty) {
      return const <_SimpleSingularIncludeJoin>[];
    }
    if (depth > 3) {
      return null;
    }

    final joins = <_SimpleSingularIncludeJoin>[];
    for (final relationEntry in include.relations.entries) {
      final entry = relationEntry.value;
      final relation = entry.relation;
      if (relation.cardinality != QueryRelationCardinality.one ||
          relation.storageKind != QueryRelationStorageKind.direct ||
          relation.localKeyFields.length != 1 ||
          relation.targetKeyFields.length != 1) {
        return null;
      }

      final alias = context.nextAlias();
      final children = _simpleSingularIncludeJoins(
        sourceModel: relation.targetModel,
        parentAlias: alias,
        include: entry.include,
        context: context,
        depth: depth + 1,
      );
      if (children == null) {
        return null;
      }

      joins.add(
        _SimpleSingularIncludeJoin(
          alias: alias,
          parentAlias: parentAlias,
          sourceModel: sourceModel,
          includeKey: relationEntry.key,
          entry: entry,
          children: children,
        ),
      );
    }
    return joins;
  }

  List<_SimpleSingularIncludeJoin> _flattenSimpleSingularIncludeJoins(
    List<_SimpleSingularIncludeJoin> joins,
  ) {
    final flat = <_SimpleSingularIncludeJoin>[];

    void visit(List<_SimpleSingularIncludeJoin> nested) {
      for (final join in nested) {
        flat.add(join);
        visit(join.children);
      }
    }

    visit(joins);
    return flat;
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
    return _transactionManager.run(action, this);
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

  Future<Map<String, Object?>> _transactionalUpsert(UpsertQuery query) {
    return transaction((_) async {
      final existing = _selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (existing != null) {
        return update(
          UpdateQuery(
            model: query.model,
            where: query.where,
            data: query.update,
            include: query.include,
            select: query.select,
          ),
        );
      }
      return create(
        CreateQuery(
          model: query.model,
          data: query.create,
          include: query.include,
        ),
      );
    });
  }

  bool _supportsSqliteFeature(int major, int minor, int patch) {
    final version = _sqliteVersionParts ??= _readSqliteVersionParts();
    final requested = <int>[major, minor, patch];
    for (var index = 0; index < requested.length; index++) {
      final actualPart = version[index];
      final requestedPart = requested[index];
      if (actualPart > requestedPart) {
        return true;
      }
      if (actualPart < requestedPart) {
        return false;
      }
    }
    return true;
  }

  List<int> _readSqliteVersionParts() {
    final rows = _database.select('SELECT sqlite_version() AS version');
    if (rows.isEmpty) {
      return const <int>[0, 0, 0];
    }

    final raw = '${rows.first['version'] ?? ''}';
    final parts = raw
        .split(RegExp(r'[^0-9]+'))
        .where((part) => part.isNotEmpty)
        .take(3)
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: true);
    while (parts.length < 3) {
      parts.add(0);
    }
    return List<int>.unmodifiable(parts);
  }

  List<String> _resolveUpsertConflictFields(
    String model,
    List<QueryPredicate> where,
  ) {
    final selectorValues = _extractEqualityPredicateValues(model, where);
    final selectorFields = selectorValues.keys.toSet();
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      throw StateError('Unknown model $model for SQLite upsert.');
    }

    final candidateFieldSets = <List<String>>[];
    if (modelDefinition.primaryKeyFields.isNotEmpty) {
      candidateFieldSets.add(modelDefinition.primaryKeyFields);
    }
    for (final field in modelDefinition.fields) {
      if ((field.isId || field.isUnique) && !field.isList) {
        candidateFieldSets.add(<String>[field.name]);
      }
    }
    candidateFieldSets.addAll(modelDefinition.compoundUniqueFieldSets);

    for (final candidate in candidateFieldSets) {
      if (candidate.length != selectorFields.length) {
        continue;
      }
      if (candidate.every(selectorFields.contains)) {
        return candidate;
      }
    }

    throw StateError(
      'SQLite upsert for $model requires where to match exactly one unique selector.',
    );
  }

  Map<String, Object?> _extractEqualityPredicateValues(
    String model,
    List<QueryPredicate> where, {
    List<String>? requiredFields,
  }) {
    final values = <String, Object?>{};
    for (final predicate in where) {
      if (predicate.operator != 'equals') {
        throw StateError(
          'SQLite upsert for $model only supports equals predicates in where.',
        );
      }
      if (values.containsKey(predicate.field)) {
        throw StateError(
          'SQLite upsert for $model received duplicate predicates for ${predicate.field}.',
        );
      }
      values[predicate.field] = predicate.value;
    }

    if (requiredFields != null) {
      for (final field in requiredFields) {
        if (!values.containsKey(field)) {
          throw StateError(
            'SQLite upsert for $model requires where to include $field.',
          );
        }
      }
    }

    return values;
  }

  Map<String, Object?> _mergeUpsertCreateData(
    String model,
    Map<String, Object?> create,
    Map<String, Object?> selectorValues,
  ) {
    final merged = Map<String, Object?>.from(create);
    for (final entry in selectorValues.entries) {
      if (merged.containsKey(entry.key) && merged[entry.key] != entry.value) {
        throw StateError(
          'SQLite upsert for $model requires create.${entry.key} to match where.${entry.key}.',
        );
      }
      merged[entry.key] = entry.value;
    }
    return merged;
  }

  Map<String, Object?> _finalSelectorValues(
    List<String> conflictFields,
    Map<String, Object?> selectorValues,
    Map<String, Object?> updateData,
  ) {
    final finalValues = <String, Object?>{};
    for (final field in conflictFields) {
      finalValues[field] = updateData.containsKey(field)
          ? updateData[field]
          : selectorValues[field];
    }
    return finalValues;
  }

  List<QueryPredicate> _buildEqualityPredicates(Map<String, Object?> values) {
    return values.entries
        .map(
          (entry) => QueryPredicate(
            field: entry.key,
            operator: 'equals',
            value: entry.value,
          ),
        )
        .toList(growable: false);
  }

  String _createManySkipDuplicatesClause(String model, bool skipDuplicates) {
    if (!skipDuplicates) {
      return '';
    }

    final clauses = _uniqueConstraintFieldSets(model)
        .map(
          (fieldSet) =>
              ' ON CONFLICT (${fieldSet.map((field) => _columnIdentifier(model, field)).join(', ')}) DO NOTHING',
        )
        .join();
    return clauses;
  }

  List<List<String>> _uniqueConstraintFieldSets(String model) {
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      return const <List<String>>[];
    }

    final fieldSets = <List<String>>[];
    if (modelDefinition.primaryKeyFields.isNotEmpty) {
      fieldSets.add(modelDefinition.primaryKeyFields);
    }
    for (final field in modelDefinition.fields) {
      if ((field.isId || field.isUnique) && !field.isList) {
        fieldSets.add(<String>[field.name]);
      }
    }
    for (final fieldSet in modelDefinition.compoundUniqueFieldSets) {
      fieldSets.add(fieldSet);
    }

    final seen = <String>{};
    final unique = <List<String>>[];
    for (final fieldSet in fieldSets) {
      final key = fieldSet.join('|');
      if (seen.add(key)) {
        unique.add(fieldSet);
      }
    }
    return unique;
  }

  List<String> _orderedInsertColumns(String model, Map<String, Object?> row) {
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      return row.keys.toList(growable: false);
    }

    final ordered = <String>[];
    for (final field in modelDefinition.fields) {
      if (row.containsKey(field.name)) {
        ordered.add(field.name);
      }
    }
    for (final field in row.keys) {
      if (!ordered.contains(field)) {
        ordered.add(field);
      }
    }
    return ordered;
  }

  List<_SelectedRow> _selectRows({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    _SqlClause? additionalWhere,
    int? limit,
    int? offset,
  }) {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(context, model, alias, where);
    final combinedWhere = additionalWhere == null
        ? whereClause
        : _combineSqlClauses(<_SqlClause>[whereClause, additionalWhere], 'AND');
    final orderClause = _buildOrderByClause(alias, model, orderBy);
    final sql = StringBuffer()
      ..write(
        'SELECT ${_quoteIdentifier(alias)}.rowid AS ${_quoteIdentifier(_rowIdColumn)}, ${_quoteIdentifier(alias)}.* '
        'FROM ${_tableReference(model, alias)} '
        'WHERE ${combinedWhere.sql}',
      );
    final parameters = <Object?>[...combinedWhere.parameters];
    if (orderClause.isNotEmpty) {
      sql.write(' ORDER BY $orderClause');
    }
    if (limit != null) {
      sql.write(' LIMIT ?');
      parameters.add(limit);
    }
    if (offset != null) {
      sql.write(' OFFSET ?');
      parameters.add(offset);
    }

    final result = _database.select(sql.toString(), parameters);
    return result
        .map((row) => _resultRowToSelectedRow(model, result, row))
        .toList(growable: false);
  }

  List<_SelectedRow> _selectDistinctRows({
    required String model,
    required List<QueryPredicate> baseWhere,
    required List<QueryPredicate> outerWhere,
    required Set<String> distinctFields,
    required List<QueryOrderBy> orderBy,
    _SqlClause? additionalOuterWhere,
    List<QueryOrderBy>? resultOrderBy,
    int? limit,
    int? offset,
  }) {
    final baseContext = _SqlBuildContext();
    const baseAlias = 'b0';
    final baseWhereClause = _buildWhereClause(
      baseContext,
      model,
      baseAlias,
      baseWhere,
    );

    final outerContext = _SqlBuildContext();
    const outerAlias = 't0';
    final outerWhereClause = _buildWhereClause(
      outerContext,
      model,
      outerAlias,
      outerWhere,
    );
    final combinedOuterWhere = additionalOuterWhere == null
        ? outerWhereClause
        : _combineSqlClauses(<_SqlClause>[
            outerWhereClause,
            additionalOuterWhere,
          ], 'AND');

    const baseCte = '_distinct_base';
    const rankedCte = '_distinct_ranked';
    const distinctCte = '_distinct';
    const rankedAlias = 'd0';
    final rowNumberOrderClause = _buildDistinctWindowOrderByClause(
      rankedAlias,
      model,
      orderBy,
      rowLocatorColumn: _rowIdColumn,
    );
    final partitionClause = distinctFields
        .map((field) => _qualifiedField(rankedAlias, model, field))
        .join(', ');

    final sql = StringBuffer()
      ..write(
        'WITH ${_quoteIdentifier(baseCte)} AS ('
        'SELECT ${_quoteIdentifier(baseAlias)}.rowid AS ${_quoteIdentifier(_rowIdColumn)}, ${_quoteIdentifier(baseAlias)}.* '
        'FROM ${_tableReference(model, baseAlias)} '
        'WHERE ${baseWhereClause.sql}'
        '), ${_quoteIdentifier(rankedCte)} AS ('
        'SELECT ${_quoteIdentifier(rankedAlias)}.*, '
        'ROW_NUMBER() OVER ('
        'PARTITION BY $partitionClause '
        'ORDER BY $rowNumberOrderClause'
        ') AS ${_quoteIdentifier(_distinctRowNumberColumn)} '
        'FROM ${_rawTableReference(baseCte, rankedAlias)}'
        '), ${_quoteIdentifier(distinctCte)} AS ('
        'SELECT * FROM ${_quoteIdentifier(rankedCte)} '
        'WHERE ${_quoteIdentifier(_distinctRowNumberColumn)} = 1'
        ') '
        'SELECT ${_quoteIdentifier(outerAlias)}.* '
        'FROM ${_rawTableReference(distinctCte, outerAlias)} '
        'WHERE ${combinedOuterWhere.sql}',
      );

    final parameters = <Object?>[
      ...baseWhereClause.parameters,
      ...combinedOuterWhere.parameters,
    ];
    final effectiveOrderBy = resultOrderBy ?? orderBy;
    if (effectiveOrderBy.isNotEmpty) {
      sql.write(
        ' ORDER BY ${_buildOrderByClause(outerAlias, model, effectiveOrderBy)}',
      );
    }
    if (limit != null) {
      sql.write(' LIMIT ?');
      parameters.add(limit);
    }
    if (offset != null) {
      sql.write(' OFFSET ?');
      parameters.add(offset);
    }

    final result = _database.select(sql.toString(), parameters);
    return result
        .map((row) => _resultRowToSelectedRow(model, result, row))
        .toList(growable: false);
  }

  _SelectedRow? _selectSingleDistinctRow({
    required String model,
    required List<QueryPredicate> baseWhere,
    required List<QueryPredicate> outerWhere,
    required Set<String> distinctFields,
    required List<QueryOrderBy> orderBy,
  }) {
    final rows = _selectDistinctRows(
      model: model,
      baseWhere: baseWhere,
      outerWhere: outerWhere,
      distinctFields: distinctFields,
      orderBy: orderBy,
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.single;
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

  List<QueryOrderBy> _cursorOrderBy(String model, List<QueryOrderBy> orderBy) {
    if (orderBy.isNotEmpty) {
      return orderBy;
    }
    final primaryKeyFields =
        _schema.findModel(model)?.primaryKeyFields ?? const <String>[];
    return primaryKeyFields
        .map((field) => QueryOrderBy(field: field, direction: SortOrder.asc))
        .toList(growable: false);
  }

  List<QueryOrderBy> _reverseOrderBy(List<QueryOrderBy> orderBy) {
    return orderBy
        .map(
          (entry) => QueryOrderBy(
            field: entry.field,
            direction: entry.direction == SortOrder.asc
                ? SortOrder.desc
                : SortOrder.asc,
          ),
        )
        .toList(growable: false);
  }

  String _buildDistinctWindowOrderByClause(
    String alias,
    String model,
    List<QueryOrderBy> orderBy, {
    required String rowLocatorColumn,
  }) {
    final parts = <String>[];
    if (orderBy.isNotEmpty) {
      parts.add(_buildOrderByClause(alias, model, orderBy));
    }
    parts.add('${_qualifiedRawField(alias, rowLocatorColumn)} ASC');
    return parts.join(', ');
  }

  _SqlClause _buildCursorWindowClause(
    String model,
    List<QueryOrderBy> orderBy,
    Map<String, Object?> cursorRecord, {
    required bool forward,
  }) {
    if (orderBy.isEmpty) {
      return (sql: '1 = 1', parameters: <Object?>[]);
    }

    final alias = 't0';
    final branches = <_SqlClause>[];
    for (var index = 0; index < orderBy.length; index++) {
      final branchParts = <String>[];
      final branchParameters = <Object?>[];
      for (var prefixIndex = 0; prefixIndex < index; prefixIndex++) {
        final equality = _cursorEqualityClause(
          alias,
          model,
          orderBy[prefixIndex].field,
          cursorRecord[orderBy[prefixIndex].field],
        );
        branchParts.add(equality.sql);
        branchParameters.addAll(equality.parameters);
      }
      final comparison = _cursorComparisonClause(
        alias,
        model,
        orderBy[index],
        cursorRecord[orderBy[index].field],
        forward: forward,
      );
      branchParts.add(comparison.sql);
      branchParameters.addAll(comparison.parameters);
      branches.add((
        sql: branchParts.map((part) => '($part)').join(' AND '),
        parameters: branchParameters,
      ));
    }

    final equalityParts = <String>[];
    final equalityParameters = <Object?>[];
    for (final entry in orderBy) {
      final equality = _cursorEqualityClause(
        alias,
        model,
        entry.field,
        cursorRecord[entry.field],
      );
      equalityParts.add(equality.sql);
      equalityParameters.addAll(equality.parameters);
    }
    branches.add((
      sql: equalityParts.map((part) => '($part)').join(' AND '),
      parameters: equalityParameters,
    ));

    return _combineSqlClauses(branches, 'OR');
  }

  _SqlClause _cursorEqualityClause(
    String alias,
    String model,
    String field,
    Object? value,
  ) {
    final qualifiedField = _qualifiedField(alias, model, field);
    if (value == null) {
      return (sql: '$qualifiedField IS NULL', parameters: <Object?>[]);
    }
    return (
      sql: '$qualifiedField = ?',
      parameters: <Object?>[_normalizeValueForStorage(model, field, value)],
    );
  }

  _SqlClause _cursorComparisonClause(
    String alias,
    String model,
    QueryOrderBy orderBy,
    Object? value, {
    required bool forward,
  }) {
    final qualifiedField = _qualifiedField(alias, model, orderBy.field);
    if (value == null) {
      return (sql: '1 = 0', parameters: <Object?>[]);
    }
    final ascending = orderBy.direction == SortOrder.asc;
    final operator = forward
        ? (ascending ? '>' : '<')
        : (ascending ? '<' : '>');
    return (
      sql: '$qualifiedField $operator ?',
      parameters: <Object?>[
        _normalizeValueForStorage(model, orderBy.field, value),
      ],
    );
  }

  _SqlClause _combineSqlClauses(List<_SqlClause> clauses, String operator) {
    if (clauses.isEmpty) {
      return (sql: '1 = 1', parameters: <Object?>[]);
    }
    if (clauses.length == 1) {
      return clauses.single;
    }
    return (
      sql: clauses.map((clause) => '(${clause.sql})').join(' $operator '),
      parameters: clauses
          .expand((clause) => clause.parameters)
          .toList(growable: false),
    );
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
    return _relationMaterializer.materializeRecord(
      model,
      record,
      include: include,
      select: select,
    );
  }

  /// Materializes a batch of records, resolving includes with a single query
  /// per relation level instead of one query per parent row (N+1 avoidance).
  List<Map<String, Object?>> _materializeRecordsBatch(
    String model,
    List<Map<String, Object?>> rawRecords, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) {
    return _relationMaterializer.materializeRecordsBatch(
      model,
      rawRecords,
      include: include,
      select: select,
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

  Iterable<RuntimeFieldView> _storedFields(String model) {
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      return const <RuntimeFieldView>[];
    }
    return modelDefinition.fields.where(
      (field) => field.kind != RuntimeFieldKind.relation,
    );
  }

  _SqlClause _buildWhereClause(
    _SqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    return _sqlBuilder.buildWhereClause(context, model, alias, predicates);
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
    return (sql: clause.sql, parameters: clause.parameters);
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

  List<_ImplicitManyToManyBatchRow> _selectImplicitManyToManyRowsBatch({
    required String sourceModel,
    required List<Map<String, Object?>> sourceRecords,
    required QueryRelation relation,
  }) {
    if (sourceRecords.isEmpty) {
      return const <_ImplicitManyToManyBatchRow>[];
    }

    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final context = _SqlBuildContext();
    final targetAlias = context.nextAlias();
    final joinAlias = context.nextAlias();
    final parameters = <Object?>[];
    final whereBranches = <String>[];
    for (final sourceRecord in sourceRecords) {
      final branchClauses = <String>[];
      for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
        branchClauses.add(
          '${_qualifiedRawField(joinAlias, storage.sourceJoinColumns[index])} = ?',
        );
        parameters.add(
          _normalizeValueForStorage(
            sourceModel,
            relation.localKeyFields[index],
            sourceRecord[relation.localKeyFields[index]],
          ),
        );
      }
      whereBranches.add('(${branchClauses.join(' AND ')})');
    }

    final sourceSelects = <String>[];
    for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
      sourceSelects.add(
        '${_qualifiedRawField(joinAlias, storage.sourceJoinColumns[index])} AS ${_quoteIdentifier('__src_$index')}',
      );
    }

    final result = _database.select(
      'SELECT ${sourceSelects.join(', ')}, ${_quoteIdentifier(targetAlias)}.* '
      'FROM ${_tableReference(relation.targetModel, targetAlias)} '
      'JOIN ${_rawTableReference(storage.tableName, joinAlias)} '
      'ON ${_qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: relation.targetModel, rightFields: relation.targetKeyFields)} '
      'WHERE ${whereBranches.join(' OR ')}',
      parameters,
    );

    return result
        .map((row) {
          final sourceKey = _RelationKey(
            List<Object?>.generate(
              storage.sourceJoinColumns.length,
              (index) => _normalizeValueFromStorage(
                sourceModel,
                relation.localKeyFields[index],
                row['__src_$index'],
              ),
              growable: false,
            ),
          );
          final targetRecord = <String, Object?>{};
          for (final field in _storedFields(relation.targetModel)) {
            targetRecord[field.name] = _normalizeValueFromStorage(
              relation.targetModel,
              field.name,
              row[field.databaseName],
            );
          }
          return _ImplicitManyToManyBatchRow(
            sourceKey: sourceKey,
            record: targetRecord,
          );
        })
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
    return (sql: clause.sql, parameters: clause.parameters);
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

  bool _recordContainsAllRelationKeyFields(
    Map<String, Object?> record,
    List<String> fields,
  ) {
    for (final field in fields) {
      if (record[field] == null) {
        return false;
      }
    }
    return true;
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
      buildClause: ({required String sql, required List<Object?> parameters}) =>
          (sql: sql, parameters: parameters),
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
    return _sqlBuilder.buildOrderByClause(alias, model, orderBy);
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
const String _distinctRowNumberColumn = '__distinct_row_number__';

class _CreateManyBatch {
  _CreateManyBatch({required this.columns});

  final List<String> columns;
  final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
}

class _SimpleSingularIncludeJoin {
  const _SimpleSingularIncludeJoin({
    required this.alias,
    required this.parentAlias,
    required this.sourceModel,
    required this.includeKey,
    required this.entry,
    required this.children,
  });

  final String alias;
  final String parentAlias;
  final String sourceModel;
  final String includeKey;
  final QueryIncludeEntry entry;
  final List<_SimpleSingularIncludeJoin> children;

  QueryRelation get relation => entry.relation;

  String columnAlias(String field) => '__join_${alias}_$field';
}
