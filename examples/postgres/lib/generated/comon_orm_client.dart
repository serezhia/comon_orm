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
    return _client.transaction(
      (tx) => action(GeneratedComonOrmClient._fromClient(tx)),
    );
  }
}

enum UserRole { admin, developer, manager }

enum TodoStatus { pending, inProgress, done }

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
          ),
        ),
      );
    }
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class UserUpdateInput {
  const UserUpdateInput({this.name, this.role});

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

class TodoCreateNestedManyWithoutUserInput {
  const TodoCreateNestedManyWithoutUserInput({
    this.create = const <TodoCreateWithoutUserInput>[],
  });

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
    List<TodoOrderByInput>? orderBy,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
  }) {
    return _delegate
        .findFirst(
          FindFirstQuery(
            model: 'Todo',
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
        .then((record) => record == null ? null : Todo.fromRecord(record));
  }

  Future<List<Todo>> findMany({
    TodoWhereInput? where,
    List<TodoOrderByInput>? orderBy,
    TodoInclude? include,
    TodoSelect? select,
    int? skip,
    int? take,
  }) {
    return _delegate
        .findMany(
          FindManyQuery(
            model: 'Todo',
            where: where?.toPredicates() ?? const <QueryPredicate>[],
            orderBy:
                orderBy
                    ?.expand((entry) => entry.toQueryOrderBy())
                    .toList(growable: false) ??
                const <QueryOrderBy>[],
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
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

  Future<Todo> create({required TodoCreateInput data, TodoInclude? include}) {
    return _delegate
        .create(
          CreateQuery(
            model: 'Todo',
            data: data.toData(),
            include: include?.toQueryInclude(),
            nestedCreates: data.toNestedCreates(),
          ),
        )
        .then(Todo.fromRecord);
  }

  Future<Todo> update({
    required TodoWhereUniqueInput where,
    required TodoUpdateInput data,
    TodoInclude? include,
    TodoSelect? select,
  }) {
    return _delegate
        .update(
          UpdateQuery(
            model: 'Todo',
            where: where.toPredicates(),
            data: data.toData(),
            include: include?.toQueryInclude(),
            select: select?.toQuerySelect(),
          ),
        )
        .then(Todo.fromRecord);
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

class TodoUpdateInput {
  const TodoUpdateInput({this.title, this.status, this.createdAt, this.userId});

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
