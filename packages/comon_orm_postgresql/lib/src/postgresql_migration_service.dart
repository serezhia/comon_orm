import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_migration_planner.dart';
import 'postgresql_migration_runner.dart';

/// File-backed PostgreSQL migration draft created from schema diffing.
class PostgresqlMigrationDraft extends MigrationDraft<PostgresqlMigrationPlan> {
  /// Creates a migration draft.
  const PostgresqlMigrationDraft({
    required super.name,
    required super.generatedAt,
    required super.plan,
    required super.beforeSchema,
    required super.afterSchema,
  }) : super(providerName: PostgresqlMigrationRunner.providerName);
}

/// Issue reported by `status` when local and database migration state differ.
class PostgresqlMigrationStatusIssue extends MigrationStatusIssue {
  /// Creates a status issue.
  const PostgresqlMigrationStatusIssue({
    required super.code,
    required super.message,
  });
}

/// Summary returned by PostgreSQL migration status checks.
class PostgresqlMigrationStatus
    extends MigrationStatus<PostgresqlMigrationStatusIssue> {
  /// Creates a migration status summary.
  const PostgresqlMigrationStatus({
    required super.localMigrationCount,
    required super.activeMigrationCount,
    required super.issues,
  });
}

/// High-level PostgreSQL migration orchestration service.
class PostgresqlMigrationService {
  /// Creates a PostgreSQL migration service.
  const PostgresqlMigrationService({
    this.planner = const PostgresqlMigrationPlanner(),
    this.runner = const PostgresqlMigrationRunner(),
  });

  /// Planner used to create migration plans.
  final PostgresqlMigrationPlanner planner;

  /// Runner used to apply, rollback, and inspect migrations.
  final PostgresqlMigrationRunner runner;

  /// Creates a migration draft by diffing the live database against [target].
  Future<PostgresqlMigrationDraft> draftFromDatabase({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String migrationName,
  }) async {
    final source = filterSchemaForUserModels(
      await planner.schemaIntrospector.introspect(executor),
      historyTableName: PostgresqlMigrationRunner.historyTableName,
    );
    final plan = _mergeRiskWarnings(
      planner.plan(from: source, to: target),
      detectPotentialDataLossWarnings(from: source, to: target),
    );
    return PostgresqlMigrationDraft(
      name: migrationName,
      generatedAt: DateTime.now().toUtc(),
      plan: plan,
      beforeSchema: schemaToSource(source),
      afterSchema: schemaToSource(target),
    );
  }

  /// Writes a draft to a migration directory on disk.
  Directory writeDraft({
    required PostgresqlMigrationDraft draft,
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
        provider: PostgresqlMigrationRunner.providerName,
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
  Future<PostgresqlMigrationResult> applySchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String migrationName,
    bool allowWarnings = false,
  }) {
    return runner.migrateToSchema(
      executor: executor,
      target: target,
      migrationName: migrationName,
      allowWarnings: allowWarnings,
    );
  }

  /// Applies [target] directly without creating history entries.
  Future<PostgresqlMigrationResult> pushSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    bool allowWarnings = false,
  }) {
    return runner.pushToSchema(
      executor: executor,
      target: target,
      allowWarnings: allowWarnings,
    );
  }

  /// Applies all pending local migrations in order.
  Future<DeployResult> deployMigrations({
    required pg.SessionExecutor executor,
    required String migrationsDirectory,
  }) async {
    final localArtifacts = loadLocalMigrationArtifacts(
      migrationsDirectory,
      provider: PostgresqlMigrationRunner.providerName,
    );
    final activeNames = (await runner.loadActiveHistory(
      executor,
    )).map((record) => record.name).toSet();
    final appliedMigrationNames = <String>[];

    for (final artifact in localArtifacts) {
      if (activeNames.contains(artifact.name)) {
        continue;
      }

      if (containsManualMigrationWarnings(artifact.warnings)) {
        throw ManualMigrationRequiredException(
          'Migration `${artifact.name}` requires manual migration and cannot be applied automatically. Complete the change manually, then run `migrate resolve --applied ${artifact.name}`.',
        );
      }

      await runner.migrateToSchema(
        executor: executor,
        target: const SchemaParser().parse(artifact.afterSchema),
        migrationName: artifact.name,
        allowWarnings: true,
      );
      activeNames.add(artifact.name);
      appliedMigrationNames.add(artifact.name);
    }

    return DeployResult(
      localMigrationCount: localArtifacts.length,
      appliedMigrationNames: List<String>.unmodifiable(appliedMigrationNames),
    );
  }

  /// Marks a local migration as already applied without executing SQL.
  Future<ResolveResult> resolveApplied({
    required pg.SessionExecutor executor,
    required String migrationsDirectory,
    required String migrationName,
  }) async {
    final artifact = _findRequiredArtifact(
      migrationsDirectory: migrationsDirectory,
      migrationName: migrationName,
    );
    final changed = await runner.markMigrationApplied(
      executor: executor,
      migrationName: migrationName,
      statementCount: artifact.statementCount,
      checksum: artifact.checksum,
      beforeSchema: artifact.beforeSchema,
      afterSchema: artifact.afterSchema,
      warnings: artifact.warnings,
      rebuildRequired: artifact.rebuildRequired,
    );
    return ResolveResult(
      migrationName: migrationName,
      action: 'applied',
      changed: changed,
    );
  }

  /// Marks an active migration as rolled back without executing SQL.
  Future<ResolveResult> resolveRolledBack({
    required pg.SessionExecutor executor,
    required String migrationName,
  }) async {
    final changed = await runner.markMigrationRolledBack(
      executor: executor,
      migrationName: migrationName,
    );
    return ResolveResult(
      migrationName: migrationName,
      action: 'rolled back',
      changed: changed,
    );
  }

  /// Rolls back a migration using stored or on-disk schema snapshots.
  Future<PostgresqlRollbackResult> rollbackMigration({
    required pg.SessionExecutor executor,
    required String migrationsDirectory,
    String? migrationName,
    String? rollbackName,
    bool allowWarnings = false,
  }) async {
    final activeHistory = await runner.loadActiveHistory(executor);
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
      executor: executor,
      target: targetSchema,
      targetMigrationName: targetRecord.name,
      rollbackName: rollbackName,
      allowWarnings: allowWarnings,
    );
  }

  /// Compares database history with local migration artifacts.
  Future<PostgresqlMigrationStatus> status({
    required pg.SessionExecutor executor,
    required String migrationsDirectory,
  }) async {
    final activeHistory = await runner.loadActiveHistory(executor);
    final issues = <PostgresqlMigrationStatusIssue>[];
    List<LocalMigrationArtifact> localArtifacts;
    try {
      localArtifacts = loadLocalMigrationArtifacts(
        migrationsDirectory,
        provider: PostgresqlMigrationRunner.providerName,
      );
    } on StateError catch (error) {
      issues.add(
        PostgresqlMigrationStatusIssue(
          code: 'invalid-local-artifacts',
          message: error.message,
        ),
      );
      localArtifacts = const <LocalMigrationArtifact>[];
    } on UnsupportedError catch (error) {
      issues.add(
        PostgresqlMigrationStatusIssue(
          code: 'local-artifacts-unavailable',
          message: '$error',
        ),
      );
      return PostgresqlMigrationStatus(
        localMigrationCount: 0,
        activeMigrationCount: activeHistory.length,
        issues: List<PostgresqlMigrationStatusIssue>.unmodifiable(issues),
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
          PostgresqlMigrationStatusIssue(
            code: 'applied-migration-missing-locally',
            message:
                'Migration ${record.name} is active in the database but missing from $migrationsDirectory.',
          ),
        );
        continue;
      }
      if (record.checksum != null && record.checksum != local.checksum) {
        issues.add(
          PostgresqlMigrationStatusIssue(
            code: 'checksum-mismatch',
            message:
                'Migration ${record.name} differs between database history and local artifacts.',
          ),
        );
      }
      if (record.beforeSchema == null || record.afterSchema == null) {
        issues.add(
          PostgresqlMigrationStatusIssue(
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
          PostgresqlMigrationStatusIssue(
            code: 'local-migration-not-applied',
            message:
                'Local migration ${artifact.name} exists in $migrationsDirectory but is not currently active in the database.',
          ),
        );
      }
    }

    return PostgresqlMigrationStatus(
      localMigrationCount: localArtifacts.length,
      activeMigrationCount: activeHistory.length,
      issues: List<PostgresqlMigrationStatusIssue>.unmodifiable(issues),
    );
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

  LocalMigrationArtifact _findRequiredArtifact({
    required String migrationsDirectory,
    required String migrationName,
  }) {
    final artifacts = loadLocalMigrationArtifacts(
      migrationsDirectory,
      provider: PostgresqlMigrationRunner.providerName,
    );
    for (final artifact in artifacts) {
      if (artifact.name == migrationName) {
        return artifact;
      }
    }
    throw StateError(
      'Migration $migrationName was not found in $migrationsDirectory.',
    );
  }
}
