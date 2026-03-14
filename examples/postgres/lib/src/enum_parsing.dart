import 'dart:io';

import 'package:comon_orm_postgres_example/generated/comon_orm_client.dart';

UserRole? parseUserRole(Object? rawValue, {bool allowNull = true}) {
  if (rawValue == null) {
    if (allowNull) {
      return null;
    }
    throw const HttpException('Field "role" is required.');
  }

  final normalized = '$rawValue'.trim();
  if (normalized.isEmpty) {
    if (allowNull) {
      return null;
    }
    throw const HttpException('Field "role" is required.');
  }

  for (final role in UserRole.values) {
    if (role.name.toLowerCase() == normalized.toLowerCase()) {
      return role;
    }
  }

  throw HttpException(
    'Invalid role "$normalized". Expected one of: ${UserRole.values.map((entry) => entry.name).join(', ')}.',
  );
}

TodoStatus? parseTodoStatus(
  Object? rawValue, {
  Object? completedValue,
  bool allowNull = true,
}) {
  if (rawValue == null) {
    if (completedValue is bool) {
      return completedValue ? TodoStatus.done : TodoStatus.pending;
    }
    if (allowNull) {
      return null;
    }
    throw const HttpException('Field "status" is required.');
  }

  final normalized = '$rawValue'.trim();
  if (normalized.isEmpty) {
    if (allowNull) {
      return null;
    }
    throw const HttpException('Field "status" is required.');
  }

  for (final status in TodoStatus.values) {
    if (status.name.toLowerCase() == normalized.toLowerCase()) {
      return status;
    }
  }

  throw HttpException(
    'Invalid status "$normalized". Expected one of: ${TodoStatus.values.map((entry) => entry.name).join(', ')}.',
  );
}
