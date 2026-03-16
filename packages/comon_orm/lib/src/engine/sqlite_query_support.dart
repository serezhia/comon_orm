import 'dart:convert';

import 'package:comon_orm/comon_orm.dart';

/// Lightweight SQL clause payload used by shared SQLite-family helper methods.
typedef SqliteSqlClause = ({String sql, List<Object?> parameters});

/// Shared helper methods for SQLite-family query assembly and value coercion.
class SqliteQuerySupport {
  /// Prevents instantiation.
  const SqliteQuerySupport._();

  /// Builds a provider-agnostic aggregate predicate clause using SQLite placeholders.
  static TClause buildAggregatePredicateClause<TClause>({
    required String alias,
    required String model,
    required QueryAggregatePredicate predicate,
    required String Function(
      String alias,
      String model,
      String field,
      QueryAggregateFunction function,
    )
    aggregateSqlExpr,
    required TClause Function({
      required String sql,
      required List<Object?> parameters,
    })
    buildClause,
  }) {
    final aggregateExpression = aggregateSqlExpr(
      alias,
      model,
      predicate.field,
      predicate.function,
    );
    switch (predicate.operator) {
      case 'in':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return buildClause(sql: '1 = 0', parameters: const <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return buildClause(
          sql: '$aggregateExpression IN ($placeholders)',
          parameters: values,
        );
      case 'notIn':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return buildClause(sql: '1 = 1', parameters: const <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return buildClause(
          sql: '$aggregateExpression NOT IN ($placeholders)',
          parameters: values,
        );
      default:
        final operator = switch (predicate.operator) {
          'equals' => '=',
          'not' => '!=',
          'gt' => '>',
          'gte' => '>=',
          'lt' => '<',
          'lte' => '<=',
          _ => throw UnsupportedError(
            'Unsupported aggregate predicate operator: ${predicate.operator}',
          ),
        };
        return buildClause(
          sql: '$aggregateExpression $operator ?',
          parameters: <Object?>[predicate.value],
        );
    }
  }

  /// Builds an `ORDER BY` clause for regular field sorting.
  static String buildOrderByClause({
    required String alias,
    required String model,
    required List<QueryOrderBy> orderBy,
    required String Function(String alias, String model, String field)
    qualifiedField,
  }) {
    return orderBy
        .map(
          (entry) =>
              '${qualifiedField(alias, model, entry.field)} ${entry.direction == SortOrder.asc ? 'ASC' : 'DESC'}',
        )
        .join(', ');
  }

  /// Builds an `ORDER BY` clause for `groupBy` field and aggregate sorting.
  static String buildGroupByOrderClause({
    required String alias,
    required String model,
    required List<GroupByOrderBy> orderBy,
    required String Function(
      String alias,
      String model,
      String field,
      QueryAggregateFunction function,
    )
    aggregateSqlExpr,
    required String Function(String alias, String model, String field)
    qualifiedField,
  }) {
    return orderBy
        .map((entry) {
          final direction = entry.direction == SortOrder.asc ? 'ASC' : 'DESC';
          if (entry.isAggregate) {
            final expression = aggregateSqlExpr(
              alias,
              model,
              entry.field ?? '_all',
              entry.aggregate!,
            );
            return '$expression $direction';
          }
          return '${qualifiedField(alias, model, entry.field!)} $direction';
        })
        .join(', ');
  }

  /// Coerces SQLite aggregate/count results into an `int` when possible.
  static int? toInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  /// Coerces SQLite numeric results into a `double` when possible.
  static double? toDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Coerces SQLite numeric results into a `num` when possible.
  static num? toNum(Object? value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  /// Normalizes bytes values before writing them into SQLite storage.
  static List<int> normalizeBytesForStorage(Object? value) {
    if (value is List<int>) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<int>().toList(growable: false);
    }
    throw ArgumentError.value(
      value,
      'value',
      'Expected bytes-compatible value.',
    );
  }

  /// Normalizes bytes values read back from SQLite storage.
  static List<int> normalizeBytesFromStorage(Object? value) {
    if (value is List<int>) {
      return value;
    }
    if (value is List<Object?>) {
      return value.whereType<int>().toList(growable: false);
    }
    throw StateError('Unexpected SQLite bytes value: $value');
  }

  /// Normalizes a logical field value before writing it into SQLite storage.
  static Object? normalizeValueForStorage({
    required RuntimeModelView? model,
    required String field,
    required Object? value,
  }) {
    if (value == null || model == null) {
      return value;
    }
    final fieldDefinition = model.findField(field);
    if (fieldDefinition == null) {
      return value;
    }
    return switch (fieldDefinition.type) {
      'Boolean' => value is bool ? (value ? 1 : 0) : value,
      'DateTime' => value is DateTime ? value.toIso8601String() : value,
      'BigInt' => value is BigInt ? value.toString() : value,
      'Float' || 'Decimal' => value is num ? value.toDouble() : value,
      'Json' => jsonEncode(value),
      'Bytes' => normalizeBytesForStorage(value),
      _ => value,
    };
  }

  /// Normalizes a SQLite storage value back into the generated logical shape.
  static Object? normalizeValueFromStorage({
    required RuntimeModelView? model,
    required String field,
    required Object? value,
  }) {
    if (value == null || model == null) {
      return value;
    }
    final fieldDefinition = model.findField(field);
    if (fieldDefinition == null) {
      return value;
    }
    return switch (fieldDefinition.type) {
      'Boolean' => value is int ? value != 0 : value,
      'DateTime' => value is String ? DateTime.parse(value) : value,
      'BigInt' =>
        value is String
            ? BigInt.parse(value)
            : value is int
            ? BigInt.from(value)
            : value,
      'Float' || 'Decimal' => value is num ? value.toDouble() : value,
      'Json' => value is String ? jsonDecode(value) : value,
      'Bytes' => normalizeBytesFromStorage(value),
      _ => value,
    };
  }

  /// Builds an equality clause across matching field lists.
  static String buildQualifiedFieldEqualityClause({
    required String leftAlias,
    required String leftModel,
    required List<String> leftFields,
    bool leftRaw = false,
    required String rightAlias,
    required String rightModel,
    required List<String> rightFields,
    bool rightRaw = false,
    required String Function(String alias, String model, String field)
    qualifiedField,
    required String Function(String alias, String field) qualifiedRawField,
  }) {
    final comparisons = <String>[];
    for (var index = 0; index < leftFields.length; index++) {
      final left = leftRaw
          ? qualifiedRawField(leftAlias, leftFields[index])
          : qualifiedField(leftAlias, leftModel, leftFields[index]);
      final right = rightRaw
          ? qualifiedRawField(rightAlias, rightFields[index])
          : qualifiedField(rightAlias, rightModel, rightFields[index]);
      comparisons.add('$left = $right');
    }
    return comparisons.join(' AND ');
  }

  /// Builds a binary predicate clause and its bound parameters.
  static ({String sql, List<Object?> parameters}) buildBinaryClause({
    required String alias,
    required String field,
    required String operator,
    required Object? value,
    required String model,
    required String Function(String alias, String model, String field)
    qualifiedField,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    if (value == null && operator == '=') {
      return (
        sql: '${qualifiedField(alias, model, field)} IS NULL',
        parameters: const <Object?>[],
      );
    }

    return (
      sql: '${qualifiedField(alias, model, field)} $operator ?',
      parameters: <Object?>[normalizeValueForStorage(model, field, value)],
    );
  }

  /// Joins already-built predicate clauses with a boolean glue operator.
  static ({String sql, List<Object?> parameters}) joinClauses({
    required List<({String sql, List<Object?> parameters})> clauses,
    required String glue,
  }) {
    if (clauses.isEmpty) {
      return (sql: '1 = 1', parameters: const <Object?>[]);
    }
    return (
      sql: clauses.map((clause) => '(${clause.sql})').join(' $glue '),
      parameters: clauses
          .expand((clause) => clause.parameters)
          .toList(growable: false),
    );
  }

  /// Builds aggregate select expressions for aggregate and group-by queries.
  static List<String> buildAggregateSelectExprs({
    required String? alias,
    required String model,
    required QueryCountSelection count,
    required Set<String> avg,
    required Set<String> sum,
    required Set<String> min,
    required Set<String> max,
    required String Function(String alias, String model, String field)
    qualifiedField,
    required String Function(String model, String field) columnIdentifier,
  }) {
    final exprs = <String>[];
    if (count.all) {
      exprs.add('COUNT(*) AS "_count__all"');
    }
    for (final field in count.fields) {
      final col = alias != null
          ? qualifiedField(alias, model, field)
          : columnIdentifier(model, field);
      exprs.add('COUNT($col) AS "_count_$field"');
    }
    for (final field in avg) {
      final col = alias != null
          ? qualifiedField(alias, model, field)
          : columnIdentifier(model, field);
      exprs.add('AVG($col) AS "_avg_$field"');
    }
    for (final field in sum) {
      final col = alias != null
          ? qualifiedField(alias, model, field)
          : columnIdentifier(model, field);
      exprs.add('SUM($col) AS "_sum_$field"');
    }
    for (final field in min) {
      final col = alias != null
          ? qualifiedField(alias, model, field)
          : columnIdentifier(model, field);
      exprs.add('MIN($col) AS "_min_$field"');
    }
    for (final field in max) {
      final col = alias != null
          ? qualifiedField(alias, model, field)
          : columnIdentifier(model, field);
      exprs.add('MAX($col) AS "_max_$field"');
    }
    return exprs;
  }

  /// Parses a raw aggregate result row into the shared aggregate result model.
  static AggregateQueryResult parseAggregateResultRow({
    required Map<String, Object?> row,
    required QueryCountSelection count,
    required Set<String> avg,
    required Set<String> sum,
    required Set<String> min,
    required Set<String> max,
  }) {
    return AggregateQueryResult(
      count: count.isEmpty
          ? null
          : QueryCountAggregateResult(
              all: count.all ? toInt(row['_count__all']) : null,
              fields: Map<String, int>.unmodifiable({
                for (final field in count.fields)
                  field: toInt(row['_count_$field']) ?? 0,
              }),
            ),
      avg: avg.isEmpty
          ? null
          : Map<String, double?>.unmodifiable({
              for (final field in avg) field: toDouble(row['_avg_$field']),
            }),
      sum: sum.isEmpty
          ? null
          : Map<String, num?>.unmodifiable({
              for (final field in sum) field: toNum(row['_sum_$field']),
            }),
      min: min.isEmpty
          ? null
          : Map<String, Object?>.unmodifiable({
              for (final field in min) field: row['_min_$field'],
            }),
      max: max.isEmpty
          ? null
          : Map<String, Object?>.unmodifiable({
              for (final field in max) field: row['_max_$field'],
            }),
    );
  }

  /// Builds a `WHERE` clause from a list of query predicates.
  static SqliteSqlClause buildWhereClause({
    required String model,
    required String alias,
    required List<QueryPredicate> predicates,
    required SqliteSqlClause Function(
      String model,
      String alias,
      QueryPredicate predicate,
    )
    buildPredicateClause,
  }) {
    if (predicates.isEmpty) {
      return (sql: '1 = 1', parameters: const <Object?>[]);
    }

    return joinClauses(
      clauses: predicates
          .map((predicate) => buildPredicateClause(model, alias, predicate))
          .toList(growable: false),
      glue: 'AND',
    );
  }

  /// Builds a single predicate clause for a SQLite-family `WHERE` expression.
  static SqliteSqlClause buildPredicateClause({
    required String model,
    required String alias,
    required QueryPredicate predicate,
    required SqliteSqlClause Function(
      String model,
      String alias,
      List<QueryPredicate> predicates,
    )
    buildWhereClause,
    required SqliteSqlClause Function(
      String sourceModel,
      String sourceAlias,
      String operator,
      QueryRelationFilter filter,
    )
    buildRelationClause,
    required SqliteSqlClause Function(
      String alias,
      String field,
      String operator,
      Object? value,
      String model,
    )
    buildBinaryClause,
    required String Function(String alias, String model, String field)
    qualifiedField,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    switch (predicate.operator) {
      case 'logicalAnd':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return (sql: '1 = 1', parameters: const <Object?>[]);
        }
        return joinClauses(
          clauses: group.branches
              .map((branch) => buildWhereClause(model, alias, branch))
              .toList(growable: false),
          glue: 'AND',
        );
      case 'logicalOr':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return (sql: '1 = 0', parameters: const <Object?>[]);
        }
        return joinClauses(
          clauses: group.branches
              .map((branch) => buildWhereClause(model, alias, branch))
              .toList(growable: false),
          glue: 'OR',
        );
      case 'logicalNot':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return (sql: '1 = 1', parameters: const <Object?>[]);
        }
        return joinClauses(
          clauses: group.branches
              .map((branch) => buildWhereClause(model, alias, branch))
              .map(
                (branchClause) => (
                  sql: 'NOT (${branchClause.sql})',
                  parameters: branchClause.parameters,
                ),
              )
              .toList(growable: false),
          glue: 'AND',
        );
      case 'relationSome':
      case 'relationNone':
      case 'relationEvery':
      case 'relationIs':
      case 'relationIsNot':
        return buildRelationClause(
          model,
          alias,
          predicate.operator,
          predicate.value as QueryRelationFilter,
        );
      case 'equals':
        return buildBinaryClause(
          alias,
          predicate.field,
          '=',
          predicate.value,
          model,
        );
      case 'not':
        if (predicate.value == null) {
          return (
            sql: '${qualifiedField(alias, model, predicate.field)} IS NOT NULL',
            parameters: const <Object?>[],
          );
        }
        return buildBinaryClause(
          alias,
          predicate.field,
          '!=',
          predicate.value,
          model,
        );
      case 'contains':
        return (
          sql: '${qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['%${predicate.value}%'],
        );
      case 'startsWith':
        return (
          sql: '${qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['${predicate.value}%'],
        );
      case 'endsWith':
        return (
          sql: '${qualifiedField(alias, model, predicate.field)} LIKE ?',
          parameters: <Object?>['%${predicate.value}'],
        );
      case 'containsInsensitive':
        return (
          sql:
              'LOWER(${qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['%${predicate.value}%'],
        );
      case 'startsWithInsensitive':
        return (
          sql:
              'LOWER(${qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['${predicate.value}%'],
        );
      case 'endsWithInsensitive':
        return (
          sql:
              'LOWER(${qualifiedField(alias, model, predicate.field)}) LIKE LOWER(?)',
          parameters: <Object?>['%${predicate.value}'],
        );
      case 'in':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return (sql: '1 = 0', parameters: const <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return (
          sql:
              '${qualifiedField(alias, model, predicate.field)} IN ($placeholders)',
          parameters: values
              .map(
                (value) =>
                    normalizeValueForStorage(model, predicate.field, value),
              )
              .toList(growable: false),
        );
      case 'notIn':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return (sql: '1 = 1', parameters: const <Object?>[]);
        }
        final placeholders = List<String>.filled(values.length, '?').join(', ');
        return (
          sql:
              '${qualifiedField(alias, model, predicate.field)} NOT IN ($placeholders)',
          parameters: values
              .map(
                (value) =>
                    normalizeValueForStorage(model, predicate.field, value),
              )
              .toList(growable: false),
        );
      case 'gt':
        return buildBinaryClause(
          alias,
          predicate.field,
          '>',
          predicate.value,
          model,
        );
      case 'gte':
        return buildBinaryClause(
          alias,
          predicate.field,
          '>=',
          predicate.value,
          model,
        );
      case 'lt':
        return buildBinaryClause(
          alias,
          predicate.field,
          '<',
          predicate.value,
          model,
        );
      case 'lte':
        return buildBinaryClause(
          alias,
          predicate.field,
          '<=',
          predicate.value,
          model,
        );
      default:
        throw UnsupportedError(
          'Unsupported predicate operator ${predicate.operator}.',
        );
    }
  }

  /// Builds a relation predicate clause for direct and implicit many-to-many relations.
  static SqliteSqlClause buildRelationClause({
    required String sourceModel,
    required String sourceAlias,
    required String operator,
    required QueryRelationFilter filter,
    required String Function() nextAlias,
    required SqliteSqlClause Function(
      String model,
      String alias,
      List<QueryPredicate> predicates,
    )
    buildWhereClause,
    required SqliteSqlClause Function(
      String sourceModel,
      String sourceAlias,
      String operator,
      QueryRelationFilter filter,
    )
    buildImplicitManyToManyRelationClause,
    required String Function({
      required String leftAlias,
      required String leftModel,
      required List<String> leftFields,
      bool leftRaw,
      required String rightAlias,
      required String rightModel,
      required List<String> rightFields,
      bool rightRaw,
    })
    qualifiedFieldEqualityClause,
    required String Function(String model, String alias) tableReference,
  }) {
    if (filter.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      return buildImplicitManyToManyRelationClause(
        sourceModel,
        sourceAlias,
        operator,
        filter,
      );
    }

    final targetAlias = nextAlias();
    final nestedClause = buildWhereClause(
      filter.relation.targetModel,
      targetAlias,
      filter.predicates,
    );
    final joinClause = qualifiedFieldEqualityClause(
      leftAlias: targetAlias,
      leftModel: filter.relation.targetModel,
      leftFields: filter.relation.targetKeyFields,
      leftRaw: false,
      rightAlias: sourceAlias,
      rightModel: sourceModel,
      rightFields: filter.relation.localKeyFields,
      rightRaw: false,
    );

    final predicateSql = switch (operator) {
      'relationSome' || 'relationIs' => 'EXISTS',
      'relationNone' || 'relationIsNot' || 'relationEvery' => 'NOT EXISTS',
      _ => throw UnsupportedError('Unsupported relation operator $operator.'),
    };

    final nestedSql = switch (operator) {
      'relationEvery' => '$joinClause AND NOT (${nestedClause.sql})',
      _ => '$joinClause AND ${nestedClause.sql}',
    };

    return (
      sql:
          '$predicateSql ('
          'SELECT 1 FROM ${tableReference(filter.relation.targetModel, targetAlias)} '
          'WHERE $nestedSql'
          ')',
      parameters: nestedClause.parameters,
    );
  }

  /// Builds an implicit many-to-many relation clause.
  static SqliteSqlClause buildImplicitManyToManyRelationClause({
    required String sourceModel,
    required String sourceAlias,
    required String operator,
    required QueryRelationFilter filter,
    required String Function() nextAlias,
    required SqliteSqlClause Function(
      String model,
      String alias,
      List<QueryPredicate> predicates,
    )
    buildWhereClause,
    required RuntimeImplicitManyToManyStorage Function(
      String sourceModel,
      QueryRelation relation,
    )
    implicitManyToManyStorage,
    required String Function({
      required String leftAlias,
      required String leftModel,
      required List<String> leftFields,
      bool leftRaw,
      required String rightAlias,
      required String rightModel,
      required List<String> rightFields,
      bool rightRaw,
    })
    qualifiedFieldEqualityClause,
    required String Function(String model, String alias) tableReference,
    required String Function(String tableName, String alias) rawTableReference,
  }) {
    final storage = implicitManyToManyStorage(sourceModel, filter.relation);
    final targetAlias = nextAlias();
    final joinAlias = nextAlias();
    final nestedClause = buildWhereClause(
      filter.relation.targetModel,
      targetAlias,
      filter.predicates,
    );
    final joinCondition = [
      qualifiedFieldEqualityClause(
        leftAlias: joinAlias,
        leftModel: filter.relation.targetModel,
        leftFields: storage.targetJoinColumns,
        leftRaw: true,
        rightAlias: targetAlias,
        rightModel: filter.relation.targetModel,
        rightFields: storage.targetKeyFields,
        rightRaw: false,
      ),
      qualifiedFieldEqualityClause(
        leftAlias: joinAlias,
        leftModel: sourceModel,
        leftFields: storage.sourceJoinColumns,
        leftRaw: true,
        rightAlias: sourceAlias,
        rightModel: sourceModel,
        rightFields: storage.sourceKeyFields,
        rightRaw: false,
      ),
    ].join(' AND ');

    final predicateSql = switch (operator) {
      'relationSome' || 'relationIs' => 'EXISTS',
      'relationNone' || 'relationIsNot' || 'relationEvery' => 'NOT EXISTS',
      _ => throw UnsupportedError('Unsupported relation operator $operator.'),
    };

    final nestedSql = switch (operator) {
      'relationEvery' => '$joinCondition AND NOT (${nestedClause.sql})',
      _ => '$joinCondition AND ${nestedClause.sql}',
    };

    return (
      sql:
          '$predicateSql ('
          'SELECT 1 FROM ${tableReference(filter.relation.targetModel, targetAlias)} '
          'JOIN ${rawTableReference(storage.tableName, joinAlias)} '
          'ON ${qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: filter.relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: filter.relation.targetModel, rightFields: storage.targetKeyFields, rightRaw: false)} '
          'WHERE $nestedSql'
          ')',
      parameters: nestedClause.parameters,
    );
  }

  /// Builds the shared row-selection SQL used by SQLite-family adapters.
  static SqliteSqlClause buildSelectRowsQuery({
    required String model,
    required String alias,
    required List<QueryPredicate> where,
    required int? limit,
    required int? offset,
    required String rowIdColumn,
    required SqliteSqlClause Function(
      String model,
      String alias,
      List<QueryPredicate> predicates,
    )
    buildWhereClause,
    required String Function(
      String alias,
      String model,
      List<QueryOrderBy> orderBy,
    )
    buildOrderByClause,
    required String Function(String model, String alias) tableReference,
    required String Function(String identifier) quoteIdentifier,
    List<QueryOrderBy> orderBy = const <QueryOrderBy>[],
  }) {
    final whereClause = buildWhereClause(model, alias, where);
    final orderClause = buildOrderByClause(alias, model, orderBy);
    final sql = StringBuffer()
      ..write(
        'SELECT ${quoteIdentifier(alias)}.rowid AS ${quoteIdentifier(rowIdColumn)}, ${quoteIdentifier(alias)}.* '
        'FROM ${tableReference(model, alias)} '
        'WHERE ${whereClause.sql}',
      );
    final parameters = <Object?>[...whereClause.parameters];

    if (orderClause.isNotEmpty) {
      sql.write(' ORDER BY $orderClause');
    }
    if (limit != null) {
      sql.write(' LIMIT ?');
      parameters.add(limit);
    }
    if (offset != null) {
      sql.write(' OFFSET ?');
      parameters.add(offset);
    }

    return (sql: sql.toString(), parameters: parameters);
  }

  /// Builds the shared implicit many-to-many include query for SQLite-family adapters.
  static SqliteSqlClause? buildSelectImplicitManyToManyRowsQuery({
    required String sourceModel,
    required Map<String, Object?> sourceRecord,
    required QueryRelation relation,
    required RuntimeImplicitManyToManyStorage storage,
    required String rowIdColumn,
    required String Function() nextAlias,
    required String Function(String tableName, String alias) rawTableReference,
    required String Function(String model, String alias) tableReference,
    required String Function(String alias, String fieldName) qualifiedRawField,
    required String Function(String identifier) quoteIdentifier,
    required String Function({
      required String leftAlias,
      required String leftModel,
      required List<String> leftFields,
      bool leftRaw,
      required String rightAlias,
      required String rightModel,
      required List<String> rightFields,
      bool rightRaw,
    })
    qualifiedFieldEqualityClause,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    for (final field in relation.localKeyFields) {
      if (sourceRecord[field] == null) {
        return null;
      }
    }

    final targetAlias = nextAlias();
    final joinAlias = nextAlias();
    final whereClauses = <String>[];
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceJoinColumns.length; index++) {
      whereClauses.add(
        '${qualifiedRawField(joinAlias, storage.sourceJoinColumns[index])} = ?',
      );
      parameters.add(
        normalizeValueForStorage(
          sourceModel,
          relation.localKeyFields[index],
          sourceRecord[relation.localKeyFields[index]],
        ),
      );
    }

    return (
      sql:
          'SELECT ${quoteIdentifier(targetAlias)}.rowid AS ${quoteIdentifier(rowIdColumn)}, ${quoteIdentifier(targetAlias)}.* '
          'FROM ${tableReference(relation.targetModel, targetAlias)} '
          'JOIN ${rawTableReference(storage.tableName, joinAlias)} '
          'ON ${qualifiedFieldEqualityClause(leftAlias: joinAlias, leftModel: relation.targetModel, leftFields: storage.targetJoinColumns, leftRaw: true, rightAlias: targetAlias, rightModel: relation.targetModel, rightFields: relation.targetKeyFields)} '
          'WHERE ${whereClauses.join(' AND ')}',
      parameters: parameters,
    );
  }

  /// Builds the shared implicit many-to-many link insert SQL and parameters.
  static SqliteSqlClause buildInsertImplicitManyToManyLinkQuery({
    required QueryRelation relation,
    required RuntimeImplicitManyToManyStorage storage,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
    required String Function(String identifier) quoteIdentifier,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    final columnNames = [
      ...storage.sourceJoinColumns,
      ...storage.targetJoinColumns,
    ];
    final parameters = <Object?>[];
    for (var index = 0; index < storage.sourceKeyFields.length; index++) {
      parameters.add(
        normalizeValueForStorage(
          storage.sourceModel,
          storage.sourceKeyFields[index],
          sourceKeyValues[relation.localKeyFields[index]],
        ),
      );
    }
    for (var index = 0; index < storage.targetKeyFields.length; index++) {
      parameters.add(
        normalizeValueForStorage(
          storage.targetModel,
          storage.targetKeyFields[index],
          targetKeyValues[relation.targetKeyFields[index]],
        ),
      );
    }

    return (
      sql:
          'INSERT OR IGNORE INTO ${quoteIdentifier(storage.tableName)} '
          '(${columnNames.map(quoteIdentifier).join(', ')}) '
          'VALUES (${List<String>.filled(columnNames.length, '?').join(', ')})',
      parameters: parameters,
    );
  }

  /// Builds the shared implicit many-to-many link delete SQL and parameters.
  static SqliteSqlClause buildDeleteImplicitManyToManyLinkQuery({
    required QueryRelation relation,
    required RuntimeImplicitManyToManyStorage storage,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
    required String Function(String identifier) quoteIdentifier,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    final whereParts = <String>[];
    final parameters = <Object?>[];

    for (var index = 0; index < storage.sourceKeyFields.length; index++) {
      whereParts.add(
        '${quoteIdentifier(storage.sourceJoinColumns[index])} = ?',
      );
      parameters.add(
        normalizeValueForStorage(
          storage.sourceModel,
          storage.sourceKeyFields[index],
          sourceKeyValues[relation.localKeyFields[index]],
        ),
      );
    }

    if (targetKeyValues != null) {
      for (var index = 0; index < storage.targetKeyFields.length; index++) {
        whereParts.add(
          '${quoteIdentifier(storage.targetJoinColumns[index])} = ?',
        );
        parameters.add(
          normalizeValueForStorage(
            storage.targetModel,
            storage.targetKeyFields[index],
            targetKeyValues[relation.targetKeyFields[index]],
          ),
        );
      }
    }

    return (
      sql:
          'DELETE FROM ${quoteIdentifier(storage.tableName)} '
          'WHERE ${whereParts.join(' AND ')}',
      parameters: parameters,
    );
  }

  /// Applies automatic field values such as `@updatedAt` timestamps.
  static Map<String, Object?> applyAutomaticFieldValues({
    required RuntimeModelView? model,
    required Map<String, Object?> data,
    required bool isCreate,
    required DateTime timestamp,
  }) {
    final nextData = Map<String, Object?>.from(data);
    if (model == null) {
      return nextData;
    }

    for (final field in model.fields.where((field) => field.isUpdatedAt)) {
      if (isCreate) {
        nextData.putIfAbsent(field.name, () => timestamp);
      } else {
        nextData[field.name] = timestamp;
      }
    }

    return nextData;
  }

  /// Resolves implicit many-to-many storage metadata from runtime schema information.
  static RuntimeImplicitManyToManyStorage
  resolveImplicitManyToManyStorageOrThrow({
    required RuntimeSchemaView schema,
    required String sourceModel,
    required QueryRelation relation,
  }) {
    final storage = resolveRuntimeImplicitManyToManyStorage(
      schema: schema,
      sourceModelName: relation.sourceModel ?? sourceModel,
      relationFieldName: relation.field,
    );
    if (storage == null) {
      throw StateError(
        'Unable to resolve implicit many-to-many storage for ${relation.sourceModel ?? sourceModel}.${relation.field}.',
      );
    }
    return storage;
  }

  /// Extracts required relation key values from a materialized record.
  static Map<String, Object?> extractRequiredRelationKeyValues({
    required Map<String, Object?> record,
    required List<String> fields,
    required String model,
    required QueryRelation relation,
    required String role,
  }) {
    final keyValues = <String, Object?>{};
    for (final field in fields) {
      final value = record[field];
      if (value == null) {
        throw StateError(
          'Missing $role key "$field" for nested create on $model.${relation.field}.',
        );
      }
      keyValues[field] = value;
    }
    return Map<String, Object?>.unmodifiable(keyValues);
  }

  /// Returns whether a record contains all required relation key fields.
  static bool recordContainsAllRelationKeyFields({
    required Map<String, Object?> record,
    required List<String> fields,
  }) {
    for (final field in fields) {
      if (record[field] == null) {
        return false;
      }
    }
    return true;
  }

  /// Returns a runtime model definition or throws when the model is unknown.
  static RuntimeModelView requireModelDefinition({
    required RuntimeSchemaView schema,
    required String model,
  }) {
    final definition = schema.findModel(model);
    if (definition == null) {
      throw StateError('Unknown model $model.');
    }
    return definition;
  }

  /// Quotes an SQLite identifier.
  static String quoteIdentifier(String identifier) {
    return '"${identifier.replaceAll('"', '""')}"';
  }

  /// Builds a raw table reference with alias.
  static String rawTableReference({
    required String tableName,
    required String alias,
    required String Function(String identifier) quoteIdentifier,
  }) {
    return '${quoteIdentifier(tableName)} AS ${quoteIdentifier(alias)}';
  }

  /// Builds a qualified raw field reference.
  static String qualifiedRawField({
    required String alias,
    required String fieldName,
    required String Function(String identifier) quoteIdentifier,
  }) {
    return '${quoteIdentifier(alias)}.${quoteIdentifier(fieldName)}';
  }

  /// Resolves a mapped database table name for a runtime model.
  static String mappedTableName({
    required RuntimeSchemaView schema,
    required String model,
  }) {
    return requireModelDefinition(schema: schema, model: model).databaseName;
  }

  /// Builds a quoted column identifier from logical model and field names.
  static String columnIdentifier({
    required RuntimeSchemaView schema,
    required String model,
    required String field,
    required String Function(String identifier) quoteIdentifier,
  }) {
    final fieldDefinition = requireModelDefinition(
      schema: schema,
      model: model,
    ).findField(field);
    return quoteIdentifier(fieldDefinition?.databaseName ?? field);
  }

  /// Builds a table reference for a logical model and alias.
  static String tableReference({
    required RuntimeSchemaView schema,
    required String model,
    required String alias,
    required String Function(String identifier) quoteIdentifier,
  }) {
    return rawTableReference(
      tableName: mappedTableName(schema: schema, model: model),
      alias: alias,
      quoteIdentifier: quoteIdentifier,
    );
  }

  /// Builds a qualified field reference for a logical model field.
  static String qualifiedField({
    required RuntimeSchemaView schema,
    required String alias,
    required String model,
    required String field,
    required String Function(String identifier) quoteIdentifier,
  }) {
    return '${quoteIdentifier(alias)}.${columnIdentifier(schema: schema, model: model, field: field, quoteIdentifier: quoteIdentifier)}';
  }

  /// Converts a raw SQLite row into a logical record map.
  static Map<String, Object?> selectedRowRecord({
    required RuntimeSchemaView schema,
    required String model,
    required Iterable<String> columns,
    required Object? Function(String column) valueForColumn,
    required Object? Function(String model, String field, Object? value)
    normalizeValueFromStorage,
    required String rowIdColumn,
  }) {
    final record = <String, Object?>{};
    final modelDefinition = requireModelDefinition(
      schema: schema,
      model: model,
    );
    for (final column in columns) {
      if (column == rowIdColumn) {
        continue;
      }
      final logicalField =
          modelDefinition.findFieldByDatabaseName(column)?.name ?? column;
      record[logicalField] = normalizeValueFromStorage(
        model,
        logicalField,
        valueForColumn(column),
      );
    }
    return record;
  }

  /// Selects the base scalar fields for a materialized record before includes are resolved.
  static Map<String, Object?> selectMaterializedRecordFields({
    required Map<String, Object?> record,
    required QuerySelect? select,
  }) {
    final base = <String, Object?>{};
    if (select == null || select.fields.isEmpty) {
      base.addAll(record);
      return base;
    }

    for (final field in select.fields) {
      if (record.containsKey(field)) {
        base[field] = record[field];
      }
    }
    return base;
  }

  /// Builds direct relation equality predicates for include loading.
  static List<QueryPredicate>? buildDirectRelationWherePredicates({
    required Map<String, Object?> sourceRecord,
    required QueryRelation relation,
  }) {
    if (!recordContainsAllRelationKeyFields(
      record: sourceRecord,
      fields: relation.localKeyFields,
    )) {
      return null;
    }

    final wherePredicates = <QueryPredicate>[];
    for (var index = 0; index < relation.targetKeyFields.length; index++) {
      wherePredicates.add(
        QueryPredicate(
          field: relation.targetKeyFields[index],
          operator: 'equals',
          value: sourceRecord[relation.localKeyFields[index]],
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(wherePredicates);
  }

  /// Normalizes included relation results to either a single object, null, or a list.
  static Object? finalizeIncludedRelationResult({
    required QueryRelation relation,
    required List<Map<String, Object?>> materialized,
  }) {
    if (relation.cardinality == QueryRelationCardinality.one) {
      if (materialized.isEmpty) {
        return null;
      }
      return materialized.first;
    }
    return List<Map<String, Object?>>.unmodifiable(materialized);
  }

  /// Builds the row lookup query used to reload a record by SQLite `rowid`.
  static SqliteSqlClause buildSelectRowByRowIdQuery({
    required RuntimeSchemaView schema,
    required String model,
    required int rowId,
    required String rowIdColumn,
    required String Function(String identifier) quoteIdentifier,
  }) {
    return (
      sql:
          'SELECT rowid AS ${quoteIdentifier(rowIdColumn)}, * '
          'FROM ${quoteIdentifier(mappedTableName(schema: schema, model: model))} '
          'WHERE rowid = ?',
      parameters: <Object?>[rowId],
    );
  }

  /// Builds the insert SQL and parameters for a logical model record.
  static SqliteSqlClause buildInsertRecordQuery({
    required RuntimeSchemaView schema,
    required String model,
    required Map<String, Object?> data,
    required String Function(String identifier) quoteIdentifier,
    required Object? Function(String model, String field, Object? value)
    normalizeValueForStorage,
  }) {
    final entries = data.entries.toList(growable: false);
    if (entries.isEmpty) {
      return (
        sql:
            'INSERT INTO ${quoteIdentifier(mappedTableName(schema: schema, model: model))} DEFAULT VALUES',
        parameters: const <Object?>[],
      );
    }

    final columns = entries
        .map(
          (entry) => columnIdentifier(
            schema: schema,
            model: model,
            field: entry.key,
            quoteIdentifier: quoteIdentifier,
          ),
        )
        .join(', ');
    final placeholders = List<String>.filled(entries.length, '?').join(', ');
    final parameters = entries
        .map((entry) => normalizeValueForStorage(model, entry.key, entry.value))
        .toList(growable: false);

    return (
      sql:
          'INSERT INTO ${quoteIdentifier(mappedTableName(schema: schema, model: model))} ($columns) VALUES ($placeholders)',
      parameters: parameters,
    );
  }
}
