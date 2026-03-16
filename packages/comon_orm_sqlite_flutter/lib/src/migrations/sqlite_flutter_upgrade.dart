import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_flutter_migrator.dart';

/// Explicit local upgrade helper for pre-runtime SQLite migrations.
Future<void> upgradeSqliteFlutterDatabase({
  required String databasePath,
  required SqliteFlutterMigrator migrator,
  DatabaseFactory? databaseFactory,
  OpenDatabaseOptions? options,
}) {
  return migrator.upgradeDatabasePath(
    databasePath: databasePath,
    databaseFactory: databaseFactory,
    options: options,
  );
}
