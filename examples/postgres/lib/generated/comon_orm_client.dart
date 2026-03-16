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
    enums: <GeneratedEnumMetadata>[
      GeneratedEnumMetadata(
        name: 'UserRole',
        databaseName: 'UserRole',
        values: <String>['admin', 'developer', 'manager'],
      ),
      GeneratedEnumMetadata(
        name: 'TodoStatus',
        databaseName: 'TodoStatus',
        values: <String>['pending', 'inProgress', 'done'],
      ),
    ],
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
          GeneratedFieldMetadata(
            name: 'role',
            databaseName: 'role',
            kind: GeneratedRuntimeFieldKind.enumeration,
            type: 'UserRole',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'todos',
            databaseName: 'todos',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Todo',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'Todo',
              cardinality: GeneratedRuntimeRelationCardinality.many,
              storageKind: GeneratedRuntimeRelationStorageKind.direct,
              localFields: <String>['id'],
              targetFields: <String>['userId'],
              inverseField: 'user',
            ),
          ),
        ],
      ),
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
            name: 'status',
            databaseName: 'status',
            kind: GeneratedRuntimeFieldKind.enumeration,
            type: 'TodoStatus',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
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
            defaultValue: GeneratedFieldDefaultMetadata(
              kind: GeneratedRuntimeDefaultKind.now,
            ),
          ),
          GeneratedFieldMetadata(
            name: 'userId',
            databaseName: 'userId',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'user',
            databaseName: 'user',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'User',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'User',
              cardinality: GeneratedRuntimeRelationCardinality.one,
              storageKind: GeneratedRuntimeRelationStorageKind.direct,
              localFields: <String>['userId'],
              targetFields: <String>['id'],
              inverseField: 'todos',
            ),
          ),
        ],
      ),
    ],
  );
}

enum UserRole { admin, developer, manager }

enum TodoStatus { pending, inProgress, done }

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
  const User({this.id, this.name, this.role, this.todos});

  final int? id;
  final String? name;
  final UserRole? role;
  final List<Todo>? todos;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      name: record['name'] as String?,
      role: record['role'] == null
          ? null
          : UserRole.values.byName(record['role'] as String),
      todos: (record['todos'] as List<Object?>?)
          ?.map((item) => Todo.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      role: json['role'] == null
          ? null
          : UserRole.values.byName(json['role'] as String),
      todos: (json['todos'] as List<Object?>?)
          ?.map((item) => Todo.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  User copyWith({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? role = _undefined,
    Object? todos = _undefined,
  }) {
    return User(
      id: id == _undefined ? this.id : id as int?,
      name: name == _undefined ? this.name : name as String?,
      role: role == _undefined ? this.role : role as UserRole?,
      todos: todos == _undefined ? this.todos : todos as List<Todo>?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (name != null) {
      record['name'] = name;
    }
    if (role != null) {
      record['role'] = role!.name;
    }
    if (todos != null) {
      record['todos'] = todos!
          .map((item) => item.toRecord())
          .toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (id != null) {
      json['id'] = id;
    }
    if (name != null) {
      json['name'] = name;
    }
    if (role != null) {
      json['role'] = role!.name;
    }
    if (todos != null) {
      json['todos'] = todos!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'User(id: $id, name: $name, role: $role, todos: $todos)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
            _deepEquals(id, other.id) &&
            _deepEquals(name, other.name) &&
            _deepEquals(role, other.role) &&
            _deepEquals(todos, other.todos);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(name),
    _deepHash(role),
    _deepHash(todos),
  ]);
}

class Todo {
  const Todo({
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
    this.user,
  });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;
  final User? user;

  factory Todo.fromRecord(Map<String, Object?> record) {
    return Todo(
      id: record['id'] as int?,
      title: record['title'] as String?,
      status: record['status'] == null
          ? null
          : TodoStatus.values.byName(record['status'] as String),
      createdAt: _asDateTime(record['createdAt']),
      userId: record['userId'] as int?,
      user: record['user'] == null
          ? null
          : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Todo.fromJson(Map<String, Object?> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String?,
      status: json['status'] == null
          ? null
          : TodoStatus.values.byName(json['status'] as String),
      createdAt: _asDateTime(json['createdAt']),
      userId: json['userId'] as int?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  Todo copyWith({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? status = _undefined,
    Object? createdAt = _undefined,
    Object? userId = _undefined,
    Object? user = _undefined,
  }) {
    return Todo(
      id: id == _undefined ? this.id : id as int?,
      title: title == _undefined ? this.title : title as String?,
      status: status == _undefined ? this.status : status as TodoStatus?,
      createdAt: createdAt == _undefined
          ? this.createdAt
          : createdAt as DateTime?,
      userId: userId == _undefined ? this.userId : userId as int?,
      user: user == _undefined ? this.user : user as User?,
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
    if (status != null) {
      record['status'] = status!.name;
    }
    if (createdAt != null) {
      record['createdAt'] = createdAt;
    }
    if (userId != null) {
      record['userId'] = userId;
    }
    if (user != null) {
      record['user'] = user!.toRecord();
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
    if (status != null) {
      json['status'] = status!.name;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toIso8601String();
    }
    if (userId != null) {
      json['userId'] = userId;
    }
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() =>
      'Todo(id: $id, title: $title, status: $status, createdAt: $createdAt, userId: $userId, user: $user)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            _deepEquals(id, other.id) &&
            _deepEquals(title, other.title) &&
            _deepEquals(status, other.status) &&
            _deepEquals(createdAt, other.createdAt) &&
            _deepEquals(userId, other.userId) &&
            _deepEquals(user, other.user);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(title),
    _deepHash(status),
    _deepHash(createdAt),
    _deepHash(userId),
    _deepHash(user),
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
    if (data.todos == null) {
      // No nested writes for todos.
    } else {
      final nested = data.todos!;
      final parentReferenceValues = <String, Object?>{
        'userId': _requireRecordValue(
          existing,
          'id',
          'nested direct relation write on User.todos',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.todos.',
        );
      }
      final currentRelatedRecords = await tx.todo._delegate.findMany(
        FindManyQuery(
          model: 'Todo',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'userId',
              operator: 'equals',
              value: parentReferenceValues['userId'],
            ),
          ],
        ),
      );
      if (nested.set != null) {
        final targetRecords = <Map<String, Object?>>[];
        for (final selector in nested.set!) {
          final related = await tx.todo._delegate.findUnique(
            FindUniqueQuery(model: 'Todo', where: selector.toPredicates()),
          );
          if (related == null) {
            throw StateError(
              'No related Todo record found for nested set on User.todos.',
            );
          }
          targetRecords.add(related);
        }
        for (final current in currentRelatedRecords) {
          final stillIncluded = targetRecords.any((target) {
            return current['id'] == target['id'];
          });
          if (!stillIncluded) {
            throw StateError(
              'Nested set is not supported for required relation User.todos when it would disconnect already attached required related records.',
            );
          }
        }
        for (final related in targetRecords) {
          await tx.todo._delegate.update(
            UpdateQuery(
              model: 'Todo',
              where: tx.todo
                  ._primaryKeyWhereUniqueFromRecord(related)
                  .toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.connect) {
        await tx.todo._delegate.update(
          UpdateQuery(
            model: 'Todo',
            where: selector.toPredicates(),
            data: <String, Object?>{'userId': parentReferenceValues['userId']},
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.todo._delegate.findUnique(
          FindUniqueQuery(model: 'Todo', where: entry.where.toPredicates()),
        );
        if (related == null) {
          await tx.todo._delegate.create(
            CreateQuery(
              model: 'Todo',
              data: <String, Object?>{
                ...entry.create.toData(),
                'userId': parentReferenceValues['userId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        } else {
          await tx.todo._delegate.update(
            UpdateQuery(
              model: 'Todo',
              where: entry.where.toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        final related = await tx.todo._delegate.findUnique(
          FindUniqueQuery(model: 'Todo', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Todo record found for nested disconnect on User.todos.',
          );
        }
        final isCurrentlyAttached = currentRelatedRecords.any((current) {
          return current['id'] == related['id'];
        });
        if (isCurrentlyAttached) {
          throw StateError(
            'Nested disconnect is not supported for required relation User.todos when it would disconnect already attached required related records.',
          );
        }
      }
    }
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
    this.name,
    this.nameFilter,
    this.role,
    this.todosSome,
    this.todosNone,
    this.todosEvery,
  });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? name;
  final StringFilter? nameFilter;
  final UserRole? role;
  final TodoWhereInput? todosSome;
  final TodoWhereInput? todosNone;
  final TodoWhereInput? todosEvery;

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
    if (name != null) {
      predicates.add(
        QueryPredicate(field: 'name', operator: 'equals', value: name),
      );
    }
    if (nameFilter != null) {
      predicates.addAll(nameFilter!.toPredicates('name'));
    }
    if (role != null) {
      predicates.add(
        QueryPredicate(
          field: 'role',
          operator: 'equals',
          value: _enumName(role),
        ),
      );
    }
    if (todosSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'todos',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'todos',
              targetModel: 'Todo',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: todosSome!.toPredicates(),
          ),
        ),
      );
    }
    if (todosNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'todos',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'todos',
              targetModel: 'Todo',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: todosNone!.toPredicates(),
          ),
        ),
      );
    }
    if (todosEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'todos',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'todos',
              targetModel: 'Todo',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: todosEvery!.toPredicates(),
          ),
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class UserWhereUniqueInput {
  const UserWhereUniqueInput({this.id});

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
    if (selectorCount != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for UserWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class UserOrderByInput {
  const UserOrderByInput({this.id, this.name, this.role});

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(QueryOrderBy(field: 'name', direction: name!));
    }
    if (role != null) {
      orderings.add(QueryOrderBy(field: 'role', direction: role!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField { id, name, role }

class UserCountAggregateInput {
  const UserCountAggregateInput({
    this.all = false,
    this.id = false,
    this.name = false,
    this.role = false,
  });

  final bool all;
  final bool id;
  final bool name;
  final bool role;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (role) {
      fields.add('role');
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
    this.name = false,
    this.role = false,
  });

  final bool id;
  final bool name;
  final bool role;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (role) {
      fields.add('role');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({
    this.id = false,
    this.name = false,
    this.role = false,
  });

  final bool id;
  final bool name;
  final bool role;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (role) {
      fields.add('role');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({this.all, this.id, this.name, this.role});

  final int? all;
  final int? id;
  final int? name;
  final int? role;

  factory UserCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      name: result.fields['name'],
      role: result.fields['role'],
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
  const UserMinAggregateResult({this.id, this.name, this.role});

  final int? id;
  final String? name;
  final UserRole? role;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      role: values['role'] == null
          ? null
          : UserRole.values.byName(values['role'] as String),
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({this.id, this.name, this.role});

  final int? id;
  final String? name;
  final UserRole? role;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      role: values['role'] == null
          ? null
          : UserRole.values.byName(values['role'] as String),
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
    this.name,
    this.role,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

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
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    if (role != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'role',
          direction: role!,
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
  const UserMinAggregateOrderByInput({this.id, this.name, this.role});

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

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
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    if (role != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'role',
          direction: role!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({this.id, this.name, this.role});

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

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
    if (name != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'name',
          direction: name!,
        ),
      );
    }
    if (role != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'role',
          direction: role!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserGroupByOrderByInput {
  const UserGroupByOrderByInput({
    this.id,
    this.name,
    this.role,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;
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
    if (name != null) {
      orderings.add(GroupByOrderBy.field(field: 'name', direction: name!));
    }
    if (role != null) {
      orderings.add(GroupByOrderBy.field(field: 'role', direction: role!));
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
    this.name,
    this.role,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? name;
  final UserRole? role;
  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return UserGroupByRow(
      id: row.group['id'] as int?,
      name: row.group['name'] as String?,
      role: row.group['role'] == null
          ? null
          : UserRole.values.byName(row.group['role'] as String),
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
  const UserInclude({this.todos = false});

  final bool todos;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (todos) {
      relations['todos'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'todos',
          targetModel: 'Todo',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'userId',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['userId'],
        ),
      );
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class UserSelect {
  const UserSelect({this.id = false, this.name = false, this.role = false});

  final bool id;
  final bool name;
  final bool role;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (role) {
      fields.add('role');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class UserCreateInput {
  const UserCreateInput({
    this.id,
    required this.name,
    required this.role,
    this.todos,
  });

  final int? id;
  final String name;
  final UserRole role;
  final TodoCreateNestedManyWithoutUserInput? todos;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['role'] = _enumName(role);
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
    if (todos != null) {
      writes.addAll(
        todos!.toRelationWrites(
          QueryRelation(
            field: 'todos',
            targetModel: 'Todo',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'userId',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['userId'],
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (todos?.hasDeferredWrites ?? false);
  }

  UserUpdateInput toDeferredRelationUpdateInput() {
    return UserUpdateInput(todos: todos?.toDeferredUpdateWrite());
  }
}

class UserUpdateInput {
  const UserUpdateInput({
    this.name,
    this.nameOps,
    this.role,
    this.roleOps,
    this.todos,
  });

  final String? name;
  final StringFieldUpdateOperationsInput? nameOps;
  final UserRole? role;
  final EnumFieldUpdateOperationsInput<UserRole>? roleOps;
  final TodoUpdateNestedManyWithoutUserInput? todos;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return todos?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
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
    if (role != null && roleOps != null) {
      throw StateError(
        'Only one of role or roleOps may be provided for UserUpdateInput.role.',
      );
    }
    if (role != null) {
      data['role'] = _enumName(role);
    }
    if (roleOps != null) {
      final ops = roleOps!;
      if (ops.hasSet) {
        data['role'] = _enumName(ops.set as UserRole?);
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
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
    if (role != null && roleOps != null) {
      throw StateError(
        'Only one of role or roleOps may be provided for UserUpdateInput.role.',
      );
    }
    if (role != null) {
      data['role'] = _enumName(role);
    }
    if (roleOps != null) {
      final ops = roleOps!;
      if (ops.hasSet) {
        data['role'] = _enumName(ops.set as UserRole?);
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class UserCreateWithoutTodosInput {
  const UserCreateWithoutTodosInput({
    this.id,
    required this.name,
    required this.role,
  });

  final int? id;
  final String name;
  final UserRole role;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['role'] = _enumName(role);
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class TodoConnectOrCreateWithoutUserInput {
  const TodoConnectOrCreateWithoutUserInput({
    required this.where,
    required this.create,
  });

  final TodoWhereUniqueInput where;
  final TodoCreateWithoutUserInput create;
}

class TodoCreateNestedManyWithoutUserInput {
  const TodoCreateNestedManyWithoutUserInput({
    this.create = const <TodoCreateWithoutUserInput>[],
    this.connect = const <TodoWhereUniqueInput>[],
    this.disconnect = const <TodoWhereUniqueInput>[],
    this.connectOrCreate = const <TodoConnectOrCreateWithoutUserInput>[],
    this.set,
  });

  final List<TodoCreateWithoutUserInput> create;
  final List<TodoWhereUniqueInput> connect;
  final List<TodoWhereUniqueInput> disconnect;
  final List<TodoConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<TodoWhereUniqueInput>? set;

  bool get hasDeferredWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    if (create.isEmpty) {
      return const <CreateRelationWrite>[];
    }
    return <CreateRelationWrite>[
      CreateRelationWrite(
        relation: relation,
        records: create.map((item) => item.toData()).toList(growable: false),
      ),
    ];
  }

  TodoUpdateNestedManyWithoutUserInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return TodoUpdateNestedManyWithoutUserInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class TodoUpdateNestedManyWithoutUserInput {
  const TodoUpdateNestedManyWithoutUserInput({
    this.connect = const <TodoWhereUniqueInput>[],
    this.disconnect = const <TodoWhereUniqueInput>[],
    this.connectOrCreate = const <TodoConnectOrCreateWithoutUserInput>[],
    this.set,
  });

  final List<TodoWhereUniqueInput> connect;
  final List<TodoWhereUniqueInput> disconnect;
  final List<TodoConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<TodoWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
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
    if (data.user == null) {
      // No nested writes for user.
    } else {
      final nested = data.user!;
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError(
          'Only one of connect, connectOrCreate or disconnect may be provided for TodoUpdateInput.user.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on Todo.user.',
          );
        }
        await tx._client
            .model('Todo')
            .update(
              UpdateQuery(
                model: 'Todo',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    related,
                    'id',
                    'nested direct relation write on Todo.user',
                  ),
                },
              ),
            );
      }
      if (nested.connectOrCreate != null) {
        final entry = nested.connectOrCreate!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: entry.where.toPredicates()),
        );
        final relatedRecord =
            related ??
            await tx.user._delegate.create(
              CreateQuery(
                model: 'User',
                data: entry.create.toData(),
                nestedCreates: entry.create.toNestedCreates(),
              ),
            );
        await tx._client
            .model('Todo')
            .update(
              UpdateQuery(
                model: 'Todo',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    relatedRecord,
                    'id',
                    'nested direct relation write on Todo.user',
                  ),
                },
              ),
            );
      }
      if (nested.disconnect) {
        throw StateError(
          'Nested disconnect is not supported for required relation Todo.user.',
        );
      }
    }
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
    this.status,
    this.createdAt,
    this.userId,
    this.userIdFilter,
    this.userIs,
    this.userIsNot,
  });

  final List<TodoWhereInput> AND;
  final List<TodoWhereInput> OR;
  final List<TodoWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? title;
  final StringFilter? titleFilter;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;
  final IntFilter? userIdFilter;
  final UserWhereInput? userIs;
  final UserWhereInput? userIsNot;

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
    if (status != null) {
      predicates.add(
        QueryPredicate(
          field: 'status',
          operator: 'equals',
          value: _enumName(status),
        ),
      );
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
    if (userId != null) {
      predicates.add(
        QueryPredicate(field: 'userId', operator: 'equals', value: userId),
      );
    }
    if (userIdFilter != null) {
      predicates.addAll(userIdFilter!.toPredicates('userId'));
    }
    if (userIs != null) {
      predicates.add(
        QueryPredicate(
          field: 'user',
          operator: 'relationIs',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'user',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'userId',
              targetKeyField: 'id',
              localKeyFields: const <String>['userId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: userIs!.toPredicates(),
          ),
        ),
      );
    }
    if (userIsNot != null) {
      predicates.add(
        QueryPredicate(
          field: 'user',
          operator: 'relationIsNot',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'user',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'userId',
              targetKeyField: 'id',
              localKeyFields: const <String>['userId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: userIsNot!.toPredicates(),
          ),
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
  const TodoOrderByInput({
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(QueryOrderBy(field: 'title', direction: title!));
    }
    if (status != null) {
      orderings.add(QueryOrderBy(field: 'status', direction: status!));
    }
    if (createdAt != null) {
      orderings.add(QueryOrderBy(field: 'createdAt', direction: createdAt!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum TodoScalarField { id, title, status, createdAt, userId }

class TodoCountAggregateInput {
  const TodoCountAggregateInput({
    this.all = false,
    this.id = false,
    this.title = false,
    this.status = false,
    this.createdAt = false,
    this.userId = false,
  });

  final bool all;
  final bool id;
  final bool title;
  final bool status;
  final bool createdAt;
  final bool userId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (status) {
      fields.add('status');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (userId) {
      fields.add('userId');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class TodoAvgAggregateInput {
  const TodoAvgAggregateInput({this.id = false, this.userId = false});

  final bool id;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoSumAggregateInput {
  const TodoSumAggregateInput({this.id = false, this.userId = false});

  final bool id;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoMinAggregateInput {
  const TodoMinAggregateInput({
    this.id = false,
    this.title = false,
    this.status = false,
    this.createdAt = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool status;
  final bool createdAt;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (status) {
      fields.add('status');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoMaxAggregateInput {
  const TodoMaxAggregateInput({
    this.id = false,
    this.title = false,
    this.status = false,
    this.createdAt = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool status;
  final bool createdAt;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (status) {
      fields.add('status');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class TodoCountAggregateResult {
  const TodoCountAggregateResult({
    this.all,
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
  });

  final int? all;
  final int? id;
  final int? title;
  final int? status;
  final int? createdAt;
  final int? userId;

  factory TodoCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return TodoCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      title: result.fields['title'],
      status: result.fields['status'],
      createdAt: result.fields['createdAt'],
      userId: result.fields['userId'],
    );
  }
}

class TodoAvgAggregateResult {
  const TodoAvgAggregateResult({this.id, this.userId});

  final double? id;
  final double? userId;

  factory TodoAvgAggregateResult.fromMap(Map<String, double?> values) {
    return TodoAvgAggregateResult(
      id: _asDouble(values['id']),
      userId: _asDouble(values['userId']),
    );
  }
}

class TodoSumAggregateResult {
  const TodoSumAggregateResult({this.id, this.userId});

  final int? id;
  final int? userId;

  factory TodoSumAggregateResult.fromMap(Map<String, num?> values) {
    return TodoSumAggregateResult(
      id: values['id']?.toInt(),
      userId: values['userId']?.toInt(),
    );
  }
}

class TodoMinAggregateResult {
  const TodoMinAggregateResult({
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
  });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;

  factory TodoMinAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMinAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      status: values['status'] == null
          ? null
          : TodoStatus.values.byName(values['status'] as String),
      createdAt: _asDateTime(values['createdAt']),
      userId: values['userId'] as int?,
    );
  }
}

class TodoMaxAggregateResult {
  const TodoMaxAggregateResult({
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
  });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;

  factory TodoMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMaxAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      status: values['status'] == null
          ? null
          : TodoStatus.values.byName(values['status'] as String),
      createdAt: _asDateTime(values['createdAt']),
      userId: values['userId'] as int?,
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
  const TodoGroupByHavingInput({this.id, this.userId});

  final NumericAggregatesFilter? id;
  final NumericAggregatesFilter? userId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    if (userId != null) {
      predicates.addAll(userId!.toPredicates('userId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class TodoCountAggregateOrderByInput {
  const TodoCountAggregateOrderByInput({
    this.all,
    this.id,
    this.title,
    this.status,
    this.createdAt,
    this.userId,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

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
    if (status != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'status',
          direction: status!,
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
    if (userId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'userId',
          direction: userId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoAvgAggregateOrderByInput {
  const TodoAvgAggregateOrderByInput({this.id, this.userId});

  final SortOrder? id;
  final SortOrder? userId;

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
    if (userId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'userId',
          direction: userId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoSumAggregateOrderByInput {
  const TodoSumAggregateOrderByInput({this.id, this.userId});

  final SortOrder? id;
  final SortOrder? userId;

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
    if (userId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'userId',
          direction: userId!,
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
    this.status,
    this.createdAt,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

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
    if (status != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'status',
          direction: status!,
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
    if (userId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'userId',
          direction: userId!,
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
    this.status,
    this.createdAt,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

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
    if (status != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'status',
          direction: status!,
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
    if (userId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'userId',
          direction: userId!,
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
    this.status,
    this.createdAt,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;
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
    if (status != null) {
      orderings.add(GroupByOrderBy.field(field: 'status', direction: status!));
    }
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'createdAt', direction: createdAt!),
      );
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.field(field: 'userId', direction: userId!));
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
    this.status,
    this.createdAt,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;
  final TodoCountAggregateResult? count;
  final TodoAvgAggregateResult? avg;
  final TodoSumAggregateResult? sum;
  final TodoMinAggregateResult? min;
  final TodoMaxAggregateResult? max;

  factory TodoGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return TodoGroupByRow(
      id: row.group['id'] as int?,
      title: row.group['title'] as String?,
      status: row.group['status'] == null
          ? null
          : TodoStatus.values.byName(row.group['status'] as String),
      createdAt: _asDateTime(row.group['createdAt']),
      userId: row.group['userId'] as int?,
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
  const TodoInclude({this.user = false});

  final bool user;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (user) {
      relations['user'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'user',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.one,
          localKeyField: 'userId',
          targetKeyField: 'id',
          localKeyFields: const <String>['userId'],
          targetKeyFields: const <String>['id'],
        ),
      );
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class TodoSelect {
  const TodoSelect({
    this.id = false,
    this.title = false,
    this.status = false,
    this.createdAt = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool status;
  final bool createdAt;
  final bool userId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (status) {
      fields.add('status');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (userId) {
      fields.add('userId');
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
    required this.status,
    this.createdAt,
    required this.userId,
    this.user,
  });

  final int? id;
  final String title;
  final TodoStatus status;
  final DateTime? createdAt;
  final int userId;
  final UserCreateNestedOneWithoutTodosInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    data['status'] = _enumName(status);
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    data['userId'] = userId;
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
    if (user != null) {
      writes.addAll(
        user!.toRelationWrites(
          QueryRelation(
            field: 'user',
            targetModel: 'User',
            cardinality: QueryRelationCardinality.one,
            localKeyField: 'userId',
            targetKeyField: 'id',
            localKeyFields: const <String>['userId'],
            targetKeyFields: const <String>['id'],
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (user?.hasDeferredWrites ?? false);
  }

  TodoUpdateInput toDeferredRelationUpdateInput() {
    return TodoUpdateInput(user: user?.toDeferredUpdateWrite());
  }
}

class TodoUpdateInput {
  const TodoUpdateInput({
    this.title,
    this.titleOps,
    this.status,
    this.statusOps,
    this.createdAt,
    this.createdAtOps,
    this.userId,
    this.userIdOps,
    this.user,
  });

  final String? title;
  final StringFieldUpdateOperationsInput? titleOps;
  final TodoStatus? status;
  final EnumFieldUpdateOperationsInput<TodoStatus>? statusOps;
  final DateTime? createdAt;
  final DateTimeFieldUpdateOperationsInput? createdAtOps;
  final int? userId;
  final IntFieldUpdateOperationsInput? userIdOps;
  final UserUpdateNestedOneWithoutTodosInput? user;

  bool get hasComputedOperators {
    return userIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return user?.hasWrites == true;
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
    if (status != null && statusOps != null) {
      throw StateError(
        'Only one of status or statusOps may be provided for TodoUpdateInput.status.',
      );
    }
    if (status != null) {
      data['status'] = _enumName(status);
    }
    if (statusOps != null) {
      final ops = statusOps!;
      if (ops.hasSet) {
        data['status'] = _enumName(ops.set as TodoStatus?);
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
    if (userId != null && userIdOps != null) {
      throw StateError(
        'Only one of userId or userIdOps may be provided for TodoUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for TodoUpdateInput.userId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for TodoUpdateInput.userId require the current record value before they can be converted to raw update data.',
        );
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
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
    if (status != null && statusOps != null) {
      throw StateError(
        'Only one of status or statusOps may be provided for TodoUpdateInput.status.',
      );
    }
    if (status != null) {
      data['status'] = _enumName(status);
    }
    if (statusOps != null) {
      final ops = statusOps!;
      if (ops.hasSet) {
        data['status'] = _enumName(ops.set as TodoStatus?);
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
    if (userId != null && userIdOps != null) {
      throw StateError(
        'Only one of userId or userIdOps may be provided for TodoUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for TodoUpdateInput.userId.',
        );
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      } else {
        final currentValue = record['userId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment TodoUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement TodoUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class TodoCreateWithoutUserInput {
  const TodoCreateWithoutUserInput({
    this.id,
    required this.title,
    required this.status,
    this.createdAt,
  });

  final int? id;
  final String title;
  final TodoStatus status;
  final DateTime? createdAt;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    data['status'] = _enumName(status);
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutTodosInput {
  const UserConnectOrCreateWithoutTodosInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutTodosInput create;
}

class UserCreateNestedOneWithoutTodosInput {
  const UserCreateNestedOneWithoutTodosInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserCreateWithoutTodosInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutTodosInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites =>
      connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutTodosInput.',
      );
    }
    if (create == null) {
      return const <CreateRelationWrite>[];
    }
    return <CreateRelationWrite>[
      CreateRelationWrite(
        relation: relation,
        records: <Map<String, Object?>>[create!.toData()],
      ),
    ];
  }

  UserUpdateNestedOneWithoutTodosInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutTodosInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutTodosInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class UserUpdateNestedOneWithoutTodosInput {
  const UserUpdateNestedOneWithoutTodosInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutTodosInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites =>
      connect != null || connectOrCreate != null || disconnect;
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
