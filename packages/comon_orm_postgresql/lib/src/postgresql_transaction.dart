import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

/// Query execution surface used by the PostgreSQL adapter runtime.
abstract interface class PostgresqlQueryExecutor {
  /// Runs a query and returns rows as string-keyed maps.
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  });

  /// Runs a statement and returns the affected row count.
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  });

  /// Runs [action] inside a PostgreSQL transaction.
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  );

  /// Releases any resources owned by the executor.
  Future<void> close();
}

/// Coordinates adapter transactions through a PostgreSQL query executor.
class PostgresqlTransactionManager {
  /// Creates a transaction manager for the given executor.
  const PostgresqlTransactionManager(this._executor);

  final PostgresqlQueryExecutor _executor;

  /// Runs [action] inside a PostgreSQL transaction-backed adapter.
  Future<T> run<T>(
    Future<T> Function(DatabaseAdapter tx) action,
    DatabaseAdapter Function(PostgresqlQueryExecutor tx) createAdapter,
  ) {
    return _executor.transaction((tx) => action(createAdapter(tx)));
  }
}

/// `PostgresqlQueryExecutor` backed by a single `package:postgres` session.
class PostgresqlSessionQueryExecutor implements PostgresqlQueryExecutor {
  /// Creates a session-backed PostgreSQL query executor.
  const PostgresqlSessionQueryExecutor(this._session);

  final pg.Session _session;

  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    final result = await _session.execute(
      sql,
      parameters: parameters,
      ignoreRows: true,
    );
    return result.affectedRows;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    final result = await _session.execute(sql, parameters: parameters);
    return result
        .map((row) => Map<String, Object?>.from(row.toColumnMap()))
        .toList(growable: false);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) async {
    return action(this);
  }
}
