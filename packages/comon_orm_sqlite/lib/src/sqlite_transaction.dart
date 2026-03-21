import 'package:comon_orm/comon_orm.dart';

/// Coordinates SQLite transactions and nested savepoints for one adapter.
class SqliteTransactionManager {
  /// Creates a transaction manager backed by raw SQL execution callbacks.
  SqliteTransactionManager({
    required this.executeSql,
    required this.quoteIdentifier,
  });

  /// Executes a raw SQLite statement.
  final void Function(String sql) executeSql;

  /// Quotes an SQLite identifier such as a savepoint name.
  final String Function(String identifier) quoteIdentifier;

  int _transactionDepth = 0;
  int _savepointCounter = 0;

  /// Runs [action] inside a transaction or nested savepoint.
  Future<T> run<T>(
    Future<T> Function(DatabaseAdapter tx) action,
    DatabaseAdapter adapter,
  ) async {
    final isRootTransaction = _transactionDepth == 0;
    final savepointName = 'sp_${_savepointCounter++}';

    if (isRootTransaction) {
      executeSql('BEGIN');
    } else {
      executeSql('SAVEPOINT ${quoteIdentifier(savepointName)}');
    }

    _transactionDepth++;
    try {
      final result = await action(adapter);
      if (isRootTransaction) {
        executeSql('COMMIT');
      } else {
        executeSql('RELEASE SAVEPOINT ${quoteIdentifier(savepointName)}');
      }
      return result;
    } catch (_) {
      if (isRootTransaction) {
        executeSql('ROLLBACK');
      } else {
        executeSql('ROLLBACK TO SAVEPOINT ${quoteIdentifier(savepointName)}');
        executeSql('RELEASE SAVEPOINT ${quoteIdentifier(savepointName)}');
      }
      rethrow;
    } finally {
      _transactionDepth--;
    }
  }
}
