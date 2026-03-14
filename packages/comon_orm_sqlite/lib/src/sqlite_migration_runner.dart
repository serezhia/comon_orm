import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_migration_planner.dart';

/// Record kind stored in SQLite migration history.
enum SqliteMigrationRecordKind {
  /// History row for a schema apply.
  apply,

  /// History row for a rollback operation.
  rollback,
}

/// Single migration history record stored in SQLite.
class SqliteMigrationRecord extends MigrationRecord<SqliteMigrationRecordKind> {
  /// Creates a migration history record.
  const SqliteMigrationRecord({
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

/// Result of applying a SQLite migration plan.
class SqliteMigrationResult extends MigrationResult<SqliteMigrationPlan> {
  /// Creates a SQLite migration result.
  const SqliteMigrationResult({required super.plan, required super.applied});
}

/// Result of rolling back SQLite migration state.
class SqliteRollbackResult extends RollbackResult {
  /// Creates a rollback result.
  const SqliteRollbackResult({
    required super.targetMigrationName,
    required super.rolledBack,
    required super.statementCount,
    required super.warnings,
  });
}

/// Applies, records, and rolls back SQLite migrations.
class SqliteMigrationRunner {
  /// Creates a SQLite migration runner.
  const SqliteMigrationRunner({this.planner = const SqliteMigrationPlanner()});

  /// Migration history table name.
  static const String historyTableName = '_comon_orm_migrations';

  /// Provider name stored with history records and checksums.
  static const String providerName = 'sqlite';

  /// Planner used to compute schema transitions.
  final SqliteMigrationPlanner planner;

  /// Ensures the migration history table exists and contains all known columns.
  void ensureHistoryTable(sqlite.Database database) {
    database.execute('''
      CREATE TABLE IF NOT EXISTS "$historyTableName" (
        name TEXT PRIMARY KEY,
        applied_at TEXT NOT NULL,
        statement_count INTEGER NOT NULL,
        kind TEXT NOT NULL DEFAULT 'apply',
        target_name TEXT,
        provider TEXT,
        checksum TEXT,
        before_schema TEXT,
        after_schema TEXT,
        warnings TEXT,
        rebuild_required INTEGER NOT NULL DEFAULT 0
      )
    ''');

    final columns = database
        .select('PRAGMA table_info("$historyTableName")')
        .map((row) => row['name'] as String)
        .toSet();

    if (!columns.contains('kind')) {
      database.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN kind TEXT NOT NULL DEFAULT \'apply\'',
      );
    }
    if (!columns.contains('target_name')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN target_name TEXT',
      );
    }
    if (!columns.contains('provider')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN provider TEXT',
      );
    }
    if (!columns.contains('checksum')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN checksum TEXT',
      );
    }
    if (!columns.contains('before_schema')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN before_schema TEXT',
      );
    }
    if (!columns.contains('after_schema')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN after_schema TEXT',
      );
    }
    if (!columns.contains('warnings')) {
      database.execute(
        'ALTER TABLE "$historyTableName" ADD COLUMN warnings TEXT',
      );
    }
    if (!columns.contains('rebuild_required')) {
      database.execute(
        'ALTER TABLE "$historyTableName" '
        'ADD COLUMN rebuild_required INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  /// Loads the full migration history ordered by application time.
  List<SqliteMigrationRecord> loadHistory(sqlite.Database database) {
    ensureHistoryTable(database);
    final rows = database.select('''
            SELECT name, applied_at, statement_count, kind, target_name,
              provider, checksum, before_schema, after_schema,
              warnings, rebuild_required
      FROM "$historyTableName"
      ORDER BY applied_at ASC, name ASC
    ''');

    return rows
        .map(
          (row) => SqliteMigrationRecord(
            name: row['name'] as String,
            appliedAt: DateTime.parse(row['applied_at'] as String),
            statementCount: row['statement_count'] as int,
            kind: _parseRecordKind(row['kind'] as String? ?? 'apply'),
            warnings: decodeMigrationWarnings(row['warnings'] as String?),
            rebuildRequired: (row['rebuild_required'] as int? ?? 0) != 0,
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
  List<SqliteMigrationRecord> loadActiveHistory(sqlite.Database database) {
    final history = loadHistory(database);
    final activeNames = _activeMigrationNames(history);

    return history
        .where((record) => record.isApply && activeNames.contains(record.name))
        .toList(growable: false);
  }

  /// Applies the schema diff to [target] and writes a history record.
  SqliteMigrationResult migrateToSchema({
    required sqlite.Database database,
    required SchemaDocument target,
    required String migrationName,
    bool allowWarnings = false,
  }) {
    ensureHistoryTable(database);
    final appliedNames = _activeMigrationNames(loadHistory(database));

    if (appliedNames.contains(migrationName)) {
      return SqliteMigrationResult(
        plan: const SqliteMigrationPlan(
          statements: <String>[],
          warnings: <String>[],
        ),
        applied: false,
      );
    }

    final filteredFrom = _currentSourceSchema(database);
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

    if (!plan.requiresRebuild && plan.statements.isEmpty) {
      _recordHistory(
        database: database,
        migrationName: migrationName,
        statementCount: 0,
        kind: SqliteMigrationRecordKind.apply,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: plan.warnings,
        rebuildRequired: plan.requiresRebuild,
      );
      return SqliteMigrationResult(plan: plan, applied: false);
    }

    if (plan.requiresRebuild) {
      final statementCount = _rebuildDatabase(
        database: database,
        source: filteredFrom,
        target: target,
      );
      _recordHistory(
        database: database,
        migrationName: migrationName,
        statementCount: statementCount,
        kind: SqliteMigrationRecordKind.apply,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: plan.warnings,
        rebuildRequired: true,
      );
      return SqliteMigrationResult(plan: plan, applied: true);
    }

    database.execute('BEGIN');
    try {
      for (final statement in plan.statements) {
        database.execute(statement);
      }
      _recordHistory(
        database: database,
        migrationName: migrationName,
        statementCount: plan.statements.length,
        kind: SqliteMigrationRecordKind.apply,
        provider: providerName,
        checksum: checksum,
        beforeSchema: beforeSchema,
        afterSchema: afterSchema,
        warnings: plan.warnings,
        rebuildRequired: false,
      );
      database.execute('COMMIT');
      return SqliteMigrationResult(plan: plan, applied: true);
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    }
  }

  /// Rolls migration history back to [targetMigrationName].
  SqliteRollbackResult rollbackToSchema({
    required sqlite.Database database,
    required SchemaDocument target,
    required String targetMigrationName,
    String? rollbackName,
    bool allowWarnings = false,
  }) {
    ensureHistoryTable(database);
    final history = loadHistory(database);
    final activeNames = _activeMigrationNames(history);
    if (!activeNames.contains(targetMigrationName)) {
      return SqliteRollbackResult(
        targetMigrationName: targetMigrationName,
        rolledBack: false,
        statementCount: 0,
        warnings: const <String>[],
      );
    }

    final source = _currentSourceSchema(database);
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
    final statementCount = _rebuildDatabase(
      database: database,
      source: source,
      target: target,
    );

    _recordHistory(
      database: database,
      migrationName: effectiveRollbackName,
      statementCount: statementCount,
      kind: SqliteMigrationRecordKind.rollback,
      provider: providerName,
      checksum: checksum,
      beforeSchema: beforeSchema,
      afterSchema: afterSchema,
      warnings: plan.warnings,
      rebuildRequired: true,
      targetName: targetMigrationName,
    );

    return SqliteRollbackResult(
      targetMigrationName: targetMigrationName,
      rolledBack: true,
      statementCount: statementCount,
      warnings: List<String>.unmodifiable(plan.warnings),
    );
  }

  void _recordHistory({
    required sqlite.Database database,
    required String migrationName,
    required int statementCount,
    required SqliteMigrationRecordKind kind,
    required String provider,
    required String checksum,
    required String beforeSchema,
    required String afterSchema,
    required List<String> warnings,
    required bool rebuildRequired,
    String? targetName,
  }) {
    database.execute(
      'INSERT INTO "$historyTableName" '
      '(name, applied_at, statement_count, kind, target_name, provider, '
      'checksum, before_schema, after_schema, warnings, rebuild_required) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        migrationName,
        DateTime.now().toUtc().toIso8601String(),
        statementCount,
        kind.name,
        targetName,
        provider,
        checksum,
        beforeSchema,
        afterSchema,
        encodeMigrationWarnings(warnings),
        rebuildRequired ? 1 : 0,
      ],
    );
  }

  SqliteMigrationRecordKind _parseRecordKind(String value) {
    return switch (value) {
      'rollback' => SqliteMigrationRecordKind.rollback,
      _ => SqliteMigrationRecordKind.apply,
    };
  }

  Set<String> _activeMigrationNames(List<SqliteMigrationRecord> history) {
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

  int _rebuildDatabase({
    required sqlite.Database database,
    required SchemaDocument source,
    required SchemaDocument target,
  }) {
    var statementCount = 0;
    database.execute('PRAGMA foreign_keys = OFF');
    database.execute('BEGIN');

    try {
      final renamedTables = <String>[];
      for (final model in source.models) {
        final tempName = _tempTableName(model.databaseName);
        database.execute(
          'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
          'RENAME TO ${_quoteIdentifier(tempName)}',
        );
        renamedTables.add(tempName);
        statementCount++;
      }

      for (final storage in collectImplicitManyToManyStorages(source)) {
        final tempName = _tempTableName(storage.tableName);
        database.execute(
          'ALTER TABLE ${_quoteIdentifier(storage.tableName)} '
          'RENAME TO ${_quoteIdentifier(tempName)}',
        );
        renamedTables.add(tempName);
        statementCount++;
      }

      for (final statement in planner.schemaApplier.createTableStatements(
        target,
      )) {
        database.execute(statement);
        statementCount++;
      }
      for (final statement
          in planner.schemaApplier.createImplicitManyToManyTableStatements(
            target,
          )) {
        database.execute(statement);
        statementCount++;
      }

      for (final targetModel in target.models) {
        ModelDefinition? sourceModel;
        for (final model in source.models) {
          if (model.databaseName == targetModel.databaseName) {
            sourceModel = model;
            break;
          }
          if (model.name == targetModel.name) {
            sourceModel ??= model;
          }
        }
        if (sourceModel == null) {
          continue;
        }

        final copyColumns = _copyableColumns(
          sourceModel: sourceModel,
          targetModel: targetModel,
        );
        if (copyColumns.isEmpty) {
          continue;
        }

        final targetCols = copyColumns
            .map((p) => _quoteIdentifier(p.$2))
            .join(', ');
        final sourceCols = copyColumns
            .map((p) => _quoteIdentifier(p.$1))
            .join(', ');
        database.execute(
          'INSERT INTO ${_quoteIdentifier(targetModel.databaseName)} ($targetCols) '
          'SELECT $sourceCols FROM ${_quoteIdentifier(_tempTableName(sourceModel.databaseName))}',
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

        database.execute(
          'INSERT INTO ${_quoteIdentifier(targetStorage.tableName)} '
          '($targetColumns) '
          'SELECT $sourceColumns '
          'FROM ${_quoteIdentifier(_tempTableName(sourceStorage.tableName))}',
        );
        statementCount++;
      }

      for (final tempName in renamedTables) {
        database.execute('DROP TABLE ${_quoteIdentifier(tempName)}');
        statementCount++;
      }

      database.execute('COMMIT');
      return statementCount;
    } catch (_) {
      database.execute('ROLLBACK');
      rethrow;
    } finally {
      database.execute('PRAGMA foreign_keys = ON');
    }
  }

  /// Returns (sourceDbColumnName, targetDbColumnName) pairs for columns that
  /// can be copied from the source model's temp table into the new target table.
  List<(String, String)> _copyableColumns({
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
  }) {
    final sourceFieldsByDatabaseName = {
      for (final field in sourceModel.fields)
        if (field.isScalar && !field.isList) field.databaseName: field,
    };
    final sourceFieldsByName = {
      for (final field in sourceModel.fields)
        if (field.isScalar && !field.isList) field.name: field,
    };
    final copyColumns = <(String, String)>[];

    for (final targetField in targetModel.fields) {
      if (!targetField.isScalar || targetField.isList) {
        continue;
      }

      final sourceField =
          sourceFieldsByDatabaseName[targetField.databaseName] ??
          sourceFieldsByName[targetField.name];
      if (sourceField == null) {
        continue;
      }
      if (sourceField.type != targetField.type) {
        continue;
      }

      copyColumns.add((sourceField.databaseName, targetField.databaseName));
    }

    return List<(String, String)>.unmodifiable(copyColumns);
  }

  String _tempTableName(String modelName) => '__comon_orm_old_$modelName';

  SchemaDocument _currentSourceSchema(sqlite.Database database) {
    final activeHistory = loadActiveHistory(database);
    if (activeHistory.isNotEmpty) {
      final lastSchemaSource = activeHistory.last.afterSchema;
      if (lastSchemaSource != null && lastSchemaSource.trim().isNotEmpty) {
        return const SchemaParser().parse(lastSchemaSource);
      }
    }

    return filterSchemaForUserModels(
      planner.schemaIntrospector.introspect(database),
      historyTableName: historyTableName,
    );
  }

  SqliteMigrationPlan _mergeRiskWarnings(
    SqliteMigrationPlan plan,
    List<String> riskWarnings,
  ) {
    return SqliteMigrationPlan(
      statements: plan.statements,
      warnings: mergeMigrationWarnings(plan.warnings, riskWarnings),
      requiresRebuild: plan.requiresRebuild,
    );
  }

  String _quoteIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}
