import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final client = GeneratedComonOrmClient.openInMemory();

  final user = await client.user.create(
    data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
  );

  print('created: ${user.email}');
}
