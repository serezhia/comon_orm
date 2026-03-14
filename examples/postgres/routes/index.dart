import 'dart:io';

import 'package:comon_orm_postgres_example/src/http_utils.dart';
import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return errorResponse(HttpStatus.methodNotAllowed, 'Method not allowed.');
  }

  return jsonResponse(<String, Object?>{
    'service': 'comon_orm_postgres_example',
    'routes': <String>[
      'GET /users',
      'POST /users',
      'GET /users/:id',
      'PATCH /users/:id',
      'DELETE /users/:id',
      'GET /todos',
      'POST /todos',
      'GET /todos/:id',
      'PATCH /todos/:id',
      'DELETE /todos/:id',
    ],
  });
}
