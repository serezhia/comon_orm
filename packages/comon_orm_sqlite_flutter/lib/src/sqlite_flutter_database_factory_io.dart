import 'dart:io';

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Creates the default SQLite database factory for Flutter VM targets.
Future<DatabaseFactory> createPlatformSqliteFlutterDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }

  return sqflite.databaseFactory;
}
