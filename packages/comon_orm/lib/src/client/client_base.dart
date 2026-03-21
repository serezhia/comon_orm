import '../engine/database_adapter.dart';
import '../engine/query_planner.dart';
import '../runtime_metadata/runtime_schema_view.dart';
import 'query_aggregates.dart';
import 'query_models.dart';

/// Entry point for ad-hoc access to models through a [DatabaseAdapter].
///
/// Generated clients wrap this class, but it can also be used directly in tests
/// or low-level integrations.
class ComonOrmClient {
  /// Creates a client backed by [adapter].
  ///
  /// When [schemaView] is provided it is forwarded to every [ModelDelegate]
  /// returned by [model] so unknown field names in predicates are caught
  /// before a query reaches the database.
  ComonOrmClient({
    required DatabaseAdapter adapter,
    RuntimeSchemaView? schemaView,
  }) : _adapter = adapter,
       _schemaView = schemaView {
    if (adapter is InMemoryDatabaseAdapter && schemaView != null) {
      adapter.bindRuntimeSchema(schemaView);
    }
  }

  final DatabaseAdapter _adapter;
  final RuntimeSchemaView? _schemaView;

  /// Returns a delegate that enforces [name] for every query issued through it.
  ModelDelegate model(String name) =>
      ModelDelegate._(_adapter, name, _schemaView);

  /// Runs [action] inside an adapter-managed transaction.
  Future<T> transaction<T>(Future<T> Function(ComonOrmClient tx) action) {
    return _adapter.transaction(
      (txAdapter) =>
          action(ComonOrmClient(adapter: txAdapter, schemaView: _schemaView)),
    );
  }

  /// Releases resources owned by the underlying adapter.
  Future<void> close() async {
    await _adapter.close();
  }
}

/// Binds model-scoped query objects to a concrete model name.
class ModelDelegate {
  ModelDelegate._(this._adapter, this._model, [this._schemaView]);

  static const QueryPlanner _planner = QueryPlanner();

  final DatabaseAdapter _adapter;
  final String _model;
  final RuntimeSchemaView? _schemaView;

  /// Throws [ArgumentError] if any predicate references a field that is not
  /// declared on [_model] in [_schemaView].  When no schema view is available
  /// the check is skipped so callers that omit the view are unaffected.
  void _validatePredicateFields(List<QueryPredicate> predicates) {
    final modelView = _schemaView?.findModel(_model);
    if (modelView == null) return;
    for (final predicate in predicates) {
      // Logical combinators (AND/OR/NOT) are not model fields — skip them.
      if (predicate.operator.startsWith('logical')) continue;
      if (modelView.findField(predicate.field) == null) {
        throw ArgumentError.value(
          predicate.field,
          'predicate.field',
          'Unknown field "${predicate.field}" on model "$_model".',
        );
      }
    }
  }

  /// Runs [action] inside an adapter-managed transaction bound to this model.
  Future<T> transaction<T>(Future<T> Function(ModelDelegate tx) action) {
    return _adapter.transaction(
      (txAdapter) => action(ModelDelegate._(txAdapter, _model, _schemaView)),
    );
  }

  /// Returns all records that match [query].
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }
    _validatePredicateFields(query.where);
    _validatePredicateFields(query.cursor?.where ?? const []);

    final planned = _planner.planFindMany(query);
    return _adapter.findMany(
      query.copyWithIncludeStrategy(planned.includeStrategy),
    );
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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);
    _validatePredicateFields(query.cursor?.where ?? const []);

    final planned = _planner.planFindFirst(query);
    return _adapter.findFirst(
      query.copyWithIncludeStrategy(planned.includeStrategy),
    );
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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);

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

  /// Adds an implicit many-to-many relation link for this model.
  Future<void> addImplicitManyToManyLink({
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) {
    if (relation.storageKind != QueryRelationStorageKind.implicitManyToMany) {
      throw ArgumentError.value(
        relation.storageKind,
        'relation.storageKind',
        'Relation storage kind must be implicitManyToMany.',
      );
    }

    return _adapter.addImplicitManyToManyLink(
      sourceModel: _model,
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  /// Removes implicit many-to-many relation links for this model.
  Future<int> removeImplicitManyToManyLinks({
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) {
    if (relation.storageKind != QueryRelationStorageKind.implicitManyToMany) {
      throw ArgumentError.value(
        relation.storageKind,
        'relation.storageKind',
        'Relation storage kind must be implicitManyToMany.',
      );
    }

    return _adapter.removeImplicitManyToManyLinks(
      sourceModel: _model,
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);

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
    _validatePredicateFields(query.where);

    return _adapter.deleteMany(query);
  }

  /// Creates or updates a single record described by [query].
  Future<Map<String, Object?>> upsert(UpsertQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }
    _validatePredicateFields(query.where);

    return _adapter.upsert(query);
  }

  /// Inserts multiple records described by [query].
  Future<int> createMany(CreateManyQuery query) {
    if (query.model != _model) {
      throw ArgumentError.value(
        query.model,
        'query.model',
        'Query model does not match delegate model.',
      );
    }

    return _adapter.createMany(query);
  }
}
