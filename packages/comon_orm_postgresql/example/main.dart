import 'dart:io';

import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final connectionUrl = Platform.environment['DATABASE_URL'];
  if (connectionUrl == null || connectionUrl.isEmpty) {
    stderr.writeln('Set DATABASE_URL before running this example.');
    exitCode = 64;
    return;
  }

  // PostgreSQL adapter openers create a package:postgres pool internally.
  final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
    schema: GeneratedComonOrmClient.runtimeSchema,
    connectionUrl: connectionUrl,
  );
  final client = GeneratedComonOrmClient(adapter: adapter);

  try {
    final user = await client.user.create(
      data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
    );

    print('created: ${user.email}');
  } finally {
    await client.close();
  }
}
