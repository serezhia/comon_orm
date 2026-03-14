import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:test/test.dart';
import 'dart:io';

void main() {
  test('exports sqlite adapter scaffold', () {
    final adapter = SqliteDatabaseAdapter.openInMemory(
      schema: const SchemaParser().parse('''
model User {
  id Int @id
}
'''),
    );
    expect(adapter, isA<SqliteDatabaseAdapter>());
    adapter.dispose();
  });

  test('opens sqlite adapter from schema path', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'comon_orm_sqlite_open_',
    );
    try {
      final schemaPath =
          '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
      final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';
      File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "${databasePath.replaceAll(r'\\', '/')}"
}

model User {
  id Int @id
}
''');

      late String openedDatabasePath;
      late SchemaDocument openedSchema;

      final adapter = await SqliteDatabaseAdapter.openFromSchemaPath(
        schemaPath: schemaPath,
        adapterFactory: ({required databasePath, required schema}) {
          openedDatabasePath = databasePath;
          openedSchema = schema;
          return SqliteDatabaseAdapter.openInMemory(schema: schema);
        },
      );

      expect(adapter, isA<SqliteDatabaseAdapter>());
      expect(openedDatabasePath, databasePath);
      expect(openedSchema.findModel('User'), isNotNull);
      adapter.dispose();
    } finally {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test('opens and applies sqlite adapter from schema path', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'comon_orm_sqlite_open_apply_',
    );
    try {
      final schemaPath =
          '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
      File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id Int @id
  email String @unique
}
''');

      final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
        schemaPath: schemaPath,
      );

      try {
        final created = await adapter.create(
          const CreateQuery(
            model: 'User',
            data: <String, Object?>{'id': 1, 'email': 'alice@example.com'},
          ),
        );

        expect(created['email'], 'alice@example.com');
        expect(await adapter.count(const CountQuery(model: 'User')), 1);
      } finally {
        adapter.dispose();
      }
    } finally {
      tempRoot.deleteSync(recursive: true);
    }
  });
}
