// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

class GeneratedComonOrmClient {
  GeneratedComonOrmClient({required DatabaseAdapter adapter})
    : _client = ComonOrmClient(adapter: adapter);

  GeneratedComonOrmClient._fromClient(this._client);

  final ComonOrmClient _client;
  late final UserDelegate user = UserDelegate(_client.model('User'));
  late final PostDelegate post = PostDelegate(_client.model('Post'));
  late final MembershipDelegate membership = MembershipDelegate(
    _client.model('Membership'),
  );

  Future<T> transaction<T>(
    Future<T> Function(GeneratedComonOrmClient tx) action,
  ) {
    return _client.transaction(
      (tx) => action(GeneratedComonOrmClient._fromClient(tx)),
    );
  }
}

class User {
  const User({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
    this.posts,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? country;
  final int? profileViews;
  final List<Post>? posts;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      name: record['name'] as String?,
      email: record['email'] as String?,
      country: record['country'] as String?,
      profileViews: record['profileViews'] as int?,
      posts: (record['posts'] as List<Object?>?)
          ?.map((item) => Post.fromRecord(item as Map<String, Object?>))
          .toList(growable: false),
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
    if (country != null) {
      record['country'] = country;
    }
    if (profileViews != null) {
      record['profileViews'] = profileViews;
    }
    if (posts != null) {
      record['posts'] = posts!
          .map((item) => item.toRecord())
          .toList(growable: false);
    }
    return Map<String, Object?>.unmodifiable(record);
  }
}

class Post {
  const Post({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
    this.user,
  });

  final int? id;
  final String? title;
  final String? content;
  final bool? published;
  final int? userId;
  final User? user;

  factory Post.fromRecord(Map<String, Object?> record) {
    return Post(
      id: record['id'] as int?,
      title: record['title'] as String?,
      content: record['content'] as String?,
      published: record['published'] as bool?,
      userId: record['userId'] as int?,
      user: record['user'] == null
          ? null
          : User.fromRecord(record['user'] as Map<String, Object?>),
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
    if (content != null) {
      record['content'] = content;
    }
    if (published != null) {
      record['published'] = published;
    }
    if (userId != null) {
      record['userId'] = userId;
    }
    if (user != null) {
      record['user'] = user!.toRecord();
    }
    return Map<String, Object?>.unmodifiable(record);
  }
}

class Membership {
  const Membership({this.tenantId, this.slug, this.role});

  final int? tenantId;
  final String? slug;
  final String? role;

  factory Membership.fromRecord(Map<String, Object?> record) {
    return Membership(
      tenantId: record['tenantId'] as int?,
      slug: record['slug'] as String?,
      role: record['role'] as String?,
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
    if (role != null) {
      record['role'] = role;
    }
    return Map<String, Object?>.unmodifiable(record);
  }
}

class UserDelegate {
  const UserDelegate(this._delegate);

  final ModelDelegate _delegate;

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
    List<UserOrderByInput>? orderBy,
    UserInclude? include,
    UserSelect? select,
    int? skip,
  }) {
    return _delegate
        .findFirst(
          FindFirstQuery(
            model: 'User',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : User.fromRecord(record));
  }

  Future<List<User>> findMany({
    UserWhereInput? where,
    List<UserOrderByInput>? orderBy,
    List<UserScalarField>? distinct,
    UserInclude? include,
    UserSelect? select,
    int? skip,
    int? take,
  }) {
    return _delegate
        .findMany(
          FindManyQuery(
            model: 'User',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            distinct:
                distinct?.map((field) => field.name).toSet() ??
                const <String>{},
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
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
    return _delegate
        .create(
          CreateQuery(
            model: 'User',
            data: data.toData(),
            include: include?.toQueryInclude(),
            nestedCreates: data.toNestedCreates(),
          ),
        )
        .then(User.fromRecord);
  }

  Future<User> update({
    required UserWhereUniqueInput where,
    required UserUpdateInput data,
    UserInclude? include,
    UserSelect? select,
  }) {
    return _delegate
        .update(
          UpdateQuery(
            model: 'User',
            where: where.toPredicates(),
            data: data.toData(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(User.fromRecord);
  }

  Future<int> updateMany({
    required UserWhereInput where,
    required UserUpdateInput data,
  }) {
    return _delegate.updateMany(
      UpdateManyQuery(
        model: 'User',
        where: where.toPredicates(),
        data: data.toData(),
      ),
    );
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
    this.email,
    this.emailFilter,
    this.country,
    this.countryFilter,
    this.profileViews,
    this.profileViewsFilter,
    this.postsSome,
    this.postsNone,
    this.postsEvery,
  });

  final List<UserWhereInput> AND;
  final List<UserWhereInput> OR;
  final List<UserWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? name;
  final StringFilter? nameFilter;
  final String? email;
  final StringFilter? emailFilter;
  final String? country;
  final StringFilter? countryFilter;
  final int? profileViews;
  final IntFilter? profileViewsFilter;
  final PostWhereInput? postsSome;
  final PostWhereInput? postsNone;
  final PostWhereInput? postsEvery;

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
    if (email != null) {
      predicates.add(
        QueryPredicate(field: 'email', operator: 'equals', value: email),
      );
    }
    if (emailFilter != null) {
      predicates.addAll(emailFilter!.toPredicates('email'));
    }
    if (country != null) {
      predicates.add(
        QueryPredicate(field: 'country', operator: 'equals', value: country),
      );
    }
    if (countryFilter != null) {
      predicates.addAll(countryFilter!.toPredicates('country'));
    }
    if (profileViews != null) {
      predicates.add(
        QueryPredicate(
          field: 'profileViews',
          operator: 'equals',
          value: profileViews,
        ),
      );
    }
    if (profileViewsFilter != null) {
      predicates.addAll(profileViewsFilter!.toPredicates('profileViews'));
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
              targetKeyField: 'userId',
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
              targetKeyField: 'userId',
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
              targetKeyField: 'userId',
            ),
            predicates: postsEvery!.toPredicates(),
          ),
        ),
      );
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
}

class UserOrderByInput {
  const UserOrderByInput({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
  final SortOrder? country;
  final SortOrder? profileViews;

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
    if (country != null) {
      orderings.add(QueryOrderBy(field: 'country', direction: country!));
    }
    if (profileViews != null) {
      orderings.add(
        QueryOrderBy(field: 'profileViews', direction: profileViews!),
      );
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum UserScalarField { id, name, email, country, profileViews }

class UserCountAggregateInput {
  const UserCountAggregateInput({
    this.all = false,
    this.id = false,
    this.name = false,
    this.email = false,
    this.country = false,
    this.profileViews = false,
  });

  final bool all;
  final bool id;
  final bool name;
  final bool email;
  final bool country;
  final bool profileViews;

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
    if (country) {
      fields.add('country');
    }
    if (profileViews) {
      fields.add('profileViews');
    }
    return QueryCountSelection(
      all: all,
      fields: Set<String>.unmodifiable(fields),
    );
  }
}

class UserAvgAggregateInput {
  const UserAvgAggregateInput({this.id = false, this.profileViews = false});

  final bool id;
  final bool profileViews;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (profileViews) {
      fields.add('profileViews');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserSumAggregateInput {
  const UserSumAggregateInput({this.id = false, this.profileViews = false});

  final bool id;
  final bool profileViews;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (profileViews) {
      fields.add('profileViews');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMinAggregateInput {
  const UserMinAggregateInput({
    this.id = false,
    this.name = false,
    this.email = false,
    this.country = false,
    this.profileViews = false,
  });

  final bool id;
  final bool name;
  final bool email;
  final bool country;
  final bool profileViews;

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
    if (country) {
      fields.add('country');
    }
    if (profileViews) {
      fields.add('profileViews');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserMaxAggregateInput {
  const UserMaxAggregateInput({
    this.id = false,
    this.name = false,
    this.email = false,
    this.country = false,
    this.profileViews = false,
  });

  final bool id;
  final bool name;
  final bool email;
  final bool country;
  final bool profileViews;

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
    if (country) {
      fields.add('country');
    }
    if (profileViews) {
      fields.add('profileViews');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class UserCountAggregateResult {
  const UserCountAggregateResult({
    this.all,
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final int? all;
  final int? id;
  final int? name;
  final int? email;
  final int? country;
  final int? profileViews;

  factory UserCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      name: result.fields['name'],
      email: result.fields['email'],
      country: result.fields['country'],
      profileViews: result.fields['profileViews'],
    );
  }
}

class UserAvgAggregateResult {
  const UserAvgAggregateResult({this.id, this.profileViews});

  final double? id;
  final double? profileViews;

  factory UserAvgAggregateResult.fromMap(Map<String, double?> values) {
    return UserAvgAggregateResult(
      id: _asDouble(values['id']),
      profileViews: _asDouble(values['profileViews']),
    );
  }
}

class UserSumAggregateResult {
  const UserSumAggregateResult({this.id, this.profileViews});

  final int? id;
  final int? profileViews;

  factory UserSumAggregateResult.fromMap(Map<String, num?> values) {
    return UserSumAggregateResult(
      id: values['id']?.toInt(),
      profileViews: values['profileViews']?.toInt(),
    );
  }
}

class UserMinAggregateResult {
  const UserMinAggregateResult({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? country;
  final int? profileViews;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      email: values['email'] as String?,
      country: values['country'] as String?,
      profileViews: values['profileViews'] as int?,
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? country;
  final int? profileViews;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      email: values['email'] as String?,
      country: values['country'] as String?,
      profileViews: values['profileViews'] as int?,
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
  const UserGroupByHavingInput({this.id, this.profileViews});

  final NumericAggregatesFilter? id;
  final NumericAggregatesFilter? profileViews;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (id != null) {
      predicates.addAll(id!.toPredicates('id'));
    }
    if (profileViews != null) {
      predicates.addAll(profileViews!.toPredicates('profileViews'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class UserCountAggregateOrderByInput {
  const UserCountAggregateOrderByInput({
    this.all,
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
  final SortOrder? country;
  final SortOrder? profileViews;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (country != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'country',
          direction: country!,
        ),
      );
    }
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'profileViews',
          direction: profileViews!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserAvgAggregateOrderByInput {
  const UserAvgAggregateOrderByInput({this.id, this.profileViews});

  final SortOrder? id;
  final SortOrder? profileViews;

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
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'profileViews',
          direction: profileViews!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserSumAggregateOrderByInput {
  const UserSumAggregateOrderByInput({this.id, this.profileViews});

  final SortOrder? id;
  final SortOrder? profileViews;

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
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'profileViews',
          direction: profileViews!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMinAggregateOrderByInput {
  const UserMinAggregateOrderByInput({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
  final SortOrder? country;
  final SortOrder? profileViews;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (country != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'country',
          direction: country!,
        ),
      );
    }
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'profileViews',
          direction: profileViews!,
        ),
      );
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({
    this.id,
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
  final SortOrder? country;
  final SortOrder? profileViews;

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
    if (email != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'email',
          direction: email!,
        ),
      );
    }
    if (country != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'country',
          direction: country!,
        ),
      );
    }
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'profileViews',
          direction: profileViews!,
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
    this.email,
    this.country,
    this.profileViews,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? email;
  final SortOrder? country;
  final SortOrder? profileViews;
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
    if (country != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'country', direction: country!),
      );
    }
    if (profileViews != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'profileViews', direction: profileViews!),
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
    this.name,
    this.email,
    this.country,
    this.profileViews,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? country;
  final int? profileViews;
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
      country: row.group['country'] as String?,
      profileViews: row.group['profileViews'] as int?,
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
  const UserInclude({this.posts = false});

  final bool posts;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (posts) {
      relations['posts'] = QueryIncludeEntry(
        relation: QueryRelation(
          field: 'posts',
          targetModel: 'Post',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'userId',
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
    this.name = false,
    this.email = false,
    this.country = false,
    this.profileViews = false,
  });

  final bool id;
  final bool name;
  final bool email;
  final bool country;
  final bool profileViews;

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
    if (country) {
      fields.add('country');
    }
    if (profileViews) {
      fields.add('profileViews');
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
    required this.email,
    this.country,
    this.profileViews,
    this.posts,
  });

  final int? id;
  final String name;
  final String email;
  final String? country;
  final int? profileViews;
  final PostCreateNestedManyWithoutUserInput? posts;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['email'] = email;
    if (country != null) {
      data['country'] = country;
    }
    if (profileViews != null) {
      data['profileViews'] = profileViews;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (posts != null) {
      writes.addAll(
        posts!.toRelationWrites(
          QueryRelation(
            field: 'posts',
            targetModel: 'Post',
            cardinality: QueryRelationCardinality.many,
            localKeyField: 'id',
            targetKeyField: 'userId',
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class UserUpdateInput {
  const UserUpdateInput({
    this.name,
    this.email,
    this.country,
    this.profileViews,
  });

  final String? name;
  final String? email;
  final String? country;
  final int? profileViews;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (name != null) {
      data['name'] = name;
    }
    if (email != null) {
      data['email'] = email;
    }
    if (country != null) {
      data['country'] = country;
    }
    if (profileViews != null) {
      data['profileViews'] = profileViews;
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class UserCreateWithoutPostsInput {
  const UserCreateWithoutPostsInput({
    this.id,
    required this.name,
    required this.email,
    this.country,
    this.profileViews,
  });

  final int? id;
  final String name;
  final String email;
  final String? country;
  final int? profileViews;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['name'] = name;
    data['email'] = email;
    if (country != null) {
      data['country'] = country;
    }
    if (profileViews != null) {
      data['profileViews'] = profileViews;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class PostCreateNestedManyWithoutUserInput {
  const PostCreateNestedManyWithoutUserInput({
    this.create = const <PostCreateWithoutUserInput>[],
  });

  final List<PostCreateWithoutUserInput> create;

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
}

class PostDelegate {
  const PostDelegate(this._delegate);

  final ModelDelegate _delegate;

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
    List<PostOrderByInput>? orderBy,
    PostInclude? include,
    PostSelect? select,
    int? skip,
  }) {
    return _delegate
        .findFirst(
          FindFirstQuery(
            model: 'Post',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
            skip: skip,
          ),
        )
        .then((record) => record == null ? null : Post.fromRecord(record));
  }

  Future<List<Post>> findMany({
    PostWhereInput? where,
    List<PostOrderByInput>? orderBy,
    List<PostScalarField>? distinct,
    PostInclude? include,
    PostSelect? select,
    int? skip,
    int? take,
  }) {
    return _delegate
        .findMany(
          FindManyQuery(
            model: 'Post',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            distinct:
                distinct?.map((field) => field.name).toSet() ??
                const <String>{},
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
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
    return _delegate
        .create(
          CreateQuery(
            model: 'Post',
            data: data.toData(),
            include: include?.toQueryInclude(),
            nestedCreates: data.toNestedCreates(),
          ),
        )
        .then(Post.fromRecord);
  }

  Future<Post> update({
    required PostWhereUniqueInput where,
    required PostUpdateInput data,
    PostInclude? include,
    PostSelect? select,
  }) {
    return _delegate
        .update(
          UpdateQuery(
            model: 'Post',
            where: where.toPredicates(),
            data: data.toData(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Post.fromRecord);
  }

  Future<int> updateMany({
    required PostWhereInput where,
    required PostUpdateInput data,
  }) {
    return _delegate.updateMany(
      UpdateManyQuery(
        model: 'Post',
        where: where.toPredicates(),
        data: data.toData(),
      ),
    );
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
    this.title,
    this.titleFilter,
    this.content,
    this.contentFilter,
    this.published,
    this.publishedFilter,
    this.userId,
    this.userIdFilter,
    this.userIs,
    this.userIsNot,
  });

  final List<PostWhereInput> AND;
  final List<PostWhereInput> OR;
  final List<PostWhereInput> NOT;
  final int? id;
  final IntFilter? idFilter;
  final String? title;
  final StringFilter? titleFilter;
  final String? content;
  final StringFilter? contentFilter;
  final bool? published;
  final BoolFilter? publishedFilter;
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
    if (content != null) {
      predicates.add(
        QueryPredicate(field: 'content', operator: 'equals', value: content),
      );
    }
    if (contentFilter != null) {
      predicates.addAll(contentFilter!.toPredicates('content'));
    }
    if (published != null) {
      predicates.add(
        QueryPredicate(
          field: 'published',
          operator: 'equals',
          value: published,
        ),
      );
    }
    if (publishedFilter != null) {
      predicates.addAll(publishedFilter!.toPredicates('published'));
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
            ),
            predicates: userIsNot!.toPredicates(),
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
}

class PostOrderByInput {
  const PostOrderByInput({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? content;
  final SortOrder? published;
  final SortOrder? userId;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (id != null) {
      orderings.add(QueryOrderBy(field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(QueryOrderBy(field: 'title', direction: title!));
    }
    if (content != null) {
      orderings.add(QueryOrderBy(field: 'content', direction: content!));
    }
    if (published != null) {
      orderings.add(QueryOrderBy(field: 'published', direction: published!));
    }
    if (userId != null) {
      orderings.add(QueryOrderBy(field: 'userId', direction: userId!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum PostScalarField { id, title, content, published, userId }

class PostCountAggregateInput {
  const PostCountAggregateInput({
    this.all = false,
    this.id = false,
    this.title = false,
    this.content = false,
    this.published = false,
    this.userId = false,
  });

  final bool all;
  final bool id;
  final bool title;
  final bool content;
  final bool published;
  final bool userId;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (content) {
      fields.add('content');
    }
    if (published) {
      fields.add('published');
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

class PostAvgAggregateInput {
  const PostAvgAggregateInput({this.id = false, this.userId = false});

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
  const PostSumAggregateInput({this.id = false, this.userId = false});

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
  const PostMinAggregateInput({
    this.id = false,
    this.title = false,
    this.content = false,
    this.published = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool content;
  final bool published;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (content) {
      fields.add('content');
    }
    if (published) {
      fields.add('published');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostMaxAggregateInput {
  const PostMaxAggregateInput({
    this.id = false,
    this.title = false,
    this.content = false,
    this.published = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool content;
  final bool published;
  final bool userId;

  Set<String> toFields() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (content) {
      fields.add('content');
    }
    if (published) {
      fields.add('published');
    }
    if (userId) {
      fields.add('userId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class PostCountAggregateResult {
  const PostCountAggregateResult({
    this.all,
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final int? all;
  final int? id;
  final int? title;
  final int? content;
  final int? published;
  final int? userId;

  factory PostCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return PostCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      title: result.fields['title'],
      content: result.fields['content'],
      published: result.fields['published'],
      userId: result.fields['userId'],
    );
  }
}

class PostAvgAggregateResult {
  const PostAvgAggregateResult({this.id, this.userId});

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
  const PostSumAggregateResult({this.id, this.userId});

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
  const PostMinAggregateResult({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final int? id;
  final String? title;
  final String? content;
  final bool? published;
  final int? userId;

  factory PostMinAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMinAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      content: values['content'] as String?,
      published: values['published'] as bool?,
      userId: values['userId'] as int?,
    );
  }
}

class PostMaxAggregateResult {
  const PostMaxAggregateResult({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final int? id;
  final String? title;
  final String? content;
  final bool? published;
  final int? userId;

  factory PostMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return PostMaxAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      content: values['content'] as String?,
      published: values['published'] as bool?,
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
  const PostGroupByHavingInput({this.id, this.userId});

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
  const PostCountAggregateOrderByInput({
    this.all,
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? content;
  final SortOrder? published;
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
    if (content != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'content',
          direction: content!,
        ),
      );
    }
    if (published != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'published',
          direction: published!,
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

class PostAvgAggregateOrderByInput {
  const PostAvgAggregateOrderByInput({this.id, this.userId});

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

class PostSumAggregateOrderByInput {
  const PostSumAggregateOrderByInput({this.id, this.userId});

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

class PostMinAggregateOrderByInput {
  const PostMinAggregateOrderByInput({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? content;
  final SortOrder? published;
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
    if (content != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'content',
          direction: content!,
        ),
      );
    }
    if (published != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'published',
          direction: published!,
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

class PostMaxAggregateOrderByInput {
  const PostMaxAggregateOrderByInput({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? content;
  final SortOrder? published;
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
    if (content != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'content',
          direction: content!,
        ),
      );
    }
    if (published != null) {
      orderings.add(
        GroupByOrderBy.aggregate(
          aggregate: function,
          field: 'published',
          direction: published!,
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

class PostGroupByOrderByInput {
  const PostGroupByOrderByInput({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? content;
  final SortOrder? published;
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
    if (content != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'content', direction: content!),
      );
    }
    if (published != null) {
      orderings.add(
        GroupByOrderBy.field(field: 'published', direction: published!),
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

class PostGroupByRow {
  const PostGroupByRow({
    this.id,
    this.title,
    this.content,
    this.published,
    this.userId,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? id;
  final String? title;
  final String? content;
  final bool? published;
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
      content: row.group['content'] as String?,
      published: row.group['published'] as bool?,
      userId: row.group['userId'] as int?,
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
  const PostInclude({this.user = false});

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
  const PostSelect({
    this.id = false,
    this.title = false,
    this.content = false,
    this.published = false,
    this.userId = false,
  });

  final bool id;
  final bool title;
  final bool content;
  final bool published;
  final bool userId;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (id) {
      fields.add('id');
    }
    if (title) {
      fields.add('title');
    }
    if (content) {
      fields.add('content');
    }
    if (published) {
      fields.add('published');
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
  const PostCreateInput({
    this.id,
    required this.title,
    this.content,
    this.published,
    required this.userId,
    this.user,
  });

  final int? id;
  final String title;
  final String? content;
  final bool? published;
  final int userId;
  final UserCreateNestedOneWithoutPostsInput? user;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    if (content != null) {
      data['content'] = content;
    }
    if (published != null) {
      data['published'] = published;
    }
    data['userId'] = userId;
    return Map<String, Object?>.unmodifiable(data);
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
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class PostUpdateInput {
  const PostUpdateInput({
    this.title,
    this.content,
    this.published,
    this.userId,
  });

  final String? title;
  final String? content;
  final bool? published;
  final int? userId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (title != null) {
      data['title'] = title;
    }
    if (content != null) {
      data['content'] = content;
    }
    if (published != null) {
      data['published'] = published;
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class PostCreateWithoutUserInput {
  const PostCreateWithoutUserInput({
    this.id,
    required this.title,
    this.content,
    this.published,
  });

  final int? id;
  final String title;
  final String? content;
  final bool? published;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (id != null) {
      data['id'] = id;
    }
    data['title'] = title;
    if (content != null) {
      data['content'] = content;
    }
    if (published != null) {
      data['published'] = published;
    }
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];
}

class UserCreateNestedOneWithoutPostsInput {
  const UserCreateNestedOneWithoutPostsInput({this.create});

  final UserCreateWithoutPostsInput? create;

  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {
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
}

class MembershipDelegate {
  const MembershipDelegate(this._delegate);

  final ModelDelegate _delegate;

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
    List<MembershipOrderByInput>? orderBy,
    MembershipInclude? include,
    MembershipSelect? select,
    int? skip,
  }) {
    return _delegate
        .findFirst(
          FindFirstQuery(
            model: 'Membership',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
            skip: skip,
          ),
        )
        .then(
          (record) => record == null ? null : Membership.fromRecord(record),
        );
  }

  Future<List<Membership>> findMany({
    MembershipWhereInput? where,
    List<MembershipOrderByInput>? orderBy,
    List<MembershipScalarField>? distinct,
    MembershipInclude? include,
    MembershipSelect? select,
    int? skip,
    int? take,
  }) {
    return _delegate
        .findMany(
          FindManyQuery(
            model: 'Membership',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            distinct:
                distinct?.map((field) => field.name).toSet() ??
                const <String>{},
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
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
    return _delegate
        .create(
          CreateQuery(
            model: 'Membership',
            data: data.toData(),
            include: include?.toQueryInclude(),
            nestedCreates: data.toNestedCreates(),
          ),
        )
        .then(Membership.fromRecord);
  }

  Future<Membership> update({
    required MembershipWhereUniqueInput where,
    required MembershipUpdateInput data,
    MembershipInclude? include,
    MembershipSelect? select,
  }) {
    return _delegate
        .update(
          UpdateQuery(
            model: 'Membership',
            where: where.toPredicates(),
            data: data.toData(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Membership.fromRecord);
  }

  Future<int> updateMany({
    required MembershipWhereInput where,
    required MembershipUpdateInput data,
  }) {
    return _delegate.updateMany(
      UpdateManyQuery(
        model: 'Membership',
        where: where.toPredicates(),
        data: data.toData(),
      ),
    );
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
    this.role,
    this.roleFilter,
  });

  final List<MembershipWhereInput> AND;
  final List<MembershipWhereInput> OR;
  final List<MembershipWhereInput> NOT;
  final int? tenantId;
  final IntFilter? tenantIdFilter;
  final String? slug;
  final StringFilter? slugFilter;
  final String? role;
  final StringFilter? roleFilter;

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
    if (role != null) {
      predicates.add(
        QueryPredicate(field: 'role', operator: 'equals', value: role),
      );
    }
    if (roleFilter != null) {
      predicates.addAll(roleFilter!.toPredicates('role'));
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
}

class MembershipOrderByInput {
  const MembershipOrderByInput({this.tenantId, this.slug, this.role});

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? role;

  List<QueryOrderBy> toQueryOrderBy() {
    final orderings = <QueryOrderBy>[];
    if (tenantId != null) {
      orderings.add(QueryOrderBy(field: 'tenantId', direction: tenantId!));
    }
    if (slug != null) {
      orderings.add(QueryOrderBy(field: 'slug', direction: slug!));
    }
    if (role != null) {
      orderings.add(QueryOrderBy(field: 'role', direction: role!));
    }
    return List<QueryOrderBy>.unmodifiable(orderings);
  }
}

enum MembershipScalarField { tenantId, slug, role }

class MembershipCountAggregateInput {
  const MembershipCountAggregateInput({
    this.all = false,
    this.tenantId = false,
    this.slug = false,
    this.role = false,
  });

  final bool all;
  final bool tenantId;
  final bool slug;
  final bool role;

  QueryCountSelection toQueryCountSelection() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
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

class MembershipAvgAggregateInput {
  const MembershipAvgAggregateInput({this.tenantId = false});

  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipSumAggregateInput {
  const MembershipSumAggregateInput({this.tenantId = false});

  final bool tenantId;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipMinAggregateInput {
  const MembershipMinAggregateInput({
    this.tenantId = false,
    this.slug = false,
    this.role = false,
  });

  final bool tenantId;
  final bool slug;
  final bool role;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (role) {
      fields.add('role');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipMaxAggregateInput {
  const MembershipMaxAggregateInput({
    this.tenantId = false,
    this.slug = false,
    this.role = false,
  });

  final bool tenantId;
  final bool slug;
  final bool role;

  Set<String> toFields() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
    }
    if (role) {
      fields.add('role');
    }
    return Set<String>.unmodifiable(fields);
  }
}

class MembershipCountAggregateResult {
  const MembershipCountAggregateResult({
    this.all,
    this.tenantId,
    this.slug,
    this.role,
  });

  final int? all;
  final int? tenantId;
  final int? slug;
  final int? role;

  factory MembershipCountAggregateResult.fromQueryCountResult(
    QueryCountAggregateResult result,
  ) {
    return MembershipCountAggregateResult(
      all: result.all,
      tenantId: result.fields['tenantId'],
      slug: result.fields['slug'],
      role: result.fields['role'],
    );
  }
}

class MembershipAvgAggregateResult {
  const MembershipAvgAggregateResult({this.tenantId});

  final double? tenantId;

  factory MembershipAvgAggregateResult.fromMap(Map<String, double?> values) {
    return MembershipAvgAggregateResult(
      tenantId: _asDouble(values['tenantId']),
    );
  }
}

class MembershipSumAggregateResult {
  const MembershipSumAggregateResult({this.tenantId});

  final int? tenantId;

  factory MembershipSumAggregateResult.fromMap(Map<String, num?> values) {
    return MembershipSumAggregateResult(tenantId: values['tenantId']?.toInt());
  }
}

class MembershipMinAggregateResult {
  const MembershipMinAggregateResult({this.tenantId, this.slug, this.role});

  final int? tenantId;
  final String? slug;
  final String? role;

  factory MembershipMinAggregateResult.fromMap(Map<String, Object?> values) {
    return MembershipMinAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      role: values['role'] as String?,
    );
  }
}

class MembershipMaxAggregateResult {
  const MembershipMaxAggregateResult({this.tenantId, this.slug, this.role});

  final int? tenantId;
  final String? slug;
  final String? role;

  factory MembershipMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return MembershipMaxAggregateResult(
      tenantId: values['tenantId'] as int?,
      slug: values['slug'] as String?,
      role: values['role'] as String?,
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
  const MembershipGroupByHavingInput({this.tenantId});

  final NumericAggregatesFilter? tenantId;

  List<QueryAggregatePredicate> toAggregatePredicates() {
    final predicates = <QueryAggregatePredicate>[];
    if (tenantId != null) {
      predicates.addAll(tenantId!.toPredicates('tenantId'));
    }
    return List<QueryAggregatePredicate>.unmodifiable(predicates);
  }
}

class MembershipCountAggregateOrderByInput {
  const MembershipCountAggregateOrderByInput({
    this.all,
    this.tenantId,
    this.slug,
    this.role,
  });

  final SortOrder? all;
  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? role;

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

class MembershipAvgAggregateOrderByInput {
  const MembershipAvgAggregateOrderByInput({this.tenantId});

  final SortOrder? tenantId;

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
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class MembershipSumAggregateOrderByInput {
  const MembershipSumAggregateOrderByInput({this.tenantId});

  final SortOrder? tenantId;

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
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class MembershipMinAggregateOrderByInput {
  const MembershipMinAggregateOrderByInput({
    this.tenantId,
    this.slug,
    this.role,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? role;

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

class MembershipMaxAggregateOrderByInput {
  const MembershipMaxAggregateOrderByInput({
    this.tenantId,
    this.slug,
    this.role,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? role;

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

class MembershipGroupByOrderByInput {
  const MembershipGroupByOrderByInput({
    this.tenantId,
    this.slug,
    this.role,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final SortOrder? tenantId;
  final SortOrder? slug;
  final SortOrder? role;
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

class MembershipGroupByRow {
  const MembershipGroupByRow({
    this.tenantId,
    this.slug,
    this.role,
    this.count,
    this.avg,
    this.sum,
    this.min,
    this.max,
  });

  final int? tenantId;
  final String? slug;
  final String? role;
  final MembershipCountAggregateResult? count;
  final MembershipAvgAggregateResult? avg;
  final MembershipSumAggregateResult? sum;
  final MembershipMinAggregateResult? min;
  final MembershipMaxAggregateResult? max;

  factory MembershipGroupByRow.fromQueryResultRow(GroupByQueryResultRow row) {
    return MembershipGroupByRow(
      tenantId: row.group['tenantId'] as int?,
      slug: row.group['slug'] as String?,
      role: row.group['role'] as String?,
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
  const MembershipInclude();

  QueryInclude? toQueryInclude() {
    return null;
  }
}

class MembershipSelect {
  const MembershipSelect({
    this.tenantId = false,
    this.slug = false,
    this.role = false,
  });

  final bool tenantId;
  final bool slug;
  final bool role;

  QuerySelect? toQuerySelect() {
    final fields = <String>{};
    if (tenantId) {
      fields.add('tenantId');
    }
    if (slug) {
      fields.add('slug');
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

class MembershipCreateInput {
  const MembershipCreateInput({
    required this.tenantId,
    required this.slug,
    required this.role,
  });

  final int tenantId;
  final String slug;
  final String role;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    data['tenantId'] = tenantId;
    data['slug'] = slug;
    data['role'] = role;
    return Map<String, Object?>.unmodifiable(data);
  }

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class MembershipUpdateInput {
  const MembershipUpdateInput({this.tenantId, this.slug, this.role});

  final int? tenantId;
  final String? slug;
  final String? role;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (tenantId != null) {
      data['tenantId'] = tenantId;
    }
    if (slug != null) {
      data['slug'] = slug;
    }
    if (role != null) {
      data['role'] = role;
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
