import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqliteFlutterDatabaseAdapter runtime schema', () {
    test('supports CRUD and updatedAt from generated metadata', () async {
      sqfliteFfiInit();

      const schema = GeneratedRuntimeSchema(
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'sqlite',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.literal,
              value: ':memory:',
            ),
          ),
        ],
        models: <GeneratedModelMetadata>[
          GeneratedModelMetadata(
            name: 'User',
            databaseName: 'users',
            primaryKeyFields: <String>['id'],
            fields: <GeneratedFieldMetadata>[
              GeneratedFieldMetadata(
                name: 'id',
                databaseName: 'id',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Int',
                isNullable: false,
                isList: false,
                isId: true,
              ),
              GeneratedFieldMetadata(
                name: 'email',
                databaseName: 'email_address',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'String',
                isNullable: false,
                isList: false,
                isUnique: true,
              ),
              GeneratedFieldMetadata(
                name: 'enabled',
                databaseName: 'enabled',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Boolean',
                isNullable: false,
                isList: false,
              ),
              GeneratedFieldMetadata(
                name: 'updatedAt',
                databaseName: 'updated_at',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'DateTime',
                isNullable: false,
                isList: false,
                isUpdatedAt: true,
              ),
            ],
          ),
        ],
      );

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
          singleInstance: false,
        ),
      );
      await database.execute('''
CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "email_address" TEXT NOT NULL UNIQUE,
  "enabled" INTEGER NOT NULL DEFAULT 0,
  "updated_at" TEXT NOT NULL
)
''');

      final adapter = SqliteFlutterDatabaseAdapter.fromGeneratedSchema(
        database: database,
        schema: schema,
      );
      final createdAt = DateTime.utc(2026, 3, 15, 12, 0, 0);
      final updatedAt = DateTime.utc(2026, 3, 15, 12, 5, 0);

      try {
        adapter.now = () => createdAt;

        final created = await adapter.create(
          const CreateQuery(
            model: 'User',
            data: <String, Object?>{'email': 'alice@example.com'},
          ),
        );

        expect(created['id'], isA<int>());
        expect(created['email'], 'alice@example.com');
        expect(created['enabled'], isFalse);
        expect(created['updatedAt'], createdAt);

        adapter.now = () => updatedAt;

        final changed = await adapter.update(
          UpdateQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'id',
                operator: 'equals',
                value: created['id'],
              ),
            ],
            data: const <String, Object?>{'enabled': true},
          ),
        );

        expect(changed['enabled'], isTrue);
        expect(changed['updatedAt'], updatedAt);

        final fetched = await adapter.findUnique(
          const FindUniqueQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'equals',
                value: 'alice@example.com',
              ),
            ],
          ),
        );

        expect(fetched, isNotNull);
        expect(fetched!['enabled'], isTrue);
      } finally {
        await adapter.close();
      }
    });
  });
}
