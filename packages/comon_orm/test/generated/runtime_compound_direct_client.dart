// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
// schema-hash: 27a604ee617dacfb6749ecd0d4c461eb16563f81b9be73a7f495c0a0f8053f26
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
  late final AccountDelegate account = AccountDelegate._(_client);
  late final SessionDelegate session = SessionDelegate._(_client);
  late final ProfileDelegate profile = ProfileDelegate._(_client);

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
            name: 'sessions',
            databaseName: 'sessions',
            kind: GeneratedRuntimeFieldKind.relation,
            type: 'Session',
            isNullable: false,
            isList: true,
            isId: false,
            isUnique: false,
            isUpdatedAt: false,
            relation: GeneratedRelationMetadata(
            targetModel: 'Session',
            cardinality: GeneratedRuntimeRelationCardinality.many,
            storageKind: GeneratedRuntimeRelationStorageKind.direct,
            localFields: <String>['tenantId', 'slug'],
            targetFields: <String>['tenantId', 'accountSlug'],
            inverseField: 'account',
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
            localFields: <String>['tenantId', 'slug'],
            targetFields: <String>['tenantId', 'accountSlug'],
            inverseField: 'account',
          ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Session',
        databaseName: 'Session',
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
            name: 'label',
            databaseName: 'label',
            kind: GeneratedRuntimeFieldKind.scalar,
            type: 'String',
            isNullable: false,
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
            inverseField: 'sessions',
          ),
          ),
        ],
      ),
      GeneratedModelMetadata(
        name: 'Profile',
        databaseName: 'Profile',
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
            isNullable: true,
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
            isNullable: true,
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
            isNullable: true,
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

class Account {
  const Account({this.tenantId, this.slug, this.name, this.sessions, this.profile, });

  final int? tenantId;
  final String? slug;
  final String? name;
  final List<Session>? sessions;
  final Profile? profile;

  factory Account.fromRecord(Map<String, Object?> record) {
    return Account(
      tenantId: record['tenantId'] as int?,
      slug: record['slug'] as String?,
      name: record['name'] as String?,
      sessions: (record['sessions'] as List<Object?>?)?.map((item) => Session.fromRecord(item as Map<String, Object?>)).toList(growable: false),
      profile: record['profile'] == null ? null : Profile.fromRecord(record['profile'] as Map<String, Object?>),
    );
  }

  factory Account.fromJson(Map<String, Object?> json) {
    return Account(
      tenantId: json['tenantId'] as int?,
      slug: json['slug'] as String?,
      name: json['name'] as String?,
      sessions: (json['sessions'] as List<Object?>?)?.map((item) => Session.fromJson(item as Map<String, Object?>)).toList(growable: false),
      profile: json['profile'] == null ? null : Profile.fromJson(json['profile'] as Map<String, Object?>),
    );
  }

  Account copyWith({
    Object? tenantId = _undefined,
    Object? slug = _undefined,
    Object? name = _undefined,
    Object? sessions = _undefined,
    Object? profile = _undefined,
  }) {
    return Account(
      tenantId: tenantId == _undefined ? this.tenantId : tenantId as int?,
      slug: slug == _undefined ? this.slug : slug as String?,
      name: name == _undefined ? this.name : name as String?,
      sessions: sessions == _undefined ? this.sessions : sessions as List<Session>?,
      profile: profile == _undefined ? this.profile : profile as Profile?,
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
    if (name != null) {
      record['name'] = name;
    }
    if (sessions != null) {
      record['sessions'] = sessions!.map((item) => item.toRecord()).toList(growable: false);
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
    if (name != null) {
      json['name'] = name;
    }
    if (sessions != null) {
      json['sessions'] = sessions!.map((item) => item.toJson()).toList(growable: false);
    }
    if (profile != null) {
      json['profile'] = profile!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Account(tenantId: $tenantId, slug: $slug, name: $name, sessions: $sessions, profile: $profile)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Account &&
        _deepEquals(tenantId, other.tenantId) &&
        _deepEquals(slug, other.slug) &&
        _deepEquals(name, other.name) &&
        _deepEquals(sessions, other.sessions) &&
        _deepEquals(profile, other.profile);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(tenantId),
    _deepHash(slug),
    _deepHash(name),
    _deepHash(sessions),
    _deepHash(profile),
  ]);
}

class Session {
  const Session({this.id, this.tenantId, this.accountSlug, this.label, this.account, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? label;
  final Account? account;

  factory Session.fromRecord(Map<String, Object?> record) {
    return Session(
      id: record['id'] as int?,
      tenantId: record['tenantId'] as int?,
      accountSlug: record['accountSlug'] as String?,
      label: record['label'] as String?,
      account: record['account'] == null ? null : Account.fromRecord(record['account'] as Map<String, Object?>),
    );
  }

  factory Session.fromJson(Map<String, Object?> json) {
    return Session(
      id: json['id'] as int?,
      tenantId: json['tenantId'] as int?,
      accountSlug: json['accountSlug'] as String?,
      label: json['label'] as String?,
      account: json['account'] == null ? null : Account.fromJson(json['account'] as Map<String, Object?>),
    );
  }

  Session copyWith({
    Object? id = _undefined,
    Object? tenantId = _undefined,
    Object? accountSlug = _undefined,
    Object? label = _undefined,
    Object? account = _undefined,
  }) {
    return Session(
      id: id == _undefined ? this.id : id as int?,
      tenantId: tenantId == _undefined ? this.tenantId : tenantId as int?,
      accountSlug: accountSlug == _undefined ? this.accountSlug : accountSlug as String?,
      label: label == _undefined ? this.label : label as String?,
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
    if (label != null) {
      record['label'] = label;
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
    if (label != null) {
      json['label'] = label;
    }
    if (account != null) {
      json['account'] = account!.toJson();
    }
    return Map<String, Object?>.unmodifiable(json);
  }

  @override
  String toString() => 'Session(id: $id, tenantId: $tenantId, accountSlug: $accountSlug, label: $label, account: $account)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Session &&
        _deepEquals(id, other.id) &&
        _deepEquals(tenantId, other.tenantId) &&
        _deepEquals(accountSlug, other.accountSlug) &&
        _deepEquals(label, other.label) &&
        _deepEquals(account, other.account);
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    runtimeType,
    _deepHash(id),
    _deepHash(tenantId),
    _deepHash(accountSlug),
    _deepHash(label),
    _deepHash(account),
  ]);
}

class Profile {
  const Profile({this.id, this.tenantId, this.accountSlug, this.bio, this.account, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;
  final Account? account;

  factory Profile.fromRecord(Map<String, Object?> record) {
    return Profile(
      id: record['id'] as int?,
      tenantId: record['tenantId'] as int?,
      accountSlug: record['accountSlug'] as String?,
      bio: record['bio'] as String?,
      account: record['account'] == null ? null : Account.fromRecord(record['account'] as Map<String, Object?>),
    );
  }

  factory Profile.fromJson(Map<String, Object?> json) {
    return Profile(
      id: json['id'] as int?,
      tenantId: json['tenantId'] as int?,
      accountSlug: json['accountSlug'] as String?,
      bio: json['bio'] as String?,
      account: json['account'] == null ? null : Account.fromJson(json['account'] as Map<String, Object?>),
    );
  }

  Profile copyWith({
    Object? id = _undefined,
    Object? tenantId = _undefined,
    Object? accountSlug = _undefined,
    Object? bio = _undefined,
    Object? account = _undefined,
  }) {
    return Profile(
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
  String toString() => 'Profile(id: $id, tenantId: $tenantId, accountSlug: $accountSlug, bio: $bio, account: $account)';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Profile &&
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
    if (data.sessions == null) {
      // No nested writes for sessions.
    } else {
      final nested = data.sessions!;
      final parentReferenceValues = <String, Object?>{
        'tenantId': _requireRecordValue(existing, 'tenantId', 'nested direct relation write on Account.sessions'),
        'accountSlug': _requireRecordValue(existing, 'slug', 'nested direct relation write on Account.sessions'),
      };
      if (nested.set != null && (nested.connect.isNotEmpty || nested.disconnect.isNotEmpty || nested.connectOrCreate.isNotEmpty)) {
        throw StateError('Only set or connect/disconnect/connectOrCreate may be provided for AccountUpdateInput.sessions.');
      }
      final currentRelatedRecords = await tx.session._delegate.findMany(
        FindManyQuery(
          model: 'Session',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
            QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
          ],
        ),
      );
      if (nested.set != null) {
        final targetRecords = <Map<String, Object?>>[];
        for (final selector in nested.set!) {
          final related = await tx.session._delegate.findUnique(
            FindUniqueQuery(
              model: 'Session',
              where: selector.toPredicates(),
            ),
          );
          if (related == null) {
            throw StateError('No related Session record found for nested set on Account.sessions.');
          }
          targetRecords.add(related);
        }
        for (final current in currentRelatedRecords) {
          final stillIncluded = targetRecords.any((target) {
            return current['id'] == target['id']
          ;
          });
          if (!stillIncluded) {
            throw StateError('Nested set is not supported for required relation Account.sessions when it would disconnect already attached required related records.');
          }
        }
        for (final related in targetRecords) {
          await tx.session._delegate.update(
            UpdateQuery(
              model: 'Session',
              where: tx.session._primaryKeyWhereUniqueFromRecord(related).toPredicates(),
              data: <String, Object?>{
                'tenantId': parentReferenceValues['tenantId'],
                'accountSlug': parentReferenceValues['accountSlug'],
              },
            ),
          );
        }
      }
      for (final selector in nested.connect) {
        await tx.session._delegate.update(
          UpdateQuery(
            model: 'Session',
            where: selector.toPredicates(),
            data: <String, Object?>{
              'tenantId': parentReferenceValues['tenantId'],
              'accountSlug': parentReferenceValues['accountSlug'],
            },
          ),
        );
      }
      for (final entry in nested.connectOrCreate) {
        final related = await tx.session._delegate.findUnique(
          FindUniqueQuery(
            model: 'Session',
            where: entry.where.toPredicates(),
          ),
        );
        if (related == null) {
          await tx.session._delegate.create(
            CreateQuery(
              model: 'Session',
              data: <String, Object?>{...entry.create.toData(),
                'tenantId': parentReferenceValues['tenantId'],
                'accountSlug': parentReferenceValues['accountSlug'],
              },
              nestedCreates: entry.create.toNestedCreates(),
            ),
          );
        } else {
          await tx.session._delegate.update(
            UpdateQuery(
              model: 'Session',
              where: entry.where.toPredicates(),
              data: <String, Object?>{
                'tenantId': parentReferenceValues['tenantId'],
                'accountSlug': parentReferenceValues['accountSlug'],
              },
            ),
          );
        }
      }
      for (final selector in nested.disconnect) {
        final related = await tx.session._delegate.findUnique(
          FindUniqueQuery(
            model: 'Session',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related Session record found for nested disconnect on Account.sessions.');
        }
        final isCurrentlyAttached = currentRelatedRecords.any((current) {
          return current['id'] == related['id']
        ;
        });
        if (isCurrentlyAttached) {
          throw StateError('Nested disconnect is not supported for required relation Account.sessions when it would disconnect already attached required related records.');
        }
      }
    }
    if (data.profile == null) {
      // No nested writes for profile.
    } else {
      final nested = data.profile!;
      final parentReferenceValues = <String, Object?>{
        'tenantId': _requireRecordValue(existing, 'tenantId', 'nested inverse one-to-one relation write on Account.profile'),
        'accountSlug': _requireRecordValue(existing, 'slug', 'nested inverse one-to-one relation write on Account.profile'),
      };
      final currentRelated = await tx.profile._delegate.findFirst(
        FindFirstQuery(
          model: 'Profile',
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
        final related = await tx.profile._delegate.findUnique(
          FindUniqueQuery(
            model: 'Profile',
            where: selector.toPredicates(),
          ),
        );
        if (related == null) {
          throw StateError('No related Profile record found for nested connect on inverse one-to-one relation Account.profile.');
        }
        final alreadyConnected =
            related['tenantId'] == parentReferenceValues['tenantId']
            && related['accountSlug'] == parentReferenceValues['accountSlug']
        ;
        if (!alreadyConnected) {
          if (currentRelated != null) {
            await tx.profile._delegate.updateMany(
              UpdateManyQuery(
                model: 'Profile',
                where: <QueryPredicate>[
                  QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
                  QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
                ],
                data: <String, Object?>{
                  'tenantId': null,
                  'accountSlug': null,
                },
              ),
            );
          }
          await tx.profile._delegate.update(
            UpdateQuery(
              model: 'Profile',
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
        final related = await tx.profile._delegate.findUnique(
          FindUniqueQuery(
            model: 'Profile',
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
              await tx.profile._delegate.updateMany(
                UpdateManyQuery(
                  model: 'Profile',
                  where: <QueryPredicate>[
                    QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
                    QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
                  ],
                  data: <String, Object?>{
                    'tenantId': null,
                    'accountSlug': null,
                  },
                ),
              );
            }
            await tx.profile._delegate.update(
              UpdateQuery(
                model: 'Profile',
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
            await tx.profile._delegate.updateMany(
              UpdateManyQuery(
                model: 'Profile',
                where: <QueryPredicate>[
                  QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
                  QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
                ],
                data: <String, Object?>{
                  'tenantId': null,
                  'accountSlug': null,
                },
              ),
            );
          }
          await tx.profile._delegate.create(
            CreateQuery(
              model: 'Profile',
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
        await tx.profile._delegate.updateMany(
          UpdateManyQuery(
            model: 'Profile',
            where: <QueryPredicate>[
              QueryPredicate(field: 'tenantId', operator: 'equals', value: parentReferenceValues['tenantId']),
              QueryPredicate(field: 'accountSlug', operator: 'equals', value: parentReferenceValues['accountSlug']),
            ],
            data: <String, Object?>{
              'tenantId': null,
              'accountSlug': null,
            },
          ),
        );
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
  const AccountWhereInput({this.AND = const <AccountWhereInput>[], this.OR = const <AccountWhereInput>[], this.NOT = const <AccountWhereInput>[], this.tenantId, this.tenantIdFilter, this.slug, this.slugFilter, this.name, this.nameFilter, this.sessionsSome, this.sessionsNone, this.sessionsEvery, this.profileIs, this.profileIsNot, });

  final List<AccountWhereInput> AND;
  final List<AccountWhereInput> OR;
  final List<AccountWhereInput> NOT;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? slug;
  final StringFilter? slugFilter;
  final String? name;
  final StringFilter? nameFilter;
  final SessionWhereInput? sessionsSome;
  final SessionWhereInput? sessionsNone;
  final SessionWhereInput? sessionsEvery;
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
    if (name != null) {
      predicates.add(QueryPredicate(field: 'name', operator: 'equals', value: name));
    }
    if (nameFilter != null) {
      predicates.addAll(nameFilter!.toPredicates('name'));
    }
    if (sessionsSome != null) {
      predicates.add(QueryPredicate(field: 'sessions', operator: 'relationSome', value: QueryRelationFilter(relation: QueryRelation(field: 'sessions', targetModel: 'Session', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: sessionsSome!.toPredicates())));
    }
    if (sessionsNone != null) {
      predicates.add(QueryPredicate(field: 'sessions', operator: 'relationNone', value: QueryRelationFilter(relation: QueryRelation(field: 'sessions', targetModel: 'Session', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: sessionsNone!.toPredicates())));
    }
    if (sessionsEvery != null) {
      predicates.add(QueryPredicate(field: 'sessions', operator: 'relationEvery', value: QueryRelationFilter(relation: QueryRelation(field: 'sessions', targetModel: 'Session', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: sessionsEvery!.toPredicates())));
    }
    if (profileIs != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: profileIs!.toPredicates())));
    }
    if (profileIsNot != null) {
      predicates.add(QueryPredicate(field: 'profile', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']), predicates: profileIsNot!.toPredicates())));
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
  const AccountOrderByInput({this.tenantId, this.slug, this.name, });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? name;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (tenantId != null) {
      orderings.add(QueryOrderBy(field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(QueryOrderBy(field: 'slug', direction: slug!));
    }
    if (name != null) {
      orderings.add(QueryOrderBy(field: 'name', direction: name!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum AccountScalarField {
  tenantId,
  slug,
  name
}

class AccountCountAggregateInput {
  const AccountCountAggregateInput({this.all = false, this.tenantId = false, this.slug = false, this.name = false, });

  final bool all;
  final bool tenantId;
  final bool slug;
  final bool name;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (name) {
      fields.add('name');
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
  const AccountMinAggregateInput({this.tenantId = false, this.slug = false, this.name = false, });

  final bool tenantId;
  final bool slug;
  final bool name;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (name) {
      fields.add('name');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountMaxAggregateInput {
  const AccountMaxAggregateInput({this.tenantId = false, this.slug = false, this.name = false, });

  final bool tenantId;
  final bool slug;
  final bool name;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (name) {
      fields.add('name');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class AccountCountAggregateResult {
  const AccountCountAggregateResult({this.all, this.tenantId, this.slug, this.name, });

  final int? all;
  final int? tenantId;
  final int? slug;
  final int? name;

  factory AccountCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return AccountCountAggregateResult(
      all: result.all,
      tenantId: result.fields['tenantId'],
      slug: result.fields['slug'],
      name: result.fields['name'],
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
  const AccountMinAggregateResult({this.tenantId, this.slug, this.name, });

  final int? tenantId;
  final String? slug;
  final String? name;

  factory AccountMinAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountMinAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      name: values['name'] as String?,
    );
  }
}

class AccountMaxAggregateResult {
  const AccountMaxAggregateResult({this.tenantId, this.slug, this.name, });

  final int? tenantId;
  final String? slug;
  final String? name;

  factory AccountMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return AccountMaxAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      name: values['name'] as String?,
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
  const AccountCountAggregateOrderByInput({this.all, this.tenantId, this.slug, this.name, });

  final SortOrder? all;
  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? name;

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
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
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
  const AccountMinAggregateOrderByInput({this.tenantId, this.slug, this.name, });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? name;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'slug', direction: slug!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountMaxAggregateOrderByInput {
  const AccountMaxAggregateOrderByInput({this.tenantId, this.slug, this.name, });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? name;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (tenantId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'slug', direction: slug!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class AccountGroupByOrderByInput {
  const AccountGroupByOrderByInput({this.tenantId, this.slug, this.name, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? name;
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

class AccountGroupByRow {
  const AccountGroupByRow({this.tenantId, this.slug, this.name, this.count, this.avg, this.sum, this.min, this.max});

  final int? tenantId;
  final String? slug;
  final String? name;
  final AccountCountAggregateResult? count;
  final AccountAvgAggregateResult? avg;
  final AccountSumAggregateResult? sum;
  final AccountMinAggregateResult? min;
  final AccountMaxAggregateResult? max;

  factory AccountGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return AccountGroupByRow(
      tenantId: row.group['tenantId'] as int?,
      slug: row.group['slug'] as String?,
      name: row.group['name'] as String?,
      count: row.aggregates.count == null ? null : AccountCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : AccountAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : AccountSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : AccountMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : AccountMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class AccountInclude {
  const AccountInclude({this.sessions = false, this.profile = false, });

  final bool sessions;
  final bool profile;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (sessions) {
      relations['sessions'] = QueryIncludeEntry(relation: QueryRelation(field: 'sessions', targetModel: 'Session', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']));
    }
    if (profile) {
      relations['profile'] = QueryIncludeEntry(relation: QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug']));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class AccountSelect {
  const AccountSelect({this.tenantId = false, this.slug = false, this.name = false, });

  final bool tenantId;
  final bool slug;
  final bool name;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
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

class AccountCreateInput {
  const AccountCreateInput({required this.tenantId, required this.slug, required this.name, this.sessions, this.profile, });

  final int tenantId;
  final String slug;
  final String name;
  final SessionCreateNestedManyWithoutAccountInput? sessions;
  final ProfileCreateNestedOneWithoutAccountInput? profile;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    data['name'] = name;
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
    if (sessions != null) {
      writes.addAll(sessions!.toRelationWrites(QueryRelation(field: 'sessions', targetModel: 'Session', cardinality: QueryRelationCardinality.many, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug'])));
    }
    if (profile != null) {
      writes.addAll(profile!.toRelationWrites(QueryRelation(field: 'profile', targetModel: 'Profile', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'slug'], targetKeyFields: const <String>['tenantId', 'accountSlug'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (sessions?.hasDeferredWrites ?? false) || (profile?.hasDeferredWrites ?? false);
  }

  AccountUpdateInput toDeferredRelationUpdateInput() {
    return AccountUpdateInput(
      sessions: sessions?.toDeferredUpdateWrite(),
      profile: profile?.toDeferredUpdateWrite(),
    );
  }
}

class AccountUpdateInput {
  const AccountUpdateInput({this.tenantId, this.tenantIdOps, this.slug, this.slugOps, this.name, this.nameOps, this.sessions, this.profile, });

  final int? tenantId;
  final IntFieldUpdateOperationsInput? tenantIdOps;
  final String? slug;
  final StringFieldUpdateOperationsInput? slugOps;
  final String? name;
  final StringFieldUpdateOperationsInput? nameOps;
  final SessionUpdateNestedManyWithoutAccountInput? sessions;
  final ProfileUpdateNestedOneWithoutAccountInput? profile;

  bool get hasComputedOperators {
    return tenantIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return sessions?.hasWrites == true || profile?.hasWrites == true;
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
    if (name != null && nameOps != null) {
      throw StateError('Only one of name or nameOps may be provided for AccountUpdateInput.name.');
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
    if (name != null && nameOps != null) {
      throw StateError('Only one of name or nameOps may be provided for AccountUpdateInput.name.');
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

class AccountCreateWithoutSessionsInput {
  const AccountCreateWithoutSessionsInput({required this.tenantId, required this.slug, required this.name, });

  final int tenantId;
  final String slug;
  final String name;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    data['name'] = name;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class AccountCreateWithoutProfileInput {
  const AccountCreateWithoutProfileInput({required this.tenantId, required this.slug, required this.name, });

  final int tenantId;
  final String slug;
  final String name;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    data['name'] = name;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class SessionConnectOrCreateWithoutAccountInput {
  const SessionConnectOrCreateWithoutAccountInput({required this.where, required this.create});

  final SessionWhereUniqueInput where;
  final SessionCreateWithoutAccountInput create;
}

class ProfileConnectOrCreateWithoutAccountInput {
  const ProfileConnectOrCreateWithoutAccountInput({required this.where, required this.create});

  final ProfileWhereUniqueInput where;
  final ProfileCreateWithoutAccountInput create;
}

class SessionCreateNestedManyWithoutAccountInput {
  const SessionCreateNestedManyWithoutAccountInput({this.create = const <SessionCreateWithoutAccountInput>[], this.connect = const <SessionWhereUniqueInput>[], this.disconnect = const <SessionWhereUniqueInput>[], this.connectOrCreate = const <SessionConnectOrCreateWithoutAccountInput>[], this.set});

  final List<SessionCreateWithoutAccountInput> create;
  final List<SessionWhereUniqueInput> connect;
  final List<SessionWhereUniqueInput> disconnect;
  final List<SessionConnectOrCreateWithoutAccountInput> connectOrCreate;
  final List<SessionWhereUniqueInput>? set;

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

  SessionUpdateNestedManyWithoutAccountInput? toDeferredUpdateWrite() {
    if (!hasDeferredWrites) {
      return null;
    }
    return SessionUpdateNestedManyWithoutAccountInput(connect: connect, disconnect: disconnect, connectOrCreate: connectOrCreate, set: set);
  }
}

class ProfileCreateNestedOneWithoutAccountInput {
  const ProfileCreateNestedOneWithoutAccountInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final ProfileCreateWithoutAccountInput? create;
  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutAccountInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutAccountInput.');
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

  ProfileUpdateNestedOneWithoutAccountInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for ProfileCreateNestedOneWithoutAccountInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return ProfileUpdateNestedOneWithoutAccountInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class SessionUpdateNestedManyWithoutAccountInput {
  const SessionUpdateNestedManyWithoutAccountInput({this.connect = const <SessionWhereUniqueInput>[], this.disconnect = const <SessionWhereUniqueInput>[], this.connectOrCreate = const <SessionConnectOrCreateWithoutAccountInput>[], this.set});

  final List<SessionWhereUniqueInput> connect;
  final List<SessionWhereUniqueInput> disconnect;
  final List<SessionConnectOrCreateWithoutAccountInput> connectOrCreate;
  final List<SessionWhereUniqueInput>? set;

  bool get hasWrites => connect.isNotEmpty || disconnect.isNotEmpty || connectOrCreate.isNotEmpty || set != null;
}

class ProfileUpdateNestedOneWithoutAccountInput {
  const ProfileUpdateNestedOneWithoutAccountInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final ProfileWhereUniqueInput? connect;
  final ProfileConnectOrCreateWithoutAccountInput? connectOrCreate;
  final bool disconnect;

  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;
}

class SessionDelegate {
  const SessionDelegate._(this._client);

  final ComonOrmClient _client;
  ModelDelegate get _delegate => _client.model('Session');

  Future<Session?> findUnique({
    required SessionWhereUniqueInput where,
    SessionInclude? include,
    SessionSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'Session',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : Session.fromRecord(record));
  }

  Future<Session?> findFirst({
    SessionWhereInput? where,
    SessionWhereUniqueInput? cursor,
    List<SessionOrderByInput>? orderBy,
    List<SessionScalarField>? distinct,
    SessionInclude? include,
    SessionSelect? select,
    int? skip,
  }) async {
    final predicates = where?.toPredicates() ?? const <QueryPredicate>[];
    final queryOrderBy = orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[];
    final queryDistinct = distinct?.map((field) => field.name).toSet() ?? const <String>{};
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'Session',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
      ),
    ).then((record) => record == null ? null : Session.fromRecord(record));
  }

  Future<List<Session>> findMany({
    SessionWhereInput? where,
    SessionWhereUniqueInput? cursor,
    List<SessionOrderByInput>? orderBy,
    List<SessionScalarField>? distinct,
    SessionInclude? include,
    SessionSelect? select,
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
        model: 'Session',
        where: predicates,
        cursor: cursor?.toQueryCursor(),
        orderBy: queryOrderBy,
        distinct: queryDistinct,
        include: queryInclude,
        select: querySelect,
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(Session.fromRecord).toList(growable: false));
  }

  Future<int> count({SessionWhereInput? where}) {
    return _delegate.count(
      CountQuery(
        model: 'Session',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
      ),
    );
  }

  Future<SessionAggregateResult> aggregate({
    SessionWhereInput? where,
    List<SessionOrderByInput>? orderBy,
    int? skip,
    int? take,
    SessionCountAggregateInput? count,
    SessionAvgAggregateInput? avg,
    SessionSumAggregateInput? sum,
    SessionMinAggregateInput? min,
    SessionMaxAggregateInput? max,
  }) {
    return _delegate.aggregate(
      AggregateQuery(
        model: 'Session',
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
    ).then(SessionAggregateResult.fromQueryResult);
  }

  Future<List<SessionGroupByRow>> groupBy({
    required List<SessionScalarField> by,
    SessionWhereInput? where,
    List<SessionGroupByOrderByInput>? orderBy,
    SessionGroupByHavingInput? having,
    int? skip,
    int? take,
    SessionCountAggregateInput? count,
    SessionAvgAggregateInput? avg,
    SessionSumAggregateInput? sum,
    SessionMinAggregateInput? min,
    SessionMaxAggregateInput? max,
  }) {
    return _delegate.groupBy(
      GroupByQuery(
        model: 'Session',
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
    ).then((rows) => rows.map(SessionGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<Session> create({
    required SessionCreateInput data,
    SessionInclude? include,
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
    required List<SessionCreateInput> data,
    bool skipDuplicates = false,
  }) {
    if (data.isEmpty) {
      return Future<int>.value(0);
    }
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Session');
      var createdCount = 0;
      for (final entry in data) {
        if (skipDuplicates) {
          var duplicateFound = false;
          for (final selector in entry.toUniqueSelectorPredicates()) {
            final existing = await txDelegate.findUnique(
              FindUniqueQuery(
                model: 'Session',
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
                model: 'Session',
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

  Future<Session> update({
    required SessionWhereUniqueInput where,
    required SessionUpdateInput data,
    SessionInclude? include,
    SessionSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Session');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Session',
          where: predicates,
        ),
      );
      if (existing == null) {
        throw StateError('No record found for update in Session.');
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

  Future<Session> upsert({
    required SessionWhereUniqueInput where,
    required SessionCreateInput create,
    required SessionUpdateInput update,
    SessionInclude? include,
    SessionSelect? select,
  }) {
    final predicates = where.toPredicates();
    final queryInclude = include?.toQueryInclude();
    final querySelect = select?.toQuerySelect();
    return _client.transaction((txClient) async {
      final tx = GeneratedComonOrmClient._fromClient(txClient);
      final txDelegate = tx._client.model('Session');
      final existing = await txDelegate.findUnique(
        FindUniqueQuery(
          model: 'Session',
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
    required SessionWhereInput where,
    required SessionUpdateInput data,
  }) {
    final predicates = where.toPredicates();
    if (data.hasComputedOperators || data.hasRelationWrites) {
      return _client.transaction((txClient) async {
        final tx = GeneratedComonOrmClient._fromClient(txClient);
        final txDelegate = tx._client.model('Session');
        final existingRecords = await txDelegate.findMany(
          FindManyQuery(
            model: 'Session',
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
        model: 'Session',
        where: predicates,
        data: data.toData(),
      ),
    );
  }

  Future<Session> _performCreateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required SessionCreateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Session');
    final created = await txDelegate.create(
      CreateQuery(
        model: 'Session',
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
      return Session.fromRecord(created);
    }
    final projected = await txDelegate.findUnique(
      FindUniqueQuery(
        model: 'Session',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Session create branch could not reload the created record by primary key.');
    }
    return Session.fromRecord(projected);
  }

  SessionWhereUniqueInput _primaryKeyWhereUniqueFromRecord(
    Map<String, Object?> record,
  ) {
    return SessionWhereUniqueInput(id: (record['id'] as int?)!);
  }

  Future<Session> _performUpdateWithRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required SessionUpdateInput data,
    QueryInclude? include,
    QuerySelect? select,
  }) async {
    final txDelegate = tx._client.model('Session');
    await txDelegate.update(
      UpdateQuery(
        model: 'Session',
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
        model: 'Session',
        where: predicates,
        include: include,
        select: select,
      ),
    );
    if (projected == null) {
      throw StateError('Session update branch could not reload the updated record for the provided unique selector.');
    }
    return Session.fromRecord(projected);
  }

  Future<void> _applyNestedRelationWrites({
    required GeneratedComonOrmClient tx,
    required List<QueryPredicate> predicates,
    required Map<String, Object?> existing,
    required SessionUpdateInput data,
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
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for SessionUpdateInput.account.');
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
          throw StateError('No related Account record found for nested connect on Session.account.');
        }
        await tx._client.model('Session').update(
          UpdateQuery(
            model: 'Session',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(related, 'tenantId', 'nested direct relation write on Session.account'),
              'accountSlug': _requireRecordValue(related, 'slug', 'nested direct relation write on Session.account'),
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
        await tx._client.model('Session').update(
          UpdateQuery(
            model: 'Session',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(relatedRecord, 'tenantId', 'nested direct relation write on Session.account'),
              'accountSlug': _requireRecordValue(relatedRecord, 'slug', 'nested direct relation write on Session.account'),
            },
          ),
        );
      }
      if (nested.disconnect) {
        throw StateError('Nested disconnect is not supported for required relation Session.account.');
      }
    }
  }


  Future<Session> delete({
    required SessionWhereUniqueInput where,
    SessionInclude? include,
    SessionSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'Session',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Session.fromRecord);
  }

  Future<int> deleteMany({
    required SessionWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'Session',
        where: where.toPredicates(),
      ),
    );
  }
}

class SessionWhereInput {
  const SessionWhereInput({this.AND = const <SessionWhereInput>[], this.OR = const <SessionWhereInput>[], this.NOT = const <SessionWhereInput>[], this.id, this.idFilter, this.tenantId, this.tenantIdFilter, this.accountSlug, this.accountSlugFilter, this.label, this.labelFilter, this.accountIs, this.accountIsNot, });

  final List<SessionWhereInput> AND;
  final List<SessionWhereInput> OR;
  final List<SessionWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? accountSlug;
  final StringFilter? accountSlugFilter;
  final String? label;
  final StringFilter? labelFilter;
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
    if (label != null) {
      predicates.add(QueryPredicate(field: 'label', operator: 'equals', value: label));
    }
    if (labelFilter != null) {
      predicates.addAll(labelFilter!.toPredicates('label'));
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

class SessionWhereUniqueInput {
  const SessionWhereUniqueInput({this.id, });

  final int? id;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for SessionWhereUniqueInput.');
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
      throw StateError('Exactly one unique selector must be provided for SessionWhereUniqueInput.');
    }
    return matches;
  }
}

class SessionOrderByInput {
  const SessionOrderByInput({this.id, this.tenantId, this.accountSlug, this.label, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? label;

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
    if (label != null) {
      orderings.add(QueryOrderBy(field: 'label', direction: label!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum SessionScalarField {
  id,
  tenantId,
  accountSlug,
  label
}

class SessionCountAggregateInput {
  const SessionCountAggregateInput({this.all = false, this.id = false, this.tenantId = false, this.accountSlug = false, this.label = false, });

  final bool all;
  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool label;

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
    if (label) {
      fields.add('label');
    }
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class SessionAvgAggregateInput {
  const SessionAvgAggregateInput({this.id = false, this.tenantId = false, });

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

class SessionSumAggregateInput {
  const SessionSumAggregateInput({this.id = false, this.tenantId = false, });

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

class SessionMinAggregateInput {
  const SessionMinAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.label = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool label;

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
    if (label) {
      fields.add('label');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class SessionMaxAggregateInput {
  const SessionMaxAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.label = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool label;

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
    if (label) {
      fields.add('label');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class SessionCountAggregateResult {
  const SessionCountAggregateResult({this.all, this.id, this.tenantId, this.accountSlug, this.label, });

  final int? all;
  final int? id;
  final int? tenantId;
  final int? accountSlug;
  final int? label;

  factory SessionCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return SessionCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      tenantId: result.fields['tenantId'],
      accountSlug: result.fields['accountSlug'],
      label: result.fields['label'],
    );
  }
}

class SessionAvgAggregateResult {
  const SessionAvgAggregateResult({this.id, this.tenantId, });

  final double? id;
  final double? tenantId;

  factory SessionAvgAggregateResult.fromMap(Map<String, double?> values) {
    return SessionAvgAggregateResult(
      id: _asDouble(values['id']),
      tenantId: _asDouble(values['tenantId']),
    );
  }
}

class SessionSumAggregateResult {
  const SessionSumAggregateResult({this.id, this.tenantId, });

  final int? id;
  final int? tenantId;

  factory SessionSumAggregateResult.fromMap(Map<String, num?> values) {
    return SessionSumAggregateResult(
      id: values['id']?.toInt(),
      tenantId: values['tenantId']?.toInt(),
    );
  }
}

class SessionMinAggregateResult {
  const SessionMinAggregateResult({this.id, this.tenantId, this.accountSlug, this.label, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? label;

  factory SessionMinAggregateResult.fromMap(Map<String, Object?> values) {
    return SessionMinAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
      label: values['label'] as String?,
    );
  }
}

class SessionMaxAggregateResult {
  const SessionMaxAggregateResult({this.id, this.tenantId, this.accountSlug, this.label, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? label;

  factory SessionMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return SessionMaxAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
      label: values['label'] as String?,
    );
  }
}

class SessionAggregateResult {
  const SessionAggregateResult({
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SessionCountAggregateResult? count;
  final SessionAvgAggregateResult? avg;
  final SessionSumAggregateResult? sum;
  final SessionMinAggregateResult? min;
  final SessionMaxAggregateResult? max;

  factory SessionAggregateResult.fromQueryResult(AggregateQueryResult result) {
    return SessionAggregateResult(
      count: result.count == null ? null : SessionCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : SessionAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : SessionSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : SessionMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : SessionMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class SessionGroupByHavingInput {
  const SessionGroupByHavingInput({this.id, this.tenantId, });

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

class SessionCountAggregateOrderByInput {
  const SessionCountAggregateOrderByInput({this.all, this.id, this.tenantId, this.accountSlug, this.label, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? label;

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
    if (label != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'label', direction: label!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class SessionAvgAggregateOrderByInput {
  const SessionAvgAggregateOrderByInput({this.id, this.tenantId, });

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

class SessionSumAggregateOrderByInput {
  const SessionSumAggregateOrderByInput({this.id, this.tenantId, });

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

class SessionMinAggregateOrderByInput {
  const SessionMinAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.label, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? label;

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
    if (label != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'label', direction: label!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class SessionMaxAggregateOrderByInput {
  const SessionMaxAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.label, });

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? label;

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
    if (label != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'label', direction: label!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class SessionGroupByOrderByInput {
  const SessionGroupByOrderByInput({this.id, this.tenantId, this.accountSlug, this.label, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
  final SortOrder? label;
  final SessionCountAggregateOrderByInput? count;
  final SessionAvgAggregateOrderByInput? avg;
  final SessionSumAggregateOrderByInput? sum;
  final SessionMinAggregateOrderByInput? min;
  final SessionMaxAggregateOrderByInput? max;

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
    if (label != null) {
      orderings.add(GroupByOrderBy.field(field: 'label', direction: label!));
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

class SessionGroupByRow {
  const SessionGroupByRow({this.id, this.tenantId, this.accountSlug, this.label, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? label;
  final SessionCountAggregateResult? count;
  final SessionAvgAggregateResult? avg;
  final SessionSumAggregateResult? sum;
  final SessionMinAggregateResult? min;
  final SessionMaxAggregateResult? max;

  factory SessionGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return SessionGroupByRow(
      id: row.group['id'] as int?,
      tenantId: row.group['tenantId'] as int?,
      accountSlug: row.group['accountSlug'] as String?,
      label: row.group['label'] as String?,
      count: row.aggregates.count == null ? null : SessionCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : SessionAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : SessionSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : SessionMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : SessionMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class SessionInclude {
  const SessionInclude({this.account = false, });

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

class SessionSelect {
  const SessionSelect({this.id = false, this.tenantId = false, this.accountSlug = false, this.label = false, });

  final bool id;
  final bool tenantId;
  final bool accountSlug;
  final bool label;

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
    if (label) {
      fields.add('label');
    }
    if (fields.isEmpty) {
      return null;
    }
    return QuerySelect(Set<String>.unmodifiable(fields));
  }
}

class SessionCreateInput {
  const SessionCreateInput({this.id, required this.tenantId, required this.accountSlug, required this.label, this.account, });

  final int? id;
  final int tenantId;
  final String accountSlug;
  final String label;
  final AccountCreateNestedOneWithoutSessionsInput? account;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['tenantId'] = tenantId;
    data['accountSlug'] = accountSlug;
    data['label'] = label;
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
    if (account != null) {
      writes.addAll(account!.toRelationWrites(QueryRelation(field: 'account', targetModel: 'Account', cardinality: QueryRelationCardinality.one, localKeyField: 'tenantId', targetKeyField: 'tenantId', localKeyFields: const <String>['tenantId', 'accountSlug'], targetKeyFields: const <String>['tenantId', 'slug'])));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }

  bool get hasDeferredRelationWrites {
    return (account?.hasDeferredWrites ?? false);
  }

  SessionUpdateInput toDeferredRelationUpdateInput() {
    return SessionUpdateInput(
      account: account?.toDeferredUpdateWrite(),
    );
  }
}

class SessionUpdateInput {
  const SessionUpdateInput({this.tenantId, this.tenantIdOps, this.accountSlug, this.accountSlugOps, this.label, this.labelOps, this.account, });

  final int? tenantId;
  final IntFieldUpdateOperationsInput? tenantIdOps;
  final String? accountSlug;
  final StringFieldUpdateOperationsInput? accountSlugOps;
  final String? label;
  final StringFieldUpdateOperationsInput? labelOps;
  final AccountUpdateNestedOneWithoutSessionsInput? account;

  bool get hasComputedOperators {
    return tenantIdOps?.hasComputedUpdate == true;
  }

  bool get hasRelationWrites {
    return account?.hasWrites == true;
  }

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for SessionUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for SessionUpdateInput.tenantId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for SessionUpdateInput.tenantId require the current record value before they can be converted to raw update data.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for SessionUpdateInput.accountSlug.');
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
    if (label != null && labelOps != null) {
      throw StateError('Only one of label or labelOps may be provided for SessionUpdateInput.label.');
    }
    if (label != null) {
      data['label'] = label;
    }
    if (labelOps != null) {
      final ops = labelOps!;
      if (ops.hasSet) {
        data['label'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {
    final data = <String, Object?>{};
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for SessionUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for SessionUpdateInput.tenantId.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      } else {
        final currentValue = record['tenantId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment SessionUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement SessionUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for SessionUpdateInput.accountSlug.');
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
    if (label != null && labelOps != null) {
      throw StateError('Only one of label or labelOps may be provided for SessionUpdateInput.label.');
    }
    if (label != null) {
      data['label'] = label;
    }
    if (labelOps != null) {
      final ops = labelOps!;
      if (ops.hasSet) {
        data['label'] = ops.set as String?;
      }
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class SessionCreateWithoutAccountInput {
  const SessionCreateWithoutAccountInput({this.id, required this.label, });

  final int? id;
  final String label;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['label'] = label;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class AccountConnectOrCreateWithoutSessionsInput {
  const AccountConnectOrCreateWithoutSessionsInput({required this.where, required this.create});

  final AccountWhereUniqueInput where;
  final AccountCreateWithoutSessionsInput create;
}

class AccountCreateNestedOneWithoutSessionsInput {
  const AccountCreateNestedOneWithoutSessionsInput({this.create, this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountCreateWithoutSessionsInput? create;
  final AccountWhereUniqueInput? connect;
  final AccountConnectOrCreateWithoutSessionsInput? connectOrCreate;
  final bool disconnect;

  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountCreateNestedOneWithoutSessionsInput.');
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

  AccountUpdateNestedOneWithoutSessionsInput? toDeferredUpdateWrite() {
    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);
    if (nestedWriteCount > 1) {
      throw StateError('Only one of create, connect, connectOrCreate or disconnect may be provided for AccountCreateNestedOneWithoutSessionsInput.');
    }
    if (!hasDeferredWrites) {
      return null;
    }
    return AccountUpdateNestedOneWithoutSessionsInput(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);
  }
}

class AccountUpdateNestedOneWithoutSessionsInput {
  const AccountUpdateNestedOneWithoutSessionsInput({this.connect, this.connectOrCreate, this.disconnect = false});

  final AccountWhereUniqueInput? connect;
  final AccountConnectOrCreateWithoutSessionsInput? connectOrCreate;
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
    if (data.account == null) {
      // No nested writes for account.
    } else {
      final nested = data.account!;
      final nestedWriteCount =
          (nested.connect != null ? 1 : 0) +
          (nested.connectOrCreate != null ? 1 : 0) +
          (nested.disconnect ? 1 : 0);
      if (nestedWriteCount > 1) {
        throw StateError('Only one of connect, connectOrCreate or disconnect may be provided for ProfileUpdateInput.account.');
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
          throw StateError('No related Account record found for nested connect on Profile.account.');
        }
        await tx._client.model('Profile').update(
          UpdateQuery(
            model: 'Profile',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(related, 'tenantId', 'nested direct relation write on Profile.account'),
              'accountSlug': _requireRecordValue(related, 'slug', 'nested direct relation write on Profile.account'),
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
        await tx._client.model('Profile').update(
          UpdateQuery(
            model: 'Profile',
            where: predicates,
            data: <String, Object?>{
              'tenantId': _requireRecordValue(relatedRecord, 'tenantId', 'nested direct relation write on Profile.account'),
              'accountSlug': _requireRecordValue(relatedRecord, 'slug', 'nested direct relation write on Profile.account'),
            },
          ),
        );
      }
      if (nested.disconnect) {
        await tx._client.model('Profile').update(
          UpdateQuery(
            model: 'Profile',
            where: predicates,
            data: <String, Object?>{
              'tenantId': null,
              'accountSlug': null,
            },
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
  const ProfileWhereInput({this.AND = const <ProfileWhereInput>[], this.OR = const <ProfileWhereInput>[], this.NOT = const <ProfileWhereInput>[], this.id, this.idFilter, this.tenantId, this.tenantIdFilter, this.accountSlug, this.accountSlugFilter, this.bio, this.bioFilter, this.accountIs, this.accountIsNot, });

  final List<ProfileWhereInput> AND;
  final List<ProfileWhereInput> OR;
  final List<ProfileWhereInput> NOT;
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

class ProfileTenantIdAccountSlugCompoundUniqueInput {
  const ProfileTenantIdAccountSlugCompoundUniqueInput({required this.tenantId, required this.accountSlug, });

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

class ProfileWhereUniqueInput {
  const ProfileWhereUniqueInput({this.id, this.tenantId_accountSlug, });

  final int? id;
  final ProfileTenantIdAccountSlugCompoundUniqueInput? tenantId_accountSlug;

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
    if (tenantId_accountSlug != null) {
      selectorCount++;
      matches = tenantId_accountSlug!.matchesRecord(record);
    }
    if (selectorCount != 1) {
      throw StateError('Exactly one unique selector must be provided for ProfileWhereUniqueInput.');
    }
    return matches;
  }
}

class ProfileOrderByInput {
  const ProfileOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

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

enum ProfileScalarField {
  id,
  tenantId,
  accountSlug,
  bio
}

class ProfileCountAggregateInput {
  const ProfileCountAggregateInput({this.all = false, this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

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

class ProfileAvgAggregateInput {
  const ProfileAvgAggregateInput({this.id = false, this.tenantId = false, });

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

class ProfileSumAggregateInput {
  const ProfileSumAggregateInput({this.id = false, this.tenantId = false, });

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

class ProfileMinAggregateInput {
  const ProfileMinAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

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

class ProfileMaxAggregateInput {
  const ProfileMaxAggregateInput({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

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

class ProfileCountAggregateResult {
  const ProfileCountAggregateResult({this.all, this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? all;
  final int? id;
  final int? tenantId;
  final int? accountSlug;
  final int? bio;

  factory ProfileCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return ProfileCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      tenantId: result.fields['tenantId'],
      accountSlug: result.fields['accountSlug'],
      bio: result.fields['bio'],
    );
  }
}

class ProfileAvgAggregateResult {
  const ProfileAvgAggregateResult({this.id, this.tenantId, });

  final double? id;
  final double? tenantId;

  factory ProfileAvgAggregateResult.fromMap(Map<String, double?> values) {
    return ProfileAvgAggregateResult(
      id: _asDouble(values['id']),
      tenantId: _asDouble(values['tenantId']),
    );
  }
}

class ProfileSumAggregateResult {
  const ProfileSumAggregateResult({this.id, this.tenantId, });

  final int? id;
  final int? tenantId;

  factory ProfileSumAggregateResult.fromMap(Map<String, num?> values) {
    return ProfileSumAggregateResult(
      id: values['id']?.toInt(),
      tenantId: values['tenantId']?.toInt(),
    );
  }
}

class ProfileMinAggregateResult {
  const ProfileMinAggregateResult({this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;

  factory ProfileMinAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMinAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
      bio: values['bio'] as String?,
    );
  }
}

class ProfileMaxAggregateResult {
  const ProfileMaxAggregateResult({this.id, this.tenantId, this.accountSlug, this.bio, });

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;

  factory ProfileMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return ProfileMaxAggregateResult(
      id: values['id'] as int?,
      tenantId: values['tenantId'] as int?,
      accountSlug: values['accountSlug'] as String?,
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
  const ProfileGroupByHavingInput({this.id, this.tenantId, });

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

class ProfileCountAggregateOrderByInput {
  const ProfileCountAggregateOrderByInput({this.all, this.id, this.tenantId, this.accountSlug, this.bio, });

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

class ProfileAvgAggregateOrderByInput {
  const ProfileAvgAggregateOrderByInput({this.id, this.tenantId, });

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

class ProfileSumAggregateOrderByInput {
  const ProfileSumAggregateOrderByInput({this.id, this.tenantId, });

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

class ProfileMinAggregateOrderByInput {
  const ProfileMinAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

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

class ProfileMaxAggregateOrderByInput {
  const ProfileMaxAggregateOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, });

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

class ProfileGroupByOrderByInput {
  const ProfileGroupByOrderByInput({this.id, this.tenantId, this.accountSlug, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final SortOrder? id;
  final SortOrder? tenantId;
  final SortOrder? accountSlug;
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

class ProfileGroupByRow {
  const ProfileGroupByRow({this.id, this.tenantId, this.accountSlug, this.bio, this.count, this.avg, this.sum, this.min, this.max});

  final int? id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;
  final ProfileCountAggregateResult? count;
  final ProfileAvgAggregateResult? avg;
  final ProfileSumAggregateResult? sum;
  final ProfileMinAggregateResult? min;
  final ProfileMaxAggregateResult? max;

  factory ProfileGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return ProfileGroupByRow(
      id: row.group['id'] as int?,
      tenantId: row.group['tenantId'] as int?,
      accountSlug: row.group['accountSlug'] as String?,
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
  const ProfileInclude({this.account = false, });

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

class ProfileSelect {
  const ProfileSelect({this.id = false, this.tenantId = false, this.accountSlug = false, this.bio = false, });

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

class ProfileCreateInput {
  const ProfileCreateInput({required this.id, this.tenantId, this.accountSlug, this.bio, this.account, });

  final int id;
  final int? tenantId;
  final String? accountSlug;
  final String? bio;
  final AccountCreateNestedOneWithoutProfileInput? account;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['id'] = id;
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (accountSlug != null) {
      data['accountSlug'] = accountSlug;
    }
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
    if (tenantId != null && accountSlug != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'tenantId', operator: 'equals', value: tenantId),
        QueryPredicate(field: 'accountSlug', operator: 'equals', value: accountSlug),
      ]);
    }
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

  ProfileUpdateInput toDeferredRelationUpdateInput() {
    return ProfileUpdateInput(
      account: account?.toDeferredUpdateWrite(),
    );
  }
}

class ProfileUpdateInput {
  const ProfileUpdateInput({this.tenantId, this.tenantIdOps, this.accountSlug, this.accountSlugOps, this.bio, this.bioOps, this.account, });

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
      throw StateError('Only one of tenantId or tenantIdOps may be provided for ProfileUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for ProfileUpdateInput.tenantId.');
      }
      if (ops.hasComputedUpdate) {
        throw StateError('Computed scalar update operators for ProfileUpdateInput.tenantId require the current record value before they can be converted to raw update data.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for ProfileUpdateInput.accountSlug.');
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
    if (tenantId != null && tenantIdOps != null) {
      throw StateError('Only one of tenantId or tenantIdOps may be provided for ProfileUpdateInput.tenantId.');
    }
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (tenantIdOps != null) {
      final ops = tenantIdOps!;
      if (ops.hasMultipleOperations) {
        throw StateError('Only one scalar update operator may be provided for ProfileUpdateInput.tenantId.');
      }
      if (ops.hasSet) {
        data['tenantId'] = ops.set as int?;
      } else {
        final currentValue = record['tenantId'] as int?;
        if (ops.increment != null) {
          if (currentValue == null) {
            throw StateError('Cannot increment ProfileUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue + ops.increment!;
        }
        if (ops.decrement != null) {
          if (currentValue == null) {
            throw StateError('Cannot decrement ProfileUpdateInput.tenantId because the current value is null.');
          }
          data['tenantId'] = currentValue - ops.decrement!;
        }
      }
    }
    if (accountSlug != null && accountSlugOps != null) {
      throw StateError('Only one of accountSlug or accountSlugOps may be provided for ProfileUpdateInput.accountSlug.');
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

class ProfileCreateWithoutAccountInput {
  const ProfileCreateWithoutAccountInput({required this.id, this.bio, });

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

