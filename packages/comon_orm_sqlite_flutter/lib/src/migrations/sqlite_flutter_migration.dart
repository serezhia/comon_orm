import 'package:sqflite_common/sqlite_api.dart';

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

  /// Source version that this step upgrades from.
  final int fromVersion;

  /// Target version after this step completes.
  final int toVersion;

  /// Debug-friendly migration label.
  final String debugName;

  final SqliteFlutterMigrationRunner _run;

  /// Executes this migration inside an existing transaction.
  Future<void> run(Transaction tx) => _run(tx);
}
