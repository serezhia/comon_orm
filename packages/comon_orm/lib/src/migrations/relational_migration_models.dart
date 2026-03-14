import '../schema/schema_ast.dart';
import 'migration_artifacts.dart';

/// Contract implemented by relational migration plans.
abstract interface class PlannedMigration {
  /// SQL statements that can be applied directly.
  List<String> get statements;

  /// Human-readable warnings that require operator review.
  List<String> get warnings;

  /// Whether the change requires a schema rebuild.
  bool get requiresRebuild;
}

/// File-backed migration draft created from schema diffing.
class MigrationDraft<TPlan extends PlannedMigration> {
  /// Creates a migration draft.
  const MigrationDraft({
    required this.name,
    required this.generatedAt,
    required this.plan,
    required this.beforeSchema,
    required this.afterSchema,
    required this.providerName,
  });

  /// Migration directory name.
  final String name;

  /// Draft creation timestamp.
  final DateTime generatedAt;

  /// Migration plan derived from the schema diff.
  final TPlan plan;

  /// Schema source before the migration.
  final String beforeSchema;

  /// Schema source after the migration.
  final String afterSchema;

  /// Provider name used for checksums and history metadata.
  final String providerName;

  /// SQL script written to `migration.sql`.
  String get sqlScript => buildMigrationSqlScript(plan);

  /// Stable checksum used for migration history validation.
  String get checksum => computeMigrationChecksum(
    provider: providerName,
    beforeSchema: beforeSchema,
    afterSchema: afterSchema,
    migrationSql: sqlScript,
    warnings: plan.warnings,
    requiresRebuild: plan.requiresRebuild,
  );
}

/// Issue reported when local and database migration state differ.
class MigrationStatusIssue {
  /// Creates a status issue.
  const MigrationStatusIssue({required this.code, required this.message});

  /// Stable machine-readable issue code.
  final String code;

  /// Human-readable issue description.
  final String message;
}

/// Summary returned by relational migration status checks.
class MigrationStatus<TIssue extends MigrationStatusIssue> {
  /// Creates a migration status summary.
  const MigrationStatus({
    required this.localMigrationCount,
    required this.activeMigrationCount,
    required this.issues,
  });

  /// Number of local migration directories found on disk.
  final int localMigrationCount;

  /// Number of migrations currently active in database history.
  final int activeMigrationCount;

  /// Status issues discovered during reconciliation.
  final List<TIssue> issues;

  /// Whether the local artifacts and database history are in sync.
  bool get isClean => issues.isEmpty;
}

/// Single migration history record stored by a relational provider.
class MigrationRecord<TKind extends Enum> {
  /// Creates a migration history record.
  const MigrationRecord({
    required this.name,
    required this.appliedAt,
    required this.statementCount,
    required this.kind,
    required this.warnings,
    required this.rebuildRequired,
    this.targetName,
    this.provider,
    this.checksum,
    this.beforeSchema,
    this.afterSchema,
  });

  /// Migration name.
  final String name;

  /// Timestamp recorded in history.
  final DateTime appliedAt;

  /// Number of executed statements.
  final int statementCount;

  /// History record kind.
  final TKind kind;

  /// Warnings associated with the migration.
  final List<String> warnings;

  /// Whether the migration required a rebuild.
  final bool rebuildRequired;

  /// Rollback target name, when [kind] is rollback.
  final String? targetName;

  /// Provider name stored with the migration.
  final String? provider;

  /// Checksum stored for drift detection.
  final String? checksum;

  /// Stored schema snapshot before the migration.
  final String? beforeSchema;

  /// Stored schema snapshot after the migration.
  final String? afterSchema;

  /// Whether this record represents an apply operation.
  bool get isApply => kind.name == 'apply';

  /// Whether this record represents a rollback operation.
  bool get isRollback => kind.name == 'rollback';
}

/// Result of applying a relational migration plan.
class MigrationResult<TPlan extends PlannedMigration> {
  /// Creates a migration result.
  const MigrationResult({required this.plan, required this.applied});

  /// Executed or proposed migration plan.
  final TPlan plan;

  /// Whether the migration was applied.
  final bool applied;
}

/// Result of rolling back relational migration state.
class RollbackResult {
  /// Creates a rollback result.
  const RollbackResult({
    required this.targetMigrationName,
    required this.rolledBack,
    required this.statementCount,
    required this.warnings,
  });

  /// Name of the migration that was rolled back to.
  final String targetMigrationName;

  /// Whether rollback statements were applied.
  final bool rolledBack;

  /// Number of executed rollback statements.
  final int statementCount;

  /// Warnings raised for the rollback plan.
  final List<String> warnings;
}

/// Builds the canonical SQL script for a migration [plan].
String buildMigrationSqlScript(PlannedMigration plan) {
  if (plan.requiresRebuild) {
    return '-- Schema rebuild required to apply this migration safely.\n';
  }
  if (plan.statements.isEmpty) {
    return '-- No schema changes required.\n';
  }
  return '${plan.statements.join(';\n')};\n';
}

/// Returns [schema] without the provider history table model.
SchemaDocument filterSchemaForUserModels(
  SchemaDocument schema, {
  required String historyTableName,
}) {
  return SchemaDocument(
    models: List<ModelDefinition>.unmodifiable(
      schema.models
          .where((model) => model.name != historyTableName)
          .toList(growable: false),
    ),
    enums: List<EnumDefinition>.unmodifiable(schema.enums),
    datasources: List<DatasourceDefinition>.unmodifiable(schema.datasources),
    generators: List<GeneratorDefinition>.unmodifiable(schema.generators),
  );
}

/// Resolves which active migration should be rolled back.
TRecord resolveRollbackTarget<TRecord>({
  required List<TRecord> activeHistory,
  required String? migrationName,
  required String Function(TRecord record) migrationNameOf,
}) {
  if (activeHistory.isEmpty) {
    throw StateError('No applied migrations available to roll back.');
  }
  if (migrationName == null) {
    return activeHistory.last;
  }
  for (final record in activeHistory.reversed) {
    if (migrationNameOf(record) == migrationName) {
      return record;
    }
  }
  throw StateError('Migration is not currently applied: $migrationName');
}

/// Returns the union of plan warnings and detected risk warnings.
List<String> mergeMigrationWarnings(
  List<String> warnings,
  List<String> riskWarnings,
) {
  if (riskWarnings.isEmpty) {
    return List<String>.unmodifiable(warnings);
  }

  return List<String>.unmodifiable(<String>{...warnings, ...riskWarnings});
}
