import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';
import 'package:comon_orm_postgres_example/src/app_database.dart';
import 'package:comon_orm_postgres_example/src/enum_parsing.dart';
import 'package:comon_orm_postgres_example/src/http_utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _listTodos(context),
    HttpMethod.post => _createTodo(context),
    _ => Future<Response>.value(
      errorResponse(HttpStatus.methodNotAllowed, 'Method not allowed.'),
    ),
  };
}

Future<Response> _listTodos(RequestContext context) async {
  final client = await AppDatabase.instance.client();
  final query = context.request.uri.queryParameters;
  final userId = int.tryParse(query['userId'] ?? '');
  final status = parseTodoStatus(
    query['status'],
    completedValue: query['completed'] == null
        ? null
        : query['completed'] == 'true',
  );

  final where = TodoWhereInput(userId: userId, status: status);

  final todos = await client.todo.findMany(
    where: userId == null && status == null ? null : where,
    include: const TodoInclude(user: true),
    orderBy: const <TodoOrderByInput>[TodoOrderByInput(id: SortOrder.asc)],
  );
  return jsonResponse(
    todos.map((todo) => todo.toRecord()).toList(growable: false),
  );
}

Future<Response> _createTodo(RequestContext context) async {
  try {
    final body = await readJsonObject(context);
    final title = ('${body['title'] ?? ''}').trim();
    final userId = body['userId'] is int
        ? body['userId'] as int
        : int.tryParse('${body['userId'] ?? ''}');
    final status =
        parseTodoStatus(body['status'], completedValue: body['completed']) ??
        TodoStatus.pending;

    if (title.isEmpty) {
      return errorResponse(HttpStatus.badRequest, 'Field "title" is required.');
    }
    if (userId == null) {
      return errorResponse(
        HttpStatus.badRequest,
        'Field "userId" is required.',
      );
    }

    final client = await AppDatabase.instance.client();
    final owner = await client.user.findUnique(
      where: UserWhereUniqueInput(id: userId),
    );
    if (owner == null) {
      return errorResponse(HttpStatus.badRequest, 'User does not exist.');
    }

    final todo = await client.todo.create(
      data: TodoCreateInput(title: title, status: status, userId: userId),
      include: const TodoInclude(user: true),
    );
    return jsonResponse(todo.toRecord(), statusCode: HttpStatus.created);
  } on HttpException catch (error) {
    return errorResponse(HttpStatus.badRequest, error.message);
  }
}
