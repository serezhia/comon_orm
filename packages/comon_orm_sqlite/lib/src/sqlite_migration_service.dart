import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_migration_planner.dart';
import 'sqlite_migration_runner.dart';

/// File-backed SQLite migration draft created from schema diffing.
class SqliteMigrationDraft extends MigrationDraft<SqliteMigrationPlan> {
  /// Creates a migration draft.
  const SqliteMigrationDraft({
    required super.name,
    required super.generatedAt,
    required super.plan,
    required super.beforeSchema,
    required super.afterSchema,
  }) : super(providerName: SqliteMigrationRunner.providerName);
}

/// Issue reported by `status` when local and database migration state differ.
class SqliteMigrationStatusIssue extends MigrationStatusIssue {
  /// Creates a status issue.
  const SqliteMigrationStatusIssue({
    required super.code,
    required super.message,
  });
}

/// Summary returned by SQLite migration status checks.
class SqliteMigrationStatus
    extends MigrationStatus<SqliteMigrationStatusIssue> {
  /// Creates a migration status summary.
  const SqliteMigrationStatus({
    required super.localMigrationCount,
    required super.activeMigrationCount,
    required super.issues,
  });
}

/// High-level SQLite migration orchestration service.
class SqliteMigrationService {
  /// Creates a SQLite migration service.
  const SqliteMigrationService({
    this.planner = const SqliteMigrationPlanner(),
    this.runner = const SqliteMigrationRunner(),
  });

  /// Planner used to create migration plans.
  final SqliteMigrationPlanner planner;

  /// Runner used to apply, rollback, and inspect migrations.
  final SqliteMigrationRunner runner;

  /// Creates a migration draft by diffing the live database against [target].
  SqliteMigrationDraft draftFromDatabase({
    required sqlite.Database database,
    required SchemaDocument target,
    required String migrationName,
  }) {
    final source = filterSchemaForUserModels(
      planner.schemaIntrospector.introspect(database),
      historyTableName: SqliteMigrationRunner.historyTableName,
    );
    final plan = _mergeRiskWarnings(
      planner.plan(from: source, to: target),
      detectPotentialDataLossWarnings(from: source, to: target),
    );
    return SqliteMigrationDraft(
      name: migrationName,
      generatedAt: DateTime.now().toUtc(),
      plan: plan,
      beforeSchema: schemaToSource(source),
      afterSchema: schemaToSource(target),
    );
  }

  /// Writes a draft to a migration directory on disk.
  Directory writeDraft({
    required SqliteMigrationDraft draft,
    required String directoryPath,
  }) {
    final root = Directory(directoryPath)..createSync(recursive: true);
    final migrationDir = Directory(
      '${root.path}${Platform.pathSeparator}${draft.name}',
    )..createSync(recursive: true);

    File(
      '${migrationDir.path}${Platform.pathSeparator}migration.sql',
    ).writeAsStringSync(draft.sqlScript);

    File(
      '${migrationDir.path}${Platform.pathSeparator}metadata.txt',
    ).writeAsStringSync(
      metadataText(
        name: draft.name,
        generatedAt: draft.generatedAt,
        statementCount: draft.plan.statements.length,
        warningCount: draft.plan.warnings.length,
        rebuildRequired: draft.plan.requiresRebuild,
        provider: SqliteMigrationRunner.providerName,
        checksum: draft.checksum,
      ),
    );

    File(
      '${migrationDir.path}${Platform.pathSeparator}before.prisma',
    ).writeAsStringSync(draft.beforeSchema);

    File(
      '${migrationDir.path}${Platform.pathSeparator}after.prisma',
    ).writeAsStringSync(draft.afterSchema);

    if (draft.plan.warnings.isNotEmpty) {
      File(
        '${migrationDir.path}${Platform.pathSeparator}warnings.txt',
      ).writeAsStringSync('${draft.plan.warnings.join('\n')}\n');
    }

    return migrationDir;
  }

  /// Applies [target] to the database and records the migration result.
  SqliteMigrationResult applySchema({
    required sqlite.Database database,
    required SchemaDocument target,
    required String migrationName,
    bool allowWarnings = false,
  }) {
    return runner.migrateToSchema(
      database: database,
      target: target,
      migrationName: migrationName,
      allowWarnings: allowWarnings,
    );
  }

  /// Rolls back a migration using stored or on-disk schema snapshots.
  SqliteRollbackResult rollbackMigration({
    required sqlite.Database database,
    required String migrationsDirectory,
    String? migrationName,
    String? rollbackName,
    bool allowWarnings = false,
  }) {
    final activeHistory = runner.loadActiveHistory(database);
    final targetRecord = resolveRollbackTarget(
      activeHistory: activeHistory,
      migrationName: migrationName,
      migrationNameOf: (record) => record.name,
    );

    final beforeSchemaFile = File(
      '$migrationsDirectory${Platform.pathSeparator}${targetRecord.name}'
      '${Platform.pathSeparator}before.prisma',
    );
    final snapshotSource = beforeSchemaFile.existsSync()
        ? beforeSchemaFile.readAsStringSync()
        : targetRecord.beforeSchema;
    if (snapshotSource == null || snapshotSource.trim().isEmpty) {
      throw StateError(
        'Rollback snapshot not found on disk and not stored in database history for ${targetRecord.name}.',
      );
    }

    final targetSchema = const SchemaParser().parse(snapshotSource);

    return runner.rollbackToSchema(
      database: database,
      target: targetSchema,
      targetMigrationName: targetRecord.name,
      rollbackName: rollbackName,
      allowWarnings: allowWarnings,
    );
  }

  /// Compares database history with local migration artifacts.
  SqliteMigrationStatus status({
    required sqlite.Database database,
    required String migrationsDirectory,
  }) {
    final activeHistory = runner.loadActiveHistory(database);
    final issues = <SqliteMigrationStatusIssue>[];
    List<LocalMigrationArtifact> localArtifacts;
    try {
      localArtifacts = loadLocalMigrationArtifacts(
        migrationsDirectory,
        provider: SqliteMigrationRunner.providerName,
      );
    } on StateError catch (error) {
      issues.add(
        SqliteMigrationStatusIssue(
          code: 'invalid-local-artifacts',
          message: error.message,
        ),
      );
      localArtifacts = const <LocalMigrationArtifact>[];
    } on UnsupportedError catch (error) {
      issues.add(
        SqliteMigrationStatusIssue(
          code: 'local-artifacts-unavailable',
          message: '$error',
        ),
      );
      return SqliteMigrationStatus(
        localMigrationCount: 0,
        activeMigrationCount: activeHistory.length,
        issues: List<SqliteMigrationStatusIssue>.unmodifiable(issues),
      );
    }

    final localByName = {
      for (final artifact in localArtifacts) artifact.name: artifact,
    };
    final activeNames = activeHistory.map((record) => record.name).toSet();

    for (final record in activeHistory) {
      final local = localByName[record.name];
      if (local == null) {
        issues.add(
          SqliteMigrationStatusIssue(
            code: 'applied-migration-missing-locally',
            message:
                'Migration ${record.name} is active in the database but missing from $migrationsDirectory.',
          ),
        );
        continue;
      }
      if (record.checksum != null && record.checksum != local.checksum) {
        issues.add(
          SqliteMigrationStatusIssue(
            code: 'checksum-mismatch',
            message:
                'Migration ${record.name} differs between database history and local artifacts.',
          ),
        );
      }
      if (record.beforeSchema == null || record.afterSchema == null) {
        issues.add(
          SqliteMigrationStatusIssue(
            code: 'missing-db-snapshot',
            message:
                'Migration ${record.name} was applied before database snapshots were recorded.',
          ),
        );
      }
    }

    for (final artifact in localArtifacts) {
      if (!activeNames.contains(artifact.name)) {
        issues.add(
          SqliteMigrationStatusIssue(
            code: 'local-migration-not-applied',
            message:
                'Local migration ${artifact.name} exists in $migrationsDirectory but is not currently active in the database.',
          ),
        );
      }
    }

    return SqliteMigrationStatus(
      localMigrationCount: localArtifacts.length,
      activeMigrationCount: activeHistory.length,
      issues: List<SqliteMigrationStatusIssue>.unmodifiable(issues),
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
}
