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
}

/// Describes the high-level operation an adapter should perform.
enum PlannedAction {
  /// Read many matching records.
  findMany,

  /// Create a new record.
  create,
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
}
