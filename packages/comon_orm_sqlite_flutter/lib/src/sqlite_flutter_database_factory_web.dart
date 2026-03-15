import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Creates the default SQLite database factory for Flutter web targets.
Future<DatabaseFactory> createPlatformSqliteFlutterDatabaseFactory() async {
  return databaseFactoryFfiWeb;
}
