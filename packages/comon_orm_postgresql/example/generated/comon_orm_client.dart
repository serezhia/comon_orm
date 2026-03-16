// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

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
  late final UserDelegate user = UserDelegate._(_client);

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

class GeneratedComonOrmClientPostgresql {
  const GeneratedComonOrmClientPostgresql._();

  static Future<GeneratedComonOrmClient> open({
    String? connectionUrl,
    String? datasourceName,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    PostgresqlRuntimeAdapterFactory? adapterFactory,
  }) async {
    final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
      schema: GeneratedComonOrmClient.runtimeSchema,
      connectionUrl: connectionUrl,
      datasourceName: datasourceName,
      resolver: resolver,
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
        provider: 'postgresql',
        url: GeneratedDatasourceUrl(
          kind: GeneratedDatasourceUrlKind.env,
          value: 'DATABASE_URL',
        ),
      ),
    ],
    enums: <GeneratedEnumMetadata>[],
    models: <GeneratedModelMetadata>[
      GeneratedModelMetadata(
        name: 'User',
        databaseName: 'User',
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
            name: 'email',
            databaseName: 'email',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: true,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'name',
            databaseName: 'name',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
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

class User {
  const User({this.id, this.email, this.name});

  final int? id;
  final String? email;
  final String? name;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      email: record['email'] as String?,
      name: record['name'] as String?,
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      name: json['name'] as String?,
    );
  }

  User copyWith({
    Object? id = _undefined,
    Object? email = _undefined,
    Object? name = _undefined,
  }) {
    return User(
      id: id == _undefined ? this.id : id as int?,
      email: email == _undefined ? this.email : email as String?,
      name: name == _undefined ? this.name : name as String?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (email != null) {
      record['email'] = email;
    }
    if (name != null) {
      record['name'] = name;
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (id != null) {
      json['id'] = id;
    }
    if (email != null) {
      json['email'] = email;
    }
    if (name != null) {
      json['name'] = name;
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
            _deepEquals(id, other.id) &&
            _deepEquals(email, other.email) &&
            _deepEquals(name, other.name);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(email),
    _deepHash(name),
  ]);
}

class UserDelegate {
  const UserDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('User');

  Future<User?> findUnique({
    required UserWhereUniqueInput where,
    UserInclude? include,
    UserSelect? select,
  }) {
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'User',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then((record) => record == null ? null : User.fromRecord(record));
  }

  Future<User?> findFirst({
    UserWhereInput? where,
    UserWhereUniqueInput? cursor,
    List<UserOrderByInput>? orderBy,
    List<UserScalarField>? distinct,
    UserInclude? include,
    UserSelect? select,
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
            model: 'User',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : User.fromRecord(record));
  }

  Future<List<User>> findMany({
    UserWhereInput? where,
    UserWhereUniqueInput? cursor,
    List<UserOrderByInput>? orderBy,
    List<UserScalarField>? distinct,
    UserInclude? include,
    UserSelect? select,
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
            model: 'User',
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
          (records) => records.map(User.fromRecord).toList(growable: false),
        );
  }

  Future<int> count({UserWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'User',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<UserAggregateResult> aggregate({
    UserWhereInput? where,
    List<UserOrderByInput>? orderBy,
    int? skip,
    int? take,
    UserCountAggregateInput? count,
    UserAvgAggregateInput? avg,
    UserSumAggregateInput? sum,
    UserMinAggregateInput? min,
    UserMaxAggregateInput? max,
  }) {
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'User',
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
        .then(UserAggregateResult.fromQueryResult);
  }

  Future<List<UserGroupByRow>> groupBy({
    required List<UserScalarField> by,
    UserWhereInput? where,
    List<UserGroupByOrderByInput>? orderBy,
    UserGroupByHavingInput? having,
    int? skip,
    int? take,
    UserCountAggregateInput? count,
    UserAvgAggregateInput? avg,
    UserSumAggregateInput? sum,
    UserMinAggregateInput? min,
    UserMaxAggregateInput? max,
  }) {
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'User',
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
              .map(UserGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
  }

  Future<User> create({required UserCreateInput data, UserInclude? include}) {
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
    required List<UserCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('User');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(model: 'User', where: selector),
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
                model: 'User',
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

  Future<User> update({
    required UserWhereUniqueInput where,
    required UserUpdateInput data,
    UserInclude? include,
    UserSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('User');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'User', where: predicates),
      );
      if (existing == null) {
        throw StateError('No record found for update in User.');
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

  Future<User> upsert({
    required UserWhereUniqueInput where,
    required UserCreateInput create,
    required UserUpdateInput update,
    UserInclude? include,
    UserSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('User');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'User', where: predicates),
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
    required UserWhereInput where,
    required UserUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('User');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(model: 'User', where: predicates),
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
      UpdateManyQuery(model: 'User', where: predicates, data: data.toData()),
    );
  }

  Future<List<User>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required UserWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'User',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <User>[];
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
      return pagedRecords.map(User.fromRecord).toList(growable: false);
    }
    final projectedRecords = <User>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'User',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'User.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(User.fromRecord(projected));
    }
    return List<User>.unmodifiable(projectedRecords);
  }

  Future<User> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required UserCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('User');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'User',
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
      return User.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'User',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'User create branch could not reload the created record by primary key.',
      );
    }
    return User.fromRecord(projected);
  }

  UserWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return UserWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<User> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required UserUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('User');
    await txDelegate.update(
      UpdateQuery(
        model: 'User',
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
        model: 'User',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'User update branch could not reload the updated record for the provided unique selector.',
      );
    }
    return User.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required UserUpdateInput data,
  }) async {
    return;
  }

  Future<User> delete({
    required UserWhereUniqueInput where,
    UserInclude? include,
    UserSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'User',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(User.fromRecord);
  }

  Future<int> deleteMany({required UserWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'User', where: where.toPredicates()),
    );
  }
}

class UserWhereInput {
  const UserWhereInput({
    this.AND = const <UserWhereInput>[],
    this.OR = const <UserWhereInput>[],
    this.NOT = const <UserWhereInput>[],
    this.id,
    this.idFilter,
    this.email,
    this.emailFilter,
    this.name,
    this.nameFilter,
  });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? email;
  final StringFilter? emailFilter;
  final String? name;
  final StringFilter? nameFilter;

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
    if (email != null) {
      predicates.add(
        QueryPredicate(field: 'email', operator: 'equals', value: email),
      );
    }
    if (emailFilter != null) {
      predicates.addAll(emailFilter!.toPredicates('email'));
    }
    if (name != null) {
      predicates.add(
        QueryPredicate(field: 'name', operator: 'equals', value: name),
      );
    }
    if (nameFilter != null) {
      predicates.addAll(nameFilter!.toPredicates('name'));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class UserWhereUniqueInput {
  const UserWhereUniqueInput({this.id, this.email});

  final int? id;
  final String? email;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (email != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'email', operator: 'equals', value: email),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for UserWhereUniqueInput.',
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
    if (email != null) {
      selectorCount++;
      matches = record['email'] == email;
    }
    if (selectorCount != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for UserWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class UserOrderByInput {
  const UserOrderByInput({this.id, this.email, this.name});

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? name;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(QueryOrderBy(field: 'email', direction: email!));
    }
    if (name != null) {
      orderings.add(QueryOrderBy(field: 'name', direction: name!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField { id, email, name }

class UserCountAggregateInput {
  const UserCountAggregateInput({
    this.all = false,
    this.id = false,
    this.email = false,
    this.name = false,
  });

  final bool all;
  final bool id;
  final bool email;
  final bool name;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (name) {
      fields.add('name');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class UserAvgAggregateInput {
  const UserAvgAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserSumAggregateInput {
  const UserSumAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMinAggregateInput {
  const UserMinAggregateInput({
    this.id = false,
    this.email = false,
    this.name = false,
  });

  final bool id;
  final bool email;
  final bool name;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (name) {
      fields.add('name');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({
    this.id = false,
    this.email = false,
    this.name = false,
  });

  final bool id;
  final bool email;
  final bool name;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (name) {
      fields.add('name');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({this.all, this.id, this.email, this.name});

  final int? all;
  final int? id;
  final int? email;
  final int? name;

  factory UserCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      email: result.fields['email'],
      name: result.fields['name'],
    );
  }
}

class UserAvgAggregateResult {
  const UserAvgAggregateResult({this.id});

  final double? id;

  factory UserAvgAggregateResult.fromMap(Map<String, double?> values) {
    return UserAvgAggregateResult(id: _asDouble(values['id']));
  }
}

class UserSumAggregateResult {
  const UserSumAggregateResult({this.id});

  final int? id;

  factory UserSumAggregateResult.fromMap(Map<String, num?> values) {
    return UserSumAggregateResult(id: values['id']?.toInt());
  }
}

class UserMinAggregateResult {
  const UserMinAggregateResult({this.id, this.email, this.name});

  final int? id;
  final String? email;
  final String? name;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      email: values['email'] as String?,
      name: values['name'] as String?,
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({this.id, this.email, this.name});

  final int? id;
  final String? email;
  final String? name;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      email: values['email'] as String?,
      name: values['name'] as String?,
    );
  }
}

class UserAggregateResult {
  const UserAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return UserAggregateResult(
      count: result.count == null
          ? null
          : UserCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : UserAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : UserSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : UserMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : UserMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class UserGroupByHavingInput {
  const UserGroupByHavingInput({this.id});

  final NumericAggregatesFilter? id;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class UserCountAggregateOrderByInput {
  const UserCountAggregateOrderByInput({
    this.all,
    this.id,
    this.email,
    this.name,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? name;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserAvgAggregateOrderByInput {
  const UserAvgAggregateOrderByInput({this.id});

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

class UserSumAggregateOrderByInput {
  const UserSumAggregateOrderByInput({this.id});

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

class UserMinAggregateOrderByInput {
  const UserMinAggregateOrderByInput({this.id, this.email, this.name});

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? name;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({this.id, this.email, this.name});

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? name;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserGroupByOrderByInput {
  const UserGroupByOrderByInput({
    this.id,
    this.email,
    this.name,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? name;
  final UserCountAggregateOrderByInput? count;
  final UserAvgAggregateOrderByInput? avg;
  final UserSumAggregateOrderByInput? sum;
  final UserMinAggregateOrderByInput? min;
  final UserMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.field(field: 'email', direction: email!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.field(field: 'name', direction: name!));
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

class UserGroupByRow {
  const UserGroupByRow({
    this.id,
    this.email,
    this.name,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? email;
  final String? name;
  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return UserGroupByRow(
      id: row.group['id'] as int?,
      email: row.group['email'] as String?,
      name: row.group['name'] as String?,
      count: row.aggregates.count == null
          ? null
          : UserCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : UserAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : UserSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : UserMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : UserMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class UserInclude {
  const UserInclude();

  QueryInclude? toQueryInclude() {
    return null;
  }
}

class UserSelect {
  const UserSelect({this.id = false, this.email = false, this.name = false});

  final bool id;
  final bool email;
  final bool name;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (name) {
      fields.add('name');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class UserCreateInput {
  const UserCreateInput({this.id, required this.email, required this.name});

  final int? id;
  final String email;
  final String name;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    data['name'] = name;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'email', operator: 'equals', value: email),
    ]);
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

  UserUpdateInput toDeferredRelationUpdateInput() {
    return UserUpdateInput();
  }
}

class UserUpdateInput {
  const UserUpdateInput({this.email, this.emailOps, this.name, this.nameOps});

  final String? email;
  final StringFieldUpdateOperationsInput? emailOps;
  final String? name;
  final StringFieldUpdateOperationsInput? nameOps;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return false;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (email != null && emailOps != null) {
      throw StateError(
        'Only one of email or emailOps may be provided for UserUpdateInput.email.',
      );
    }
    if (email != null) {
      data['email'] = email;
    }
    if (emailOps != null) {
      final ops = emailOps!;
      if (ops.hasSet) {
        data['email'] = ops.set as String?;
      }
    }
    if (name != null && nameOps != null) {
      throw StateError(
        'Only one of name or nameOps may be provided for UserUpdateInput.name.',
      );
    }
    if (name != null) {
      data['name'] = name;
    }
    if (nameOps != null) {
      final ops = nameOps!;
      if (ops.hasSet) {
        data['name'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (email != null && emailOps != null) {
      throw StateError(
        'Only one of email or emailOps may be provided for UserUpdateInput.email.',
      );
    }
    if (email != null) {
      data['email'] = email;
    }
    if (emailOps != null) {
      final ops = emailOps!;
      if (ops.hasSet) {
        data['email'] = ops.set as String?;
      }
    }
    if (name != null && nameOps != null) {
      throw StateError(
        'Only one of name or nameOps may be provided for UserUpdateInput.name.',
      );
    }
    if (name != null) {
      data['name'] = name;
    }
    if (nameOps != null) {
      final ops = nameOps!;
      if (ops.hasSet) {
        data['name'] = ops.set as String?;
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
