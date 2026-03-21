import 'package:comon_orm/comon_orm.dart';

/// Callback used to build relation-filter clauses from the SQLite adapter.
typedef SqliteRelationClauseBuilder =
    SqliteSqlClause Function(
      SqliteSqlBuildContext context,
      String sourceModel,
      String sourceAlias,
      String operator,
      QueryRelationFilter filter,
    );

/// Builds SQLite WHERE and ORDER BY SQL fragments for query execution.
class SqliteSqlBuilder {
  /// Creates a SQLite SQL builder backed by adapter-owned callbacks.
  const SqliteSqlBuilder({
    required this.buildRelationClause,
    required this.qualifiedField,
    required this.normalizeValueForStorage,
  });

  /// Builds provider-specific SQL for relation predicates.
  final SqliteRelationClauseBuilder buildRelationClause;

  /// Resolves a fully-qualified field reference.
  final String Function(String alias, String model, String field)
  qualifiedField;

  /// Normalizes Dart values before they are sent to SQLite.
  final Object? Function(String model, String field, Object? value)
  normalizeValueForStorage;

  /// Builds a WHERE clause for [predicates].
  SqliteSqlClause buildWhereClause(
    SqliteSqlBuildContext context,
    String model,
    String alias,
    List<QueryPredicate> predicates,
  ) {
    final clause = SqliteQuerySupport.buildWhereClause(
      model: model,
      alias: alias,
      predicates: predicates,
      buildPredicateClause: (innerModel, innerAlias, predicate) {
        final built = _buildPredicateClause(
          context,
          innerModel,
          innerAlias,
          predicate,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
    );
    return (sql: clause.sql, parameters: clause.parameters);
  }

  /// Builds an ORDER BY clause for [orderBy].
  String buildOrderByClause(
    String alias,
    String model,
    List<QueryOrderBy> orderBy,
  ) {
    return SqliteQuerySupport.buildOrderByClause(
      alias: alias,
      model: model,
      orderBy: orderBy,
      qualifiedField: qualifiedField,
    );
  }

  SqliteSqlClause _buildPredicateClause(
    SqliteSqlBuildContext context,
    String model,
    String alias,
    QueryPredicate predicate,
  ) {
    final clause = SqliteQuerySupport.buildPredicateClause(
      model: model,
      alias: alias,
      predicate: predicate,
      buildWhereClause: (innerModel, innerAlias, predicates) {
        final built = buildWhereClause(
          context,
          innerModel,
          innerAlias,
          predicates,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      buildRelationClause: (sourceModel, sourceAlias, operator, filter) {
        final built = buildRelationClause(
          context,
          sourceModel,
          sourceAlias,
          operator,
          filter,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      buildBinaryClause: (innerAlias, field, operator, value, innerModel) {
        final built = _binaryClause(
          innerAlias,
          field,
          operator,
          value,
          innerModel,
        );
        return (sql: built.sql, parameters: built.parameters);
      },
      qualifiedField: qualifiedField,
      normalizeValueForStorage: normalizeValueForStorage,
    );
    return (sql: clause.sql, parameters: clause.parameters);
  }

  SqliteSqlClause _binaryClause(
    String alias,
    String field,
    String operator,
    Object? value,
    String model,
  ) {
    final clause = SqliteQuerySupport.buildBinaryClause(
      alias: alias,
      field: field,
      operator: operator,
      value: value,
      model: model,
      qualifiedField: qualifiedField,
      normalizeValueForStorage: normalizeValueForStorage,
    );
    return (sql: clause.sql, parameters: clause.parameters);
  }
}

/// Mutable context shared while building nested SQLite SQL fragments.
class SqliteSqlBuildContext {
  int _aliasCounter = 0;

  /// Returns the next generated table alias.
  String nextAlias() => 't${_aliasCounter++}';
}
