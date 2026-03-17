import '../client/query_models.dart';

/// Converts high-level query objects into a compact execution plan.
class QueryPlanner {
  /// Creates a stateless planner.
  const QueryPlanner();

  /// Creates a plan for a `findMany` query.
  PlannedOperation planFindMany(FindManyQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.findMany,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      selectedFields:
          query.select?.fields.toList(growable: false) ?? const <String>[],
      includeStrategy: _includeStrategy(query.include),
    );
  }

  /// Creates a plan for a `findUnique` query.
  PlannedOperation planFindUnique(FindUniqueQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.findUnique,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      selectedFields:
          query.select?.fields.toList(growable: false) ?? const <String>[],
    );
  }

  /// Creates a plan for a `findFirst` query.
  PlannedOperation planFindFirst(FindFirstQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.findFirst,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      selectedFields:
          query.select?.fields.toList(growable: false) ?? const <String>[],
      includeStrategy: _includeStrategy(query.include),
    );
  }

  /// Creates a plan for a `create` query.
  PlannedOperation planCreate(CreateQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.create,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      nestedWriteRelations: query.nestedCreates
          .map((write) => write.relation)
          .toList(growable: false),
    );
  }

  /// Creates a plan for a `createMany` query.
  PlannedOperation planCreateMany(CreateManyQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.createMany,
    );
  }

  /// Creates a plan for an `update` query.
  PlannedOperation planUpdate(UpdateQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.update,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      selectedFields:
          query.select?.fields.toList(growable: false) ?? const <String>[],
    );
  }

  /// Creates a plan for an `updateMany` query.
  PlannedOperation planUpdateMany(UpdateManyQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.updateMany,
    );
  }

  /// Creates a plan for an `upsert` query.
  PlannedOperation planUpsert(UpsertQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.upsert,
      includeRelations:
          query.include?.relations.keys.toList(growable: false) ??
          const <String>[],
      selectedFields:
          query.select?.fields.toList(growable: false) ?? const <String>[],
    );
  }

  /// Creates a plan for a `delete` query.
  PlannedOperation planDelete(DeleteQuery query) {
    return PlannedOperation(model: query.model, action: PlannedAction.delete);
  }

  /// Creates a plan for a `deleteMany` query.
  PlannedOperation planDeleteMany(DeleteManyQuery query) {
    return PlannedOperation(
      model: query.model,
      action: PlannedAction.deleteMany,
    );
  }

  /// Returns the preferred include resolution strategy for the given include.
  /// Multi-row operations benefit from [IncludeStrategy.batch]; single-record
  /// operations keep the simpler [IncludeStrategy.perRow] default.
  IncludeStrategy _includeStrategy(QueryInclude? include) {
    if (include == null || include.relations.isEmpty) {
      return IncludeStrategy.perRow;
    }
    return IncludeStrategy.batch;
  }
}

/// Describes the high-level operation an adapter should perform.
enum PlannedAction {
  /// Read many matching records.
  findMany,

  /// Read one record by unique predicate.
  findUnique,

  /// Read the first matching record.
  findFirst,

  /// Create a new record.
  create,

  /// Batch-insert multiple records.
  createMany,

  /// Update a single matching record.
  update,

  /// Update all matching records.
  updateMany,

  /// Create or update a record (upsert).
  upsert,

  /// Delete a single matching record.
  delete,

  /// Delete all matching records.
  deleteMany,
}

/// Strategy an adapter should use to resolve include relations.
enum IncludeStrategy {
  /// Resolve each parent row individually (simple, no batching).
  perRow,

  /// Collect FK values from all parent rows and fire one query per relation
  /// level (eliminates N+1 for multi-row results).
  batch,
}

/// Provider-agnostic execution plan derived from query input.
class PlannedOperation {
  /// Creates a planned operation.
  const PlannedOperation({
    required this.model,
    required this.action,
    this.includeRelations = const <String>[],
    this.selectedFields = const <String>[],
    this.nestedWriteRelations = const <QueryRelation>[],
    this.includeStrategy = IncludeStrategy.perRow,
  });

  /// Model name targeted by the operation.
  final String model;

  /// Operation kind.
  final PlannedAction action;

  /// Relation field names to materialize after the main query.
  final List<String> includeRelations;

  /// Scalar fields to project when a query uses `select`.
  final List<String> selectedFields;

  /// Nested relation writes to execute as part of a create operation.
  final List<QueryRelation> nestedWriteRelations;

  /// Preferred strategy for loading included relations.
  final IncludeStrategy includeStrategy;
}
