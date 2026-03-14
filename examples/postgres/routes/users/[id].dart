import 'dart:io';

import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';
import 'package:comon_orm_postgres_example/src/app_database.dart';
import 'package:comon_orm_postgres_example/src/enum_parsing.dart';
import 'package:comon_orm_postgres_example/src/http_utils.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String idParam) async {
  final id = int.tryParse(idParam);
  if (id == null) {
    return errorResponse(HttpStatus.badRequest, 'Invalid user id.');
  }

  return switch (context.request.method) {
    HttpMethod.get => _getUser(id),
    HttpMethod.patch => _updateUser(context, id),
    HttpMethod.delete => _deleteUser(id),
    _ => Future<Response>.value(
      errorResponse(HttpStatus.methodNotAllowed, 'Method not allowed.'),
    ),
  };
}

Future<Response> _getUser(int id) async {
  final client = await AppDatabase.instance.client();
  final user = await client.user.findUnique(
    where: UserWhereUniqueInput(id: id),
    include: const UserInclude(todos: true),
  );
  if (user == null) {
    return errorResponse(HttpStatus.notFound, 'User not found.');
  }
  return jsonResponse(user.toRecord());
}

Future<Response> _updateUser(RequestContext context, int id) async {
  try {
    final body = await readJsonObject(context);
    final name = body['name'] == null ? null : ('${body['name']}').trim();
    final role = parseUserRole(body['role']);
    if (name != null && name.isEmpty) {
      return errorResponse(HttpStatus.badRequest, 'Field "name" is required.');
    }
    if (name == null && role == null) {
      return errorResponse(
        HttpStatus.badRequest,
        'Provide at least one of: name, role.',
      );
    }

    final client = await AppDatabase.instance.client();
    final existing = await client.user.findUnique(
      where: UserWhereUniqueInput(id: id),
    );
    if (existing == null) {
      return errorResponse(HttpStatus.notFound, 'User not found.');
    }

    final updated = await client.user.update(
      where: UserWhereUniqueInput(id: id),
      data: UserUpdateInput(name: name, role: role),
      include: const UserInclude(todos: true),
    );
    return jsonResponse(updated.toRecord());
  } on HttpException catch (error) {
    return errorResponse(HttpStatus.badRequest, error.message);
  }
}

Future<Response> _deleteUser(int id) async {
  final client = await AppDatabase.instance.client();
  final existing = await client.user.findUnique(
    where: UserWhereUniqueInput(id: id),
  );
  if (existing == null) {
    return errorResponse(HttpStatus.notFound, 'User not found.');
  }

  await client.transaction((tx) async {
    await tx.todo.deleteMany(where: TodoWhereInput(userId: id));
    await tx.user.delete(where: UserWhereUniqueInput(id: id));
    return null;
  });
  return jsonResponse(<String, Object?>{'deleted': true, 'id': id});
}
