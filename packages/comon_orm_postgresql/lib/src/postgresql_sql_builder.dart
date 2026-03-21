import 'package:comon_orm/comon_orm.dart';

/// Callback used to build relation-filter clauses from the adapter.
typedef PostgresqlRelationClauseBuilder =
    PostgresqlSqlClause Function(
      PostgresqlSqlBuildContext context,
      String sourceModel,
      String sourceAlias,
      String operator,
      QueryRelationFilter filter,
    );

/// Builds PostgreSQL WHERE and ORDER BY SQL fragments for query execution.
class PostgresqlSqlBuilder {
  /// Creates a PostgreSQL SQL builder backed by adapter-owned callbacks.
  const PostgresqlSqlBuilder({
    required this.buildRelationClause,
    required this.normalizeValueForStorage,
    required this.parameterWithCast,
    required this.qualifiedField,
  });

  /// Builds provider-specific SQL for relation predicates.
  final PostgresqlRelationClauseBuilder buildRelationClause;

  /// Normalizes Dart values before they are sent to PostgreSQL.
  final Object? Function(String model, String field, Object? value)
  normalizeValueForStorage;

  /// Applies PostgreSQL type casts to placeholders where needed.
  final String Function(String model, String field, String placeholder)
  parameterWithCast;

  /// Resolves a fully-qualified field reference.
  final String Function(String alias, String model, String field)
  qualifiedField;

  /// Builds a WHERE clause for [predicates].
  PostgresqlSqlClause buildWhereClause(
    PostgresqlSqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    if (predicates.isEmpty) {
      return const PostgresqlSqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }

    final clauses = predicates
        .map(
          (predicate) =>
              _buildPredicateClause(context, model, alias, predicate),
        )
        .toList(growable: false);
    return _joinClauses(clauses, 'AND');
  }

  /// Builds an ORDER BY clause for [orderBy].
  String buildOrderByClause(
    String alias,
    String model,
    List<QueryOrderBy> orderBy,
  ) {
    return orderBy
        .map(
          (entry) =>
              '${qualifiedField(alias, model, entry.field)} ${entry.direction == SortOrder.asc ? 'ASC' : 'DESC'}',
        )
        .join(', ');
  }

  PostgresqlSqlClause _buildPredicateClause(
    PostgresqlSqlBuildContext context,
    String model,
    String alias,
    QueryPredicate predicate,
  ) {
    switch (predicate.operator) {
      case 'logicalAnd':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const PostgresqlSqlClause(
            sql: '1 = 1',
            parameters: <Object?>[],
          );
        }
        return _joinClauses(
          group.branches
              .map((branch) => buildWhereClause(context, model, alias, branch))
              .toList(growable: false),
          'AND',
        );
      case 'logicalOr':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const PostgresqlSqlClause(
            sql: '1 = 0',
            parameters: <Object?>[],
          );
        }
        return _joinClauses(
          group.branches
              .map((branch) => buildWhereClause(context, model, alias, branch))
              .toList(growable: false),
          'OR',
        );
      case 'logicalNot':
        final group = predicate.value as QueryLogicalGroup;
        if (group.branches.isEmpty) {
          return const PostgresqlSqlClause(
            sql: '1 = 1',
            parameters: <Object?>[],
          );
        }
        final negated = group.branches
            .map((branch) => buildWhereClause(context, model, alias, branch))
            .map(
              (branchClause) => PostgresqlSqlClause(
                sql: 'NOT (${branchClause.sql})',
                parameters: branchClause.parameters,
              ),
            )
            .toList(growable: false);
        return _joinClauses(negated, 'AND');
      case 'relationSome':
      case 'relationNone':
      case 'relationEvery':
      case 'relationIs':
      case 'relationIsNot':
        return buildRelationClause(
          context,
          model,
          alias,
          predicate.operator,
          predicate.value as QueryRelationFilter,
        );
      case 'equals':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '=',
          predicate.value,
          model,
        );
      case 'not':
        if (predicate.value == null) {
          return PostgresqlSqlClause(
            sql: '${qualifiedField(alias, model, predicate.field)} IS NOT NULL',
            parameters: const <Object?>[],
          );
        }
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '!=',
          predicate.value,
          model,
        );
      case 'contains':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}%',
          model,
        );
      case 'startsWith':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '${predicate.value}%',
          model,
        );
      case 'endsWith':
        return _stringPatternClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}',
          model,
        );
      case 'containsInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}%',
          model,
        );
      case 'startsWithInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '${predicate.value}%',
          model,
        );
      case 'endsWithInsensitive':
        return _ilikeClause(
          context,
          alias,
          predicate.field,
          '%${predicate.value}',
          model,
        );
      case 'in':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return const PostgresqlSqlClause(
            sql: '1 = 0',
            parameters: <Object?>[],
          );
        }
        final parameters = <Object?>[];
        final placeholders = <String>[];
        for (final value in values) {
          final placeholder = context.nextParameter();
          placeholders.add(
            parameterWithCast(model, predicate.field, placeholder),
          );
          parameters.add(
            normalizeValueForStorage(model, predicate.field, value),
          );
        }
        return PostgresqlSqlClause(
          sql:
              '${qualifiedField(alias, model, predicate.field)} IN (${placeholders.join(', ')})',
          parameters: parameters,
        );
      case 'notIn':
        final values = predicate.value as List<Object?>;
        if (values.isEmpty) {
          return const PostgresqlSqlClause(
            sql: '1 = 1',
            parameters: <Object?>[],
          );
        }
        final parameters = <Object?>[];
        final placeholders = <String>[];
        for (final value in values) {
          final placeholder = context.nextParameter();
          placeholders.add(
            parameterWithCast(model, predicate.field, placeholder),
          );
          parameters.add(
            normalizeValueForStorage(model, predicate.field, value),
          );
        }
        return PostgresqlSqlClause(
          sql:
              '${qualifiedField(alias, model, predicate.field)} NOT IN (${placeholders.join(', ')})',
          parameters: parameters,
        );
      case 'gt':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '>',
          predicate.value,
          model,
        );
      case 'gte':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '>=',
          predicate.value,
          model,
        );
      case 'lt':
        return _binaryClause(
          context,
          alias,
          predicate.field,
          '<',
          predicate.value,
          model,
        );
      case 'lte':
        return _binaryClause(
          context,
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

  PostgresqlSqlClause _binaryClause(
    PostgresqlSqlBuildContext context,
    String alias,
    String field,
    String operator,
    Object? value,
    String model,
  ) {
    if (value == null && operator == '=') {
      return PostgresqlSqlClause(
        sql: '${qualifiedField(alias, model, field)} IS NULL',
        parameters: const <Object?>[],
      );
    }

    final placeholder = context.nextParameter();
    return PostgresqlSqlClause(
      sql:
          '${qualifiedField(alias, model, field)} $operator ${parameterWithCast(model, field, placeholder)}',
      parameters: <Object?>[normalizeValueForStorage(model, field, value)],
    );
  }

  PostgresqlSqlClause _stringPatternClause(
    PostgresqlSqlBuildContext context,
    String alias,
    String field,
    String pattern,
    String model,
  ) {
    final placeholder = context.nextParameter();
    return PostgresqlSqlClause(
      sql: '${qualifiedField(alias, model, field)} LIKE $placeholder',
      parameters: <Object?>[normalizeValueForStorage(model, field, pattern)],
    );
  }

  PostgresqlSqlClause _ilikeClause(
    PostgresqlSqlBuildContext context,
    String alias,
    String field,
    String pattern,
    String model,
  ) {
    final placeholder = context.nextParameter();
    return PostgresqlSqlClause(
      sql: '${qualifiedField(alias, model, field)} ILIKE $placeholder',
      parameters: <Object?>[normalizeValueForStorage(model, field, pattern)],
    );
  }

  PostgresqlSqlClause _joinClauses(
    List<PostgresqlSqlClause> clauses,
    String glue,
  ) {
    if (clauses.isEmpty) {
      return const PostgresqlSqlClause(sql: '1 = 1', parameters: <Object?>[]);
    }

    return PostgresqlSqlClause(
      sql: clauses.map((clause) => '(${clause.sql})').join(' $glue '),
      parameters: clauses
          .expand((clause) => clause.parameters)
          .toList(growable: false),
    );
  }
}

/// Mutable context shared while building nested PostgreSQL SQL fragments.
class PostgresqlSqlBuildContext {
  int _aliasCounter = 0;
  int _parameterCounter = 0;

  /// Returns the next generated table alias.
  String nextAlias() => 't${_aliasCounter++}';

  /// Returns the next positional parameter placeholder.
  String nextParameter() => '\$${++_parameterCounter}';
}

/// SQL fragment plus its ordered PostgreSQL parameters.
class PostgresqlSqlClause {
  /// Creates a PostgreSQL SQL fragment.
  const PostgresqlSqlClause({required this.sql, required this.parameters});

  /// SQL text for the fragment.
  final String sql;

  /// Positional parameters for the fragment.
  final List<Object?> parameters;
}
