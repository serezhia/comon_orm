import '../engine/database_adapter.dart';
import 'query_aggregates.dart';
import 'query_models.dart';

/// Entry point for ad-hoc access to models through a [DatabaseAdapter].
///
/// Generated clients wrap this class, but it can also be used directly in tests
/// or low-level integrations.
class ComonOrmClient {
  /// Creates a client backed by [adapter].
  ComonOrmClient({required DatabaseAdapter adapter}) : _adapter = adapter;

  final DatabaseAdapter _adapter;

  /// Returns a delegate that enforces [name] for every query issued through it.
  ModelDelegate model(String name) => ModelDelegate._(_adapter, name);

  /// Runs [action] inside an adapter-managed transaction.
  Future<T> transaction<T>(Future<T> Function(ComonOrmClient tx) action) {
    return _adapter.transaction(
      (txAdapter) => action(ComonOrmClient(adapter: txAdapter)),
    );
  }
}

/// Binds model-scoped query objects to a concrete model name.
class ModelDelegate {
  ModelDelegate._(this._adapter, this._model);

  final DatabaseAdapter _adapter;
  final String _model;

  /// Returns all records that match [query].
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.findMany(query);
  }

  /// Returns the single matching record for [query], if any.
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.findUnique(query);
  }

  /// Returns the first matching record for [query], if any.
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.findFirst(query);
  }

  /// Counts records that match [query].
  Future<int> count(CountQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.count(query);
  }

  /// Computes aggregate values for [query].
  Future<AggregateQueryResult> aggregate(AggregateQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.aggregate(query);
  }

  /// Groups records according to [query] and returns aggregate rows.
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.groupBy(query);
  }

  /// Creates a single record described by [query].
  Future<Map<String, Object?>> create(CreateQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.create(query);
  }

  /// Updates a single record described by [query].
  Future<Map<String, Object?>> update(UpdateQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.update(query);
  }

  /// Updates every record matched by [query] and returns the number changed.
  Future<int> updateMany(UpdateManyQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.updateMany(query);
  }

  /// Deletes a single record described by [query].
  Future<Map<String, Object?>> delete(DeleteQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.delete(query);
  }

  /// Deletes every record matched by [query] and returns the number removed.
  Future<int> deleteMany(DeleteManyQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.deleteMany(query);
  }
}
