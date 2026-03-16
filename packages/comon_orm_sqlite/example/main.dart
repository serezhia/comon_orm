import 'dart:io';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  const databasePath = 'example/example.db';
  _requireExistingDatabase(databasePath);
  final client = await _openClient(databasePath: databasePath);
  try {
    final user = await client.user.create(
      data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
    );

    print('created: ${user.email}');
  } finally {
    await client.close();
  }
}

Future<GeneratedComonOrmClient> _openClient({required String databasePath}) {
  return GeneratedComonOrmClientSqlite.open(databasePath: databasePath);
}

void _requireExistingDatabase(String databasePath) {
  if (File(databasePath).existsSync()) {
    return;
  }

  throw StateError(
    'Missing SQLite database at $databasePath. '
    'Create it through the migration/apply tooling before running this example.',
  );
}
