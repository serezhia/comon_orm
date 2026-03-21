import 'dart:async';

import '../client/query_aggregates.dart';
import '../client/query_models.dart';
import 'database_adapter.dart';

/// Operation kinds that can be intercepted by [DatabaseMiddleware].
enum DatabaseMiddlewareOperation {
  /// Intercepts [DatabaseAdapter.findMany].
  findMany,

  /// Intercepts [DatabaseAdapter.findUnique].
  findUnique,

  /// Intercepts [DatabaseAdapter.findFirst].
  findFirst,

  /// Intercepts [DatabaseAdapter.count].
  count,

  /// Intercepts [DatabaseAdapter.aggregate].
  aggregate,

  /// Intercepts [DatabaseAdapter.groupBy].
  groupBy,

  /// Intercepts [DatabaseAdapter.create].
  create,

  /// Intercepts [DatabaseAdapter.addImplicitManyToManyLink].
  addImplicitManyToManyLink,

  /// Intercepts [DatabaseAdapter.removeImplicitManyToManyLinks].
  removeImplicitManyToManyLinks,

  /// Intercepts [DatabaseAdapter.update].
  update,

  /// Intercepts [DatabaseAdapter.updateMany].
  updateMany,

  /// Intercepts [DatabaseAdapter.delete].
  delete,

  /// Intercepts [DatabaseAdapter.deleteMany].
  deleteMany,

  /// Intercepts [DatabaseAdapter.upsert].
  upsert,

  /// Intercepts [DatabaseAdapter.createMany].
  createMany,

  /// Intercepts [DatabaseAdapter.rawQuery].
  rawQuery,

  /// Intercepts [DatabaseAdapter.rawExecute].
  rawExecute,

  /// Intercepts [DatabaseAdapter.transaction].
  transaction,
}

/// Mutable middleware context passed to [DatabaseMiddleware.beforeQuery].
class DatabaseMiddlewareContext {
  /// Creates a middleware context.
  DatabaseMiddlewareContext({
    required this.operation,
    this.model,
    this.payload,
    this.sql,
    List<Object?> parameters = const <Object?>[],
  }) : _parameters = List<Object?>.from(parameters, growable: true);

  /// Operation being intercepted.
  final DatabaseMiddlewareOperation operation;

  /// Optional model name associated with the operation.
  final String? model;

  /// Query-like payload for adapter operations.
  Object? payload;

  /// Raw SQL text for raw operations, if present.
  String? sql;

  final List<Object?> _parameters;

  /// Returns the payload cast to [T].
  T payloadAs<T>() => payload as T;

  /// Mutable raw parameters for raw operations.
  List<Object?> get parameters => _parameters;
}

/// Result passed to [DatabaseMiddleware.afterQuery].
class DatabaseMiddlewareResult {
  /// Creates a middleware result.
  const DatabaseMiddlewareResult({
    required this.context,
    required this.duration,
    this.result,
    this.error,
    this.stackTrace,
  });

  /// Context used for the intercepted operation.
  final DatabaseMiddlewareContext context;

  /// Time spent executing the wrapped operation.
  final Duration duration;

  /// Operation result when execution succeeded.
  final Object? result;

  /// Error thrown by the operation, if any.
  final Object? error;

  /// Stack trace captured for [error], if any.
  final StackTrace? stackTrace;

  /// Whether the operation completed without throwing.
  bool get isSuccess => error == null;
}

/// Hook surface for observing or mutating adapter operations.
abstract interface class DatabaseMiddleware {
  /// Runs before the wrapped adapter operation executes.
  FutureOr<void> beforeQuery(DatabaseMiddlewareContext context);

  /// Runs after the wrapped adapter operation completes or throws.
  FutureOr<void> afterQuery(DatabaseMiddlewareResult result);
}

/// Decorator that applies [DatabaseMiddleware] to a [DatabaseAdapter].
class MiddlewareDatabaseAdapter implements DatabaseAdapter {
  /// Creates a middleware-decorated adapter.
  const MiddlewareDatabaseAdapter({
    required DatabaseAdapter adapter,
    required List<DatabaseMiddleware> middlewares,
  }) : _adapter = adapter,
       _middlewares = middlewares;

  final DatabaseAdapter _adapter;
  final List<DatabaseMiddleware> _middlewares;

  Future<T> _run<T>({
    required DatabaseMiddlewareContext context,
    required Future<T> Function(DatabaseMiddlewareContext context) execute,
  }) async {
    for (final middleware in _middlewares) {
      await middleware.beforeQuery(context);
    }

    final stopwatch = Stopwatch()..start();
    try {
      final result = await execute(context);
      stopwatch.stop();
      final middlewareResult = DatabaseMiddlewareResult(
        context: context,
        duration: stopwatch.elapsed,
        result: result,
      );
      for (final middleware in _middlewares.reversed) {
        await middleware.afterQuery(middlewareResult);
      }
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      final middlewareResult = DatabaseMiddlewareResult(
        context: context,
        duration: stopwatch.elapsed,
        error: error,
        stackTrace: stackTrace,
      );
      for (final middleware in _middlewares.reversed) {
        await middleware.afterQuery(middlewareResult);
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.findMany,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.findMany(context.payloadAs<FindManyQuery>()),
    );
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.findUnique,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.findUnique(context.payloadAs<FindUniqueQuery>()),
    );
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.findFirst,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.findFirst(context.payloadAs<FindFirstQuery>()),
    );
  }

  @override
  Future<int> count(CountQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.count,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.count(context.payloadAs<CountQuery>()),
    );
  }

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.aggregate,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.aggregate(context.payloadAs<AggregateQuery>()),
    );
  }

  @override
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.groupBy,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.groupBy(context.payloadAs<GroupByQuery>()),
    );
  }

  @override
  Future<Map<String, Object?>> create(CreateQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.create,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.create(context.payloadAs<CreateQuery>()),
    );
  }

  @override
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.addImplicitManyToManyLink,
        model: sourceModel,
        payload: (
          relation: relation,
          sourceKeyValues: sourceKeyValues,
          targetKeyValues: targetKeyValues,
        ),
      ),
      execute: (context) {
        final payload = context
            .payloadAs<
              ({
                QueryRelation relation,
                Map<String, Object?> sourceKeyValues,
                Map<String, Object?> targetKeyValues,
              })
            >();
        return _adapter.addImplicitManyToManyLink(
          sourceModel: sourceModel,
          relation: payload.relation,
          sourceKeyValues: payload.sourceKeyValues,
          targetKeyValues: payload.targetKeyValues,
        );
      },
    );
  }

  @override
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.removeImplicitManyToManyLinks,
        model: sourceModel,
        payload: (
          relation: relation,
          sourceKeyValues: sourceKeyValues,
          targetKeyValues: targetKeyValues,
        ),
      ),
      execute: (context) {
        final payload = context
            .payloadAs<
              ({
                QueryRelation relation,
                Map<String, Object?> sourceKeyValues,
                Map<String, Object?>? targetKeyValues,
              })
            >();
        return _adapter.removeImplicitManyToManyLinks(
          sourceModel: sourceModel,
          relation: payload.relation,
          sourceKeyValues: payload.sourceKeyValues,
          targetKeyValues: payload.targetKeyValues,
        );
      },
    );
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.update,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.update(context.payloadAs<UpdateQuery>()),
    );
  }

  @override
  Future<int> updateMany(UpdateManyQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.updateMany,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.updateMany(context.payloadAs<UpdateManyQuery>()),
    );
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.delete,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.delete(context.payloadAs<DeleteQuery>()),
    );
  }

  @override
  Future<int> deleteMany(DeleteManyQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.deleteMany,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.deleteMany(context.payloadAs<DeleteManyQuery>()),
    );
  }

  @override
  Future<Map<String, Object?>> upsert(UpsertQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.upsert,
        model: query.model,
        payload: query,
      ),
      execute: (context) => _adapter.upsert(context.payloadAs<UpsertQuery>()),
    );
  }

  @override
  Future<int> createMany(CreateManyQuery query) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.createMany,
        model: query.model,
        payload: query,
      ),
      execute: (context) =>
          _adapter.createMany(context.payloadAs<CreateManyQuery>()),
    );
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.rawQuery,
        sql: sql,
        parameters: parameters,
      ),
      execute: (context) => _adapter.rawQuery(
        context.sql!,
        List<Object?>.unmodifiable(context.parameters),
      ),
    );
  }

  @override
  Future<int> rawExecute(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.rawExecute,
        sql: sql,
        parameters: parameters,
      ),
      execute: (context) => _adapter.rawExecute(
        context.sql!,
        List<Object?>.unmodifiable(context.parameters),
      ),
    );
  }

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action) {
    return _run(
      context: DatabaseMiddlewareContext(
        operation: DatabaseMiddlewareOperation.transaction,
      ),
      execute: (_) => _adapter.transaction(
        (tx) => action(
          MiddlewareDatabaseAdapter(adapter: tx, middlewares: _middlewares),
        ),
      ),
    );
  }

  @override
  FutureOr<void> close() => _adapter.close();
}
