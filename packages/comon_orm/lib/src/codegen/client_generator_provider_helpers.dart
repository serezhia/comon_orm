part of 'client_generator.dart';

extension on ClientGenerator {
  void _writeProviderHelpers(
    StringBuffer buffer,
    Set<String> datasourceProviders, {
    required SqliteClientHelperKind sqliteHelperKind,
  }) {
    if (datasourceProviders.contains('sqlite')) {
      if (sqliteHelperKind == SqliteClientHelperKind.flutter) {
        _writeFlutterSqliteProviderHelper(buffer);
      } else {
        _writeVmSqliteProviderHelper(buffer);
      }
    }

    if (datasourceProviders.contains('postgresql')) {
      _writePostgresqlProviderHelper(buffer);
    }
  }

  void _writeFlutterSqliteProviderHelper(StringBuffer buffer) {
    buffer
      ..writeln('class GeneratedComonOrmClientFlutterSqlite {')
      ..writeln('  const GeneratedComonOrmClientFlutterSqlite._();')
      ..writeln()
      ..writeln('  static Future<GeneratedComonOrmClient> open({')
      ..writeln('    String? databasePath,')
      ..writeln('    String? datasourceName,')
      ..writeln('    DatabaseFactory? databaseFactory,')
      ..writeln('    SqliteFlutterRuntimeAdapterFactory? adapterFactory,')
      ..writeln('  }) async {')
      ..writeln(
        '    final adapter = await SqliteFlutterDatabaseAdapter.openFromGeneratedSchema(',
      )
      ..writeln('      schema: GeneratedComonOrmClient.runtimeSchema,')
      ..writeln('      databasePath: databasePath,')
      ..writeln('      datasourceName: datasourceName,')
      ..writeln('      databaseFactory: databaseFactory,')
      ..writeln('      adapterFactory: adapterFactory,')
      ..writeln('    );')
      ..writeln('    return GeneratedComonOrmClient(adapter: adapter);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeVmSqliteProviderHelper(StringBuffer buffer) {
    buffer
      ..writeln('class GeneratedComonOrmClientSqlite {')
      ..writeln('  const GeneratedComonOrmClientSqlite._();')
      ..writeln()
      ..writeln('  static Future<GeneratedComonOrmClient> open({')
      ..writeln('    String? databasePath,')
      ..writeln('    String? datasourceName,')
      ..writeln(
        '    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),',
      )
      ..writeln('    SqliteRuntimeAdapterFactory? adapterFactory,')
      ..writeln('  }) async {')
      ..writeln(
        '    final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(',
      )
      ..writeln('      schema: GeneratedComonOrmClient.runtimeSchema,')
      ..writeln('      databasePath: databasePath,')
      ..writeln('      datasourceName: datasourceName,')
      ..writeln('      resolver: resolver,')
      ..writeln('      adapterFactory: adapterFactory,')
      ..writeln('    );')
      ..writeln('    return GeneratedComonOrmClient(adapter: adapter);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writePostgresqlProviderHelper(StringBuffer buffer) {
    buffer
      ..writeln('class GeneratedComonOrmClientPostgresql {')
      ..writeln('  const GeneratedComonOrmClientPostgresql._();')
      ..writeln()
      ..writeln('  static Future<GeneratedComonOrmClient> open({')
      ..writeln('    String? connectionUrl,')
      ..writeln('    String? datasourceName,')
      ..writeln(
        '    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),',
      )
      ..writeln('    PostgresqlRuntimeAdapterFactory? adapterFactory,')
      ..writeln('  }) async {')
      ..writeln(
        '    final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(',
      )
      ..writeln('      schema: GeneratedComonOrmClient.runtimeSchema,')
      ..writeln('      connectionUrl: connectionUrl,')
      ..writeln('      datasourceName: datasourceName,')
      ..writeln('      resolver: resolver,')
      ..writeln('      adapterFactory: adapterFactory,')
      ..writeln('    );')
      ..writeln('    return GeneratedComonOrmClient(adapter: adapter);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }
}
