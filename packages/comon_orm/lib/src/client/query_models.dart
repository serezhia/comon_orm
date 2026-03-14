import 'package:meta/meta.dart';

/// Case-sensitivity mode for string filter predicates.
enum QueryStringMode {
  /// Case-sensitive matching (default).
  sensitive,

  /// Case-insensitive matching (ILIKE in PostgreSQL, LOWER() in SQLite).
  insensitive,
}

@immutable
/// String field predicates used in generated and manual query inputs.
class StringFilter {
  /// Creates a string filter.
  const StringFilter({
    this.equals,
    this.contains,
    this.startsWith,
    this.endsWith,
    this.inList,
    this.notInList,
    this.not,
    this.mode = QueryStringMode.sensitive,
  });

  /// Exact string match.
  final String? equals;

  /// Substring match.
  final String? contains;

  /// Prefix match.
  final String? startsWith;

  /// Suffix match.
  final String? endsWith;

  /// Membership test.
  final List<String>? inList;

  /// Negated membership test.
  final List<String>? notInList;

  /// Negated exact match.
  final String? not;

  /// Case-sensitivity mode for pattern predicates.
  final QueryStringMode mode;

  /// Expands this filter into backend-neutral predicates for [field].
  List<QueryPredicate> toPredicates(String field) {
    final predicates = <QueryPredicate>[];
    if (equals != null) {
      predicates.add(
        QueryPredicate(field: field, operator: 'equals', value: equals),
      );
    }
    if (contains != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: mode == QueryStringMode.insensitive
              ? 'containsInsensitive'
              : 'contains',
          value: contains,
        ),
      );
    }
    if (startsWith != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: mode == QueryStringMode.insensitive
              ? 'startsWithInsensitive'
              : 'startsWith',
          value: startsWith,
        ),
      );
    }
    if (endsWith != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: mode == QueryStringMode.insensitive
              ? 'endsWithInsensitive'
              : 'endsWith',
          value: endsWith,
        ),
      );
    }
    if (inList != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: 'in',
          value: List<String>.unmodifiable(inList!),
        ),
      );
    }
    if (notInList != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: 'notIn',
          value: List<String>.unmodifiable(notInList!),
        ),
      );
    }
    if (not != null) {
      predicates.add(QueryPredicate(field: field, operator: 'not', value: not));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

@immutable
/// Integer field predicates used in generated and manual query inputs.
class IntFilter {
  /// Creates an integer filter.
  const IntFilter({
    this.equals,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.inList,
    this.notInList,
    this.not,
  });

  /// Exact integer match.
  final int? equals;

  /// Strictly greater-than match.
  final int? gt;

  /// Greater-than-or-equal match.
  final int? gte;

  /// Strictly less-than match.
  final int? lt;

  /// Less-than-or-equal match.
  final int? lte;

  /// Membership test.
  final List<int>? inList;

  /// Negated membership test.
  final List<int>? notInList;

  /// Negated exact match.
  final int? not;

  /// Expands this filter into backend-neutral predicates for [field].
  List<QueryPredicate> toPredicates(String field) {
    final predicates = <QueryPredicate>[];
    if (equals != null) {
      predicates.add(
        QueryPredicate(field: field, operator: 'equals', value: equals),
      );
    }
    if (gt != null) {
      predicates.add(QueryPredicate(field: field, operator: 'gt', value: gt));
    }
    if (gte != null) {
      predicates.add(QueryPredicate(field: field, operator: 'gte', value: gte));
    }
    if (lt != null) {
      predicates.add(QueryPredicate(field: field, operator: 'lt', value: lt));
    }
    if (lte != null) {
      predicates.add(QueryPredicate(field: field, operator: 'lte', value: lte));
    }
    if (inList != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: 'in',
          value: List<int>.unmodifiable(inList!),
        ),
      );
    }
    if (notInList != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: 'notIn',
          value: List<int>.unmodifiable(notInList!),
        ),
      );
    }
    if (not != null) {
      predicates.add(QueryPredicate(field: field, operator: 'not', value: not));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

@immutable
/// Boolean field predicates used in generated and manual query inputs.
class BoolFilter {
  /// Creates a boolean filter.
  const BoolFilter({this.equals, this.not});

  /// Exact boolean match.
  final bool? equals;

  /// Negated exact match.
  final bool? not;

  /// Expands this filter into backend-neutral predicates for [field].
  List<QueryPredicate> toPredicates(String field) {
    final predicates = <QueryPredicate>[];
    if (equals != null) {
      predicates.add(
        QueryPredicate(field: field, operator: 'equals', value: equals),
      );
    }
    if (not != null) {
      predicates.add(QueryPredicate(field: field, operator: 'not', value: not));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

/// Sort direction used in `orderBy` clauses.
enum SortOrder {
  /// Ascending order.
  asc,

  /// Descending order.
  desc,
}

@immutable
/// Single field ordering entry.
class QueryOrderBy {
  /// Creates an ordering entry.
  const QueryOrderBy({required this.field, required this.direction});

  /// Field name to sort by.
  final String field;

  /// Sort direction.
  final SortOrder direction;
}

/// Cardinality of a relation from the source model point of view.
enum QueryRelationCardinality {
  /// Exactly one related record.
  one,

  /// Zero or more related records.
  many,
}

/// Physical storage strategy used by a relation.
enum QueryRelationStorageKind {
  /// Relation is stored directly on one side through foreign keys.
  direct,

  /// Relation is stored in an implicit join table.
  implicitManyToMany,
}

@immutable
/// Relation metadata used for includes, filters, and nested writes.
class QueryRelation {
  /// Creates relation metadata.
  const QueryRelation({
    required this.field,
    required this.targetModel,
    required this.cardinality,
    required this.localKeyField,
    required this.targetKeyField,
    List<String> localKeyFields = const <String>[],
    List<String> targetKeyFields = const <String>[],
    this.storageKind = QueryRelationStorageKind.direct,
    this.sourceModel,
    this.inverseField,
  }) : _localKeyFields = localKeyFields,
       _targetKeyFields = targetKeyFields;

  /// Source model relation field name.
  final String field;

  /// Target model name.
  final String targetModel;

  /// Relation cardinality.
  final QueryRelationCardinality cardinality;

  /// Source-side key field used to join records.
  final String localKeyField;

  /// Source-side key fields used to join records.
  final List<String> _localKeyFields;

  /// Source-side key fields used to join records.
  List<String> get localKeyFields => _localKeyFields.isEmpty
      ? <String>[localKeyField]
      : List<String>.unmodifiable(_localKeyFields);

  /// Target-side key field used to join records.
  final String targetKeyField;

  /// Target-side key fields used to join records.
  final List<String> _targetKeyFields;

  /// Target-side key fields used to join records.
  List<String> get targetKeyFields => _targetKeyFields.isEmpty
      ? <String>[targetKeyField]
      : List<String>.unmodifiable(_targetKeyFields);

  /// Storage strategy for the relation.
  final QueryRelationStorageKind storageKind;

  /// Optional source model name when the relation is materialized externally.
  final String? sourceModel;

  /// Optional inverse relation field on the target model.
  final String? inverseField;
}

@immutable
/// Relation-scoped predicates used by nested filters.
class QueryRelationFilter {
  /// Creates a relation filter.
  const QueryRelationFilter({required this.relation, required this.predicates});

  /// Relation metadata to filter through.
  final QueryRelation relation;

  /// Predicates applied to the related records.
  final List<QueryPredicate> predicates;
}

@immutable
/// Logical OR group represented as branches of predicates.
class QueryLogicalGroup {
  /// Creates a logical predicate group.
  const QueryLogicalGroup({required this.branches});

  /// Predicate branches evaluated as alternatives.
  final List<List<QueryPredicate>> branches;
}

@immutable
/// Single entry inside an include tree.
class QueryIncludeEntry {
  /// Creates an include entry.
  const QueryIncludeEntry({required this.relation, this.include, this.select});

  /// Relation being included.
  final QueryRelation relation;

  /// Nested relation includes.
  final QueryInclude? include;

  /// Scalar field projection applied to the related model.
  final QuerySelect? select;
}

@immutable
/// Backend-neutral predicate used by adapters.
class QueryPredicate {
  /// Creates a query predicate.
  const QueryPredicate({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// Field name the predicate applies to.
  final String field;

  /// Operator understood by the target adapter.
  final String operator;

  /// Operand value for the predicate.
  final Object? value;
}

@immutable
/// Include tree for eager-loading relations.
class QueryInclude {
  /// Creates an include tree.
  const QueryInclude(this.relations);

  /// Relation includes keyed by relation field name.
  final Map<String, QueryIncludeEntry> relations;
}

@immutable
/// Scalar field projection.
class QuerySelect {
  /// Creates a field projection.
  const QuerySelect(this.fields);

  /// Selected scalar field names.
  final Set<String> fields;
}

@immutable
/// Query object for fetching multiple records.
class FindManyQuery {
  /// Creates a `findMany` query.
  const FindManyQuery({
    required this.model,
    this.where = const <QueryPredicate>[],
    this.orderBy = const <QueryOrderBy>[],
    this.distinct = const <String>{},
    this.include,
    this.select,
    this.skip,
    this.take,
  });

  /// Model name to query.
  final String model;

  /// Predicates combined by the adapter.
  final List<QueryPredicate> where;

  /// Ordering clauses.
  final List<QueryOrderBy> orderBy;

  /// Scalar fields used to de-duplicate matching rows before pagination.
  final Set<String> distinct;

  /// Relations to include in the result.
  final QueryInclude? include;

  /// Scalar fields to project.
  final QuerySelect? select;

  /// Number of matching rows to skip.
  final int? skip;

  /// Maximum number of rows to return.
  final int? take;
}

@immutable
/// Query object for fetching a unique record.
class FindUniqueQuery {
  /// Creates a `findUnique` query.
  const FindUniqueQuery({
    required this.model,
    this.where = const <QueryPredicate>[],
    this.include,
    this.select,
  });

  /// Model name to query.
  final String model;

  /// Predicates expected to identify a single row.
  final List<QueryPredicate> where;

  /// Relations to include in the result.
  final QueryInclude? include;

  /// Scalar fields to project.
  final QuerySelect? select;
}

@immutable
/// Query object for fetching the first matching record.
class FindFirstQuery {
  /// Creates a `findFirst` query.
  const FindFirstQuery({
    required this.model,
    this.where = const <QueryPredicate>[],
    this.orderBy = const <QueryOrderBy>[],
    this.include,
    this.select,
    this.skip,
  });

  /// Model name to query.
  final String model;

  /// Predicates combined by the adapter.
  final List<QueryPredicate> where;

  /// Ordering clauses used before selecting the first record.
  final List<QueryOrderBy> orderBy;

  /// Relations to include in the result.
  final QueryInclude? include;

  /// Scalar fields to project.
  final QuerySelect? select;

  /// Number of matches to skip before taking the first row.
  final int? skip;
}

@immutable
/// Query object for counting records.
class CountQuery {
  /// Creates a `count` query.
  const CountQuery({
    required this.model,
    this.where = const <QueryPredicate>[],
  });

  /// Model name to query.
  final String model;

  /// Predicates used to restrict the count.
  final List<QueryPredicate> where;
}

@immutable
/// Nested create payload for a single relation.
class CreateRelationWrite {
  /// Creates a nested relation write.
  const CreateRelationWrite({required this.relation, required this.records});

  /// Relation metadata describing where nested records should be written.
  final QueryRelation relation;

  /// Raw records to create on the related model.
  final List<Map<String, Object?>> records;
}

@immutable
/// Query object for creating a single record.
class CreateQuery {
  /// Creates a `create` query.
  const CreateQuery({
    required this.model,
    required this.data,
    this.include,
    this.nestedCreates = const <CreateRelationWrite>[],
  });

  /// Model name to write to.
  final String model;

  /// Scalar data assigned to the new record.
  final Map<String, Object?> data;

  /// Relations to materialize in the returned payload.
  final QueryInclude? include;

  /// Nested relation writes executed as part of the create.
  final List<CreateRelationWrite> nestedCreates;
}

@immutable
/// Query object for updating a single record.
class UpdateQuery {
  /// Creates an `update` query.
  const UpdateQuery({
    required this.model,
    required this.where,
    required this.data,
    this.include,
    this.select,
  });

  /// Model name to update.
  final String model;

  /// Predicates expected to identify the target row.
  final List<QueryPredicate> where;

  /// Updated scalar data.
  final Map<String, Object?> data;

  /// Relations to materialize in the returned payload.
  final QueryInclude? include;

  /// Scalar fields to project in the returned payload.
  final QuerySelect? select;
}

@immutable
/// Query object for deleting a single record.
class DeleteQuery {
  /// Creates a `delete` query.
  const DeleteQuery({
    required this.model,
    required this.where,
    this.include,
    this.select,
  });

  /// Model name to delete from.
  final String model;

  /// Predicates expected to identify the target row.
  final List<QueryPredicate> where;

  /// Relations to materialize in the returned payload.
  final QueryInclude? include;

  /// Scalar fields to project in the returned payload.
  final QuerySelect? select;
}

@immutable
/// Query object for bulk updates.
class UpdateManyQuery {
  /// Creates an `updateMany` query.
  const UpdateManyQuery({
    required this.model,
    required this.where,
    required this.data,
  });

  /// Model name to update.
  final String model;

  /// Predicates used to select rows for update.
  final List<QueryPredicate> where;

  /// Updated scalar data.
  final Map<String, Object?> data;
}

@immutable
/// Query object for bulk deletes.
class DeleteManyQuery {
  /// Creates a `deleteMany` query.
  const DeleteManyQuery({required this.model, required this.where});

  /// Model name to delete from.
  final String model;

  /// Predicates used to select rows for deletion.
  final List<QueryPredicate> where;
}
