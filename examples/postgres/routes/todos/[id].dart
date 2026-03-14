import 'dart:io';

import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';
import 'package:comon_orm_postgres_example/src/app_database.dart';
import 'package:comon_orm_postgres_example/src/enum_parsing.dart';
import 'package:comon_orm_postgres_example/src/http_utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String idParam) async {
  final id = int.tryParse(idParam);
  if (id == null) {
    return errorResponse(HttpStatus.badRequest, 'Invalid todo id.');
  }

  return switch (context.request.method) {
    HttpMethod.get => _getTodo(id),
    HttpMethod.patch => _updateTodo(context, id),
    HttpMethod.delete => _deleteTodo(id),
    _ => Future<Response>.value(
      errorResponse(HttpStatus.methodNotAllowed, 'Method not allowed.'),
    ),
  };
}

Future<Response> _getTodo(int id) async {
  final client = await AppDatabase.instance.client();
  final todo = await client.todo.findUnique(
    where: TodoWhereUniqueInput(id: id),
    include: const TodoInclude(user: true),
  );
  if (todo == null) {
    return errorResponse(HttpStatus.notFound, 'Todo not found.');
  }
  return jsonResponse(todo.toRecord());
}

Future<Response> _updateTodo(RequestContext context, int id) async {
  try {
    final body = await readJsonObject(context);
    final title = body['title'] == null ? null : ('${body['title']}').trim();
    final status = parseTodoStatus(
      body['status'],
      completedValue: body['completed'],
    );

    if (title != null && title.isEmpty) {
      return errorResponse(
        HttpStatus.badRequest,
        'Field "title" cannot be empty.',
      );
    }
    if (title == null && status == null) {
      return errorResponse(
        HttpStatus.badRequest,
        'Provide at least one of: title, status.',
      );
    }

    final client = await AppDatabase.instance.client();
    final existing = await client.todo.findUnique(
      where: TodoWhereUniqueInput(id: id),
    );
    if (existing == null) {
      return errorResponse(HttpStatus.notFound, 'Todo not found.');
    }

    final updated = await client.todo.update(
      where: TodoWhereUniqueInput(id: id),
      data: TodoUpdateInput(title: title, status: status),
      include: const TodoInclude(user: true),
    );
    return jsonResponse(updated.toRecord());
  } on HttpException catch (error) {
    return errorResponse(HttpStatus.badRequest, error.message);
  }
}

Future<Response> _deleteTodo(int id) async {
  final client = await AppDatabase.instance.client();
  final existing = await client.todo.findUnique(
    where: TodoWhereUniqueInput(id: id),
  );
  if (existing == null) {
    return errorResponse(HttpStatus.notFound, 'Todo not found.');
  }

  await client.todo.delete(where: TodoWhereUniqueInput(id: id));
  return jsonResponse(<String, Object?>{'deleted': true, 'id': id});
}
