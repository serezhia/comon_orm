// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

class GeneratedComonOrmClient {
  GeneratedComonOrmClient({required DatabaseAdapter adapter})
    : _client = ComonOrmClient(adapter: adapter);

  GeneratedComonOrmClient._fromClient(this._client);

  static const GeneratedRuntimeSchema runtimeSchema =
      GeneratedComonOrmMetadata.schema;

  static final RuntimeSchemaView runtimeSchemaView =
      runtimeSchemaViewFromGeneratedSchema(runtimeSchema);

  static InMemoryDatabaseAdapter createInMemoryAdapter() {
    return InMemoryDatabaseAdapter.fromGeneratedSchema(schema: runtimeSchema);
  }

  factory GeneratedComonOrmClient.openInMemory() {
    return GeneratedComonOrmClient(adapter: createInMemoryAdapter());
  }

  final ComonOrmClient _client;
  late final TodoDelegate todo = TodoDelegate._(_client);

  Future<T> transaction<T>(
    Future<T> Function(GeneratedComonOrmClient tx) action,
  ) {
    return _client.transaction(
      (tx) => action(GeneratedComonOrmClient._fromClient(tx)),
    );
  }

  Future<void> close() async {
    await _client.close();
  }
}

class GeneratedComonOrmClientFlutterSqlite {
  const GeneratedComonOrmClientFlutterSqlite._();

  static Future<GeneratedComonOrmClient> open({
    String? databasePath,
    String? datasourceName,
    DatabaseFactory? databaseFactory,
    SqliteFlutterRuntimeAdapterFactory? adapterFactory,
  }) async {
    final adapter = await SqliteFlutterDatabaseAdapter.openFromGeneratedSchema(
      schema: GeneratedComonOrmClient.runtimeSchema,
      databasePath: databasePath,
      datasourceName: datasourceName,
      databaseFactory: databaseFactory,
      adapterFactory: adapterFactory,
    );
    return GeneratedComonOrmClient(adapter: adapter);
  }
}

class GeneratedComonOrmMetadata {
  const GeneratedComonOrmMetadata._();

  static const GeneratedRuntimeSchema schema = GeneratedRuntimeSchema(
    datasources: <GeneratedDatasourceMetadata>[
      GeneratedDatasourceMetadata(
        name: 'db',
        provider: 'sqlite',
        url: GeneratedDatasourceUrl(
          kind: GeneratedDatasourceUrlKind.literal,
          value: 'file:app.db',
        ),
      ),
    ],
    enums: <GeneratedEnumMetadata>[],
    models: <GeneratedModelMetadata>[
      GeneratedModelMetadata(
        name: 'Todo',
        databaseName: 'Todo',
        primaryKeyFields: <String>['id'],
        compoundUniqueFieldSets: <List<String>>[],
        fields: <GeneratedFieldMetadata>[
          GeneratedFieldMetadata(
            name: 'id',
            databaseName: 'id',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: true,
            isUnique: false,
            isUpdatedAt: false,
            defaultValue: GeneratedFieldDefaultMetadata(
              kind: GeneratedRuntimeDefaultKind.autoincrement,
            ),
          ),
          GeneratedFieldMetadata(
            name: 'title',
            databaseName: 'title',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'done',
            databaseName: 'done',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Boolean',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            defaultValue: GeneratedFieldDefaultMetadata(
              kind: GeneratedRuntimeDefaultKind.literal,
              value: 'false',
            ),
          ),
          GeneratedFieldMetadata(
            name: 'createdAt',
            databaseName: 'createdAt',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'DateTime',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
        ],
      ),
    ],
  );
}

class StringFieldUpdateOperationsInput {
  const StringFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class BoolFieldUpdateOperationsInput {
  const BoolFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class DateTimeFieldUpdateOperationsInput {
  const DateTimeFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class BytesFieldUpdateOperationsInput {
  const BytesFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class JsonFieldUpdateOperationsInput {
  const JsonFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class IntFieldUpdateOperationsInput {
  const IntFieldUpdateOperationsInput({
    this.set = _undefined,
    this.increment,
    this.decrement,
  });

  final Object? set;
  final int? increment;
  final int? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations =>
      (hasSet ? 1 : 0) +
          (increment != null ? 1 : 0) +
          (decrement != null ? 1 : 0) >
      1;
}

class DoubleFieldUpdateOperationsInput {
  const DoubleFieldUpdateOperationsInput({
    this.set = _undefined,
    this.increment,
    this.decrement,
  });

  final Object? set;
  final double? increment;
  final double? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations =>
      (hasSet ? 1 : 0) +
          (increment != null ? 1 : 0) +
          (decrement != null ? 1 : 0) >
      1;
}

class BigIntFieldUpdateOperationsInput {
  const BigIntFieldUpdateOperationsInput({
    this.set = _undefined,
    this.increment,
    this.decrement,
  });

  final Object? set;
  final BigInt? increment;
  final BigInt? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations =>
      (hasSet ? 1 : 0) +
          (increment != null ? 1 : 0) +
          (decrement != null ? 1 : 0) >
      1;
}

class EnumFieldUpdateOperationsInput<T extends Enum> {
  const EnumFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class Todo {
  const Todo({this.id, this.title, this.done, this.createdAt});

  final int? id;
  final String? title;
  final bool? done;
  final DateTime? createdAt;

  factory Todo.fromRecord(Map<String, Object?> record) {
    return Todo(
      id: record['id'] as int?,
      title: record['title'] as String?,
      done: record['done'] as bool?,
      createdAt: _asDateTime(record['createdAt']),
    );
  }

  factory Todo.fromJson(Map<String, Object?> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String?,
      done: json['done'] as bool?,
      createdAt: _asDateTime(json['createdAt']),
    );
  }

  Todo copyWith({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? done = _undefined,
    Object? createdAt = _undefined,
  }) {
    return Todo(
      id: id == _undefined ? this.id : id as int?,
      title: title == _undefined ? this.title : title as String?,
      done: done == _undefined ? this.done : done as bool?,
      createdAt: createdAt == _undefined
          ? this.createdAt
          : createdAt as DateTime?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (title != null) {
      record['title'] = title;
    }
    if (done != null) {
      record['done'] = done;
    }
    if (createdAt != null) {
      record['createdAt'] = createdAt;
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (id != null) {
      json['id'] = id;
    }
    if (title != null) {
      json['title'] = title;
    }
    if (done != null) {
      json['done'] = done;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toIso8601String();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() =>
      'Todo(id: $id, title: $title, done: $done, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            _deepEquals(id, other.id) &&
            _deepEquals(title, other.title) &&
            _deepEquals(done, other.done) &&
            _deepEquals(createdAt, other.createdAt);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(title),
    _deepHash(done),
    _deepHash(createdAt),
  ]);
}

class TodoDelegate {
  const TodoDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Todo');

  Future<Todo?> findUnique({
    required TodoWhereUniqueInput where,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'Todo',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then((record) => record == null ? null : Todo.fromRecord(record));
  }

  Future<Todo?> findFirst({
    TodoWhereInput? where,
    TodoWhereUniqueInput? cursor,
    List<TodoOrderByInput>? orderBy,
    List<TodoScalarField>? distinct,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy =
        orderBy
            ?.expand((entry) => entry.toQueryOrderBy())
            .toList(growable: false) ??
        const <QueryOrderBy>[];
    final queryDistinct =
        distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    if (cursor != null) {
      final records = await _findManyWithCursor(
        predicates: predicates,
        cursor: cursor,
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: 1,
      );
      if (records.isEmpty) {
        return null;
      }
      return records.first;
    }
    return _delegate
        .findFirst(
          FindFirstQuery(
            model: 'Todo',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : Todo.fromRecord(record));
  }

  Future<List<Todo>> findMany({
    TodoWhereInput? where,
    TodoWhereUniqueInput? cursor,
    List<TodoOrderByInput>? orderBy,
    List<TodoScalarField>? distinct,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
    int? take,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy =
        orderBy
            ?.expand((entry) => entry.toQueryOrderBy())
            .toList(growable: false) ??
        const <QueryOrderBy>[];
    final queryDistinct =
        distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    if (cursor != null) {
      return _findManyWithCursor(
        predicates: predicates,
        cursor: cursor,
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      );
    }
    return _delegate
        .findMany(
          FindManyQuery(
            model: 'Todo',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
            take: take,
          ),
        )
        .then(
          (records) => records.map(Todo.fromRecord).toList(growable: false),
        );
  }

  Future<int> count({TodoWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Todo',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<TodoAggregateResult> aggregate({
    TodoWhereInput? where,
    List<TodoOrderByInput>? orderBy,
    int? skip,
    int? take,
    TodoCountAggregateInput? count,
    TodoAvgAggregateInput? avg,
    TodoSumAggregateInput? sum,
    TodoMinAggregateInput? min,
    TodoMaxAggregateInput? max,
  }) {
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'Todo',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            skip: skip,
            take: take,
            count:
                count?.toQueryCountSelection() ?? const QueryCountSelection(),
            avg: avg?.toFields() ?? const <String>{},
            sum: sum?.toFields() ?? const <String>{},
            min: min?.toFields() ?? const <String>{},
            max: max?.toFields() ?? const <String>{},
          ),
        )
        .then(TodoAggregateResult.fromQueryResult);
  }

  Future<List<TodoGroupByRow>> groupBy({
    required List<TodoScalarField> by,
    TodoWhereInput? where,
    List<TodoGroupByOrderByInput>? orderBy,
    TodoGroupByHavingInput? having,
    int? skip,
    int? take,
    TodoCountAggregateInput? count,
    TodoAvgAggregateInput? avg,
    TodoSumAggregateInput? sum,
    TodoMinAggregateInput? min,
    TodoMaxAggregateInput? max,
  }) {
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'Todo',
            by: by.map((field) => field.name).toList(growable: false),
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            having:
                having?.toAggregatePredicates() ??
                const <QueryAggregatePredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toGroupByOrderBy())
                    .toList(growable: false) ??
                const <GroupByOrderBy>[],
            skip: skip,
            take: take,
            count:
                count?.toQueryCountSelection() ?? const QueryCountSelection(),
            avg: avg?.toFields() ?? const <String>{},
            sum: sum?.toFields() ?? const <String>{},
            min: min?.toFields() ?? const <String>{},
            max: max?.toFields() ?? const <String>{},
          ),
        )
        .then(
          (rows) => rows
              .map(TodoGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
  }

  Future<Todo> create({required TodoCreateInput data, TodoInclude? include}) {
    final queryInclude = include?.toQueryInclude();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      return _performCreateWithRelationWrites(
        tx: tx,
        data: data,
        include: queryInclude,
      );
    });
  }

  Future<int> createMany({
    required List<TodoCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Todo');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(model: 'Todo', where: selector),
            );
            if (existing != null) {
              duplicateFound = true;
              break;
            }
          }
          if (duplicateFound) {
            continue;
          }
        }
        try {
          if (entry.hasDeferredRelationWrites) {
            await _performCreateWithRelationWrites(tx: tx, data: entry);
          } else {
            await txDelegate.create(
              CreateQuery(
                model: 'Todo',
                data: entry.toData(),
                nestedCreates: entry.toNestedCreates(),
              ),
            );
          }
        } on Object catch (error) {
          if (skipDuplicates && _isSkippableDuplicateError(error)) {
            continue;
          }
          rethrow;
        }
        createdCount++;
      }
      return createdCount;
    });
  }

  Future<Todo> update({
    required TodoWhereUniqueInput where,
    required TodoUpdateInput data,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Todo');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Todo', where: predicates),
      );
      if (existing == null) {
        throw StateError('No record found for update in Todo.');
      }
      return _performUpdateWithRelationWrites(
        tx: tx,
        predicates: predicates,
        existing: existing,
        data: data,
        include: queryInclude,
        select: querySelect,
      );
    });
  }

  Future<Todo> upsert({
    required TodoWhereUniqueInput where,
    required TodoCreateInput create,
    required TodoUpdateInput update,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Todo');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Todo', where: predicates),
      );
      if (existing != null) {
        return _performUpdateWithRelationWrites(
          tx: tx,
          predicates: predicates,
          existing: existing,
          data: update,
          include: queryInclude,
          select: querySelect,
        );
      }
      return _performCreateWithRelationWrites(
        tx: tx,
        data: create,
        include: queryInclude,
        select: querySelect,
      );
    });
  }

  Future<int> updateMany({
    required TodoWhereInput where,
    required TodoUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Todo');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(model: 'Todo', where: predicates),
        );
        var updatedCount = 0;
        for (final record in existingRecords) {
          await _performUpdateWithRelationWrites(
            tx: tx,
            predicates: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
            existing: record,
            data: data,
          );
          updatedCount++;
        }
        return updatedCount;
      });
    }
    return _delegate.updateMany(
      UpdateManyQuery(model: 'Todo', where: predicates, data: data.toData()),
    );
  }

  Future<List<Todo>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required TodoWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'Todo',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <Todo>[];
    }
    final effectiveSkip = skip ?? 0;
    final startIndex = cursorIndex + effectiveSkip;
    final boundedStartIndex = startIndex < 0 ? 0 : startIndex;
    late final List<Map<String, Object?>> pagedRecords;
    if (take == null) {
      pagedRecords = rawRecords.skip(boundedStartIndex).toList(growable: false);
    } else if (take >= 0) {
      pagedRecords = rawRecords
          .skip(boundedStartIndex)
          .take(take)
          .toList(growable: false);
    } else {
      final endExclusive = cursorIndex + 1 - effectiveSkip;
      final boundedEndExclusive = endExclusive <= 0
          ? 0
          : (endExclusive > rawRecords.length
                ? rawRecords.length
                : endExclusive);
      final startInclusive = boundedEndExclusive + take;
      final boundedBackwardStart = startInclusive < 0 ? 0 : startInclusive;
      pagedRecords = rawRecords
          .sublist(boundedBackwardStart, boundedEndExclusive)
          .toList(growable: false);
    }
    if (include == null && select == null) {
      return pagedRecords.map(Todo.fromRecord).toList(growable: false);
    }
    final projectedRecords = <Todo>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'Todo',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'Todo.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(Todo.fromRecord(projected));
    }
    return List<Todo>.unmodifiable(projectedRecords);
  }

  Future<Todo> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required TodoCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Todo');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Todo',
        data: data.toData(),
        nestedCreates: data.toNestedCreates(),
      ),
    );
    final predicates = _primaryKeyWhereUniqueFromRecord(created).toPredicates();
    if (data.hasDeferredRelationWrites) {
      await _applyNestedRelationWrites(
        tx: tx,
        predicates: predicates,
        existing: created,
        data: data.toDeferredRelationUpdateInput(),
      );
    }
    if (include == null && select == null && !data.hasDeferredRelationWrites) {
      return Todo.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Todo',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Todo create branch could not reload the created record by primary key.',
      );
    }
    return Todo.fromRecord(projected);
  }

  TodoWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return TodoWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<Todo> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required TodoUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Todo');
    await txDelegate.update(
      UpdateQuery(
        model: 'Todo',
        where: predicates,
        data: data.resolveDataAgainstRecord(existing),
      ),
    );
    await _applyNestedRelationWrites(
      tx: tx,
      predicates: predicates,
      existing: existing,
      data: data,
    );
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Todo',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Todo update branch could not reload the updated record for the provided unique selector.',
      );
    }
    return Todo.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required TodoUpdateInput data,
  }) async {
    return;
  }

  Future<Todo> delete({
    required TodoWhereUniqueInput where,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'Todo',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Todo.fromRecord);
  }

  Future<int> deleteMany({required TodoWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'Todo', where: where.toPredicates()),
    );
  }
}

class TodoWhereInput {
  const TodoWhereInput({
    this.AND = const <TodoWhereInput>[],
    this.OR = const <TodoWhereInput>[],
    this.NOT = const <TodoWhereInput>[],
    this.id,
    this.idFilter,
    this.title,
    this.titleFilter,
    this.done,
    this.doneFilter,
    this.createdAt,
  });

  final List<TodoWhereInput> AND;
  final List<TodoWhereInput> OR;
  final List<TodoWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? title;
  final StringFilter? titleFilter;
  final bool? done;
  final BoolFilter? doneFilter;
  final DateTime? createdAt;

  List<QueryPredicate> toPredicates() {
    final predicates = <QueryPredicate>[];
    if (AND.isNotEmpty) {
      predicates.add(
        QueryPredicate(
          field: 'AND',
          operator: 'logicalAnd',
          value: QueryLogicalGroup(
            branches: AND
                .map((entry) => entry.toPredicates())
                .toList(growable: false),
          ),
        ),
      );
    }
    if (OR.isNotEmpty) {
      predicates.add(
        QueryPredicate(
          field: 'OR',
          operator: 'logicalOr',
          value: QueryLogicalGroup(
            branches: OR
                .map((entry) => entry.toPredicates())
                .toList(growable: false),
          ),
        ),
      );
    }
    if (NOT.isNotEmpty) {
      predicates.add(
        QueryPredicate(
          field: 'NOT',
          operator: 'logicalNot',
          value: QueryLogicalGroup(
            branches: NOT
                .map((entry) => entry.toPredicates())
                .toList(growable: false),
          ),
        ),
      );
    }
    if (id != null) {
      predicates.add(
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      );
    }
    if (idFilter != null) {
      predicates.addAll(idFilter!.toPredicates('id'));
    }
    if (title != null) {
      predicates.add(
        QueryPredicate(field: 'title', operator: 'equals', value: title),
      );
    }
    if (titleFilter != null) {
      predicates.addAll(titleFilter!.toPredicates('title'));
    }
    if (done != null) {
      predicates.add(
        QueryPredicate(field: 'done', operator: 'equals', value: done),
      );
    }
    if (doneFilter != null) {
      predicates.addAll(doneFilter!.toPredicates('done'));
    }
    if (createdAt != null) {
      predicates.add(
        QueryPredicate(
          field: 'createdAt',
          operator: 'equals',
          value: createdAt,
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class TodoWhereUniqueInput {
  const TodoWhereUniqueInput({this.id});

  final int? id;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for TodoWhereUniqueInput.',
      );
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }

  bool matchesRecord(Map<String, Object?> record) {
    var selectorCount = 0;
    var matches = false;
    if (id != null) {
      selectorCount++;
      matches = record['id'] == id;
    }
    if (selectorCount != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for TodoWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class TodoOrderByInput {
  const TodoOrderByInput({this.id, this.title, this.done, this.createdAt});

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(QueryOrderBy(field: 'title', direction: title!));
    }
    if (done != null) {
      orderings.add(QueryOrderBy(field: 'done', direction: done!));
    }
    if (createdAt != null) {
      orderings.add(QueryOrderBy(field: 'createdAt', direction: createdAt!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum TodoScalarField { id, title, done, createdAt }

class TodoCountAggregateInput {
  const TodoCountAggregateInput({
    this.all = false,
    this.id = false,
    this.title = false,
    this.done = false,
    this.createdAt = false,
  });

  final bool all;
  final bool id;
  final bool title;
  final bool done;
  final bool createdAt;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (done) {
      fields.add('done');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class TodoAvgAggregateInput {
  const TodoAvgAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoSumAggregateInput {
  const TodoSumAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoMinAggregateInput {
  const TodoMinAggregateInput({
    this.id = false,
    this.title = false,
    this.done = false,
    this.createdAt = false,
  });

  final bool id;
  final bool title;
  final bool done;
  final bool createdAt;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (done) {
      fields.add('done');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoMaxAggregateInput {
  const TodoMaxAggregateInput({
    this.id = false,
    this.title = false,
    this.done = false,
    this.createdAt = false,
  });

  final bool id;
  final bool title;
  final bool done;
  final bool createdAt;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (done) {
      fields.add('done');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoCountAggregateResult {
  const TodoCountAggregateResult({
    this.all,
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final int? all;
  final int? id;
  final int? title;
  final int? done;
  final int? createdAt;

  factory TodoCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return TodoCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      title: result.fields['title'],
      done: result.fields['done'],
      createdAt: result.fields['createdAt'],
    );
  }
}

class TodoAvgAggregateResult {
  const TodoAvgAggregateResult({this.id});

  final double? id;

  factory TodoAvgAggregateResult.fromMap(Map<String, double?> values) {
    return TodoAvgAggregateResult(id: _asDouble(values['id']));
  }
}

class TodoSumAggregateResult {
  const TodoSumAggregateResult({this.id});

  final int? id;

  factory TodoSumAggregateResult.fromMap(Map<String, num?> values) {
    return TodoSumAggregateResult(id: values['id']?.toInt());
  }
}

class TodoMinAggregateResult {
  const TodoMinAggregateResult({
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final int? id;
  final String? title;
  final bool? done;
  final DateTime? createdAt;

  factory TodoMinAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMinAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      done: values['done'] as bool?,
      createdAt: _asDateTime(values['createdAt']),
    );
  }
}

class TodoMaxAggregateResult {
  const TodoMaxAggregateResult({
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final int? id;
  final String? title;
  final bool? done;
  final DateTime? createdAt;

  factory TodoMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMaxAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      done: values['done'] as bool?,
      createdAt: _asDateTime(values['createdAt']),
    );
  }
}

class TodoAggregateResult {
  const TodoAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final TodoCountAggregateResult? count;
  final TodoAvgAggregateResult? avg;
  final TodoSumAggregateResult? sum;
  final TodoMinAggregateResult? min;
  final TodoMaxAggregateResult? max;

  factory TodoAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return TodoAggregateResult(
      count: result.count == null
          ? null
          : TodoCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : TodoAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : TodoSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : TodoMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : TodoMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class TodoGroupByHavingInput {
  const TodoGroupByHavingInput({this.id});

  final NumericAggregatesFilter? id;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class TodoCountAggregateOrderByInput {
  const TodoCountAggregateOrderByInput({
    this.all,
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(
        GroupByOrderBy.aggregate(aggregate: function, direction: all!),
      );
    }
    if (id != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'id',
          direction: id!,
        ),
      );
    }
    if (title != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'title',
          direction: title!,
        ),
      );
    }
    if (done != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'done',
          direction: done!,
        ),
      );
    }
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoAvgAggregateOrderByInput {
  const TodoAvgAggregateOrderByInput({this.id});

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'id',
          direction: id!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoSumAggregateOrderByInput {
  const TodoSumAggregateOrderByInput({this.id});

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'id',
          direction: id!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoMinAggregateOrderByInput {
  const TodoMinAggregateOrderByInput({
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'id',
          direction: id!,
        ),
      );
    }
    if (title != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'title',
          direction: title!,
        ),
      );
    }
    if (done != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'done',
          direction: done!,
        ),
      );
    }
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoMaxAggregateOrderByInput {
  const TodoMaxAggregateOrderByInput({
    this.id,
    this.title,
    this.done,
    this.createdAt,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'id',
          direction: id!,
        ),
      );
    }
    if (title != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'title',
          direction: title!,
        ),
      );
    }
    if (done != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'done',
          direction: done!,
        ),
      );
    }
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoGroupByOrderByInput {
  const TodoGroupByOrderByInput({
    this.id,
    this.title,
    this.done,
    this.createdAt,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;
  final TodoCountAggregateOrderByInput? count;
  final TodoAvgAggregateOrderByInput? avg;
  final TodoSumAggregateOrderByInput? sum;
  final TodoMinAggregateOrderByInput? min;
  final TodoMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.field(field: 'title', direction: title!));
    }
    if (done != null) {
      orderings.add(GroupByOrderBy.field(field: 'done', direction: done!));
    }
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'createdAt', direction: createdAt!),
      );
    }
    if (count != null) {
      orderings.addAll(count!.toGroupByOrderBy(QueryAggregateFunction.count));
    }
    if (avg != null) {
      orderings.addAll(avg!.toGroupByOrderBy(QueryAggregateFunction.avg));
    }
    if (sum != null) {
      orderings.addAll(sum!.toGroupByOrderBy(QueryAggregateFunction.sum));
    }
    if (min != null) {
      orderings.addAll(min!.toGroupByOrderBy(QueryAggregateFunction.min));
    }
    if (max != null) {
      orderings.addAll(max!.toGroupByOrderBy(QueryAggregateFunction.max));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoGroupByRow {
  const TodoGroupByRow({
    this.id,
    this.title,
    this.done,
    this.createdAt,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? title;
  final bool? done;
  final DateTime? createdAt;
  final TodoCountAggregateResult? count;
  final TodoAvgAggregateResult? avg;
  final TodoSumAggregateResult? sum;
  final TodoMinAggregateResult? min;
  final TodoMaxAggregateResult? max;

  factory TodoGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return TodoGroupByRow(
      id: row.group['id'] as int?,
      title: row.group['title'] as String?,
      done: row.group['done'] as bool?,
      createdAt: _asDateTime(row.group['createdAt']),
      count: row.aggregates.count == null
          ? null
          : TodoCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : TodoAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : TodoSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : TodoMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : TodoMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class TodoInclude {
  const TodoInclude();

  QueryInclude? toQueryInclude() {
    return null;
  }
}

class TodoSelect {
  const TodoSelect({
    this.id = false,
    this.title = false,
    this.done = false,
    this.createdAt = false,
  });

  final bool id;
  final bool title;
  final bool done;
  final bool createdAt;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (done) {
      fields.add('done');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class TodoCreateInput {
  const TodoCreateInput({
    this.id,
    required this.title,
    this.done,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final bool? done;
  final DateTime createdAt;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    if (done != null) {
      data['done'] = done;
    }
    data['createdAt'] = createdAt;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    return List<List<QueryPredicate>>.unmodifiable(
      selectors.map(List<QueryPredicate>.unmodifiable),
    );
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return false;
  }

  TodoUpdateInput toDeferredRelationUpdateInput() {
    return TodoUpdateInput();
  }
}

class TodoUpdateInput {
  const TodoUpdateInput({
    this.title,
    this.titleOps,
    this.done,
    this.doneOps,
    this.createdAt,
    this.createdAtOps,
  });

  final String? title;
  final StringFieldUpdateOperationsInput? titleOps;
  final bool? done;
  final BoolFieldUpdateOperationsInput? doneOps;
  final DateTime? createdAt;
  final DateTimeFieldUpdateOperationsInput? createdAtOps;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return false;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (title != null && titleOps != null) {
      throw StateError(
        'Only one of title or titleOps may be provided for TodoUpdateInput.title.',
      );
    }
    if (title != null) {
      data['title'] = title;
    }
    if (titleOps != null) {
      final ops = titleOps!;
      if (ops.hasSet) {
        data['title'] = ops.set as String?;
      }
    }
    if (done != null && doneOps != null) {
      throw StateError(
        'Only one of done or doneOps may be provided for TodoUpdateInput.done.',
      );
    }
    if (done != null) {
      data['done'] = done;
    }
    if (doneOps != null) {
      final ops = doneOps!;
      if (ops.hasSet) {
        data['done'] = ops.set as bool?;
      }
    }
    if (createdAt != null && createdAtOps != null) {
      throw StateError(
        'Only one of createdAt or createdAtOps may be provided for TodoUpdateInput.createdAt.',
      );
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (createdAtOps != null) {
      final ops = createdAtOps!;
      if (ops.hasSet) {
        data['createdAt'] = ops.set as DateTime?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (title != null && titleOps != null) {
      throw StateError(
        'Only one of title or titleOps may be provided for TodoUpdateInput.title.',
      );
    }
    if (title != null) {
      data['title'] = title;
    }
    if (titleOps != null) {
      final ops = titleOps!;
      if (ops.hasSet) {
        data['title'] = ops.set as String?;
      }
    }
    if (done != null && doneOps != null) {
      throw StateError(
        'Only one of done or doneOps may be provided for TodoUpdateInput.done.',
      );
    }
    if (done != null) {
      data['done'] = done;
    }
    if (doneOps != null) {
      final ops = doneOps!;
      if (ops.hasSet) {
        data['done'] = ops.set as bool?;
      }
    }
    if (createdAt != null && createdAtOps != null) {
      throw StateError(
        'Only one of createdAt or createdAtOps may be provided for TodoUpdateInput.createdAt.',
      );
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (createdAtOps != null) {
      final ops = createdAtOps!;
      if (ops.hasSet) {
        data['createdAt'] = ops.set as DateTime?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

DateTime? _asDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return null;
}

List<int>? _asBytes(Object? value) {
  if (value is List<int>) {
    return value;
  }
  if (value is List<Object?>) {
    return value.whereType<int>().toList(growable: false);
  }
  return null;
}

BigInt? _asBigInt(Object? value) {
  if (value is BigInt) {
    return value;
  }
  if (value is int) {
    return BigInt.from(value);
  }
  if (value is String) {
    return BigInt.tryParse(value);
  }
  return null;
}

String? _enumName(Object? value) {
  if (value is Enum) {
    return value.name;
  }
  return null;
}

class _Undefined {
  const _Undefined();
}

const Object _undefined = _Undefined();

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) {
    return true;
  }
  if (left is List<Object?> && right is List<Object?>) {
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (!_deepEquals(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }
  if (left is Map<Object?, Object?> && right is Map<Object?, Object?>) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key)) {
        return false;
      }
      if (!_deepEquals(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return left == right;
}

int _deepHash(Object? value) {
  if (value is List<Object?>) {
    return Object.hashAll(value.map(_deepHash));
  }
  if (value is Map<Object?, Object?>) {
    final entries =
        value.entries
            .map(
              (entry) =>
                  Object.hash(_deepHash(entry.key), _deepHash(entry.value)),
            )
            .toList(growable: false)
          ..sort();
    return Object.hashAll(entries);
  }
  return value.hashCode;
}

Object? _jsonEncodable(Object? value) {
  if (value == null || value is String || value is num || value is bool) {
    return value;
  }
  if (value is DateTime) {
    return value.toIso8601String();
  }
  if (value is BigInt) {
    return value.toString();
  }
  if (value is Enum) {
    return value.name;
  }
  if (value is List<Object?>) {
    return value.map(_jsonEncodable).toList(growable: false);
  }
  if (value is Map<Object?, Object?>) {
    final json = <String, Object?>{};
    for (final entry in value.entries) {
      json[entry.key.toString()] = _jsonEncodable(entry.value);
    }
    return Map<String, Object?>.unmodifiable(json);
  }
  return value;
}

Object? _requireRecordValue(
  Map<String, Object?> record,
  String field,
  String context,
) {
  final value = record[field];
  if (value == null) {
    throw StateError('Missing required key "$field" for $context.');
  }
  return value;
}

bool _isSkippableDuplicateError(Object error) {
  final code = _errorCode(error);
  if (code == '23505') {
    return true;
  }
  final normalized = error.toString().toLowerCase();
  return normalized.contains(
        'duplicate key value violates unique constraint',
      ) ||
      normalized.contains('unique constraint failed') ||
      normalized.contains('unique violation');
}

String? _errorCode(Object error) {
  try {
    final dynamicError = error as dynamic;
    final code = dynamicError.code;
    return code is String ? code : null;
  } catch (_) {
    return null;
  }
}
