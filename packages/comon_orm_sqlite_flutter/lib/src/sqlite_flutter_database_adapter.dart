import 'dart:convert';

import 'package:comon_orm/comon_orm.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_flutter_bootstrap.dart';
import 'sqlite_flutter_database_factory.dart';
import 'sqlite_flutter_schema_applier.dart';

/// Factory signature used by schema-based open helpers.
typedef SqliteFlutterAdapterFactory =
    Future<SqliteFlutterDatabaseAdapter> Function({
      required String databasePath,
      required Database database,
      required SchemaDocument schema,
    });

/// SQLite `DatabaseAdapter` implementation backed by `sqflite_common`.
class SqliteFlutterDatabaseAdapter implements DatabaseAdapter {
  /// Creates an adapter from an open SQLite [database] and parsed [schema].
  SqliteFlutterDatabaseAdapter({
    required Database database,
    required SchemaDocument schema,
  }) : _executor = database,
       _database = database,
       _schema = schema;

  SqliteFlutterDatabaseAdapter._transaction({
    required DatabaseExecutor executor,
    required SchemaDocument schema,
  }) : _executor = executor,
       _database = null,
       _schema = schema;

  /// Opens an in-memory adapter for tests and ephemeral workflows.
  static Future<SqliteFlutterDatabaseAdapter> openInMemory({
    required SchemaDocument schema,
    DatabaseFactory? databaseFactory,
  }) async {
    final factory =
        databaseFactory ?? await createDefaultSqliteFlutterDatabaseFactory();
    final database = await factory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        singleInstance: false,
      ),
    );
    return SqliteFlutterDatabaseAdapter(database: database, schema: schema);
  }

  /// Loads a validated schema, resolves its datasource, and opens an adapter.
  static Future<SqliteFlutterDatabaseAdapter> openFromSchemaPath({
    required String schemaPath,
    String? databasePath,
    String? datasourceName,
    SchemaWorkflow workflow = const SchemaWorkflow(),
    DatabaseFactory? databaseFactory,
    SqliteFlutterAdapterFactory? adapterFactory,
  }) async {
    final bootstrap = SqliteFlutterBootstrap(workflow: workflow);
    final opened = await bootstrap.openFromSchemaPath(
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
      databaseFactory: databaseFactory,
    );
    return (adapterFactory ?? _defaultAdapterFactory)(
      databasePath: opened.databasePath,
      database: opened.database,
      schema: opened.schema,
    );
  }

  /// Loads a schema source, resolves its datasource, and opens an adapter.
  static Future<SqliteFlutterDatabaseAdapter> openFromSchemaSource({
    required String source,
    String filePath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    SchemaWorkflow workflow = const SchemaWorkflow(),
    DatabaseFactory? databaseFactory,
    SqliteFlutterAdapterFactory? adapterFactory,
  }) async {
    final bootstrap = SqliteFlutterBootstrap(workflow: workflow);
    final opened = await bootstrap.openFromSchemaSource(
      source: source,
      filePath: filePath,
      databasePath: databasePath,
      datasourceName: datasourceName,
      databaseFactory: databaseFactory,
    );
    return (adapterFactory ?? _defaultAdapterFactory)(
      databasePath: opened.databasePath,
      database: opened.database,
      schema: opened.schema,
    );
  }

  /// Loads a schema, applies it to the target database, and opens an adapter.
  static Future<SqliteFlutterDatabaseAdapter> openAndApplyFromSchemaPath({
    required String schemaPath,
    String? databasePath,
    String? datasourceName,
    SchemaWorkflow workflow = const SchemaWorkflow(),
    DatabaseFactory? databaseFactory,
    SqliteFlutterAdapterFactory? adapterFactory,
  }) async {
    final bootstrap = SqliteFlutterBootstrap(workflow: workflow);
    final opened = await bootstrap.openFromSchemaPath(
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
      databaseFactory: databaseFactory,
    );
    await const SqliteFlutterSchemaApplier().apply(
      opened.database,
      opened.schema,
    );
    return (adapterFactory ?? _defaultAdapterFactory)(
      databasePath: opened.databasePath,
      database: opened.database,
      schema: opened.schema,
    );
  }

  /// Loads schema source, applies it to the target database, and opens an adapter.
  static Future<SqliteFlutterDatabaseAdapter> openAndApplyFromSchemaSource({
    required String source,
    String filePath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    SchemaWorkflow workflow = const SchemaWorkflow(),
    DatabaseFactory? databaseFactory,
    SqliteFlutterAdapterFactory? adapterFactory,
  }) async {
    final bootstrap = SqliteFlutterBootstrap(workflow: workflow);
    final opened = await bootstrap.openFromSchemaSource(
      source: source,
      filePath: filePath,
      databasePath: databasePath,
      datasourceName: datasourceName,
      databaseFactory: databaseFactory,
    );
    await const SqliteFlutterSchemaApplier().apply(
      opened.database,
      opened.schema,
    );
    return (adapterFactory ?? _defaultAdapterFactory)(
      databasePath: opened.databasePath,
      database: opened.database,
      schema: opened.schema,
    );
  }

  static Future<SqliteFlutterDatabaseAdapter> _defaultAdapterFactory({
    required String databasePath,
    required Database database,
    required SchemaDocument schema,
  }) async {
    return SqliteFlutterDatabaseAdapter(database: database, schema: schema);
  }

  final DatabaseExecutor _executor;
  final Database? _database;
  final SchemaDocument _schema;

  /// Clock used for automatic field values such as `@updatedAt`.
  DateTime Function() now = () => DateTime.now().toUtc();

  /// Closes the underlying database if this adapter owns the top-level handle.
  Future<void> close() {
    return _database?.close() ?? Future<void>.value();
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
    final result = await _executor.rawQuery(
      'SELECT COUNT(*) AS ${_quoteIdentifier('count')} '
      'FROM ${_tableReference(query.model, alias)} '
      'WHERE ${whereClause.sql}',
      whereClause.parameters,
    );
    return result.first['count'] as int;
  }

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) async {
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

    final rows = await _executor.rawQuery(sql, parameters);
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

    if (query.having.isNotEmpty) {
      final havingParts = <String>[];
      for (final pred in query.having) {
        final clause = _buildAggregatePredicateClause(alias, query.model, pred);
        havingParts.add('(${clause.sql})');
        parameters.addAll(clause.parameters);
      }
      sql.write(' HAVING ${havingParts.join(' AND ')}');
    }

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

    final rows = await _executor.rawQuery(sql.toString(), parameters);
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
    return transaction((tx) async {
      final txAdapter = tx as SqliteFlutterDatabaseAdapter;
      final inserted = await txAdapter._insertRecord(
        query.model,
        txAdapter._applyAutomaticFieldValues(
          query.model,
          query.data,
          isCreate: true,
        ),
      );

      for (final nestedWrite in query.nestedCreates) {
        final parentKeyValues = txAdapter._extractRequiredRelationKeyValues(
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
          final childRecord = await txAdapter
              ._insertRecord(nestedWrite.relation.targetModel, {
                ...txAdapter._applyAutomaticFieldValues(
                  nestedWrite.relation.targetModel,
                  nestedRecord,
                  isCreate: true,
                ),
                ...directAssignments,
              });

          if (nestedWrite.relation.storageKind ==
              QueryRelationStorageKind.implicitManyToMany) {
            final childKeyValues = txAdapter._extractRequiredRelationKeyValues(
              childRecord.record,
              nestedWrite.relation.targetKeyFields,
              model: nestedWrite.relation.targetModel,
              relation: nestedWrite.relation,
              role: 'child',
            );
            await txAdapter._insertImplicitManyToManyLink(
              sourceModel: query.model,
              relation: nestedWrite.relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: childKeyValues,
            );
          }
        }
      }

      return Map<String, Object?>.unmodifiable(
        await txAdapter._materializeRecord(
          query.model,
          inserted.record,
          include: query.include,
          select: null,
        ),
      );
    });
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) async {
    return transaction((tx) async {
      final txAdapter = tx as SqliteFlutterDatabaseAdapter;
      final selected = await txAdapter._selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (selected == null) {
        throw StateError('No record found for delete in ${query.model}.');
      }

      await txAdapter._executor.rawDelete(
        'DELETE FROM ${_quoteIdentifier(_mappedTableName(query.model))} '
        'WHERE rowid = ?',
        <Object?>[selected.rowId],
      );

      return Map<String, Object?>.unmodifiable(
        await txAdapter._materializeRecord(
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
    return _executor.rawDelete(
      'DELETE FROM ${_quoteIdentifier(_mappedTableName(query.model))} AS ${_quoteIdentifier(alias)} '
      'WHERE ${whereClause.sql}',
      whereClause.parameters,
    );
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) async {
    final selected = await _selectSingleRow(
      model: query.model,
      where: query.where,
      orderBy: query.orderBy,
      offset: query.skip,
    );
    if (selected == null) {
      return null;
    }

    return Map<String, Object?>.unmodifiable(
      await _materializeRecord(
        query.model,
        selected.record,
        include: query.include,
        select: query.select,
      ),
    );
  }

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) async {
    final rows = await _selectRows(
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

    final materialized = <Map<String, Object?>>[];
    for (final record in records) {
      materialized.add(
        Map<String, Object?>.unmodifiable(
          await _materializeRecord(
            query.model,
            record,
            include: query.include,
            select: query.select,
          ),
        ),
      );
    }
    return List<Map<String, Object?>>.unmodifiable(materialized);
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) async {
    final selected = await _selectSingleRow(
      model: query.model,
      where: query.where,
      orderBy: const <QueryOrderBy>[],
    );
    if (selected == null) {
      return null;
    }

    return Map<String, Object?>.unmodifiable(
      await _materializeRecord(
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
    if (_database == null) {
      return action(this);
    }

    final nowProvider = now;
    return _database.transaction<T>((txn) async {
      final txAdapter = SqliteFlutterDatabaseAdapter._transaction(
        executor: txn,
        schema: _schema,
      )..now = nowProvider;
      return action(txAdapter);
    });
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) async {
    return transaction((tx) async {
      final txAdapter = tx as SqliteFlutterDatabaseAdapter;
      final selected = await txAdapter._selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (selected == null) {
        throw StateError('No record found for update in ${query.model}.');
      }

      final updateData = txAdapter._applyAutomaticFieldValues(
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
        await txAdapter._executor.rawUpdate(
          'UPDATE ${_quoteIdentifier(_mappedTableName(query.model))} '
          'SET ${assignments.join(', ')} '
          'WHERE rowid = ?',
          parameters,
        );
      }

      final updated = await txAdapter._selectRowByRowId(
        query.model,
        selected.rowId,
      );
      return Map<String, Object?>.unmodifiable(
        await txAdapter._materializeRecord(
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

    return _executor.rawUpdate(
      'UPDATE ${_quoteIdentifier(_mappedTableName(query.model))} AS ${_quoteIdentifier(alias)} '
      'SET ${assignments.join(', ')} '
      'WHERE ${whereClause.sql}',
      parameters,
    );
  }

  Future<_SelectedRow> _selectRowByRowId(String model, int rowId) async {
    final result = await _executor.rawQuery(
      'SELECT rowid AS ${_quoteIdentifier(_rowIdColumn)}, * '
      'FROM ${_quoteIdentifier(_mappedTableName(model))} '
      'WHERE rowid = ?',
      <Object?>[rowId],
    );
    if (result.isEmpty) {
      throw StateError('No row found for $model with rowid $rowId.');
    }
    return _resultRowToSelectedRow(model, result.first);
  }

  Map<String, Object?> _applyAutomaticFieldValues(
    String model,
    Map<String, Object?> data, {
    required bool isCreate,
  }) {
    final nextData = Map<String, Object?>.from(data);
    final timestamp = now();

    for (final field in _updatedAtFields(model)) {
      if (isCreate) {
        nextData.putIfAbsent(field.name, () => timestamp);
      } else {
        nextData[field.name] = timestamp;
      }
    }

    return nextData;
  }

  Iterable<FieldDefinition> _updatedAtFields(String model) {
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      return const <FieldDefinition>[];
    }

    return modelDefinition.fields.where((field) => field.isUpdatedAt);
  }

  Future<List<_SelectedRow>> _selectRows({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    int? limit,
    int? offset,
  }) async {
    final context = _SqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(context, model, alias, where);
    final orderClause = _buildOrderByClause(alias, model, orderBy);
    final sql = StringBuffer()
      ..write(
        'SELECT ${_quoteIdentifier(alias)}.rowid AS ${_quoteIdentifier(_rowIdColumn)}, ${_quoteIdentifier(alias)}.* '
        'FROM ${_tableReference(model, alias)} '
        'WHERE ${whereClause.sql}',
      );
    final parameters = <Object?>[...whereClause.parameters];

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

    final result = await _executor.rawQuery(sql.toString(), parameters);
    return result
        .map((row) => _resultRowToSelectedRow(model, row))
        .toList(growable: false);
  }

  Future<_SelectedRow?> _selectSingleRow({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    int? offset,
  }) async {
    final rows = await _selectRows(
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

  Future<_SelectedRow> _insertRecord(
    String model,
    Map<String, Object?> data,
  ) async {
    final entries = data.entries.toList(growable: false);
    if (entries.isEmpty) {
      final rowId = await _executor.rawInsert(
        'INSERT INTO ${_quoteIdentifier(_mappedTableName(model))} DEFAULT VALUES',
      );
      return _selectRowByRowId(model, rowId);
    }

    final columns = entries
        .map((entry) => _columnIdentifier(model, entry.key))
        .join(', ');
    final placeholders = List<String>.filled(entries.length, '?').join(', ');
    final parameters = entries
        .map(
          (entry) => _normalizeValueForStorage(model, entry.key, entry.value),
        )
        .toList(growable: false);

    final rowId = await _executor.rawInsert(
      'INSERT INTO ${_quoteIdentifier(_mappedTableName(model))} ($columns) VALUES ($placeholders)',
      parameters,
    );
    return _selectRowByRowId(model, rowId);
  }

  Future<Map<String, Object?>> _materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    final base = <String, Object?>{};

    if (select == null || select.fields.isEmpty) {
      base.addAll(record);
    } else {
      for (final field in select.fields) {
        if (record.containsKey(field)) {
          base[field] = record[field];
        }
      }
    }

    if (include != null) {
      for (final entry in include.relations.entries) {
        base[entry.key] = await _resolveInclude(model, record, entry.value);
      }
    }

    return base;
  }

  Future<Object?> _resolveInclude(
    String sourceModel,
    Map<String, Object?> sourceRecord,
    QueryIncludeEntry entry,
  ) async {
    if (entry.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      final relatedRows = await _selectImplicitManyToManyRows(
        sourceModel: sourceModel,
        sourceRecord: sourceRecord,
        relation: entry.relation,
      );
      final materialized = <Map<String, Object?>>[];
      for (final row in relatedRows) {
        materialized.add(
          Map<String, Object?>.unmodifiable(
            await _materializeRecord(
              entry.relation.targetModel,
              row.record,
              include: entry.include,
              select: entry.select,
            ),
          ),
        );
      }
      return List<Map<String, Object?>>.unmodifiable(materialized);
    }

    if (!_recordContainsAllRelationKeyFields(
      sourceRecord,
      entry.relation.localKeyFields,
    )) {
      return entry.relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
    }

    final wherePredicates = <QueryPredicate>[];
    for (
      var index = 0;
      index < entry.relation.targetKeyFields.length;
      index++
    ) {
      wherePredicates.add(
        QueryPredicate(
          field: entry.relation.targetKeyFields[index],
          operator: 'equals',
          value: sourceRecord[entry.relation.localKeyFields[index]],
        ),
      );
    }

    final relatedRows = await _selectRows(
      model: entry.relation.targetModel,
      where: wherePredicates,
      orderBy: const <QueryOrderBy>[],
    );

    final materialized = <Map<String, Object?>>[];
    for (final row in relatedRows) {
      materialized.add(
        Map<String, Object?>.unmodifiable(
          await _materializeRecord(
            entry.relation.targetModel,
            row.record,
            include: entry.include,
            select: entry.select,
          ),
        ),
      );
    }

    if (entry.relation.cardinality == QueryRelationCardinality.one) {
      if (materialized.isEmpty) {
        return null;
      }
      return materialized.first;
    }

    return List<Map<String, Object?>>.unmodifiable(materialized);
  }

  _SelectedRow _resultRowToSelectedRow(String model, Map<String, Object?> row) {
    final record = <String, Object?>{};
    for (final column in row.keys) {
      if (column == _rowIdColumn) {
        continue;
      }
      final logicalField =
          _modelDefinition(model).findFieldByDatabaseName(column)?.name ??
          column;
      record[logicalField] = _normalizeValueFromStorage(
        model,
        logicalField,
        row[column],
      );
    }
    return _SelectedRow(rowId: row[_rowIdColumn] as int, record: record);
  }

  _SqlClause _buildWhereClause(
    _SqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    if (predicates.isEmpty) {
      return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }

    final clauses = predicates
        .map(
          (predicate) =>
              _buildPredicateClause(context, model, alias, predicate),
        )
        .toList(growable: false);
    return _joinClauses(clauses, 'AND');
  }

  _SqlClause _buildPredicateClause(
    _SqlBuildContext context,
    String model,
    String alias,
    QueryPredicate predicate,
  ) {
    switch (predicate.operator) {
      case 'logicalAnd':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        return _joinClauses(
          group.branches
              .map((branch) => _buildWhereClause(context, model, alias, branch))
              .toList(growable: false),
          'AND',
        );
      case 'logicalOr':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const _SqlClause(sql: '1 = 0', parameters: <Object?>[]);
        }
        return _joinClauses(
          group.branches
              .map((branch) => _buildWhereClause(context, model, alias, branch))
              .toList(growable: false),
          'OR',
        );
      case 'logicalNot':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final negated = group.branches
            .map((branch) => _buildWhereClause(context, model, alias, branch))
            .map(
              (branchClause) => _SqlClause(
                sql: 'NOT (${branchClause.sql})',
                parameters: branchClause.parameters,
              ),
            )
            .toList(growable: false);
        return _joinClauses(negated, 'AND');
      case 'relationSome':
      case 'relationNone':
      case 'relationEvery':
      case 'relationIs':
      case 'relationIsNot':
        return _buildRelationClause(
          context,
          model,
          alias,
          predicate.operator,
          predicate.value as QueryRelationFilter,
        );
      case 'equals':
        return _binaryClause(
          alias,
          predicate.field,
          '=',
          predicate.value,
          model,
        );
      case 'not':
        if (predicate.value == null) {
          return _SqlClause(
            sql:
                '${_qualifiedField(alias, model, predicate.field)} IS NOT NULL',
            parameters: const <Object?>[],
          );
        }
        return _binaryClause(
          alias,
          predicate.field,
          '!=',
          predicate.value,
          model,
        );
      case 'contains':
        return _SqlClause(
          sql: '${_qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['%${predicate.value}%'],
        );
      case 'startsWith':
        return _SqlClause(
          sql: '${_qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['${predicate.value}%'],
        );
      case 'endsWith':
        return _SqlClause(
          sql: '${_qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['%${predicate.value}'],
        );
      case 'containsInsensitive':
        return _SqlClause(
          sql:
              'LOWER(${_qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['%${predicate.value}%'],
        );
      case 'startsWithInsensitive':
        return _SqlClause(
          sql:
              'LOWER(${_qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['${predicate.value}%'],
        );
      case 'endsWithInsensitive':
        return _SqlClause(
          sql:
              'LOWER(${_qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['%${predicate.value}'],
        );
      case 'in':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return const _SqlClause(sql: '1 = 0', parameters: <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return _SqlClause(
          sql:
              '${_qualifiedField(alias, model, predicate.field)} IN ($placeholders)',
          parameters: values
              .map(
                (value) =>
                    _normalizeValueForStorage(model, predicate.field, value),
              )
              .toList(growable: false),
        );
      case 'notIn':
        final notInValues = predicate.value as List<Object?>;
        if (notInValues.isEmpty) {
          return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final notInPlaceholders = List<String>.filled(
          notInValues.length,
          '?',
        ).join(', ');
        return _SqlClause(
          sql:
              '${_qualifiedField(alias, model, predicate.field)} NOT IN ($notInPlaceholders)',
          parameters: notInValues
              .map(
                (value) =>
                    _normalizeValueForStorage(model, predicate.field, value),
              )
              .toList(growable: false),
        );
      case 'gt':
        return _binaryClause(
          alias,
          predicate.field,
          '>',
          predicate.value,
          model,
        );
      case 'gte':
        return _binaryClause(
          alias,
          predicate.field,
          '>=',
          predicate.value,
          model,
        );
      case 'lt':
        return _binaryClause(
          alias,
          predicate.field,
          '<',
          predicate.value,
          model,
        );
      case 'lte':
        return _binaryClause(
          alias,
          predicate.field,
          '<=',
          predicate.value,
          model,
        );
      default:
        throw UnsupportedError(
          'Unsupported predicate operator ${predicate.operator}.',
        );
    }
  }

  _SqlClause _buildRelationClause(
    _SqlBuildContext context,
    String sourceModel,
    String sourceAlias,
    String operator,
    QueryRelationFilter filter,
  ) {
    if (filter.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      return _buildImplicitManyToManyRelationClause(
        context,
        sourceModel,
        sourceAlias,
        operator,
        filter,
      );
    }

    final targetAlias = context.nextAlias();
    final nestedClause = _buildWhereClause(
      context,
      filter.relation.targetModel,
      targetAlias,
      filter.predicates,
    );
    final joinClause = _qualifiedFieldEqualityClause(
      leftAlias: targetAlias,
      leftModel: filter.relation.targetModel,
      leftFields: filter.relation.targetKeyFields,
      rightAlias: sourceAlias,
      rightModel: sourceModel,
      rightFields: filter.relation.localKeyFields,
    );

    String predicateSql;
    List<Object?> parameters;

    switch (operator) {
      case 'relationSome':
      case 'relationIs':
        predicateSql = 'EXISTS';
        parameters = nestedClause.parameters;
      case 'relationNone':
      case 'relationIsNot':
        predicateSql = 'NOT EXISTS';
        parameters = nestedClause.parameters;
      case 'relationEvery':
        predicateSql = 'NOT EXISTS';
        parameters = nestedClause.parameters;
      default:
        throw UnsupportedError('Unsupported relation operator $operator.');
    }

    final nestedSql = switch (operator) {
      'relationEvery' => '$joinClause AND NOT (${nestedClause.sql})',
      _ => '$joinClause AND ${nestedClause.sql}',
    };

    return _SqlClause(
      sql:
          '$predicateSql ('
          'SELECT 1 FROM ${_tableReference(filter.relation.targetModel, targetAlias)} '
          'WHERE $nestedSql'
          ')',
      parameters: parameters,
    );
  }

  Future<void> _insertImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) async {
    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final columnNames = [
      ...storage.sourceJoinColumns,
      ...storage.targetJoinColumns,
    ];
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceKeyFields.length; index++) {
      parameters.add(
        _normalizeValueForStorage(
          storage.sourceModel.name,
          storage.sourceKeyFields[index],
          sourceKeyValues[relation.localKeyFields[index]],
        ),
      );
    }
    for (var index = 0; index < storage.targetKeyFields.length; index++) {
      parameters.add(
        _normalizeValueForStorage(
          storage.targetModel.name,
          storage.targetKeyFields[index],
          targetKeyValues[relation.targetKeyFields[index]],
        ),
      );
    }
    await _executor.rawInsert(
      'INSERT OR IGNORE INTO ${_quoteIdentifier(storage.tableName)} '
      '(${columnNames.map(_quoteIdentifier).join(', ')}) '
      'VALUES (${List<String>.filled(columnNames.length, '?').join(', ')})',
      parameters,
    );
  }

  Future<List<_SelectedRow>> _selectImplicitManyToManyRows({
    required String sourceModel,
    required Map<String, Object?> sourceRecord,
    required QueryRelation relation,
  }) async {
    if (!_recordContainsAllRelationKeyFields(
      sourceRecord,
      relation.localKeyFields,
    )) {
      return const <_SelectedRow>[];
    }

    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final context = _SqlBuildContext();
    final targetAlias = context.nextAlias();
    final joinAlias = context.nextAlias();
    final whereClauses = <String>[];
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
      whereClauses.add(
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
    final result = await _executor.rawQuery(
      'SELECT ${_quoteIdentifier(targetAlias)}.rowid AS ${_quoteIdentifier(_rowIdColumn)}, ${_quoteIdentifier(targetAlias)}.* '
      'FROM ${_tableReference(relation.targetModel, targetAlias)} '
      'JOIN ${_rawTableReference(storage.tableName, joinAlias)} '
      'ON ${_qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: relation.targetModel, rightFields: relation.targetKeyFields)} '
      'WHERE ${whereClauses.join(' AND ')}',
      parameters,
    );
    return result
        .map((row) => _resultRowToSelectedRow(relation.targetModel, row))
        .toList(growable: false);
  }

  _SqlClause _buildImplicitManyToManyRelationClause(
    _SqlBuildContext context,
    String sourceModel,
    String sourceAlias,
    String operator,
    QueryRelationFilter filter,
  ) {
    final storage = _implicitManyToManyStorage(sourceModel, filter.relation);
    final targetAlias = context.nextAlias();
    final joinAlias = context.nextAlias();
    final nestedClause = _buildWhereClause(
      context,
      filter.relation.targetModel,
      targetAlias,
      filter.predicates,
    );
    final joinCondition = [
      _qualifiedFieldEqualityClause(
        leftAlias: joinAlias,
        leftModel: filter.relation.targetModel,
        leftFields: storage.targetJoinColumns,
        leftRaw: true,
        rightAlias: targetAlias,
        rightModel: filter.relation.targetModel,
        rightFields: storage.targetKeyFields,
      ),
      _qualifiedFieldEqualityClause(
        leftAlias: joinAlias,
        leftModel: sourceModel,
        leftFields: storage.sourceJoinColumns,
        leftRaw: true,
        rightAlias: sourceAlias,
        rightModel: sourceModel,
        rightFields: storage.sourceKeyFields,
      ),
    ].join(' AND ');

    final predicateSql = switch (operator) {
      'relationSome' || 'relationIs' => 'EXISTS',
      'relationNone' || 'relationIsNot' || 'relationEvery' => 'NOT EXISTS',
      _ => throw UnsupportedError('Unsupported relation operator $operator.'),
    };

    final nestedSql = switch (operator) {
      'relationEvery' => '$joinCondition AND NOT (${nestedClause.sql})',
      _ => '$joinCondition AND ${nestedClause.sql}',
    };

    return _SqlClause(
      sql:
          '$predicateSql ('
          'SELECT 1 FROM ${_tableReference(filter.relation.targetModel, targetAlias)} '
          'JOIN ${_rawTableReference(storage.tableName, joinAlias)} '
          'ON ${_qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: filter.relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: filter.relation.targetModel, rightFields: storage.targetKeyFields)} '
          'WHERE $nestedSql'
          ')',
      parameters: nestedClause.parameters,
    );
  }

  ImplicitManyToManyStorageDefinition _implicitManyToManyStorage(
    String sourceModel,
    QueryRelation relation,
  ) {
    final storage = resolveImplicitManyToManyStorage(
      schema: _schema,
      sourceModelName: relation.sourceModel ?? sourceModel,
      relationFieldName: relation.field,
    );
    if (storage == null) {
      throw StateError(
        'Unable to resolve implicit many-to-many storage for ${relation.sourceModel ?? sourceModel}.${relation.field}.',
      );
    }
    return storage;
  }

  Map<String, Object?> _extractRequiredRelationKeyValues(
    Map<String, Object?> record,
    List<String> fields, {
    required String model,
    required QueryRelation relation,
    required String role,
  }) {
    final keyValues = <String, Object?>{};
    for (final field in fields) {
      final value = record[field];
      if (value == null) {
        throw StateError(
          'Missing $role key "$field" for nested create on $model.${relation.field}.',
        );
      }
      keyValues[field] = value;
    }
    return Map<String, Object?>.unmodifiable(keyValues);
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
    final comparisons = <String>[];
    for (var index = 0; index < leftFields.length; index++) {
      final left = leftRaw
          ? _qualifiedRawField(leftAlias, leftFields[index])
          : _qualifiedField(leftAlias, leftModel, leftFields[index]);
      final right = rightRaw
          ? _qualifiedRawField(rightAlias, rightFields[index])
          : _qualifiedField(rightAlias, rightModel, rightFields[index]);
      comparisons.add('$left = $right');
    }
    return comparisons.join(' AND ');
  }

  _SqlClause _binaryClause(
    String alias,
    String field,
    String operator,
    Object? value,
    String model,
  ) {
    if (value == null && operator == '=') {
      return _SqlClause(
        sql: '${_qualifiedField(alias, model, field)} IS NULL',
        parameters: const <Object?>[],
      );
    }

    return _SqlClause(
      sql: '${_qualifiedField(alias, model, field)} $operator ?',
      parameters: <Object?>[_normalizeValueForStorage(model, field, value)],
    );
  }

  _SqlClause _joinClauses(List<_SqlClause> clauses, String glue) {
    if (clauses.isEmpty) {
      return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }
    return _SqlClause(
      sql: clauses.map((clause) => '(${clause.sql})').join(' $glue '),
      parameters: clauses
          .expand((clause) => clause.parameters)
          .toList(growable: false),
    );
  }

  List<String> _buildAggregateSelectExprs(
    String? alias,
    String model,
    QueryCountSelection count,
    Set<String> avg,
    Set<String> sum,
    Set<String> min,
    Set<String> max,
  ) {
    final exprs = <String>[];
    if (count.all) {
      exprs.add('COUNT(*) AS "_count__all"');
    }
    for (final field in count.fields) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('COUNT($col) AS "_count_$field"');
    }
    for (final field in avg) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('AVG($col) AS "_avg_$field"');
    }
    for (final field in sum) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('SUM($col) AS "_sum_$field"');
    }
    for (final field in min) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('MIN($col) AS "_min_$field"');
    }
    for (final field in max) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('MAX($col) AS "_max_$field"');
    }
    return exprs;
  }

  AggregateQueryResult _parseAggregateResultRow(
    Map<String, Object?> row,
    QueryCountSelection count,
    Set<String> avg,
    Set<String> sum,
    Set<String> min,
    Set<String> max,
  ) {
    return AggregateQueryResult(
      count: count.isEmpty
          ? null
          : QueryCountAggregateResult(
              all: count.all ? _toInt(row['_count__all']) : null,
              fields: Map<String, int>.unmodifiable({
                for (final field in count.fields)
                  field: _toInt(row['_count_$field']) ?? 0,
              }),
            ),
      avg: avg.isEmpty
          ? null
          : Map<String, double?>.unmodifiable({
              for (final field in avg) field: _toDouble(row['_avg_$field']),
            }),
      sum: sum.isEmpty
          ? null
          : Map<String, num?>.unmodifiable({
              for (final field in sum) field: _toNum(row['_sum_$field']),
            }),
      min: min.isEmpty
          ? null
          : Map<String, Object?>.unmodifiable({
              for (final field in min) field: row['_min_$field'],
            }),
      max: max.isEmpty
          ? null
          : Map<String, Object?>.unmodifiable({
              for (final field in max) field: row['_max_$field'],
            }),
    );
  }

  _SqlClause _buildAggregatePredicateClause(
    String alias,
    String model,
    QueryAggregatePredicate pred,
  ) {
    final aggExpr = _aggregateSqlExpr(alias, model, pred.field, pred.function);
    switch (pred.operator) {
      case 'in':
        final values = pred.value as List<Object?>;
        if (values.isEmpty) {
          return const _SqlClause(sql: '1 = 0', parameters: <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return _SqlClause(
          sql: '$aggExpr IN ($placeholders)',
          parameters: values,
        );
      case 'notIn':
        final values = pred.value as List<Object?>;
        if (values.isEmpty) {
          return const _SqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return _SqlClause(
          sql: '$aggExpr NOT IN ($placeholders)',
          parameters: values,
        );
      default:
        final op = switch (pred.operator) {
          'equals' => '=',
          'not' => '!=',
          'gt' => '>',
          'gte' => '>=',
          'lt' => '<',
          'lte' => '<=',
          _ => throw UnsupportedError(
            'Unsupported aggregate predicate operator: ${pred.operator}',
          ),
        };
        return _SqlClause(
          sql: '$aggExpr $op ?',
          parameters: <Object?>[pred.value],
        );
    }
  }

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

  String _buildGroupByOrderClause(
    String alias,
    String model,
    List<GroupByOrderBy> orderBy,
  ) {
    return orderBy
        .map((entry) {
          final dir = entry.direction == SortOrder.asc ? 'ASC' : 'DESC';
          if (entry.isAggregate) {
            final expr = _aggregateSqlExpr(
              alias,
              model,
              entry.field ?? '_all',
              entry.aggregate!,
            );
            return '$expr $dir';
          }
          return '${_qualifiedField(alias, model, entry.field!)} $dir';
        })
        .join(', ');
  }

  static int? _toInt(Object? v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return null;
  }

  static double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static num? _toNum(Object? v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  String _buildOrderByClause(
    String alias,
    String model,
    List<QueryOrderBy> orderBy,
  ) {
    return orderBy
        .map(
          (entry) =>
              '${_qualifiedField(alias, model, entry.field)} ${entry.direction == SortOrder.asc ? 'ASC' : 'DESC'}',
        )
        .join(', ');
  }

  String _rawTableReference(String tableName, String alias) {
    return '${_quoteIdentifier(tableName)} AS ${_quoteIdentifier(alias)}';
  }

  String _qualifiedRawField(String alias, String fieldName) {
    return '${_quoteIdentifier(alias)}.${_quoteIdentifier(fieldName)}';
  }

  Object? _normalizeValueForStorage(String model, String field, Object? value) {
    if (value == null) {
      return null;
    }
    final fieldDefinition = _modelDefinition(model).findField(field);
    if (fieldDefinition == null) {
      return value;
    }
    return switch (fieldDefinition.type) {
      'Boolean' => value is bool ? (value ? 1 : 0) : value,
      'DateTime' => value is DateTime ? value.toIso8601String() : value,
      'BigInt' => value is BigInt ? value.toString() : value,
      'Float' || 'Decimal' => value is num ? value.toDouble() : value,
      'Json' => jsonEncode(value),
      'Bytes' => _normalizeBytesForStorage(value),
      _ => value,
    };
  }

  Object? _normalizeValueFromStorage(
    String model,
    String field,
    Object? value,
  ) {
    if (value == null) {
      return null;
    }
    final fieldDefinition = _modelDefinition(model).findField(field);
    if (fieldDefinition == null) {
      return value;
    }
    return switch (fieldDefinition.type) {
      'Boolean' => value is int ? value != 0 : value,
      'DateTime' => value is String ? DateTime.parse(value) : value,
      'BigInt' =>
        value is String
            ? BigInt.parse(value)
            : value is int
            ? BigInt.from(value)
            : value,
      'Float' || 'Decimal' => value is num ? value.toDouble() : value,
      'Json' => value is String ? jsonDecode(value) : value,
      'Bytes' => _normalizeBytesFromStorage(value),
      _ => value,
    };
  }

  List<int> _normalizeBytesForStorage(Object? value) {
    if (value is List<int>) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<int>().toList(growable: false);
    }
    throw ArgumentError.value(
      value,
      'value',
      'Expected bytes-compatible value.',
    );
  }

  List<int> _normalizeBytesFromStorage(Object? value) {
    if (value is List<int>) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<int>().toList(growable: false);
    }
    throw StateError('Unexpected SQLite bytes value: $value');
  }

  ModelDefinition _modelDefinition(String model) {
    final definition = _schema.findModel(model);
    if (definition == null) {
      throw StateError('Unknown model $model.');
    }
    return definition;
  }

  String _tableReference(String model, String alias) {
    return '${_quoteIdentifier(_mappedTableName(model))} AS ${_quoteIdentifier(alias)}';
  }

  String _qualifiedField(String alias, String model, String field) {
    return '${_quoteIdentifier(alias)}.${_columnIdentifier(model, field)}';
  }

  String _mappedTableName(String model) {
    return _modelDefinition(model).databaseName;
  }

  String _columnIdentifier(String model, String field) {
    final fieldDefinition = _modelDefinition(model).findField(field);
    return _quoteIdentifier(fieldDefinition?.databaseName ?? field);
  }

  String _quoteIdentifier(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
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
