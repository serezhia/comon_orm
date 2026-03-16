import 'dart:async';

// ignore_for_file: library_private_types_in_public_api

import '../runtime_metadata/generated_runtime_schema.dart';
import '../runtime_metadata/runtime_schema_view.dart';
import '../schema/schema_ast.dart';
import '../client/query_aggregates.dart';
import '../client/query_models.dart';

/// Backend contract used by generated clients and low-level query delegates.
abstract interface class DatabaseAdapter {
  /// Returns every record that matches [query].
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query);

  /// Returns the single record uniquely matched by [query], if any.
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query);

  /// Returns the first record matched by [query], if any.
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query);

  /// Counts records matched by [query].
  Future<int> count(CountQuery query);

  /// Computes aggregate values for [query].
  Future<AggregateQueryResult> aggregate(AggregateQuery query);

  /// Groups records according to [query] and returns aggregate rows.
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query);

  /// Creates and returns a single record described by [query].
  Future<Map<String, Object?>> create(CreateQuery query);

  /// Adds an implicit many-to-many link for [relation].
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  });

  /// Removes implicit many-to-many links for [relation].
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  });

  /// Updates and returns a single record described by [query].
  Future<Map<String, Object?>> update(UpdateQuery query);

  /// Updates every record matched by [query].
  Future<int> updateMany(UpdateManyQuery query);

  /// Deletes and returns a single record described by [query].
  Future<Map<String, Object?>> delete(DeleteQuery query);

  /// Deletes every record matched by [query].
  Future<int> deleteMany(DeleteManyQuery query);

  /// Runs [action] inside a backend transaction.
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action);

  /// Releases resources owned by the adapter.
  FutureOr<void> close();
}

/// In-memory adapter intended for tests, examples, and local experimentation.
class InMemoryDatabaseAdapter implements DatabaseAdapter {
  /// Creates an in-memory adapter backed by optional seeded state.
  InMemoryDatabaseAdapter({
    Map<String, List<Map<String, Object?>>>? store,
    Map<String, List<_RelationLink>>? relationLinks,
    SchemaDocument? schema,
    RuntimeSchemaView? runtimeSchema,
  }) : _store = store ?? <String, List<Map<String, Object?>>>{},
       _relationLinks = relationLinks ?? <String, List<_RelationLink>>{},
       _schema =
           runtimeSchema ??
           (schema == null
               ? null
               : runtimeSchemaViewFromSchemaDocument(schema));

  /// Creates an in-memory adapter backed by runtime schema metadata.
  InMemoryDatabaseAdapter.fromRuntimeSchema({
    Map<String, List<Map<String, Object?>>>? store,
    Map<String, List<_RelationLink>>? relationLinks,
    required RuntimeSchemaView schema,
  }) : _store = store ?? <String, List<Map<String, Object?>>>{},
       _relationLinks = relationLinks ?? <String, List<_RelationLink>>{},
       _schema = schema;

  /// Creates an in-memory adapter backed by generated runtime metadata.
  factory InMemoryDatabaseAdapter.fromGeneratedSchema({
    Map<String, List<Map<String, Object?>>>? store,
    Map<String, List<_RelationLink>>? relationLinks,
    required GeneratedRuntimeSchema schema,
  }) {
    return InMemoryDatabaseAdapter.fromRuntimeSchema(
      store: store,
      relationLinks: relationLinks,
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
    );
  }

  final Map<String, List<Map<String, Object?>>> _store;
  final Map<String, List<_RelationLink>> _relationLinks;
  final RuntimeSchemaView? _schema;

  /// Clock used for automatically populated values such as `@updatedAt`.
  DateTime Function() now = () => DateTime.now().toUtc();

  @override
  void close() {}

  @override
  Future<Map<String, Object?>> create(CreateQuery query) async {
    return transaction((tx) async {
      final adapter = tx as InMemoryDatabaseAdapter;
      final records = adapter._store.putIfAbsent(
        query.model,
        () => <Map<String, Object?>>[],
      );
      final nextRecord = adapter._applyAutomaticFieldValues(
        query.model,
        query.data,
        isCreate: true,
      );
      adapter._assignAutoId(query.model, nextRecord);
      records.add(nextRecord);

      for (final nestedWrite in query.nestedCreates) {
        final parentKeyValues = adapter._extractRequiredKeyValues(
          nextRecord,
          nestedWrite.relation.localKeyFields,
          model: query.model,
          relation: nestedWrite.relation,
          role: 'parent',
        );

        for (final nestedRecord in nestedWrite.records) {
          final childRecord = adapter._applyAutomaticFieldValues(
            nestedWrite.relation.targetModel,
            nestedRecord,
            isCreate: true,
          );

          if (nestedWrite.relation.storageKind ==
              QueryRelationStorageKind.direct) {
            for (
              var index = 0;
              index < nestedWrite.relation.targetKeyFields.length;
              index++
            ) {
              childRecord[nestedWrite.relation.targetKeyFields[index]] =
                  parentKeyValues[nestedWrite.relation.localKeyFields[index]];
            }
          }

          adapter._assignAutoId(nestedWrite.relation.targetModel, childRecord);
          adapter._store
              .putIfAbsent(
                nestedWrite.relation.targetModel,
                () => <Map<String, Object?>>[],
              )
              .add(childRecord);

          if (nestedWrite.relation.storageKind ==
              QueryRelationStorageKind.implicitManyToMany) {
            final childKeyValues = adapter._extractRequiredKeyValues(
              childRecord,
              nestedWrite.relation.targetKeyFields,
              model: nestedWrite.relation.targetModel,
              relation: nestedWrite.relation,
              role: 'child',
            );

            adapter._addImplicitManyToManyLink(
              relation: nestedWrite.relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: childKeyValues,
            );
          }
        }
      }

      final materialized = adapter._materializeRecord(
        query.model,
        nextRecord,
        include: query.include,
        select: null,
      );
      return Map<String, Object?>.unmodifiable(materialized);
    });
  }

  @override
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) async {
    _addImplicitManyToManyLink(
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  @override
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) async {
    return _removeImplicitManyToManyLinks(
      relation: relation,
      sourceKeyValues: sourceKeyValues,
      targetKeyValues: targetKeyValues,
    );
  }

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    final ordered = _applyWhereAndOrderBy(records, query.where, query.orderBy);
    final distinct = applyDistinctRecords(ordered, query.distinct);
    final skipped = query.skip == null ? distinct : distinct.skip(query.skip!);
    final taken = query.take == null ? skipped : skipped.take(query.take!);

    return taken
        .map(
          (record) => Map<String, Object?>.unmodifiable(
            _materializeRecord(
              query.model,
              record,
              include: query.include,
              select: query.select,
            ),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    for (final record in records) {
      if (_matchesWhere(record, query.where)) {
        return Map<String, Object?>.unmodifiable(
          _materializeRecord(
            query.model,
            record,
            include: query.include,
            select: query.select,
          ),
        );
      }
    }

    return null;
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    final ordered = _applyWhereAndOrderBy(records, query.where, query.orderBy);
    final distinct = applyDistinctRecords(ordered, query.distinct);
    final skipped = query.skip == null ? distinct : distinct.skip(query.skip!);
    for (final record in skipped) {
      return Map<String, Object?>.unmodifiable(
        _materializeRecord(
          query.model,
          record,
          include: query.include,
          select: query.select,
        ),
      );
    }

    return null;
  }

  @override
  Future<int> count(CountQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    return records.where((record) => _matchesWhere(record, query.where)).length;
  }

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    final ordered = _applyWhereAndOrderBy(
      records,
      query.where,
      query.orderBy,
    ).toList(growable: false);
    final skipped = query.skip == null ? ordered : ordered.skip(query.skip!);
    final taken = query.take == null ? skipped : skipped.take(query.take!);
    return computeAggregateQueryResult(taken, query);
  }

  @override
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) async {
    final records = _store[query.model] ?? const <Map<String, Object?>>[];
    final filtered = records
        .where((record) => _matchesWhere(record, query.where))
        .toList(growable: false);
    return computeGroupByQueryResultRows(filtered, query);
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) async {
    return transaction((tx) async {
      final adapter = tx as InMemoryDatabaseAdapter;
      final records = adapter._store[query.model] ?? <Map<String, Object?>>[];
      final updateData = adapter._applyAutomaticFieldValues(
        query.model,
        query.data,
        isCreate: false,
      );

      for (var index = 0; index < records.length; index++) {
        final record = records[index];
        if (!_matchesWhere(record, query.where)) {
          continue;
        }

        final updated = Map<String, Object?>.from(record)..addAll(updateData);
        records[index] = updated;
        return Map<String, Object?>.unmodifiable(
          adapter._materializeRecord(
            query.model,
            updated,
            include: query.include,
            select: query.select,
          ),
        );
      }

      throw StateError('No record found for update in ${query.model}.');
    });
  }

  @override
  Future<int> updateMany(UpdateManyQuery query) async {
    return transaction((tx) async {
      final adapter = tx as InMemoryDatabaseAdapter;
      final records = adapter._store[query.model] ?? <Map<String, Object?>>[];
      var updatedCount = 0;
      final updateData = adapter._applyAutomaticFieldValues(
        query.model,
        query.data,
        isCreate: false,
      );

      for (var index = 0; index < records.length; index++) {
        final record = records[index];
        if (!_matchesWhere(record, query.where)) {
          continue;
        }

        records[index] = Map<String, Object?>.from(record)..addAll(updateData);
        updatedCount++;
      }

      return updatedCount;
    });
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) async {
    return transaction((tx) async {
      final adapter = tx as InMemoryDatabaseAdapter;
      final records = adapter._store[query.model] ?? <Map<String, Object?>>[];

      for (var index = 0; index < records.length; index++) {
        final record = records[index];
        if (!_matchesWhere(record, query.where)) {
          continue;
        }

        final deleted = Map<String, Object?>.from(record);
        records.removeAt(index);
        return Map<String, Object?>.unmodifiable(
          adapter._materializeRecord(
            query.model,
            deleted,
            include: query.include,
            select: query.select,
          ),
        );
      }

      throw StateError('No record found for delete in ${query.model}.');
    });
  }

  @override
  Future<int> deleteMany(DeleteManyQuery query) async {
    return transaction((tx) async {
      final adapter = tx as InMemoryDatabaseAdapter;
      final records = adapter._store[query.model] ?? <Map<String, Object?>>[];
      final retained = <Map<String, Object?>>[];
      var deletedCount = 0;

      for (final record in records) {
        if (_matchesWhere(record, query.where)) {
          deletedCount++;
          continue;
        }
        retained.add(record);
      }

      adapter._store[query.model] = retained;
      return deletedCount;
    });
  }

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action) {
    final snapshot = <String, List<Map<String, Object?>>>{
      for (final entry in _store.entries)
        entry.key: entry.value
            .map((record) => Map<String, Object?>.from(record))
            .toList(),
    };
    final transactionalAdapter = InMemoryDatabaseAdapter(
      store: snapshot,
      relationLinks: {
        for (final entry in _relationLinks.entries)
          entry.key: entry.value
              .map(
                (link) => _RelationLink(
                  sourceKeyValues: Map<String, Object?>.from(
                    link.sourceKeyValues,
                  ),
                  targetKeyValues: Map<String, Object?>.from(
                    link.targetKeyValues,
                  ),
                ),
              )
              .toList(),
      },
      runtimeSchema: _schema,
    )..now = now;

    return action(transactionalAdapter).then((value) {
      _store
        ..clear()
        ..addAll(snapshot);
      _relationLinks
        ..clear()
        ..addAll({
          for (final entry in transactionalAdapter._relationLinks.entries)
            entry.key: entry.value
                .map(
                  (link) => _RelationLink(
                    sourceKeyValues: Map<String, Object?>.from(
                      link.sourceKeyValues,
                    ),
                    targetKeyValues: Map<String, Object?>.from(
                      link.targetKeyValues,
                    ),
                  ),
                )
                .toList(),
        });
      return value;
    });
  }

  Map<String, Object?> _applyAutomaticFieldValues(
    String model,
    Map<String, Object?> data, {
    required bool isCreate,
  }) {
    final nextData = Map<String, Object?>.from(data);
    final timestamp = now();

    for (final field in _updatedAtFields(model)) {
      if (isCreate) {
        nextData.putIfAbsent(field.name, () => timestamp);
      } else {
        nextData[field.name] = timestamp;
      }
    }

    return nextData;
  }

  Iterable<RuntimeFieldView> _updatedAtFields(String model) {
    final modelDefinition = _schema?.findModel(model);
    if (modelDefinition == null) {
      return const <RuntimeFieldView>[];
    }

    return modelDefinition.fields.where((field) => field.isUpdatedAt);
  }

  Iterable<Map<String, Object?>> _applyWhereAndOrderBy(
    List<Map<String, Object?>> records,
    List<QueryPredicate> where,
    List<QueryOrderBy> orderBy,
  ) {
    final filtered = records
        .where((record) => _matchesWhere(record, where))
        .toList(growable: true);

    if (orderBy.isEmpty) {
      return filtered;
    }

    filtered.sort((left, right) => _compareRecords(left, right, orderBy));
    return filtered;
  }

  int _compareRecords(
    Map<String, Object?> left,
    Map<String, Object?> right,
    List<QueryOrderBy> orderBy,
  ) {
    for (final ordering in orderBy) {
      final comparison = _compareValues(
        left[ordering.field],
        right[ordering.field],
      );
      if (comparison == 0) {
        continue;
      }

      return ordering.direction == SortOrder.asc ? comparison : -comparison;
    }

    return 0;
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

  bool _matchesWhere(
    Map<String, Object?> record,
    List<QueryPredicate> predicates,
  ) {
    for (final predicate in predicates) {
      switch (predicate.operator) {
        case 'logicalAnd':
          if (predicate.value is! QueryLogicalGroup) {
            return false;
          }
          if (!_matchesLogicalAnd(
            record,
            predicate.value! as QueryLogicalGroup,
          )) {
            return false;
          }
        case 'logicalOr':
          if (predicate.value is! QueryLogicalGroup) {
            return false;
          }
          if (!_matchesLogicalOr(
            record,
            predicate.value! as QueryLogicalGroup,
          )) {
            return false;
          }
        case 'logicalNot':
          if (predicate.value is! QueryLogicalGroup) {
            return false;
          }
          if (!_matchesLogicalNot(
            record,
            predicate.value! as QueryLogicalGroup,
          )) {
            return false;
          }
        case 'relationSome':
          if (predicate.value is! QueryRelationFilter) {
            return false;
          }
          if (!_matchesRelationSome(
            record,
            predicate.value! as QueryRelationFilter,
          )) {
            return false;
          }
        case 'relationNone':
          if (predicate.value is! QueryRelationFilter) {
            return false;
          }
          if (!_matchesRelationNone(
            record,
            predicate.value! as QueryRelationFilter,
          )) {
            return false;
          }
        case 'relationEvery':
          if (predicate.value is! QueryRelationFilter) {
            return false;
          }
          if (!_matchesRelationEvery(
            record,
            predicate.value! as QueryRelationFilter,
          )) {
            return false;
          }
        case 'relationIs':
          if (predicate.value is! QueryRelationFilter) {
            return false;
          }
          if (!_matchesRelationIs(
            record,
            predicate.value! as QueryRelationFilter,
          )) {
            return false;
          }
        case 'relationIsNot':
          if (predicate.value is! QueryRelationFilter) {
            return false;
          }
          if (!_matchesRelationIsNot(
            record,
            predicate.value! as QueryRelationFilter,
          )) {
            return false;
          }
        case 'equals':
          final candidate = record[predicate.field];
          if (candidate != predicate.value) {
            return false;
          }
        case 'not':
          final candidate = record[predicate.field];
          if (candidate == predicate.value) {
            return false;
          }
        case 'contains':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.contains(predicate.value! as String)) {
            return false;
          }
        case 'startsWith':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.startsWith(predicate.value! as String)) {
            return false;
          }
        case 'endsWith':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.endsWith(predicate.value! as String)) {
            return false;
          }
        case 'containsInsensitive':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.toLowerCase().contains(
            (predicate.value! as String).toLowerCase(),
          )) {
            return false;
          }
        case 'startsWithInsensitive':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.toLowerCase().startsWith(
            (predicate.value! as String).toLowerCase(),
          )) {
            return false;
          }
        case 'endsWithInsensitive':
          final candidate = record[predicate.field];
          if (candidate is! String || predicate.value is! String) {
            return false;
          }
          if (!candidate.toLowerCase().endsWith(
            (predicate.value! as String).toLowerCase(),
          )) {
            return false;
          }
        case 'in':
          final candidate = record[predicate.field];
          if (predicate.value is! List<Object?>) {
            return false;
          }
          if (!(predicate.value! as List<Object?>).contains(candidate)) {
            return false;
          }
        case 'notIn':
          final candidate = record[predicate.field];
          if (predicate.value is! List<Object?>) {
            return false;
          }
          if ((predicate.value! as List<Object?>).contains(candidate)) {
            return false;
          }
        case 'gt':
          if (!_compareNumber(
            record[predicate.field],
            predicate.value,
            (left, right) => left > right,
          )) {
            return false;
          }
        case 'gte':
          if (!_compareNumber(
            record[predicate.field],
            predicate.value,
            (left, right) => left >= right,
          )) {
            return false;
          }
        case 'lt':
          if (!_compareNumber(
            record[predicate.field],
            predicate.value,
            (left, right) => left < right,
          )) {
            return false;
          }
        case 'lte':
          if (!_compareNumber(
            record[predicate.field],
            predicate.value,
            (left, right) => left <= right,
          )) {
            return false;
          }
        default:
          return false;
      }
    }

    return true;
  }

  bool _matchesLogicalAnd(
    Map<String, Object?> record,
    QueryLogicalGroup group,
  ) {
    for (final branch in group.branches) {
      if (!_matchesWhere(record, branch)) {
        return false;
      }
    }

    return true;
  }

  bool _matchesLogicalOr(Map<String, Object?> record, QueryLogicalGroup group) {
    if (group.branches.isEmpty) {
      return false;
    }

    for (final branch in group.branches) {
      if (_matchesWhere(record, branch)) {
        return true;
      }
    }

    return false;
  }

  bool _matchesLogicalNot(
    Map<String, Object?> record,
    QueryLogicalGroup group,
  ) {
    for (final branch in group.branches) {
      if (_matchesWhere(record, branch)) {
        return false;
      }
    }

    return true;
  }

  bool _matchesRelationSome(
    Map<String, Object?> record,
    QueryRelationFilter filter,
  ) {
    for (final relatedRecord in _relatedRecords(record, filter.relation)) {
      if (_matchesWhere(relatedRecord, filter.predicates)) {
        return true;
      }
    }

    return false;
  }

  bool _matchesRelationNone(
    Map<String, Object?> record,
    QueryRelationFilter filter,
  ) {
    for (final relatedRecord in _relatedRecords(record, filter.relation)) {
      if (_matchesWhere(relatedRecord, filter.predicates)) {
        return false;
      }
    }

    return true;
  }

  bool _matchesRelationIs(
    Map<String, Object?> record,
    QueryRelationFilter filter,
  ) {
    final relatedRecord = _singleRelatedRecord(record, filter.relation);
    if (relatedRecord == null) {
      return false;
    }

    return _matchesWhere(relatedRecord, filter.predicates);
  }

  bool _matchesRelationIsNot(
    Map<String, Object?> record,
    QueryRelationFilter filter,
  ) {
    final relatedRecord = _singleRelatedRecord(record, filter.relation);
    if (relatedRecord == null) {
      return true;
    }

    return !_matchesWhere(relatedRecord, filter.predicates);
  }

  Map<String, Object?>? _singleRelatedRecord(
    Map<String, Object?> record,
    QueryRelation relation,
  ) {
    for (final relatedRecord in _relatedRecords(record, relation)) {
      return relatedRecord;
    }

    return null;
  }

  bool _matchesRelationEvery(
    Map<String, Object?> record,
    QueryRelationFilter filter,
  ) {
    for (final relatedRecord in _relatedRecords(record, filter.relation)) {
      if (!_matchesWhere(relatedRecord, filter.predicates)) {
        return false;
      }
    }

    return true;
  }

  Iterable<Map<String, Object?>> _relatedRecords(
    Map<String, Object?> record,
    QueryRelation relation,
  ) {
    if (relation.storageKind == QueryRelationStorageKind.implicitManyToMany) {
      return _implicitManyToManyRelatedRecords(record, relation);
    }

    if (!_recordContainsAllFields(record, relation.localKeyFields)) {
      return const <Map<String, Object?>>[];
    }

    return (_store[relation.targetModel] ?? const <Map<String, Object?>>[])
        .where(
          (candidate) => _recordsMatchOnFields(
            left: record,
            leftFields: relation.localKeyFields,
            right: candidate,
            rightFields: relation.targetKeyFields,
          ),
        );
  }

  Iterable<Map<String, Object?>> _implicitManyToManyRelatedRecords(
    Map<String, Object?> record,
    QueryRelation relation,
  ) {
    if (!_recordContainsAllFields(record, relation.localKeyFields)) {
      return const <Map<String, Object?>>[];
    }

    final relatedRecords = <Map<String, Object?>>[];
    for (final link
        in _relationLinks[_relationLinkKey(relation)] ??
            const <_RelationLink>[]) {
      if (!_recordMatchesKeyValues(record, link.sourceKeyValues)) {
        continue;
      }

      for (final candidate
          in _store[relation.targetModel] ?? const <Map<String, Object?>>[]) {
        if (_recordMatchesKeyValues(candidate, link.targetKeyValues)) {
          relatedRecords.add(candidate);
          break;
        }
      }
    }

    return relatedRecords;
  }

  bool _compareNumber(
    Object? left,
    Object? right,
    bool Function(num left, num right) predicate,
  ) {
    if (left is! num || right is! num) {
      return false;
    }

    return predicate(left, right);
  }

  Map<String, Object?> _materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) {
    final base = <String, Object?>{};

    if (select == null || select.fields.isEmpty) {
      base.addAll(record);
    } else {
      for (final field in select.fields) {
        if (record.containsKey(field)) {
          base[field] = record[field];
        }
      }
    }

    if (include != null) {
      for (final entry in include.relations.entries) {
        base[entry.key] = _resolveInclude(model, record, entry.value);
      }
    }

    return base;
  }

  Object? _resolveInclude(
    String sourceModel,
    Map<String, Object?> sourceRecord,
    QueryIncludeEntry entry,
  ) {
    final targetRecords = _relatedRecords(sourceRecord, entry.relation)
        .map(
          (candidate) => Map<String, Object?>.unmodifiable(
            _materializeRecord(
              entry.relation.targetModel,
              candidate,
              include: entry.include,
              select: entry.select,
            ),
          ),
        )
        .toList(growable: false);

    if (entry.relation.cardinality == QueryRelationCardinality.one) {
      if (targetRecords.isEmpty) {
        return null;
      }

      return targetRecords.first;
    }

    return targetRecords;
  }

  void _assignAutoId(String model, Map<String, Object?> record) {
    if (record.containsKey('id') && record['id'] != null) {
      return;
    }

    final records = _store[model] ?? const <Map<String, Object?>>[];
    var maxId = 0;

    for (final existingRecord in records) {
      final existingId = existingRecord['id'];
      if (existingId is int && existingId > maxId) {
        maxId = existingId;
      }
    }
    record['id'] = maxId + 1;
  }

  void _addImplicitManyToManyLink({
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) {
    final forwardLinks = _relationLinks.putIfAbsent(
      _relationLinkKey(relation),
      () => <_RelationLink>[],
    );
    if (!forwardLinks.any(
      (link) =>
          _keyValuesEqual(link.sourceKeyValues, sourceKeyValues) &&
          _keyValuesEqual(link.targetKeyValues, targetKeyValues),
    )) {
      forwardLinks.add(
        _RelationLink(
          sourceKeyValues: Map<String, Object?>.unmodifiable(sourceKeyValues),
          targetKeyValues: Map<String, Object?>.unmodifiable(targetKeyValues),
        ),
      );
    }

    final reverseRelation = _reverseImplicitManyToManyRelation(relation);
    if (reverseRelation == null) {
      return;
    }

    final reverseLinks = _relationLinks.putIfAbsent(
      _relationLinkKey(reverseRelation),
      () => <_RelationLink>[],
    );
    if (!reverseLinks.any(
      (link) =>
          _keyValuesEqual(link.sourceKeyValues, targetKeyValues) &&
          _keyValuesEqual(link.targetKeyValues, sourceKeyValues),
    )) {
      reverseLinks.add(
        _RelationLink(
          sourceKeyValues: Map<String, Object?>.unmodifiable(targetKeyValues),
          targetKeyValues: Map<String, Object?>.unmodifiable(sourceKeyValues),
        ),
      );
    }
  }

  int _removeImplicitManyToManyLinks({
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) {
    final forwardLinks = _relationLinks[_relationLinkKey(relation)];
    if (forwardLinks == null || forwardLinks.isEmpty) {
      return 0;
    }

    final removedForward = <_RelationLink>[];
    forwardLinks.removeWhere((link) {
      final matchesSource = _keyValuesEqual(
        link.sourceKeyValues,
        sourceKeyValues,
      );
      final matchesTarget =
          targetKeyValues == null ||
          _keyValuesEqual(link.targetKeyValues, targetKeyValues);
      final shouldRemove = matchesSource && matchesTarget;
      if (shouldRemove) {
        removedForward.add(link);
      }
      return shouldRemove;
    });

    if (forwardLinks.isEmpty) {
      _relationLinks.remove(_relationLinkKey(relation));
    }

    if (removedForward.isEmpty) {
      return 0;
    }

    final reverseRelation = _reverseImplicitManyToManyRelation(relation);
    if (reverseRelation != null) {
      final reverseLinks = _relationLinks[_relationLinkKey(reverseRelation)];
      if (reverseLinks != null) {
        reverseLinks.removeWhere(
          (link) => removedForward.any(
            (removed) =>
                _keyValuesEqual(
                  link.sourceKeyValues,
                  removed.targetKeyValues,
                ) &&
                _keyValuesEqual(link.targetKeyValues, removed.sourceKeyValues),
          ),
        );
        if (reverseLinks.isEmpty) {
          _relationLinks.remove(_relationLinkKey(reverseRelation));
        }
      }
    }

    return removedForward.length;
  }

  QueryRelation? _reverseImplicitManyToManyRelation(QueryRelation relation) {
    if (relation.storageKind != QueryRelationStorageKind.implicitManyToMany ||
        relation.sourceModel == null ||
        relation.inverseField == null) {
      return null;
    }

    return QueryRelation(
      field: relation.inverseField!,
      targetModel: relation.sourceModel!,
      cardinality: QueryRelationCardinality.many,
      localKeyField: relation.targetKeyField,
      targetKeyField: relation.localKeyField,
      localKeyFields: relation.targetKeyFields,
      targetKeyFields: relation.localKeyFields,
      storageKind: QueryRelationStorageKind.implicitManyToMany,
      sourceModel: relation.targetModel,
      inverseField: relation.field,
    );
  }

  Map<String, Object?> _extractRequiredKeyValues(
    Map<String, Object?> record,
    List<String> fields, {
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

  bool _recordContainsAllFields(
    Map<String, Object?> record,
    List<String> fields,
  ) {
    for (final field in fields) {
      if (record[field] == null) {
        return false;
      }
    }
    return true;
  }

  bool _recordsMatchOnFields({
    required Map<String, Object?> left,
    required List<String> leftFields,
    required Map<String, Object?> right,
    required List<String> rightFields,
  }) {
    for (var index = 0; index < leftFields.length; index++) {
      if (left[leftFields[index]] != right[rightFields[index]]) {
        return false;
      }
    }
    return true;
  }

  bool _recordMatchesKeyValues(
    Map<String, Object?> record,
    Map<String, Object?> keyValues,
  ) {
    for (final entry in keyValues.entries) {
      if (record[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  bool _keyValuesEqual(Map<String, Object?> left, Map<String, Object?> right) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (right[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  String _relationLinkKey(QueryRelation relation) {
    if (relation.sourceModel == null) {
      throw StateError(
        'Implicit many-to-many relation ${relation.field} is missing sourceModel metadata.',
      );
    }

    return '${relation.sourceModel}.${relation.field}';
  }
}

class _RelationLink {
  const _RelationLink({
    required this.sourceKeyValues,
    required this.targetKeyValues,
  });

  final Map<String, Object?> sourceKeyValues;
  final Map<String, Object?> targetKeyValues;
}
