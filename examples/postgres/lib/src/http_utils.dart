import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

int? pathId(Request request) {
  final segments = request.uri.pathSegments;
  if (segments.isEmpty) {
    return null;
  }
  return int.tryParse(segments.last);
}

Future<Map<String, Object?>> readJsonObject(RequestContext context) async {
  final decoded = await context.request.json();
  if (decoded is Map<String, dynamic>) {
    return Map<String, Object?>.from(decoded);
  }
  if (decoded is Map<Object?, Object?>) {
    return decoded.map((key, value) => MapEntry('$key', value));
  }
  throw const HttpException('Expected JSON object body.');
}

Response jsonResponse(Object? body, {int statusCode = HttpStatus.ok}) {
  return Response(
    statusCode: statusCode,
    body: jsonEncode(_normalizeJson(body)),
    headers: const <String, Object>{
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    },
  );
}

Response errorResponse(int statusCode, String message) {
  return jsonResponse(<String, Object?>{
    'error': message,
  }, statusCode: statusCode);
}

Object? _normalizeJson(Object? value) {
  if (value is DateTime) {
    return value.toUtc().toIso8601String();
  }
  if (value is BigInt) {
    return value.toString();
  }
  if (value is List<Object?>) {
    return value.map(_normalizeJson).toList(growable: false);
  }
  if (value is Map<String, Object?>) {
    return value.map(
      (key, nestedValue) => MapEntry(key, _normalizeJson(nestedValue)),
    );
  }
  if (value is Iterable<Object?>) {
    return value.map(_normalizeJson).toList(growable: false);
  }
  return value;
}
