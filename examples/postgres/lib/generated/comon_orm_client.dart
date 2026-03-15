// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

class GeneratedComonOrmClient {
  GeneratedComonOrmClient({required DatabaseAdapter adapter})
    : _client = ComonOrmClient(adapter: adapter);

  GeneratedComonOrmClient._fromClient(this._client);

  final ComonOrmClient _client;
  late final UserDelegate user = UserDelegate(_client.model('User'));
  late final TodoDelegate todo = TodoDelegate(_client.model('Todo'));

  Future<T> transaction<T>(
    Future<T> Function(GeneratedComonOrmClient tx) action,
  ) {
    return _client.transaction((tx) => action(GeneratedComonOrmClient._fromClient(tx)));
  }
}

enum UserRole {
  admin,
  developer,
  manager
}

enum TodoStatus {
  pending,
  inProgress,
  done
}

class User {
  const User({this.id, this.name, this.role, this.todos, });

  final int? id;
  final String? name;
  final UserRole? role;
  final List<Todo>? todos;

  factory User.fromRecord(Map<String, Object?> record) {
    return User(
      id: record['id'] as int?,
      name: record['name'] as String?,
      role: record['role'] == null ? null : UserRole.values.byName(record['role'] as String),
      todos: (record['todos'] as List<Object?>?)?.map((item) => Todo.fromRecord(item as Map<String, Object?>)).toList(growable: false),
    );
  }

  factory User.fromJson(Map<String, Object?> json) {
    return User(
      id: json['id'] as int?,
      name: json['name'] as String?,
      role: json['role'] == null ? null : UserRole.values.byName(json['role'] as String),
      todos: (json['todos'] as List<Object?>?)?.map((item) => Todo.fromJson(item as Map<String, Object?>)).toList(growable: false),
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
      record['todos'] = todos!.map((item) => item.toRecord()).toList(growable: false);
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
      json['todos'] = todos!.map((item) => item.toJson()).toList(growable: false);
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
  const Todo({this.id, this.title, this.status, this.createdAt, this.userId, this.user, });

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
      status: record['status'] == null ? null : TodoStatus.values.byName(record['status'] as String),
      createdAt: _asDateTime(record['createdAt']),
      userId: record['userId'] as int?,
      user: record['user'] == null ? null : User.fromRecord(record['user'] as Map<String, Object?>),
    );
  }

  factory Todo.fromJson(Map<String, Object?> json) {
    return Todo(
      id: json['id'] as int?,
      title: json['title'] as String?,
      status: json['status'] == null ? null : TodoStatus.values.byName(json['status'] as String),
      createdAt: _asDateTime(json['createdAt']),
      userId: json['userId'] as int?,
      user: json['user'] == null ? null : User.fromJson(json['user'] as Map<String, Object?>),
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
      createdAt: createdAt == _undefined ? this.createdAt : createdAt as DateTime?,
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
  String toString() => 'Todo(id: $id, title: $title, status: $status, createdAt: $createdAt, userId: $userId, user: $user)';

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
  const UserDelegate(this._delegate);

  final ModelDelegate _delegate;

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
    List<UserOrderByInput>? orderBy,
    UserInclude? include,
    UserSelect? select,
    int? skip,
  }) {
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'User',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
        skip: skip,
      ),
    ).then((record) => record == null ? null : User.fromRecord(record));
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
    return _delegate.findMany(
      FindManyQuery(
        model: 'User',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        distinct: distinct?.map((field) => field.name).toSet() ?? const <String>{},
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
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
    return _delegate.create(
      CreateQuery(
        model: 'User',
        data: data.toData(),
        include: include?.toQueryInclude(),
        nestedCreates: data.toNestedCreates(),
      ),
    ).then(User.fromRecord);
  }

  Future<User> update({
    required UserWhereUniqueInput where,
    required UserUpdateInput data,
    UserInclude? include,
    UserSelect? select,
  }) {
    return _delegate.update(
      UpdateQuery(
        model: 'User',
        where: where.toPredicates(),
        data: data.toData(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(User.fromRecord);
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
  const UserWhereInput({this.AND = const <UserWhereInput>[], this.OR = const <UserWhereInput>[], this.NOT = const <UserWhereInput>[], this.id, this.idFilter, this.name, this.nameFilter, this.role, this.todosSome, this.todosNone, this.todosEvery, });

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
    if (role != null) {
      predicates.add(QueryPredicate(field: 'role', operator: 'equals', value: _enumName(role)));
    }
    if (todosSome != null) {
      predicates.add(QueryPredicate(field: 'todos', operator: 'relationSome', value: QueryRelationFilter(relation: QueryRelation(field: 'todos', targetModel: 'Todo', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId'), predicates: todosSome!.toPredicates())));
    }
    if (todosNone != null) {
      predicates.add(QueryPredicate(field: 'todos', operator: 'relationNone', value: QueryRelationFilter(relation: QueryRelation(field: 'todos', targetModel: 'Todo', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId'), predicates: todosNone!.toPredicates())));
    }
    if (todosEvery != null) {
      predicates.add(QueryPredicate(field: 'todos', operator: 'relationEvery', value: QueryRelationFilter(relation: QueryRelation(field: 'todos', targetModel: 'Todo', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId'), predicates: todosEvery!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class UserWhereUniqueInput {
  const UserWhereUniqueInput({this.id, });

  final int? id;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for UserWhereUniqueInput.');
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }
}

class UserOrderByInput {
  const UserOrderByInput({this.id, this.name, this.role, });

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

enum UserScalarField {
  id,
  name,
  role
}

class UserCountAggregateInput {
  const UserCountAggregateInput({this.all = false, this.id = false, this.name = false, this.role = false, });

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
  const UserMinAggregateInput({this.id = false, this.name = false, this.role = false, });

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
  const UserMaxAggregateInput({this.id = false, this.name = false, this.role = false, });

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
  const UserCountAggregateResult({this.all, this.id, this.name, this.role, });

  final int? all;
  final int? id;
  final int? name;
  final int? role;

  factory UserCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
    return UserCountAggregateResult(
      all: result.all,
      id: result.fields['id'],
      name: result.fields['name'],
      role: result.fields['role'],
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
  const UserMinAggregateResult({this.id, this.name, this.role, });

  final int? id;
  final String? name;
  final UserRole? role;

  factory UserMinAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMinAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      role: values['role'] == null ? null : UserRole.values.byName(values['role'] as String),
    );
  }
}

class UserMaxAggregateResult {
  const UserMaxAggregateResult({this.id, this.name, this.role, });

  final int? id;
  final String? name;
  final UserRole? role;

  factory UserMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return UserMaxAggregateResult(
      id: values['id'] as int?,
      name: values['name'] as String?,
      role: values['role'] == null ? null : UserRole.values.byName(values['role'] as String),
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
  const UserCountAggregateOrderByInput({this.all, this.id, this.name, this.role, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

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
    if (role != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'role', direction: role!));
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
  const UserMinAggregateOrderByInput({this.id, this.name, this.role, });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    if (role != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'role', direction: role!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserMaxAggregateOrderByInput {
  const UserMaxAggregateOrderByInput({this.id, this.name, this.role, });

  final SortOrder? id;
  final SortOrder? name;
  final SortOrder? role;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (name != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'name', direction: name!));
    }
    if (role != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'role', direction: role!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class UserGroupByOrderByInput {
  const UserGroupByOrderByInput({this.id, this.name, this.role, this.count, this.avg, this.sum, this.min, this.max});

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
  const UserGroupByRow({this.id, this.name, this.role, this.count, this.avg, this.sum, this.min, this.max});

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
      role: row.group['role'] == null ? null : UserRole.values.byName(row.group['role'] as String),
      count: row.aggregates.count == null ? null : UserCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : UserAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : UserSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : UserMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : UserMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class UserInclude {
  const UserInclude({this.todos = false, });

  final bool todos;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (todos) {
      relations['todos'] = QueryIncludeEntry(relation: QueryRelation(field: 'todos', targetModel: 'Todo', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId'));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class UserSelect {
  const UserSelect({this.id = false, this.name = false, this.role = false, });

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
  const UserCreateInput({this.id, required this.name, required this.role, this.todos, });

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

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (todos != null) {
      writes.addAll(todos!.toRelationWrites(QueryRelation(field: 'todos', targetModel: 'Todo', cardinality: QueryRelationCardinality.many, localKeyField: 'id', targetKeyField: 'userId')));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class UserUpdateInput {
  const UserUpdateInput({this.name, this.role, });

  final String? name;
  final UserRole? role;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (name != null) {
      data['name'] = name;
    }
    if (role != null) {
      data['role'] = _enumName(role);
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class UserCreateWithoutTodosInput {
  const UserCreateWithoutTodosInput({this.id, required this.name, required this.role, });

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

class TodoCreateNestedManyWithoutUserInput {
  const TodoCreateNestedManyWithoutUserInput({this.create = const <TodoCreateWithoutUserInput>[]});

  final List<TodoCreateWithoutUserInput> create;

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

class TodoDelegate {
  const TodoDelegate(this._delegate);

  final ModelDelegate _delegate;

  Future<Todo?> findUnique({
    required TodoWhereUniqueInput where,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate.findUnique(
      FindUniqueQuery(
        model: 'Todo',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then((record) => record == null ? null : Todo.fromRecord(record));
  }

  Future<Todo?> findFirst({
    TodoWhereInput? where,
    List<TodoOrderByInput>? orderBy,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
  }) {
    return _delegate.findFirst(
      FindFirstQuery(
        model: 'Todo',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
        skip: skip,
      ),
    ).then((record) => record == null ? null : Todo.fromRecord(record));
  }

  Future<List<Todo>> findMany({
    TodoWhereInput? where,
    List<TodoOrderByInput>? orderBy,
    List<TodoScalarField>? distinct,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
    int? take,
  }) {
    return _delegate.findMany(
      FindManyQuery(
        model: 'Todo',
        where: where?.toPredicates() ?? const <QueryPredicate>[],
        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],
        distinct: distinct?.map((field) => field.name).toSet() ?? const <String>{},
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
        skip: skip,
        take: take,
      ),
    ).then((records) => records.map(Todo.fromRecord).toList(growable: false));
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
    return _delegate.aggregate(
      AggregateQuery(
        model: 'Todo',
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
    ).then(TodoAggregateResult.fromQueryResult);
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
    return _delegate.groupBy(
      GroupByQuery(
        model: 'Todo',
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
    ).then((rows) => rows.map(TodoGroupByRow.fromQueryResultRow).toList(growable: false));
  }

  Future<Todo> create({
    required TodoCreateInput data,
    TodoInclude? include,
  }) {
    return _delegate.create(
      CreateQuery(
        model: 'Todo',
        data: data.toData(),
        include: include?.toQueryInclude(),
        nestedCreates: data.toNestedCreates(),
      ),
    ).then(Todo.fromRecord);
  }

  Future<Todo> update({
    required TodoWhereUniqueInput where,
    required TodoUpdateInput data,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate.update(
      UpdateQuery(
        model: 'Todo',
        where: where.toPredicates(),
        data: data.toData(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Todo.fromRecord);
  }

  Future<int> updateMany({
    required TodoWhereInput where,
    required TodoUpdateInput data,
  }) {
    return _delegate.updateMany(
      UpdateManyQuery(
        model: 'Todo',
        where: where.toPredicates(),
        data: data.toData(),
      ),
    );
  }

  Future<Todo> delete({
    required TodoWhereUniqueInput where,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate.delete(
      DeleteQuery(
        model: 'Todo',
        where: where.toPredicates(),
        include: include?.toQueryInclude(),
        select: select?.toQuerySelect(),
      ),
    ).then(Todo.fromRecord);
  }

  Future<int> deleteMany({
    required TodoWhereInput where,
  }) {
    return _delegate.deleteMany(
      DeleteManyQuery(
        model: 'Todo',
        where: where.toPredicates(),
      ),
    );
  }
}

class TodoWhereInput {
  const TodoWhereInput({this.AND = const <TodoWhereInput>[], this.OR = const <TodoWhereInput>[], this.NOT = const <TodoWhereInput>[], this.id, this.idFilter, this.title, this.titleFilter, this.status, this.createdAt, this.userId, this.userIdFilter, this.userIs, this.userIsNot, });

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
    if (status != null) {
      predicates.add(QueryPredicate(field: 'status', operator: 'equals', value: _enumName(status)));
    }
    if (createdAt != null) {
      predicates.add(QueryPredicate(field: 'createdAt', operator: 'equals', value: createdAt));
    }
    if (userId != null) {
      predicates.add(QueryPredicate(field: 'userId', operator: 'equals', value: userId));
    }
    if (userIdFilter != null) {
      predicates.addAll(userIdFilter!.toPredicates('userId'));
    }
    if (userIs != null) {
      predicates.add(QueryPredicate(field: 'user', operator: 'relationIs', value: QueryRelationFilter(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id'), predicates: userIs!.toPredicates())));
    }
    if (userIsNot != null) {
      predicates.add(QueryPredicate(field: 'user', operator: 'relationIsNot', value: QueryRelationFilter(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id'), predicates: userIsNot!.toPredicates())));
    }
    return List<QueryPredicate>.unmodifiable(predicates);
  }
}

class TodoWhereUniqueInput {
  const TodoWhereUniqueInput({this.id, });

  final int? id;

  List<QueryPredicate> toPredicates() {
    final selectors = <List<QueryPredicate>>[];
    if (id != null) {
      selectors.add(<QueryPredicate>[
        QueryPredicate(field: 'id', operator: 'equals', value: id),
      ]);
    }
    if (selectors.length != 1) {
      throw StateError('Exactly one unique selector must be provided for TodoWhereUniqueInput.');
    }
    return List<QueryPredicate>.unmodifiable(selectors.single);
  }
}

class TodoOrderByInput {
  const TodoOrderByInput({this.id, this.title, this.status, this.createdAt, this.userId, });

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

enum TodoScalarField {
  id,
  title,
  status,
  createdAt,
  userId
}

class TodoCountAggregateInput {
  const TodoCountAggregateInput({this.all = false, this.id = false, this.title = false, this.status = false, this.createdAt = false, this.userId = false, });

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
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class TodoAvgAggregateInput {
  const TodoAvgAggregateInput({this.id = false, this.userId = false, });

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
  const TodoSumAggregateInput({this.id = false, this.userId = false, });

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
  const TodoMinAggregateInput({this.id = false, this.title = false, this.status = false, this.createdAt = false, this.userId = false, });

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
  const TodoMaxAggregateInput({this.id = false, this.title = false, this.status = false, this.createdAt = false, this.userId = false, });

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
  const TodoCountAggregateResult({this.all, this.id, this.title, this.status, this.createdAt, this.userId, });

  final int? all;
  final int? id;
  final int? title;
  final int? status;
  final int? createdAt;
  final int? userId;

  factory TodoCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
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
  const TodoAvgAggregateResult({this.id, this.userId, });

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
  const TodoSumAggregateResult({this.id, this.userId, });

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
  const TodoMinAggregateResult({this.id, this.title, this.status, this.createdAt, this.userId, });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;

  factory TodoMinAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMinAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      status: values['status'] == null ? null : TodoStatus.values.byName(values['status'] as String),
      createdAt: _asDateTime(values['createdAt']),
      userId: values['userId'] as int?,
    );
  }
}

class TodoMaxAggregateResult {
  const TodoMaxAggregateResult({this.id, this.title, this.status, this.createdAt, this.userId, });

  final int? id;
  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;

  factory TodoMaxAggregateResult.fromMap(Map<String, Object?> values) {
    return TodoMaxAggregateResult(
      id: values['id'] as int?,
      title: values['title'] as String?,
      status: values['status'] == null ? null : TodoStatus.values.byName(values['status'] as String),
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
      count: result.count == null ? null : TodoCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : TodoAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : TodoSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : TodoMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : TodoMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class TodoGroupByHavingInput {
  const TodoGroupByHavingInput({this.id, this.userId, });

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
  const TodoCountAggregateOrderByInput({this.all, this.id, this.title, this.status, this.createdAt, this.userId, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
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
    if (status != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'status', direction: status!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoAvgAggregateOrderByInput {
  const TodoAvgAggregateOrderByInput({this.id, this.userId, });

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

class TodoSumAggregateOrderByInput {
  const TodoSumAggregateOrderByInput({this.id, this.userId, });

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

class TodoMinAggregateOrderByInput {
  const TodoMinAggregateOrderByInput({this.id, this.title, this.status, this.createdAt, this.userId, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (status != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'status', direction: status!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoMaxAggregateOrderByInput {
  const TodoMaxAggregateOrderByInput({this.id, this.title, this.status, this.createdAt, this.userId, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? status;
  final SortOrder? createdAt;
  final SortOrder? userId;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (status != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'status', direction: status!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    if (userId != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'userId', direction: userId!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoGroupByOrderByInput {
  const TodoGroupByOrderByInput({this.id, this.title, this.status, this.createdAt, this.userId, this.count, this.avg, this.sum, this.min, this.max});

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
      orderings.add(GroupByOrderBy.field(field: 'createdAt', direction: createdAt!));
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
  const TodoGroupByRow({this.id, this.title, this.status, this.createdAt, this.userId, this.count, this.avg, this.sum, this.min, this.max});

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
      status: row.group['status'] == null ? null : TodoStatus.values.byName(row.group['status'] as String),
      createdAt: _asDateTime(row.group['createdAt']),
      userId: row.group['userId'] as int?,
      count: row.aggregates.count == null ? null : TodoCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : TodoAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : TodoSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : TodoMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : TodoMaxAggregateResult.fromMap(row.aggregates.max!),
    );
  }
}

class TodoInclude {
  const TodoInclude({this.user = false, });

  final bool user;

  QueryInclude? toQueryInclude() {
    final relations = <String, QueryIncludeEntry>{};
    if (user) {
      relations['user'] = QueryIncludeEntry(relation: QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id'));
    }
    if (relations.isEmpty) {
      return null;
    }
    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));
  }
}

class TodoSelect {
  const TodoSelect({this.id = false, this.title = false, this.status = false, this.createdAt = false, this.userId = false, });

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
  const TodoCreateInput({this.id, required this.title, required this.status, this.createdAt, required this.userId, this.user, });

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

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    if (user != null) {
      writes.addAll(user!.toRelationWrites(QueryRelation(field: 'user', targetModel: 'User', cardinality: QueryRelationCardinality.one, localKeyField: 'userId', targetKeyField: 'id')));
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class TodoUpdateInput {
  const TodoUpdateInput({this.title, this.status, this.createdAt, this.userId, });

  final String? title;
  final TodoStatus? status;
  final DateTime? createdAt;
  final int? userId;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (title != null) {
      data['title'] = title;
    }
    if (status != null) {
      data['status'] = _enumName(status);
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }
    if (userId != null) {
      data['userId'] = userId;
    }
    return Map<String, Object?>.unmodifiable(data);
  }
}

class TodoCreateWithoutUserInput {
  const TodoCreateWithoutUserInput({this.id, required this.title, required this.status, this.createdAt, });

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

class UserCreateNestedOneWithoutTodosInput {
  const UserCreateNestedOneWithoutTodosInput({this.create});

  final UserCreateWithoutTodosInput? create;

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

