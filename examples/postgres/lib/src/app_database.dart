import 'dart:io';

import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  PostgresqlDatabaseAdapter? _adapter;
  GeneratedComonOrmClient? _client;
  Future<GeneratedComonOrmClient>? _initializing;

  Future<GeneratedComonOrmClient> client() {
    final existing = _client;
    if (existing != null) {
      return Future<GeneratedComonOrmClient>.value(existing);
    }
    final initializing = _initializing;
    if (initializing != null) {
      return initializing;
    }

    final future = _initialize();
    _initializing = future;
    return future;
  }

  Future<GeneratedComonOrmClient> _initialize() async {
    try {
      final adapter = _shouldAutoApplySchema()
          ? await PostgresqlDatabaseAdapter.openAndApplyFromSchemaPath(
              schemaPath: 'schema.prisma',
            )
          : await PostgresqlDatabaseAdapter.openFromSchemaPath(
              schemaPath: 'schema.prisma',
            );
      _adapter = adapter;
      final client = GeneratedComonOrmClient(adapter: adapter);
      _client = client;
      return client;
    } finally {
      _initializing = null;
    }
  }

  Future<void> close() async {
    final adapter = _adapter;
    _adapter = null;
    _client = null;
    _initializing = null;
    if (adapter != null) {
      await adapter.close();
    }
  }

  bool _shouldAutoApplySchema() {
    final raw = Platform.environment['AUTO_APPLY_SCHEMA'];
    if (raw == null) {
      return true;
    }
    return raw.toLowerCase() != 'false';
  }
}
