import 'package:meta/meta.dart';

import 'query_models.dart';

@immutable
/// Numeric predicates used by aggregate filters and numeric comparisons.
class DoubleFilter {
  /// Creates a numeric filter.
  const DoubleFilter({
    this.equals,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.inList,
    this.notInList,
    this.not,
  });

  /// Exact numeric match.
  final double? equals;

  /// Strictly greater-than match.
  final double? gt;

  /// Greater-than-or-equal match.
  final double? gte;

  /// Strictly less-than match.
  final double? lt;

  /// Less-than-or-equal match.
  final double? lte;

  /// Membership test.
  final List<double>? inList;

  /// Negated membership test.
  final List<double>? notInList;

  /// Negated exact match.
  final double? not;

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
          value: List<double>.unmodifiable(inList!),
        ),
      );
    }
    if (notInList != null) {
      predicates.add(
        QueryPredicate(
          field: field,
          operator: 'notIn',
          value: List<double>.unmodifiable(notInList!),
        ),
      );
    }
    if (not != null) {
      predicates.add(QueryPredicate(field: field, operator: 'not', value: not));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

/// Aggregate function names supported by the query engine.
enum QueryAggregateFunction {
  /// Counts matching records or non-null field values.
  count,

  /// Computes the arithmetic mean of numeric field values.
  avg,

  /// Computes the sum of numeric field values.
  sum,

  /// Returns the smallest non-null field value.
  min,

  /// Returns the largest non-null field value.
  max,
}

@immutable
/// Count selection for aggregate and group-by queries.
class QueryCountSelection {
  /// Creates a count selection.
  const QueryCountSelection({this.all = false, this.fields = const <String>{}});

  /// Whether to return the total record count as `_all`.
  final bool all;

  /// Scalar fields to count non-null values for.
  final Set<String> fields;

  /// Whether no count values were requested.
  bool get isEmpty => !all && fields.isEmpty;
}

@immutable
/// Backend-neutral aggregate query.
class AggregateQuery {
  /// Creates an aggregate query.
  const AggregateQuery({
    required this.model,
    this.where = const <QueryPredicate>[],
    this.orderBy = const <QueryOrderBy>[],
    this.skip,
    this.take,
    this.count = const QueryCountSelection(),
    this.avg = const <String>{},
    this.sum = const <String>{},
    this.min = const <String>{},
    this.max = const <String>{},
  });

  /// Model name to query.
  final String model;

  /// Predicates combined by the adapter.
  final List<QueryPredicate> where;

  /// Ordering clauses used before applying [skip] and [take].
  final List<QueryOrderBy> orderBy;

  /// Number of matching rows to skip before aggregating.
  final int? skip;

  /// Maximum number of rows to aggregate.
  final int? take;

  /// Count selections to compute.
  final QueryCountSelection count;

  /// Numeric fields to average.
  final Set<String> avg;

  /// Numeric fields to sum.
  final Set<String> sum;

  /// Fields to minimize.
  final Set<String> min;

  /// Fields to maximize.
  final Set<String> max;
}

@immutable
/// Count values returned by an aggregate query.
class QueryCountAggregateResult {
  /// Creates a count aggregate result.
  const QueryCountAggregateResult({
    this.all,
    this.fields = const <String, int>{},
  });

  /// Total number of aggregated rows when `_all` was requested.
  final int? all;

  /// Non-null value counts keyed by field name.
  final Map<String, int> fields;
}

@immutable
/// Aggregate output returned by [AggregateQuery] and [GroupByQuery].
class AggregateQueryResult {
  /// Creates an aggregate output.
  const AggregateQueryResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  /// Count results, if requested.
  final QueryCountAggregateResult? count;

  /// Average results keyed by field name.
  final Map<String, double?>? avg;

  /// Sum results keyed by field name.
  final Map<String, num?>? sum;

  /// Minimum values keyed by field name.
  final Map<String, Object?>? min;

  /// Maximum values keyed by field name.
  final Map<String, Object?>? max;
}

@immutable
/// Aggregate predicate used by `having` and aggregate-aware ordering.
class QueryAggregatePredicate {
  /// Creates an aggregate predicate.
  const QueryAggregatePredicate({
    required this.field,
    required this.function,
    required this.operator,
    required this.value,
  });

  /// Field name the aggregate is computed for.
  final String field;

  /// Aggregate function applied to [field].
  final QueryAggregateFunction function;

  /// Operator understood by the aggregate engine.
  final String operator;

  /// Operand value for the predicate.
  final Object? value;
}

@immutable
/// Numeric aggregate filters used in generated `having` inputs.
class NumericAggregatesFilter {
  /// Creates numeric aggregate filters.
  const NumericAggregatesFilter({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  /// Count predicate for the grouped field.
  final IntFilter? count;

  /// Average predicate for the grouped field.
  final DoubleFilter? avg;

  /// Sum predicate for the grouped field.
  final DoubleFilter? sum;

  /// Minimum predicate for the grouped field.
  final DoubleFilter? min;

  /// Maximum predicate for the grouped field.
  final DoubleFilter? max;

  /// Expands this filter into aggregate predicates for [field].
  List<QueryAggregatePredicate> toPredicates(String field) {
    final predicates = <QueryAggregatePredicate>[];
    if (count != null) {
      predicates.addAll(
        _intAggregatePredicates(field, QueryAggregateFunction.count, count!),
      );
    }
    if (avg != null) {
      predicates.addAll(
        _doubleAggregatePredicates(field, QueryAggregateFunction.avg, avg!),
      );
    }
    if (sum != null) {
      predicates.addAll(
        _doubleAggregatePredicates(field, QueryAggregateFunction.sum, sum!),
      );
    }
    if (min != null) {
      predicates.addAll(
        _doubleAggregatePredicates(field, QueryAggregateFunction.min, min!),
      );
    }
    if (max != null) {
      predicates.addAll(
        _doubleAggregatePredicates(field, QueryAggregateFunction.max, max!),
      );
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

@immutable
/// Ordering entry used by group-by queries.
class GroupByOrderBy {
  /// Creates an ordering by a grouped field.
  const GroupByOrderBy.field({required this.field, required this.direction})
    : aggregate = null;

  /// Creates an ordering by an aggregate value.
  const GroupByOrderBy.aggregate({
    required this.aggregate,
    required this.direction,
    this.field,
  });

  /// Grouped field name for direct ordering.
  final String? field;

  /// Aggregate function for aggregate ordering.
  final QueryAggregateFunction? aggregate;

  /// Sort direction.
  final SortOrder direction;

  /// Whether this ordering is aggregate-based.
  bool get isAggregate => aggregate != null;
}

@immutable
/// Backend-neutral group-by query.
class GroupByQuery {
  /// Creates a group-by query.
  const GroupByQuery({
    required this.model,
    required this.by,
    this.where = const <QueryPredicate>[],
    this.having = const <QueryAggregatePredicate>[],
    this.orderBy = const <GroupByOrderBy>[],
    this.skip,
    this.take,
    this.count = const QueryCountSelection(),
    this.avg = const <String>{},
    this.sum = const <String>{},
    this.min = const <String>{},
    this.max = const <String>{},
  });

  /// Model name to query.
  final String model;

  /// Grouping key fields in output order.
  final List<String> by;

  /// Predicates applied before grouping.
  final List<QueryPredicate> where;

  /// Aggregate predicates applied after grouping.
  final List<QueryAggregatePredicate> having;

  /// Ordering clauses applied to grouped rows.
  final List<GroupByOrderBy> orderBy;

  /// Number of grouped rows to skip.
  final int? skip;

  /// Maximum number of grouped rows to return.
  final int? take;

  /// Count selections to compute for each group.
  final QueryCountSelection count;

  /// Numeric fields to average for each group.
  final Set<String> avg;

  /// Numeric fields to sum for each group.
  final Set<String> sum;

  /// Fields to minimize for each group.
  final Set<String> min;

  /// Fields to maximize for each group.
  final Set<String> max;
}

@immutable
/// Single grouped row returned by [GroupByQuery].
class GroupByQueryResultRow {
  /// Creates a grouped row.
  const GroupByQueryResultRow({required this.group, required this.aggregates});

  /// Group key values keyed by field name.
  final Map<String, Object?> group;

  /// Aggregate values computed for this group.
  final AggregateQueryResult aggregates;
}

/// Returns [records] with duplicate rows removed according to [fields].
List<Map<String, Object?>> applyDistinctRecords(
  Iterable<Map<String, Object?>> records,
  Iterable<String> fields,
) {
  final distinctFields = fields.toList(growable: false);
  if (distinctFields.isEmpty) {
    return List<Map<String, Object?>>.unmodifiable(
      records.toList(growable: false),
    );
  }

  final seen = <_DistinctKey>{};
  final deduplicated = <Map<String, Object?>>[];
  for (final record in records) {
    final key = _DistinctKey(
      distinctFields.map((field) => record[field]).toList(growable: false),
    );
    if (seen.add(key)) {
      deduplicated.add(record);
    }
  }

  return List<Map<String, Object?>>.unmodifiable(deduplicated);
}

/// Computes aggregate values for [records] according to [query].
AggregateQueryResult computeAggregateQueryResult(
  Iterable<Map<String, Object?>> records,
  AggregateQuery query,
) {
  final rows = records.toList(growable: false);

  return AggregateQueryResult(
    count: query.count.isEmpty
        ? null
        : QueryCountAggregateResult(
            all: query.count.all ? rows.length : null,
            fields: Map<String, int>.unmodifiable({
              for (final field in query.count.fields)
                field: rows.where((record) => record[field] != null).length,
            }),
          ),
    avg: query.avg.isEmpty
        ? null
        : Map<String, double?>.unmodifiable({
            for (final field in query.avg) field: _average(rows, field),
          }),
    sum: query.sum.isEmpty
        ? null
        : Map<String, num?>.unmodifiable({
            for (final field in query.sum) field: _sum(rows, field),
          }),
    min: query.min.isEmpty
        ? null
        : Map<String, Object?>.unmodifiable({
            for (final field in query.min) field: _min(rows, field),
          }),
    max: query.max.isEmpty
        ? null
        : Map<String, Object?>.unmodifiable({
            for (final field in query.max) field: _max(rows, field),
          }),
  );
}

/// Computes grouped rows for [records] according to [query].
List<GroupByQueryResultRow> computeGroupByQueryResultRows(
  Iterable<Map<String, Object?>> records,
  GroupByQuery query,
) {
  if (query.by.isEmpty) {
    throw StateError('GroupByQuery.by must contain at least one field.');
  }

  final groups = <_DistinctKey, List<Map<String, Object?>>>{};
  final groupValues = <_DistinctKey, Map<String, Object?>>{};

  for (final record in records) {
    final keyValues = query.by
        .map((field) => record[field])
        .toList(growable: false);
    final key = _DistinctKey(keyValues);
    groups.putIfAbsent(key, () => <Map<String, Object?>>[]).add(record);
    groupValues.putIfAbsent(
      key,
      () => Map<String, Object?>.unmodifiable({
        for (final field in query.by) field: record[field],
      }),
    );
  }

  var results = groups.entries
      .map((entry) {
        final aggregate = computeAggregateQueryResult(
          entry.value,
          AggregateQuery(
            model: query.model,
            count: query.count,
            avg: query.avg,
            sum: query.sum,
            min: query.min,
            max: query.max,
          ),
        );
        return GroupByQueryResultRow(
          group: groupValues[entry.key]!,
          aggregates: aggregate,
        );
      })
      .where(
        (row) => query.having.every(
          (predicate) => _matchesAggregatePredicate(row.aggregates, predicate),
        ),
      )
      .toList(growable: true);

  if (query.orderBy.isNotEmpty) {
    results.sort(
      (left, right) => _compareGroupedRows(left, right, query.orderBy),
    );
  }

  if (query.skip != null) {
    results = results.skip(query.skip!).toList(growable: false);
  }
  if (query.take != null) {
    results = results.take(query.take!).toList(growable: false);
  }

  return List<GroupByQueryResultRow>.unmodifiable(results);
}

List<QueryAggregatePredicate> _intAggregatePredicates(
  String field,
  QueryAggregateFunction function,
  IntFilter filter,
) {
  final predicates = <QueryAggregatePredicate>[];
  if (filter.equals != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'equals',
        value: filter.equals,
      ),
    );
  }
  if (filter.gt != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'gt',
        value: filter.gt,
      ),
    );
  }
  if (filter.gte != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'gte',
        value: filter.gte,
      ),
    );
  }
  if (filter.lt != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'lt',
        value: filter.lt,
      ),
    );
  }
  if (filter.lte != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'lte',
        value: filter.lte,
      ),
    );
  }
  if (filter.inList != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'in',
        value: List<int>.unmodifiable(filter.inList!),
      ),
    );
  }
  if (filter.notInList != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'notIn',
        value: List<int>.unmodifiable(filter.notInList!),
      ),
    );
  }
  if (filter.not != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'not',
        value: filter.not,
      ),
    );
  }
  return List<QueryAggregatePredicate>.unmodifiable(predicates);
}

List<QueryAggregatePredicate> _doubleAggregatePredicates(
  String field,
  QueryAggregateFunction function,
  DoubleFilter filter,
) {
  final predicates = <QueryAggregatePredicate>[];
  if (filter.equals != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'equals',
        value: filter.equals,
      ),
    );
  }
  if (filter.gt != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'gt',
        value: filter.gt,
      ),
    );
  }
  if (filter.gte != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'gte',
        value: filter.gte,
      ),
    );
  }
  if (filter.lt != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'lt',
        value: filter.lt,
      ),
    );
  }
  if (filter.lte != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'lte',
        value: filter.lte,
      ),
    );
  }
  if (filter.inList != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'in',
        value: List<double>.unmodifiable(filter.inList!),
      ),
    );
  }
  if (filter.notInList != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'notIn',
        value: List<double>.unmodifiable(filter.notInList!),
      ),
    );
  }
  if (filter.not != null) {
    predicates.add(
      QueryAggregatePredicate(
        field: field,
        function: function,
        operator: 'not',
        value: filter.not,
      ),
    );
  }
  return List<QueryAggregatePredicate>.unmodifiable(predicates);
}

double? _average(List<Map<String, Object?>> records, String field) {
  final numericValues = records
      .map((record) => record[field])
      .whereType<num>()
      .toList(growable: false);
  if (numericValues.isEmpty) {
    return null;
  }

  final total = numericValues.fold<double>(
    0,
    (sum, value) => sum + value.toDouble(),
  );
  return total / numericValues.length;
}

num? _sum(List<Map<String, Object?>> records, String field) {
  final numericValues = records
      .map((record) => record[field])
      .whereType<num>()
      .toList(growable: false);
  if (numericValues.isEmpty) {
    return null;
  }

  if (numericValues.every((value) => value is int)) {
    return numericValues.fold<int>(0, (sum, value) => sum + value.toInt());
  }

  return numericValues.fold<double>(0, (sum, value) => sum + value.toDouble());
}

Object? _min(List<Map<String, Object?>> records, String field) {
  Object? current;
  for (final value in records.map((record) => record[field])) {
    if (value == null) {
      continue;
    }
    if (current == null || _compareValues(value, current) < 0) {
      current = value;
    }
  }
  return current;
}

Object? _max(List<Map<String, Object?>> records, String field) {
  Object? current;
  for (final value in records.map((record) => record[field])) {
    if (value == null) {
      continue;
    }
    if (current == null || _compareValues(value, current) > 0) {
      current = value;
    }
  }
  return current;
}

bool _matchesAggregatePredicate(
  AggregateQueryResult aggregates,
  QueryAggregatePredicate predicate,
) {
  final actualValue = _aggregateValue(
    aggregates,
    predicate.function,
    predicate.field,
  );
  return _matchesOperator(actualValue, predicate.operator, predicate.value);
}

Object? _aggregateValue(
  AggregateQueryResult aggregates,
  QueryAggregateFunction function,
  String? field,
) {
  return switch (function) {
    QueryAggregateFunction.count =>
      field == null ? aggregates.count?.all : aggregates.count?.fields[field],
    QueryAggregateFunction.avg => field == null ? null : aggregates.avg?[field],
    QueryAggregateFunction.sum => field == null ? null : aggregates.sum?[field],
    QueryAggregateFunction.min => field == null ? null : aggregates.min?[field],
    QueryAggregateFunction.max => field == null ? null : aggregates.max?[field],
  };
}

int _compareGroupedRows(
  GroupByQueryResultRow left,
  GroupByQueryResultRow right,
  List<GroupByOrderBy> orderBy,
) {
  for (final ordering in orderBy) {
    final comparison = ordering.isAggregate
        ? _compareValues(
            _aggregateValue(
              left.aggregates,
              ordering.aggregate!,
              ordering.field,
            ),
            _aggregateValue(
              right.aggregates,
              ordering.aggregate!,
              ordering.field,
            ),
          )
        : _compareValues(
            left.group[ordering.field],
            right.group[ordering.field],
          );
    if (comparison == 0) {
      continue;
    }

    return ordering.direction == SortOrder.asc ? comparison : -comparison;
  }

  return 0;
}

bool _matchesOperator(
  Object? actualValue,
  String operator,
  Object? expectedValue,
) {
  switch (operator) {
    case 'equals':
      return actualValue == expectedValue;
    case 'not':
      return actualValue != expectedValue;
    case 'gt':
      return _compareValues(actualValue, expectedValue) > 0;
    case 'gte':
      return _compareValues(actualValue, expectedValue) >= 0;
    case 'lt':
      return _compareValues(actualValue, expectedValue) < 0;
    case 'lte':
      return _compareValues(actualValue, expectedValue) <= 0;
    case 'in':
      if (expectedValue is! Iterable<Object?>) {
        return false;
      }
      return expectedValue.contains(actualValue);
    default:
      return false;
  }
}

int _compareValues(Object? left, Object? right) {
  if (left == null && right == null) {
    return 0;
  }
  if (left == null) {
    return -1;
  }
  if (right == null) {
    return 1;
  }
  if (left is num && right is num) {
    return left.compareTo(right);
  }
  if (left is String && right is String) {
    return left.compareTo(right);
  }
  if (left is DateTime && right is DateTime) {
    return left.compareTo(right);
  }
  if (left is bool && right is bool) {
    return (left ? 1 : 0).compareTo(right ? 1 : 0);
  }

  return left.toString().compareTo(right.toString());
}

class _DistinctKey {
  const _DistinctKey(this.values);

  final List<Object?> values;

  @override
  bool operator ==(Object other) {
    if (other is! _DistinctKey || other.values.length != values.length) {
      return false;
    }

    for (var index = 0; index < values.length; index++) {
      if (other.values[index] != values[index]) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);
}
