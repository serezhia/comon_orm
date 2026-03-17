import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_connection.dart';

/// Factory signature used by runtime-metadata open helpers.
typedef PostgresqlRuntimeAdapterFactory =
    Future<PostgresqlDatabaseAdapter> Function({
      required String connectionUrl,
      required RuntimeSchemaView schema,
    });

/// Query execution surface used by the PostgreSQL adapter runtime.
abstract interface class PostgresqlQueryExecutor {
  /// Runs a query and returns rows as string-keyed maps.
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  });

  /// Runs a statement and returns the affected row count.
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  });

  /// Runs [action] inside a PostgreSQL transaction.
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  );

  /// Releases any resources owned by the executor.
  Future<void> close();
}

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
    return transaction((tx) async {
      final txAdapter = tx as PostgresqlDatabaseAdapter;
      final existing = await txAdapter._selectSingleRow(
        model: query.model,
        where: query.where,
        orderBy: const <QueryOrderBy>[],
      );
      if (existing != null) {
        return txAdapter.update(
          UpdateQuery(
            model: query.model,
            where: query.where,
            data: query.update,
            include: query.include,
            select: query.select,
          ),
        );
      }
      return txAdapter.create(
        CreateQuery(
          model: query.model,
          data: query.create,
          include: query.include,
        ),
      );
    });
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

    return _executor.execute(
      'INSERT INTO $tableName ($columns) VALUES ${valueSets.join(', ')}',
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
    if (query.cursor != null && query.distinct.isEmpty) {
      return _findManyWithCursor(query);
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
    return _executor.transaction(
      (tx) => action(
        PostgresqlDatabaseAdapter.fromRuntimeSchema(
          executor: tx,
          schema: _schema,
        )..now = now,
      ),
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

  /// Materializes a batch of records, resolving includes with a single query
  /// per relation level instead of one query per parent row (N+1 avoidance).
  Future<List<Map<String, Object?>>> _materializeRecordsBatch(
    String model,
    List<Map<String, Object?>> rawRecords, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    if (rawRecords.isEmpty) return const <Map<String, Object?>>[];

    final results = rawRecords
        .map((raw) {
          final base = <String, Object?>{};
          if (select == null || select.fields.isEmpty) {
            base.addAll(raw);
          } else {
            for (final field in select.fields) {
              if (raw.containsKey(field)) base[field] = raw[field];
            }
          }
          return base;
        })
        .toList(growable: false);

    if (include == null) return results;

    for (final entry in include.relations.entries) {
      await _applyBatchInclude(
        model: model,
        rawRecords: rawRecords,
        results: results,
        includeKey: entry.key,
        entry: entry.value,
      );
    }

    return results;
  }

  /// Resolves a single include relation across all parent records at once.
  /// Falls back to per-row resolution for M2M and compound FK relations.
  Future<void> _applyBatchInclude({
    required String model,
    required List<Map<String, Object?>> rawRecords,
    required List<Map<String, Object?>> results,
    required String includeKey,
    required QueryIncludeEntry entry,
  }) async {
    final relation = entry.relation;

    if (relation.storageKind == QueryRelationStorageKind.implicitManyToMany ||
        relation.localKeyFields.length > 1) {
      // Fall back to per-row resolution for M2M and compound FKs.
      for (var i = 0; i < rawRecords.length; i++) {
        results[i][includeKey] = await _resolveInclude(
          model,
          rawRecords[i],
          entry,
        );
      }
      return;
    }

    final localField = relation.localKeyField;
    final targetField = relation.targetKeyField;

    final fkValues = rawRecords
        .map((r) => r[localField])
        .where((v) => v != null)
        .toSet()
        .toList(growable: false);

    if (fkValues.isEmpty) {
      final defaultValue = relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
      for (final result in results) {
        result[includeKey] = defaultValue;
      }
      return;
    }

    // Single batch query for all parent rows.
    final targetRows = await _selectRows(
      model: relation.targetModel,
      where: [
        QueryPredicate(field: targetField, operator: 'in', value: fkValues),
      ],
      orderBy: const <QueryOrderBy>[],
    );

    // Recursively materialize related rows in batch.
    final rawTargets = targetRows.map((r) => r.record).toList(growable: false);
    final materializedTargets = await _materializeRecordsBatch(
      relation.targetModel,
      rawTargets,
      include: entry.include,
      select: entry.select,
    );

    // Build lookup: targetField value → list of materialized records.
    final lookup = <Object?, List<Map<String, Object?>>>{};
    for (var i = 0; i < targetRows.length; i++) {
      final key = targetRows[i].record[targetField];
      (lookup[key] ??= []).add(materializedTargets[i]);
    }

    // Attach results to parent records.
    for (var i = 0; i < rawRecords.length; i++) {
      final fkValue = rawRecords[i][localField];
      final matches = fkValue != null
          ? lookup[fkValue] ?? const <Map<String, Object?>>[]
          : const <Map<String, Object?>>[];
      if (relation.cardinality == QueryRelationCardinality.one) {
        results[i][includeKey] = matches.isEmpty
            ? null
            : Map<String, Object?>.unmodifiable(matches.first);
      } else {
        results[i][includeKey] = List<Map<String, Object?>>.unmodifiable(
          matches,
        );
      }
    }
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

      return materialized;
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

    return materialized;
  }

  _PostgresqlClause _buildWhereClause(
    _PostgresqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    if (predicates.isEmpty) {
      return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }

    final clauses = predicates
        .map(
          (predicate) =>
              _buildPredicateClause(context, model, alias, predicate),
        )
        .toList(growable: false);
    return _joinClauses(clauses, 'AND');
  }

  _PostgresqlClause _buildPredicateClause(
    _PostgresqlBuildContext context,
    String model,
    String alias,
    QueryPredicate predicate,
  ) {
    switch (predicate.operator) {
      case 'logicalAnd':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
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
          return const _PostgresqlClause(sql: '1 = 0', parameters: <Object?>[]);
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
          return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final negated = group.branches
            .map((branch) => _buildWhereClause(context, model, alias, branch))
            .map(
              (branchClause) => _PostgresqlClause(
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
          context,
          alias,
          predicate.field,
          '=',
          predicate.value,
          model,
        );
      case 'not':
        if (predicate.value == null) {
          return _PostgresqlClause(
            sql:
                '${_qualifiedField(alias, model, predicate.field)} IS NOT NULL',
            parameters: const <Object?>[],
          );
        }
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '!=',
          predicate.value,
          model,
        );
      case 'contains':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}%',
          model,
        );
      case 'startsWith':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '${predicate.value}%',
          model,
        );
      case 'endsWith':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}',
          model,
        );
      case 'containsInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}%',
          model,
        );
      case 'startsWithInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '${predicate.value}%',
          model,
        );
      case 'endsWithInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}',
          model,
        );
      case 'in':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return const _PostgresqlClause(sql: '1 = 0', parameters: <Object?>[]);
        }
        final parameters = <Object?>[];
        final placeholders = <String>[];
        for (final value in values) {
          final placeholder = context.nextParameter();
          placeholders.add(
            _parameterWithCast(model, predicate.field, placeholder),
          );
          parameters.add(
            _normalizeValueForStorage(model, predicate.field, value),
          );
        }
        return _PostgresqlClause(
          sql:
              '${_qualifiedField(alias, model, predicate.field)} IN (${placeholders.join(', ')})',
          parameters: parameters,
        );
      case 'notIn':
        final notInValues = predicate.value as List<Object?>;
        if (notInValues.isEmpty) {
          return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
        }
        final notInParameters = <Object?>[];
        final notInPlaceholders = <String>[];
        for (final value in notInValues) {
          final placeholder = context.nextParameter();
          notInPlaceholders.add(
            _parameterWithCast(model, predicate.field, placeholder),
          );
          notInParameters.add(
            _normalizeValueForStorage(model, predicate.field, value),
          );
        }
        return _PostgresqlClause(
          sql:
              '${_qualifiedField(alias, model, predicate.field)} NOT IN (${notInPlaceholders.join(', ')})',
          parameters: notInParameters,
        );
      case 'gt':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '>',
          predicate.value,
          model,
        );
      case 'gte':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '>=',
          predicate.value,
          model,
        );
      case 'lt':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '<',
          predicate.value,
          model,
        );
      case 'lte':
        return _binaryClause(
          context,
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

  _PostgresqlClause _binaryClause(
    _PostgresqlBuildContext context,
    String alias,
    String field,
    String operator,
    Object? value,
    String model,
  ) {
    if (value == null && operator == '=') {
      return _PostgresqlClause(
        sql: '${_qualifiedField(alias, model, field)} IS NULL',
        parameters: const <Object?>[],
      );
    }

    final placeholder = context.nextParameter();
    return _PostgresqlClause(
      sql:
          '${_qualifiedField(alias, model, field)} $operator '
          '${_parameterWithCast(model, field, placeholder)}',
      parameters: <Object?>[_normalizeValueForStorage(model, field, value)],
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

  _PostgresqlClause _stringPatternClause(
    _PostgresqlBuildContext context,
    String alias,
    String field,
    String pattern,
    String model,
  ) {
    final placeholder = context.nextParameter();
    return _PostgresqlClause(
      sql: '${_qualifiedField(alias, model, field)} LIKE $placeholder',
      parameters: <Object?>[_normalizeValueForStorage(model, field, pattern)],
    );
  }

  _PostgresqlClause _ilikeClause(
    _PostgresqlBuildContext context,
    String alias,
    String field,
    String pattern,
    String model,
  ) {
    final placeholder = context.nextParameter();
    return _PostgresqlClause(
      sql: '${_qualifiedField(alias, model, field)} ILIKE $placeholder',
      parameters: <Object?>[_normalizeValueForStorage(model, field, pattern)],
    );
  }

  _PostgresqlClause _joinClauses(List<_PostgresqlClause> clauses, String glue) {
    if (clauses.isEmpty) {
      return const _PostgresqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }

    return _PostgresqlClause(
      sql: clauses.map((clause) => '(${clause.sql})').join(' $glue '),
      parameters: clauses
          .expand((clause) => clause.parameters)
          .toList(growable: false),
    );
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

class _SelectedRow {
  const _SelectedRow({required this.rowLocator, required this.record});

  final String rowLocator;
  final Map<String, Object?> record;
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

class _SessionBackedQueryExecutor implements PostgresqlQueryExecutor {
  const _SessionBackedQueryExecutor(this._session);

  final pg.Session _session;

  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    final result = await _session.execute(
      sql,
      parameters: parameters,
      ignoreRows: true,
    );
    return result.affectedRows;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    final result = await _session.execute(sql, parameters: parameters);
    return result
        .map((row) => Map<String, Object?>.from(row.toColumnMap()))
        .toList(growable: false);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) async {
    return action(this);
  }
}

class _PostgresqlBuildContext {
  int _aliasCounter = 0;
  int _parameterCounter = 0;

  String nextAlias() => 't${_aliasCounter++}';

  String nextParameter() => '\$${++_parameterCounter}';
}

class _PostgresqlClause {
  const _PostgresqlClause({required this.sql, required this.parameters});

  final String sql;
  final List<Object?> parameters;
}
