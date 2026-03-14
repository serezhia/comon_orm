import 'package:comon_orm/comon_orm.dart';

import 'generated/comon_orm_client.dart';

const workflow = SchemaWorkflow();

Future<void> main() async {
  final loaded = await workflow.loadValidatedSchema('example/schema.prisma');

  final adapter = InMemoryDatabaseAdapter(schema: loaded.schema);
  final client = GeneratedComonOrmClient(adapter: adapter);

  final user = await client.user.create(
    data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
  );

  print('created: ${user.email}');
}
