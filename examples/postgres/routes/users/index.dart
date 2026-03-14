import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';
import 'package:comon_orm_postgres_example/src/app_database.dart';
import 'package:comon_orm_postgres_example/src/enum_parsing.dart';
import 'package:comon_orm_postgres_example/src/http_utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _listUsers(context),
    HttpMethod.post => _createUser(context),
    _ => Future<Response>.value(
      errorResponse(HttpStatus.methodNotAllowed, 'Method not allowed.'),
    ),
  };
}

Future<Response> _listUsers(RequestContext context) async {
  final client = await AppDatabase.instance.client();
  final queryRole = parseUserRole(context.request.uri.queryParameters['role']);
  final users = await client.user.findMany(
    where: queryRole == null ? null : UserWhereInput(role: queryRole),
    include: const UserInclude(todos: true),
    orderBy: const <UserOrderByInput>[UserOrderByInput(id: SortOrder.asc)],
  );
  return jsonResponse(
    users.map((user) => user.toRecord()).toList(growable: false),
  );
}

Future<Response> _createUser(RequestContext context) async {
  try {
    final body = await readJsonObject(context);
    final name = (body['name'] as String?)?.trim();
    final role = parseUserRole(body['role']) ?? UserRole.developer;
    if (name == null || name.isEmpty) {
      return errorResponse(HttpStatus.badRequest, 'Field "name" is required.');
    }

    final todos = body['todos'];
    final nestedTodos = switch (todos) {
      List<Object?>() =>
        todos
            .whereType<Map<Object?, Object?>>()
            .map((item) {
              final title = ('${item['title'] ?? ''}').trim();
              if (title.isEmpty) {
                throw const HttpException('Todo title is required.');
              }
              final status =
                  parseTodoStatus(
                    item['status'],
                    completedValue: item['completed'],
                  ) ??
                  TodoStatus.pending;
              return TodoCreateWithoutUserInput(title: title, status: status);
            })
            .toList(growable: false),
      _ => const <TodoCreateWithoutUserInput>[],
    };

    final client = await AppDatabase.instance.client();
    final user = await client.user.create(
      data: UserCreateInput(
        name: name,
        role: role,
        todos: nestedTodos.isEmpty
            ? null
            : TodoCreateNestedManyWithoutUserInput(create: nestedTodos),
      ),
      include: const UserInclude(todos: true),
    );
    return jsonResponse(user.toRecord(), statusCode: HttpStatus.created);
  } on HttpException catch (error) {
    return errorResponse(HttpStatus.badRequest, error.message);
  }
}
