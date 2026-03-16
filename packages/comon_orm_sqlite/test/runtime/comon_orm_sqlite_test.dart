import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

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
    adapter.close();
  });

  test('opens sqlite adapter from generated schema metadata', () async {
    late String openedDatabasePath;
    late RuntimeSchemaView openedSchema;

    final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(
      schema: const GeneratedRuntimeSchema(
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'sqlite',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.literal,
              value: 'file:dev.db',
            ),
          ),
        ],
        models: <GeneratedModelMetadata>[],
      ),
      schemaPath: '/app/prisma/schema.prisma',
      adapterFactory: ({required databasePath, required schema}) {
        openedDatabasePath = databasePath;
        openedSchema = schema;
        return SqliteDatabaseAdapter.fromRuntimeSchema(
          database: sqlite.sqlite3.openInMemory(),
          schema: schema,
        );
      },
    );

    expect(adapter, isA<SqliteDatabaseAdapter>());
    expect(openedDatabasePath, '/app/prisma/dev.db');
    expect(openedSchema.findDatasource('db'), isNotNull);
    adapter.close();
  });

  test(
    'runtime datasource resolution still allows explicit file override',
    () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_sqlite_runtime_open_',
      );
      try {
        final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';

        late String openedDatabasePath;

        final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(
          schema: const GeneratedRuntimeSchema(
            datasources: <GeneratedDatasourceMetadata>[
              GeneratedDatasourceMetadata(
                name: 'db',
                provider: 'sqlite',
                url: GeneratedDatasourceUrl(
                  kind: GeneratedDatasourceUrlKind.literal,
                  value: 'file:dev.db',
                ),
              ),
            ],
            models: <GeneratedModelMetadata>[],
          ),
          databasePath: databasePath,
          adapterFactory: ({required databasePath, required schema}) {
            openedDatabasePath = databasePath;
            return SqliteDatabaseAdapter.fromRuntimeSchema(
              database: sqlite.sqlite3.openInMemory(),
              schema: schema,
            );
          },
        );

        expect(openedDatabasePath, databasePath);
        adapter.close();
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    },
  );
}
