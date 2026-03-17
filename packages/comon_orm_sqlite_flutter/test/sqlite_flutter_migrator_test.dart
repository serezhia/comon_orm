import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqliteFlutterMigrator', () {
    test('runs schema-diff migrations for additive changes', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final fromSchema = const SchemaParser().parse('''
model User {
  id Int @id
  email String @unique
}
''');
        final toSchema = const SchemaParser().parse('''
model User {
  id Int @id
  email String @unique
  enabled Boolean @default(false)
}
''');

        await const SqliteFlutterSchemaApplier().apply(database, fromSchema);
        await database.insert('User', <String, Object?>{
          'id': 1,
          'email': 'alice@example.com',
        });
        await database.execute('PRAGMA user_version = 1;');

        final migrator = SqliteFlutterMigrator(
          currentVersion: 2,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.schemaDiff(
              fromVersion: 1,
              toVersion: 2,
              debugName: 'add_enabled_flag',
              fromSchema: fromSchema,
              toSchema: toSchema,
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT email, enabled FROM User WHERE id = 1;',
        );
        expect(rows.single['email'], 'alice@example.com');
        expect(rows.single['enabled'], 0);
        expect(await migrator.readVersion(database), 2);
      } finally {
        await database.close();
      }
    });

    test('runs schema-diff migrations for rebuild changes', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final fromSchema = const SchemaParser().parse('''
model Todo {
  id Int @id
  title String
}
''');
        final toSchema = const SchemaParser().parse('''
model Todo {
  id Int @id
  title String

  @@map("todos")
}
''');

        await const SqliteFlutterSchemaApplier().apply(database, fromSchema);
        await database.insert('Todo', <String, Object?>{
          'id': 1,
          'title': 'Ship web migrations',
        });
        await database.execute('PRAGMA user_version = 2;');

        final migrator = SqliteFlutterMigrator(
          currentVersion: 3,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.schemaDiff(
              fromVersion: 2,
              toVersion: 3,
              debugName: 'rename_todo_table',
              fromSchema: fromSchema,
              toSchema: toSchema,
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT title FROM todos WHERE id = 1;',
        );
        expect(rows.single['title'], 'Ship web migrations');

        final oldTable = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'Todo';",
        );
        expect(oldTable, isEmpty);
        expect(await migrator.readVersion(database), 3);
      } finally {
        await database.close();
      }
    });

    test('runs SQL-first migrations and updates user_version', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, full_name TEXT NOT NULL);',
        );
        await database.insert('users', <String, Object?>{
          'id': 1,
          'full_name': 'Alice Example',
        });
        await database.execute('PRAGMA user_version = 1;');

        final migrator = SqliteFlutterMigrator(
          currentVersion: 2,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.sql(
              fromVersion: 1,
              toVersion: 2,
              debugName: 'split_user_name',
              statements: <String>[
                'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
                'ALTER TABLE users ADD COLUMN last_name TEXT NOT NULL DEFAULT "";',
              ],
              afterSql: (tx) async {
                final rows = await tx.rawQuery(
                  'SELECT id, full_name FROM users;',
                );
                for (final row in rows) {
                  await tx.update(
                    'users',
                    <String, Object?>{
                      'first_name': 'Alice',
                      'last_name': 'Example',
                    },
                    where: 'id = ?',
                    whereArgs: <Object?>[row['id']],
                  );
                }
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT first_name, last_name FROM users WHERE id = 1;',
        );
        expect(rows.single['first_name'], 'Alice');
        expect(rows.single['last_name'], 'Example');
        expect(await migrator.readVersion(database), 2);
      } finally {
        await database.close();
      }
    });

    test('runs custom Dart migration for rebuild-heavy data moves', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            is_done INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          );
        ''');
        await database.insert('todos', <String, Object?>{
          'id': 1,
          'title': 'Ship API',
          'description': 'Before rebuild',
          'is_done': 1,
          'created_at': '2026-03-16T10:00:00.000Z',
          'updated_at': '2026-03-16T10:00:00.000Z',
        });
        await database.execute('PRAGMA user_version = 2;');

        final migrator = SqliteFlutterMigrator(
          currentVersion: 3,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.rebuildTable(
              fromVersion: 2,
              toVersion: 3,
              debugName: 'rebuild_todos',
              tableName: 'todos',
              createReplacementTableSql: '''
                  CREATE TABLE todos_new (
                    id INTEGER PRIMARY KEY,
                    title TEXT NOT NULL,
                    note TEXT,
                    status TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                  );
                ''',
              replacementTableName: 'todos_new',
              copyData: (tx, sourceTable, targetTable) async {
                final oldRows = await tx.rawQuery(
                  'SELECT id, title, description, is_done, created_at, updated_at FROM $sourceTable;',
                );
                for (final row in oldRows) {
                  await tx.insert(targetTable, <String, Object?>{
                    'id': row['id'],
                    'title': row['title'],
                    'note': row['description'],
                    'status': row['is_done'] == 1 ? 'done' : 'todo',
                    'created_at': row['created_at'],
                    'updated_at': row['updated_at'],
                  });
                }
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT title, note, status FROM todos WHERE id = 1;',
        );
        expect(rows.single['title'], 'Ship API');
        expect(rows.single['note'], 'Before rebuild');
        expect(rows.single['status'], 'done');
        expect(await migrator.readVersion(database), 3);
      } finally {
        await database.close();
      }
    });

    test('can inspect pending migrations before running upgrade', () async {
      final migrator = SqliteFlutterMigrator(
        currentVersion: 3,
        migrations: <SqliteFlutterMigration>[
          SqliteFlutterMigration.sql(
            fromVersion: 1,
            toVersion: 2,
            debugName: 'step_one',
            statements: <String>[
              'CREATE TABLE users (id INTEGER PRIMARY KEY);',
            ],
          ),
          SqliteFlutterMigration.sql(
            fromVersion: 2,
            toVersion: 3,
            debugName: 'step_two',
            statements: <String>[
              'CREATE TABLE todos (id INTEGER PRIMARY KEY);',
            ],
          ),
        ],
      );

      final pending = migrator.pendingMigrationsFrom(1);
      expect(pending.map((migration) => migration.debugName).toList(), <String>[
        'step_one',
        'step_two',
      ]);
    });

    test('upgradeDatabasePath opens, upgrades, and closes the database', () async {
      sqfliteFfiInit();

      final databasePath =
          '${await databaseFactoryFfi.getDatabasesPath()}/sqlite_flutter_migrator_test.db';
      await databaseFactoryFfi.deleteDatabase(databasePath);

      final database = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await database.execute(
        'CREATE TABLE users (id INTEGER PRIMARY KEY, full_name TEXT NOT NULL);',
      );
      await database.insert('users', <String, Object?>{
        'id': 1,
        'full_name': 'Alice Example',
      });
      await database.execute('PRAGMA user_version = 1;');
      await database.close();

      final migrator = SqliteFlutterMigrator(
        currentVersion: 2,
        migrations: <SqliteFlutterMigration>[
          SqliteFlutterMigration.sql(
            fromVersion: 1,
            toVersion: 2,
            debugName: 'add_first_name',
            statements: <String>[
              'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
            ],
            afterSql: (tx) async {
              await tx.update(
                'users',
                <String, Object?>{'first_name': 'Alice'},
                where: 'id = ?',
                whereArgs: <Object?>[1],
              );
            },
          ),
        ],
      );

      await upgradeSqliteFlutterDatabase(
        databasePath: databasePath,
        databaseFactory: databaseFactoryFfi,
        migrator: migrator,
      );

      final reopened = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      try {
        final rows = await reopened.rawQuery(
          'SELECT first_name FROM users WHERE id = 1;',
        );
        expect(rows.single['first_name'], 'Alice');
        expect(await migrator.readVersion(reopened), 2);
      } finally {
        await reopened.close();
        await databaseFactoryFfi.deleteDatabase(databasePath);
      }
    });
  });
}
