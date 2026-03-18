import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_connection.dart';
import 'postgresql_relation_materializer.dart';
import 'postgresql_sql_builder.dart';
import 'postgresql_transaction.dart';

typedef _PostgresqlBuildContext = PostgresqlSqlBuildContext;
typedef _PostgresqlClause = PostgresqlSqlClause;
typedef _SelectedRow = PostgresqlSelectedRow;
typedef _ImplicitManyToManyBatchRow = PostgresqlImplicitManyToManyBatchRow;
typedef _RelationKey = PostgresqlRelationKey;
typedef _SessionBackedQueryExecutor = PostgresqlSessionQueryExecutor;

/// Factory signature used by runtime-metadata open helpers.
typedef PostgresqlRuntimeAdapterFactory =
    Future<PostgresqlDatabaseAdapter> Function({
      required String connectionUrl,
      required RuntimeSchemaView schema,
    });

/// PostgreSQL `DatabaseAdapter` implementation backed by `package:postgres`.
class PostgresqlDatabaseAdapter implements DatabaseAdapter {
  /// Creates an adapter from an already configured [executor] and [schema].
  PostgresqlDatabaseAdapter({
    required PostgresqlQueryExecutor executor,
    required SchemaDocument schema,
    Future<void> Function()? closeCallback,
  }) : this.fromRuntimeSchema(
         executor: executor,
         schema: runtimeSchemaViewFromSchemaDocument(schema),
         closeCallback: closeCallback,
       );

  /// Creates an adapter from an already configured [executor] and runtime [schema].
  PostgresqlDatabaseAdapter.fromRuntimeSchema({
    required PostgresqlQueryExecutor executor,
    required RuntimeSchemaView schema,
    Future<void> Function()? closeCallback,
  }) : _executor = executor,
       _schema = schema,
       _closeCallback = closeCallback;

  /// Creates an adapter from an already configured [executor] and generated metadata.
  factory PostgresqlDatabaseAdapter.fromGeneratedSchema({
    required PostgresqlQueryExecutor executor,
    required GeneratedRuntimeSchema schema,
    Future<void> Function()? closeCallback,
  }) {
    return PostgresqlDatabaseAdapter.fromRuntimeSchema(
      executor: executor,
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      closeCallback: closeCallback,
    );
  }

  final PostgresqlQueryExecutor _executor;
  final RuntimeSchemaView _schema;
  final Future<void> Function()? _closeCallback;
  late final PostgresqlSqlBuilder _sqlBuilder = PostgresqlSqlBuilder(
    buildRelationClause: _buildRelationClause,
    normalizeValueForStorage: _normalizeValueForStorage,
    parameterWithCast: _parameterWithCast,
    qualifiedField: _qualifiedField,
  );
  late final PostgresqlRelationMaterializer _relationMaterializer =
      PostgresqlRelationMaterializer(
        recordContainsAllRelationKeyFields: _recordContainsAllRelationKeyFields,
        selectImplicitManyToManyRows: _selectImplicitManyToManyRows,
        selectImplicitManyToManyRowsBatch: _selectImplicitManyToManyRowsBatch,
        selectRows: _selectRows,
      );
  late final PostgresqlTransactionManager _transactionManager =
      PostgresqlTransactionManager(_executor);

  /// Clock used for automatic field values such as `@updatedAt`.
  DateTime Function() now = () => DateTime.now().toUtc();

  /// Opens an adapter from a structured PostgreSQL connection config.
  static Future<PostgresqlDatabaseAdapter> connect({
    required PostgresqlConnectionConfig config,
    required SchemaDocument schema,
  }) async {
    final pg.SessionExecutor pool = pg.Pool<Object?>.withEndpoints(
      <pg.Endpoint>[config.endpoint],
      settings: pg.PoolSettings(sslMode: config.sslMode),
    );
    final executor = _RetryingSessionExecutorBackedQueryExecutor(pool);
    return PostgresqlDatabaseAdapter(
      executor: executor,
      schema: schema,
      closeCallback: executor.close,
    );
  }

  /// Opens an adapter from a PostgreSQL connection URL.
  static Future<PostgresqlDatabaseAdapter> openFromUrl({
    required String connectionUrl,
    required SchemaDocument schema,
    pg.SslMode? sslMode,
  }) async {
    final pg.SessionExecutor pool = _poolFromUrl(
      connectionUrl,
      sslMode: sslMode,
    );
    final executor = _RetryingSessionExecutorBackedQueryExecutor(pool);
    return PostgresqlDatabaseAdapter(
      executor: executor,
      schema: schema,
      closeCallback: executor.close,
    );
  }

  /// Opens an adapter from a PostgreSQL connection URL and runtime metadata.
  static Future<PostgresqlDatabaseAdapter> openFromUrlAndRuntimeSchema({
    required String connectionUrl,
    required RuntimeSchemaView schema,
    pg.SslMode? sslMode,
  }) async {
    final pg.SessionExecutor pool = _poolFromUrl(
      connectionUrl,
      sslMode: sslMode,
    );
    final executor = _RetryingSessionExecutorBackedQueryExecutor(pool);
    return PostgresqlDatabaseAdapter.fromRuntimeSchema(
      executor: executor,
      schema: schema,
      closeCallback: executor.close,
    );
  }

  /// Opens an adapter from a PostgreSQL connection URL and generated metadata.
  static Future<PostgresqlDatabaseAdapter> openFromUrlAndGeneratedSchema({
    required String connectionUrl,
    required GeneratedRuntimeSchema schema,
    pg.SslMode? sslMode,
  }) {
    return openFromUrlAndRuntimeSchema(
      connectionUrl: connectionUrl,
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      sslMode: sslMode,
    );
  }

  /// Resolves datasource metadata and opens an adapter from a runtime schema.
  static Future<PostgresqlDatabaseAdapter> openFromRuntimeSchema({
    required RuntimeSchemaView schema,
    String schemaPath = 'schema.prisma',
    String? connectionUrl,
    String? datasourceName,
    pg.SslMode? sslMode,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    PostgresqlRuntimeAdapterFactory? adapterFactory,
  }) async {
    final resolvedConnectionUrl =
        connectionUrl ??
        resolver
            .resolveDatasource(
              schema: schema,
              datasourceName: datasourceName,
              expectedProvider: 'postgresql',
              schemaPath: schemaPath,
            )
            .url;

    if (adapterFactory != null) {
      return adapterFactory(
        connectionUrl: resolvedConnectionUrl,
        schema: schema,
      );
    }

    return PostgresqlDatabaseAdapter.openFromUrlAndRuntimeSchema(
      connectionUrl: resolvedConnectionUrl,
      schema: schema,
      sslMode: sslMode,
    );
  }

  /// Resolves datasource metadata and opens an adapter from generated metadata.
  static Future<PostgresqlDatabaseAdapter> openFromGeneratedSchema({
    required GeneratedRuntimeSchema schema,
    String schemaPath = 'schema.prisma',
    String? connectionUrl,
    String? datasourceName,
    pg.SslMode? sslMode,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    PostgresqlRuntimeAdapterFactory? adapterFactory,
  }) {
    return openFromRuntimeSchema(
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      schemaPath: schemaPath,
      connectionUrl: connectionUrl,
      datasourceName: datasourceName,
      sslMode: sslMode,
      resolver: resolver,
      adapterFactory: adapterFactory,
    );
  }

  static pg.SessionExecutor _poolFromUrl(
    String connectionUrl, {
    pg.SslMode? sslMode,
  }) {
    if (sslMode == null) {
      return pg.Pool<Object?>.withUrl(connectionUrl);
    }

    return pg.Pool<Object?>.withUrl(
      _connectionUrlWithSslMode(connectionUrl, sslMode),
    );
  }

  static String _connectionUrlWithSslMode(
    String connectionUrl,
    pg.SslMode sslMode,
  ) {
    final fragmentIndex = connectionUrl.indexOf('#');
    final fragment = fragmentIndex >= 0
        ? connectionUrl.substring(fragmentIndex)
        : '';
    final withoutFragment = fragmentIndex >= 0
        ? connectionUrl.substring(0, fragmentIndex)
        : connectionUrl;
    final queryIndex = withoutFragment.indexOf('?');
    final base = queryIndex >= 0
        ? withoutFragment.substring(0, queryIndex)
        : withoutFragment;
    final existingQuery = queryIndex >= 0
        ? withoutFragment.substring(queryIndex + 1)
        : '';
    final filteredParams = existingQuery
        .split('&')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .where((part) => !part.toLowerCase().startsWith('sslmode='))
        .toList(growable: true);
    filteredParams.add('sslmode=${_sslModeQueryValue(sslMode)}');
    return '$base?${filteredParams.join('&')}$fragment';
  }

  static String _sslModeQueryValue(pg.SslMode sslMode) {
    return switch (sslMode) {
      pg.SslMode.disable => 'disable',
      pg.SslMode.require => 'require',
      pg.SslMode.verifyFull => 'verify-full',
    };
  }

  /// Closes the underlying executor or pool if one was supplied.
  @override
  Future<void> close() {
    return _closeCallback?.call() ?? Future.value();
  }

  @override
  Future<int> count(CountQuery query) async {
    final context = _PostgresqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    final rows = await _executor.query(
      'SELECT COUNT(*) AS ${_quoteIdentifier('count')} '
      'FROM ${_tableReference(query.model, alias)} '
      'WHERE ${whereClause.sql}',
      parameters: whereClause.parameters,
    );
    final value = rows.first['count'];
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse('$value');
  }

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) async {
    // Build the window CTE that applies WHERE / ORDER / LIMIT / OFFSET.
    final context = _PostgresqlBuildContext();
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
      final p = context.nextParameter();
      innerSql.write(' LIMIT $p');
      parameters.add(query.take);
    }
    if (query.skip != null) {
      final p = context.nextParameter();
      innerSql.write(' OFFSET $p');
      parameters.add(query.skip);
    }

    // Build outer SELECT of aggregate expressions.
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

    final rows = await _executor.query(sql, parameters: parameters);
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
    final context = _PostgresqlBuildContext();
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
        final clause = _buildAggregatePredicateClause(
          context,
          alias,
          query.model,
          pred,
        );
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
      final p = context.nextParameter();
      sql.write(' LIMIT $p');
      parameters.add(query.take);
    }
    if (query.skip != null) {
      final p = context.nextParameter();
      sql.write(' OFFSET $p');
      parameters.add(query.skip);
    }

    final rows = await _executor.query(sql.toString(), parameters: parameters);
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
      final txAdapter = tx as PostgresqlDatabaseAdapter;
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
          inserted,
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
              childRecord,
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
          inserted,
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
  }) {
    return _insertImplicitManyToManyLink(
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
  }) {
    return _deleteImplicitManyToManyLinks(
      sourceModel: sourceModel,
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) async {
    return transaction((tx) async {
      final txAdapter = tx as PostgresqlDatabaseAdapter;
      final selected = await txAdapter._selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (selected == null) {
        throw StateError('No record found for delete in ${query.model}.');
      }

      await txAdapter._executor.execute(
        'DELETE FROM ${_quoteIdentifier(_mappedTableName(query.model))} '
        'WHERE ctid = ${_parameter(1)}::tid',
        parameters: <Object?>[selected.rowLocator],
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
    final context = _PostgresqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    return _executor.execute(
      'DELETE FROM ${_quoteIdentifier(query.model)} AS ${_quoteIdentifier(alias)} '
      'WHERE ${whereClause.sql}',
      parameters: whereClause.parameters,
    );
  }

  @override
  Future<Map<String, Object?>> upsert(UpsertQuery query) async {
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
        'PostgreSQL upsert for ${query.model} requires insert data.',
      );
    }

    final context = _PostgresqlBuildContext();
    final columns = insertEntries
        .map((entry) => _columnIdentifier(query.model, entry.key))
        .join(', ');
    final insertPlaceholders = <String>[];
    final parameters = <Object?>[];
    for (final entry in insertEntries) {
      final placeholder = context.nextParameter();
      insertPlaceholders.add(
        _parameterWithCast(query.model, entry.key, placeholder),
      );
      parameters.add(
        _normalizeValueForStorage(query.model, entry.key, entry.value),
      );
    }

    final assignments = <String>[];
    if (updateData.isEmpty) {
      final noOpField = conflictFields.first;
      assignments.add(
        '${_columnIdentifier(query.model, noOpField)} = EXCLUDED.${_columnIdentifier(query.model, noOpField)}',
      );
    } else {
      for (final entry in updateData.entries) {
        final placeholder = context.nextParameter();
        assignments.add(
          '${_columnIdentifier(query.model, entry.key)} = ${_parameterWithCast(query.model, entry.key, placeholder)}',
        );
        parameters.add(
          _normalizeValueForStorage(query.model, entry.key, entry.value),
        );
      }
    }

    final conflictTarget = conflictFields
        .map((field) => _columnIdentifier(query.model, field))
        .join(', ');
    final rows = await _executor.query(
      'INSERT INTO ${_quoteIdentifier(_mappedTableName(query.model))} ($columns) '
      'VALUES (${insertPlaceholders.join(', ')}) '
      'ON CONFLICT ($conflictTarget) DO UPDATE '
      'SET ${assignments.join(', ')} '
      'RETURNING *',
      parameters: parameters,
    );
    final record = _normalizeRecordFromStorage(query.model, rows.single);
    return Map<String, Object?>.unmodifiable(
      await _materializeRecord(
        query.model,
        record,
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
    final processedRows = query.data
        .map(
          (row) => _applyAutomaticFieldValues(query.model, row, isCreate: true),
        )
        .toList(growable: false);

    // Collect the union of all column names so every row has the same shape.
    final allColumns = <String>{};
    for (final row in processedRows) {
      allColumns.addAll(row.keys);
    }
    final columnList = allColumns.toList(growable: false);

    final context = _PostgresqlBuildContext();
    final tableName = _quoteIdentifier(_mappedTableName(query.model));
    final columns = columnList
        .map((col) => _columnIdentifier(query.model, col))
        .join(', ');
    final valueSets = <String>[];
    final parameters = <Object?>[];

    for (final row in processedRows) {
      final placeholders = columnList.map((col) {
        final p = context.nextParameter();
        parameters.add(_normalizeValueForStorage(query.model, col, row[col]));
        return _parameterWithCast(query.model, col, p);
      }).toList();
      valueSets.add('(${placeholders.join(', ')})');
    }

    final conflictClause = query.skipDuplicates
        ? ' ON CONFLICT DO NOTHING'
        : '';

    return _executor.execute(
      'INSERT INTO $tableName ($columns) VALUES ${valueSets.join(', ')}$conflictClause',
      parameters: parameters,
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    return _executor.query(sql, parameters: parameters);
  }

  @override
  Future<int> rawExecute(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    return _executor.execute(sql, parameters: parameters);
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
    if (query.distinct.isNotEmpty) {
      return _findManyWithDistinctPushdown(query);
    }

    if (query.cursor != null) {
      return _findManyWithCursor(query);
    }

    if (query.distinct.isEmpty &&
        (query.includeStrategy == null ||
            query.includeStrategy == IncludeStrategy.join)) {
      final joined = await _findManyWithSimpleSingularIncludeJoins(query);
      if (joined != null) {
        return List<Map<String, Object?>>.unmodifiable(
          joined.map(Map<String, Object?>.unmodifiable),
        );
      }
    }

    final rows = await _selectRows(
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
        ? await Future.wait(
            rawRecords.map(
              (raw) => _materializeRecord(
                query.model,
                raw,
                include: query.include,
                select: query.select,
              ),
            ),
          )
        : await _materializeRecordsBatch(
            query.model,
            rawRecords,
            include: query.include,
            select: query.select,
          );
    return List<Map<String, Object?>>.unmodifiable(
      materialized.map(Map<String, Object?>.unmodifiable),
    );
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
      cursorRow = await _selectSingleDistinctRow(
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

    final rows = await _selectDistinctRows(
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
        ? await Future.wait(
            rawRecords.map(
              (raw) => _materializeRecord(
                query.model,
                raw,
                include: query.include,
                select: query.select,
              ),
            ),
          )
        : await _materializeRecordsBatch(
            query.model,
            rawRecords,
            include: query.include,
            select: query.select,
          );
    return List<Map<String, Object?>>.unmodifiable(
      materialized.map(Map<String, Object?>.unmodifiable),
    );
  }

  Future<List<Map<String, Object?>>?> _findManyWithSimpleSingularIncludeJoins(
    FindManyQuery query,
  ) async {
    final context = _PostgresqlBuildContext();
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
        'SELECT ${_quoteIdentifier(alias)}.ctid::text AS ${_quoteIdentifier(_ctidColumn)}, ${_quoteIdentifier(alias)}.*',
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
    if (query.orderBy.isNotEmpty) {
      sql.write(' ORDER BY $orderClause');
    }
    if (query.take != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' LIMIT $placeholder');
      parameters.add(query.take);
    }
    if (query.skip != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' OFFSET $placeholder');
      parameters.add(query.skip);
    }

    final rows = await _executor.query(sql.toString(), parameters: parameters);
    return rows
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

    final cursorRow = await _selectSingleRow(
      model: query.model,
      where: cursor.where,
      orderBy: const <QueryOrderBy>[],
    );
    if (cursorRow == null) {
      return const <Map<String, Object?>>[];
    }

    final orderBy = _cursorOrderBy(query.model, query.orderBy);
    final forward = query.take == null || query.take! >= 0;
    final rows = await _selectRows(
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

    final materialized = await _materializeRecordsBatch(
      query.model,
      rawRecords,
      include: query.include,
      select: query.select,
    );
    return List<Map<String, Object?>>.unmodifiable(
      materialized.map(Map<String, Object?>.unmodifiable),
    );
  }

  Map<String, Object?> _materializeJoinedFindManyRow(
    String model,
    Map<String, Object?> row, {
    required List<_SimpleSingularIncludeJoin> joins,
    required QuerySelect? select,
  }) {
    final record = _normalizeBaseJoinedRecord(model, row);
    final base = _selectJoinedRecordFields(record, select);

    for (final join in joins) {
      base[join.includeKey] = _materializeJoinedIncludeRecord(join, row);
    }
    return base;
  }

  Map<String, Object?> _normalizeBaseJoinedRecord(
    String model,
    Map<String, Object?> row,
  ) {
    final storageRow = <String, Object?>{};
    for (final field in _storedFields(model)) {
      if (row.containsKey(field.databaseName)) {
        storageRow[field.databaseName] = row[field.databaseName];
      }
    }
    return _normalizeRecordFromStorage(model, storageRow);
  }

  Map<String, Object?>? _materializeJoinedIncludeRecord(
    _SimpleSingularIncludeJoin join,
    Map<String, Object?> row,
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

    final selected = _selectJoinedRecordFields(record, join.entry.select);
    for (final child in join.children) {
      selected[child.includeKey] = _materializeJoinedIncludeRecord(child, row);
    }
    return Map<String, Object?>.unmodifiable(selected);
  }

  List<_SimpleSingularIncludeJoin>? _simpleSingularIncludeJoins({
    required String sourceModel,
    required String parentAlias,
    required QueryInclude? include,
    required _PostgresqlBuildContext context,
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

  Map<String, Object?> _selectJoinedRecordFields(
    Map<String, Object?> record,
    QuerySelect? select,
  ) {
    final selected = <String, Object?>{};
    if (select == null || select.fields.isEmpty) {
      selected.addAll(record);
      return selected;
    }

    for (final field in select.fields) {
      if (record.containsKey(field)) {
        selected[field] = record[field];
      }
    }
    return selected;
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
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action) {
    return _transactionManager.run(
      action,
      (tx) => PostgresqlDatabaseAdapter.fromRuntimeSchema(
        executor: tx,
        schema: _schema,
      )..now = now,
    );
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) async {
    return transaction((tx) async {
      final txAdapter = tx as PostgresqlDatabaseAdapter;
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

      late _SelectedRow updated;
      if (updateData.isNotEmpty) {
        final context = _PostgresqlBuildContext();
        final assignments = <String>[];
        final parameters = <Object?>[];
        for (final entry in updateData.entries) {
          final placeholder = context.nextParameter();
          assignments.add(
            '${_columnIdentifier(query.model, entry.key)} = ${_parameterWithCast(query.model, entry.key, placeholder)}',
          );
          parameters.add(
            _normalizeValueForStorage(query.model, entry.key, entry.value),
          );
        }
        final locatorPlaceholder = context.nextParameter();
        parameters.add(selected.rowLocator);

        final rows = await txAdapter._executor.query(
          'UPDATE ${_quoteIdentifier(_mappedTableName(query.model))} '
          'SET ${assignments.join(', ')} '
          'WHERE ctid = $locatorPlaceholder::tid '
          'RETURNING ctid::text AS ${_quoteIdentifier(_ctidColumn)}, *',
          parameters: parameters,
        );
        updated = _resultRowToSelectedRow(query.model, rows.single);
      } else {
        updated = selected;
      }

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

    final context = _PostgresqlBuildContext();
    final alias = context.nextAlias();
    final assignments = <String>[];
    final parameters = <Object?>[];
    for (final entry in updateData.entries) {
      final placeholder = context.nextParameter();
      assignments.add(
        '${_columnIdentifier(query.model, entry.key)} = ${_parameterWithCast(query.model, entry.key, placeholder)}',
      );
      parameters.add(
        _normalizeValueForStorage(query.model, entry.key, entry.value),
      );
    }
    final whereClause = _buildWhereClause(
      context,
      query.model,
      alias,
      query.where,
    );
    parameters.addAll(whereClause.parameters);

    return _executor.execute(
      'UPDATE ${_quoteIdentifier(query.model)} AS ${_quoteIdentifier(alias)} '
      'SET ${assignments.join(', ')} '
      'WHERE ${whereClause.sql}',
      parameters: parameters,
    );
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

  List<String> _resolveUpsertConflictFields(
    String model,
    List<QueryPredicate> where,
  ) {
    final selectorValues = _extractEqualityPredicateValues(model, where);
    final selectorFields = selectorValues.keys.toSet();
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      throw StateError('Unknown model $model for PostgreSQL upsert.');
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
      'PostgreSQL upsert for $model requires where to match exactly one unique selector.',
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
          'PostgreSQL upsert for $model only supports equals predicates in where.',
        );
      }
      if (values.containsKey(predicate.field)) {
        throw StateError(
          'PostgreSQL upsert for $model received duplicate predicates for ${predicate.field}.',
        );
      }
      values[predicate.field] = predicate.value;
    }

    if (requiredFields != null) {
      for (final field in requiredFields) {
        if (!values.containsKey(field)) {
          throw StateError(
            'PostgreSQL upsert for $model requires where to include $field.',
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
          'PostgreSQL upsert for $model requires create.${entry.key} to match where.${entry.key}.',
        );
      }
      merged[entry.key] = entry.value;
    }
    return merged;
  }

  Iterable<RuntimeFieldView> _updatedAtFields(String model) {
    final modelDefinition = _schema.findModel(model);
    if (modelDefinition == null) {
      return const <RuntimeFieldView>[];
    }

    return modelDefinition.fields.where((field) => field.isUpdatedAt);
  }

  Future<List<_SelectedRow>> _selectRows({
    required String model,
    required List<QueryPredicate> where,
    required List<QueryOrderBy> orderBy,
    _PostgresqlClause? additionalWhere,
    int? limit,
    int? offset,
  }) async {
    final context = _PostgresqlBuildContext();
    final alias = context.nextAlias();
    final whereClause = _buildWhereClause(context, model, alias, where);
    final combinedWhere = additionalWhere == null
        ? whereClause
        : _combineClauses(<_PostgresqlClause>[
            whereClause,
            additionalWhere,
          ], 'AND');
    final orderClause = _buildOrderByClause(alias, model, orderBy);
    final sql = StringBuffer()
      ..write(
        'SELECT ${_quoteIdentifier(alias)}.ctid::text AS ${_quoteIdentifier(_ctidColumn)}, ${_quoteIdentifier(alias)}.* '
        'FROM ${_tableReference(model, alias)} '
        'WHERE ${combinedWhere.sql}',
      );
    final parameters = <Object?>[...combinedWhere.parameters];
    if (orderBy.isNotEmpty) {
      sql.write(' ORDER BY $orderClause');
    }
    if (limit != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' LIMIT $placeholder');
      parameters.add(limit);
    }
    if (offset != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' OFFSET $placeholder');
      parameters.add(offset);
    }

    final rows = await _executor.query(sql.toString(), parameters: parameters);
    return rows
        .map((row) => _resultRowToSelectedRow(model, row))
        .toList(growable: false);
  }

  Future<List<_SelectedRow>> _selectDistinctRows({
    required String model,
    required List<QueryPredicate> baseWhere,
    required List<QueryPredicate> outerWhere,
    required Set<String> distinctFields,
    required List<QueryOrderBy> orderBy,
    _PostgresqlClause? additionalOuterWhere,
    List<QueryOrderBy>? resultOrderBy,
    int? limit,
    int? offset,
  }) async {
    final baseContext = _PostgresqlBuildContext();
    const baseAlias = 'b0';
    final baseWhereClause = _buildWhereClause(
      baseContext,
      model,
      baseAlias,
      baseWhere,
    );

    final outerContext = _PostgresqlBuildContext();
    const outerAlias = 't0';
    final outerWhereClause = _buildWhereClause(
      outerContext,
      model,
      outerAlias,
      outerWhere,
    );
    final combinedOuterWhere = additionalOuterWhere == null
        ? outerWhereClause
        : _combineClauses(<_PostgresqlClause>[
            outerWhereClause,
            additionalOuterWhere,
          ], 'AND');
    final shiftedOuterWhere = _shiftClauseParameters(
      combinedOuterWhere,
      baseWhereClause.parameters.length,
    );

    const baseCte = '_distinct_base';
    const rankedCte = '_distinct_ranked';
    const distinctCte = '_distinct';
    const rankedAlias = 'd0';
    final rowNumberOrderClause = _buildDistinctWindowOrderByClause(
      rankedAlias,
      model,
      orderBy,
      rowLocatorColumn: _ctidColumn,
    );
    final partitionClause = distinctFields
        .map((field) => _qualifiedField(rankedAlias, model, field))
        .join(', ');

    final sql = StringBuffer()
      ..write(
        'WITH ${_quoteIdentifier(baseCte)} AS ('
        'SELECT ${_quoteIdentifier(baseAlias)}.ctid::text AS ${_quoteIdentifier(_ctidColumn)}, ${_quoteIdentifier(baseAlias)}.* '
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
        'WHERE ${shiftedOuterWhere.sql}',
      );

    final parameters = <Object?>[
      ...baseWhereClause.parameters,
      ...shiftedOuterWhere.parameters,
    ];
    final effectiveOrderBy = resultOrderBy ?? orderBy;
    if (effectiveOrderBy.isNotEmpty) {
      sql.write(
        ' ORDER BY ${_buildOrderByClause(outerAlias, model, effectiveOrderBy)}',
      );
    }
    if (limit != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' LIMIT $placeholder');
      parameters.add(limit);
    }
    if (offset != null) {
      final placeholder = '\$${parameters.length + 1}';
      sql.write(' OFFSET $placeholder');
      parameters.add(offset);
    }

    final rows = await _executor.query(sql.toString(), parameters: parameters);
    return rows
        .map((row) => _resultRowToSelectedRow(model, row))
        .toList(growable: false);
  }

  Future<_SelectedRow?> _selectSingleDistinctRow({
    required String model,
    required List<QueryPredicate> baseWhere,
    required List<QueryPredicate> outerWhere,
    required Set<String> distinctFields,
    required List<QueryOrderBy> orderBy,
  }) async {
    final rows = await _selectDistinctRows(
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

  _PostgresqlClause _buildCursorWindowClause(
    String model,
    List<QueryOrderBy> orderBy,
    Map<String, Object?> cursorRecord, {
    required bool forward,
  }) {
    if (orderBy.isEmpty) {
      return const _PostgresqlClause(sql: 'TRUE', parameters: <Object?>[]);
    }

    const alias = 't0';
    final branches = <_PostgresqlClause>[];
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
      branches.add(
        _PostgresqlClause(
          sql: branchParts.map((part) => '($part)').join(' AND '),
          parameters: branchParameters,
        ),
      );
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
    branches.add(
      _PostgresqlClause(
        sql: equalityParts.map((part) => '($part)').join(' AND '),
        parameters: equalityParameters,
      ),
    );

    return _combineClauses(branches, 'OR');
  }

  _PostgresqlClause _cursorEqualityClause(
    String alias,
    String model,
    String field,
    Object? value,
  ) {
    final qualifiedField = _qualifiedField(alias, model, field);
    if (value == null) {
      return const _PostgresqlClause(sql: 'FALSE', parameters: <Object?>[]);
    }
    return _PostgresqlClause(
      sql: '$qualifiedField = ${_nextCursorParameterPlaceholder(1)}',
      parameters: <Object?>[_normalizeValueForStorage(model, field, value)],
    );
  }

  _PostgresqlClause _cursorComparisonClause(
    String alias,
    String model,
    QueryOrderBy orderBy,
    Object? value, {
    required bool forward,
  }) {
    final qualifiedField = _qualifiedField(alias, model, orderBy.field);
    if (value == null) {
      return const _PostgresqlClause(sql: 'FALSE', parameters: <Object?>[]);
    }
    final ascending = orderBy.direction == SortOrder.asc;
    final operator = forward
        ? (ascending ? '>' : '<')
        : (ascending ? '<' : '>');
    return _PostgresqlClause(
      sql: '$qualifiedField $operator ${_nextCursorParameterPlaceholder(1)}',
      parameters: <Object?>[
        _normalizeValueForStorage(model, orderBy.field, value),
      ],
    );
  }

  _PostgresqlClause _combineClauses(
    List<_PostgresqlClause> clauses,
    String operator,
  ) {
    if (clauses.isEmpty) {
      return const _PostgresqlClause(sql: 'TRUE', parameters: <Object?>[]);
    }
    if (clauses.length == 1) {
      return clauses.single;
    }

    final sql = StringBuffer();
    final parameters = <Object?>[];
    for (var index = 0; index < clauses.length; index++) {
      if (index > 0) {
        sql.write(' $operator ');
      }
      final shifted = _shiftClauseParameters(clauses[index], parameters.length);
      sql.write('(${shifted.sql})');
      parameters.addAll(shifted.parameters);
    }
    return _PostgresqlClause(sql: sql.toString(), parameters: parameters);
  }

  _PostgresqlClause _shiftClauseParameters(
    _PostgresqlClause clause,
    int offset,
  ) {
    if (offset == 0 || clause.parameters.isEmpty) {
      return clause;
    }
    final sql = clause.sql.replaceAllMapped(
      RegExp(r'\$(\d+)'),
      (match) => '\$${int.parse(match.group(1)!) + offset}',
    );
    return _PostgresqlClause(sql: sql, parameters: clause.parameters);
  }

  String _nextCursorParameterPlaceholder(int index) => '\$$index';

  _SelectedRow _resultRowToSelectedRow(String model, Map<String, Object?> row) {
    final locator = row[_ctidColumn];
    if (locator == null) {
      throw StateError('Missing row locator for $model.');
    }
    return _SelectedRow(
      rowLocator: '$locator',
      record: _normalizeRecordFromStorage(model, row),
    );
  }

  Future<Map<String, Object?>> _insertRecord(
    String model,
    Map<String, Object?> data,
  ) async {
    final entries = data.entries.toList(growable: false);
    if (entries.isEmpty) {
      final rows = await _executor.query(
        'INSERT INTO ${_quoteIdentifier(_mappedTableName(model))} DEFAULT VALUES RETURNING *',
      );
      return _normalizeRecordFromStorage(model, rows.single);
    }

    final context = _PostgresqlBuildContext();
    final columns = entries
        .map((entry) => _columnIdentifier(model, entry.key))
        .join(', ');
    final placeholders = <String>[];
    final parameters = <Object?>[];
    for (final entry in entries) {
      final placeholder = context.nextParameter();
      placeholders.add(_parameterWithCast(model, entry.key, placeholder));
      parameters.add(_normalizeValueForStorage(model, entry.key, entry.value));
    }

    final rows = await _executor.query(
      'INSERT INTO ${_quoteIdentifier(_mappedTableName(model))} ($columns) '
      'VALUES (${placeholders.join(', ')}) '
      'RETURNING *',
      parameters: parameters,
    );
    return _normalizeRecordFromStorage(model, rows.single);
  }

  Future<Map<String, Object?>> _materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    return _relationMaterializer.materializeRecord(
      model,
      record,
      include: include,
      select: select,
    );
  }

  /// Materializes a batch of records, resolving includes with a single query
  /// per relation level instead of one query per parent row (N+1 avoidance).
  Future<List<Map<String, Object?>>> _materializeRecordsBatch(
    String model,
    List<Map<String, Object?>> rawRecords, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    return _relationMaterializer.materializeRecordsBatch(
      model,
      rawRecords,
      include: include,
      select: select,
    );
  }

  _PostgresqlClause _buildWhereClause(
    _PostgresqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    return _sqlBuilder.buildWhereClause(context, model, alias, predicates);
  }

  _PostgresqlClause _buildRelationClause(
    _PostgresqlBuildContext context,
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

    final predicateSql = switch (operator) {
      'relationSome' || 'relationIs' => 'EXISTS',
      'relationNone' || 'relationIsNot' || 'relationEvery' => 'NOT EXISTS',
      _ => throw UnsupportedError('Unsupported relation operator $operator.'),
    };

    final nestedSql = switch (operator) {
      'relationEvery' => '$joinClause AND NOT (${nestedClause.sql})',
      _ => '$joinClause AND ${nestedClause.sql}',
    };

    return _PostgresqlClause(
      sql:
          '$predicateSql ('
          'SELECT 1 FROM ${_tableReference(filter.relation.targetModel, targetAlias)} '
          'WHERE $nestedSql'
          ')',
      parameters: nestedClause.parameters,
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
    final placeholders = List<String>.generate(
      columnNames.length,
      (index) => _parameter(index + 1),
      growable: false,
    );
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceKeyFields.length; index++) {
      parameters.add(
        _normalizeValueForStorage(
          storage.sourceModel,
          storage.sourceKeyFields[index],
          sourceKeyValues[relation.localKeyFields[index]],
        ),
      );
    }
    for (var index = 0; index < storage.targetKeyFields.length; index++) {
      parameters.add(
        _normalizeValueForStorage(
          storage.targetModel,
          storage.targetKeyFields[index],
          targetKeyValues[relation.targetKeyFields[index]],
        ),
      );
    }
    await _executor.execute(
      'INSERT INTO ${_quoteIdentifier(storage.tableName)} '
      '(${columnNames.map(_quoteIdentifier).join(', ')}) '
      'VALUES (${placeholders.join(', ')}) '
      'ON CONFLICT DO NOTHING',
      parameters: parameters,
    );
  }

  Future<int> _deleteImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) async {
    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final whereParts = <String>[];
    final parameters = <Object?>[];

    for (var index = 0; index < storage.sourceKeyFields.length; index++) {
      whereParts.add(
        '${_quoteIdentifier(storage.sourceJoinColumns[index])} = ${_parameter(parameters.length + 1)}',
      );
      parameters.add(
        _normalizeValueForStorage(
          storage.sourceModel,
          storage.sourceKeyFields[index],
          sourceKeyValues[relation.localKeyFields[index]],
        ),
      );
    }

    if (targetKeyValues != null) {
      for (var index = 0; index < storage.targetKeyFields.length; index++) {
        whereParts.add(
          '${_quoteIdentifier(storage.targetJoinColumns[index])} = ${_parameter(parameters.length + 1)}',
        );
        parameters.add(
          _normalizeValueForStorage(
            storage.targetModel,
            storage.targetKeyFields[index],
            targetKeyValues[relation.targetKeyFields[index]],
          ),
        );
      }
    }

    return _executor.execute(
      'DELETE FROM ${_quoteIdentifier(storage.tableName)} '
      'WHERE ${whereParts.join(' AND ')}',
      parameters: parameters,
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
    final context = _PostgresqlBuildContext();
    final targetAlias = context.nextAlias();
    final joinAlias = context.nextAlias();
    final sourceWhereClauses = <String>[];
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
      final placeholder = context.nextParameter();
      sourceWhereClauses.add(
        '${_qualifiedRawField(joinAlias, storage.sourceJoinColumns[index])} = $placeholder',
      );
      parameters.add(
        _normalizeValueForStorage(
          sourceModel,
          relation.localKeyFields[index],
          sourceRecord[relation.localKeyFields[index]],
        ),
      );
    }
    final rows = await _executor.query(
      'SELECT ${_quoteIdentifier(targetAlias)}.ctid::text AS ${_quoteIdentifier(_ctidColumn)}, ${_quoteIdentifier(targetAlias)}.* '
      'FROM ${_tableReference(relation.targetModel, targetAlias)} '
      'JOIN ${_rawTableReference(storage.tableName, joinAlias)} '
      'ON ${_qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: relation.targetModel, rightFields: relation.targetKeyFields)} '
      'WHERE ${sourceWhereClauses.join(' AND ')}',
      parameters: parameters,
    );
    return rows
        .map((row) => _resultRowToSelectedRow(relation.targetModel, row))
        .toList(growable: false);
  }

  Future<List<_ImplicitManyToManyBatchRow>> _selectImplicitManyToManyRowsBatch({
    required String sourceModel,
    required List<Map<String, Object?>> sourceRecords,
    required QueryRelation relation,
  }) async {
    if (sourceRecords.isEmpty) {
      return const <_ImplicitManyToManyBatchRow>[];
    }

    final storage = _implicitManyToManyStorage(sourceModel, relation);
    final context = _PostgresqlBuildContext();
    final targetAlias = context.nextAlias();
    final joinAlias = context.nextAlias();
    final parameters = <Object?>[];
    final whereBranches = <String>[];
    for (final sourceRecord in sourceRecords) {
      final branchClauses = <String>[];
      for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
        final placeholder = context.nextParameter();
        branchClauses.add(
          '${_qualifiedRawField(joinAlias, storage.sourceJoinColumns[index])} = $placeholder',
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

    final rows = await _executor.query(
      'SELECT ${sourceSelects.join(', ')}, ${_quoteIdentifier(targetAlias)}.* '
      'FROM ${_tableReference(relation.targetModel, targetAlias)} '
      'JOIN ${_rawTableReference(storage.tableName, joinAlias)} '
      'ON ${_qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: relation.targetModel, rightFields: relation.targetKeyFields)} '
      'WHERE ${whereBranches.join(' OR ')}',
      parameters: parameters,
    );

    return rows
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
          final targetStorageRow = <String, Object?>{};
          for (final field in _storedFields(relation.targetModel)) {
            if (row.containsKey(field.databaseName)) {
              targetStorageRow[field.databaseName] = row[field.databaseName];
            }
          }
          return _ImplicitManyToManyBatchRow(
            sourceKey: sourceKey,
            record: _normalizeRecordFromStorage(
              relation.targetModel,
              targetStorageRow,
            ),
          );
        })
        .toList(growable: false);
  }

  _PostgresqlClause _buildImplicitManyToManyRelationClause(
    _PostgresqlBuildContext context,
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

    return _PostgresqlClause(
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

  RuntimeImplicitManyToManyStorage _implicitManyToManyStorage(
    String sourceModel,
    QueryRelation relation,
  ) {
    final storage = resolveRuntimeImplicitManyToManyStorage(
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
      exprs.add('AVG($col::float8) AS "_avg_$field"');
    }
    for (final field in sum) {
      final col = alias != null
          ? _qualifiedField(alias, model, field)
          : _columnIdentifier(model, field);
      exprs.add('SUM($col::float8) AS "_sum_$field"');
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

  /// Builds a HAVING predicate clause for a single aggregate predicate.
  _PostgresqlClause _buildAggregatePredicateClause(
    _PostgresqlBuildContext context,
    String alias,
    String model,
    QueryAggregatePredicate pred,
  ) {
    final aggExpr = _aggregateSqlExpr(alias, model, pred.field, pred.function);
    switch (pred.operator) {
      case 'in':
        final values = pred.value as List<Object?>;
        if (values.isEmpty) {
          return const _PostgresqlClause(sql: '1 = 0', parameters: <Object?>[]);
        }
        final placeholders = <String>[];
        final params = <Object?>[];
        for (final v in values) {
          placeholders.add(context.nextParameter());
          params.add(v);
        }
        return _PostgresqlClause(
          sql: '$aggExpr IN (${placeholders.join(', ')})',
          parameters: params,
        );
      case 'notIn':
        final values = pred.value as List<Object?>;
        if (values.isEmpty) {
          return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final placeholders = <String>[];
        final params = <Object?>[];
        for (final v in values) {
          placeholders.add(context.nextParameter());
          params.add(v);
        }
        return _PostgresqlClause(
          sql: '$aggExpr NOT IN (${placeholders.join(', ')})',
          parameters: params,
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
        final placeholder = context.nextParameter();
        return _PostgresqlClause(
          sql: '$aggExpr $op $placeholder',
          parameters: <Object?>[pred.value],
        );
    }
  }

  /// Builds an SQL aggregate expression string (e.g. `COUNT(*)`, `AVG(t0."age"::float8)`).
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
      QueryAggregateFunction.avg => 'AVG($qualField::float8)',
      QueryAggregateFunction.sum => 'SUM($qualField::float8)',
      QueryAggregateFunction.min => 'MIN($qualField)',
      QueryAggregateFunction.max => 'MAX($qualField)',
    };
  }

  /// Builds ORDER BY clause for GROUP BY queries (supports both field and
  /// aggregate ordering).
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
    return _sqlBuilder.buildOrderByClause(alias, model, orderBy);
  }

  String _rawTableReference(String tableName, String alias) {
    return '${_quoteIdentifier(tableName)} AS ${_quoteIdentifier(alias)}';
  }

  String _qualifiedRawField(String alias, String fieldName) {
    return '${_quoteIdentifier(alias)}.${_quoteIdentifier(fieldName)}';
  }

  Map<String, Object?> _normalizeRecordFromStorage(
    String model,
    Map<String, Object?> row,
  ) {
    final record = <String, Object?>{};
    for (final entry in row.entries) {
      final logicalField =
          _modelDefinition(model).findFieldByDatabaseName(entry.key)?.name ??
          entry.key;
      record[logicalField] = _normalizeValueFromStorage(
        model,
        logicalField,
        entry.value,
      );
    }
    return record;
  }

  Iterable<RuntimeFieldView> _storedFields(String model) {
    return _modelDefinition(
      model,
    ).fields.where((field) => field.kind != RuntimeFieldKind.relation);
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
      'BigInt' =>
        value is BigInt
            ? pg.Type.bigInteger.value(value.toInt())
            : value is int
            ? pg.Type.bigInteger.value(value)
            : value,
      'Float' => value is num ? value.toDouble() : value,
      'Decimal' => value is num ? value.toDouble() : value,
      'Json' => pg.Type.jsonb.value(value),
      'Bytes' => pg.Type.byteArray.value(_normalizeBytesForStorage(value)),
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

    if (_schema.findEnum(fieldDefinition.type) != null) {
      if (value is pg.UndecodedBytes) {
        return value.asString;
      }
      return value;
    }

    return switch (fieldDefinition.type) {
      'String' => value is pg.UndecodedBytes ? value.asString : value,
      'BigInt' =>
        value is BigInt
            ? value
            : value is int
            ? BigInt.from(value)
            : value is String
            ? BigInt.parse(value)
            : value,
      'Float' || 'Decimal' =>
        value is num
            ? value.toDouble()
            : value is String
            ? double.parse(value)
            : value,
      'Json' =>
        value is String
            ? jsonDecode(value)
            : value is Map<String, Object?> || value is List<Object?>
            ? value
            : value,
      'Bytes' => _normalizeBytesFromStorage(value),
      _ => value,
    };
  }

  List<int> _normalizeBytesForStorage(Object? value) {
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return Uint8List.fromList(value);
    }
    if (value is List<Object?>) {
      return Uint8List.fromList(value.whereType<int>().toList(growable: false));
    }
    throw ArgumentError.value(
      value,
      'value',
      'Expected bytes-compatible value.',
    );
  }

  List<int> _normalizeBytesFromStorage(Object? value) {
    if (value is Uint8List) {
      return value;
    }
    if (value is List<int>) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<int>().toList(growable: false);
    }
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.startsWith(r'\x')) {
        final hex = trimmed.substring(2);
        final bytes = <int>[];
        for (var index = 0; index < hex.length; index += 2) {
          bytes.add(int.parse(hex.substring(index, index + 2), radix: 16));
        }
        return bytes;
      }
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final inner = trimmed.substring(1, trimmed.length - 1).trim();
        if (inner.isEmpty) {
          return const <int>[];
        }
        return inner
            .split(',')
            .map((item) => int.parse(item.trim()))
            .toList(growable: false);
      }
    }
    throw StateError('Unexpected PostgreSQL bytes value: $value');
  }

  RuntimeModelView _modelDefinition(String model) {
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

  String _parameterWithCast(String model, String field, String placeholder) {
    final fieldDefinition = _modelDefinition(model).findField(field);
    if (fieldDefinition == null) {
      return placeholder;
    }

    return switch (fieldDefinition.type) {
      'Json' => '$placeholder::jsonb',
      _ => placeholder,
    };
  }

  String _parameter(int index) => '\$$index';

  String _quoteIdentifier(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }
}

const String _ctidColumn = '__ctid__';
const String _distinctRowNumberColumn = '__distinct_row_number__';

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

class _RetryingSessionExecutorBackedQueryExecutor
    implements PostgresqlQueryExecutor {
  const _RetryingSessionExecutorBackedQueryExecutor(this._executor);

  final pg.SessionExecutor _executor;

  @override
  Future<void> close() => _executor.close();

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) {
    return _runWithRetry(
      () => _executor.run((session) async {
        final result = await session.execute(
          sql,
          parameters: parameters,
          ignoreRows: true,
        );
        return result.affectedRows;
      }),
    );
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) {
    return _runWithRetry(
      () => _executor.run((session) async {
        final result = await session.execute(sql, parameters: parameters);
        return result
            .map((row) => Map<String, Object?>.from(row.toColumnMap()))
            .toList(growable: false);
      }),
    );
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) {
    var actionStarted = false;
    return _runWithRetry(
      () => _executor.runTx((tx) {
        actionStarted = true;
        return action(_SessionBackedQueryExecutor(tx));
      }),
      canRetry: () => !actionStarted,
    );
  }

  Future<T> _runWithRetry<T>(
    Future<T> Function() operation, {
    bool Function()? canRetry,
  }) async {
    try {
      return await operation();
    } on Object catch (error) {
      if ((canRetry?.call() ?? true) && _isRetryableConnectionError(error)) {
        return operation();
      }
      rethrow;
    }
  }

  bool _isRetryableConnectionError(Object error) {
    if (error is pg.ServerException) {
      return false;
    }

    final message = '$error'.toLowerCase();
    return message.contains('connection is not open') ||
        message.contains('connection is closing down');
  }
}
