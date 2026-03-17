// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
// schema-hash: 103cfa960ef080b83d9f425f6c34036e44282b071ec4b0ed3b1bd7f448ac0d60
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
  late final ProfileDelegate profile = ProfileDelegate._(_client);
  late final AccountDelegate account = AccountDelegate._(_client);
  late final AccountProfileDelegate accountProfile = AccountProfileDelegate._(_client);

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
            name: 'profile',
            databaseName: 'profile',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Profile',
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
            targetModel: 'Profile',
            cardinality: GeneratedRuntimeRelationCardinality.one,
            storageKind: GeneratedRuntimeRelationStorageKind.direct,
            localFields: <String>['id'],
            targetFields: <String>['userId'],
            inverseField: 'user',
          ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Profile',
        databaseName: 'Profile',
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
          ),
          GeneratedFieldMetadata(
            name: 'userId',
            databaseName: 'userId',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: true,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'bio',
            databaseName: 'bio',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: true,
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
            inverseField: 'profile',
          ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Account',
        databaseName: 'Account',
        primaryKeyFields: <String>['tenantId', 'slug'],
        compoundUniqueFieldSets: <List<String>>[],
        fields: <GeneratedFieldMetadata>[
          GeneratedFieldMetadata(
            name: 'tenantId',
            databaseName: 'tenantId',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'slug',
            databaseName: 'slug',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'profile',
            databaseName: 'profile',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'AccountProfile',
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
            targetModel: 'AccountProfile',
            cardinality: GeneratedRuntimeRelationCardinality.one,
            storageKind: GeneratedRuntimeRelationStorageKind.direct,
            localFields: <String>['tenantId', 'slug'],
            targetFields: <String>['tenantId', 'accountSlug'],
            inverseField: 'account',
          ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'AccountProfile',
        databaseName: 'AccountProfile',
        primaryKeyFields: <String>['id'],
        compoundUniqueFieldSets: <List<String>>[<String>['tenantId', 'accountSlug']],
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
          ),
          GeneratedFieldMetadata(
            name: 'tenantId',
            databaseName: 'tenantId',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'accountSlug',
            databaseName: 'accountSlug',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'bio',
            databaseName: 'bio',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'account',
            databaseName: 'account',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Account',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
            targetModel: 'Account',
            cardinality: GeneratedRuntimeRelationCardinality.one,
            storageKind: GeneratedRuntimeRelationStorageKind.direct,
            localFields: <String>['tenantId', 'accountSlug'],
            targetFields: <String>['tenantId', 'slug'],
            inverseField: 'profile',
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
  const User({this.id, this.email, this.profile, });

  final int? id;
  final String? email;
  final Profile? profile;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      email: record['email'] as String?,
      profile: record['profile'] == null ? null : Profile.fromRecord(record['profile'] as Map<String, Object?>),
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      profile: json['profile'] == null ? null : Profile.fromJson(json['profile'] as Map<String, Object?>),
    );
  }

  User copyWith({
    Object? id = _undefined,
    Object? email = _undefined,
    Object? profile = _undefined,
  }) {
    return User(
      id: id == _undefined ? this.id : id as int?,
      email: email == _undefined ? this.email : email as String?,
      profile: profile == _undefined ? this.profile : profile as Profile?,
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
    if (profile != null) {
      record['profile'] = profile!.toRecord();
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
    if (profile != null) {
      json['profile'] = profile!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'User(id: $id, email: $email, profile: $profile)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
        _deepEquals(id, other.id) &&
        _deepEquals(email, other.email) &&
        _deepEquals(profile, other.profile);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(email),
    _deepHash(profile),
  ]);
}

class Profile {
  const Profile({this.id, this.userId, this.bio, this.user, });

  final int? id;
  final int? userId;
  final String? bio;
  final User? user;

  factory Profile.fromRecord(Map<String, Object?> record) {
    return Profile(
      id: record['id'] as int?,
      userId: record['userId'] as int?,
      bio: record['bio'] as String?,
      user: record['user'] == null ? null : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Profile.fromJson(Map<String, Object?> json) {
    return Profile(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      bio: json['bio'] as String?,
      user: json['user'] == null ? null : User.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  Profile copyWith({
    Object? id = _undefined,
    Object? userId = _undefined,
    Object? bio = _undefined,
    Object? user = _undefined,
  }) {
    return Profile(
      id: id == _undefined ? this.id : id as int?,
      userId: userId == _undefined ? this.userId : userId as int?,
      bio: bio == _undefined ? this.bio : bio as String?,
      user: user == _undefined ? this.user : user as User?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (userId != null) {
      record['userId'] = userId;
    }
    if (bio != null) {
      record['bio'] = bio;
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
    if (userId != null) {
      json['userId'] = userId;
    }
    if (bio != null) {
      json['bio'] = bio;
    }
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Profile(id: $id, userId: $userId, bio: $bio, user: $user)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Profile &&
        _deepEquals(id, other.id) &&
        _deepEquals(userId, other.userId) &&
        _deepEquals(bio, other.bio) &&
        _deepEquals(user, other.user);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(userId),
    _deepHash(bio),
    _deepHash(user),
  ]);
}

class Account {
  const Account({this.tenantId, this.slug, this.profile, });

  final int? tenantId;
  final String? slug;
  final AccountProfile? profile;

  factory Account.fromRecord(Map<String, Object?> record) {
    return Account(
      tenantId: record['tenantId'] as int?,
      slug: record['slug'] as String?,
      profile: record['profile'] == null ? null : AccountProfile.fromRecord(record['profile'] as Map<String, Object?>),
    );
  }

  factory Account.fromJson(Map<String, Object?> json) {
    return Account(
      tenantId: json['tenantId'] as int?,
      slug: json['slug'] as String?,
      profile: json['profile'] == null ? null : AccountProfile.fromJson(json['profile'] as Map<String, Object?>),
    );
  }

  Account copyWith({
    Object? tenantId = _undefined,
    Object? slug = _undefined,
    Object? profile = _undefined,
  }) {
    return Account(
      tenantId: tenantId == _undefined ? this.tenantId : tenantId as int?,
      slug: slug == _undefined ? this.slug : slug as String?,
      profile: profile == _undefined ? this.profile : profile as AccountProfile?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (tenantId != null) {
      record['tenantId'] = tenantId;
    }
    if (slug != null) {
      record['slug'] = slug;
    }
    if (profile != null) {
      record['profile'] = profile!.toRecord();
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (tenantId != null) {
      json['tenantId'] = tenantId;
    }
    if (slug != null) {
      json['slug'] = slug;
    }
    if (profile != null) {
      json['profile'] = profile!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Account(tenantId: $tenantId, slug: $slug, profile: $profile)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Account &&
        _deepEquals(tenantId, other.tenantId) &&
        _deepEquals(slug, other.slug) &&
        _deepEquals(profile, other.profile);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(tenantId),
    _deepHash(slug),
    _deepHash(profile),
  ]);
}

class AccountProfile {
  const AccountProfile({this.id, this.tenantId, this.accountSlug, this.bio, this.account, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;
  final Account? account;

  factory AccountProfile.fromRecord(Map<String, Object?> record) {
    return AccountProfile(
      id: record['id'] as int?,
      tenantId: record['tenantId'] as int?,
      accountSlug: record['accountSlug'] as String?,
      bio: record['bio'] as String?,
      account: record['account'] == null ? null : Account.fromRecord(record['account'] as Map<String, Object?>),
    );
  }

  factory AccountProfile.fromJson(Map<String, Object?> json) {
    return AccountProfile(
      id: json['id'] as int?,
      tenantId: json['tenantId'] as int?,
      accountSlug: json['accountSlug'] as String?,
      bio: json['bio'] as String?,
      account: json['account'] == null ? null : Account.fromJson(json['account'] as Map<String, Object?>),
    );
  }

  AccountProfile copyWith({
    Object? id = _undefined,
    Object? tenantId = _undefined,
    Object? accountSlug = _undefined,
    Object? bio = _undefined,
    Object? account = _undefined,
  }) {
    return AccountProfile(
      id: id == _undefined ? this.id : id as int?,
      tenantId: tenantId == _undefined ? this.tenantId : tenantId as int?,
      accountSlug: accountSlug == _undefined ? this.accountSlug : accountSlug as String?,
      bio: bio == _undefined ? this.bio : bio as String?,
      account: account == _undefined ? this.account : account as Account?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (tenantId != null) {
      record['tenantId'] = tenantId;
    }
    if (accountSlug != null) {
      record['accountSlug'] = accountSlug;
    }
    if (bio != null) {
      record['bio'] = bio;
    }
    if (account != null) {
      record['account'] = account!.toRecord();
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (id != null) {
      json['id'] = id;
    }
    if (tenantId != null) {
      json['tenantId'] = tenantId;
    }
    if (accountSlug != null) {
      json['accountSlug'] = accountSlug;
    }
    if (bio != null) {
      json['bio'] = bio;
    }
    if (account != null) {
      json['account'] = account!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'AccountProfile(id: $id, tenantId: $tenantId, accountSlug: $accountSlug, bio: $bio, account: $account)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AccountProfile &&
        _deepEquals(id, other.id) &&
        _deepEquals(tenantId, other.tenantId) &&
        _deepEquals(accountSlug, other.accountSlug) &&
        _deepEquals(bio, other.bio) &&
        _deepEquals(account, other.account);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(tenantId),
    _deepHash(accountSlug),
    _deepHash(bio),
    _deepHash(account),
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
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(
                model: 'User',
                where: selector,
              ),
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
    if (data.profile == null) {
      // No nested writes for profile.
    } else {
      final nested = data.profile!;
      final parentReferenceValues = <String, Object?>{
        'userId': _requireRecordValue(existing, 'id', 'nested inverse one-to-one relation write on User.profile'),
      };
      final currentRelated = await tx.profile._delegate.findFirst(
        FindFirstQuery(
          model: 'Profile',
          where: <QueryPredicate>[
            QueryPredicate(field: 'userId', operator: 'equals', value: parentReferenceValues['userId']),
          ],
        ),
      );
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for UserUpdateInput.profile.');
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.profile._delegate.findUnique(
          FindUniqueQuery(
            model: 'Profile',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related Profile record found for nested connect on inverse one-to-one relation User.profile.');
        }
        final alreadyConnected =
            related['userId'] == parentReferenceValues['userId']
        ;
        if (!alreadyConnected) {
          if (currentRelated != null) {
            throw StateError('Nested connect cannot replace the existing inverse one-to-one relation User.profile because Profile.userId is required.');
          }
          await tx.profile._delegate.update(
            UpdateQuery(
              model: 'Profile',
              where: selector.toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      if (nested.connectOrCreate != null) {
        final entry = nested.connectOrCreate!;
        final related = await tx.profile._delegate.findUnique(
          FindUniqueQuery(
            model: 'Profile',
            where: entry.where.toPredicates(),
          ),
        );
        if (related != null) {
          final alreadyConnected =
              related['userId'] == parentReferenceValues['userId']
          ;
          if (!alreadyConnected) {
            if (currentRelated != null) {
              throw StateError('Nested connectOrCreate cannot replace the existing inverse one-to-one relation User.profile because Profile.userId is required.');
            }
            await tx.profile._delegate.update(
              UpdateQuery(
                model: 'Profile',
                where: entry.where.toPredicates(),
                data: <String, Object?>{
                  'userId': parentReferenceValues['userId'],
                },
              ),
            );
          }
        } else {
          if (currentRelated != null) {
            throw StateError('Nested connectOrCreate cannot create a new inverse one-to-one relation User.profile because Profile.userId is required and already attached.');
          }
          await tx.profile._delegate.create(
            CreateQuery(
              model: 'Profile',
              data: <String, Object?>{...entry.create.toData(),
                'userId': parentReferenceValues['userId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        }
      }
      if (nested.disconnect) {
        if (currentRelated != null) {
        throw StateError('Nested disconnect is not supported for required inverse one-to-one relation User.profile.');
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
  const UserWhereInput({this.AND = const <UserWhereInput>[], this.OR = const <UserWhereInput>[], this.NOT = const <UserWhereInput>[], this.id, this.idFilter, this.email, this.emailFilter, this.profileIs, this.profileIsNot, });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? email;
  final StringFilter? emailFilter;
  final ProfileWhereInput? profileIs;
  final ProfileWhereInput? profileIsNot;

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
    if (email != null) {
      predicates.add(QueryPredicate(field: 'email', operator: 'equals', value: email));
    }
    if (emailFilter != null) {
      predicates.addAll(emailFilter!.toPredicates('email'));
    }
    if (profileIs != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']), predicates: profileIs!.toPredicates())));
    }
    if (profileIsNot != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']), predicates: profileIsNot!.toPredicates())));
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
  const UserOrderByInput({this.id, this.email, });

  final SortOrder? id;
  final SortOrder? email;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(QueryOrderBy(field: 'email', direction: email!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField {
  id,
  email
}

class UserCountAggregateInput {
  const UserCountAggregateInput({this.all = false, this.id = false, this.email = false, });

  final bool all;
  final bool id;
  final bool email;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
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
  const UserMinAggregateInput({this.id = false, this.email = false, });

  final bool id;
  final bool email;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({this.id = false, this.email = false, });

  final bool id;
  final bool email;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({this.all, this.id, this.email, });

  final int? all;
  final int? id;
  final int? email;

  factory UserCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
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
  const UserMinAggregateResult({this.id, this.email, });

  final int? id;
  final String? email;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      email: values['email'] as String?,
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({this.id, this.email, });

  final int? id;
  final String? email;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
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
  const UserCountAggregateOrderByInput({this.all, this.id, this.email, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
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
  const UserMinAggregateOrderByInput({this.id, this.email, });

  final SortOrder? id;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'email', direction: email!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({this.id, this.email, });

  final SortOrder? id;
  final SortOrder? email;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'email', direction: email!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserGroupByOrderByInput {
  const UserGroupByOrderByInput({this.id, this.email, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
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
  const UserGroupByRow({this.id, this.email, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final String? email;
  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return UserGroupByRow(
      id: row.group['id'] as int?,
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
  const UserInclude({this.profile = false, });

  final bool profile;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (profile) {
      relations['profile'] = QueryIncludeEntry(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class UserSelect {
  const UserSelect({this.id = false, this.email = false, });

  final bool id;
  final bool email;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
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
  const UserCreateInput({this.id, required this.email, this.profile, });

  final int? id;
  final String email;
  final ProfileCreateNestedOneWithoutUserInput? profile;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
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
    if (profile != null) {
      writes.addAll(profile!.toRelationWrites(QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'id', targetKeyField: 'userId', localKeyFields: const <String>['id'], targetKeyFields: const <String>['userId'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (profile?.hasDeferredWrites ?? false);
  }

  UserUpdateInput toDeferredRelationUpdateInput() {
    return UserUpdateInput(
      profile: profile?.toDeferredUpdateWrite(),
    );
  }
}

class UserUpdateInput {
  const UserUpdateInput({this.email, this.emailOps, this.profile, });

  final String? email;
  final StringFieldUpdateOperationsInput? emailOps;
  final ProfileUpdateNestedOneWithoutUserInput? profile;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return profile?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
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

class UserCreateWithoutProfileInput {
  const UserCreateWithoutProfileInput({this.id, required this.email, });

  final int? id;
  final String email;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class ProfileConnectOrCreateWithoutUserInput {
  const ProfileConnectOrCreateWithoutUserInput({required this.where, required this.create});

  final ProfileWhereUniqueInput where;
  final ProfileCreateWithoutUserInput create;
}

class ProfileCreateNestedOneWithoutUserInput {
  const ProfileCreateNestedOneWithoutUserInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final ProfileCreateWithoutUserInput? create;
  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutUserInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutUserInput.');
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

  ProfileUpdateNestedOneWithoutUserInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutUserInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return ProfileUpdateNestedOneWithoutUserInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class ProfileUpdateNestedOneWithoutUserInput {
  const ProfileUpdateNestedOneWithoutUserInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutUserInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;
}

class ProfileDelegate {
  const ProfileDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Profile');

  Future<Profile?> findUnique({
    required ProfileWhereUniqueInput where,
    ProfileInclude? include,
    ProfileSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'Profile',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : Profile.fromRecord(record));
  }

  Future<Profile?> findFirst({
    ProfileWhereInput? where,
    ProfileWhereUniqueInput? cursor,
    List<ProfileOrderByInput>? orderBy,
    List<ProfileScalarField>? distinct,
    ProfileInclude? include,
    ProfileSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'Profile',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : Profile.fromRecord(record));
  }

  Future<List<Profile>> findMany({
    ProfileWhereInput? where,
    ProfileWhereUniqueInput? cursor,
    List<ProfileOrderByInput>? orderBy,
    List<ProfileScalarField>? distinct,
    ProfileInclude? include,
    ProfileSelect? select,
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
        model: 'Profile',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(Profile.fromRecord).toList(growable: false));
  }

  Future<int> count({ProfileWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Profile',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<ProfileAggregateResult> aggregate({
    ProfileWhereInput? where,
    List<ProfileOrderByInput>? orderBy,
    int? skip,
    int? take,
    ProfileCountAggregateInput? count,
    ProfileAvgAggregateInput? avg,
    ProfileSumAggregateInput? sum,
    ProfileMinAggregateInput? min,
    ProfileMaxAggregateInput? max,
  }) {
    return _delegate.aggregate(
      AggregateQuery(
        model: 'Profile',
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
    ).then(ProfileAggregateResult.fromQueryResult);
  }

  Future<List<ProfileGroupByRow>> groupBy({
    required List<ProfileScalarField> by,
    ProfileWhereInput? where,
    List<ProfileGroupByOrderByInput>? orderBy,
    ProfileGroupByHavingInput? having,
    int? skip,
    int? take,
    ProfileCountAggregateInput? count,
    ProfileAvgAggregateInput? avg,
    ProfileSumAggregateInput? sum,
    ProfileMinAggregateInput? min,
    ProfileMaxAggregateInput? max,
  }) {
    return _delegate.groupBy(
      GroupByQuery(
        model: 'Profile',
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
    ).then((rows) => rows.map(ProfileGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<Profile> create({
    required ProfileCreateInput data,
    ProfileInclude? include,
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
    required List<ProfileCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Profile');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(
                model: 'Profile',
                where: selector,
              ),
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
            await _performCreateWithRelationWrites(
              tx: tx,
              data: entry,
            );
          } else {
            await txDelegate.create(
              CreateQuery(
                model: 'Profile',
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

  Future<Profile> update({
    required ProfileWhereUniqueInput where,
    required ProfileUpdateInput data,
    ProfileInclude? include,
    ProfileSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Profile');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Profile',
          where: predicates,
        ),
      );
      if (existing == null) {
        throw StateError('No record found for update in Profile.');
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

  Future<Profile> upsert({
    required ProfileWhereUniqueInput where,
    required ProfileCreateInput create,
    required ProfileUpdateInput update,
    ProfileInclude? include,
    ProfileSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Profile');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Profile',
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
    required ProfileWhereInput where,
    required ProfileUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Profile');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(
            model: 'Profile',
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
        model: 'Profile',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<Profile> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required ProfileCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Profile');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Profile',
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
      return Profile.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Profile',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Profile create branch could not reload the created record by primary key.');
    }
    return Profile.fromRecord(projected);
  }

  ProfileWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return ProfileWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<Profile> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required ProfileUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Profile');
    await txDelegate.update(
      UpdateQuery(
        model: 'Profile',
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
        model: 'Profile',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Profile update branch could not reload the updated record for the provided unique selector.');
    }
    return Profile.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required ProfileUpdateInput data,
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
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for ProfileUpdateInput.user.');
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
          throw StateError('No related User record found for nested connect on Profile.user.');
        }
        await tx._client.model('Profile').update(
          UpdateQuery(
            model: 'Profile',
            where: predicates,
            data: <String, Object?>{
              'userId': _requireRecordValue(related, 'id', 'nested direct relation write on Profile.user'),
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
        await tx._client.model('Profile').update(
          UpdateQuery(
            model: 'Profile',
            where: predicates,
            data: <String, Object?>{
              'userId': _requireRecordValue(relatedRecord, 'id', 'nested direct relation write on Profile.user'),
            },
          ),
        );
      }
      if (nested.disconnect) {
        throw StateError('Nested disconnect is not supported for required relation Profile.user.');
      }
    }
  }


  Future<Profile> delete({
    required ProfileWhereUniqueInput where,
    ProfileInclude? include,
    ProfileSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'Profile',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Profile.fromRecord);
  }

  Future<int> deleteMany({
    required ProfileWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'Profile',
        where: where.toPredicates(),
      ),
    );
  }
}

class ProfileWhereInput {
  const ProfileWhereInput({this.AND = const <ProfileWhereInput>[], this.OR = const <ProfileWhereInput>[], this.NOT = const <ProfileWhereInput>[], this.id, this.idFilter, this.userId, this.userIdFilter, this.bio, this.bioFilter, this.userIs, this.userIsNot, });

  final List<ProfileWhereInput> AND;
  final List<ProfileWhereInput> OR;
  final List<ProfileWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final int? userId;
  final IntFilter? userIdFilter;
  final String? bio;
  final StringFilter? bioFilter;
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
    if (userId != null) {
      predicates.add(QueryPredicate(field: 'userId', operator: 'equals', value: userId));
    }
    if (userIdFilter != null) {
      predicates.addAll(userIdFilter!.toPredicates('userId'));
    }
    if (bio != null) {
      predicates.add(QueryPredicate(field: 'bio', operator: 'equals', value: bio));
    }
    if (bioFilter != null) {
      predicates.addAll(bioFilter!.toPredicates('bio'));
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

class ProfileWhereUniqueInput {
  const ProfileWhereUniqueInput({this.id, this.userId, });

  final int? id;
  final int? userId;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (userId != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'userId', operator: 'equals', value: userId),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for ProfileWhereUniqueInput.');
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
    if (userId != null) {
      selectorCount++;
      matches = record['userId'] == userId;
    }
    if (selectorCount != 1) {
      throw StateError('Exactly one unique selector must be provided for ProfileWhereUniqueInput.');
    }
    return matches;
  }
}

class ProfileOrderByInput {
  const ProfileOrderByInput({this.id, this.userId, this.bio, });

  final SortOrder? id;
  final SortOrder? userId;
  final SortOrder? bio;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    if (bio != null) {
      orderings.add(QueryOrderBy(field: 'bio', direction: bio!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum ProfileScalarField {
  id,
  userId,
  bio
}

class ProfileCountAggregateInput {
  const ProfileCountAggregateInput({this.all = false, this.id = false, this.userId = false, this.bio = false, });

  final bool all;
  final bool id;
  final bool userId;
  final bool bio;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    if (bio) {
      fields.add('bio');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class ProfileAvgAggregateInput {
  const ProfileAvgAggregateInput({this.id = false, this.userId = false, });

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

class ProfileSumAggregateInput {
  const ProfileSumAggregateInput({this.id = false, this.userId = false, });

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

class ProfileMinAggregateInput {
  const ProfileMinAggregateInput({this.id = false, this.userId = false, this.bio = false, });

  final bool id;
  final bool userId;
  final bool bio;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    if (bio) {
      fields.add('bio');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class ProfileMaxAggregateInput {
  const ProfileMaxAggregateInput({this.id = false, this.userId = false, this.bio = false, });

  final bool id;
  final bool userId;
  final bool bio;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    if (bio) {
      fields.add('bio');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class ProfileCountAggregateResult {
  const ProfileCountAggregateResult({this.all, this.id, this.userId, this.bio, });

  final int? all;
  final int? id;
  final int? userId;
  final int? bio;

  factory ProfileCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return ProfileCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      userId: result.fields['userId'],
      bio: result.fields['bio'],
    );
  }
}

class ProfileAvgAggregateResult {
  const ProfileAvgAggregateResult({this.id, this.userId, });

  final double? id;
  final double? userId;

  factory ProfileAvgAggregateResult.fromMap(Map<String, double?> values) {
    return ProfileAvgAggregateResult(
      id: _asDouble(values['id']),
      userId: _asDouble(values['userId']),
    );
  }
}

class ProfileSumAggregateResult {
  const ProfileSumAggregateResult({this.id, this.userId, });

  final int? id;
  final int? userId;

  factory ProfileSumAggregateResult.fromMap(Map<String, num?> values) {
    return ProfileSumAggregateResult(
      id: values['id']?.toInt(),
      userId: values['userId']?.toInt(),
    );
  }
}

class ProfileMinAggregateResult {
  const ProfileMinAggregateResult({this.id, this.userId, this.bio, });

  final int? id;
  final int? userId;
  final String? bio;

  factory ProfileMinAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMinAggregateResult(
      id: values['id'] as int?,
      userId: values['userId'] as int?,
      bio: values['bio'] as String?,
    );
  }
}

class ProfileMaxAggregateResult {
  const ProfileMaxAggregateResult({this.id, this.userId, this.bio, });

  final int? id;
  final int? userId;
  final String? bio;

  factory ProfileMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMaxAggregateResult(
      id: values['id'] as int?,
      userId: values['userId'] as int?,
      bio: values['bio'] as String?,
    );
  }
}

class ProfileAggregateResult {
  const ProfileAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final ProfileCountAggregateResult? count;
  final ProfileAvgAggregateResult? avg;
  final ProfileSumAggregateResult? sum;
  final ProfileMinAggregateResult? min;
  final ProfileMaxAggregateResult? max;

  factory ProfileAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return ProfileAggregateResult(
      count: result.count == null ? null : ProfileCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : ProfileAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : ProfileSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : ProfileMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : ProfileMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class ProfileGroupByHavingInput {
  const ProfileGroupByHavingInput({this.id, this.userId, });

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

class ProfileCountAggregateOrderByInput {
  const ProfileCountAggregateOrderByInput({this.all, this.id, this.userId, this.bio, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? userId;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class ProfileAvgAggregateOrderByInput {
  const ProfileAvgAggregateOrderByInput({this.id, this.userId, });

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

class ProfileSumAggregateOrderByInput {
  const ProfileSumAggregateOrderByInput({this.id, this.userId, });

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

class ProfileMinAggregateOrderByInput {
  const ProfileMinAggregateOrderByInput({this.id, this.userId, this.bio, });

  final SortOrder? id;
  final SortOrder? userId;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class ProfileMaxAggregateOrderByInput {
  const ProfileMaxAggregateOrderByInput({this.id, this.userId, this.bio, });

  final SortOrder? id;
  final SortOrder? userId;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class ProfileGroupByOrderByInput {
  const ProfileGroupByOrderByInput({this.id, this.userId, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? userId;
  final SortOrder? bio;
  final ProfileCountAggregateOrderByInput? count;
  final ProfileAvgAggregateOrderByInput? avg;
  final ProfileSumAggregateOrderByInput? sum;
  final ProfileMinAggregateOrderByInput? min;
  final ProfileMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.field(field: 'userId', direction: userId!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.field(field: 'bio', direction: bio!));
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

class ProfileGroupByRow {
  const ProfileGroupByRow({this.id, this.userId, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final int? userId;
  final String? bio;
  final ProfileCountAggregateResult? count;
  final ProfileAvgAggregateResult? avg;
  final ProfileSumAggregateResult? sum;
  final ProfileMinAggregateResult? min;
  final ProfileMaxAggregateResult? max;

  factory ProfileGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return ProfileGroupByRow(
      id: row.group['id'] as int?,
      userId: row.group['userId'] as int?,
      bio: row.group['bio'] as String?,
      count: row.aggregates.count == null ? null : ProfileCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : ProfileAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : ProfileSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : ProfileMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : ProfileMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class ProfileInclude {
  const ProfileInclude({this.user = false, });

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

class ProfileSelect {
  const ProfileSelect({this.id = false, this.userId = false, this.bio = false, });

  final bool id;
  final bool userId;
  final bool bio;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (userId) {
      fields.add('userId');
    }
    if (bio) {
      fields.add('bio');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class ProfileCreateInput {
  const ProfileCreateInput({required this.id, required this.userId, this.bio, this.user, });

  final int id;
  final int userId;
  final String? bio;
  final UserCreateNestedOneWithoutProfileInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    data['userId'] = userId;
    if (bio != null) {
      data['bio'] = bio;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'userId', operator: 'equals', value: userId),
      ]);
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

  ProfileUpdateInput toDeferredRelationUpdateInput() {
    return ProfileUpdateInput(
      user: user?.toDeferredUpdateWrite(),
    );
  }
}

class ProfileUpdateInput {
  const ProfileUpdateInput({this.userId, this.userIdOps, this.bio, this.bioOps, this.user, });

  final int? userId;
  final IntFieldUpdateOperationsInput? userIdOps;
  final String? bio;
  final StringFieldUpdateOperationsInput? bioOps;
  final UserUpdateNestedOneWithoutProfileInput? user;

  bool get hasComputedOperators {
    return userIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return user?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (userId != null && userIdOps != null) {
      throw StateError('Only one of userId or userIdOps may be provided for ProfileUpdateInput.userId.');
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for ProfileUpdateInput.userId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for ProfileUpdateInput.userId require the current record value before they can be converted to raw update data.');
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      }
    }
    if (bio != null && bioOps != null) {
      throw StateError('Only one of bio or bioOps may be provided for ProfileUpdateInput.bio.');
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (bioOps != null) {
      final ops = bioOps!;
      if (ops.hasSet) {
        data['bio'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (userId != null && userIdOps != null) {
      throw StateError('Only one of userId or userIdOps may be provided for ProfileUpdateInput.userId.');
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for ProfileUpdateInput.userId.');
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      } else {
        final currentValue = record['userId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment ProfileUpdateInput.userId because the current value is null.');
          }
          data['userId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement ProfileUpdateInput.userId because the current value is null.');
          }
          data['userId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (bio != null && bioOps != null) {
      throw StateError('Only one of bio or bioOps may be provided for ProfileUpdateInput.bio.');
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (bioOps != null) {
      final ops = bioOps!;
      if (ops.hasSet) {
        data['bio'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class ProfileCreateWithoutUserInput {
  const ProfileCreateWithoutUserInput({required this.id, this.bio, });

  final int id;
  final String? bio;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    if (bio != null) {
      data['bio'] = bio;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutProfileInput {
  const UserConnectOrCreateWithoutProfileInput({required this.where, required this.create});

  final UserWhereUniqueInput where;
  final UserCreateWithoutProfileInput create;
}

class UserCreateNestedOneWithoutProfileInput {
  const UserCreateNestedOneWithoutProfileInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final UserCreateWithoutProfileInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutProfileInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutProfileInput.');
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

  UserUpdateNestedOneWithoutProfileInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutProfileInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutProfileInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class UserUpdateNestedOneWithoutProfileInput {
  const UserUpdateNestedOneWithoutProfileInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutProfileInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;
}

class AccountDelegate {
  const AccountDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Account');

  Future<Account?> findUnique({
    required AccountWhereUniqueInput where,
    AccountInclude? include,
    AccountSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'Account',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : Account.fromRecord(record));
  }

  Future<Account?> findFirst({
    AccountWhereInput? where,
    AccountWhereUniqueInput? cursor,
    List<AccountOrderByInput>? orderBy,
    List<AccountScalarField>? distinct,
    AccountInclude? include,
    AccountSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'Account',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : Account.fromRecord(record));
  }

  Future<List<Account>> findMany({
    AccountWhereInput? where,
    AccountWhereUniqueInput? cursor,
    List<AccountOrderByInput>? orderBy,
    List<AccountScalarField>? distinct,
    AccountInclude? include,
    AccountSelect? select,
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
        model: 'Account',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(Account.fromRecord).toList(growable: false));
  }

  Future<int> count({AccountWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Account',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<AccountAggregateResult> aggregate({
    AccountWhereInput? where,
    List<AccountOrderByInput>? orderBy,
    int? skip,
    int? take,
    AccountCountAggregateInput? count,
    AccountAvgAggregateInput? avg,
    AccountSumAggregateInput? sum,
    AccountMinAggregateInput? min,
    AccountMaxAggregateInput? max,
  }) {
    return _delegate.aggregate(
      AggregateQuery(
        model: 'Account',
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
    ).then(AccountAggregateResult.fromQueryResult);
  }

  Future<List<AccountGroupByRow>> groupBy({
    required List<AccountScalarField> by,
    AccountWhereInput? where,
    List<AccountGroupByOrderByInput>? orderBy,
    AccountGroupByHavingInput? having,
    int? skip,
    int? take,
    AccountCountAggregateInput? count,
    AccountAvgAggregateInput? avg,
    AccountSumAggregateInput? sum,
    AccountMinAggregateInput? min,
    AccountMaxAggregateInput? max,
  }) {
    return _delegate.groupBy(
      GroupByQuery(
        model: 'Account',
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
    ).then((rows) => rows.map(AccountGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<Account> create({
    required AccountCreateInput data,
    AccountInclude? include,
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
    required List<AccountCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Account');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(
                model: 'Account',
                where: selector,
              ),
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
            await _performCreateWithRelationWrites(
              tx: tx,
              data: entry,
            );
          } else {
            await txDelegate.create(
              CreateQuery(
                model: 'Account',
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

  Future<Account> update({
    required AccountWhereUniqueInput where,
    required AccountUpdateInput data,
    AccountInclude? include,
    AccountSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Account');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Account',
          where: predicates,
        ),
      );
      if (existing == null) {
        throw StateError('No record found for update in Account.');
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

  Future<Account> upsert({
    required AccountWhereUniqueInput where,
    required AccountCreateInput create,
    required AccountUpdateInput update,
    AccountInclude? include,
    AccountSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Account');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Account',
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
    required AccountWhereInput where,
    required AccountUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Account');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(
            model: 'Account',
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
        model: 'Account',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<Account> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required AccountCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Account');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Account',
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
      return Account.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Account',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Account create branch could not reload the created record by primary key.');
    }
    return Account.fromRecord(projected);
  }

  AccountWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return AccountWhereUniqueInput(
      tenantId_slug: AccountTenantIdSlugCompoundUniqueInput(
        tenantId: (record['tenantId'] as int?)!,
        slug: (record['slug'] as String?)!,
      ),
    );
  }

  Future<Account> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required AccountUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Account');
    await txDelegate.update(
      UpdateQuery(
        model: 'Account',
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
        model: 'Account',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Account update branch could not reload the updated record for the provided unique selector.');
    }
    return Account.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required AccountUpdateInput data,
  }) async {
    if (data.profile == null) {
      // No nested writes for profile.
    } else {
      final nested = data.profile!;
      final parentReferenceValues = <String, Object?>{
        'tenantId': _requireRecordValue(existing, 'tenantId', 'nested inverse one-to-one relation write on Account.profile'),
        'accountSlug': _requireRecordValue(existing, 'slug', 'nested inverse one-to-one relation write on Account.profile'),
      };
      final currentRelated = await tx.accountProfile._delegate.findFirst(
        FindFirstQuery(
          model: 'AccountProfile',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
            QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
          ],
        ),
      );
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for AccountUpdateInput.profile.');
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.accountProfile._delegate.findUnique(
          FindUniqueQuery(
            model: 'AccountProfile',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related AccountProfile record found for nested connect on inverse one-to-one relation Account.profile.');
        }
        final alreadyConnected =
            related['tenantId'] == parentReferenceValues['tenantId']
            && related['accountSlug'] == parentReferenceValues['accountSlug']
        ;
        if (!alreadyConnected) {
          if (currentRelated != null) {
            throw StateError('Nested connect cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.');
          }
          await tx.accountProfile._delegate.update(
            UpdateQuery(
              model: 'AccountProfile',
              where: selector.toPredicates(),
              data: <String, Object?>{
                'tenantId': parentReferenceValues['tenantId'],
                'accountSlug': parentReferenceValues['accountSlug'],
              },
            ),
          );
        }
      }
      if (nested.connectOrCreate != null) {
        final entry = nested.connectOrCreate!;
        final related = await tx.accountProfile._delegate.findUnique(
          FindUniqueQuery(
            model: 'AccountProfile',
            where: entry.where.toPredicates(),
          ),
        );
        if (related != null) {
          final alreadyConnected =
              related['tenantId'] == parentReferenceValues['tenantId']
              && related['accountSlug'] == parentReferenceValues['accountSlug']
          ;
          if (!alreadyConnected) {
            if (currentRelated != null) {
              throw StateError('Nested connectOrCreate cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.');
            }
            await tx.accountProfile._delegate.update(
              UpdateQuery(
                model: 'AccountProfile',
                where: entry.where.toPredicates(),
                data: <String, Object?>{
                  'tenantId': parentReferenceValues['tenantId'],
                  'accountSlug': parentReferenceValues['accountSlug'],
                },
              ),
            );
          }
        } else {
          if (currentRelated != null) {
            throw StateError('Nested connectOrCreate cannot create a new inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required and already attached.');
          }
          await tx.accountProfile._delegate.create(
            CreateQuery(
              model: 'AccountProfile',
              data: <String, Object?>{...entry.create.toData(),
                'tenantId': parentReferenceValues['tenantId'],
                'accountSlug': parentReferenceValues['accountSlug'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        }
      }
      if (nested.disconnect) {
        if (currentRelated != null) {
        throw StateError('Nested disconnect is not supported for required inverse one-to-one relation Account.profile.');
        }
      }
    }
  }


  Future<Account> delete({
    required AccountWhereUniqueInput where,
    AccountInclude? include,
    AccountSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'Account',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Account.fromRecord);
  }

  Future<int> deleteMany({
    required AccountWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'Account',
        where: where.toPredicates(),
      ),
    );
  }
}

class AccountWhereInput {
  const AccountWhereInput({this.AND = const <AccountWhereInput>[], this.OR = const <AccountWhereInput>[], this.NOT = const <AccountWhereInput>[], this.tenantId, this.tenantIdFilter, this.slug, this.slugFilter, this.profileIs, this.profileIsNot, });

  final List<AccountWhereInput> AND;
  final List<AccountWhereInput> OR;
  final List<AccountWhereInput> NOT;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? slug;
  final StringFilter? slugFilter;
  final AccountProfileWhereInput? profileIs;
  final AccountProfileWhereInput? profileIsNot;

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
    if (tenantId != null) {
      predicates.add(QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId));
    }
    if (tenantIdFilter != null) {
      predicates.addAll(tenantIdFilter!.toPredicates('tenantId'));
    }
    if (slug != null) {
      predicates.add(QueryPredicate(field: 'slug', operator: 'equals', value: slug));
    }
    if (slugFilter != null) {
      predicates.addAll(slugFilter!.toPredicates('slug'));
    }
    if (profileIs != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'AccountProfile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: profileIs!.toPredicates())));
    }
    if (profileIsNot != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'AccountProfile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: profileIsNot!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class AccountTenantIdSlugCompoundUniqueInput {
  const AccountTenantIdSlugCompoundUniqueInput({required this.tenantId, required this.slug, });

  final int tenantId;
  final String slug;

  List<QueryPredicate> toPredicates() {
    return List<QueryPredicate>.unmodifiable(<QueryPredicate>[
      QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
      QueryPredicate(field: 'slug', operator: 'equals', value: slug),
    ]);
  }

  bool matchesRecord(Map<String, Object?> record) {
    return record['tenantId'] == tenantId && record['slug'] == slug;
  }
}

class AccountWhereUniqueInput {
  const AccountWhereUniqueInput({this.tenantId_slug, });

  final AccountTenantIdSlugCompoundUniqueInput? tenantId_slug;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (tenantId_slug != null) {
      selectors.add(tenantId_slug!.toPredicates());
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for AccountWhereUniqueInput.');
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }

  QueryCursor toQueryCursor() {
    return QueryCursor(where: toPredicates());
  }

  bool matchesRecord(Map<String, Object?> record) {
    var selectorCount = 0;
    var matches = false;
    if (tenantId_slug != null) {
      selectorCount++;
      matches = tenantId_slug!.matchesRecord(record);
    }
    if (selectorCount != 1) {
      throw StateError('Exactly one unique selector must be provided for AccountWhereUniqueInput.');
    }
    return matches;
  }
}

class AccountOrderByInput {
  const AccountOrderByInput({this.tenantId, this.slug, });

  final SortOrder? tenantId;
  final SortOrder? slug;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (tenantId != null) {
      orderings.add(QueryOrderBy(field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(QueryOrderBy(field: 'slug', direction: slug!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum AccountScalarField {
  tenantId,
  slug
}

class AccountCountAggregateInput {
  const AccountCountAggregateInput({this.all = false, this.tenantId = false, this.slug = false, });

  final bool all;
  final bool tenantId;
  final bool slug;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class AccountAvgAggregateInput {
  const AccountAvgAggregateInput({this.tenantId = false, });

  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountSumAggregateInput {
  const AccountSumAggregateInput({this.tenantId = false, });

  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountMinAggregateInput {
  const AccountMinAggregateInput({this.tenantId = false, this.slug = false, });

  final bool tenantId;
  final bool slug;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountMaxAggregateInput {
  const AccountMaxAggregateInput({this.tenantId = false, this.slug = false, });

  final bool tenantId;
  final bool slug;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountCountAggregateResult {
  const AccountCountAggregateResult({this.all, this.tenantId, this.slug, });

  final int? all;
  final int? tenantId;
  final int? slug;

  factory AccountCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return AccountCountAggregateResult(
      all: result.all,
      tenantId: result.fields['tenantId'],
      slug: result.fields['slug'],
    );
  }
}

class AccountAvgAggregateResult {
  const AccountAvgAggregateResult({this.tenantId, });

  final double? tenantId;

  factory AccountAvgAggregateResult.fromMap(Map<String, double?> values) {
    return AccountAvgAggregateResult(
      tenantId: _asDouble(values['tenantId']),
    );
  }
}

class AccountSumAggregateResult {
  const AccountSumAggregateResult({this.tenantId, });

  final int? tenantId;

  factory AccountSumAggregateResult.fromMap(Map<String, num?> values) {
    return AccountSumAggregateResult(
      tenantId: values['tenantId']?.toInt(),
    );
  }
}

class AccountMinAggregateResult {
  const AccountMinAggregateResult({this.tenantId, this.slug, });

  final int? tenantId;
  final String? slug;

  factory AccountMinAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountMinAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
    );
  }
}

class AccountMaxAggregateResult {
  const AccountMaxAggregateResult({this.tenantId, this.slug, });

  final int? tenantId;
  final String? slug;

  factory AccountMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountMaxAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
    );
  }
}

class AccountAggregateResult {
  const AccountAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final AccountCountAggregateResult? count;
  final AccountAvgAggregateResult? avg;
  final AccountSumAggregateResult? sum;
  final AccountMinAggregateResult? min;
  final AccountMaxAggregateResult? max;

  factory AccountAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return AccountAggregateResult(
      count: result.count == null ? null : AccountCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : AccountAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : AccountSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : AccountMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : AccountMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class AccountGroupByHavingInput {
  const AccountGroupByHavingInput({this.tenantId, });

  final NumericAggregatesFilter? tenantId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (tenantId != null) {
      predicates.addAll(tenantId!.toPredicates('tenantId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class AccountCountAggregateOrderByInput {
  const AccountCountAggregateOrderByInput({this.all, this.tenantId, this.slug, });

  final SortOrder? all;
  final SortOrder? tenantId;
  final SortOrder? slug;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'slug', direction: slug!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountAvgAggregateOrderByInput {
  const AccountAvgAggregateOrderByInput({this.tenantId, });

  final SortOrder? tenantId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountSumAggregateOrderByInput {
  const AccountSumAggregateOrderByInput({this.tenantId, });

  final SortOrder? tenantId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountMinAggregateOrderByInput {
  const AccountMinAggregateOrderByInput({this.tenantId, this.slug, });

  final SortOrder? tenantId;
  final SortOrder? slug;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'slug', direction: slug!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountMaxAggregateOrderByInput {
  const AccountMaxAggregateOrderByInput({this.tenantId, this.slug, });

  final SortOrder? tenantId;
  final SortOrder? slug;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'slug', direction: slug!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountGroupByOrderByInput {
  const AccountGroupByOrderByInput({this.tenantId, this.slug, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? tenantId;
  final SortOrder? slug;
  final AccountCountAggregateOrderByInput? count;
  final AccountAvgAggregateOrderByInput? avg;
  final AccountSumAggregateOrderByInput? sum;
  final AccountMinAggregateOrderByInput? min;
  final AccountMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.field(field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.field(field: 'slug', direction: slug!));
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

class AccountGroupByRow {
  const AccountGroupByRow({this.tenantId, this.slug, this.count, this.avg, this.sum, this.min, this.max});

  final int? tenantId;
  final String? slug;
  final AccountCountAggregateResult? count;
  final AccountAvgAggregateResult? avg;
  final AccountSumAggregateResult? sum;
  final AccountMinAggregateResult? min;
  final AccountMaxAggregateResult? max;

  factory AccountGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return AccountGroupByRow(
      tenantId: row.group['tenantId'] as int?,
      slug: row.group['slug'] as String?,
      count: row.aggregates.count == null ? null : AccountCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : AccountAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : AccountSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : AccountMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : AccountMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class AccountInclude {
  const AccountInclude({this.profile = false, });

  final bool profile;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (profile) {
      relations['profile'] = QueryIncludeEntry(relation: QueryRelation(field: 'profile', targetModel: 'AccountProfile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class AccountSelect {
  const AccountSelect({this.tenantId = false, this.slug = false, });

  final bool tenantId;
  final bool slug;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class AccountCreateInput {
  const AccountCreateInput({required this.tenantId, required this.slug, this.profile, });

  final int tenantId;
  final String slug;
  final AccountProfileCreateNestedOneWithoutAccountInput? profile;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
        QueryPredicate(field: 'slug', operator: 'equals', value: slug),
      ]);
    return List<List<QueryPredicate>>.unmodifiable(selectors.map(List<QueryPredicate>.unmodifiable));
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (profile != null) {
      writes.addAll(profile!.toRelationWrites(QueryRelation(field: 'profile', targetModel: 'AccountProfile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (profile?.hasDeferredWrites ?? false);
  }

  AccountUpdateInput toDeferredRelationUpdateInput() {
    return AccountUpdateInput(
      profile: profile?.toDeferredUpdateWrite(),
    );
  }
}

class AccountUpdateInput {
  const AccountUpdateInput({this.tenantId, this.tenantIdOps, this.slug, this.slugOps, this.profile, });

  final int? tenantId;
  final IntFieldUpdateOperationsInput? tenantIdOps;
  final String? slug;
  final StringFieldUpdateOperationsInput? slugOps;
  final AccountProfileUpdateNestedOneWithoutAccountInput? profile;

  bool get hasComputedOperators {
    return tenantIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return profile?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for AccountUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for AccountUpdateInput.tenantId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for AccountUpdateInput.tenantId require the current record value before they can be converted to raw update data.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      }
    }
    if (slug != null && slugOps != null) {
      throw StateError('Only one of slug or slugOps may be provided for AccountUpdateInput.slug.');
    }
    if (slug != null) {
      data['slug'] = slug;
    }
    if (slugOps != null) {
      final ops = slugOps!;
      if (ops.hasSet) {
        data['slug'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for AccountUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for AccountUpdateInput.tenantId.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      } else {
        final currentValue = record['tenantId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment AccountUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement AccountUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (slug != null && slugOps != null) {
      throw StateError('Only one of slug or slugOps may be provided for AccountUpdateInput.slug.');
    }
    if (slug != null) {
      data['slug'] = slug;
    }
    if (slugOps != null) {
      final ops = slugOps!;
      if (ops.hasSet) {
        data['slug'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class AccountCreateWithoutProfileInput {
  const AccountCreateWithoutProfileInput({required this.tenantId, required this.slug, });

  final int tenantId;
  final String slug;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class AccountProfileConnectOrCreateWithoutAccountInput {
  const AccountProfileConnectOrCreateWithoutAccountInput({required this.where, required this.create});

  final AccountProfileWhereUniqueInput where;
  final AccountProfileCreateWithoutAccountInput create;
}

class AccountProfileCreateNestedOneWithoutAccountInput {
  const AccountProfileCreateNestedOneWithoutAccountInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountProfileCreateWithoutAccountInput? create;
  final AccountProfileWhereUniqueInput? connect;
  final AccountProfileConnectOrCreateWithoutAccountInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountProfileCreateNestedOneWithoutAccountInput.');
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

  AccountProfileUpdateNestedOneWithoutAccountInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountProfileCreateNestedOneWithoutAccountInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return AccountProfileUpdateNestedOneWithoutAccountInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class AccountProfileUpdateNestedOneWithoutAccountInput {
  const AccountProfileUpdateNestedOneWithoutAccountInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountProfileWhereUniqueInput? connect;
  final AccountProfileConnectOrCreateWithoutAccountInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;
}

class AccountProfileDelegate {
  const AccountProfileDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('AccountProfile');

  Future<AccountProfile?> findUnique({
    required AccountProfileWhereUniqueInput where,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'AccountProfile',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : AccountProfile.fromRecord(record));
  }

  Future<AccountProfile?> findFirst({
    AccountProfileWhereInput? where,
    AccountProfileWhereUniqueInput? cursor,
    List<AccountProfileOrderByInput>? orderBy,
    List<AccountProfileScalarField>? distinct,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'AccountProfile',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : AccountProfile.fromRecord(record));
  }

  Future<List<AccountProfile>> findMany({
    AccountProfileWhereInput? where,
    AccountProfileWhereUniqueInput? cursor,
    List<AccountProfileOrderByInput>? orderBy,
    List<AccountProfileScalarField>? distinct,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
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
        model: 'AccountProfile',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(AccountProfile.fromRecord).toList(growable: false));
  }

  Future<int> count({AccountProfileWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'AccountProfile',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<AccountProfileAggregateResult> aggregate({
    AccountProfileWhereInput? where,
    List<AccountProfileOrderByInput>? orderBy,
    int? skip,
    int? take,
    AccountProfileCountAggregateInput? count,
    AccountProfileAvgAggregateInput? avg,
    AccountProfileSumAggregateInput? sum,
    AccountProfileMinAggregateInput? min,
    AccountProfileMaxAggregateInput? max,
  }) {
    return _delegate.aggregate(
      AggregateQuery(
        model: 'AccountProfile',
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
    ).then(AccountProfileAggregateResult.fromQueryResult);
  }

  Future<List<AccountProfileGroupByRow>> groupBy({
    required List<AccountProfileScalarField> by,
    AccountProfileWhereInput? where,
    List<AccountProfileGroupByOrderByInput>? orderBy,
    AccountProfileGroupByHavingInput? having,
    int? skip,
    int? take,
    AccountProfileCountAggregateInput? count,
    AccountProfileAvgAggregateInput? avg,
    AccountProfileSumAggregateInput? sum,
    AccountProfileMinAggregateInput? min,
    AccountProfileMaxAggregateInput? max,
  }) {
    return _delegate.groupBy(
      GroupByQuery(
        model: 'AccountProfile',
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
    ).then((rows) => rows.map(AccountProfileGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<AccountProfile> create({
    required AccountProfileCreateInput data,
    AccountProfileInclude? include,
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
    required List<AccountProfileCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('AccountProfile');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(
                model: 'AccountProfile',
                where: selector,
              ),
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
            await _performCreateWithRelationWrites(
              tx: tx,
              data: entry,
            );
          } else {
            await txDelegate.create(
              CreateQuery(
                model: 'AccountProfile',
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

  Future<AccountProfile> update({
    required AccountProfileWhereUniqueInput where,
    required AccountProfileUpdateInput data,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('AccountProfile');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'AccountProfile',
          where: predicates,
        ),
      );
      if (existing == null) {
        throw StateError('No record found for update in AccountProfile.');
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

  Future<AccountProfile> upsert({
    required AccountProfileWhereUniqueInput where,
    required AccountProfileCreateInput create,
    required AccountProfileUpdateInput update,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('AccountProfile');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'AccountProfile',
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
    required AccountProfileWhereInput where,
    required AccountProfileUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('AccountProfile');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(
            model: 'AccountProfile',
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
        model: 'AccountProfile',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<AccountProfile> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required AccountProfileCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('AccountProfile');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'AccountProfile',
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
      return AccountProfile.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'AccountProfile',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('AccountProfile create branch could not reload the created record by primary key.');
    }
    return AccountProfile.fromRecord(projected);
  }

  AccountProfileWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return AccountProfileWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<AccountProfile> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required AccountProfileUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('AccountProfile');
    await txDelegate.update(
      UpdateQuery(
        model: 'AccountProfile',
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
        model: 'AccountProfile',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('AccountProfile update branch could not reload the updated record for the provided unique selector.');
    }
    return AccountProfile.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required AccountProfileUpdateInput data,
  }) async {
    if (data.account == null) {
      // No nested writes for account.
    } else {
      final nested = data.account!;
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for AccountProfileUpdateInput.account.');
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.account._delegate.findUnique(
          FindUniqueQuery(
            model: 'Account',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related Account record found for nested connect on AccountProfile.account.');
        }
        await tx._client.model('AccountProfile').update(
          UpdateQuery(
            model: 'AccountProfile',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(related, 'tenantId', 'nested direct relation write on AccountProfile.account'),
              'accountSlug': _requireRecordValue(related, 'slug', 'nested direct relation write on AccountProfile.account'),
            },
          ),
        );
      }
      if (nested.connectOrCreate != null) {
        final entry = nested.connectOrCreate!;
        final related = await tx.account._delegate.findUnique(
          FindUniqueQuery(
            model: 'Account',
            where: entry.where.toPredicates(),
          ),
        );
        final relatedRecord = related ??
            await tx.account._delegate.create(
              CreateQuery(
                model: 'Account',
                data: entry.create.toData(),
                nestedCreates: entry.create.toNestedCreates(),
              ),
            );
        await tx._client.model('AccountProfile').update(
          UpdateQuery(
            model: 'AccountProfile',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(relatedRecord, 'tenantId', 'nested direct relation write on AccountProfile.account'),
              'accountSlug': _requireRecordValue(relatedRecord, 'slug', 'nested direct relation write on AccountProfile.account'),
            },
          ),
        );
      }
      if (nested.disconnect) {
        throw StateError('Nested disconnect is not supported for required relation AccountProfile.account.');
      }
    }
  }


  Future<AccountProfile> delete({
    required AccountProfileWhereUniqueInput where,
    AccountProfileInclude? include,
    AccountProfileSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'AccountProfile',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(AccountProfile.fromRecord);
  }

  Future<int> deleteMany({
    required AccountProfileWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'AccountProfile',
        where: where.toPredicates(),
      ),
    );
  }
}

class AccountProfileWhereInput {
  const AccountProfileWhereInput({this.AND = const <AccountProfileWhereInput>[], this.OR = const <AccountProfileWhereInput>[], this.NOT = const <AccountProfileWhereInput>[], this.id, this.idFilter, this.tenantId, this.tenantIdFilter, this.accountSlug, this.accountSlugFilter, this.bio, this.bioFilter, this.accountIs, this.accountIsNot, });

  final List<AccountProfileWhereInput> AND;
  final List<AccountProfileWhereInput> OR;
  final List<AccountProfileWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? accountSlug;
  final StringFilter? accountSlugFilter;
  final String? bio;
  final StringFilter? bioFilter;
  final AccountWhereInput? accountIs;
  final AccountWhereInput? accountIsNot;

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
    if (tenantId != null) {
      predicates.add(QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId));
    }
    if (tenantIdFilter != null) {
      predicates.addAll(tenantIdFilter!.toPredicates('tenantId'));
    }
    if (accountSlug != null) {
      predicates.add(QueryPredicate(field: 'accountSlug', operator: 'equals', value: accountSlug));
    }
    if (accountSlugFilter != null) {
      predicates.addAll(accountSlugFilter!.toPredicates('accountSlug'));
    }
    if (bio != null) {
      predicates.add(QueryPredicate(field: 'bio', operator: 'equals', value: bio));
    }
    if (bioFilter != null) {
      predicates.addAll(bioFilter!.toPredicates('bio'));
    }
    if (accountIs != null) {
      predicates.add(QueryPredicate(field: 'account', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'account', targetModel: 'Account', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'accountSlug'], targetKeyFields: const <String>['tenantId', 'slug']), predicates: accountIs!.toPredicates())));
    }
    if (accountIsNot != null) {
      predicates.add(QueryPredicate(field: 'account', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'account', targetModel: 'Account', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'accountSlug'], targetKeyFields: const <String>['tenantId', 'slug']), predicates: accountIsNot!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class AccountProfileTenantIdAccountSlugCompoundUniqueInput {
  const AccountProfileTenantIdAccountSlugCompoundUniqueInput({required this.tenantId, required this.accountSlug, });

  final int tenantId;
  final String accountSlug;

  List<QueryPredicate> toPredicates() {
    return List<QueryPredicate>.unmodifiable(<QueryPredicate>[
      QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
      QueryPredicate(field: 'accountSlug', operator: 'equals', value: accountSlug),
    ]);
  }

  bool matchesRecord(Map<String, Object?> record) {
    return record['tenantId'] == tenantId && record['accountSlug'] == accountSlug;
  }
}

class AccountProfileWhereUniqueInput {
  const AccountProfileWhereUniqueInput({this.id, this.tenantId_accountSlug, });

  final int? id;
  final AccountProfileTenantIdAccountSlugCompoundUniqueInput? tenantId_accountSlug;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (tenantId_accountSlug != null) {
      selectors.add(tenantId_accountSlug!.toPredicates());
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for AccountProfileWhereUniqueInput.');
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
    if (tenantId_accountSlug != null) {
      selectorCount++;
      matches = tenantId_accountSlug!.matchesRecord(record);
    }
    if (selectorCount != 1) {
      throw StateError('Exactly one unique selector must be provided for AccountProfileWhereUniqueInput.');
    }
    return matches;
  }
}

class AccountProfileOrderByInput {
  const AccountProfileOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? bio;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(QueryOrderBy(field: 'tenantId', direction: tenantId!));
    }
    if (accountSlug != null) {
      orderings.add(QueryOrderBy(field: 'accountSlug', direction: accountSlug!));
    }
    if (bio != null) {
      orderings.add(QueryOrderBy(field: 'bio', direction: bio!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum AccountProfileScalarField {
  id,
  tenantId,
  accountSlug,
  bio
}

class AccountProfileCountAggregateInput {
  const AccountProfileCountAggregateInput({this.all = false, this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

  final bool all;
  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool bio;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    if (accountSlug) {
      fields.add('accountSlug');
    }
    if (bio) {
      fields.add('bio');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class AccountProfileAvgAggregateInput {
  const AccountProfileAvgAggregateInput({this.id = false, this.tenantId = false, });

  final bool id;
  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountProfileSumAggregateInput {
  const AccountProfileSumAggregateInput({this.id = false, this.tenantId = false, });

  final bool id;
  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountProfileMinAggregateInput {
  const AccountProfileMinAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool bio;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    if (accountSlug) {
      fields.add('accountSlug');
    }
    if (bio) {
      fields.add('bio');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountProfileMaxAggregateInput {
  const AccountProfileMaxAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool bio;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    if (accountSlug) {
      fields.add('accountSlug');
    }
    if (bio) {
      fields.add('bio');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountProfileCountAggregateResult {
  const AccountProfileCountAggregateResult({this.all, this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? all;
  final int? id;
  final int? tenantId;
  final int? accountSlug;
  final int? bio;

  factory AccountProfileCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return AccountProfileCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      tenantId: result.fields['tenantId'],
      accountSlug: result.fields['accountSlug'],
      bio: result.fields['bio'],
    );
  }
}

class AccountProfileAvgAggregateResult {
  const AccountProfileAvgAggregateResult({this.id, this.tenantId, });

  final double? id;
  final double? tenantId;

  factory AccountProfileAvgAggregateResult.fromMap(Map<String, double?> values) {
    return AccountProfileAvgAggregateResult(
      id: _asDouble(values['id']),
      tenantId: _asDouble(values['tenantId']),
    );
  }
}

class AccountProfileSumAggregateResult {
  const AccountProfileSumAggregateResult({this.id, this.tenantId, });

  final int? id;
  final int? tenantId;

  factory AccountProfileSumAggregateResult.fromMap(Map<String, num?> values) {
    return AccountProfileSumAggregateResult(
      id: values['id']?.toInt(),
      tenantId: values['tenantId']?.toInt(),
    );
  }
}

class AccountProfileMinAggregateResult {
  const AccountProfileMinAggregateResult({this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;

  factory AccountProfileMinAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountProfileMinAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
      bio: values['bio'] as String?,
    );
  }
}

class AccountProfileMaxAggregateResult {
  const AccountProfileMaxAggregateResult({this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;

  factory AccountProfileMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountProfileMaxAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
      bio: values['bio'] as String?,
    );
  }
}

class AccountProfileAggregateResult {
  const AccountProfileAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final AccountProfileCountAggregateResult? count;
  final AccountProfileAvgAggregateResult? avg;
  final AccountProfileSumAggregateResult? sum;
  final AccountProfileMinAggregateResult? min;
  final AccountProfileMaxAggregateResult? max;

  factory AccountProfileAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return AccountProfileAggregateResult(
      count: result.count == null ? null : AccountProfileCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : AccountProfileAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : AccountProfileSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : AccountProfileMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : AccountProfileMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class AccountProfileGroupByHavingInput {
  const AccountProfileGroupByHavingInput({this.id, this.tenantId, });

  final NumericAggregatesFilter? id;
  final NumericAggregatesFilter? tenantId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    if (tenantId != null) {
      predicates.addAll(tenantId!.toPredicates('tenantId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class AccountProfileCountAggregateOrderByInput {
  const AccountProfileCountAggregateOrderByInput({this.all, this.id, this.tenantId, this.accountSlug, this.bio, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));
    }
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (accountSlug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'accountSlug', direction: accountSlug!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountProfileAvgAggregateOrderByInput {
  const AccountProfileAvgAggregateOrderByInput({this.id, this.tenantId, });

  final SortOrder? id;
  final SortOrder? tenantId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountProfileSumAggregateOrderByInput {
  const AccountProfileSumAggregateOrderByInput({this.id, this.tenantId, });

  final SortOrder? id;
  final SortOrder? tenantId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountProfileMinAggregateOrderByInput {
  const AccountProfileMinAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (accountSlug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'accountSlug', direction: accountSlug!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountProfileMaxAggregateOrderByInput {
  const AccountProfileMaxAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? bio;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (accountSlug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'accountSlug', direction: accountSlug!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'bio', direction: bio!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountProfileGroupByOrderByInput {
  const AccountProfileGroupByOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? bio;
  final AccountProfileCountAggregateOrderByInput? count;
  final AccountProfileAvgAggregateOrderByInput? avg;
  final AccountProfileSumAggregateOrderByInput? sum;
  final AccountProfileMinAggregateOrderByInput? min;
  final AccountProfileMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
    }
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.field(field: 'tenantId', direction: tenantId!));
    }
    if (accountSlug != null) {
      orderings.add(GroupByOrderBy.field(field: 'accountSlug', direction: accountSlug!));
    }
    if (bio != null) {
      orderings.add(GroupByOrderBy.field(field: 'bio', direction: bio!));
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

class AccountProfileGroupByRow {
  const AccountProfileGroupByRow({this.id, this.tenantId, this.accountSlug, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;
  final AccountProfileCountAggregateResult? count;
  final AccountProfileAvgAggregateResult? avg;
  final AccountProfileSumAggregateResult? sum;
  final AccountProfileMinAggregateResult? min;
  final AccountProfileMaxAggregateResult? max;

  factory AccountProfileGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return AccountProfileGroupByRow(
      id: row.group['id'] as int?,
      tenantId: row.group['tenantId'] as int?,
      accountSlug: row.group['accountSlug'] as String?,
      bio: row.group['bio'] as String?,
      count: row.aggregates.count == null ? null : AccountProfileCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : AccountProfileAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : AccountProfileSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : AccountProfileMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : AccountProfileMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class AccountProfileInclude {
  const AccountProfileInclude({this.account = false, });

  final bool account;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (account) {
      relations['account'] = QueryIncludeEntry(relation: QueryRelation(field: 'account', targetModel: 'Account', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'accountSlug'], targetKeyFields: const <String>['tenantId', 'slug']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class AccountProfileSelect {
  const AccountProfileSelect({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool bio;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (tenantId) {
      fields.add('tenantId');
    }
    if (accountSlug) {
      fields.add('accountSlug');
    }
    if (bio) {
      fields.add('bio');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class AccountProfileCreateInput {
  const AccountProfileCreateInput({required this.id, required this.tenantId, required this.accountSlug, this.bio, this.account, });

  final int id;
  final int tenantId;
  final String accountSlug;
  final String? bio;
  final AccountCreateNestedOneWithoutProfileInput? account;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    data['tenantId'] = tenantId;
    data['accountSlug'] = accountSlug;
    if (bio != null) {
      data['bio'] = bio;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
        QueryPredicate(field: 'accountSlug', operator: 'equals', value: accountSlug),
      ]);
    return List<List<QueryPredicate>>.unmodifiable(selectors.map(List<QueryPredicate>.unmodifiable));
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (account != null) {
      writes.addAll(account!.toRelationWrites(QueryRelation(field: 'account', targetModel: 'Account', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'accountSlug'], targetKeyFields: const <String>['tenantId', 'slug'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (account?.hasDeferredWrites ?? false);
  }

  AccountProfileUpdateInput toDeferredRelationUpdateInput() {
    return AccountProfileUpdateInput(
      account: account?.toDeferredUpdateWrite(),
    );
  }
}

class AccountProfileUpdateInput {
  const AccountProfileUpdateInput({this.tenantId, this.tenantIdOps, this.accountSlug, this.accountSlugOps, this.bio, this.bioOps, this.account, });

  final int? tenantId;
  final IntFieldUpdateOperationsInput? tenantIdOps;
  final String? accountSlug;
  final StringFieldUpdateOperationsInput? accountSlugOps;
  final String? bio;
  final StringFieldUpdateOperationsInput? bioOps;
  final AccountUpdateNestedOneWithoutProfileInput? account;

  bool get hasComputedOperators {
    return tenantIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return account?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for AccountProfileUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for AccountProfileUpdateInput.tenantId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for AccountProfileUpdateInput.tenantId require the current record value before they can be converted to raw update data.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for AccountProfileUpdateInput.accountSlug.');
    }
    if (accountSlug != null) {
      data['accountSlug'] = accountSlug;
    }
    if (accountSlugOps != null) {
      final ops = accountSlugOps!;
      if (ops.hasSet) {
        data['accountSlug'] = ops.set as String?;
      }
    }
    if (bio != null && bioOps != null) {
      throw StateError('Only one of bio or bioOps may be provided for AccountProfileUpdateInput.bio.');
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (bioOps != null) {
      final ops = bioOps!;
      if (ops.hasSet) {
        data['bio'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for AccountProfileUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for AccountProfileUpdateInput.tenantId.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      } else {
        final currentValue = record['tenantId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment AccountProfileUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement AccountProfileUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for AccountProfileUpdateInput.accountSlug.');
    }
    if (accountSlug != null) {
      data['accountSlug'] = accountSlug;
    }
    if (accountSlugOps != null) {
      final ops = accountSlugOps!;
      if (ops.hasSet) {
        data['accountSlug'] = ops.set as String?;
      }
    }
    if (bio != null && bioOps != null) {
      throw StateError('Only one of bio or bioOps may be provided for AccountProfileUpdateInput.bio.');
    }
    if (bio != null) {
      data['bio'] = bio;
    }
    if (bioOps != null) {
      final ops = bioOps!;
      if (ops.hasSet) {
        data['bio'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class AccountProfileCreateWithoutAccountInput {
  const AccountProfileCreateWithoutAccountInput({required this.id, this.bio, });

  final int id;
  final String? bio;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    if (bio != null) {
      data['bio'] = bio;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class AccountConnectOrCreateWithoutProfileInput {
  const AccountConnectOrCreateWithoutProfileInput({required this.where, required this.create});

  final AccountWhereUniqueInput where;
  final AccountCreateWithoutProfileInput create;
}

class AccountCreateNestedOneWithoutProfileInput {
  const AccountCreateNestedOneWithoutProfileInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountCreateWithoutProfileInput? create;
  final AccountWhereUniqueInput? connect;
  final AccountConnectOrCreateWithoutProfileInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountCreateNestedOneWithoutProfileInput.');
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

  AccountUpdateNestedOneWithoutProfileInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountCreateNestedOneWithoutProfileInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return AccountUpdateNestedOneWithoutProfileInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class AccountUpdateNestedOneWithoutProfileInput {
  const AccountUpdateNestedOneWithoutProfileInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountWhereUniqueInput? connect;
  final AccountConnectOrCreateWithoutProfileInput? connectOrCreate;
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

