import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
    schemaPath: 'example/schema.prisma',
  );
  try {
    final client = GeneratedComonOrmClient(adapter: adapter);

    final user = await client.user.create(
      data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
    );

    print('created: ${user.email}');
  } finally {
    adapter.close();
  }
}
