// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

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
  late final PostDelegate post = PostDelegate._(_client);
  late final ProfileDelegate profile = ProfileDelegate._(_client);
  late final GroupDelegate group = GroupDelegate._(_client);
  late final MembershipDelegate membership = MembershipDelegate._(_client);

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

class GeneratedComonOrmClientSqlite {
  const GeneratedComonOrmClientSqlite._();

  static Future<GeneratedComonOrmClient> open({
    String? databasePath,
    String? datasourceName,
    RuntimeDatasourceResolver resolver = const RuntimeDatasourceResolver(),
    SqliteRuntimeAdapterFactory? adapterFactory,
  }) async {
    final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(
      schema: GeneratedComonOrmClient.runtimeSchema,
      databasePath: databasePath,
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
        provider: 'sqlite',
        url: GeneratedDatasourceUrl(
          kind: GeneratedDatasourceUrlKind.env,
          value: 'DATABASE_URL',
        ),
      ),
    ],
    enums: <GeneratedEnumMetadata>[
      GeneratedEnumMetadata(
        name: 'UserRole',
        databaseName: 'user_role',
        values: <String>['admin', 'member'],
      ),
    ],
    models: <GeneratedModelMetadata>[
      GeneratedModelMetadata(
        name: 'User',
        databaseName: 'users',
        primaryKeyFields: <String>['id'],
        compoundUniqueFieldSets: <List<String>>[
          <String>['email', 'role'],
        ],
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
            databaseName: 'email_address',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: true,
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
            name: 'updatedAt',
            databaseName: 'updatedAt',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'DateTime',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: true,
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
            name: 'managerId',
            databaseName: 'managerId',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'manager',
            databaseName: 'manager',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'User',
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'User',
              cardinality: GeneratedRuntimeRelationCardinality.one,
              storageKind: GeneratedRuntimeRelationStorageKind.direct,
              localFields: <String>['managerId'],
              targetFields: <String>['id'],
              relationName: 'ManagerChain',
              inverseField: 'reports',
            ),
          ),
          GeneratedFieldMetadata(
            name: 'reports',
            databaseName: 'reports',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'User',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'User',
              cardinality: GeneratedRuntimeRelationCardinality.many,
              storageKind: GeneratedRuntimeRelationStorageKind.direct,
              localFields: <String>['id'],
              targetFields: <String>['managerId'],
              relationName: 'ManagerChain',
              inverseField: 'manager',
            ),
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
              targetFields: <String>['authorId'],
              relationName: 'UserPosts',
              inverseField: 'author',
            ),
          ),
          GeneratedFieldMetadata(
            name: 'groups',
            databaseName: 'groups',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Group',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'Group',
              cardinality: GeneratedRuntimeRelationCardinality.many,
              storageKind:
                  GeneratedRuntimeRelationStorageKind.implicitManyToMany,
              localFields: <String>['id'],
              targetFields: <String>['id'],
              inverseField: 'users',
              storageTableName:
                  '_comon_orm_m2m__Z3JvdXBz__dXNlcnM__dXNlcnM__Z3JvdXBz',
              sourceJoinColumns: <String>['m2m__dXNlcnM__Z3JvdXBz__aWQ'],
              targetJoinColumns: <String>['m2m__Z3JvdXBz__dXNlcnM__aWQ'],
            ),
          ),
          GeneratedFieldMetadata(
            name: 'memberships',
            databaseName: 'memberships',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Membership',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'Membership',
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
        databaseName: 'posts',
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
            name: 'authorId',
            databaseName: 'author_id',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'Int',
            isNullable: false,
            isList: false,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'author',
            databaseName: 'author',
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
              localFields: <String>['authorId'],
              targetFields: <String>['id'],
              relationName: 'UserPosts',
              inverseField: 'posts',
            ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Profile',
        databaseName: 'profiles',
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
            isNullable: true,
            isList: false,
            isId: false,
            isUnique: true,
            isUpdatedAt: false,
          ),
          GeneratedFieldMetadata(
            name: 'user',
            databaseName: 'user',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'User',
            isNullable: true,
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
        name: 'Group',
        databaseName: 'groups',
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
            name: 'users',
            databaseName: 'users',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'User',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
              targetModel: 'User',
              cardinality: GeneratedRuntimeRelationCardinality.many,
              storageKind:
                  GeneratedRuntimeRelationStorageKind.implicitManyToMany,
              localFields: <String>['id'],
              targetFields: <String>['id'],
              inverseField: 'groups',
              storageTableName:
                  '_comon_orm_m2m__Z3JvdXBz__dXNlcnM__dXNlcnM__Z3JvdXBz',
              sourceJoinColumns: <String>['m2m__Z3JvdXBz__dXNlcnM__aWQ'],
              targetJoinColumns: <String>['m2m__dXNlcnM__Z3JvdXBz__aWQ'],
            ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Membership',
        databaseName: 'memberships',
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
              inverseField: 'memberships',
            ),
          ),
        ],
      ),
    ],
  );
}

enum UserRole { admin, member }

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
  const User({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
    this.manager,
    this.reports,
    this.profile,
    this.posts,
    this.groups,
    this.memberships,
  });

  final int? id;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole? role;
  final int? managerId;
  final User? manager;
  final List<User>? reports;
  final Profile? profile;
  final List<Post>? posts;
  final List<Group>? groups;
  final List<Membership>? memberships;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      email: record['email'] as String?,
      createdAt: _asDateTime(record['createdAt']),
      updatedAt: _asDateTime(record['updatedAt']),
      role: record['role'] == null
          ? null
          : UserRole.values.byName(record['role'] as String),
      managerId: record['managerId'] as int?,
      manager: record['manager'] == null
          ? null
          : User.fromRecord(record['manager'] as Map<String, Object?>),
      reports: (record['reports'] as List<Object?>?)
          ?.map((item) => User.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
      profile: record['profile'] == null
          ? null
          : Profile.fromRecord(record['profile'] as Map<String, Object?>),
      posts: (record['posts'] as List<Object?>?)
          ?.map((item) => Post.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
      groups: (record['groups'] as List<Object?>?)
          ?.map((item) => Group.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
      memberships: (record['memberships'] as List<Object?>?)
          ?.map((item) => Membership.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      email: json['email'] as String?,
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      role: json['role'] == null
          ? null
          : UserRole.values.byName(json['role'] as String),
      managerId: json['managerId'] as int?,
      manager: json['manager'] == null
          ? null
          : User.fromJson(json['manager'] as Map<String, Object?>),
      reports: (json['reports'] as List<Object?>?)
          ?.map((item) => User.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
      profile: json['profile'] == null
          ? null
          : Profile.fromJson(json['profile'] as Map<String, Object?>),
      posts: (json['posts'] as List<Object?>?)
          ?.map((item) => Post.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
      groups: (json['groups'] as List<Object?>?)
          ?.map((item) => Group.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
      memberships: (json['memberships'] as List<Object?>?)
          ?.map((item) => Membership.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  User copyWith({
    Object? id = _undefined,
    Object? email = _undefined,
    Object? createdAt = _undefined,
    Object? updatedAt = _undefined,
    Object? role = _undefined,
    Object? managerId = _undefined,
    Object? manager = _undefined,
    Object? reports = _undefined,
    Object? profile = _undefined,
    Object? posts = _undefined,
    Object? groups = _undefined,
    Object? memberships = _undefined,
  }) {
    return User(
      id: id == _undefined ? this.id : id as int?,
      email: email == _undefined ? this.email : email as String?,
      createdAt: createdAt == _undefined
          ? this.createdAt
          : createdAt as DateTime?,
      updatedAt: updatedAt == _undefined
          ? this.updatedAt
          : updatedAt as DateTime?,
      role: role == _undefined ? this.role : role as UserRole?,
      managerId: managerId == _undefined ? this.managerId : managerId as int?,
      manager: manager == _undefined ? this.manager : manager as User?,
      reports: reports == _undefined ? this.reports : reports as List<User>?,
      profile: profile == _undefined ? this.profile : profile as Profile?,
      posts: posts == _undefined ? this.posts : posts as List<Post>?,
      groups: groups == _undefined ? this.groups : groups as List<Group>?,
      memberships: memberships == _undefined
          ? this.memberships
          : memberships as List<Membership>?,
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
    if (createdAt != null) {
      record['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      record['updatedAt'] = updatedAt;
    }
    if (role != null) {
      record['role'] = role!.name;
    }
    if (managerId != null) {
      record['managerId'] = managerId;
    }
    if (manager != null) {
      record['manager'] = manager!.toRecord();
    }
    if (reports != null) {
      record['reports'] = reports!
          .map((item) => item.toRecord())
          .toList(growable: false);
    }
    if (profile != null) {
      record['profile'] = profile!.toRecord();
    }
    if (posts != null) {
      record['posts'] = posts!
          .map((item) => item.toRecord())
          .toList(growable: false);
    }
    if (groups != null) {
      record['groups'] = groups!
          .map((item) => item.toRecord())
          .toList(growable: false);
    }
    if (memberships != null) {
      record['memberships'] = memberships!
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
    if (email != null) {
      json['email'] = email;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      json['updatedAt'] = updatedAt!.toIso8601String();
    }
    if (role != null) {
      json['role'] = role!.name;
    }
    if (managerId != null) {
      json['managerId'] = managerId;
    }
    if (manager != null) {
      json['manager'] = manager!.toJson();
    }
    if (reports != null) {
      json['reports'] = reports!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    if (profile != null) {
      json['profile'] = profile!.toJson();
    }
    if (posts != null) {
      json['posts'] = posts!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    if (groups != null) {
      json['groups'] = groups!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    if (memberships != null) {
      json['memberships'] = memberships!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() =>
      'User(id: $id, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, role: $role, managerId: $managerId, manager: $manager, reports: $reports, profile: $profile, posts: $posts, groups: $groups, memberships: $memberships)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
            _deepEquals(id, other.id) &&
            _deepEquals(email, other.email) &&
            _deepEquals(createdAt, other.createdAt) &&
            _deepEquals(updatedAt, other.updatedAt) &&
            _deepEquals(role, other.role) &&
            _deepEquals(managerId, other.managerId) &&
            _deepEquals(manager, other.manager) &&
            _deepEquals(reports, other.reports) &&
            _deepEquals(profile, other.profile) &&
            _deepEquals(posts, other.posts) &&
            _deepEquals(groups, other.groups) &&
            _deepEquals(memberships, other.memberships);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(email),
    _deepHash(createdAt),
    _deepHash(updatedAt),
    _deepHash(role),
    _deepHash(managerId),
    _deepHash(manager),
    _deepHash(reports),
    _deepHash(profile),
    _deepHash(posts),
    _deepHash(groups),
    _deepHash(memberships),
  ]);
}

class Post {
  const Post({this.id, this.authorId, this.author});

  final int? id;
  final int? authorId;
  final User? author;

  factory Post.fromRecord(Map<String, Object?> record) {
    return Post(
      id: record['id'] as int?,
      authorId: record['authorId'] as int?,
      author: record['author'] == null
          ? null
          : User.fromRecord(record['author'] as Map<String, Object?>),
    );
  }

  factory Post.fromJson(Map<String, Object?> json) {
    return Post(
      id: json['id'] as int?,
      authorId: json['authorId'] as int?,
      author: json['author'] == null
          ? null
          : User.fromJson(json['author'] as Map<String, Object?>),
    );
  }

  Post copyWith({
    Object? id = _undefined,
    Object? authorId = _undefined,
    Object? author = _undefined,
  }) {
    return Post(
      id: id == _undefined ? this.id : id as int?,
      authorId: authorId == _undefined ? this.authorId : authorId as int?,
      author: author == _undefined ? this.author : author as User?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (authorId != null) {
      record['authorId'] = authorId;
    }
    if (author != null) {
      record['author'] = author!.toRecord();
    }
    return Map<String, Object?>.unmodifiable(record);
  }

  Map<String, Object?> toJson() {
    final json = <String, Object?>{};
    if (id != null) {
      json['id'] = id;
    }
    if (authorId != null) {
      json['authorId'] = authorId;
    }
    if (author != null) {
      json['author'] = author!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Post(id: $id, authorId: $authorId, author: $author)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Post &&
            _deepEquals(id, other.id) &&
            _deepEquals(authorId, other.authorId) &&
            _deepEquals(author, other.author);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(authorId),
    _deepHash(author),
  ]);
}

class Profile {
  const Profile({this.id, this.userId, this.user});

  final int? id;
  final int? userId;
  final User? user;

  factory Profile.fromRecord(Map<String, Object?> record) {
    return Profile(
      id: record['id'] as int?,
      userId: record['userId'] as int?,
      user: record['user'] == null
          ? null
          : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Profile.fromJson(Map<String, Object?> json) {
    return Profile(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  Profile copyWith({
    Object? id = _undefined,
    Object? userId = _undefined,
    Object? user = _undefined,
  }) {
    return Profile(
      id: id == _undefined ? this.id : id as int?,
      userId: userId == _undefined ? this.userId : userId as int?,
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
    if (user != null) {
      json['user'] = user!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Profile(id: $id, userId: $userId, user: $user)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Profile &&
            _deepEquals(id, other.id) &&
            _deepEquals(userId, other.userId) &&
            _deepEquals(user, other.user);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(userId),
    _deepHash(user),
  ]);
}

class Group {
  const Group({this.id, this.users});

  final int? id;
  final List<User>? users;

  factory Group.fromRecord(Map<String, Object?> record) {
    return Group(
      id: record['id'] as int?,
      users: (record['users'] as List<Object?>?)
          ?.map((item) => User.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  factory Group.fromJson(Map<String, Object?> json) {
    return Group(
      id: json['id'] as int?,
      users: (json['users'] as List<Object?>?)
          ?.map((item) => User.fromJson(item as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  Group copyWith({Object? id = _undefined, Object? users = _undefined}) {
    return Group(
      id: id == _undefined ? this.id : id as int?,
      users: users == _undefined ? this.users : users as List<User>?,
    );
  }

  Map<String, Object?> toRecord() {
    final record = <String, Object?>{};
    if (id != null) {
      record['id'] = id;
    }
    if (users != null) {
      record['users'] = users!
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
    if (users != null) {
      json['users'] = users!
          .map((item) => item.toJson())
          .toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Group(id: $id, users: $users)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Group &&
            _deepEquals(id, other.id) &&
            _deepEquals(users, other.users);
  }

  @override
  int get hashCode =>
      Object.hashAll(<Object?>[runtimeType, _deepHash(id), _deepHash(users)]);
}

class Membership {
  const Membership({this.tenantId, this.slug, this.userId, this.user});

  final int? tenantId;
  final String? slug;
  final int? userId;
  final User? user;

  factory Membership.fromRecord(Map<String, Object?> record) {
    return Membership(
      tenantId: record['tenantId'] as int?,
      slug: record['slug'] as String?,
      userId: record['userId'] as int?,
      user: record['user'] == null
          ? null
          : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Membership.fromJson(Map<String, Object?> json) {
    return Membership(
      tenantId: json['tenantId'] as int?,
      slug: json['slug'] as String?,
      userId: json['userId'] as int?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  Membership copyWith({
    Object? tenantId = _undefined,
    Object? slug = _undefined,
    Object? userId = _undefined,
    Object? user = _undefined,
  }) {
    return Membership(
      tenantId: tenantId == _undefined ? this.tenantId : tenantId as int?,
      slug: slug == _undefined ? this.slug : slug as String?,
      userId: userId == _undefined ? this.userId : userId as int?,
      user: user == _undefined ? this.user : user as User?,
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
    if (tenantId != null) {
      json['tenantId'] = tenantId;
    }
    if (slug != null) {
      json['slug'] = slug;
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
      'Membership(tenantId: $tenantId, slug: $slug, userId: $userId, user: $user)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Membership &&
            _deepEquals(tenantId, other.tenantId) &&
            _deepEquals(slug, other.slug) &&
            _deepEquals(userId, other.userId) &&
            _deepEquals(user, other.user);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(tenantId),
    _deepHash(slug),
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
    if (data.manager == null) {
      // No nested writes for manager.
    } else {
      final nested = data.manager!;
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError(
          'Only one of connect, connectOrCreate or disconnect may be provided for UserUpdateInput.manager.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on User.manager.',
          );
        }
        await tx._client
            .model('User')
            .update(
              UpdateQuery(
                model: 'User',
                where: predicates,
                data: <String, Object?>{
                  'managerId': _requireRecordValue(
                    related,
                    'id',
                    'nested direct relation write on User.manager',
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
            .model('User')
            .update(
              UpdateQuery(
                model: 'User',
                where: predicates,
                data: <String, Object?>{
                  'managerId': _requireRecordValue(
                    relatedRecord,
                    'id',
                    'nested direct relation write on User.manager',
                  ),
                },
              ),
            );
      }
      if (nested.disconnect) {
        await tx._client
            .model('User')
            .update(
              UpdateQuery(
                model: 'User',
                where: predicates,
                data: <String, Object?>{'managerId': null},
              ),
            );
      }
    }
    if (data.reports == null) {
      // No nested writes for reports.
    } else {
      final nested = data.reports!;
      final parentReferenceValues = <String, Object?>{
        'managerId': _requireRecordValue(
          existing,
          'id',
          'nested direct relation write on User.reports',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.reports.',
        );
      }
      if (nested.set != null) {
        await tx.user._delegate.updateMany(
          UpdateManyQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'managerId',
                operator: 'equals',
                value: parentReferenceValues['managerId'],
              ),
            ],
            data: <String, Object?>{'managerId': null},
          ),
        );
        for (final selector in nested.set!) {
          await tx.user._delegate.update(
            UpdateQuery(
              model: 'User',
              where: selector.toPredicates(),
              data: <String, Object?>{
                'managerId': parentReferenceValues['managerId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.connect) {
        await tx.user._delegate.update(
          UpdateQuery(
            model: 'User',
            where: selector.toPredicates(),
            data: <String, Object?>{
              'managerId': parentReferenceValues['managerId'],
            },
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: entry.where.toPredicates()),
        );
        if (related == null) {
          await tx.user._delegate.create(
            CreateQuery(
              model: 'User',
              data: <String, Object?>{
                ...entry.create.toData(),
                'managerId': parentReferenceValues['managerId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        } else {
          await tx.user._delegate.update(
            UpdateQuery(
              model: 'User',
              where: entry.where.toPredicates(),
              data: <String, Object?>{
                'managerId': parentReferenceValues['managerId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        await tx.user._delegate.update(
          UpdateQuery(
            model: 'User',
            where: selector.toPredicates(),
            data: <String, Object?>{'managerId': null},
          ),
        );
      }
    }
    if (data.profile == null) {
      // No nested writes for profile.
    } else {
      final nested = data.profile!;
      final parentReferenceValues = <String, Object?>{
        'userId': _requireRecordValue(
          existing,
          'id',
          'nested inverse one-to-one relation write on User.profile',
        ),
      };
      final currentRelated = await tx.profile._delegate.findFirst(
        FindFirstQuery(
          model: 'Profile',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'userId',
              operator: 'equals',
              value: parentReferenceValues['userId'],
            ),
          ],
        ),
      );
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError(
          'Only one of connect, connectOrCreate or disconnect may be provided for UserUpdateInput.profile.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.profile._delegate.findUnique(
          FindUniqueQuery(model: 'Profile', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Profile record found for nested connect on inverse one-to-one relation User.profile.',
          );
        }
        final alreadyConnected =
            related['userId'] == parentReferenceValues['userId'];
        if (!alreadyConnected) {
          if (currentRelated != null) {
            await tx.profile._delegate.updateMany(
              UpdateManyQuery(
                model: 'Profile',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'userId',
                    operator: 'equals',
                    value: parentReferenceValues['userId'],
                  ),
                ],
                data: <String, Object?>{'userId': null},
              ),
            );
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
          FindUniqueQuery(model: 'Profile', where: entry.where.toPredicates()),
        );
        if (related != null) {
          final alreadyConnected =
              related['userId'] == parentReferenceValues['userId'];
          if (!alreadyConnected) {
            if (currentRelated != null) {
              await tx.profile._delegate.updateMany(
                UpdateManyQuery(
                  model: 'Profile',
                  where: <QueryPredicate>[
                    QueryPredicate(
                      field: 'userId',
                      operator: 'equals',
                      value: parentReferenceValues['userId'],
                    ),
                  ],
                  data: <String, Object?>{'userId': null},
                ),
              );
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
            await tx.profile._delegate.updateMany(
              UpdateManyQuery(
                model: 'Profile',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'userId',
                    operator: 'equals',
                    value: parentReferenceValues['userId'],
                  ),
                ],
                data: <String, Object?>{'userId': null},
              ),
            );
          }
          await tx.profile._delegate.create(
            CreateQuery(
              model: 'Profile',
              data: <String, Object?>{
                ...entry.create.toData(),
                'userId': parentReferenceValues['userId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        }
      }
      if (nested.disconnect) {
        await tx.profile._delegate.updateMany(
          UpdateManyQuery(
            model: 'Profile',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'userId',
                operator: 'equals',
                value: parentReferenceValues['userId'],
              ),
            ],
            data: <String, Object?>{'userId': null},
          ),
        );
      }
    }
    if (data.posts == null) {
      // No nested writes for posts.
    } else {
      final nested = data.posts!;
      final parentReferenceValues = <String, Object?>{
        'authorId': _requireRecordValue(
          existing,
          'id',
          'nested direct relation write on User.posts',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.posts.',
        );
      }
      final currentRelatedRecords = await tx.post._delegate.findMany(
        FindManyQuery(
          model: 'Post',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'authorId',
              operator: 'equals',
              value: parentReferenceValues['authorId'],
            ),
          ],
        ),
      );
      if (nested.set != null) {
        final targetRecords = <Map<String, Object?>>[];
        for (final selector in nested.set!) {
          final related = await tx.post._delegate.findUnique(
            FindUniqueQuery(model: 'Post', where: selector.toPredicates()),
          );
          if (related == null) {
            throw StateError(
              'No related Post record found for nested set on User.posts.',
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
              'Nested set is not supported for required relation User.posts when it would disconnect already attached required related records.',
            );
          }
        }
        for (final related in targetRecords) {
          await tx.post._delegate.update(
            UpdateQuery(
              model: 'Post',
              where: tx.post
                  ._primaryKeyWhereUniqueFromRecord(related)
                  .toPredicates(),
              data: <String, Object?>{
                'authorId': parentReferenceValues['authorId'],
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
              'authorId': parentReferenceValues['authorId'],
            },
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.post._delegate.findUnique(
          FindUniqueQuery(model: 'Post', where: entry.where.toPredicates()),
        );
        if (related == null) {
          await tx.post._delegate.create(
            CreateQuery(
              model: 'Post',
              data: <String, Object?>{
                ...entry.create.toData(),
                'authorId': parentReferenceValues['authorId'],
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
                'authorId': parentReferenceValues['authorId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        final related = await tx.post._delegate.findUnique(
          FindUniqueQuery(model: 'Post', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Post record found for nested disconnect on User.posts.',
          );
        }
        final isCurrentlyAttached = currentRelatedRecords.any((current) {
          return current['id'] == related['id'];
        });
        if (isCurrentlyAttached) {
          throw StateError(
            'Nested disconnect is not supported for required relation User.posts when it would disconnect already attached required related records.',
          );
        }
      }
    }
    if (data.groups == null) {
      // No nested writes for groups.
    } else {
      final nested = data.groups!;
      final relation = QueryRelation(
        field: 'groups',
        targetModel: 'Group',
        cardinality: QueryRelationCardinality.many,
        localKeyField: 'id',
        targetKeyField: 'id',
        localKeyFields: const <String>['id'],
        targetKeyFields: const <String>['id'],
        storageKind: QueryRelationStorageKind.implicitManyToMany,
        sourceModel: 'User',
        inverseField: 'users',
      );
      final parentKeyValues = <String, Object?>{
        'id': _requireRecordValue(
          existing,
          'id',
          'nested implicit many-to-many write on User.groups',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.groups.',
        );
      }
      if (nested.set != null) {
        await tx._client
            .model('User')
            .removeImplicitManyToManyLinks(
              relation: relation,
              sourceKeyValues: parentKeyValues,
            );
        for (final selector in nested.set!) {
          final related = await tx.group._delegate.findUnique(
            FindUniqueQuery(model: 'Group', where: selector.toPredicates()),
          );
          if (related == null) {
            throw StateError(
              'No related Group record found for nested set on User.groups.',
            );
          }
          final targetKeyValues = <String, Object?>{
            'id': _requireRecordValue(
              related,
              'id',
              'nested implicit many-to-many write on User.groups',
            ),
          };
          await tx._client
              .model('User')
              .addImplicitManyToManyLink(
                relation: relation,
                sourceKeyValues: parentKeyValues,
                targetKeyValues: targetKeyValues,
              );
        }
      }
      for (final selector in nested.connect) {
        final related = await tx.group._delegate.findUnique(
          FindUniqueQuery(model: 'Group', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Group record found for nested connect on User.groups.',
          );
        }
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            related,
            'id',
            'nested implicit many-to-many write on User.groups',
          ),
        };
        await tx._client
            .model('User')
            .addImplicitManyToManyLink(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.group._delegate.findUnique(
          FindUniqueQuery(model: 'Group', where: entry.where.toPredicates()),
        );
        final relatedRecord =
            related ??
            await tx.group._delegate.create(
              CreateQuery(
                model: 'Group',
                data: entry.create.toData(),
                nestedCreates: entry.create.toNestedCreates(),
              ),
            );
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            relatedRecord,
            'id',
            'nested implicit many-to-many write on User.groups',
          ),
        };
        await tx._client
            .model('User')
            .addImplicitManyToManyLink(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
      for (final selector in nested.disconnect) {
        final related = await tx.group._delegate.findUnique(
          FindUniqueQuery(model: 'Group', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Group record found for nested disconnect on User.groups.',
          );
        }
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            related,
            'id',
            'nested implicit many-to-many write on User.groups',
          ),
        };
        await tx._client
            .model('User')
            .removeImplicitManyToManyLinks(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
    }
    if (data.memberships == null) {
      // No nested writes for memberships.
    } else {
      final nested = data.memberships!;
      final parentReferenceValues = <String, Object?>{
        'userId': _requireRecordValue(
          existing,
          'id',
          'nested direct relation write on User.memberships',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for UserUpdateInput.memberships.',
        );
      }
      final currentRelatedRecords = await tx.membership._delegate.findMany(
        FindManyQuery(
          model: 'Membership',
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
          final related = await tx.membership._delegate.findUnique(
            FindUniqueQuery(
              model: 'Membership',
              where: selector.toPredicates(),
            ),
          );
          if (related == null) {
            throw StateError(
              'No related Membership record found for nested set on User.memberships.',
            );
          }
          targetRecords.add(related);
        }
        for (final current in currentRelatedRecords) {
          final stillIncluded = targetRecords.any((target) {
            return current['tenantId'] == target['tenantId'] &&
                current['slug'] == target['slug'];
          });
          if (!stillIncluded) {
            throw StateError(
              'Nested set is not supported for required relation User.memberships when it would disconnect already attached required related records.',
            );
          }
        }
        for (final related in targetRecords) {
          await tx.membership._delegate.update(
            UpdateQuery(
              model: 'Membership',
              where: tx.membership
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
        await tx.membership._delegate.update(
          UpdateQuery(
            model: 'Membership',
            where: selector.toPredicates(),
            data: <String, Object?>{'userId': parentReferenceValues['userId']},
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.membership._delegate.findUnique(
          FindUniqueQuery(
            model: 'Membership',
            where: entry.where.toPredicates(),
          ),
        );
        if (related == null) {
          await tx.membership._delegate.create(
            CreateQuery(
              model: 'Membership',
              data: <String, Object?>{
                ...entry.create.toData(),
                'userId': parentReferenceValues['userId'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        } else {
          await tx.membership._delegate.update(
            UpdateQuery(
              model: 'Membership',
              where: entry.where.toPredicates(),
              data: <String, Object?>{
                'userId': parentReferenceValues['userId'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        final related = await tx.membership._delegate.findUnique(
          FindUniqueQuery(model: 'Membership', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related Membership record found for nested disconnect on User.memberships.',
          );
        }
        final isCurrentlyAttached = currentRelatedRecords.any((current) {
          return current['tenantId'] == related['tenantId'] &&
              current['slug'] == related['slug'];
        });
        if (isCurrentlyAttached) {
          throw StateError(
            'Nested disconnect is not supported for required relation User.memberships when it would disconnect already attached required related records.',
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
    this.email,
    this.emailFilter,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
    this.managerIdFilter,
    this.reportsSome,
    this.reportsNone,
    this.reportsEvery,
    this.postsSome,
    this.postsNone,
    this.postsEvery,
    this.groupsSome,
    this.groupsNone,
    this.groupsEvery,
    this.membershipsSome,
    this.membershipsNone,
    this.membershipsEvery,
    this.managerIs,
    this.managerIsNot,
    this.profileIs,
    this.profileIsNot,
  });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? email;
  final StringFilter? emailFilter;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole? role;
  final int? managerId;
  final IntFilter? managerIdFilter;
  final UserWhereInput? reportsSome;
  final UserWhereInput? reportsNone;
  final UserWhereInput? reportsEvery;
  final PostWhereInput? postsSome;
  final PostWhereInput? postsNone;
  final PostWhereInput? postsEvery;
  final GroupWhereInput? groupsSome;
  final GroupWhereInput? groupsNone;
  final GroupWhereInput? groupsEvery;
  final MembershipWhereInput? membershipsSome;
  final MembershipWhereInput? membershipsNone;
  final MembershipWhereInput? membershipsEvery;
  final UserWhereInput? managerIs;
  final UserWhereInput? managerIsNot;
  final ProfileWhereInput? profileIs;
  final ProfileWhereInput? profileIsNot;

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
    if (createdAt != null) {
      predicates.add(
        QueryPredicate(
          field: 'createdAt',
          operator: 'equals',
          value: createdAt,
        ),
      );
    }
    if (updatedAt != null) {
      predicates.add(
        QueryPredicate(
          field: 'updatedAt',
          operator: 'equals',
          value: updatedAt,
        ),
      );
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
    if (managerId != null) {
      predicates.add(
        QueryPredicate(
          field: 'managerId',
          operator: 'equals',
          value: managerId,
        ),
      );
    }
    if (managerIdFilter != null) {
      predicates.addAll(managerIdFilter!.toPredicates('managerId'));
    }
    if (reportsSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'reports',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'reports',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'managerId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['managerId'],
            ),
            predicates: reportsSome!.toPredicates(),
          ),
        ),
      );
    }
    if (reportsNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'reports',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'reports',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'managerId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['managerId'],
            ),
            predicates: reportsNone!.toPredicates(),
          ),
        ),
      );
    }
    if (reportsEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'reports',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'reports',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'managerId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['managerId'],
            ),
            predicates: reportsEvery!.toPredicates(),
          ),
        ),
      );
    }
    if (postsSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'posts',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'posts',
              targetModel: 'Post',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'authorId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['authorId'],
            ),
            predicates: postsSome!.toPredicates(),
          ),
        ),
      );
    }
    if (postsNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'posts',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'posts',
              targetModel: 'Post',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'authorId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['authorId'],
            ),
            predicates: postsNone!.toPredicates(),
          ),
        ),
      );
    }
    if (postsEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'posts',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'posts',
              targetModel: 'Post',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'authorId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['authorId'],
            ),
            predicates: postsEvery!.toPredicates(),
          ),
        ),
      );
    }
    if (groupsSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'groups',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'groups',
              targetModel: 'Group',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'User',
              inverseField: 'users',
            ),
            predicates: groupsSome!.toPredicates(),
          ),
        ),
      );
    }
    if (groupsNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'groups',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'groups',
              targetModel: 'Group',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'User',
              inverseField: 'users',
            ),
            predicates: groupsNone!.toPredicates(),
          ),
        ),
      );
    }
    if (groupsEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'groups',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'groups',
              targetModel: 'Group',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'User',
              inverseField: 'users',
            ),
            predicates: groupsEvery!.toPredicates(),
          ),
        ),
      );
    }
    if (membershipsSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'memberships',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'memberships',
              targetModel: 'Membership',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: membershipsSome!.toPredicates(),
          ),
        ),
      );
    }
    if (membershipsNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'memberships',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'memberships',
              targetModel: 'Membership',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: membershipsNone!.toPredicates(),
          ),
        ),
      );
    }
    if (membershipsEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'memberships',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'memberships',
              targetModel: 'Membership',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: membershipsEvery!.toPredicates(),
          ),
        ),
      );
    }
    if (managerIs != null) {
      predicates.add(
        QueryPredicate(
          field: 'manager',
          operator: 'relationIs',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'manager',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'managerId',
              targetKeyField: 'id',
              localKeyFields: const <String>['managerId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: managerIs!.toPredicates(),
          ),
        ),
      );
    }
    if (managerIsNot != null) {
      predicates.add(
        QueryPredicate(
          field: 'manager',
          operator: 'relationIsNot',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'manager',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'managerId',
              targetKeyField: 'id',
              localKeyFields: const <String>['managerId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: managerIsNot!.toPredicates(),
          ),
        ),
      );
    }
    if (profileIs != null) {
      predicates.add(
        QueryPredicate(
          field: 'profile',
          operator: 'relationIs',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'profile',
              targetModel: 'Profile',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: profileIs!.toPredicates(),
          ),
        ),
      );
    }
    if (profileIsNot != null) {
      predicates.add(
        QueryPredicate(
          field: 'profile',
          operator: 'relationIsNot',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'profile',
              targetModel: 'Profile',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'id',
              targetKeyField: 'userId',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['userId'],
            ),
            predicates: profileIsNot!.toPredicates(),
          ),
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class UserEmailRoleCompoundUniqueInput {
  const UserEmailRoleCompoundUniqueInput({
    required this.email,
    required this.role,
  });

  final String email;
  final UserRole role;

  List<QueryPredicate> toPredicates() {
    return List<QueryPredicate>.unmodifiable(<QueryPredicate>[
      QueryPredicate(field: 'email', operator: 'equals', value: email),
      QueryPredicate(field: 'role', operator: 'equals', value: _enumName(role)),
    ]);
  }

  bool matchesRecord(Map<String, Object?> record) {
    return record['email'] == email && record['role'] == _enumName(role);
  }
}

class UserWhereUniqueInput {
  const UserWhereUniqueInput({this.id, this.email, this.email_role});

  final int? id;
  final String? email;
  final UserEmailRoleCompoundUniqueInput? email_role;

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
    if (email_role != null) {
      selectors.add(email_role!.toPredicates());
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
    if (email_role != null) {
      selectorCount++;
      matches = email_role!.matchesRecord(record);
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
  const UserOrderByInput({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? createdAt;
  final SortOrder? updatedAt;
  final SortOrder? role;
  final SortOrder? managerId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (email != null) {
      orderings.add(QueryOrderBy(field: 'email', direction: email!));
    }
    if (createdAt != null) {
      orderings.add(QueryOrderBy(field: 'createdAt', direction: createdAt!));
    }
    if (updatedAt != null) {
      orderings.add(QueryOrderBy(field: 'updatedAt', direction: updatedAt!));
    }
    if (role != null) {
      orderings.add(QueryOrderBy(field: 'role', direction: role!));
    }
    if (managerId != null) {
      orderings.add(QueryOrderBy(field: 'managerId', direction: managerId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField { id, email, createdAt, updatedAt, role, managerId }

class UserCountAggregateInput {
  const UserCountAggregateInput({
    this.all = false,
    this.id = false,
    this.email = false,
    this.createdAt = false,
    this.updatedAt = false,
    this.role = false,
    this.managerId = false,
  });

  final bool all;
  final bool id;
  final bool email;
  final bool createdAt;
  final bool updatedAt;
  final bool role;
  final bool managerId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (updatedAt) {
      fields.add('updatedAt');
    }
    if (role) {
      fields.add('role');
    }
    if (managerId) {
      fields.add('managerId');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class UserAvgAggregateInput {
  const UserAvgAggregateInput({this.id = false, this.managerId = false});

  final bool id;
  final bool managerId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (managerId) {
      fields.add('managerId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserSumAggregateInput {
  const UserSumAggregateInput({this.id = false, this.managerId = false});

  final bool id;
  final bool managerId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (managerId) {
      fields.add('managerId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMinAggregateInput {
  const UserMinAggregateInput({
    this.id = false,
    this.email = false,
    this.createdAt = false,
    this.updatedAt = false,
    this.role = false,
    this.managerId = false,
  });

  final bool id;
  final bool email;
  final bool createdAt;
  final bool updatedAt;
  final bool role;
  final bool managerId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (updatedAt) {
      fields.add('updatedAt');
    }
    if (role) {
      fields.add('role');
    }
    if (managerId) {
      fields.add('managerId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({
    this.id = false,
    this.email = false,
    this.createdAt = false,
    this.updatedAt = false,
    this.role = false,
    this.managerId = false,
  });

  final bool id;
  final bool email;
  final bool createdAt;
  final bool updatedAt;
  final bool role;
  final bool managerId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (updatedAt) {
      fields.add('updatedAt');
    }
    if (role) {
      fields.add('role');
    }
    if (managerId) {
      fields.add('managerId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({
    this.all,
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final int? all;
  final int? id;
  final int? email;
  final int? createdAt;
  final int? updatedAt;
  final int? role;
  final int? managerId;

  factory UserCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      email: result.fields['email'],
      createdAt: result.fields['createdAt'],
      updatedAt: result.fields['updatedAt'],
      role: result.fields['role'],
      managerId: result.fields['managerId'],
    );
  }
}

class UserAvgAggregateResult {
  const UserAvgAggregateResult({this.id, this.managerId});

  final double? id;
  final double? managerId;

  factory UserAvgAggregateResult.fromMap(Map<String, double?> values) {
    return UserAvgAggregateResult(
      id: _asDouble(values['id']),
      managerId: _asDouble(values['managerId']),
    );
  }
}

class UserSumAggregateResult {
  const UserSumAggregateResult({this.id, this.managerId});

  final int? id;
  final int? managerId;

  factory UserSumAggregateResult.fromMap(Map<String, num?> values) {
    return UserSumAggregateResult(
      id: values['id']?.toInt(),
      managerId: values['managerId']?.toInt(),
    );
  }
}

class UserMinAggregateResult {
  const UserMinAggregateResult({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final int? id;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole? role;
  final int? managerId;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      email: values['email'] as String?,
      createdAt: _asDateTime(values['createdAt']),
      updatedAt: _asDateTime(values['updatedAt']),
      role: values['role'] == null
          ? null
          : UserRole.values.byName(values['role'] as String),
      managerId: values['managerId'] as int?,
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final int? id;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole? role;
  final int? managerId;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      email: values['email'] as String?,
      createdAt: _asDateTime(values['createdAt']),
      updatedAt: _asDateTime(values['updatedAt']),
      role: values['role'] == null
          ? null
          : UserRole.values.byName(values['role'] as String),
      managerId: values['managerId'] as int?,
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
  const UserGroupByHavingInput({this.id, this.managerId});

  final NumericAggregatesFilter? id;
  final NumericAggregatesFilter? managerId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    if (managerId != null) {
      predicates.addAll(managerId!.toPredicates('managerId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class UserCountAggregateOrderByInput {
  const UserCountAggregateOrderByInput({
    this.all,
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? createdAt;
  final SortOrder? updatedAt;
  final SortOrder? role;
  final SortOrder? managerId;

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
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    if (updatedAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'updatedAt',
          direction: updatedAt!,
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
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'managerId',
          direction: managerId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserAvgAggregateOrderByInput {
  const UserAvgAggregateOrderByInput({this.id, this.managerId});

  final SortOrder? id;
  final SortOrder? managerId;

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
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'managerId',
          direction: managerId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserSumAggregateOrderByInput {
  const UserSumAggregateOrderByInput({this.id, this.managerId});

  final SortOrder? id;
  final SortOrder? managerId;

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
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'managerId',
          direction: managerId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMinAggregateOrderByInput {
  const UserMinAggregateOrderByInput({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? createdAt;
  final SortOrder? updatedAt;
  final SortOrder? role;
  final SortOrder? managerId;

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
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    if (updatedAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'updatedAt',
          direction: updatedAt!,
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
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'managerId',
          direction: managerId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
  });

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? createdAt;
  final SortOrder? updatedAt;
  final SortOrder? role;
  final SortOrder? managerId;

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
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'createdAt',
          direction: createdAt!,
        ),
      );
    }
    if (updatedAt != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'updatedAt',
          direction: updatedAt!,
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
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'managerId',
          direction: managerId!,
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
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? email;
  final SortOrder? createdAt;
  final SortOrder? updatedAt;
  final SortOrder? role;
  final SortOrder? managerId;
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
    if (createdAt != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'createdAt', direction: createdAt!),
      );
    }
    if (updatedAt != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'updatedAt', direction: updatedAt!),
      );
    }
    if (role != null) {
      orderings.add(GroupByOrderBy.field(field: 'role', direction: role!));
    }
    if (managerId != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'managerId', direction: managerId!),
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

class UserGroupByRow {
  const UserGroupByRow({
    this.id,
    this.email,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.managerId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole? role;
  final int? managerId;
  final UserCountAggregateResult? count;
  final UserAvgAggregateResult? avg;
  final UserSumAggregateResult? sum;
  final UserMinAggregateResult? min;
  final UserMaxAggregateResult? max;

  factory UserGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return UserGroupByRow(
      id: row.group['id'] as int?,
      email: row.group['email'] as String?,
      createdAt: _asDateTime(row.group['createdAt']),
      updatedAt: _asDateTime(row.group['updatedAt']),
      role: row.group['role'] == null
          ? null
          : UserRole.values.byName(row.group['role'] as String),
      managerId: row.group['managerId'] as int?,
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
  const UserInclude({
    this.manager = false,
    this.reports = false,
    this.profile = false,
    this.posts = false,
    this.groups = false,
    this.memberships = false,
  });

  final bool manager;
  final bool reports;
  final bool profile;
  final bool posts;
  final bool groups;
  final bool memberships;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (manager) {
      relations['manager'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'manager',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.one,
          localKeyField: 'managerId',
          targetKeyField: 'id',
          localKeyFields: const <String>['managerId'],
          targetKeyFields: const <String>['id'],
        ),
      );
    }
    if (reports) {
      relations['reports'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'reports',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'managerId',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['managerId'],
        ),
      );
    }
    if (profile) {
      relations['profile'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'profile',
          targetModel: 'Profile',
          cardinality: QueryRelationCardinality.one,
          localKeyField: 'id',
          targetKeyField: 'userId',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['userId'],
        ),
      );
    }
    if (posts) {
      relations['posts'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'posts',
          targetModel: 'Post',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'authorId',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['authorId'],
        ),
      );
    }
    if (groups) {
      relations['groups'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'groups',
          targetModel: 'Group',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'id',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['id'],
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'User',
          inverseField: 'users',
        ),
      );
    }
    if (memberships) {
      relations['memberships'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'memberships',
          targetModel: 'Membership',
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
  const UserSelect({
    this.id = false,
    this.email = false,
    this.createdAt = false,
    this.updatedAt = false,
    this.role = false,
    this.managerId = false,
  });

  final bool id;
  final bool email;
  final bool createdAt;
  final bool updatedAt;
  final bool role;
  final bool managerId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (email) {
      fields.add('email');
    }
    if (createdAt) {
      fields.add('createdAt');
    }
    if (updatedAt) {
      fields.add('updatedAt');
    }
    if (role) {
      fields.add('role');
    }
    if (managerId) {
      fields.add('managerId');
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
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
    this.manager,
    this.reports,
    this.profile,
    this.posts,
    this.groups,
    this.memberships,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;
  final UserCreateNestedOneWithoutReportsInput? manager;
  final UserCreateNestedManyWithoutManagerInput? reports;
  final ProfileCreateNestedOneWithoutUserInput? profile;
  final PostCreateNestedManyWithoutAuthorInput? posts;
  final GroupCreateNestedManyWithoutUsersInput? groups;
  final MembershipCreateNestedManyWithoutUserInput? memberships;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
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
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'email', operator: 'equals', value: email),
      QueryPredicate(field: 'role', operator: 'equals', value: _enumName(role)),
    ]);
    return List<List<QueryPredicate>>.unmodifiable(
      selectors.map(List<QueryPredicate>.unmodifiable),
    );
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (manager != null) {
      writes.addAll(
        manager!.toRelationWrites(
          QueryRelation(
            field: 'manager',
            targetModel: 'User',
            cardinality: QueryRelationCardinality.one,
            localKeyField: 'managerId',
            targetKeyField: 'id',
            localKeyFields: const <String>['managerId'],
            targetKeyFields: const <String>['id'],
          ),
        ),
      );
    }
    if (reports != null) {
      writes.addAll(
        reports!.toRelationWrites(
          QueryRelation(
            field: 'reports',
            targetModel: 'User',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'managerId',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['managerId'],
          ),
        ),
      );
    }
    if (profile != null) {
      writes.addAll(
        profile!.toRelationWrites(
          QueryRelation(
            field: 'profile',
            targetModel: 'Profile',
            cardinality: QueryRelationCardinality.one,
            localKeyField: 'id',
            targetKeyField: 'userId',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['userId'],
          ),
        ),
      );
    }
    if (posts != null) {
      writes.addAll(
        posts!.toRelationWrites(
          QueryRelation(
            field: 'posts',
            targetModel: 'Post',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'authorId',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['authorId'],
          ),
        ),
      );
    }
    if (groups != null) {
      writes.addAll(
        groups!.toRelationWrites(
          QueryRelation(
            field: 'groups',
            targetModel: 'Group',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'id',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['id'],
            storageKind: QueryRelationStorageKind.implicitManyToMany,
            sourceModel: 'User',
            inverseField: 'users',
          ),
        ),
      );
    }
    if (memberships != null) {
      writes.addAll(
        memberships!.toRelationWrites(
          QueryRelation(
            field: 'memberships',
            targetModel: 'Membership',
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
    return (manager?.hasDeferredWrites ?? false) ||
        (reports?.hasDeferredWrites ?? false) ||
        (profile?.hasDeferredWrites ?? false) ||
        (posts?.hasDeferredWrites ?? false) ||
        (groups?.hasDeferredWrites ?? false) ||
        (memberships?.hasDeferredWrites ?? false);
  }

  UserUpdateInput toDeferredRelationUpdateInput() {
    return UserUpdateInput(
      manager: manager?.toDeferredUpdateWrite(),
      reports: reports?.toDeferredUpdateWrite(),
      profile: profile?.toDeferredUpdateWrite(),
      posts: posts?.toDeferredUpdateWrite(),
      groups: groups?.toDeferredUpdateWrite(),
      memberships: memberships?.toDeferredUpdateWrite(),
    );
  }
}

class UserUpdateInput {
  const UserUpdateInput({
    this.email,
    this.emailOps,
    this.createdAt,
    this.createdAtOps,
    this.updatedAt,
    this.updatedAtOps,
    this.role,
    this.roleOps,
    this.managerId,
    this.managerIdOps,
    this.manager,
    this.reports,
    this.profile,
    this.posts,
    this.groups,
    this.memberships,
  });

  final String? email;
  final StringFieldUpdateOperationsInput? emailOps;
  final DateTime? createdAt;
  final DateTimeFieldUpdateOperationsInput? createdAtOps;
  final DateTime? updatedAt;
  final DateTimeFieldUpdateOperationsInput? updatedAtOps;
  final UserRole? role;
  final EnumFieldUpdateOperationsInput<UserRole>? roleOps;
  final int? managerId;
  final IntFieldUpdateOperationsInput? managerIdOps;
  final UserUpdateNestedOneWithoutReportsInput? manager;
  final UserUpdateNestedManyWithoutManagerInput? reports;
  final ProfileUpdateNestedOneWithoutUserInput? profile;
  final PostUpdateNestedManyWithoutAuthorInput? posts;
  final GroupUpdateNestedManyWithoutUsersInput? groups;
  final MembershipUpdateNestedManyWithoutUserInput? memberships;

  bool get hasComputedOperators {
    return managerIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return manager?.hasWrites == true ||
        reports?.hasWrites == true ||
        profile?.hasWrites == true ||
        posts?.hasWrites == true ||
        groups?.hasWrites == true ||
        memberships?.hasWrites == true;
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
    if (createdAt != null && createdAtOps != null) {
      throw StateError(
        'Only one of createdAt or createdAtOps may be provided for UserUpdateInput.createdAt.',
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
    if (updatedAt != null && updatedAtOps != null) {
      throw StateError(
        'Only one of updatedAt or updatedAtOps may be provided for UserUpdateInput.updatedAt.',
      );
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    if (updatedAtOps != null) {
      final ops = updatedAtOps!;
      if (ops.hasSet) {
        data['updatedAt'] = ops.set as DateTime?;
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
    if (managerId != null && managerIdOps != null) {
      throw StateError(
        'Only one of managerId or managerIdOps may be provided for UserUpdateInput.managerId.',
      );
    }
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    if (managerIdOps != null) {
      final ops = managerIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for UserUpdateInput.managerId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for UserUpdateInput.managerId require the current record value before they can be converted to raw update data.',
        );
      }
      if (ops.hasSet) {
        data['managerId'] = ops.set as int?;
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
    if (createdAt != null && createdAtOps != null) {
      throw StateError(
        'Only one of createdAt or createdAtOps may be provided for UserUpdateInput.createdAt.',
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
    if (updatedAt != null && updatedAtOps != null) {
      throw StateError(
        'Only one of updatedAt or updatedAtOps may be provided for UserUpdateInput.updatedAt.',
      );
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    if (updatedAtOps != null) {
      final ops = updatedAtOps!;
      if (ops.hasSet) {
        data['updatedAt'] = ops.set as DateTime?;
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
    if (managerId != null && managerIdOps != null) {
      throw StateError(
        'Only one of managerId or managerIdOps may be provided for UserUpdateInput.managerId.',
      );
    }
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    if (managerIdOps != null) {
      final ops = managerIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for UserUpdateInput.managerId.',
        );
      }
      if (ops.hasSet) {
        data['managerId'] = ops.set as int?;
      } else {
        final currentValue = record['managerId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment UserUpdateInput.managerId because the current value is null.',
            );
          }
          data['managerId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement UserUpdateInput.managerId because the current value is null.',
            );
          }
          data['managerId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class UserCreateWithoutManagerInput {
  const UserCreateWithoutManagerInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateWithoutReportsInput {
  const UserCreateWithoutReportsInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateWithoutProfileInput {
  const UserCreateWithoutProfileInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateWithoutPostsInput {
  const UserCreateWithoutPostsInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateWithoutGroupsInput {
  const UserCreateWithoutGroupsInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateWithoutMembershipsInput {
  const UserCreateWithoutMembershipsInput({
    this.id,
    required this.email,
    this.createdAt,
    this.updatedAt,
    required this.role,
    this.managerId,
  });

  final int? id;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final UserRole role;
  final int? managerId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['email'] = email;
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (updatedAt != null) {
      data['updatedAt'] = updatedAt;
    }
    data['role'] = _enumName(role);
    if (managerId != null) {
      data['managerId'] = managerId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutReportsInput {
  const UserConnectOrCreateWithoutReportsInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutReportsInput create;
}

class UserConnectOrCreateWithoutManagerInput {
  const UserConnectOrCreateWithoutManagerInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutManagerInput create;
}

class ProfileConnectOrCreateWithoutUserInput {
  const ProfileConnectOrCreateWithoutUserInput({
    required this.where,
    required this.create,
  });

  final ProfileWhereUniqueInput where;
  final ProfileCreateWithoutUserInput create;
}

class PostConnectOrCreateWithoutAuthorInput {
  const PostConnectOrCreateWithoutAuthorInput({
    required this.where,
    required this.create,
  });

  final PostWhereUniqueInput where;
  final PostCreateWithoutAuthorInput create;
}

class GroupConnectOrCreateWithoutUsersInput {
  const GroupConnectOrCreateWithoutUsersInput({
    required this.where,
    required this.create,
  });

  final GroupWhereUniqueInput where;
  final GroupCreateWithoutUsersInput create;
}

class MembershipConnectOrCreateWithoutUserInput {
  const MembershipConnectOrCreateWithoutUserInput({
    required this.where,
    required this.create,
  });

  final MembershipWhereUniqueInput where;
  final MembershipCreateWithoutUserInput create;
}

class UserCreateNestedOneWithoutReportsInput {
  const UserCreateNestedOneWithoutReportsInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserCreateWithoutReportsInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutReportsInput? connectOrCreate;
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
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutReportsInput.',
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

  UserUpdateNestedOneWithoutReportsInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutReportsInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutReportsInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class UserCreateNestedManyWithoutManagerInput {
  const UserCreateNestedManyWithoutManagerInput({
    this.create = const <UserCreateWithoutManagerInput>[],
    this.connect = const <UserWhereUniqueInput>[],
    this.disconnect = const <UserWhereUniqueInput>[],
    this.connectOrCreate = const <UserConnectOrCreateWithoutManagerInput>[],
    this.set,
  });

  final List<UserCreateWithoutManagerInput> create;
  final List<UserWhereUniqueInput> connect;
  final List<UserWhereUniqueInput> disconnect;
  final List<UserConnectOrCreateWithoutManagerInput> connectOrCreate;
  final List<UserWhereUniqueInput>? set;

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

  UserUpdateNestedManyWithoutManagerInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedManyWithoutManagerInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class ProfileCreateNestedOneWithoutUserInput {
  const ProfileCreateNestedOneWithoutUserInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final ProfileCreateWithoutUserInput? create;
  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutUserInput? connectOrCreate;
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
        'Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutUserInput.',
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

  ProfileUpdateNestedOneWithoutUserInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutUserInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return ProfileUpdateNestedOneWithoutUserInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class PostCreateNestedManyWithoutAuthorInput {
  const PostCreateNestedManyWithoutAuthorInput({
    this.create = const <PostCreateWithoutAuthorInput>[],
    this.connect = const <PostWhereUniqueInput>[],
    this.disconnect = const <PostWhereUniqueInput>[],
    this.connectOrCreate = const <PostConnectOrCreateWithoutAuthorInput>[],
    this.set,
  });

  final List<PostCreateWithoutAuthorInput> create;
  final List<PostWhereUniqueInput> connect;
  final List<PostWhereUniqueInput> disconnect;
  final List<PostConnectOrCreateWithoutAuthorInput> connectOrCreate;
  final List<PostWhereUniqueInput>? set;

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

  PostUpdateNestedManyWithoutAuthorInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return PostUpdateNestedManyWithoutAuthorInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class GroupCreateNestedManyWithoutUsersInput {
  const GroupCreateNestedManyWithoutUsersInput({
    this.create = const <GroupCreateWithoutUsersInput>[],
    this.connect = const <GroupWhereUniqueInput>[],
    this.disconnect = const <GroupWhereUniqueInput>[],
    this.connectOrCreate = const <GroupConnectOrCreateWithoutUsersInput>[],
    this.set,
  });

  final List<GroupCreateWithoutUsersInput> create;
  final List<GroupWhereUniqueInput> connect;
  final List<GroupWhereUniqueInput> disconnect;
  final List<GroupConnectOrCreateWithoutUsersInput> connectOrCreate;
  final List<GroupWhereUniqueInput>? set;

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

  GroupUpdateNestedManyWithoutUsersInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return GroupUpdateNestedManyWithoutUsersInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class MembershipCreateNestedManyWithoutUserInput {
  const MembershipCreateNestedManyWithoutUserInput({
    this.create = const <MembershipCreateWithoutUserInput>[],
    this.connect = const <MembershipWhereUniqueInput>[],
    this.disconnect = const <MembershipWhereUniqueInput>[],
    this.connectOrCreate = const <MembershipConnectOrCreateWithoutUserInput>[],
    this.set,
  });

  final List<MembershipCreateWithoutUserInput> create;
  final List<MembershipWhereUniqueInput> connect;
  final List<MembershipWhereUniqueInput> disconnect;
  final List<MembershipConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<MembershipWhereUniqueInput>? set;

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

  MembershipUpdateNestedManyWithoutUserInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return MembershipUpdateNestedManyWithoutUserInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class UserUpdateNestedOneWithoutReportsInput {
  const UserUpdateNestedOneWithoutReportsInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutReportsInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites =>
      connect != null || connectOrCreate != null || disconnect;
}

class UserUpdateNestedManyWithoutManagerInput {
  const UserUpdateNestedManyWithoutManagerInput({
    this.connect = const <UserWhereUniqueInput>[],
    this.disconnect = const <UserWhereUniqueInput>[],
    this.connectOrCreate = const <UserConnectOrCreateWithoutManagerInput>[],
    this.set,
  });

  final List<UserWhereUniqueInput> connect;
  final List<UserWhereUniqueInput> disconnect;
  final List<UserConnectOrCreateWithoutManagerInput> connectOrCreate;
  final List<UserWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
}

class ProfileUpdateNestedOneWithoutUserInput {
  const ProfileUpdateNestedOneWithoutUserInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutUserInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites =>
      connect != null || connectOrCreate != null || disconnect;
}

class PostUpdateNestedManyWithoutAuthorInput {
  const PostUpdateNestedManyWithoutAuthorInput({
    this.connect = const <PostWhereUniqueInput>[],
    this.disconnect = const <PostWhereUniqueInput>[],
    this.connectOrCreate = const <PostConnectOrCreateWithoutAuthorInput>[],
    this.set,
  });

  final List<PostWhereUniqueInput> connect;
  final List<PostWhereUniqueInput> disconnect;
  final List<PostConnectOrCreateWithoutAuthorInput> connectOrCreate;
  final List<PostWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
}

class GroupUpdateNestedManyWithoutUsersInput {
  const GroupUpdateNestedManyWithoutUsersInput({
    this.connect = const <GroupWhereUniqueInput>[],
    this.disconnect = const <GroupWhereUniqueInput>[],
    this.connectOrCreate = const <GroupConnectOrCreateWithoutUsersInput>[],
    this.set,
  });

  final List<GroupWhereUniqueInput> connect;
  final List<GroupWhereUniqueInput> disconnect;
  final List<GroupConnectOrCreateWithoutUsersInput> connectOrCreate;
  final List<GroupWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
}

class MembershipUpdateNestedManyWithoutUserInput {
  const MembershipUpdateNestedManyWithoutUserInput({
    this.connect = const <MembershipWhereUniqueInput>[],
    this.disconnect = const <MembershipWhereUniqueInput>[],
    this.connectOrCreate = const <MembershipConnectOrCreateWithoutUserInput>[],
    this.set,
  });

  final List<MembershipWhereUniqueInput> connect;
  final List<MembershipWhereUniqueInput> disconnect;
  final List<MembershipConnectOrCreateWithoutUserInput> connectOrCreate;
  final List<MembershipWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
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
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'Post',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then((record) => record == null ? null : Post.fromRecord(record));
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
            model: 'Post',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : Post.fromRecord(record));
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
            model: 'Post',
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
          (records) => records.map(Post.fromRecord).toList(growable: false),
        );
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
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'Post',
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
        .then(PostAggregateResult.fromQueryResult);
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
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'Post',
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
              .map(PostGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
  }

  Future<Post> create({required PostCreateInput data, PostInclude? include}) {
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
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(model: 'Post', where: selector),
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
        FindUniqueQuery(model: 'Post', where: predicates),
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
        FindUniqueQuery(model: 'Post', where: predicates),
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
          FindManyQuery(model: 'Post', where: predicates),
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
      UpdateManyQuery(model: 'Post', where: predicates, data: data.toData()),
    );
  }

  Future<List<Post>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required PostWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'Post',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <Post>[];
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
      return pagedRecords.map(Post.fromRecord).toList(growable: false);
    }
    final projectedRecords = <Post>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'Post',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'Post.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(Post.fromRecord(projected));
    }
    return List<Post>.unmodifiable(projectedRecords);
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
      throw StateError(
        'Post create branch could not reload the created record by primary key.',
      );
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
      throw StateError(
        'Post update branch could not reload the updated record for the provided unique selector.',
      );
    }
    return Post.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required PostUpdateInput data,
  }) async {
    if (data.author == null) {
      // No nested writes for author.
    } else {
      final nested = data.author!;
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError(
          'Only one of connect, connectOrCreate or disconnect may be provided for PostUpdateInput.author.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on Post.author.',
          );
        }
        await tx._client
            .model('Post')
            .update(
              UpdateQuery(
                model: 'Post',
                where: predicates,
                data: <String, Object?>{
                  'authorId': _requireRecordValue(
                    related,
                    'id',
                    'nested direct relation write on Post.author',
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
            .model('Post')
            .update(
              UpdateQuery(
                model: 'Post',
                where: predicates,
                data: <String, Object?>{
                  'authorId': _requireRecordValue(
                    relatedRecord,
                    'id',
                    'nested direct relation write on Post.author',
                  ),
                },
              ),
            );
      }
      if (nested.disconnect) {
        throw StateError(
          'Nested disconnect is not supported for required relation Post.author.',
        );
      }
    }
  }

  Future<Post> delete({
    required PostWhereUniqueInput where,
    PostInclude? include,
    PostSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'Post',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Post.fromRecord);
  }

  Future<int> deleteMany({required PostWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'Post', where: where.toPredicates()),
    );
  }
}

class PostWhereInput {
  const PostWhereInput({
    this.AND = const <PostWhereInput>[],
    this.OR = const <PostWhereInput>[],
    this.NOT = const <PostWhereInput>[],
    this.id,
    this.idFilter,
    this.authorId,
    this.authorIdFilter,
    this.authorIs,
    this.authorIsNot,
  });

  final List<PostWhereInput> AND;
  final List<PostWhereInput> OR;
  final List<PostWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final int? authorId;
  final IntFilter? authorIdFilter;
  final UserWhereInput? authorIs;
  final UserWhereInput? authorIsNot;

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
    if (authorId != null) {
      predicates.add(
        QueryPredicate(field: 'authorId', operator: 'equals', value: authorId),
      );
    }
    if (authorIdFilter != null) {
      predicates.addAll(authorIdFilter!.toPredicates('authorId'));
    }
    if (authorIs != null) {
      predicates.add(
        QueryPredicate(
          field: 'author',
          operator: 'relationIs',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'author',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'authorId',
              targetKeyField: 'id',
              localKeyFields: const <String>['authorId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: authorIs!.toPredicates(),
          ),
        ),
      );
    }
    if (authorIsNot != null) {
      predicates.add(
        QueryPredicate(
          field: 'author',
          operator: 'relationIsNot',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'author',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.one,
              localKeyField: 'authorId',
              targetKeyField: 'id',
              localKeyFields: const <String>['authorId'],
              targetKeyFields: const <String>['id'],
            ),
            predicates: authorIsNot!.toPredicates(),
          ),
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class PostWhereUniqueInput {
  const PostWhereUniqueInput({this.id});

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
        'Exactly one unique selector must be provided for PostWhereUniqueInput.',
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
        'Exactly one unique selector must be provided for PostWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class PostOrderByInput {
  const PostOrderByInput({this.id, this.authorId});

  final SortOrder? id;
  final SortOrder? authorId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (authorId != null) {
      orderings.add(QueryOrderBy(field: 'authorId', direction: authorId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum PostScalarField { id, authorId }

class PostCountAggregateInput {
  const PostCountAggregateInput({
    this.all = false,
    this.id = false,
    this.authorId = false,
  });

  final bool all;
  final bool id;
  final bool authorId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class PostAvgAggregateInput {
  const PostAvgAggregateInput({this.id = false, this.authorId = false});

  final bool id;
  final bool authorId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostSumAggregateInput {
  const PostSumAggregateInput({this.id = false, this.authorId = false});

  final bool id;
  final bool authorId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostMinAggregateInput {
  const PostMinAggregateInput({this.id = false, this.authorId = false});

  final bool id;
  final bool authorId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostMaxAggregateInput {
  const PostMaxAggregateInput({this.id = false, this.authorId = false});

  final bool id;
  final bool authorId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostCountAggregateResult {
  const PostCountAggregateResult({this.all, this.id, this.authorId});

  final int? all;
  final int? id;
  final int? authorId;

  factory PostCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return PostCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      authorId: result.fields['authorId'],
    );
  }
}

class PostAvgAggregateResult {
  const PostAvgAggregateResult({this.id, this.authorId});

  final double? id;
  final double? authorId;

  factory PostAvgAggregateResult.fromMap(Map<String, double?> values) {
    return PostAvgAggregateResult(
      id: _asDouble(values['id']),
      authorId: _asDouble(values['authorId']),
    );
  }
}

class PostSumAggregateResult {
  const PostSumAggregateResult({this.id, this.authorId});

  final int? id;
  final int? authorId;

  factory PostSumAggregateResult.fromMap(Map<String, num?> values) {
    return PostSumAggregateResult(
      id: values['id']?.toInt(),
      authorId: values['authorId']?.toInt(),
    );
  }
}

class PostMinAggregateResult {
  const PostMinAggregateResult({this.id, this.authorId});

  final int? id;
  final int? authorId;

  factory PostMinAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMinAggregateResult(
      id: values['id'] as int?,
      authorId: values['authorId'] as int?,
    );
  }
}

class PostMaxAggregateResult {
  const PostMaxAggregateResult({this.id, this.authorId});

  final int? id;
  final int? authorId;

  factory PostMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMaxAggregateResult(
      id: values['id'] as int?,
      authorId: values['authorId'] as int?,
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
      count: result.count == null
          ? null
          : PostCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : PostAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : PostSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : PostMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : PostMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class PostGroupByHavingInput {
  const PostGroupByHavingInput({this.id, this.authorId});

  final NumericAggregatesFilter? id;
  final NumericAggregatesFilter? authorId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    if (authorId != null) {
      predicates.addAll(authorId!.toPredicates('authorId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class PostCountAggregateOrderByInput {
  const PostCountAggregateOrderByInput({this.all, this.id, this.authorId});

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? authorId;

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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'authorId',
          direction: authorId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostAvgAggregateOrderByInput {
  const PostAvgAggregateOrderByInput({this.id, this.authorId});

  final SortOrder? id;
  final SortOrder? authorId;

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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'authorId',
          direction: authorId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostSumAggregateOrderByInput {
  const PostSumAggregateOrderByInput({this.id, this.authorId});

  final SortOrder? id;
  final SortOrder? authorId;

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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'authorId',
          direction: authorId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostMinAggregateOrderByInput {
  const PostMinAggregateOrderByInput({this.id, this.authorId});

  final SortOrder? id;
  final SortOrder? authorId;

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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'authorId',
          direction: authorId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostMaxAggregateOrderByInput {
  const PostMaxAggregateOrderByInput({this.id, this.authorId});

  final SortOrder? id;
  final SortOrder? authorId;

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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'authorId',
          direction: authorId!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class PostGroupByOrderByInput {
  const PostGroupByOrderByInput({
    this.id,
    this.authorId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? authorId;
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
    if (authorId != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'authorId', direction: authorId!),
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

class PostGroupByRow {
  const PostGroupByRow({
    this.id,
    this.authorId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final int? authorId;
  final PostCountAggregateResult? count;
  final PostAvgAggregateResult? avg;
  final PostSumAggregateResult? sum;
  final PostMinAggregateResult? min;
  final PostMaxAggregateResult? max;

  factory PostGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return PostGroupByRow(
      id: row.group['id'] as int?,
      authorId: row.group['authorId'] as int?,
      count: row.aggregates.count == null
          ? null
          : PostCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : PostAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : PostSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : PostMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : PostMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class PostInclude {
  const PostInclude({this.author = false});

  final bool author;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (author) {
      relations['author'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'author',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.one,
          localKeyField: 'authorId',
          targetKeyField: 'id',
          localKeyFields: const <String>['authorId'],
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

class PostSelect {
  const PostSelect({this.id = false, this.authorId = false});

  final bool id;
  final bool authorId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (authorId) {
      fields.add('authorId');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class PostCreateInput {
  const PostCreateInput({
    required this.id,
    required this.authorId,
    this.author,
  });

  final int id;
  final int authorId;
  final UserCreateNestedOneWithoutPostsInput? author;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    data['authorId'] = authorId;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'id', operator: 'equals', value: id),
    ]);
    return List<List<QueryPredicate>>.unmodifiable(
      selectors.map(List<QueryPredicate>.unmodifiable),
    );
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (author != null) {
      writes.addAll(
        author!.toRelationWrites(
          QueryRelation(
            field: 'author',
            targetModel: 'User',
            cardinality: QueryRelationCardinality.one,
            localKeyField: 'authorId',
            targetKeyField: 'id',
            localKeyFields: const <String>['authorId'],
            targetKeyFields: const <String>['id'],
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (author?.hasDeferredWrites ?? false);
  }

  PostUpdateInput toDeferredRelationUpdateInput() {
    return PostUpdateInput(author: author?.toDeferredUpdateWrite());
  }
}

class PostUpdateInput {
  const PostUpdateInput({this.authorId, this.authorIdOps, this.author});

  final int? authorId;
  final IntFieldUpdateOperationsInput? authorIdOps;
  final UserUpdateNestedOneWithoutPostsInput? author;

  bool get hasComputedOperators {
    return authorIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return author?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (authorId != null && authorIdOps != null) {
      throw StateError(
        'Only one of authorId or authorIdOps may be provided for PostUpdateInput.authorId.',
      );
    }
    if (authorId != null) {
      data['authorId'] = authorId;
    }
    if (authorIdOps != null) {
      final ops = authorIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for PostUpdateInput.authorId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for PostUpdateInput.authorId require the current record value before they can be converted to raw update data.',
        );
      }
      if (ops.hasSet) {
        data['authorId'] = ops.set as int?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (authorId != null && authorIdOps != null) {
      throw StateError(
        'Only one of authorId or authorIdOps may be provided for PostUpdateInput.authorId.',
      );
    }
    if (authorId != null) {
      data['authorId'] = authorId;
    }
    if (authorIdOps != null) {
      final ops = authorIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for PostUpdateInput.authorId.',
        );
      }
      if (ops.hasSet) {
        data['authorId'] = ops.set as int?;
      } else {
        final currentValue = record['authorId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment PostUpdateInput.authorId because the current value is null.',
            );
          }
          data['authorId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement PostUpdateInput.authorId because the current value is null.',
            );
          }
          data['authorId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class PostCreateWithoutAuthorInput {
  const PostCreateWithoutAuthorInput({required this.id});

  final int id;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutPostsInput {
  const UserConnectOrCreateWithoutPostsInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutPostsInput create;
}

class UserCreateNestedOneWithoutPostsInput {
  const UserCreateNestedOneWithoutPostsInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserCreateWithoutPostsInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutPostsInput? connectOrCreate;
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
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutPostsInput.',
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

  UserUpdateNestedOneWithoutPostsInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutPostsInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutPostsInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class UserUpdateNestedOneWithoutPostsInput {
  const UserUpdateNestedOneWithoutPostsInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutPostsInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites =>
      connect != null || connectOrCreate != null || disconnect;
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
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'Profile',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then((record) => record == null ? null : Profile.fromRecord(record));
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
            model: 'Profile',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : Profile.fromRecord(record));
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
            model: 'Profile',
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
          (records) => records.map(Profile.fromRecord).toList(growable: false),
        );
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
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'Profile',
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
        .then(ProfileAggregateResult.fromQueryResult);
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
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'Profile',
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
              .map(ProfileGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
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
              FindUniqueQuery(model: 'Profile', where: selector),
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
        FindUniqueQuery(model: 'Profile', where: predicates),
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
        FindUniqueQuery(model: 'Profile', where: predicates),
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
          FindManyQuery(model: 'Profile', where: predicates),
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
      UpdateManyQuery(model: 'Profile', where: predicates, data: data.toData()),
    );
  }

  Future<List<Profile>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required ProfileWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'Profile',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <Profile>[];
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
      return pagedRecords.map(Profile.fromRecord).toList(growable: false);
    }
    final projectedRecords = <Profile>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'Profile',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'Profile.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(Profile.fromRecord(projected));
    }
    return List<Profile>.unmodifiable(projectedRecords);
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
      throw StateError(
        'Profile create branch could not reload the created record by primary key.',
      );
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
      throw StateError(
        'Profile update branch could not reload the updated record for the provided unique selector.',
      );
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
        throw StateError(
          'Only one of connect, connectOrCreate or disconnect may be provided for ProfileUpdateInput.user.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on Profile.user.',
          );
        }
        await tx._client
            .model('Profile')
            .update(
              UpdateQuery(
                model: 'Profile',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    related,
                    'id',
                    'nested direct relation write on Profile.user',
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
            .model('Profile')
            .update(
              UpdateQuery(
                model: 'Profile',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    relatedRecord,
                    'id',
                    'nested direct relation write on Profile.user',
                  ),
                },
              ),
            );
      }
      if (nested.disconnect) {
        await tx._client
            .model('Profile')
            .update(
              UpdateQuery(
                model: 'Profile',
                where: predicates,
                data: <String, Object?>{'userId': null},
              ),
            );
      }
    }
  }

  Future<Profile> delete({
    required ProfileWhereUniqueInput where,
    ProfileInclude? include,
    ProfileSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'Profile',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Profile.fromRecord);
  }

  Future<int> deleteMany({required ProfileWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'Profile', where: where.toPredicates()),
    );
  }
}

class ProfileWhereInput {
  const ProfileWhereInput({
    this.AND = const <ProfileWhereInput>[],
    this.OR = const <ProfileWhereInput>[],
    this.NOT = const <ProfileWhereInput>[],
    this.id,
    this.idFilter,
    this.userId,
    this.userIdFilter,
    this.userIs,
    this.userIsNot,
  });

  final List<ProfileWhereInput> AND;
  final List<ProfileWhereInput> OR;
  final List<ProfileWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
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

class ProfileWhereUniqueInput {
  const ProfileWhereUniqueInput({this.id, this.userId});

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
      throw StateError(
        'Exactly one unique selector must be provided for ProfileWhereUniqueInput.',
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
    if (userId != null) {
      selectorCount++;
      matches = record['userId'] == userId;
    }
    if (selectorCount != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for ProfileWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class ProfileOrderByInput {
  const ProfileOrderByInput({this.id, this.userId});

  final SortOrder? id;
  final SortOrder? userId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum ProfileScalarField { id, userId }

class ProfileCountAggregateInput {
  const ProfileCountAggregateInput({
    this.all = false,
    this.id = false,
    this.userId = false,
  });

  final bool all;
  final bool id;
  final bool userId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
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

class ProfileAvgAggregateInput {
  const ProfileAvgAggregateInput({this.id = false, this.userId = false});

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
  const ProfileSumAggregateInput({this.id = false, this.userId = false});

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
  const ProfileMinAggregateInput({this.id = false, this.userId = false});

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

class ProfileMaxAggregateInput {
  const ProfileMaxAggregateInput({this.id = false, this.userId = false});

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

class ProfileCountAggregateResult {
  const ProfileCountAggregateResult({this.all, this.id, this.userId});

  final int? all;
  final int? id;
  final int? userId;

  factory ProfileCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return ProfileCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      userId: result.fields['userId'],
    );
  }
}

class ProfileAvgAggregateResult {
  const ProfileAvgAggregateResult({this.id, this.userId});

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
  const ProfileSumAggregateResult({this.id, this.userId});

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
  const ProfileMinAggregateResult({this.id, this.userId});

  final int? id;
  final int? userId;

  factory ProfileMinAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMinAggregateResult(
      id: values['id'] as int?,
      userId: values['userId'] as int?,
    );
  }
}

class ProfileMaxAggregateResult {
  const ProfileMaxAggregateResult({this.id, this.userId});

  final int? id;
  final int? userId;

  factory ProfileMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMaxAggregateResult(
      id: values['id'] as int?,
      userId: values['userId'] as int?,
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
      count: result.count == null
          ? null
          : ProfileCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : ProfileAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : ProfileSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : ProfileMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : ProfileMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class ProfileGroupByHavingInput {
  const ProfileGroupByHavingInput({this.id, this.userId});

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
  const ProfileCountAggregateOrderByInput({this.all, this.id, this.userId});

  final SortOrder? all;
  final SortOrder? id;
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

class ProfileAvgAggregateOrderByInput {
  const ProfileAvgAggregateOrderByInput({this.id, this.userId});

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

class ProfileSumAggregateOrderByInput {
  const ProfileSumAggregateOrderByInput({this.id, this.userId});

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

class ProfileMinAggregateOrderByInput {
  const ProfileMinAggregateOrderByInput({this.id, this.userId});

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

class ProfileMaxAggregateOrderByInput {
  const ProfileMaxAggregateOrderByInput({this.id, this.userId});

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

class ProfileGroupByOrderByInput {
  const ProfileGroupByOrderByInput({
    this.id,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? userId;
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
  const ProfileGroupByRow({
    this.id,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final int? userId;
  final ProfileCountAggregateResult? count;
  final ProfileAvgAggregateResult? avg;
  final ProfileSumAggregateResult? sum;
  final ProfileMinAggregateResult? min;
  final ProfileMaxAggregateResult? max;

  factory ProfileGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return ProfileGroupByRow(
      id: row.group['id'] as int?,
      userId: row.group['userId'] as int?,
      count: row.aggregates.count == null
          ? null
          : ProfileCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : ProfileAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : ProfileSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : ProfileMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : ProfileMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class ProfileInclude {
  const ProfileInclude({this.user = false});

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

class ProfileSelect {
  const ProfileSelect({this.id = false, this.userId = false});

  final bool id;
  final bool userId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
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

class ProfileCreateInput {
  const ProfileCreateInput({required this.id, this.userId, this.user});

  final int id;
  final int? userId;
  final UserCreateNestedOneWithoutProfileInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    if (userId != null) {
      data['userId'] = userId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'id', operator: 'equals', value: id),
    ]);
    if (userId != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'userId', operator: 'equals', value: userId),
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

  ProfileUpdateInput toDeferredRelationUpdateInput() {
    return ProfileUpdateInput(user: user?.toDeferredUpdateWrite());
  }
}

class ProfileUpdateInput {
  const ProfileUpdateInput({this.userId, this.userIdOps, this.user});

  final int? userId;
  final IntFieldUpdateOperationsInput? userIdOps;
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
      throw StateError(
        'Only one of userId or userIdOps may be provided for ProfileUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for ProfileUpdateInput.userId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for ProfileUpdateInput.userId require the current record value before they can be converted to raw update data.',
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
    if (userId != null && userIdOps != null) {
      throw StateError(
        'Only one of userId or userIdOps may be provided for ProfileUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for ProfileUpdateInput.userId.',
        );
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      } else {
        final currentValue = record['userId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment ProfileUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement ProfileUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class ProfileCreateWithoutUserInput {
  const ProfileCreateWithoutUserInput({required this.id});

  final int id;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutProfileInput {
  const UserConnectOrCreateWithoutProfileInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutProfileInput create;
}

class UserCreateNestedOneWithoutProfileInput {
  const UserCreateNestedOneWithoutProfileInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserCreateWithoutProfileInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutProfileInput? connectOrCreate;
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
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutProfileInput.',
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

  UserUpdateNestedOneWithoutProfileInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutProfileInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutProfileInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class UserUpdateNestedOneWithoutProfileInput {
  const UserUpdateNestedOneWithoutProfileInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutProfileInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites =>
      connect != null || connectOrCreate != null || disconnect;
}

class GroupDelegate {
  const GroupDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Group');

  Future<Group?> findUnique({
    required GroupWhereUniqueInput where,
    GroupInclude? include,
    GroupSelect? select,
  }) {
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'Group',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then((record) => record == null ? null : Group.fromRecord(record));
  }

  Future<Group?> findFirst({
    GroupWhereInput? where,
    GroupWhereUniqueInput? cursor,
    List<GroupOrderByInput>? orderBy,
    List<GroupScalarField>? distinct,
    GroupInclude? include,
    GroupSelect? select,
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
            model: 'Group',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : Group.fromRecord(record));
  }

  Future<List<Group>> findMany({
    GroupWhereInput? where,
    GroupWhereUniqueInput? cursor,
    List<GroupOrderByInput>? orderBy,
    List<GroupScalarField>? distinct,
    GroupInclude? include,
    GroupSelect? select,
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
            model: 'Group',
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
          (records) => records.map(Group.fromRecord).toList(growable: false),
        );
  }

  Future<int> count({GroupWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Group',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<GroupAggregateResult> aggregate({
    GroupWhereInput? where,
    List<GroupOrderByInput>? orderBy,
    int? skip,
    int? take,
    GroupCountAggregateInput? count,
    GroupAvgAggregateInput? avg,
    GroupSumAggregateInput? sum,
    GroupMinAggregateInput? min,
    GroupMaxAggregateInput? max,
  }) {
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'Group',
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
        .then(GroupAggregateResult.fromQueryResult);
  }

  Future<List<GroupGroupByRow>> groupBy({
    required List<GroupScalarField> by,
    GroupWhereInput? where,
    List<GroupGroupByOrderByInput>? orderBy,
    GroupGroupByHavingInput? having,
    int? skip,
    int? take,
    GroupCountAggregateInput? count,
    GroupAvgAggregateInput? avg,
    GroupSumAggregateInput? sum,
    GroupMinAggregateInput? min,
    GroupMaxAggregateInput? max,
  }) {
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'Group',
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
              .map(GroupGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
  }

  Future<Group> create({
    required GroupCreateInput data,
    GroupInclude? include,
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
    required List<GroupCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Group');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(model: 'Group', where: selector),
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
                model: 'Group',
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

  Future<Group> update({
    required GroupWhereUniqueInput where,
    required GroupUpdateInput data,
    GroupInclude? include,
    GroupSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Group');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Group', where: predicates),
      );
      if (existing == null) {
        throw StateError('No record found for update in Group.');
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

  Future<Group> upsert({
    required GroupWhereUniqueInput where,
    required GroupCreateInput create,
    required GroupUpdateInput update,
    GroupInclude? include,
    GroupSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Group');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Group', where: predicates),
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
    required GroupWhereInput where,
    required GroupUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Group');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(model: 'Group', where: predicates),
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
      UpdateManyQuery(model: 'Group', where: predicates, data: data.toData()),
    );
  }

  Future<List<Group>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required GroupWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'Group',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <Group>[];
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
      return pagedRecords.map(Group.fromRecord).toList(growable: false);
    }
    final projectedRecords = <Group>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'Group',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'Group.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(Group.fromRecord(projected));
    }
    return List<Group>.unmodifiable(projectedRecords);
  }

  Future<Group> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required GroupCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Group');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Group',
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
      return Group.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Group',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Group create branch could not reload the created record by primary key.',
      );
    }
    return Group.fromRecord(projected);
  }

  GroupWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return GroupWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<Group> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required GroupUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Group');
    await txDelegate.update(
      UpdateQuery(
        model: 'Group',
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
        model: 'Group',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Group update branch could not reload the updated record for the provided unique selector.',
      );
    }
    return Group.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required GroupUpdateInput data,
  }) async {
    if (data.users == null) {
      // No nested writes for users.
    } else {
      final nested = data.users!;
      final relation = QueryRelation(
        field: 'users',
        targetModel: 'User',
        cardinality: QueryRelationCardinality.many,
        localKeyField: 'id',
        targetKeyField: 'id',
        localKeyFields: const <String>['id'],
        targetKeyFields: const <String>['id'],
        storageKind: QueryRelationStorageKind.implicitManyToMany,
        sourceModel: 'Group',
        inverseField: 'groups',
      );
      final parentKeyValues = <String, Object?>{
        'id': _requireRecordValue(
          existing,
          'id',
          'nested implicit many-to-many write on Group.users',
        ),
      };
      if (nested.set != null &&
          (nested.connect.isNotEmpty ||
              nested.disconnect.isNotEmpty ||
              nested.connectOrCreate.isNotEmpty)) {
        throw StateError(
          'Only set or connect/disconnect/connectOrCreate may be provided for GroupUpdateInput.users.',
        );
      }
      if (nested.set != null) {
        await tx._client
            .model('Group')
            .removeImplicitManyToManyLinks(
              relation: relation,
              sourceKeyValues: parentKeyValues,
            );
        for (final selector in nested.set!) {
          final related = await tx.user._delegate.findUnique(
            FindUniqueQuery(model: 'User', where: selector.toPredicates()),
          );
          if (related == null) {
            throw StateError(
              'No related User record found for nested set on Group.users.',
            );
          }
          final targetKeyValues = <String, Object?>{
            'id': _requireRecordValue(
              related,
              'id',
              'nested implicit many-to-many write on Group.users',
            ),
          };
          await tx._client
              .model('Group')
              .addImplicitManyToManyLink(
                relation: relation,
                sourceKeyValues: parentKeyValues,
                targetKeyValues: targetKeyValues,
              );
        }
      }
      for (final selector in nested.connect) {
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on Group.users.',
          );
        }
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            related,
            'id',
            'nested implicit many-to-many write on Group.users',
          ),
        };
        await tx._client
            .model('Group')
            .addImplicitManyToManyLink(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
      for (final entry in nested.connectOrCreate) {
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
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            relatedRecord,
            'id',
            'nested implicit many-to-many write on Group.users',
          ),
        };
        await tx._client
            .model('Group')
            .addImplicitManyToManyLink(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
      for (final selector in nested.disconnect) {
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested disconnect on Group.users.',
          );
        }
        final targetKeyValues = <String, Object?>{
          'id': _requireRecordValue(
            related,
            'id',
            'nested implicit many-to-many write on Group.users',
          ),
        };
        await tx._client
            .model('Group')
            .removeImplicitManyToManyLinks(
              relation: relation,
              sourceKeyValues: parentKeyValues,
              targetKeyValues: targetKeyValues,
            );
      }
    }
  }

  Future<Group> delete({
    required GroupWhereUniqueInput where,
    GroupInclude? include,
    GroupSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'Group',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Group.fromRecord);
  }

  Future<int> deleteMany({required GroupWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'Group', where: where.toPredicates()),
    );
  }
}

class GroupWhereInput {
  const GroupWhereInput({
    this.AND = const <GroupWhereInput>[],
    this.OR = const <GroupWhereInput>[],
    this.NOT = const <GroupWhereInput>[],
    this.id,
    this.idFilter,
    this.usersSome,
    this.usersNone,
    this.usersEvery,
  });

  final List<GroupWhereInput> AND;
  final List<GroupWhereInput> OR;
  final List<GroupWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final UserWhereInput? usersSome;
  final UserWhereInput? usersNone;
  final UserWhereInput? usersEvery;

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
    if (usersSome != null) {
      predicates.add(
        QueryPredicate(
          field: 'users',
          operator: 'relationSome',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'users',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'Group',
              inverseField: 'groups',
            ),
            predicates: usersSome!.toPredicates(),
          ),
        ),
      );
    }
    if (usersNone != null) {
      predicates.add(
        QueryPredicate(
          field: 'users',
          operator: 'relationNone',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'users',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'Group',
              inverseField: 'groups',
            ),
            predicates: usersNone!.toPredicates(),
          ),
        ),
      );
    }
    if (usersEvery != null) {
      predicates.add(
        QueryPredicate(
          field: 'users',
          operator: 'relationEvery',
          value: QueryRelationFilter(
            relation: QueryRelation(
              field: 'users',
              targetModel: 'User',
              cardinality: QueryRelationCardinality.many,
              localKeyField: 'id',
              targetKeyField: 'id',
              localKeyFields: const <String>['id'],
              targetKeyFields: const <String>['id'],
              storageKind: QueryRelationStorageKind.implicitManyToMany,
              sourceModel: 'Group',
              inverseField: 'groups',
            ),
            predicates: usersEvery!.toPredicates(),
          ),
        ),
      );
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class GroupWhereUniqueInput {
  const GroupWhereUniqueInput({this.id});

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
        'Exactly one unique selector must be provided for GroupWhereUniqueInput.',
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
        'Exactly one unique selector must be provided for GroupWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class GroupOrderByInput {
  const GroupOrderByInput({this.id});

  final SortOrder? id;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum GroupScalarField { id }

class GroupCountAggregateInput {
  const GroupCountAggregateInput({this.all = false, this.id = false});

  final bool all;
  final bool id;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class GroupAvgAggregateInput {
  const GroupAvgAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class GroupSumAggregateInput {
  const GroupSumAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class GroupMinAggregateInput {
  const GroupMinAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class GroupMaxAggregateInput {
  const GroupMaxAggregateInput({this.id = false});

  final bool id;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class GroupCountAggregateResult {
  const GroupCountAggregateResult({this.all, this.id});

  final int? all;
  final int? id;

  factory GroupCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return GroupCountAggregateResult(all: result.all, id: result.fields['id']);
  }
}

class GroupAvgAggregateResult {
  const GroupAvgAggregateResult({this.id});

  final double? id;

  factory GroupAvgAggregateResult.fromMap(Map<String, double?> values) {
    return GroupAvgAggregateResult(id: _asDouble(values['id']));
  }
}

class GroupSumAggregateResult {
  const GroupSumAggregateResult({this.id});

  final int? id;

  factory GroupSumAggregateResult.fromMap(Map<String, num?> values) {
    return GroupSumAggregateResult(id: values['id']?.toInt());
  }
}

class GroupMinAggregateResult {
  const GroupMinAggregateResult({this.id});

  final int? id;

  factory GroupMinAggregateResult.fromMap(Map<String, Object?> values) {
    return GroupMinAggregateResult(id: values['id'] as int?);
  }
}

class GroupMaxAggregateResult {
  const GroupMaxAggregateResult({this.id});

  final int? id;

  factory GroupMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return GroupMaxAggregateResult(id: values['id'] as int?);
  }
}

class GroupAggregateResult {
  const GroupAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final GroupCountAggregateResult? count;
  final GroupAvgAggregateResult? avg;
  final GroupSumAggregateResult? sum;
  final GroupMinAggregateResult? min;
  final GroupMaxAggregateResult? max;

  factory GroupAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return GroupAggregateResult(
      count: result.count == null
          ? null
          : GroupCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : GroupAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : GroupSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : GroupMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : GroupMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class GroupGroupByHavingInput {
  const GroupGroupByHavingInput({this.id});

  final NumericAggregatesFilter? id;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class GroupCountAggregateOrderByInput {
  const GroupCountAggregateOrderByInput({this.all, this.id});

  final SortOrder? all;
  final SortOrder? id;

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
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class GroupAvgAggregateOrderByInput {
  const GroupAvgAggregateOrderByInput({this.id});

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

class GroupSumAggregateOrderByInput {
  const GroupSumAggregateOrderByInput({this.id});

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

class GroupMinAggregateOrderByInput {
  const GroupMinAggregateOrderByInput({this.id});

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

class GroupMaxAggregateOrderByInput {
  const GroupMaxAggregateOrderByInput({this.id});

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

class GroupGroupByOrderByInput {
  const GroupGroupByOrderByInput({
    this.id,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final GroupCountAggregateOrderByInput? count;
  final GroupAvgAggregateOrderByInput? avg;
  final GroupSumAggregateOrderByInput? sum;
  final GroupMinAggregateOrderByInput? min;
  final GroupMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.field(field: 'id', direction: id!));
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

class GroupGroupByRow {
  const GroupGroupByRow({
    this.id,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final GroupCountAggregateResult? count;
  final GroupAvgAggregateResult? avg;
  final GroupSumAggregateResult? sum;
  final GroupMinAggregateResult? min;
  final GroupMaxAggregateResult? max;

  factory GroupGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return GroupGroupByRow(
      id: row.group['id'] as int?,
      count: row.aggregates.count == null
          ? null
          : GroupCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : GroupAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : GroupSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : GroupMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : GroupMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class GroupInclude {
  const GroupInclude({this.users = false});

  final bool users;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (users) {
      relations['users'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'users',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'id',
          localKeyFields: const <String>['id'],
          targetKeyFields: const <String>['id'],
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'Group',
          inverseField: 'groups',
        ),
      );
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class GroupSelect {
  const GroupSelect({this.id = false});

  final bool id;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class GroupCreateInput {
  const GroupCreateInput({required this.id, this.users});

  final int id;
  final UserCreateNestedManyWithoutGroupsInput? users;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'id', operator: 'equals', value: id),
    ]);
    return List<List<QueryPredicate>>.unmodifiable(
      selectors.map(List<QueryPredicate>.unmodifiable),
    );
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (users != null) {
      writes.addAll(
        users!.toRelationWrites(
          QueryRelation(
            field: 'users',
            targetModel: 'User',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'id',
            localKeyFields: const <String>['id'],
            targetKeyFields: const <String>['id'],
            storageKind: QueryRelationStorageKind.implicitManyToMany,
            sourceModel: 'Group',
            inverseField: 'groups',
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (users?.hasDeferredWrites ?? false);
  }

  GroupUpdateInput toDeferredRelationUpdateInput() {
    return GroupUpdateInput(users: users?.toDeferredUpdateWrite());
  }
}

class GroupUpdateInput {
  const GroupUpdateInput({this.users});

  final UserUpdateNestedManyWithoutGroupsInput? users;

  bool get hasComputedOperators {
    return false;
  }

  bool get hasRelationWrites {
    return users?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    return Map<String, Object?>.unmodifiable(data);
  }
}

class GroupCreateWithoutUsersInput {
  const GroupCreateWithoutUsersInput({required this.id});

  final int id;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserConnectOrCreateWithoutGroupsInput {
  const UserConnectOrCreateWithoutGroupsInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutGroupsInput create;
}

class UserCreateNestedManyWithoutGroupsInput {
  const UserCreateNestedManyWithoutGroupsInput({
    this.create = const <UserCreateWithoutGroupsInput>[],
    this.connect = const <UserWhereUniqueInput>[],
    this.disconnect = const <UserWhereUniqueInput>[],
    this.connectOrCreate = const <UserConnectOrCreateWithoutGroupsInput>[],
    this.set,
  });

  final List<UserCreateWithoutGroupsInput> create;
  final List<UserWhereUniqueInput> connect;
  final List<UserWhereUniqueInput> disconnect;
  final List<UserConnectOrCreateWithoutGroupsInput> connectOrCreate;
  final List<UserWhereUniqueInput>? set;

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

  UserUpdateNestedManyWithoutGroupsInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedManyWithoutGroupsInput(
      connect: connect,
      disconnect: disconnect,
      connectOrCreate: connectOrCreate,
      set: set,
    );
  }
}

class UserUpdateNestedManyWithoutGroupsInput {
  const UserUpdateNestedManyWithoutGroupsInput({
    this.connect = const <UserWhereUniqueInput>[],
    this.disconnect = const <UserWhereUniqueInput>[],
    this.connectOrCreate = const <UserConnectOrCreateWithoutGroupsInput>[],
    this.set,
  });

  final List<UserWhereUniqueInput> connect;
  final List<UserWhereUniqueInput> disconnect;
  final List<UserConnectOrCreateWithoutGroupsInput> connectOrCreate;
  final List<UserWhereUniqueInput>? set;

  bool get hasWrites =>
      connect.isNotEmpty ||
      disconnect.isNotEmpty ||
      connectOrCreate.isNotEmpty ||
      set != null;
}

class MembershipDelegate {
  const MembershipDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Membership');

  Future<Membership?> findUnique({
    required MembershipWhereUniqueInput where,
    MembershipInclude? include,
    MembershipSelect? select,
  }) {
    return _delegate
        .findUnique(
          FindUniqueQuery(
            model: 'Membership',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(
          (record) => record == null ? null : Membership.fromRecord(record),
        );
  }

  Future<Membership?> findFirst({
    MembershipWhereInput? where,
    MembershipWhereUniqueInput? cursor,
    List<MembershipOrderByInput>? orderBy,
    List<MembershipScalarField>? distinct,
    MembershipInclude? include,
    MembershipSelect? select,
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
            model: 'Membership',
            where: predicates,
            orderBy: queryOrderBy,
            distinct: queryDistinct,
            include: queryInclude,
            select: querySelect,
            skip: skip,
          ),
        )
        .then(
          (record) => record == null ? null : Membership.fromRecord(record),
        );
  }

  Future<List<Membership>> findMany({
    MembershipWhereInput? where,
    MembershipWhereUniqueInput? cursor,
    List<MembershipOrderByInput>? orderBy,
    List<MembershipScalarField>? distinct,
    MembershipInclude? include,
    MembershipSelect? select,
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
            model: 'Membership',
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
          (records) =>
              records.map(Membership.fromRecord).toList(growable: false),
        );
  }

  Future<int> count({MembershipWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Membership',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<MembershipAggregateResult> aggregate({
    MembershipWhereInput? where,
    List<MembershipOrderByInput>? orderBy,
    int? skip,
    int? take,
    MembershipCountAggregateInput? count,
    MembershipAvgAggregateInput? avg,
    MembershipSumAggregateInput? sum,
    MembershipMinAggregateInput? min,
    MembershipMaxAggregateInput? max,
  }) {
    return _delegate
        .aggregate(
          AggregateQuery(
            model: 'Membership',
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
        .then(MembershipAggregateResult.fromQueryResult);
  }

  Future<List<MembershipGroupByRow>> groupBy({
    required List<MembershipScalarField> by,
    MembershipWhereInput? where,
    List<MembershipGroupByOrderByInput>? orderBy,
    MembershipGroupByHavingInput? having,
    int? skip,
    int? take,
    MembershipCountAggregateInput? count,
    MembershipAvgAggregateInput? avg,
    MembershipSumAggregateInput? sum,
    MembershipMinAggregateInput? min,
    MembershipMaxAggregateInput? max,
  }) {
    return _delegate
        .groupBy(
          GroupByQuery(
            model: 'Membership',
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
              .map(MembershipGroupByRow.fromQueryResultRow)
              .toList(growable: false),
        );
  }

  Future<Membership> create({
    required MembershipCreateInput data,
    MembershipInclude? include,
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
    required List<MembershipCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Membership');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(model: 'Membership', where: selector),
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
                model: 'Membership',
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

  Future<Membership> update({
    required MembershipWhereUniqueInput where,
    required MembershipUpdateInput data,
    MembershipInclude? include,
    MembershipSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Membership');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Membership', where: predicates),
      );
      if (existing == null) {
        throw StateError('No record found for update in Membership.');
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

  Future<Membership> upsert({
    required MembershipWhereUniqueInput where,
    required MembershipCreateInput create,
    required MembershipUpdateInput update,
    MembershipInclude? include,
    MembershipSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Membership');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(model: 'Membership', where: predicates),
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
    required MembershipWhereInput where,
    required MembershipUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Membership');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(model: 'Membership', where: predicates),
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
        model: 'Membership',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<List<Membership>> _findManyWithCursor({
    required List<QueryPredicate> predicates,
    required MembershipWhereUniqueInput cursor,
    required List<QueryOrderBy> orderBy,
    required Set<String> distinct,
    QueryInclude? include,
    QuerySelect? select,
    int? skip,
    int? take,
  }) async {
    final rawRecords = await _delegate.findMany(
      FindManyQuery(
        model: 'Membership',
        where: predicates,
        orderBy: orderBy,
        distinct: distinct,
      ),
    );
    final cursorIndex = rawRecords.indexWhere(cursor.matchesRecord);
    if (cursorIndex < 0) {
      return const <Membership>[];
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
      return pagedRecords.map(Membership.fromRecord).toList(growable: false);
    }
    final projectedRecords = <Membership>[];
    for (final record in pagedRecords) {
      final projected = await _delegate.findUnique(
        FindUniqueQuery(
          model: 'Membership',
          where: _primaryKeyWhereUniqueFromRecord(record).toPredicates(),
          include: include,
          select: select,
        ),
      );
      if (projected == null) {
        throw StateError(
          'Membership.findMany(cursor: ...) could not reload a paged record by primary key.',
        );
      }
      projectedRecords.add(Membership.fromRecord(projected));
    }
    return List<Membership>.unmodifiable(projectedRecords);
  }

  Future<Membership> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required MembershipCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Membership');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Membership',
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
      return Membership.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Membership',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Membership create branch could not reload the created record by primary key.',
      );
    }
    return Membership.fromRecord(projected);
  }

  MembershipWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return MembershipWhereUniqueInput(
      tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
        tenantId: (record['tenantId'] as int?)!,
        slug: (record['slug'] as String?)!,
      ),
    );
  }

  Future<Membership> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required MembershipUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Membership');
    await txDelegate.update(
      UpdateQuery(
        model: 'Membership',
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
        model: 'Membership',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError(
        'Membership update branch could not reload the updated record for the provided unique selector.',
      );
    }
    return Membership.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required MembershipUpdateInput data,
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
          'Only one of connect, connectOrCreate or disconnect may be provided for MembershipUpdateInput.user.',
        );
      }
      if (nested.connect != null) {
        final selector = nested.connect!;
        final related = await tx.user._delegate.findUnique(
          FindUniqueQuery(model: 'User', where: selector.toPredicates()),
        );
        if (related == null) {
          throw StateError(
            'No related User record found for nested connect on Membership.user.',
          );
        }
        await tx._client
            .model('Membership')
            .update(
              UpdateQuery(
                model: 'Membership',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    related,
                    'id',
                    'nested direct relation write on Membership.user',
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
            .model('Membership')
            .update(
              UpdateQuery(
                model: 'Membership',
                where: predicates,
                data: <String, Object?>{
                  'userId': _requireRecordValue(
                    relatedRecord,
                    'id',
                    'nested direct relation write on Membership.user',
                  ),
                },
              ),
            );
      }
      if (nested.disconnect) {
        throw StateError(
          'Nested disconnect is not supported for required relation Membership.user.',
        );
      }
    }
  }

  Future<Membership> delete({
    required MembershipWhereUniqueInput where,
    MembershipInclude? include,
    MembershipSelect? select,
  }) {
    return _delegate
        .delete(
          DeleteQuery(
            model: 'Membership',
            where: where.toPredicates(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Membership.fromRecord);
  }

  Future<int> deleteMany({required MembershipWhereInput where}) {
    return _delegate.deleteMany(
      DeleteManyQuery(model: 'Membership', where: where.toPredicates()),
    );
  }
}

class MembershipWhereInput {
  const MembershipWhereInput({
    this.AND = const <MembershipWhereInput>[],
    this.OR = const <MembershipWhereInput>[],
    this.NOT = const <MembershipWhereInput>[],
    this.tenantId,
    this.tenantIdFilter,
    this.slug,
    this.slugFilter,
    this.userId,
    this.userIdFilter,
    this.userIs,
    this.userIsNot,
  });

  final List<MembershipWhereInput> AND;
  final List<MembershipWhereInput> OR;
  final List<MembershipWhereInput> NOT;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? slug;
  final StringFilter? slugFilter;
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
    if (tenantId != null) {
      predicates.add(
        QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
      );
    }
    if (tenantIdFilter != null) {
      predicates.addAll(tenantIdFilter!.toPredicates('tenantId'));
    }
    if (slug != null) {
      predicates.add(
        QueryPredicate(field: 'slug', operator: 'equals', value: slug),
      );
    }
    if (slugFilter != null) {
      predicates.addAll(slugFilter!.toPredicates('slug'));
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

class MembershipTenantIdSlugCompoundUniqueInput {
  const MembershipTenantIdSlugCompoundUniqueInput({
    required this.tenantId,
    required this.slug,
  });

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

class MembershipWhereUniqueInput {
  const MembershipWhereUniqueInput({this.tenantId_slug});

  final MembershipTenantIdSlugCompoundUniqueInput? tenantId_slug;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (tenantId_slug != null) {
      selectors.add(tenantId_slug!.toPredicates());
    }
    if (selectors.length != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for MembershipWhereUniqueInput.',
      );
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }

  bool matchesRecord(Map<String, Object?> record) {
    var selectorCount = 0;
    var matches = false;
    if (tenantId_slug != null) {
      selectorCount++;
      matches = tenantId_slug!.matchesRecord(record);
    }
    if (selectorCount != 1) {
      throw StateError(
        'Exactly one unique selector must be provided for MembershipWhereUniqueInput.',
      );
    }
    return matches;
  }
}

class MembershipOrderByInput {
  const MembershipOrderByInput({this.tenantId, this.slug, this.userId});

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? userId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (tenantId != null) {
      orderings.add(QueryOrderBy(field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(QueryOrderBy(field: 'slug', direction: slug!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum MembershipScalarField { tenantId, slug, userId }

class MembershipCountAggregateInput {
  const MembershipCountAggregateInput({
    this.all = false,
    this.tenantId = false,
    this.slug = false,
    this.userId = false,
  });

  final bool all;
  final bool tenantId;
  final bool slug;
  final bool userId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
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

class MembershipAvgAggregateInput {
  const MembershipAvgAggregateInput({
    this.tenantId = false,
    this.userId = false,
  });

  final bool tenantId;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipSumAggregateInput {
  const MembershipSumAggregateInput({
    this.tenantId = false,
    this.userId = false,
  });

  final bool tenantId;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipMinAggregateInput {
  const MembershipMinAggregateInput({
    this.tenantId = false,
    this.slug = false,
    this.userId = false,
  });

  final bool tenantId;
  final bool slug;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipMaxAggregateInput {
  const MembershipMaxAggregateInput({
    this.tenantId = false,
    this.slug = false,
    this.userId = false,
  });

  final bool tenantId;
  final bool slug;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipCountAggregateResult {
  const MembershipCountAggregateResult({
    this.all,
    this.tenantId,
    this.slug,
    this.userId,
  });

  final int? all;
  final int? tenantId;
  final int? slug;
  final int? userId;

  factory MembershipCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return MembershipCountAggregateResult(
      all: result.all,
      tenantId: result.fields['tenantId'],
      slug: result.fields['slug'],
      userId: result.fields['userId'],
    );
  }
}

class MembershipAvgAggregateResult {
  const MembershipAvgAggregateResult({this.tenantId, this.userId});

  final double? tenantId;
  final double? userId;

  factory MembershipAvgAggregateResult.fromMap(Map<String, double?> values) {
    return MembershipAvgAggregateResult(
      tenantId: _asDouble(values['tenantId']),
      userId: _asDouble(values['userId']),
    );
  }
}

class MembershipSumAggregateResult {
  const MembershipSumAggregateResult({this.tenantId, this.userId});

  final int? tenantId;
  final int? userId;

  factory MembershipSumAggregateResult.fromMap(Map<String, num?> values) {
    return MembershipSumAggregateResult(
      tenantId: values['tenantId']?.toInt(),
      userId: values['userId']?.toInt(),
    );
  }
}

class MembershipMinAggregateResult {
  const MembershipMinAggregateResult({this.tenantId, this.slug, this.userId});

  final int? tenantId;
  final String? slug;
  final int? userId;

  factory MembershipMinAggregateResult.fromMap(Map<String, Object?> values) {
    return MembershipMinAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      userId: values['userId'] as int?,
    );
  }
}

class MembershipMaxAggregateResult {
  const MembershipMaxAggregateResult({this.tenantId, this.slug, this.userId});

  final int? tenantId;
  final String? slug;
  final int? userId;

  factory MembershipMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return MembershipMaxAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      userId: values['userId'] as int?,
    );
  }
}

class MembershipAggregateResult {
  const MembershipAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final MembershipCountAggregateResult? count;
  final MembershipAvgAggregateResult? avg;
  final MembershipSumAggregateResult? sum;
  final MembershipMinAggregateResult? min;
  final MembershipMaxAggregateResult? max;

  factory MembershipAggregateResult.fromQueryResult(
    AggregateQueryResult result,
  ) {
    return MembershipAggregateResult(
      count: result.count == null
          ? null
          : MembershipCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null
          ? null
          : MembershipAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null
          ? null
          : MembershipSumAggregateResult.fromMap(result.sum!),
      min: result.min == null
          ? null
          : MembershipMinAggregateResult.fromMap(result.min!),
      max: result.max == null
          ? null
          : MembershipMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class MembershipGroupByHavingInput {
  const MembershipGroupByHavingInput({this.tenantId, this.userId});

  final NumericAggregatesFilter? tenantId;
  final NumericAggregatesFilter? userId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (tenantId != null) {
      predicates.addAll(tenantId!.toPredicates('tenantId'));
    }
    if (userId != null) {
      predicates.addAll(userId!.toPredicates('userId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class MembershipCountAggregateOrderByInput {
  const MembershipCountAggregateOrderByInput({
    this.all,
    this.tenantId,
    this.slug,
    this.userId,
  });

  final SortOrder? all;
  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (all != null) {
      orderings.add(
        GroupByOrderBy.aggregate(aggregate: function, direction: all!),
      );
    }
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'tenantId',
          direction: tenantId!,
        ),
      );
    }
    if (slug != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'slug',
          direction: slug!,
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

class MembershipAvgAggregateOrderByInput {
  const MembershipAvgAggregateOrderByInput({this.tenantId, this.userId});

  final SortOrder? tenantId;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'tenantId',
          direction: tenantId!,
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

class MembershipSumAggregateOrderByInput {
  const MembershipSumAggregateOrderByInput({this.tenantId, this.userId});

  final SortOrder? tenantId;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'tenantId',
          direction: tenantId!,
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

class MembershipMinAggregateOrderByInput {
  const MembershipMinAggregateOrderByInput({
    this.tenantId,
    this.slug,
    this.userId,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'tenantId',
          direction: tenantId!,
        ),
      );
    }
    if (slug != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'slug',
          direction: slug!,
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

class MembershipMaxAggregateOrderByInput {
  const MembershipMaxAggregateOrderByInput({
    this.tenantId,
    this.slug,
    this.userId,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'tenantId',
          direction: tenantId!,
        ),
      );
    }
    if (slug != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'slug',
          direction: slug!,
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

class MembershipGroupByOrderByInput {
  const MembershipGroupByOrderByInput({
    this.tenantId,
    this.slug,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? userId;
  final MembershipCountAggregateOrderByInput? count;
  final MembershipAvgAggregateOrderByInput? avg;
  final MembershipSumAggregateOrderByInput? sum;
  final MembershipMinAggregateOrderByInput? min;
  final MembershipMaxAggregateOrderByInput? max;

  List<GroupByOrderBy> toGroupByOrderBy() {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'tenantId', direction: tenantId!),
      );
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.field(field: 'slug', direction: slug!));
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

class MembershipGroupByRow {
  const MembershipGroupByRow({
    this.tenantId,
    this.slug,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? tenantId;
  final String? slug;
  final int? userId;
  final MembershipCountAggregateResult? count;
  final MembershipAvgAggregateResult? avg;
  final MembershipSumAggregateResult? sum;
  final MembershipMinAggregateResult? min;
  final MembershipMaxAggregateResult? max;

  factory MembershipGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return MembershipGroupByRow(
      tenantId: row.group['tenantId'] as int?,
      slug: row.group['slug'] as String?,
      userId: row.group['userId'] as int?,
      count: row.aggregates.count == null
          ? null
          : MembershipCountAggregateResult.fromQueryCountResult(
              row.aggregates.count!,
            ),
      avg: row.aggregates.avg == null
          ? null
          : MembershipAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null
          ? null
          : MembershipSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null
          ? null
          : MembershipMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null
          ? null
          : MembershipMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class MembershipInclude {
  const MembershipInclude({this.user = false});

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

class MembershipSelect {
  const MembershipSelect({
    this.tenantId = false,
    this.slug = false,
    this.userId = false,
  });

  final bool tenantId;
  final bool slug;
  final bool userId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
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

class MembershipCreateInput {
  const MembershipCreateInput({
    required this.tenantId,
    required this.slug,
    required this.userId,
    this.user,
  });

  final int tenantId;
  final String slug;
  final int userId;
  final UserCreateNestedOneWithoutMembershipsInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    data['userId'] = userId;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<List<QueryPredicate>> toUniqueSelectorPredicates() {
    final selectors = <List<QueryPredicate>>[];
    selectors.add(<QueryPredicate>[
      QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
      QueryPredicate(field: 'slug', operator: 'equals', value: slug),
    ]);
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

  MembershipUpdateInput toDeferredRelationUpdateInput() {
    return MembershipUpdateInput(user: user?.toDeferredUpdateWrite());
  }
}

class MembershipUpdateInput {
  const MembershipUpdateInput({
    this.tenantId,
    this.tenantIdOps,
    this.slug,
    this.slugOps,
    this.userId,
    this.userIdOps,
    this.user,
  });

  final int? tenantId;
  final IntFieldUpdateOperationsInput? tenantIdOps;
  final String? slug;
  final StringFieldUpdateOperationsInput? slugOps;
  final int? userId;
  final IntFieldUpdateOperationsInput? userIdOps;
  final UserUpdateNestedOneWithoutMembershipsInput? user;

  bool get hasComputedOperators {
    return tenantIdOps?.hasComputedUpdate == true ||
        userIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return user?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError(
        'Only one of tenantId or tenantIdOps may be provided for MembershipUpdateInput.tenantId.',
      );
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for MembershipUpdateInput.tenantId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for MembershipUpdateInput.tenantId require the current record value before they can be converted to raw update data.',
        );
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      }
    }
    if (slug != null && slugOps != null) {
      throw StateError(
        'Only one of slug or slugOps may be provided for MembershipUpdateInput.slug.',
      );
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
    if (userId != null && userIdOps != null) {
      throw StateError(
        'Only one of userId or userIdOps may be provided for MembershipUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for MembershipUpdateInput.userId.',
        );
      }
      if (ops.hasComputedUpdate) {
        throw StateError(
          'Computed scalar update operators for MembershipUpdateInput.userId require the current record value before they can be converted to raw update data.',
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
    if (tenantId != null && tenantIdOps != null) {
      throw StateError(
        'Only one of tenantId or tenantIdOps may be provided for MembershipUpdateInput.tenantId.',
      );
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for MembershipUpdateInput.tenantId.',
        );
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      } else {
        final currentValue = record['tenantId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment MembershipUpdateInput.tenantId because the current value is null.',
            );
          }
          data['tenantId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement MembershipUpdateInput.tenantId because the current value is null.',
            );
          }
          data['tenantId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (slug != null && slugOps != null) {
      throw StateError(
        'Only one of slug or slugOps may be provided for MembershipUpdateInput.slug.',
      );
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
    if (userId != null && userIdOps != null) {
      throw StateError(
        'Only one of userId or userIdOps may be provided for MembershipUpdateInput.userId.',
      );
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    if (userIdOps != null) {
      final ops = userIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError(
          'Only one scalar update operator may be provided for MembershipUpdateInput.userId.',
        );
      }
      if (ops.hasSet) {
        data['userId'] = ops.set as int?;
      } else {
        final currentValue = record['userId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot increment MembershipUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError(
              'Cannot decrement MembershipUpdateInput.userId because the current value is null.',
            );
          }
          data['userId'] = currentValue - ops.decrement!;
        }
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class MembershipCreateWithoutUserInput {
  const MembershipCreateWithoutUserInput({
    required this.tenantId,
    required this.slug,
  });

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

class UserConnectOrCreateWithoutMembershipsInput {
  const UserConnectOrCreateWithoutMembershipsInput({
    required this.where,
    required this.create,
  });

  final UserWhereUniqueInput where;
  final UserCreateWithoutMembershipsInput create;
}

class UserCreateNestedOneWithoutMembershipsInput {
  const UserCreateNestedOneWithoutMembershipsInput({
    this.create,
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserCreateWithoutMembershipsInput? create;
  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutMembershipsInput? connectOrCreate;
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
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutMembershipsInput.',
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

  UserUpdateNestedOneWithoutMembershipsInput? toDeferredUpdateWrite() {
    final nestedWriteCount =
        (create != null ? 1 : 0) +
        (connect != null ? 1 : 0) +
        (connectOrCreate != null ? 1 : 0) +
        (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError(
        'Only one of create, connect, connectOrCreate or disconnect may be provided for UserCreateNestedOneWithoutMembershipsInput.',
      );
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return UserUpdateNestedOneWithoutMembershipsInput(
      connect: connect,
      connectOrCreate: connectOrCreate,
      disconnect: disconnect,
    );
  }
}

class UserUpdateNestedOneWithoutMembershipsInput {
  const UserUpdateNestedOneWithoutMembershipsInput({
    this.connect,
    this.connectOrCreate,
    this.disconnect = false,
  });

  final UserWhereUniqueInput? connect;
  final UserConnectOrCreateWithoutMembershipsInput? connectOrCreate;
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
