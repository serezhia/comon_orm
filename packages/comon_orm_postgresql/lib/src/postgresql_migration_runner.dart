import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_migration_planner.dart';

/// Record kind stored in PostgreSQL migration history.
enum PostgresqlMigrationRecordKind {
  /// History row for a schema apply.
  apply,

  /// History row for a rollback operation.
  rollback,
}

/// Single migration history record stored in PostgreSQL.
class PostgresqlMigrationRecord
    extends MigrationRecord<PostgresqlMigrationRecordKind> {
  /// Creates a migration history record.
  const PostgresqlMigrationRecord({
    required super.name,
    required super.appliedAt,
    required super.statementCount,
    required super.kind,
    required super.warnings,
    required super.rebuildRequired,
    super.targetName,
    super.provider,
    super.checksum,
    super.beforeSchema,
    super.afterSchema,
  });
}

/// Result of applying a PostgreSQL migration plan.
class PostgresqlMigrationResult
    extends MigrationResult<PostgresqlMigrationPlan> {
  /// Creates a PostgreSQL migration result.
  const PostgresqlMigrationResult({
    required super.plan,
    required super.applied,
  });
}

/// Result of rolling back PostgreSQL migration state.
class PostgresqlRollbackResult extends RollbackResult {
  /// Creates a rollback result.
  const PostgresqlRollbackResult({
    required super.targetMigrationName,
    required super.rolledBack,
    required super.statementCount,
    required super.warnings,
  });
}

/// Applies, records, and rolls back PostgreSQL migrations.
class PostgresqlMigrationRunner {
  /// Creates a PostgreSQL migration runner.
  const PostgresqlMigrationRunner({
    this.planner = const PostgresqlMigrationPlanner(),
  });

  /// Migration history table name.
  static const String historyTableName = '_comon_orm_migrations';

  /// Provider name stored with history records and checksums.
  static const String providerName = 'postgresql';

  /// Planner used to compute schema transitions.
  final PostgresqlMigrationPlanner planner;

  /// Ensures the migration history table exists and contains all known columns.
  Future<void> ensureHistoryTable(pg.SessionExecutor executor) async {
    await executor.run((session) async {
      await session.execute('''
          CREATE TABLE IF NOT EXISTS "$historyTableName" (
            name TEXT PRIMARY KEY,
            applied_at TIMESTAMPTZ NOT NULL,
            statement_count INTEGER NOT NULL,
            kind TEXT NOT NULL DEFAULT 'apply',
            target_name TEXT,
            provider TEXT,
            checksum TEXT,
            before_schema TEXT,
            after_schema TEXT,
            warnings TEXT,
            rebuild_required BOOLEAN NOT NULL DEFAULT FALSE
          )
        ''', ignoreRows: true);
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS kind TEXT NOT NULL DEFAULT \'apply\'',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS target_name TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS provider TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS checksum TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS before_schema TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS after_schema TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS warnings TEXT',
        ignoreRows: true,
      );
      await session.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN IF NOT EXISTS rebuild_required BOOLEAN NOT NULL DEFAULT FALSE',
        ignoreRows: true,
      );
    });
  }

  /// Loads the full migration history ordered by application time.
  Future<List<PostgresqlMigrationRecord>> loadHistory(
    pg.SessionExecutor executor,
  ) async {
    await ensureHistoryTable(executor);
    final rows = await _query(executor, '''
         SELECT name, applied_at, statement_count, kind, target_name,
           provider, checksum, before_schema, after_schema,
           warnings, rebuild_required
        FROM "$historyTableName"
        ORDER BY applied_at ASC, name ASC
      ''');

    return rows
        .map(
          (row) => PostgresqlMigrationRecord(
            name: row['name'] as String,
            appliedAt: _asDateTime(row['applied_at'])!,
            statementCount: _asInt(row['statement_count']),
            kind: _parseRecordKind(row['kind'] as String? ?? 'apply'),
            warnings: decodeMigrationWarnings(row['warnings'] as String?),
            rebuildRequired: _asBool(row['rebuild_required']),
            targetName: row['target_name'] as String?,
            provider: row['provider'] as String?,
            checksum: row['checksum'] as String?,
            beforeSchema: row['before_schema'] as String?,
            afterSchema: row['after_schema'] as String?,
          ),
        )
        .toList(growable: false);
  }

  /// Loads only the currently active apply records.
  Future<List<PostgresqlMigrationRecord>> loadActiveHistory(
    pg.SessionExecutor executor,
  ) async {
    final history = await loadHistory(executor);
    final activeNames = _activeMigrationNames(history);
    return history
        .where((record) => record.isApply && activeNames.contains(record.name))
        .toList(growable: false);
  }

  /// Applies the schema diff to [target] and writes a history record.
  Future<PostgresqlMigrationResult> migrateToSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String migrationName,
    bool allowWarnings = false,
  }) async {
    await ensureHistoryTable(executor);
    final appliedNames = _activeMigrationNames(await loadHistory(executor));
    if (appliedNames.contains(migrationName)) {
      return PostgresqlMigrationResult(
        plan: const PostgresqlMigrationPlan(
          statements: <String>[],
          warnings: <String>[],
        ),
        applied: false,
      );
    }

    final filteredFrom = filterSchemaForUserModels(
      await planner.schemaIntrospector.introspect(executor),
      historyTableName: historyTableName,
    );
    final plan = _mergeRiskWarnings(
      planner.plan(from: filteredFrom, to: target),
      detectPotentialDataLossWarnings(from: filteredFrom, to: target),
    );
    final beforeSchema = schemaToSource(filteredFrom);
    final afterSchema = schemaToSource(target);
    final migrationSql = buildMigrationSqlScript(plan);
    final checksum = computeMigrationChecksum(
      provider: providerName,
      beforeSchema: beforeSchema,
      afterSchema: afterSchema,
      migrationSql: migrationSql,
      warnings: plan.warnings,
      requiresRebuild: plan.requiresRebuild,
    );
    if (plan.warnings.isNotEmpty && !allowWarnings) {
      throw StateError(
        'Migration plan contains warnings: ${plan.warnings.join(' | ')}',
      );
    }

    await executor.runTx((session) async {
      if (plan.requiresRebuild) {
        await _rebuildDatabase(
          session: session,
          source: filteredFrom,
          target: target,
        );
      } else {
        for (final statement in plan.statements) {
          await session.execute(statement, ignoreRows: true);
        }
      }
      await _recordHistory(
        session,
        migrationName: migrationName,
        statementCount: plan.requiresRebuild
            ? target.models.length
            : plan.statements.length,
        kind: PostgresqlMigrationRecordKind.apply,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: plan.warnings,
        rebuildRequired: plan.requiresRebuild,
      );
    });

    return PostgresqlMigrationResult(
      plan: plan,
      applied: plan.requiresRebuild || plan.statements.isNotEmpty,
    );
  }

  /// Applies the schema diff to [target] without writing migration history.
  Future<PostgresqlMigrationResult> pushToSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    bool allowWarnings = false,
  }) async {
    final filteredFrom = filterSchemaForUserModels(
      await planner.schemaIntrospector.introspect(executor),
      historyTableName: historyTableName,
    );
    final plan = _mergeRiskWarnings(
      planner.plan(from: filteredFrom, to: target),
      detectPotentialDataLossWarnings(from: filteredFrom, to: target),
    );
    if (plan.warnings.isNotEmpty && !allowWarnings) {
      throw StateError(
        'Migration plan contains warnings: ${plan.warnings.join(' | ')}',
      );
    }

    if (!plan.requiresRebuild && plan.statements.isEmpty) {
      return PostgresqlMigrationResult(plan: plan, applied: false);
    }

    await executor.runTx((session) async {
      if (plan.requiresRebuild) {
        await _rebuildDatabase(
          session: session,
          source: filteredFrom,
          target: target,
        );
      } else {
        for (final statement in plan.statements) {
          await session.execute(statement, ignoreRows: true);
        }
      }
    });

    return PostgresqlMigrationResult(
      plan: plan,
      applied: plan.requiresRebuild || plan.statements.isNotEmpty,
    );
  }

  /// Rolls migration history back to [targetMigrationName].
  Future<PostgresqlRollbackResult> rollbackToSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String targetMigrationName,
    String? rollbackName,
    bool allowWarnings = false,
  }) async {
    await ensureHistoryTable(executor);
    final history = await loadHistory(executor);
    final activeNames = _activeMigrationNames(history);
    if (!activeNames.contains(targetMigrationName)) {
      return PostgresqlRollbackResult(
        targetMigrationName: targetMigrationName,
        rolledBack: false,
        statementCount: 0,
        warnings: const <String>[],
      );
    }

    final source = filterSchemaForUserModels(
      await planner.schemaIntrospector.introspect(executor),
      historyTableName: historyTableName,
    );
    final plan = _mergeRiskWarnings(
      planner.plan(from: source, to: target),
      detectPotentialDataLossWarnings(from: source, to: target),
    );
    if (plan.warnings.isNotEmpty && !allowWarnings) {
      throw StateError(
        'Rollback plan contains warnings: ${plan.warnings.join(' | ')}',
      );
    }
    final effectiveRollbackName =
        rollbackName ??
        '${targetMigrationName}_rollback_${DateTime.now().toUtc().millisecondsSinceEpoch}';
    final beforeSchema = schemaToSource(source);
    final afterSchema = schemaToSource(target);
    final migrationSql = buildMigrationSqlScript(plan);
    final checksum = computeMigrationChecksum(
      provider: providerName,
      beforeSchema: beforeSchema,
      afterSchema: afterSchema,
      migrationSql: migrationSql,
      warnings: plan.warnings,
      requiresRebuild: true,
    );
    var statementCount = 0;

    await executor.runTx((session) async {
      statementCount = await _rebuildDatabase(
        session: session,
        source: source,
        target: target,
      );
      await _recordHistory(
        session,
        migrationName: effectiveRollbackName,
        statementCount: statementCount,
        kind: PostgresqlMigrationRecordKind.rollback,
        targetName: targetMigrationName,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: plan.warnings,
        rebuildRequired: true,
      );
    });

    return PostgresqlRollbackResult(
      targetMigrationName: targetMigrationName,
      rolledBack: true,
      statementCount: statementCount,
      warnings: List<String>.unmodifiable(plan.warnings),
    );
  }

  Future<void> _recordHistory(
    pg.Session session, {
    required String migrationName,
    required int statementCount,
    required PostgresqlMigrationRecordKind kind,
    required String provider,
    required String checksum,
    required String beforeSchema,
    required String afterSchema,
    required List<String> warnings,
    required bool rebuildRequired,
    String? targetName,
  }) {
    return session.execute(
      '''
        INSERT INTO "$historyTableName"
          (name, applied_at, statement_count, kind, target_name, provider,
           checksum, before_schema, after_schema, warnings, rebuild_required)
        VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10, \$11)
      ''',
      parameters: <Object?>[
        migrationName,
        DateTime.now().toUtc(),
        statementCount,
        kind.name,
        targetName,
        provider,
        checksum,
        beforeSchema,
        afterSchema,
        encodeMigrationWarnings(warnings),
        rebuildRequired,
      ],
      ignoreRows: true,
    );
  }

  /// Inserts an apply record without executing schema statements.
  Future<bool> markMigrationApplied({
    required pg.SessionExecutor executor,
    required String migrationName,
    required int statementCount,
    required String checksum,
    required String beforeSchema,
    required String afterSchema,
    required List<String> warnings,
    required bool rebuildRequired,
  }) async {
    await ensureHistoryTable(executor);
    final activeNames = _activeMigrationNames(await loadHistory(executor));
    if (activeNames.contains(migrationName)) {
      return false;
    }

    await executor.run((session) {
      return _recordHistory(
        session,
        migrationName: migrationName,
        statementCount: statementCount,
        kind: PostgresqlMigrationRecordKind.apply,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: warnings,
        rebuildRequired: rebuildRequired,
      );
    });
    return true;
  }

  /// Inserts a rollback record without executing schema statements.
  Future<bool> markMigrationRolledBack({
    required pg.SessionExecutor executor,
    required String migrationName,
    String? rollbackName,
  }) async {
    await ensureHistoryTable(executor);
    final history = await loadHistory(executor);
    final activeNames = _activeMigrationNames(history);
    if (!activeNames.contains(migrationName)) {
      return false;
    }

    final targetRecord = history.lastWhere(
      (record) => record.name == migrationName,
    );
    final effectiveRollbackName =
        rollbackName ??
        '${migrationName}_resolve_rollback_${DateTime.now().toUtc().millisecondsSinceEpoch}';
    await executor.run((session) {
      return _recordHistory(
        session,
        migrationName: effectiveRollbackName,
        statementCount: 0,
        kind: PostgresqlMigrationRecordKind.rollback,
        targetName: migrationName,
        provider: providerName,
        checksum: targetRecord.checksum ?? effectiveRollbackName,
        beforeSchema:
            targetRecord.afterSchema ?? targetRecord.beforeSchema ?? '',
        afterSchema:
            targetRecord.beforeSchema ?? targetRecord.afterSchema ?? '',
        warnings: const <String>[],
        rebuildRequired: false,
      );
    });
    return true;
  }

  Future<int> _rebuildDatabase({
    required pg.TxSession session,
    required SchemaDocument source,
    required SchemaDocument target,
  }) async {
    var statementCount = 0;
    final renamedTables = <String>[];
    final renamedEnums = <(String, String)>[];

    for (final sourceEnum in source.enums) {
      final targetEnum =
          target.findEnum(sourceEnum.name) ??
          target.findEnumByDatabaseName(sourceEnum.databaseName);
      if (targetEnum == null || !_sameEnumDefinition(sourceEnum, targetEnum)) {
        final tempEnumName = _tempEnumName(sourceEnum.databaseName);
        await session.execute(
          'ALTER TYPE ${_quoteIdentifier(sourceEnum.databaseName)} '
          'RENAME TO ${_quoteIdentifier(tempEnumName)}',
          ignoreRows: true,
        );
        renamedEnums.add((sourceEnum.databaseName, tempEnumName));
        statementCount++;
      }
    }

    for (final model in source.models) {
      final tempName = _tempTableName(model.databaseName);
      await session.execute(
        'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
        'RENAME TO ${_quoteIdentifier(tempName)}',
        ignoreRows: true,
      );
      renamedTables.add(tempName);
      statementCount++;
    }

    for (final storage in collectImplicitManyToManyStorages(source)) {
      final tempName = _tempTableName(storage.tableName);
      await session.execute(
        'ALTER TABLE ${_quoteIdentifier(storage.tableName)} '
        'RENAME TO ${_quoteIdentifier(tempName)}',
        ignoreRows: true,
      );
      renamedTables.add(tempName);
      statementCount++;
    }

    for (final statement in planner.schemaApplier.createSchemaStatements(
      target,
    )) {
      await session.execute(statement, ignoreRows: true);
      statementCount++;
    }

    for (final targetModel in target.models) {
      final sourceModel = source.findModel(targetModel.name);
      if (sourceModel == null) {
        continue;
      }

      await _validateEnumCopyCompatibility(
        session: session,
        sourceSchema: source,
        targetSchema: target,
        sourceModel: sourceModel,
        targetModel: targetModel,
      );

      final copyColumns = _copyableColumns(
        sourceSchema: source,
        targetSchema: target,
        sourceModel: sourceModel,
        targetModel: targetModel,
      );
      if (copyColumns.isEmpty) {
        continue;
      }

      final targetColumns = copyColumns
          .map((mapping) => _quoteIdentifier(mapping.targetColumn))
          .join(', ');
      final sourceExpressions = copyColumns
          .map((mapping) => mapping.sourceExpression)
          .join(', ');
      await session.execute(
        'INSERT INTO ${_quoteIdentifier(targetModel.databaseName)} ($targetColumns) '
        'SELECT $sourceExpressions FROM ${_quoteIdentifier(_tempTableName(sourceModel.databaseName))}',
        ignoreRows: true,
      );
      statementCount++;
    }

    final sourceStorages = {
      for (final storage in collectImplicitManyToManyStorages(source))
        storage.tableName: storage,
    };
    for (final targetStorage in collectImplicitManyToManyStorages(target)) {
      final sourceStorage = sourceStorages[targetStorage.tableName];
      if (sourceStorage == null ||
          sourceStorage.signature != targetStorage.signature) {
        continue;
      }

      final targetColumns = [
        ...targetStorage.sourceJoinColumns,
        ...targetStorage.targetJoinColumns,
      ].map(_quoteIdentifier).join(', ');
      final sourceColumns = [
        ...sourceStorage.sourceJoinColumns,
        ...sourceStorage.targetJoinColumns,
      ].map(_quoteIdentifier).join(', ');

      await session.execute(
        'INSERT INTO ${_quoteIdentifier(targetStorage.tableName)} '
        '($targetColumns) '
        'SELECT $sourceColumns '
        'FROM ${_quoteIdentifier(_tempTableName(sourceStorage.tableName))}',
        ignoreRows: true,
      );
      statementCount++;
    }

    for (final tempName in renamedTables) {
      await session.execute(
        'DROP TABLE ${_quoteIdentifier(tempName)}',
        ignoreRows: true,
      );
      statementCount++;
    }

    for (final rename in renamedEnums) {
      await session.execute(
        'DROP TYPE IF EXISTS ${_quoteIdentifier(rename.$2)}',
        ignoreRows: true,
      );
      statementCount++;
    }

    return statementCount;
  }

  Future<void> _validateEnumCopyCompatibility({
    required pg.TxSession session,
    required SchemaDocument sourceSchema,
    required SchemaDocument targetSchema,
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
  }) async {
    for (final targetField in targetModel.fields) {
      if (targetField.isList) {
        continue;
      }

      final sourceField = sourceModel.findField(targetField.name);
      if (sourceField == null || sourceField.isList) {
        continue;
      }

      final sourceEnum =
          sourceSchema.findEnum(sourceField.type) ??
          sourceSchema.findEnumByDatabaseName(sourceField.type);
      final targetEnum =
          targetSchema.findEnum(targetField.type) ??
          targetSchema.findEnumByDatabaseName(targetField.type);
      if (sourceEnum == null || targetEnum == null) {
        continue;
      }
      if (_sameEnumDefinition(sourceEnum, targetEnum)) {
        continue;
      }

      final allowedValues = targetEnum.values.map(_quoteLiteral).join(', ');
      final rows = await session.execute(
        'SELECT DISTINCT ${_quoteIdentifier(sourceField.databaseName)}::text AS value '
        'FROM ${_quoteIdentifier(_tempTableName(sourceModel.databaseName))} '
        'WHERE ${_quoteIdentifier(sourceField.databaseName)} IS NOT NULL '
        'AND ${_quoteIdentifier(sourceField.databaseName)}::text NOT IN ($allowedValues) '
        'ORDER BY value ASC',
      );
      if (rows.isEmpty) {
        continue;
      }

      final invalidValues = rows
          .map((row) => row.toColumnMap()['value'] as String)
          .toList(growable: false);
      throw StateError(
        'Cannot rebuild enum ${targetEnum.name} for '
        '${targetModel.name}.${targetField.name}; '
        'rows contain values not present in target enum: '
        '${invalidValues.join(', ')}',
      );
    }
  }

  List<_CopyColumnMapping> _copyableColumns({
    required SchemaDocument sourceSchema,
    required SchemaDocument targetSchema,
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
  }) {
    bool isCopyableField(FieldDefinition field, SchemaDocument schema) {
      if (field.isList) {
        return false;
      }
      return field.isScalar ||
          schema.findEnum(field.type) != null ||
          schema.findEnumByDatabaseName(field.type) != null;
    }

    final sourceFields = {
      for (final field in sourceModel.fields)
        if (isCopyableField(field, sourceSchema)) field.name: field,
    };
    final copyColumns = <_CopyColumnMapping>[];

    for (final targetField in targetModel.fields) {
      if (!isCopyableField(targetField, targetSchema)) {
        continue;
      }
      final sourceField = sourceFields[targetField.name];
      if (sourceField == null) {
        continue;
      }
      if (!_sameFieldType(
        sourceSchema,
        sourceField,
        targetSchema,
        targetField,
      )) {
        continue;
      }

      final sourceColumn = _quoteIdentifier(sourceField.databaseName);
      final targetColumn = targetField.databaseName;
      final targetEnum =
          targetSchema.findEnum(targetField.type) ??
          targetSchema.findEnumByDatabaseName(targetField.type);
      final sourceEnum =
          sourceSchema.findEnum(sourceField.type) ??
          sourceSchema.findEnumByDatabaseName(sourceField.type);
      final targetIsEnum = targetEnum != null;
      final sourceIsEnum = sourceEnum != null;

      if (sourceIsEnum && targetIsEnum) {
        copyColumns.add(
          _CopyColumnMapping(
            targetColumn: targetColumn,
            sourceExpression:
                '$sourceColumn::text::${_quoteIdentifier(targetEnum.databaseName)}',
          ),
        );
        continue;
      }

      copyColumns.add(
        _CopyColumnMapping(
          targetColumn: targetColumn,
          sourceExpression: sourceColumn,
        ),
      );
    }

    return List<_CopyColumnMapping>.unmodifiable(copyColumns);
  }

  bool _sameEnumDefinition(EnumDefinition left, EnumDefinition right) {
    if (left.values.length != right.values.length) {
      return false;
    }
    for (var index = 0; index < left.values.length; index++) {
      if (left.values[index] != right.values[index]) {
        return false;
      }
    }
    return true;
  }

  bool _sameFieldType(
    SchemaDocument sourceSchema,
    FieldDefinition sourceField,
    SchemaDocument targetSchema,
    FieldDefinition targetField,
  ) {
    if (sourceField.type == targetField.type) {
      return true;
    }

    final sourceEnum =
        sourceSchema.findEnum(sourceField.type) ??
        sourceSchema.findEnumByDatabaseName(sourceField.type);
    final targetEnum =
        targetSchema.findEnum(targetField.type) ??
        targetSchema.findEnumByDatabaseName(targetField.type);
    if (sourceEnum == null || targetEnum == null) {
      return false;
    }

    return sourceEnum.databaseName == targetEnum.databaseName;
  }

  PostgresqlMigrationRecordKind _parseRecordKind(String value) {
    return switch (value) {
      'rollback' => PostgresqlMigrationRecordKind.rollback,
      _ => PostgresqlMigrationRecordKind.apply,
    };
  }

  Set<String> _activeMigrationNames(List<PostgresqlMigrationRecord> history) {
    final activeNames = <String>{};
    for (final record in history) {
      if (record.isApply) {
        activeNames.add(record.name);
        continue;
      }
      final targetName = record.targetName;
      if (targetName != null) {
        activeNames.remove(targetName);
      }
    }
    return activeNames;
  }

  Future<List<Map<String, Object?>>> _query(
    pg.SessionExecutor executor,
    String sql,
  ) {
    return executor.run((session) async {
      final result = await session.execute(sql);
      return result
          .map((row) => Map<String, Object?>.from(row.toColumnMap()))
          .toList(growable: false);
    });
  }

  DateTime? _asDateTime(Object? value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse('$value');
  }

  bool _asBool(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0;
    }
    if (value is String) {
      return value == 'true' || value == 't' || value == '1';
    }
    return false;
  }

  PostgresqlMigrationPlan _mergeRiskWarnings(
    PostgresqlMigrationPlan plan,
    List<String> riskWarnings,
  ) {
    return PostgresqlMigrationPlan(
      statements: plan.statements,
      warnings: mergeMigrationWarnings(plan.warnings, riskWarnings),
      requiresRebuild: plan.requiresRebuild,
    );
  }

  String _tempTableName(String tableName) => '__comon_orm_old_$tableName';

  String _tempEnumName(String enumName) => '__comon_orm_old_$enumName';

  String _quoteIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }

  String _quoteLiteral(String value) {
    return '\'${value.replaceAll("'", "''")}\'';
  }
}

class _CopyColumnMapping {
  const _CopyColumnMapping({
    required this.targetColumn,
    required this.sourceExpression,
  });

  final String targetColumn;
  final String sourceExpression;
}
