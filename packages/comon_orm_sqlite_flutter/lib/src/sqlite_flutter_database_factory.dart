import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_flutter_database_factory_io.dart'
    if (dart.library.js_interop) 'sqlite_flutter_database_factory_web.dart';

/// Loads the default database factory for the current platform.
typedef SqliteFlutterDatabaseFactoryLoader = Future<DatabaseFactory> Function();

/// Creates the default SQLite database factory for the active Flutter target.
Future<DatabaseFactory> createDefaultSqliteFlutterDatabaseFactory() {
  return createPlatformSqliteFlutterDatabaseFactory();
}
