import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

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
      final client = await GeneratedComonOrmClientPostgresql.open();
      _client = client;
      return client;
    } finally {
      _initializing = null;
    }
  }

  Future<void> close() async {
    final client = _client;
    _client = null;
    _initializing = null;
    if (client != null) {
      await client.close();
    }
  }
}
