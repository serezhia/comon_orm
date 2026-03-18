import 'package:comon_orm/comon_orm.dart';

/// Callback used to load rows for a standard relation lookup.
typedef SqliteSelectRows =
    List<SqliteSelectedRow> Function({
      required String model,
      required List<QueryPredicate> where,
      required List<QueryOrderBy> orderBy,
    });

/// Callback used to load rows for one implicit many-to-many parent record.
typedef SqliteSelectImplicitManyToManyRows =
    List<SqliteSelectedRow> Function({
      required String sourceModel,
      required Map<String, Object?> sourceRecord,
      required QueryRelation relation,
    });

/// Callback used to load rows for batched implicit many-to-many parent records.
typedef SqliteSelectImplicitManyToManyRowsBatch =
    List<SqliteImplicitManyToManyBatchRow> Function({
      required String sourceModel,
      required List<Map<String, Object?>> sourceRecords,
      required QueryRelation relation,
    });

/// Materializes selected SQLite rows into include-aware runtime payloads.
class SqliteRelationMaterializer {
  /// Creates a materializer backed by adapter-owned row loading callbacks.
  const SqliteRelationMaterializer({
    required this.recordContainsAllRelationKeyFields,
    required this.selectImplicitManyToManyRows,
    required this.selectImplicitManyToManyRowsBatch,
    required this.selectRows,
  });

  /// Checks whether all local key fields needed for a relation are present.
  final bool Function(Map<String, Object?> record, List<String> fields)
  recordContainsAllRelationKeyFields;

  /// Loads implicit many-to-many rows for a single parent record.
  final SqliteSelectImplicitManyToManyRows selectImplicitManyToManyRows;

  /// Loads implicit many-to-many rows for a batch of parent records.
  final SqliteSelectImplicitManyToManyRowsBatch
  selectImplicitManyToManyRowsBatch;

  /// Loads rows for a standard relation query.
  final SqliteSelectRows selectRows;

  /// Materializes a single selected record with include/select projection.
  Map<String, Object?> materializeRecord(
    String model,
    Map<String, Object?> record, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) {
    final base = SqliteQuerySupport.selectMaterializedRecordFields(
      record: record,
      select: select,
    );

    if (include != null) {
      for (final entry in include.relations.entries) {
        base[entry.key] = resolveInclude(model, record, entry.value);
      }
    }

    return base;
  }

  /// Materializes a batch of selected records with include/select projection.
  List<Map<String, Object?>> materializeRecordsBatch(
    String model,
    List<Map<String, Object?>> rawRecords, {
    required QueryInclude? include,
    required QuerySelect? select,
  }) {
    if (rawRecords.isEmpty) {
      return const <Map<String, Object?>>[];
    }

    final results = rawRecords
        .map(
          (raw) => SqliteQuerySupport.selectMaterializedRecordFields(
            record: raw,
            select: select,
          ),
        )
        .toList(growable: false);

    if (include == null) {
      return results;
    }

    for (final entry in include.relations.entries) {
      _applyBatchInclude(
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
  Object? resolveInclude(
    String sourceModel,
    Map<String, Object?> sourceRecord,
    QueryIncludeEntry entry,
  ) {
    if (entry.relation.storageKind ==
        QueryRelationStorageKind.implicitManyToMany) {
      final relatedRows = selectImplicitManyToManyRows(
        sourceModel: sourceModel,
        sourceRecord: sourceRecord,
        relation: entry.relation,
      );
      final materialized = relatedRows
          .map(
            (row) => Map<String, Object?>.unmodifiable(
              materializeRecord(
                entry.relation.targetModel,
                row.record,
                include: entry.include,
                select: entry.select,
              ),
            ),
          )
          .toList(growable: false);
      return SqliteQuerySupport.finalizeIncludedRelationResult(
        relation: entry.relation,
        materialized: materialized,
      );
    }

    final wherePredicates =
        SqliteQuerySupport.buildDirectRelationWherePredicates(
          sourceRecord: sourceRecord,
          relation: entry.relation,
        );
    if (wherePredicates == null) {
      return entry.relation.cardinality == QueryRelationCardinality.many
          ? const <Map<String, Object?>>[]
          : null;
    }

    final relatedRows = selectRows(
      model: entry.relation.targetModel,
      where: wherePredicates,
      orderBy: const <QueryOrderBy>[],
    );

    final materialized = relatedRows
        .map(
          (row) => Map<String, Object?>.unmodifiable(
            materializeRecord(
              entry.relation.targetModel,
              row.record,
              include: entry.include,
              select: entry.select,
            ),
          ),
        )
        .toList(growable: false);

    return SqliteQuerySupport.finalizeIncludedRelationResult(
      relation: entry.relation,
      materialized: materialized,
    );
  }

  void _applyBatchInclude({
    required String model,
    required List<Map<String, Object?>> rawRecords,
    required List<Map<String, Object?>> results,
    required String includeKey,
    required QueryIncludeEntry entry,
  }) {
    final relation = entry.relation;

    if (relation.storageKind == QueryRelationStorageKind.implicitManyToMany) {
      _applyImplicitManyToManyBatchInclude(
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
        results[index][includeKey] = resolveInclude(
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

    final targetRows = selectRows(
      model: relation.targetModel,
      where: <QueryPredicate>[
        QueryPredicate(field: targetField, operator: 'in', value: fkValues),
      ],
      orderBy: const <QueryOrderBy>[],
    );

    final materializedTargets = materializeRecordsBatch(
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

  void _applyImplicitManyToManyBatchInclude({
    required String model,
    required List<Map<String, Object?>> rawRecords,
    required List<Map<String, Object?>> results,
    required String includeKey,
    required QueryIncludeEntry entry,
  }) {
    final relation = entry.relation;
    final parentIndicesByKey = <SqliteRelationKey, List<int>>{};
    final dedupedSourceRecords = <SqliteRelationKey, Map<String, Object?>>{};

    for (var index = 0; index < rawRecords.length; index++) {
      final record = rawRecords[index];
      if (!recordContainsAllRelationKeyFields(
        record,
        relation.localKeyFields,
      )) {
        results[index][includeKey] = const <Map<String, Object?>>[];
        continue;
      }

      final key = SqliteRelationKey(
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

    final relatedRows = selectImplicitManyToManyRowsBatch(
      sourceModel: model,
      sourceRecords: dedupedSourceRecords.values.toList(growable: false),
      relation: relation,
    );
    final materializedTargets = materializeRecordsBatch(
      relation.targetModel,
      relatedRows.map((row) => row.record).toList(growable: false),
      include: entry.include,
      select: entry.select,
    );

    final targetsByParentKey =
        <SqliteRelationKey, List<Map<String, Object?>>>{};
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
}

/// A selected SQLite row plus its row id.
class SqliteSelectedRow {
  /// Creates a selected SQLite row.
  const SqliteSelectedRow({required this.rowId, required this.record});

  /// SQLite row id used for follow-up updates and deletes.
  final int rowId;

  /// Normalized runtime record values.
  final Map<String, Object?> record;
}

/// A batched implicit many-to-many row paired with its parent key.
class SqliteImplicitManyToManyBatchRow {
  /// Creates a batched implicit many-to-many row.
  const SqliteImplicitManyToManyBatchRow({
    required this.sourceKey,
    required this.record,
  });

  /// Parent relation key.
  final SqliteRelationKey sourceKey;

  /// Normalized target record values.
  final Map<String, Object?> record;
}

/// Composite relation key used while grouping batched include results.
class SqliteRelationKey {
  /// Creates a relation key from ordered field values.
  const SqliteRelationKey(this.values);

  /// Ordered field values that identify the relation row.
  final List<Object?> values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! SqliteRelationKey || other.values.length != values.length) {
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
