import 'package:sqflite_common/sqlite_api.dart';

import '../sqlite_flutter_database_factory.dart';
import 'sqlite_flutter_migration.dart';

/// Explicit runner for app-side local SQLite upgrades.
class SqliteFlutterMigrator {
  /// Creates a migration runner for ordered local upgrade steps.
  SqliteFlutterMigrator({
    required this.currentVersion,
    required List<SqliteFlutterMigration> migrations,
    SqliteFlutterDatabaseFactoryLoader? databaseFactoryLoader,
  }) : _databaseFactoryLoader =
           databaseFactoryLoader ?? createDefaultSqliteFlutterDatabaseFactory,
       _migrationsByStartVersion = {
         for (final migration in migrations) migration.fromVersion: migration,
       } {
    _validateMigrations(migrations);
  }

  /// Current local schema version expected by the application.
  final int currentVersion;

  final SqliteFlutterDatabaseFactoryLoader _databaseFactoryLoader;
  final Map<int, SqliteFlutterMigration> _migrationsByStartVersion;

  /// Returns the ordered migration list known to this migrator.
  List<SqliteFlutterMigration> get migrations {
    final ordered = _migrationsByStartVersion.values.toList()
      ..sort((left, right) => left.fromVersion.compareTo(right.fromVersion));
    return ordered;
  }

  /// Reads the current SQLite `PRAGMA user_version` value.
  Future<int> readVersion(DatabaseExecutor database) async {
    final rows = await database.rawQuery('PRAGMA user_version;');
    if (rows.isEmpty) {
      return 0;
    }

    final value = rows.first.values.first;
    if (value is int) {
      return value;
    }

    return int.parse(value.toString());
  }

  /// Returns true when the database version is behind the app version.
  Future<bool> needsUpgrade(DatabaseExecutor database) async {
    return (await readVersion(database)) < currentVersion;
  }

  /// Returns the ordered migration steps that would run from [version].
  List<SqliteFlutterMigration> pendingMigrationsFrom(int version) {
    final pending = <SqliteFlutterMigration>[];
    var current = version;

    while (current < currentVersion) {
      final migration = _migrationsByStartVersion[current];
      if (migration == null) {
        throw StateError('Missing migration for version $current.');
      }
      pending.add(migration);
      current = migration.toVersion;
    }

    return pending;
  }

  /// Upgrades an already-open database if its local version is behind.
  Future<void> upgradeDatabase(Database database) async {
    final userVersion = await readVersion(database);

    if (userVersion > currentVersion) {
      throw StateError(
        'Local database version $userVersion is newer than app version '
        '$currentVersion.',
      );
    }

    if (userVersion == currentVersion) {
      return;
    }

    await database.transaction((tx) async {
      var version = userVersion;
      while (version < currentVersion) {
        final migration = _migrationsByStartVersion[version];
        if (migration == null) {
          throw StateError('Missing migration for version $version.');
        }

        await migration.run(tx);
        await _setUserVersion(tx, migration.toVersion);
        version = migration.toVersion;
      }
    });
  }

  /// Opens a database by path, runs local upgrades, and closes it again.
  Future<void> upgradeDatabasePath({
    required String databasePath,
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final factory = databaseFactory ?? await _databaseFactoryLoader();
    final database = await factory.openDatabase(databasePath, options: options);

    try {
      await upgradeDatabase(database);
    } finally {
      await database.close();
    }
  }

  Future<void> _setUserVersion(DatabaseExecutor database, int version) {
    return database.execute('PRAGMA user_version = $version;');
  }

  void _validateMigrations(List<SqliteFlutterMigration> migrations) {
    if (currentVersion < 0) {
      throw StateError('currentVersion must be non-negative.');
    }

    final seenStartVersions = <int>{};
    for (final migration in migrations) {
      if (!seenStartVersions.add(migration.fromVersion)) {
        throw StateError(
          'Duplicate migration starting at version ${migration.fromVersion}.',
        );
      }

      if (migration.fromVersion < 0) {
        throw StateError(
          'Migration ${migration.debugName} has a negative fromVersion.',
        );
      }

      if (migration.toVersion <= migration.fromVersion) {
        throw StateError(
          'Migration ${migration.debugName} has invalid version step '
          '${migration.fromVersion} -> ${migration.toVersion}.',
        );
      }
    }

    final reachableVersionChain = <int>{0};
    for (final migration in this.migrations) {
      if (!reachableVersionChain.contains(migration.fromVersion) &&
          migration.fromVersion != currentVersion) {
        continue;
      }
      reachableVersionChain.add(migration.toVersion);
    }
  }
}
