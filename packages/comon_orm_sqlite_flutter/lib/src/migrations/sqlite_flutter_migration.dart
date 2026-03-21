import 'package:comon_orm/comon_orm.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'migration_schema.dart';
import 'sqlite_flutter_schema_migration_planner.dart';

/// Runs one versioned local SQLite migration step.
typedef SqliteFlutterMigrationRunner = Future<void> Function(Transaction tx);

/// Copies or transforms data during a rebuild-style migration.
typedef SqliteFlutterRebuildTableRunner =
    Future<void> Function(
      Transaction tx,
      String sourceTable,
      String targetTable,
    );

/// One explicit local upgrade step for a Flutter SQLite database.
class SqliteFlutterMigration {
  /// Creates a custom Dart-coded migration step.
  const SqliteFlutterMigration({
    required this.fromVersion,
    required this.toVersion,
    required this.debugName,
    required SqliteFlutterMigrationRunner run,
  }) : _run = run;

  /// Creates a SQL-first migration step with an optional post-SQL callback.
  factory SqliteFlutterMigration.sql({
    required int fromVersion,
    required int toVersion,
    required String debugName,
    required List<String> statements,
    SqliteFlutterMigrationRunner? afterSql,
  }) {
    return SqliteFlutterMigration(
      fromVersion: fromVersion,
      toVersion: toVersion,
      debugName: debugName,
      run: (tx) async {
        for (final statement in statements) {
          await tx.execute(statement);
        }

        if (afterSql != null) {
          await afterSql(tx);
        }
      },
    );
  }

  /// Creates a convenience migration for the common SQLite rebuild flow.
  factory SqliteFlutterMigration.rebuildTable({
    required int fromVersion,
    required int toVersion,
    required String debugName,
    required String tableName,
    required String createReplacementTableSql,
    required SqliteFlutterRebuildTableRunner copyData,
    String? replacementTableName,
    List<String> beforeSwapStatements = const <String>[],
    List<String> afterSwapStatements = const <String>[],
  }) {
    final nextTableName = replacementTableName ?? '${tableName}__new';
    return SqliteFlutterMigration(
      fromVersion: fromVersion,
      toVersion: toVersion,
      debugName: debugName,
      run: (tx) async {
        await tx.execute(createReplacementTableSql);
        await copyData(tx, tableName, nextTableName);

        for (final statement in beforeSwapStatements) {
          await tx.execute(statement);
        }

        await tx.execute('DROP TABLE $tableName;');
        await tx.execute('ALTER TABLE $nextTableName RENAME TO $tableName;');

        for (final statement in afterSwapStatements) {
          await tx.execute(statement);
        }
      },
    );
  }

  /// Creates a migration step from two SQLite schema snapshots.
  factory SqliteFlutterMigration.schemaDiff({
    required int fromVersion,
    required int toVersion,
    required String debugName,
    required SchemaDocument fromSchema,
    required SchemaDocument toSchema,
    bool allowWarnings = false,
    SqliteFlutterSchemaMigrationPlanner planner =
        const SqliteFlutterSchemaMigrationPlanner(),
  }) {
    final filteredFrom = fromSchema.withoutIgnored();
    final filteredTo = toSchema.withoutIgnored();
    final plan = _mergeRiskWarnings(
      planner.plan(from: filteredFrom, to: filteredTo),
      detectPotentialDataLossWarnings(from: filteredFrom, to: filteredTo),
    );

    if (plan.warnings.isNotEmpty && !allowWarnings) {
      throw StateError(
        'Schema diff migration $debugName contains warnings: ${plan.warnings.join(' | ')}',
      );
    }

    return SqliteFlutterMigration(
      fromVersion: fromVersion,
      toVersion: toVersion,
      debugName: debugName,
      run: (tx) async {
        if (plan.requiresRebuild) {
          await _rebuildDatabase(
            database: tx,
            planner: planner,
            source: filteredFrom,
            target: filteredTo,
          );
          return;
        }

        for (final statement in plan.statements) {
          await tx.execute(statement);
        }
      },
    );
  }

  /// Creates a Dart-coded migration step using the [MigrationSchema] builder.
  ///
  /// This is the recommended way to write most migrations:
  ///
  /// ```dart
  /// SqliteFlutterMigration.schema(
  ///   fromVersion: 0,
  ///   toVersion: 1,
  ///   debugName: 'create_users',
  ///   run: (schema) {
  ///     schema.createTable('users', (table) {
  ///       table.id();
  ///       table.text('email').notNull().unique();
  ///       table.text('name');
  ///       table.boolean('active').notNull().defaultValue(true);
  ///       table.timestamps();
  ///     });
  ///   },
  /// );
  /// ```
  ///
  /// Operations are collected synchronously during [run] and then executed
  /// in order against the migration transaction.
  factory SqliteFlutterMigration.schema({
    required int fromVersion,
    required int toVersion,
    required String debugName,
    required void Function(MigrationSchema schema) run,
  }) {
    return SqliteFlutterMigration(
      fromVersion: fromVersion,
      toVersion: toVersion,
      debugName: debugName,
      run: (tx) async {
        final schema = MigrationSchema();
        run(schema);
        await schema.applyTo(tx);
      },
    );
  }

  /// Source version that this step upgrades from.
  final int fromVersion;

  /// Target version after this step completes.
  final int toVersion;

  /// Debug-friendly migration label.
  final String debugName;

  final SqliteFlutterMigrationRunner _run;

  /// Executes this migration inside an existing transaction.
  Future<void> run(Transaction tx) => _run(tx);

  static SqliteFlutterSchemaMigrationPlan _mergeRiskWarnings(
    SqliteFlutterSchemaMigrationPlan plan,
    List<String> riskWarnings,
  ) {
    return SqliteFlutterSchemaMigrationPlan(
      statements: plan.statements,
      warnings: mergeMigrationWarnings(plan.warnings, riskWarnings),
      requiresRebuild: plan.requiresRebuild,
    );
  }

  static Future<void> _rebuildDatabase({
    required DatabaseExecutor database,
    required SqliteFlutterSchemaMigrationPlanner planner,
    required SchemaDocument source,
    required SchemaDocument target,
  }) async {
    final renamedTables = <String>[];

    for (final model in source.models) {
      final tempName = _tempTableName(model.databaseName);
      await database.execute(
        'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
        'RENAME TO ${_quoteIdentifier(tempName)}',
      );
      renamedTables.add(tempName);
    }

    for (final storage in collectImplicitManyToManyStorages(source)) {
      final tempName = _tempTableName(storage.tableName);
      await database.execute(
        'ALTER TABLE ${_quoteIdentifier(storage.tableName)} '
        'RENAME TO ${_quoteIdentifier(tempName)}',
      );
      renamedTables.add(tempName);
    }

    for (final statement in planner.schemaApplier.createTableStatements(
      target,
    )) {
      await database.execute(statement);
    }
    for (final statement
        in planner.schemaApplier.createImplicitManyToManyTableStatements(
          target,
        )) {
      await database.execute(statement);
    }

    for (final targetModel in target.models) {
      ModelDefinition? sourceModel;
      for (final model in source.models) {
        if (model.databaseName == targetModel.databaseName) {
          sourceModel = model;
          break;
        }
        sourceModel ??= model.name == targetModel.name ? model : sourceModel;
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
          .map((pair) => _quoteIdentifier(pair.$2))
          .join(', ');
      final sourceCols = copyColumns
          .map((pair) => _quoteIdentifier(pair.$1))
          .join(', ');
      await database.execute(
        'INSERT INTO ${_quoteIdentifier(targetModel.databaseName)} ($targetCols) '
        'SELECT $sourceCols FROM ${_quoteIdentifier(_tempTableName(sourceModel.databaseName))}',
      );
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

      await database.execute(
        'INSERT INTO ${_quoteIdentifier(targetStorage.tableName)} '
        '($targetColumns) '
        'SELECT $sourceColumns '
        'FROM ${_quoteIdentifier(_tempTableName(sourceStorage.tableName))}',
      );
    }

    for (final tempName in renamedTables) {
      await database.execute('DROP TABLE ${_quoteIdentifier(tempName)}');
    }
  }

  static List<(String, String)> _copyableColumns({
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

  static String _tempTableName(String modelName) =>
      '__comon_orm_old_$modelName';

  static String _quoteIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }
}
