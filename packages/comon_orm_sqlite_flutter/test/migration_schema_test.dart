import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CreateTableBuilder', () {
    test('builds simple table with typed columns', () {
      final builder = CreateTableBuilder();
      builder.integer('id').primaryKey().autoIncrement();
      builder.text('email').notNull().unique();
      builder.text('name');
      builder.boolean('active').notNull().defaultValue(true);

      final sql = builder.buildSql('users');

      expect(
        sql,
        'CREATE TABLE IF NOT EXISTS "users" '
        '("id" INTEGER PRIMARY KEY AUTOINCREMENT, '
        '"email" TEXT NOT NULL UNIQUE, '
        '"name" TEXT, '
        '"active" INTEGER NOT NULL DEFAULT 1)',
      );
    });

    test('builds table with id() shortcut', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.text('title').notNull();

      final sql = builder.buildSql('todos');

      expect(sql, contains('"id" INTEGER PRIMARY KEY AUTOINCREMENT'));
      expect(sql, contains('"title" TEXT NOT NULL'));
    });

    test('builds table with timestamps and softDeletes', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.text('email').notNull();
      builder.timestamps();
      builder.softDeletes();

      final sql = builder.buildSql('users');

      expect(sql, contains('"created_at" TEXT NOT NULL'));
      expect(sql, contains('"updated_at" TEXT NOT NULL'));
      expect(sql, contains('"deleted_at" TEXT'));
      expect(sql, isNot(contains('"deleted_at" TEXT NOT NULL')));
    });

    test('builds table with compound primary key', () {
      final builder = CreateTableBuilder();
      builder.integer('post_id').notNull();
      builder.integer('tag_id').notNull();
      builder.primaryKey(['post_id', 'tag_id']);

      final sql = builder.buildSql('post_tags');

      expect(sql, contains('PRIMARY KEY ("post_id", "tag_id")'));
      // Inline PRIMARY KEY should be suppressed
      expect(sql, isNot(contains('INTEGER PRIMARY KEY,')));
    });

    test('builds table with compound unique constraint', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.text('first_name').notNull();
      builder.text('last_name').notNull();
      builder.unique(['first_name', 'last_name']);

      final sql = builder.buildSql('people');

      expect(sql, contains('UNIQUE ("first_name", "last_name")'));
    });

    test('builds table with foreign key', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder
          .integer('user_id')
          .notNull()
          .foreignKey('users', 'id', onDelete: 'CASCADE');

      final sql = builder.buildSql('posts');

      expect(sql, contains('"user_id" INTEGER NOT NULL'));
      expect(
        sql,
        contains(
          'FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE',
        ),
      );
    });

    test('builds table with check constraint', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.integer('age').notNull().check('"age" >= 0');

      final sql = builder.buildSql('people');

      expect(sql, contains('CHECK ("age" >= 0)'));
    });

    test('renders string default value correctly', () {
      final builder = CreateTableBuilder();
      builder.text('status').notNull().defaultValue('pending');

      final sql = builder.buildSql('tasks');

      expect(sql, contains("DEFAULT 'pending'"));
    });

    test('renders boolean default values as 0/1', () {
      final builder = CreateTableBuilder();
      builder.boolean('active').notNull().defaultValue(true);
      builder.boolean('deleted').notNull().defaultValue(false);

      final sql = builder.buildSql('flags');

      expect(sql, contains('DEFAULT 1'));
      expect(sql, contains('DEFAULT 0'));
    });

    test('renders numeric default values', () {
      final builder = CreateTableBuilder();
      builder.integer('count').notNull().defaultValue(0);
      builder.real('score').notNull().defaultValue(1.5);

      final sql = builder.buildSql('stats');

      expect(sql, contains('"count" INTEGER NOT NULL DEFAULT 0'));
      expect(sql, contains('"score" REAL NOT NULL DEFAULT 1.5'));
    });

    test('builds table with datetime columns', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.datetime('published_at');

      final sql = builder.buildSql('articles');

      // datetime is stored as TEXT
      expect(sql, contains('"published_at" TEXT'));
    });

    test('builds table with rawConstraint', () {
      final builder = CreateTableBuilder();
      builder.id();
      builder.integer('min_val').notNull();
      builder.integer('max_val').notNull();
      builder.rawConstraint('CHECK ("min_val" <= "max_val")');

      final sql = builder.buildSql('ranges');

      expect(sql, contains('CHECK ("min_val" <= "max_val")'));
    });
  });

  group('AlterTableBuilder', () {
    test('builds ADD COLUMN statement', () {
      final builder = AlterTableBuilder();
      builder.text('avatar_url');

      final statements = builder.buildStatements('users');

      expect(statements, hasLength(1));
      expect(
        statements.first,
        'ALTER TABLE "users" ADD COLUMN "avatar_url" TEXT',
      );
    });

    test('builds ADD COLUMN with constraints', () {
      final builder = AlterTableBuilder();
      builder.text('status').notNull().defaultValue('active');

      final statements = builder.buildStatements('users');

      expect(
        statements.first,
        'ALTER TABLE "users" ADD COLUMN "status" TEXT NOT NULL DEFAULT \'active\'',
      );
    });

    test('builds DROP COLUMN statement', () {
      final builder = AlterTableBuilder();
      builder.dropColumn('legacy_field');

      final statements = builder.buildStatements('users');

      expect(statements, hasLength(1));
      expect(
        statements.first,
        'ALTER TABLE "users" DROP COLUMN "legacy_field"',
      );
    });

    test('builds RENAME COLUMN statement', () {
      final builder = AlterTableBuilder();
      builder.renameColumn('description', to: 'note');

      final statements = builder.buildStatements('todos');

      expect(statements, hasLength(1));
      expect(
        statements.first,
        'ALTER TABLE "todos" RENAME COLUMN "description" TO "note"',
      );
    });

    test('builds mixed operations in declaration order', () {
      final builder = AlterTableBuilder();
      builder.text('status').notNull().defaultValue('pending');
      builder.renameColumn('description', to: 'note');
      builder.dropColumn('is_done');

      final statements = builder.buildStatements('todos');

      expect(statements, hasLength(3));
      expect(statements[0], contains('ADD COLUMN "status"'));
      expect(statements[1], contains('RENAME COLUMN "description" TO "note"'));
      expect(statements[2], contains('DROP COLUMN "is_done"'));
    });
  });

  group('MigrationSchema', () {
    test('createTable creates a real table', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final schema = MigrationSchema();
        schema.createTable('users', (table) {
          table.id();
          table.text('email').notNull().unique();
          table.text('name');
          table.boolean('active').notNull().defaultValue(true);
          table.timestamps();
        });

        await schema.applyTo(database);

        await database.insert('users', <String, Object?>{
          'email': 'alice@example.com',
          'name': 'Alice',
          'active': 1,
          'created_at': '2026-03-18T00:00:00Z',
          'updated_at': '2026-03-18T00:00:00Z',
        });

        final rows = await database.rawQuery(
          'SELECT * FROM users WHERE id = 1',
        );
        expect(rows.single['email'], 'alice@example.com');
        expect(rows.single['active'], 1);
      } finally {
        await database.close();
      }
    });

    test('alterTable adds a column', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL)',
        );
        await database.insert('users', <String, Object?>{
          'id': 1,
          'email': 'alice@example.com',
        });

        final schema = MigrationSchema();
        schema.alterTable('users', (table) {
          table.text('avatar_url');
        });

        await schema.applyTo(database);

        await database.update(
          'users',
          <String, Object?>{'avatar_url': 'https://example.com/alice.png'},
          where: 'id = ?',
          whereArgs: [1],
        );

        final rows = await database.rawQuery(
          'SELECT avatar_url FROM users WHERE id = 1',
        );
        expect(rows.single['avatar_url'], 'https://example.com/alice.png');
      } finally {
        await database.close();
      }
    });

    test('alterTable renames a column', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE todos (id INTEGER PRIMARY KEY, description TEXT)',
        );
        await database.insert('todos', <String, Object?>{
          'id': 1,
          'description': 'Ship it',
        });

        final schema = MigrationSchema();
        schema.alterTable('todos', (table) {
          table.renameColumn('description', to: 'note');
        });

        await schema.applyTo(database);

        final rows = await database.rawQuery(
          'SELECT note FROM todos WHERE id = 1',
        );
        expect(rows.single['note'], 'Ship it');
      } finally {
        await database.close();
      }
    });

    test('alterTable drops a column', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL, legacy TEXT)',
        );

        final schema = MigrationSchema();
        schema.alterTable('users', (table) {
          table.dropColumn('legacy');
        });

        await schema.applyTo(database);

        final columns = await database.rawQuery('PRAGMA table_info(users)');
        final columnNames = columns.map((c) => c['name']).toList();
        expect(columnNames, containsAll(['id', 'email']));
        expect(columnNames, isNot(contains('legacy')));
      } finally {
        await database.close();
      }
    });

    test('renameTable renames a table', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE old_cache (id INTEGER PRIMARY KEY, data TEXT)',
        );
        await database.insert('old_cache', <String, Object?>{
          'id': 1,
          'data': 'cached',
        });

        final schema = MigrationSchema();
        schema.renameTable('old_cache', to: 'cache');

        await schema.applyTo(database);

        final rows = await database.rawQuery(
          'SELECT data FROM cache WHERE id = 1',
        );
        expect(rows.single['data'], 'cached');
      } finally {
        await database.close();
      }
    });

    test('dropTable drops a table', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE temp_data (id INTEGER PRIMARY KEY)',
        );

        final schema = MigrationSchema();
        schema.dropTable('temp_data');

        await schema.applyTo(database);

        final tables = await database.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'temp_data'",
        );
        expect(tables, isEmpty);
      } finally {
        await database.close();
      }
    });

    test('dropTableIfExists does not throw for missing table', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final schema = MigrationSchema();
        schema.dropTableIfExists('nonexistent');

        // Should not throw
        await schema.applyTo(database);
      } finally {
        await database.close();
      }
    });

    test('execute runs raw SQL', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, status TEXT NOT NULL DEFAULT "active")',
        );
        await database.insert('users', <String, Object?>{'id': 1});

        final schema = MigrationSchema();
        schema.execute("UPDATE users SET status = 'archived' WHERE id = 1");

        await schema.applyTo(database);

        final rows = await database.rawQuery(
          'SELECT status FROM users WHERE id = 1',
        );
        expect(rows.single['status'], 'archived');
      } finally {
        await database.close();
      }
    });

    test('createIndex adds an index to a table', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL)',
        );

        final schema = MigrationSchema();
        schema.createIndex(
          'idx_users_email',
          on: 'users',
          columns: ['email'],
          unique: true,
        );

        await schema.applyTo(database);

        final indexes = await database.rawQuery('PRAGMA index_list(users)');
        final indexNames = indexes.map((i) => i['name']).toList();
        expect(indexNames, contains('idx_users_email'));
      } finally {
        await database.close();
      }
    });

    test('dropIndex removes an index', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        await database.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY, email TEXT NOT NULL)',
        );
        await database.execute('CREATE INDEX idx_users_email ON users (email)');

        final schema = MigrationSchema();
        schema.dropIndex('idx_users_email');

        await schema.applyTo(database);

        final indexes = await database.rawQuery('PRAGMA index_list(users)');
        final indexNames = indexes.map((i) => i['name']).toList();
        expect(indexNames, isNot(contains('idx_users_email')));
      } finally {
        await database.close();
      }
    });

    test('operations execute in declaration order', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final schema = MigrationSchema();
        // 1. Create table
        schema.createTable('todos', (table) {
          table.id();
          table.text('title').notNull();
          table.boolean('is_done').notNull().defaultValue(false);
        });
        // 2. Seed data
        schema.execute(
          "INSERT INTO todos (title, is_done) VALUES ('Ship it', 0)",
        );
        // 3. Add column
        schema.alterTable('todos', (table) {
          table.text('status').notNull().defaultValue('pending');
        });
        // 4. Backfill
        schema.execute(
          "UPDATE todos SET status = CASE WHEN is_done = 1 THEN 'done' ELSE 'pending' END",
        );

        await schema.applyTo(database);

        final rows = await database.rawQuery('SELECT title, status FROM todos');
        expect(rows.single['title'], 'Ship it');
        expect(rows.single['status'], 'pending');
      } finally {
        await database.close();
      }
    });
  });

  group('SqliteFlutterMigration.schema', () {
    test('creates tables and upgrades via migrator', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final migrator = SqliteFlutterMigrator(
          currentVersion: 1,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.schema(
              fromVersion: 0,
              toVersion: 1,
              debugName: 'create_users',
              run: (schema) {
                schema.createTable('users', (table) {
                  table.id();
                  table.text('email').notNull().unique();
                  table.text('name');
                  table.boolean('active').notNull().defaultValue(true);
                  table.timestamps();
                });
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        await database.insert('users', <String, Object?>{
          'email': 'bob@example.com',
          'name': 'Bob',
          'active': 1,
          'created_at': '2026-03-18T00:00:00Z',
          'updated_at': '2026-03-18T00:00:00Z',
        });

        final rows = await database.rawQuery(
          'SELECT email, name, active FROM users WHERE id = 1',
        );
        expect(rows.single['email'], 'bob@example.com');
        expect(rows.single['name'], 'Bob');
        expect(rows.single['active'], 1);
        expect(await migrator.readVersion(database), 1);
      } finally {
        await database.close();
      }
    });

    test('chains multiple schema migrations', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final migrator = SqliteFlutterMigrator(
          currentVersion: 3,
          migrations: <SqliteFlutterMigration>[
            // v0 → v1: Create tables
            SqliteFlutterMigration.schema(
              fromVersion: 0,
              toVersion: 1,
              debugName: 'create_tables',
              run: (schema) {
                schema.createTable('users', (table) {
                  table.id();
                  table.text('email').notNull().unique();
                  table.text('full_name').notNull();
                });

                schema.createTable('posts', (table) {
                  table.id();
                  table.text('title').notNull();
                  table.text('body');
                  table
                      .integer('author_id')
                      .notNull()
                      .foreignKey('users', 'id', onDelete: 'CASCADE');
                });
              },
            ),
            // v1 → v2: Add columns + index
            SqliteFlutterMigration.schema(
              fromVersion: 1,
              toVersion: 2,
              debugName: 'add_avatar_and_index',
              run: (schema) {
                schema.alterTable('users', (table) {
                  table.text('avatar_url');
                });
                schema.createIndex(
                  'idx_posts_author',
                  on: 'posts',
                  columns: ['author_id'],
                );
              },
            ),
            // v2 → v3: Rename column
            SqliteFlutterMigration.schema(
              fromVersion: 2,
              toVersion: 3,
              debugName: 'rename_full_name',
              run: (schema) {
                schema.alterTable('users', (table) {
                  table.renameColumn('full_name', to: 'display_name');
                });
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        // Insert data using the final schema
        await database.insert('users', <String, Object?>{
          'email': 'alice@example.com',
          'display_name': 'Alice',
          'avatar_url': 'https://example.com/alice.png',
        });
        await database.insert('posts', <String, Object?>{
          'title': 'Hello',
          'body': 'World',
          'author_id': 1,
        });

        final users = await database.rawQuery(
          'SELECT display_name, avatar_url FROM users WHERE id = 1',
        );
        expect(users.single['display_name'], 'Alice');
        expect(users.single['avatar_url'], 'https://example.com/alice.png');

        final posts = await database.rawQuery(
          'SELECT title FROM posts WHERE author_id = 1',
        );
        expect(posts.single['title'], 'Hello');

        expect(await migrator.readVersion(database), 3);
      } finally {
        await database.close();
      }
    });

    test('mixes .schema() with other migration types', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final migrator = SqliteFlutterMigrator(
          currentVersion: 2,
          migrations: <SqliteFlutterMigration>[
            // v0 → v1: Dart-coded schema migration
            SqliteFlutterMigration.schema(
              fromVersion: 0,
              toVersion: 1,
              debugName: 'create_users',
              run: (schema) {
                schema.createTable('users', (table) {
                  table.id();
                  table.text('email').notNull();
                  table.text('full_name').notNull();
                });
              },
            ),
            // v1 → v2: Raw SQL migration (split name)
            SqliteFlutterMigration.sql(
              fromVersion: 1,
              toVersion: 2,
              debugName: 'split_name',
              statements: <String>[
                'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT ""',
                'ALTER TABLE users ADD COLUMN last_name TEXT NOT NULL DEFAULT ""',
              ],
              afterSql: (tx) async {
                await tx.execute(
                  "INSERT INTO users (email, full_name) VALUES ('alice@example.com', 'Alice Example')",
                );
                await tx.update(
                  'users',
                  <String, Object?>{
                    'first_name': 'Alice',
                    'last_name': 'Example',
                  },
                  where: 'id = ?',
                  whereArgs: [1],
                );
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT first_name, last_name FROM users WHERE id = 1',
        );
        expect(rows.single['first_name'], 'Alice');
        expect(rows.single['last_name'], 'Example');
        expect(await migrator.readVersion(database), 2);
      } finally {
        await database.close();
      }
    });

    test('compound primary key with foreign keys end-to-end', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final migrator = SqliteFlutterMigrator(
          currentVersion: 1,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.schema(
              fromVersion: 0,
              toVersion: 1,
              debugName: 'create_m2m',
              run: (schema) {
                schema.createTable('posts', (table) {
                  table.id();
                  table.text('title').notNull();
                });
                schema.createTable('tags', (table) {
                  table.id();
                  table.text('name').notNull().unique();
                });
                schema.createTable('post_tags', (table) {
                  table
                      .integer('post_id')
                      .notNull()
                      .foreignKey('posts', 'id', onDelete: 'CASCADE');
                  table
                      .integer('tag_id')
                      .notNull()
                      .foreignKey('tags', 'id', onDelete: 'CASCADE');
                  table.primaryKey(['post_id', 'tag_id']);
                });
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        await database.execute('PRAGMA foreign_keys = ON');
        await database.insert('posts', <String, Object?>{'title': 'Hello'});
        await database.insert('tags', <String, Object?>{'name': 'dart'});
        await database.insert('post_tags', <String, Object?>{
          'post_id': 1,
          'tag_id': 1,
        });

        final rows = await database.rawQuery('''
          SELECT p.title, t.name
          FROM post_tags pt
          JOIN posts p ON p.id = pt.post_id
          JOIN tags t ON t.id = pt.tag_id
        ''');
        expect(rows.single['title'], 'Hello');
        expect(rows.single['name'], 'dart');
      } finally {
        await database.close();
      }
    });

    test('structural and data operations interleave correctly', () async {
      sqfliteFfiInit();

      final database = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );

      try {
        final migrator = SqliteFlutterMigrator(
          currentVersion: 1,
          migrations: <SqliteFlutterMigration>[
            SqliteFlutterMigration.schema(
              fromVersion: 0,
              toVersion: 1,
              debugName: 'create_and_seed',
              run: (schema) {
                schema.createTable('config', (table) {
                  table.text('key').notNull().primaryKey();
                  table.text('value').notNull();
                });
                // Seed default config
                schema.execute(
                  "INSERT INTO config (key, value) VALUES ('app_version', '1.0.0')",
                );
                schema.execute(
                  "INSERT INTO config (key, value) VALUES ('theme', 'light')",
                );
              },
            ),
          ],
        );

        await migrator.upgradeDatabase(database);

        final rows = await database.rawQuery(
          'SELECT * FROM config ORDER BY key',
        );
        expect(rows, hasLength(2));
        expect(rows[0]['key'], 'app_version');
        expect(rows[1]['key'], 'theme');
      } finally {
        await database.close();
      }
    });
  });
}
