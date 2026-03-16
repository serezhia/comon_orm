import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final client = await GeneratedComonOrmClientPostgresql.open();

  try {
    final user = await client.user.create(
      data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
    );

    print('created: ${user.email}');
  } finally {
    await client.close();
  }
}
