import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await PostgresqlDatabaseAdapter.openAndApplyFromSchemaPath(
    schemaPath: 'example/schema.prisma',
  );

  try {
    final client = GeneratedComonOrmClient(adapter: adapter);
    final user = await client.user.create(
      data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
    );

    print('created: ${user.email}');
  } finally {
    await adapter.close();
  }
}
