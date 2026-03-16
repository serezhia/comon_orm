// Generated code. Do not edit by hand.
// ignore_for_file: unused_element, non_constant_identifier_names
import 'package:comon_orm/comon_orm.dart';

class GeneratedComonOrmClient {
  GeneratedComonOrmClient({required DatabaseAdapter adapter})
    : _client = ComonOrmClient(adapter: adapter);

  GeneratedComonOrmClient._fromClient(this._client);

  final ComonOrmClient _client;
  late final TodoDelegate todo = TodoDelegate(_client.model('Todo'));

  Future<T> transaction<T>(
    Future<T> Function(GeneratedComonOrmClient tx) action,
  ) {
    return _client.transaction((tx) => action(GeneratedComonOrmClient._fromClient(tx)));
  }
}

class Todo {
  const Todo({this.id, this.title, this.done, this.createdAt, });

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
      createdAt: createdAt == _undefined ? this.createdAt : createdAt as DateTime?,
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
  String toString() => 'Todo(id: $id, title: $title, done: $done, createdAt: $createdAt)';

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
  const TodoWhereInput({this.AND = const <TodoWhereInput>[], this.OR = const <TodoWhereInput>[], this.NOT = const <TodoWhereInput>[], this.id, this.idFilter, this.title, this.titleFilter, this.done, this.doneFilter, this.createdAt, });

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
    if (done != null) {
      predicates.add(QueryPredicate(field: 'done', operator: 'equals', value: done));
    }
    if (doneFilter != null) {
      predicates.addAll(doneFilter!.toPredicates('done'));
    }
    if (createdAt != null) {
      predicates.add(QueryPredicate(field: 'createdAt', operator: 'equals', value: createdAt));
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
  const TodoOrderByInput({this.id, this.title, this.done, this.createdAt, });

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

enum TodoScalarField {
  id,
  title,
  done,
  createdAt
}

class TodoCountAggregateInput {
  const TodoCountAggregateInput({this.all = false, this.id = false, this.title = false, this.done = false, this.createdAt = false, });

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
    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));
  }
}

class TodoAvgAggregateInput {
  const TodoAvgAggregateInput({this.id = false, });

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
  const TodoSumAggregateInput({this.id = false, });

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
  const TodoMinAggregateInput({this.id = false, this.title = false, this.done = false, this.createdAt = false, });

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
  const TodoMaxAggregateInput({this.id = false, this.title = false, this.done = false, this.createdAt = false, });

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
  const TodoCountAggregateResult({this.all, this.id, this.title, this.done, this.createdAt, });

  final int? all;
  final int? id;
  final int? title;
  final int? done;
  final int? createdAt;

  factory TodoCountAggregateResult.fromQueryCountResult(QueryCountAggregateResult result) {
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
  const TodoAvgAggregateResult({this.id, });

  final double? id;

  factory TodoAvgAggregateResult.fromMap(Map<String, double?> values) {
    return TodoAvgAggregateResult(
      id: _asDouble(values['id']),
    );
  }
}

class TodoSumAggregateResult {
  const TodoSumAggregateResult({this.id, });

  final int? id;

  factory TodoSumAggregateResult.fromMap(Map<String, num?> values) {
    return TodoSumAggregateResult(
      id: values['id']?.toInt(),
    );
  }
}

class TodoMinAggregateResult {
  const TodoMinAggregateResult({this.id, this.title, this.done, this.createdAt, });

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
  const TodoMaxAggregateResult({this.id, this.title, this.done, this.createdAt, });

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
      count: result.count == null ? null : TodoCountAggregateResult.fromQueryCountResult(result.count!),
      avg: result.avg == null ? null : TodoAvgAggregateResult.fromMap(result.avg!),
      sum: result.sum == null ? null : TodoSumAggregateResult.fromMap(result.sum!),
      min: result.min == null ? null : TodoMinAggregateResult.fromMap(result.min!),
      max: result.max == null ? null : TodoMaxAggregateResult.fromMap(result.max!),
    );
  }
}

class TodoGroupByHavingInput {
  const TodoGroupByHavingInput({this.id, });

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
  const TodoCountAggregateOrderByInput({this.all, this.id, this.title, this.done, this.createdAt, });

  final SortOrder? all;
  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

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
    if (done != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'done', direction: done!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoAvgAggregateOrderByInput {
  const TodoAvgAggregateOrderByInput({this.id, });

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoSumAggregateOrderByInput {
  const TodoSumAggregateOrderByInput({this.id, });

  final SortOrder? id;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoMinAggregateOrderByInput {
  const TodoMinAggregateOrderByInput({this.id, this.title, this.done, this.createdAt, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (done != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'done', direction: done!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoMaxAggregateOrderByInput {
  const TodoMaxAggregateOrderByInput({this.id, this.title, this.done, this.createdAt, });

  final SortOrder? id;
  final SortOrder? title;
  final SortOrder? done;
  final SortOrder? createdAt;

  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {
    final orderings = <GroupByOrderBy>[];
    if (id != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'id', direction: id!));
    }
    if (title != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'title', direction: title!));
    }
    if (done != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'done', direction: done!));
    }
    if (createdAt != null) {
      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: 'createdAt', direction: createdAt!));
    }
    return List<GroupByOrderBy>.unmodifiable(orderings);
  }
}

class TodoGroupByOrderByInput {
  const TodoGroupByOrderByInput({this.id, this.title, this.done, this.createdAt, this.count, this.avg, this.sum, this.min, this.max});

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
      orderings.add(GroupByOrderBy.field(field: 'createdAt', direction: createdAt!));
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
  const TodoGroupByRow({this.id, this.title, this.done, this.createdAt, this.count, this.avg, this.sum, this.min, this.max});

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
      count: row.aggregates.count == null ? null : TodoCountAggregateResult.fromQueryCountResult(row.aggregates.count!),
      avg: row.aggregates.avg == null ? null : TodoAvgAggregateResult.fromMap(row.aggregates.avg!),
      sum: row.aggregates.sum == null ? null : TodoSumAggregateResult.fromMap(row.aggregates.sum!),
      min: row.aggregates.min == null ? null : TodoMinAggregateResult.fromMap(row.aggregates.min!),
      max: row.aggregates.max == null ? null : TodoMaxAggregateResult.fromMap(row.aggregates.max!),
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
  const TodoSelect({this.id = false, this.title = false, this.done = false, this.createdAt = false, });

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
  const TodoCreateInput({this.id, required this.title, this.done, required this.createdAt, });

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

  List<CreateRelationWrite> toNestedCreates() {
    final writes = <CreateRelationWrite>[];
    return List<CreateRelationWrite>.unmodifiable(writes);
  }
}

class TodoUpdateInput {
  const TodoUpdateInput({this.title, this.done, this.createdAt, });

  final String? title;
  final bool? done;
  final DateTime? createdAt;

  Map<String, Object?> toData() {
    final data = <String, Object?>{};
    if (title != null) {
      data['title'] = title;
    }
    if (done != null) {
      data['done'] = done;
    }
    if (createdAt != null) {
      data['createdAt'] = createdAt;
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

