import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

void main() {
  group('SqliteMigrationRunner', () {
    test('applies additive migration and records history', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const runner = SqliteMigrationRunner();

      final result = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );

      expect(result.applied, isTrue);
      expect(result.plan.statements, hasLength(1));

      final columns = database.select('PRAGMA table_info("User")');
      expect(columns.any((row) => row['name'] == 'nickname'), isTrue);

      final history = runner.loadHistory(database);
      expect(history, hasLength(1));
      expect(history.single.name, '20260313_add_user_nickname');
      expect(history.single.statementCount, 1);
      expect(history.single.kind, SqliteMigrationRecordKind.apply);

      database.dispose();
    });

    test('does not reapply the same migration name twice', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  nickname String?
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const runner = SqliteMigrationRunner();

      final firstRun = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );
      final secondRun = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );

      expect(firstRun.applied, isTrue);
      expect(secondRun.applied, isFalse);
      expect(runner.loadHistory(database), hasLength(1));

      database.dispose();
    });

    test('refuses warning-bearing migration plans by default', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const runner = SqliteMigrationRunner();

      expect(
        () => runner.migrateToSchema(
          database: database,
          target: target,
          migrationName: '20260313_add_unique_email',
        ),
        throwsStateError,
      );
      expect(runner.loadHistory(database), isEmpty);

      database.dispose();
    });

    test('records empty migration when schema is already current', () {
      final schema = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);
      const runner = SqliteMigrationRunner();

      final result = runner.migrateToSchema(
        database: database,
        target: schema,
        migrationName: '20260313_baseline',
      );

      expect(result.applied, isFalse);
      final history = runner.loadHistory(database);
      expect(history, hasLength(1));
      expect(history.single.statementCount, 0);

      database.dispose();
    });

    test(
      'rebuilds schema for relation constraint changes and preserves data',
      () {
        final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  title String
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: SetNull)
}
''');
        final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  title String
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: Cascade)
}
''');

        final database = sqlite.sqlite3.openInMemory();
        const SqliteSchemaApplier().apply(database, initial);
        database.execute('INSERT INTO "User" (id) VALUES (?)', <Object?>[1]);
        database.execute(
          'INSERT INTO "Post" (title, userId) VALUES (?, ?)',
          <Object?>['keep me', 1],
        );

        const runner = SqliteMigrationRunner();
        final result = runner.migrateToSchema(
          database: database,
          target: target,
          migrationName: '20260314_update_post_user_fk',
        );

        expect(result.applied, isTrue);
        expect(result.plan.requiresRebuild, isTrue);
        expect(result.plan.warnings, isEmpty);

        final relation = const SqliteSchemaIntrospector()
            .introspect(database)
            .findModel('Post')
            ?.findField('user')
            ?.attribute('relation');
        expect(relation, isNotNull);
        expect(relation!.arguments['onDelete'], 'Cascade');

        final rows = database.select(
          'SELECT title, userId FROM "Post" ORDER BY id ASC',
        );
        expect(rows.single['title'], 'keep me');
        expect(rows.single['userId'], 1);

        final history = runner.loadHistory(database);
        expect(history, hasLength(1));
        expect(history.single.statementCount, greaterThan(0));

        database.dispose();
      },
    );

    test('rebuild preserves data when model and fields use @@map / @map', () {
      final initial = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String @map("category_name")

  products Product[]

  @@map("categories")
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String    @map("product_title")
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)

  @@map("products")
}
''');
      final target = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String @map("category_name")

  products Product[]

  @@map("categories")
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String    @map("product_title")
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@map("products")
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      database.execute(
        'INSERT INTO "categories" (id, category_name) VALUES (?, ?)',
        <Object?>[1, 'Electronics'],
      );
      database.execute(
        'INSERT INTO "products" (product_title, categoryId) VALUES (?, ?)',
        <Object?>['Widget', 1],
      );

      const runner = SqliteMigrationRunner();
      final result = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260401_mapped_rebuild',
        allowWarnings: true,
      );

      expect(result.applied, isTrue);
      expect(result.plan.requiresRebuild, isTrue);

      final cats = database.select(
        'SELECT id, category_name FROM "categories"',
      );
      expect(cats.single['category_name'], 'Electronics');

      final prods = database.select(
        'SELECT product_title, categoryId FROM "products"',
      );
      expect(prods.single['product_title'], 'Widget');
      expect(prods.single['categoryId'], 1);

      database.dispose();
    });

    test('rebuild preserves scalar data when a mapped column name changes', () {
      final initial = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String

  products Product[]
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String    @map("product_title")
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)
}
''');
      final target = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String

  products Product[]
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String    @map("title_text")
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: Cascade)
}
''');

      final database = sqlite.sqlite3.openInMemory();

      const runner = SqliteMigrationRunner();
      final baseline = runner.migrateToSchema(
        database: database,
        target: initial,
        migrationName: '20260401_baseline_mapped_column',
      );

      database.execute(
        'INSERT INTO "Category" (id, name) VALUES (?, ?)',
        <Object?>[1, 'Electronics'],
      );
      database.execute(
        'INSERT INTO "Product" (product_title, categoryId) VALUES (?, ?)',
        <Object?>['Widget', 1],
      );

      final result = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260402_mapped_column_rebuild',
        allowWarnings: true,
      );

      expect(baseline.applied, isTrue);
      expect(result.applied, isTrue);
      expect(result.plan.requiresRebuild, isTrue);

      final rows = database.select(
        'SELECT id, title_text, categoryId FROM "Product"',
      );
      expect(rows.single['title_text'], 'Widget');
      expect(rows.single['categoryId'], 1);

      database.dispose();
    });

    test('rebuild preserves rows when a mapped table name changes', () {
      final initial = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String

  products Product[]
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: SetNull)

  @@map("catalog_products")
}
''');
      final target = const SchemaParser().parse('''
model Category {
  id   Int    @id @default(autoincrement())
  name String

  products Product[]
}

model Product {
  id         Int       @id @default(autoincrement())
  title      String
  categoryId Int?
  category   Category? @relation(fields: [categoryId], references: [id], onDelete: Cascade)

  @@map("store_products")
}
''');

      final database = sqlite.sqlite3.openInMemory();

      const runner = SqliteMigrationRunner();
      final baseline = runner.migrateToSchema(
        database: database,
        target: initial,
        migrationName: '20260403_baseline_mapped_table',
      );

      database.execute(
        'INSERT INTO "Category" (id, name) VALUES (?, ?)',
        <Object?>[1, 'Electronics'],
      );
      database.execute(
        'INSERT INTO "catalog_products" (title, categoryId) VALUES (?, ?)',
        <Object?>['Widget', 1],
      );

      final result = runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260404_mapped_table_rebuild',
        allowWarnings: true,
      );

      expect(baseline.applied, isTrue);
      expect(result.applied, isTrue);
      expect(result.plan.requiresRebuild, isTrue);

      final rows = database.select(
        'SELECT id, title, categoryId FROM "store_products"',
      );
      expect(rows.single['title'], 'Widget');
      expect(rows.single['categoryId'], 1);

      database.dispose();
    });

    test('rolls back an applied migration and preserves shared data', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const runner = SqliteMigrationRunner();
      runner.migrateToSchema(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );

      database.execute(
        'INSERT INTO "User" (name, nickname) VALUES (?, ?)',
        <Object?>['Grace', 'hopper'],
      );

      expect(
        () => runner.rollbackToSchema(
          database: database,
          target: initial,
          targetMigrationName: '20260313_add_user_nickname',
          rollbackName: '20260313_add_user_nickname_rollback',
        ),
        throwsStateError,
      );

      final result = runner.rollbackToSchema(
        database: database,
        target: initial,
        targetMigrationName: '20260313_add_user_nickname',
        rollbackName: '20260313_add_user_nickname_rollback',
        allowWarnings: true,
      );

      expect(result.rolledBack, isTrue);
      expect(result.warnings, isNotEmpty);
      final columns = database.select('PRAGMA table_info("User")');
      expect(columns.any((row) => row['name'] == 'nickname'), isFalse);
      final rows = database.select('SELECT id, name FROM "User"');
      expect(rows.single['name'], 'Grace');

      final activeHistory = runner.loadActiveHistory(database);
      expect(activeHistory, isEmpty);
      final history = runner.loadHistory(database);
      expect(history, hasLength(2));
      expect(history.last.kind, SqliteMigrationRecordKind.rollback);
      expect(history.last.targetName, '20260313_add_user_nickname');

      database.dispose();
    });
  });
}
