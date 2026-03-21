import 'package:comon_orm/comon_orm.dart';

/// Callback used to load rows for a standard relation lookup.
typedef PostgresqlSelectRows =
    Future<List<PostgresqlSelectedRow>> Function({
      required String model,
      required List<QueryPredicate> where,
      required List<QueryOrderBy> orderBy,
    });

/// Callback used to load rows for one implicit many-to-many parent record.
typedef PostgresqlSelectImplicitManyToManyRows =
    Future<List<PostgresqlSelectedRow>> Function({
      required String sourceModel,
      required Map<String, Object?> sourceRecord,
      required QueryRelation relation,
    });

/// Callback used to load rows for batched implicit many-to-many parent records.
typedef PostgresqlSelectImplicitManyToManyRowsBatch =
    Future<List<PostgresqlImplicitManyToManyBatchRow>> Function({
      required String sourceModel,
      required List<Map<String, Object?>> sourceRecords,
      required QueryRelation relation,
    });

/// Materializes selected PostgreSQL rows into include-aware runtime payloads.
class PostgresqlRelationMaterializer {
  /// Creates a materializer backed by adapter-owned row loading callbacks.
  const PostgresqlRelationMaterializer({
    required this.recordContainsAllRelationKeyFields,
    required this.selectImplicitManyToManyRows,
    required this.selectImplicitManyToManyRowsBatch,
    required this.selectRows,
  });

  /// Checks whether all local key fields needed for a relation are present.
  final bool Function(Map<String, Object?> record, List<String> fields)
  recordContainsAllRelationKeyFields;

  /// Loads implicit many-to-many rows for a single parent record.
  final PostgresqlSelectImplicitManyToManyRows selectImplicitManyToManyRows;

  /// Loads implicit many-to-many rows for a batch of parent records.
  final PostgresqlSelectImplicitManyToManyRowsBatch
  selectImplicitManyToManyRowsBatch;

  /// Loads rows for a standard relation query.
  final PostgresqlSelectRows selectRows;

  /// Materializes a single selected record with include/select projection.
  Future<Map<String, Object?>> materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    final base = _selectRecordFields(record, select);

    if (include != null) {
      for (final entry in include.relations.entries) {
        base[entry.key] = await resolveInclude(model, record, entry.value);
      }
    }

    return base;
  }

  /// Materializes a batch of selected records with include/select projection.
  Future<List<Map<String, Object?>>> materializeRecordsBatch(
    String model,
    List<Map<String, Object?>> rawRecords, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) async {
    if (rawRecords.isEmpty) {
      return const <Map<String, Object?>>[];
    }

    final results = rawRecords
        .map((raw) => _selectRecordFields(raw, select))
        .toList(growable: false);

    if (include == null) {
      return results;
    }

    for (final entry in include.relations.entries) {
      await _applyBatchInclude(
        model: model,
        rawRecords: rawRecords,
        results: results,
        includeKey: entry.key,
        entry: entry.value,
      );
    }

    return results;
  }

  /// Resolves a single include entry for [sourceRecord].
  Future<Object?> resolveInclude(
    String sourceModel,
    Map<String, Object?> sourceRecord,
    QueryIncludeEntry entry,
  ) async {
    if (entry.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      final relatedRows = await selectImplicitManyToManyRows(
        sourceModel: sourceModel,
        sourceRecord: sourceRecord,
        relation: entry.relation,
      );
      final materialized = <Map<String, Object?>>[];
      for (final row in relatedRows) {
        materialized.add(
          Map<String, Object?>.unmodifiable(
            await materializeRecord(
              entry.relation.targetModel,
              row.record,
              include: entry.include,
              select: entry.select,
            ),
          ),
        );
      }

      return materialized;
    }

    if (!recordContainsAllRelationKeyFields(
      sourceRecord,
      entry.relation.localKeyFields,
    )) {
      return entry.relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
    }

    final wherePredicates = <QueryPredicate>[];
    for (
      var index = 0;
      index < entry.relation.targetKeyFields.length;
      index++
    ) {
      wherePredicates.add(
        QueryPredicate(
          field: entry.relation.targetKeyFields[index],
          operator: 'equals',
          value: sourceRecord[entry.relation.localKeyFields[index]],
        ),
      );
    }

    final relatedRows = await selectRows(
      model: entry.relation.targetModel,
      where: wherePredicates,
      orderBy: const <QueryOrderBy>[],
    );

    final materialized = <Map<String, Object?>>[];
    for (final row in relatedRows) {
      materialized.add(
        Map<String, Object?>.unmodifiable(
          await materializeRecord(
            entry.relation.targetModel,
            row.record,
            include: entry.include,
            select: entry.select,
          ),
        ),
      );
    }

    if (entry.relation.cardinality == QueryRelationCardinality.one) {
      if (materialized.isEmpty) {
        return null;
      }
      return materialized.first;
    }

    return materialized;
  }

  Future<void> _applyBatchInclude({
    required String model,
    required List<Map<String, Object?>> rawRecords,
    required List<Map<String, Object?>> results,
    required String includeKey,
    required QueryIncludeEntry entry,
  }) async {
    final relation = entry.relation;

    if (relation.storageKind == QueryRelationStorageKind.implicitManyToMany) {
      await _applyImplicitManyToManyBatchInclude(
        model: model,
        rawRecords: rawRecords,
        results: results,
        includeKey: includeKey,
        entry: entry,
      );
      return;
    }

    if (relation.localKeyFields.length > 1) {
      for (var index = 0; index < rawRecords.length; index++) {
        results[index][includeKey] = await resolveInclude(
          model,
          rawRecords[index],
          entry,
        );
      }
      return;
    }

    final localField = relation.localKeyField;
    final targetField = relation.targetKeyField;
    final fkValues = rawRecords
        .map((record) => record[localField])
        .where((value) => value != null)
        .toSet()
        .toList(growable: false);

    if (fkValues.isEmpty) {
      final defaultValue = relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
      for (final result in results) {
        result[includeKey] = defaultValue;
      }
      return;
    }

    final targetRows = await selectRows(
      model: relation.targetModel,
      where: <QueryPredicate>[
        QueryPredicate(field: targetField, operator: 'in', value: fkValues),
      ],
      orderBy: const <QueryOrderBy>[],
    );

    final materializedTargets = await materializeRecordsBatch(
      relation.targetModel,
      targetRows.map((row) => row.record).toList(growable: false),
      include: entry.include,
      select: entry.select,
    );

    final lookup = <Object?, List<Map<String, Object?>>>{};
    for (var index = 0; index < targetRows.length; index++) {
      final key = targetRows[index].record[targetField];
      (lookup[key] ??= <Map<String, Object?>>[]).add(
        materializedTargets[index],
      );
    }

    for (var index = 0; index < rawRecords.length; index++) {
      final fkValue = rawRecords[index][localField];
      final matches = fkValue != null
          ? lookup[fkValue] ?? const <Map<String, Object?>>[]
          : const <Map<String, Object?>>[];
      if (relation.cardinality == QueryRelationCardinality.one) {
        results[index][includeKey] = matches.isEmpty
            ? null
            : Map<String, Object?>.unmodifiable(matches.first);
      } else {
        results[index][includeKey] = List<Map<String, Object?>>.unmodifiable(
          matches,
        );
      }
    }
  }

  Future<void> _applyImplicitManyToManyBatchInclude({
    required String model,
    required List<Map<String, Object?>> rawRecords,
    required List<Map<String, Object?>> results,
    required String includeKey,
    required QueryIncludeEntry entry,
  }) async {
    final relation = entry.relation;
    final parentIndicesByKey = <PostgresqlRelationKey, List<int>>{};
    final dedupedSourceRecords =
        <PostgresqlRelationKey, Map<String, Object?>>{};

    for (var index = 0; index < rawRecords.length; index++) {
      final record = rawRecords[index];
      if (!recordContainsAllRelationKeyFields(
        record,
        relation.localKeyFields,
      )) {
        results[index][includeKey] = const <Map<String, Object?>>[];
        continue;
      }

      final key = PostgresqlRelationKey(
        relation.localKeyFields
            .map((field) => record[field])
            .toList(growable: false),
      );
      (parentIndicesByKey[key] ??= <int>[]).add(index);
      dedupedSourceRecords.putIfAbsent(key, () => record);
    }

    if (dedupedSourceRecords.isEmpty) {
      return;
    }

    final relatedRows = await selectImplicitManyToManyRowsBatch(
      sourceModel: model,
      sourceRecords: dedupedSourceRecords.values.toList(growable: false),
      relation: relation,
    );
    final materializedTargets = await materializeRecordsBatch(
      relation.targetModel,
      relatedRows.map((row) => row.record).toList(growable: false),
      include: entry.include,
      select: entry.select,
    );

    final targetsByParentKey =
        <PostgresqlRelationKey, List<Map<String, Object?>>>{};
    for (var index = 0; index < relatedRows.length; index++) {
      (targetsByParentKey[relatedRows[index].sourceKey] ??=
              <Map<String, Object?>>[])
          .add(materializedTargets[index]);
    }

    for (final entryByKey in parentIndicesByKey.entries) {
      final matches = List<Map<String, Object?>>.unmodifiable(
        targetsByParentKey[entryByKey.key] ?? const <Map<String, Object?>>[],
      );
      for (final parentIndex in entryByKey.value) {
        results[parentIndex][includeKey] = matches;
      }
    }
  }

  Map<String, Object?> _selectRecordFields(
    Map<String, Object?> record,
    QuerySelect? select,
  ) {
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
}

/// A selected PostgreSQL row plus its row locator.
class PostgresqlSelectedRow {
  /// Creates a selected PostgreSQL row.
  const PostgresqlSelectedRow({required this.rowLocator, required this.record});

  /// Stable locator used for follow-up row selection.
  final String rowLocator;

  /// Normalized runtime record values.
  final Map<String, Object?> record;
}

/// A batched implicit many-to-many row paired with its parent key.
class PostgresqlImplicitManyToManyBatchRow {
  /// Creates a batched implicit many-to-many row.
  const PostgresqlImplicitManyToManyBatchRow({
    required this.sourceKey,
    required this.record,
  });

  /// Parent relation key.
  final PostgresqlRelationKey sourceKey;

  /// Normalized target record values.
  final Map<String, Object?> record;
}

/// Composite relation key used while grouping batched include results.
class PostgresqlRelationKey {
  /// Creates a relation key from ordered field values.
  const PostgresqlRelationKey(this.values);

  /// Ordered field values that identify the relation row.
  final List<Object?> values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! PostgresqlRelationKey ||
        other.values.length != values.length) {
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
