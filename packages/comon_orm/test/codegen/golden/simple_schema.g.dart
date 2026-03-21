// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

class GeneratedComonOrmClient {
  GeneratedComonOrmClient({required DatabaseAdapter adapter})
    : _client = ComonOrmClient(adapter: adapter, schemaView: runtimeSchemaView);

  GeneratedComonOrmClient._fromClient(this._client);

  static const GeneratedRuntimeSchema runtimeSchema = GeneratedComonOrmMetadata.schema;

  static final RuntimeSchemaView runtimeSchemaView =
      runtimeSchemaViewFromGeneratedSchema(runtimeSchema);

  static InMemoryDatabaseAdapter createInMemoryAdapter() {
    return InMemoryDatabaseAdapter.fromGeneratedSchema(
      schema: runtimeSchema,
    );
  }

  factory GeneratedComonOrmClient.openInMemory() {
    return GeneratedComonOrmClient(adapter: createInMemoryAdapter());
  }

  final ComonOrmClient _client;
  late final UserDelegate user = UserDelegate._(_client);
  late final PostDelegate post = PostDelegate._(_client);

  Future<T> transaction<T>(
    Future<T> Function(GeneratedComonOrmClient tx) action,
  ) {
    return _client.transaction((tx) => action(GeneratedComonOrmClient._fromClient(tx)));
  }

  Future<void> close() async {
    await _client.close();
  }
}

class GeneratedComonOrmMetadata {
  const GeneratedComonOrmMetadata._();

  static const GeneratedRuntimeSchema schema = GeneratedRuntimeSchema(
    datasources: <GeneratedDatasourceMetadata>[
    ],
    enums: <GeneratedEnumMetadata>[
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
            defaultValue: GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.autoincrement),
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
            name: 'posts',
            databaseName: 'posts',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Post',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
            targetModel: 'Post',
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
        name: 'Post',
        databaseName: 'Post',
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
            defaultValue: GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.autoincrement),
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
            inverseField: 'posts',
          ),
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
  const IntFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});

  final Object? set;
  final int? increment;
  final int? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;
}

class DoubleFieldUpdateOperationsInput {
  const DoubleFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});

  final Object? set;
  final double? increment;
  final double? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;
}

class BigIntFieldUpdateOperationsInput {
  const BigIntFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});

  final Object? set;
  final BigInt? increment;
  final BigInt? decrement;

  bool get hasSet => !identical(set, _undefined);
  bool get hasComputedUpdate => increment != null || decrement != null;
  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;
}

class EnumFieldUpdateOperationsInput<T extends Enum> {
  const EnumFieldUpdateOperationsInput({this.set = _undefined});

  final Object? set;

  bool get hasSet => !identical(set, _undefined);
}

class User {
  const User({this.id, this.name, this.email, this.posts, });

  final int? id;
  final String? name;
  final String? email;
  final List<Post>? posts;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      name: record['name'] as String?,
      email: record['email'] as String?,
      posts: (record['posts'] as List<Object?>?)?.map((item) => Post.fromRecord(item as Map<String, Object?>)).toList(growable: false),
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      posts: (json['posts'] as List<Object?>?)?.map((item) => Post.fromJson(item as Map<String, Object?>)).toList(growable: false),
    );
  }

  User copyWith({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? email = _undefined,
    Object? posts = _undefined,
  }) {
    return User(
      id: id == _undefined ? this.id : id as int?,
      name: name == _undefined ? this.name : name as String?,
      email: email == _undefined ? this.email : email as String?,
      posts: posts == _undefined ? this.posts : posts as List<Post>?,
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
    if (email != null) {
      record['email'] = email;
    }
    if (posts != null) {
      record['posts'] = posts!.map((item) => item.toRecord()).toList(growable: false);
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
    if (email != null) {
      json['email'] = email;
    }
    if (posts != null) {
      json['posts'] = posts!.map((item) => item.toJson()).toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email, posts: $posts)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
        _deepEquals(id, other.id) &&
        _deepEquals(name, other.name) &&
        _deepEquals(email, other.email) &&
        _deepEquals(posts, other.posts);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(name),
    _deepHash(email),
    _deepHash(posts),
  ]);
}

class Post {
  const Post({this.id, this.title, this.userId, this.user, });

  final int? id;
  final String? title;
  final int? userId;
  final User? user;

  factory Post.fromRecord(Map<String, Object?> record) {
    return Post(
      id: record['id'] as int?,
      title: record['title'] as String?,
      userId: record['userId'] as int?,
      user: record['user'] == null ? null : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Post.fromJson(Map<String, Object?> json) {
    return Post(
      id: json['id'] as int?,
      title: json['title'] as String?,
      userId: json['userId'] as int?,
      user: json['user'] == null ? null : User.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  Post copyWith({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? userId = _undefined,
    Object? user = _undefined,
  }) {
    return Post(
      id: id == _undefined ? this.id : id as int?,
      title: title == _undefined ? this.title : title as String?,
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
    if (userId != null) {
      json['userId'] = userId;
    }
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Post(id: $id, title: $title, userId: $userId, user: $user)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Post &&
        _deepEquals(id, other.id) &&
        _deepEquals(title, other.title) &&
        _deepEquals(userId, other.userId) &&
        _deepEquals(user, other.user);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(title),
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
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'User',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : User.fromRecord(record));
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
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'User',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : User.fromRecord(record));
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
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findMany(
      FindManyQuery(
        model: 'User',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(User.fromRecord).toList(growable: false));
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
    return _delegate.aggregate(
      AggregateQuery(
        model: 'User',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        skip: skip,
        take: take,
        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),
        avg: avg?.toFields() ?? const <String>{},
        sum: sum?.toFields() ?? const <String>{},
        min: min?.toFields() ?? const <String>{},
        max: max?.toFields() ?? const <String>{},
      ),
    ).then(UserAggregateResult.fromQueryResult);
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
    return _delegate.groupBy(
      GroupByQuery(
        model: 'User',
        by: by.map((field) => field.name).toList(growable: false),
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        having: having?.toAggregatePredicates() ?? const <QueryAggregatePredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toGroupByOrderBy()).toList(growable: false) ?? const <GroupByOrderBy>[],
        skip: skip,
        take: take,
        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),
        avg: avg?.toFields() ?? const <String>{},
        sum: sum?.toFields() ?? const <String>{},
        min: min?.toFields() ?? const <String>{},
        max: max?.toFields() ?? const <String>{},
      ),
    ).then((rows) => rows.map(UserGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<User> create({
    required UserCreateInput data,
    UserInclude? include,
  }) {
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
      final hasDeferredRelationWrites = data.any(
        (entry) => entry.hasDeferredRelationWrites,
      );
      if (!hasDeferredRelationWrites) {
        return txDelegate.createMany(
          CreateManyQuery(
            model: 'User',
            data: data.map((entry) => entry.toData()).toList(growable: false),
            skipDuplicates: skipDuplicates,
          ),
        );
      }
      var createdCount = 0;
      for (final entry in data) {
        try {
          if (entry.hasDeferredRelationWrites) {
            await _performCreateWithRelationWrites(
              tx: tx,
              data: entry,
            );
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
        FindUniqueQuery(
          model: 'User',
          where: predicates,
        ),
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
        FindUniqueQuery(
          model: 'User',
          where: predicates,
        ),
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
          FindManyQuery(
            model: 'User',
            where: predicates,
          ),
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
      UpdateManyQuery(
        model: 'User',
        where: predicates,
        data: data.toData(),
      ),
    );
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
      throw StateError('User create branch could not reload the created record by primary key.');
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
      throw StateError('User update branch could not reload the updated record for the provided unique selector.');
    }
    return User.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required UserUpdateInput data,
  }) async {
    if (data.posts == null) {
      // No nested writes for posts.
    } else {
      final nested = data.posts!;
      final parentReferenceValues = <String, Object?>{
        'userId': _requireRecordValue(existing, 'id', 'nested direct relation write on User.posts'),
      };
      if (nested.set != null && (nested.connect.isNotEmpty || nested.disconnect.isNotEmpty || nested.connectOrCreate.isNotEmpty)) {
        throw StateError('Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.posts.');
      }
      final currentRelatedRecords = await tx.post._delegate.findMany(
        FindManyQuery(
          model: 'Post',
          where: <QueryPredicate>[
            QueryPredicate(field: 'userId', operator: 'equals', value: parentReferenceValues['userId']),
          ],
        ),
      );
      if (nested.set != null) {
        final targetRecords = <Map<String, Object?>>[];
        for (final selector in nested.set!) {
          final related = await tx.post._delegate.findUnique(
            FindUniqueQuery(
              model: 'Post',
              where: selector.toPredicates(),
            ),
          );
          if (related == null) {
            throw StateError('No related Post record found for nested set on User.posts.');
          }
          targetRecords.add(related);
        }
        for (final current in currentRelatedRecords) {
          final stillIncluded = targetRecords.any((target) {
            return current['id'] == target['id']
          ;
          });
          if (!stillIncluded) {
            throw StateError('Nested set is not supported for required relation User.posts when it would disconnect already attached required related records.');
          }
        }
        for (final related in targetRecords) {
          await tx.post._delegate.update(
            UpdateQuery(
              model: 'Post',
              where: tx.post._primaryKeyWhereUniqueFromRecord(related).toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.connect) {
        await tx.post._delegate.update(
          UpdateQuery(
            model: 'Post',
            where: selector.toPredicates(),
            data: <String, Object?>{
              'userId': parentReferenceValues['userId'],
            },
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.post._delegate.findUnique(
          FindUniqueQuery(
            model: 'Post',
            where: entry.where.toPredicates(),
          ),
        );
        if (related == null) {
          await tx.post._delegate.create(
            CreateQuery(
              model: 'Post',
              data: <String, Object?>{...entry.create.toData(),
                'userId': parentReferenceValues['userId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        } else {
          await tx.post._delegate.update(
            UpdateQuery(
              model: 'Post',
              where: entry.where.toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        final related = await tx.post._delegate.findUnique(
          FindUniqueQuery(
            model: 'Post',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related Post record found for nested disconnect on User.posts.');
        }
        final isCurrentlyAttached = currentRelatedRecords.any((current) {
          return current['id'] == related['id']
        ;
        });
        if (isCurrentlyAttached) {
          throw StateError('Nested disconnect is not supported for required relation User.posts when it would disconnect already attached required related records.');
        }
      }
    }
  }


  Future<User> delete({
    required UserWhereUniqueInput where,
    UserInclude? include,
    UserSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'User',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(User.fromRecord);
  }

  Future<int> deleteMany({
    required UserWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'User',
        where: where.toPredicates(),
      ),
    );
  }
}

class UserWhereInput {
  const UserWhereInput({this.AND = const <UserWhereInput>[], this.OR = const <UserWhereInput>[], this.NOT = const <UserWhereInput>[], this.id, this.idFilter, this.name, this.nameFilter, this.email, this.emailFilter, this.postsSome, this.postsNone, this.postsEvery, });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? name;
  final StringFilter? nameFilter;
  final String? email;
  final StringFilter? emailFilter;
  final PostWhereInput? postsSome;
  final PostWhereInput? postsNone;
  final PostWhereInput? postsEvery;

  List<QueryPredicate> toPredicates() {
    final predicates = <QueryPredicate>[];
    if (AND.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'AND', operator: 'logicalAnd', value: QueryLogicalGroup(branches: AND.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (OR.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'OR', operator: 'logicalOr', value: QueryLogicalGroup(branches: OR.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (NOT.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'NOT', operator: 'logicalNot', value: QueryLogicalGroup(branches: NOT.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (id != null) {
      predicates.add(QueryPredicate(field: 'id', operator: 'equals', value: id));
    }
    if (idFilter != null) {
      predicates.addAll(idFilter!.toPredicates('id'));
    }
    if (name != null) {
      predicates.add(QueryPredicate(field: 'name', operator: 'equals', value: name));
    }
    if (nameFilter != null) {
      predicates.addAll(nameFilter!.toPredicates('name'));
    }
    if (email != null) {
      predicates.add(QueryPredicate(field: 'email', operator: 'equals', value: email));
    }
    if (emailFilter != null) {
      predicates.addAll(emailFilter!.toPredicates('email'));
    }
    if (postsSome != null) {
      predicates.add(QueryPredicate(field: 'posts', operator: 'relationSome', value: QueryRelationFilter(relation: QueryRelation(field: 'posts', targetModel: 'Post', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']), predicates: postsSome!.toPredicates())));
    }
    if (postsNone != null) {
      predicates.add(QueryPredicate(field: 'posts', operator: 'relationNone', value: QueryRelationFilter(relation: QueryRelation(field: 'posts', targetModel: 'Post', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']), predicates: postsNone!.toPredicates())));
    }
    if (postsEvery != null) {
      predicates.add(QueryPredicate(field: 'posts', operator: 'relationEvery', value: QueryRelationFilter(relation: QueryRelation(field: 'posts', targetModel: 'Post', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']), predicates: postsEvery!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class UserWhereUniqueInput {
  const UserWhereUniqueInput({this.id, this.email, });

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
      throw StateError('Exactly one unique selector must be provided for UserWhereUniqueInput.');
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }

  QueryCursor toQueryCursor() {
    return QueryCursor(where: toPredicates());
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
      throw StateError('Exactly one unique selector must be provided for UserWhereUniqueInput.');
    }
    return matches;
  }
}

class UserOrderByInput {
  const UserOrderByInput({this.id, this.name, this.email, });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(QueryOrderBy(field: 'name', direction: name!));
    }
    if (email != null) {
      orderings.add(QueryOrderBy(field: 'email', direction: email!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField {
  id,
  name,
  email
}

class UserCountAggregateInput {
  const UserCountAggregateInput({this.all = false, this.id = false, this.name = false, this.email = false, });

  final bool all;
  final bool id;
  final bool name;
  final bool email;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (email) {
      fields.add('email');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class UserAvgAggregateInput {
  const UserAvgAggregateInput({this.id = false, });

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
  const UserSumAggregateInput({this.id = false, });

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
  const UserMinAggregateInput({this.id = false, this.name = false, this.email = false, });

  final bool id;
  final bool name;
  final bool email;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (email) {
      fields.add('email');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({this.id = false, this.name = false, this.email = false, });

  final bool id;
  final bool name;
  final bool email;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (email) {
      fields.add('email');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({this.all, this.id, this.name, this.email, });

  final int? all;
  final int? id;
  final int? name;
  final int? email;

  factory UserCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      name: result.fields['name'],
      email: result.fields['email'],
    );
  }
}

class UserAvgAggregateResult {
  const UserAvgAggregateResult({this.id, });

  final double? id;

  factory UserAvgAggregateResult.fromMap(Map<String, double?> values) {
    return UserAvgAggregateResult(
      id: _asDouble(values['id']),
    );
  }
}

class UserSumAggregateResult {
  const UserSumAggregateResult({this.id, });

  final int? id;

  factory UserSumAggregateResult.fromMap(Map<String, num?> values) {
    return UserSumAggregateResult(
      id: values['id']?.toInt(),
    );
  }
}

class UserMinAggregateResult {
  const UserMinAggregateResult({this.id, this.name, this.email, });

  final int? id;
  final String? name;
  final String? email;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      email: values['email'] as String?,
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({this.id, this.name, this.email, });

  final int? id;
  final String? name;
  final String? email;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      email: values['email'] as String?,
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
      count: result.count == null ? null : UserCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : UserAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : UserSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : UserMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : UserMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class UserGroupByHavingInput {
  const UserGroupByHavingInput({this.id, });

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
  const UserCountAggregateOrderByInput({this.all, this.id, this.name, this.email, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'email', direction: email!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserAvgAggregateOrderByInput {
  const UserAvgAggregateOrderByInput({this.id, });

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserSumAggregateOrderByInput {
  const UserSumAggregateOrderByInput({this.id, });

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMinAggregateOrderByInput {
  const UserMinAggregateOrderByInput({this.id, this.name, this.email, });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'email', direction: email!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({this.id, this.name, this.email, });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'email', direction: email!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserGroupByOrderByInput {
  const UserGroupByOrderByInput({this.id, this.name, this.email, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
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
    if (email != null) {
      orderings.add(GroupByOrderBy.field(field: 'email', direction: email!));
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
  const UserGroupByRow({this.id, this.name, this.email, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final String? name;
  final String? email;
  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return UserGroupByRow(
      id: row.group['id'] as int?,
      name: row.group['name'] as String?,
      email: row.group['email'] as String?,
      count: row.aggregates.count == null ? null : UserCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : UserAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : UserSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : UserMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : UserMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class UserInclude {
  const UserInclude({this.posts = false, });

  final bool posts;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (posts) {
      relations['posts'] = QueryIncludeEntry(relation: QueryRelation(field: 'posts', targetModel: 'Post', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class UserSelect {
  const UserSelect({this.id = false, this.name = false, this.email = false, });

  final bool id;
  final bool name;
  final bool email;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (name) {
      fields.add('name');
    }
    if (email) {
      fields.add('email');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class UserCreateInput {
  const UserCreateInput({this.id, required this.name, required this.email, this.posts, });

  final int? id;
  final String name;
  final String email;
  final PostCreateNestedManyWithoutUserInput? posts;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['email'] = email;
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
    return List<List<QueryPredicate>>.unmodifiable(selectors.map(List<QueryPredicate>.unmodifiable));
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (posts != null) {
      writes.addAll(posts!.toRelationWrites(QueryRelation(field: 'posts', targetModel: 'Post', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (posts?.hasDeferredWrites ?? false);
  }

  UserUpdateInput toDeferredRelationUpdateInput() {
    return UserUpdateInput(
      posts: posts?.toDeferredUpdateWrite(),
    );
  }
}

class UserUpdateInput {
  const UserUpdateInput({this.name, this.nameOps, this.email, this.emailOps, this.posts, });

  final String? name;
  final StringFieldUpdateOperationsInput? nameOps;
  final String? email;
  final StringFieldUpdateOperationsInput? emailOps;
  final PostUpdateNestedManyWithoutUserInput? posts;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return posts?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (name != null && nameOps != null) {
      throw StateError('Only one of name or nameOps may be provided for UserUpdateInput.name.');
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
    if (email != null && emailOps != null) {
      throw StateError('Only one of email or emailOps may be provided for UserUpdateInput.email.');
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
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (name != null && nameOps != null) {
      throw StateError('Only one of name or nameOps may be provided for UserUpdateInput.name.');
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
    if (email != null && emailOps != null) {
      throw StateError('Only one of email or emailOps may be provided for UserUpdateInput.email.');
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
    return Map<String, Object?>.unmodifiable(data);
  }
}

class UserCreateWithoutPostsInput {
  const UserCreateWithoutPostsInput({this.id, required this.name, required this.email, });

  final int? id;
  final String name;
  final String email;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['email'] = email;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class PostConnectOrCreateWithoutUserInput {
  const PostConnectOrCreateWithoutUserInput({required this.where, required this.create});

  final PostWhereUniqueInput where;
  final PostCreateWithoutUserInput create;
}

class PostCreateNestedManyWithoutUserInput {
  const PostCreateNestedManyWithoutUserInput({this.create = const <PostCreateWithoutUserInput>[], this.connect = const <PostWhereUniqueInput>[], this.disconnect = const <PostWhereUniqueInput>[], this.connectOrCreate = const <PostConnectOrCreateWithoutUserInput>[], this.set});

  final List<PostCreateWithoutUserInput> create;
  final List<PostWhereUniqueInput> connect;
  final List<PostWhereUniqueInput> disconnect;
  final List<PostConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<PostWhereUniqueInput>? set;

  bool get hasDeferredWrites => connect.isNotEmpty || disconnect.isNotEmpty || connectOrCreate.isNotEmpty || set != null;

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

  PostUpdateNestedManyWithoutUserInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return PostUpdateNestedManyWithoutUserInput(connect: connect, disconnect: disconnect, connectOrCreate: connectOrCreate, set: set);
  }
}

class PostUpdateNestedManyWithoutUserInput {
  const PostUpdateNestedManyWithoutUserInput({this.connect = const <PostWhereUniqueInput>[], this.disconnect = const <PostWhereUniqueInput>[], this.connectOrCreate = const <PostConnectOrCreateWithoutUserInput>[], this.set});

  final List<PostWhereUniqueInput> connect;
  final List<PostWhereUniqueInput> disconnect;
  final List<PostConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<PostWhereUniqueInput>? set;

  bool get hasWrites => connect.isNotEmpty || disconnect.isNotEmpty || connectOrCreate.isNotEmpty || set != null;
}

class PostDelegate {
  const PostDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Post');

  Future<Post?> findUnique({
    required PostWhereUniqueInput where,
    PostInclude? include,
    PostSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'Post',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : Post.fromRecord(record));
  }

  Future<Post?> findFirst({
    PostWhereInput? where,
    PostWhereUniqueInput? cursor,
    List<PostOrderByInput>? orderBy,
    List<PostScalarField>? distinct,
    PostInclude? include,
    PostSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'Post',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : Post.fromRecord(record));
  }

  Future<List<Post>> findMany({
    PostWhereInput? where,
    PostWhereUniqueInput? cursor,
    List<PostOrderByInput>? orderBy,
    List<PostScalarField>? distinct,
    PostInclude? include,
    PostSelect? select,
    int? skip,
    int? take,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findMany(
      FindManyQuery(
        model: 'Post',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(Post.fromRecord).toList(growable: false));
  }

  Future<int> count({PostWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Post',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<PostAggregateResult> aggregate({
    PostWhereInput? where,
    List<PostOrderByInput>? orderBy,
    int? skip,
    int? take,
    PostCountAggregateInput? count,
    PostAvgAggregateInput? avg,
    PostSumAggregateInput? sum,
    PostMinAggregateInput? min,
    PostMaxAggregateInput? max,
  }) {
    return _delegate.aggregate(
      AggregateQuery(
        model: 'Post',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        skip: skip,
        take: take,
        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),
        avg: avg?.toFields() ?? const <String>{},
        sum: sum?.toFields() ?? const <String>{},
        min: min?.toFields() ?? const <String>{},
        max: max?.toFields() ?? const <String>{},
      ),
    ).then(PostAggregateResult.fromQueryResult);
  }

  Future<List<PostGroupByRow>> groupBy({
    required List<PostScalarField> by,
    PostWhereInput? where,
    List<PostGroupByOrderByInput>? orderBy,
    PostGroupByHavingInput? having,
    int? skip,
    int? take,
    PostCountAggregateInput? count,
    PostAvgAggregateInput? avg,
    PostSumAggregateInput? sum,
    PostMinAggregateInput? min,
    PostMaxAggregateInput? max,
  }) {
    return _delegate.groupBy(
      GroupByQuery(
        model: 'Post',
        by: by.map((field) => field.name).toList(growable: false),
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        having: having?.toAggregatePredicates() ?? const <QueryAggregatePredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toGroupByOrderBy()).toList(growable: false) ?? const <GroupByOrderBy>[],
        skip: skip,
        take: take,
        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),
        avg: avg?.toFields() ?? const <String>{},
        sum: sum?.toFields() ?? const <String>{},
        min: min?.toFields() ?? const <String>{},
        max: max?.toFields() ?? const <String>{},
      ),
    ).then((rows) => rows.map(PostGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<Post> create({
    required PostCreateInput data,
    PostInclude? include,
  }) {
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
    required List<PostCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Post');
      final hasDeferredRelationWrites = data.any(
        (entry) => entry.hasDeferredRelationWrites,
      );
      if (!hasDeferredRelationWrites) {
        return txDelegate.createMany(
          CreateManyQuery(
            model: 'Post',
            data: data.map((entry) => entry.toData()).toList(growable: false),
            skipDuplicates: skipDuplicates,
          ),
        );
      }
      var createdCount = 0;
      for (final entry in data) {
        try {
          if (entry.hasDeferredRelationWrites) {
            await _performCreateWithRelationWrites(
              tx: tx,
              data: entry,
            );
          } else {
            await txDelegate.create(
              CreateQuery(
                model: 'Post',
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

  Future<Post> update({
    required PostWhereUniqueInput where,
    required PostUpdateInput data,
    PostInclude? include,
    PostSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Post');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Post',
          where: predicates,
        ),
      );
      if (existing == null) {
        throw StateError('No record found for update in Post.');
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

  Future<Post> upsert({
    required PostWhereUniqueInput where,
    required PostCreateInput create,
    required PostUpdateInput update,
    PostInclude? include,
    PostSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Post');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Post',
          where: predicates,
        ),
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
    required PostWhereInput where,
    required PostUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Post');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(
            model: 'Post',
            where: predicates,
          ),
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
      UpdateManyQuery(
        model: 'Post',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<Post> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required PostCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Post');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Post',
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
      return Post.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Post',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Post create branch could not reload the created record by primary key.');
    }
    return Post.fromRecord(projected);
  }

  PostWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return PostWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<Post> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required PostUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Post');
    await txDelegate.update(
      UpdateQuery(
        model: 'Post',
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
        model: 'Post',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Post update branch could not reload the updated record for the provided unique selector.');
    }
    return Post.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required PostUpdateInput data,
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
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for PostUpdateInput.user.');
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(
            model: 'User',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related User record found for nested connect on Post.user.');
        }
        await tx._client.model('Post').update(
          UpdateQuery(
            model: 'Post',
            where: predicates,
            data: <String, Object?>{
              'userId': _requireRecordValue(related, 'id', 'nested direct relation write on Post.user'),
            },
          ),
        );
      }
      if (nested.connectOrCreate != null) {
        final entry = nested.connectOrCreate!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(
            model: 'User',
            where: entry.where.toPredicates(),
          ),
        );
        final relatedRecord = related ??
            await tx.user._delegate.create(
              CreateQuery(
                model: 'User',
                data: entry.create.toData(),
                nestedCreates: entry.create.toNestedCreates(),
              ),
            );
        await tx._client.model('Post').update(
          UpdateQuery(
            model: 'Post',
            where: predicates,
            data: <String, Object?>{
              'userId': _requireRecordValue(relatedRecord, 'id', 'nested direct relation write on Post.user'),
            },
          ),
        );
      }
      if (nested.disconnect) {
        throw StateError('Nested disconnect is not supported for required relation Post.user.');
      }
    }
  }


  Future<Post> delete({
    required PostWhereUniqueInput where,
    PostInclude? include,
    PostSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'Post',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Post.fromRecord);
  }

  Future<int> deleteMany({
    required PostWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'Post',
        where: where.toPredicates(),
      ),
    );
  }
}

class PostWhereInput {
  const PostWhereInput({this.AND = const <PostWhereInput>[], this.OR = const <PostWhereInput>[], this.NOT = const <PostWhereInput>[], this.id, this.idFilter, this.title, this.titleFilter, this.userId, this.userIdFilter, this.userIs, this.userIsNot, });

  final List<PostWhereInput> AND;
  final List<PostWhereInput> OR;
  final List<PostWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? title;
  final StringFilter? titleFilter;
  final int? userId;
  final IntFilter? userIdFilter;
  final UserWhereInput? userIs;
  final UserWhereInput? userIsNot;

  List<QueryPredicate> toPredicates() {
    final predicates = <QueryPredicate>[];
    if (AND.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'AND', operator: 'logicalAnd', value: QueryLogicalGroup(branches: AND.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (OR.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'OR', operator: 'logicalOr', value: QueryLogicalGroup(branches: OR.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (NOT.isNotEmpty) {
      predicates.add(QueryPredicate(field: 'NOT', operator: 'logicalNot', value: QueryLogicalGroup(branches: NOT.map((entry) => entry.toPredicates()).toList(growable: false))));
    }
    if (id != null) {
      predicates.add(QueryPredicate(field: 'id', operator: 'equals', value: id));
    }
    if (idFilter != null) {
      predicates.addAll(idFilter!.toPredicates('id'));
    }
    if (title != null) {
      predicates.add(QueryPredicate(field: 'title', operator: 'equals', value: title));
    }
    if (titleFilter != null) {
      predicates.addAll(titleFilter!.toPredicates('title'));
    }
    if (userId != null) {
      predicates.add(QueryPredicate(field: 'userId', operator: 'equals', value: userId));
    }
    if (userIdFilter != null) {
      predicates.addAll(userIdFilter!.toPredicates('userId'));
    }
    if (userIs != null) {
      predicates.add(QueryPredicate(field: 'user', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id', localKeyFields: const <String>['userId'], targetKeyFields: const <String>['id']), predicates: userIs!.toPredicates())));
    }
    if (userIsNot != null) {
      predicates.add(QueryPredicate(field: 'user', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id', localKeyFields: const <String>['userId'], targetKeyFields: const <String>['id']), predicates: userIsNot!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class PostWhereUniqueInput {
  const PostWhereUniqueInput({this.id, });

  final int? id;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for PostWhereUniqueInput.');
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }

  QueryCursor toQueryCursor() {
    return QueryCursor(where: toPredicates());
  }

  bool matchesRecord(Map<String, Object?> record) {
    var selectorCount = 0;
    var matches = false;
    if (id != null) {
      selectorCount++;
      matches = record['id'] == id;
    }
    if (selectorCount != 1) {
      throw StateError('Exactly one unique selector must be provided for PostWhereUniqueInput.');
    }
    return matches;
  }
}

class PostOrderByInput {
  const PostOrderByInput({this.id, this.title, this.userId, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? userId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(QueryOrderBy(field: 'title', direction: title!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum PostScalarField {
  id,
  title,
  userId
}

class PostCountAggregateInput {
  const PostCountAggregateInput({this.all = false, this.id = false, this.title = false, this.userId = false, });

  final bool all;
  final bool id;
  final bool title;
  final bool userId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (userId) {
      fields.add('userId');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class PostAvgAggregateInput {
  const PostAvgAggregateInput({this.id = false, this.userId = false, });

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

class PostSumAggregateInput {
  const PostSumAggregateInput({this.id = false, this.userId = false, });

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

class PostMinAggregateInput {
  const PostMinAggregateInput({this.id = false, this.title = false, this.userId = false, });

  final bool id;
  final bool title;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostMaxAggregateInput {
  const PostMaxAggregateInput({this.id = false, this.title = false, this.userId = false, });

  final bool id;
  final bool title;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostCountAggregateResult {
  const PostCountAggregateResult({this.all, this.id, this.title, this.userId, });

  final int? all;
  final int? id;
  final int? title;
  final int? userId;

  factory PostCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return PostCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      title: result.fields['title'],
      userId: result.fields['userId'],
    );
  }
}

class PostAvgAggregateResult {
  const PostAvgAggregateResult({this.id, this.userId, });

  final double? id;
  final double? userId;

  factory PostAvgAggregateResult.fromMap(Map<String, double?> values) {
    return PostAvgAggregateResult(
      id: _asDouble(values['id']),
      userId: _asDouble(values['userId']),
    );
  }
}

class PostSumAggregateResult {
  const PostSumAggregateResult({this.id, this.userId, });

  final int? id;
  final int? userId;

  factory PostSumAggregateResult.fromMap(Map<String, num?> values) {
    return PostSumAggregateResult(
      id: values['id']?.toInt(),
      userId: values['userId']?.toInt(),
    );
  }
}

class PostMinAggregateResult {
  const PostMinAggregateResult({this.id, this.title, this.userId, });

  final int? id;
  final String? title;
  final int? userId;

  factory PostMinAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMinAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      userId: values['userId'] as int?,
    );
  }
}

class PostMaxAggregateResult {
  const PostMaxAggregateResult({this.id, this.title, this.userId, });

  final int? id;
  final String? title;
  final int? userId;

  factory PostMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMaxAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      userId: values['userId'] as int?,
    );
  }
}

class PostAggregateResult {
  const PostAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final PostCountAggregateResult? count;
  final PostAvgAggregateResult? avg;
  final PostSumAggregateResult? sum;
  final PostMinAggregateResult? min;
  final PostMaxAggregateResult? max;

  factory PostAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return PostAggregateResult(
      count: result.count == null ? null : PostCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : PostAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : PostSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : PostMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : PostMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class PostGroupByHavingInput {
  const PostGroupByHavingInput({this.id, this.userId, });

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

class PostCountAggregateOrderByInput {
  const PostCountAggregateOrderByInput({this.all, this.id, this.title, this.userId, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostAvgAggregateOrderByInput {
  const PostAvgAggregateOrderByInput({this.id, this.userId, });

  final SortOrder? id;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostSumAggregateOrderByInput {
  const PostSumAggregateOrderByInput({this.id, this.userId, });

  final SortOrder? id;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostMinAggregateOrderByInput {
  const PostMinAggregateOrderByInput({this.id, this.title, this.userId, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostMaxAggregateOrderByInput {
  const PostMaxAggregateOrderByInput({this.id, this.title, this.userId, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostGroupByOrderByInput {
  const PostGroupByOrderByInput({this.id, this.title, this.userId, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? userId;
  final PostCountAggregateOrderByInput? count;
  final PostAvgAggregateOrderByInput? avg;
  final PostSumAggregateOrderByInput? sum;
  final PostMinAggregateOrderByInput? min;
  final PostMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.field(field: 'title', direction: title!));
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

class PostGroupByRow {
  const PostGroupByRow({this.id, this.title, this.userId, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final String? title;
  final int? userId;
  final PostCountAggregateResult? count;
  final PostAvgAggregateResult? avg;
  final PostSumAggregateResult? sum;
  final PostMinAggregateResult? min;
  final PostMaxAggregateResult? max;

  factory PostGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return PostGroupByRow(
      id: row.group['id'] as int?,
      title: row.group['title'] as String?,
      userId: row.group['userId'] as int?,
      count: row.aggregates.count == null ? null : PostCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : PostAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : PostSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : PostMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : PostMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class PostInclude {
  const PostInclude({this.user = false, });

  final bool user;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (user) {
      relations['user'] = QueryIncludeEntry(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id', localKeyFields: const <String>['userId'], targetKeyFields: const <String>['id']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class PostSelect {
  const PostSelect({this.id = false, this.title = false, this.userId = false, });

  final bool id;
  final bool title;
  final bool userId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
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

class PostCreateInput {
  const PostCreateInput({this.id, required this.title, required this.userId, this.user, });

  final int? id;
  final String title;
  final int userId;
  final UserCreateNestedOneWithoutPostsInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
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
    return List<List<QueryPredicate>>.unmodifiable(selectors.map(List<QueryPredicate>.unmodifiable));
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (user != null) {
      writes.addAll(user!.toRelationWrites(QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id', localKeyFields: const <String>['userId'], targetKeyFields: const <String>['id'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (user?.hasDeferredWrites ?? false);
  }

  PostUpdateInput toDeferredRelationUpdateInput() {
    return PostUpdateInput(
      user: user?.toDeferredUpdateWrite(),
    );
  }
}

class PostUpdateInput {
  const PostUpdateInput({this.title, this.titleOps, this.userId, this.userIdOps, this.user, });

  final String? title;
  final StringFieldUpdateOperationsInput? titleOps;
  final int? userId;
  final IntFieldUpdateOperationsInput? userIdOps;
  final UserUpdateNestedOneWithoutPostsInput? user;

  bool get hasComputedOperators {
    return userIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return user?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (title != null && titleOps != null) {
      throw StateError('Only one of title or titleOps may be provided for PostUpdateInput.title.');
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
    if (userId != null && userIdOps != null) {
      throw StateError('Only one of userId or userIdOps may be provided for PostUpdateInput.userId.');
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for PostUpdateInput.userId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for PostUpdateInput.userId require the current record value before they can be converted to raw update data.');
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
      throw StateError('Only one of title or titleOps may be provided for PostUpdateInput.title.');
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
    if (userId != null && userIdOps != null) {
      throw StateError('Only one of userId or userIdOps may be provided for PostUpdateInput.userId.');
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for PostUpdateInput.userId.');
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      } else {
        final currentValue = record['userId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment PostUpdateInput.userId because the current value is null.');
          }
          data['userId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement PostUpdateInput.userId because the current value is null.');
          }
          data['userId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class PostCreateWithoutUserInput {
  const PostCreateWithoutUserInput({this.id, required this.title, });

  final int? id;
  final String title;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutPostsInput {
  const UserConnectOrCreateWithoutPostsInput({required this.where, required this.create});

  final UserWhereUniqueInput where;
  final UserCreateWithoutPostsInput create;
}

class UserCreateNestedOneWithoutPostsInput {
  const UserCreateNestedOneWithoutPostsInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final UserCreateWithoutPostsInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutPostsInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutPostsInput.');
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

  UserUpdateNestedOneWithoutPostsInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutPostsInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutPostsInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class UserUpdateNestedOneWithoutPostsInput {
  const UserUpdateNestedOneWithoutPostsInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutPostsInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;
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
    final entries = value.entries
        .map((entry) => Object.hash(_deepHash(entry.key), _deepHash(entry.value)))
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
    throw StateError(
      'Missing required key "$field" for $context.',
    );
  }
  return value;
}

bool _isSkippableDuplicateError(Object error) {
  final code = _errorCode(error);
  if (code == '23505') {
    return true;
  }
  final normalized = error.toString().toLowerCase();
  return normalized.contains('duplicate key value violates unique constraint') ||
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

