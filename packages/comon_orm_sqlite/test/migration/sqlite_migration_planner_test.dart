import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

void main() {
  group('SqliteMigrationPlanner', () {
    test('creates new tables for newly added models', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}

model Post {
  id Int @id @default(autoincrement())
  title String
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.statements, hasLength(1));
      expect(
        plan.statements.single,
        contains('CREATE TABLE IF NOT EXISTS "Post"'),
      );
    });

    test('adds compatible columns to existing tables', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
  published Boolean @default(false)
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.statements, hasLength(2));
      expect(
        plan.statements[0],
        contains('ALTER TABLE "User" ADD COLUMN "nickname" TEXT'),
      );
      expect(
        plan.statements[1],
        contains(
          'ALTER TABLE "User" ADD COLUMN "published" BOOLEAN NOT NULL DEFAULT 0',
        ),
      );
    });

    test('warns on unsupported destructive or constrained changes', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.statements, isEmpty);
      expect(
        plan.warnings,
        contains('Adding unique field User.email requires manual migration.'),
      );
      expect(
        plan.warnings,
        contains('Dropping User.name requires manual migration.'),
      );
    });

    test('warns on field shape changes', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  age Int
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  age String
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.statements, isEmpty);
      expect(
        plan.warnings,
        contains('Altering User.age requires manual migration.'),
      );
    });

    test('introspects applied schema from live database', () {
      final schema = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
}

model Post {
  id Int @id @default(autoincrement())
  title String
  published Boolean @default(false)
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: SetNull, onUpdate: Cascade)
}
''');
      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);

      final introspected = const SqliteSchemaIntrospector().introspect(
        database,
      );
      final userModel = introspected.findModel('User');
      final postModel = introspected.findModel('Post');

      expect(userModel, isNotNull);
      expect(postModel, isNotNull);
      expect(userModel!.findField('id')!.isId, isTrue);
      expect(
        userModel.findField('id')!.attribute('default')?.arguments['value'],
        'autoincrement()',
      );
      expect(userModel.findField('email')!.isUnique, isTrue);
      expect(postModel!.findField('published')!.type, 'Boolean');
      expect(
        postModel
            .findField('published')!
            .attribute('default')
            ?.arguments['value'],
        'false',
      );
      expect(postModel.findField('userId')!.type, 'Int');
      expect(postModel.findField('user')!.type, 'User');
      expect(
        postModel
            .findField('user')!
            .attribute('relation')
            ?.arguments['onDelete'],
        'SetNull',
      );
      expect(
        postModel
            .findField('user')!
            .attribute('relation')
            ?.arguments['onUpdate'],
        'Cascade',
      );

      database.close();
    });

    test('plans additive migration directly from live database', () {
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

      final plan = const SqliteMigrationPlanner().planFromDatabase(
        database: database,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(plan.statements, hasLength(1));
      expect(
        plan.statements.single,
        contains('ALTER TABLE "User" ADD COLUMN "nickname" TEXT'),
      );

      database.close();
    });

    test('introspects sqlite native type subset from live database', () {
      final schema = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model Sample {
  id      Int    @id @db.Integer
  amount  Decimal @db.Numeric
  rating  Float  @db.Real
  payload Json?  @db.Text
  blob    Bytes  @db.Blob
}
''');
      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);

      final introspected = const SqliteSchemaIntrospector().introspect(
        database,
      );
      final sample = introspected.findModel('Sample')!;

      expect(sample.findField('id')!.attribute('db.Integer'), isNotNull);
      expect(sample.findField('amount')!.attribute('db.Numeric'), isNotNull);
      expect(sample.findField('rating')!.attribute('db.Real'), isNotNull);
      expect(sample.findField('payload')!.attribute('db.Text'), isNotNull);
      expect(sample.findField('blob')!.attribute('db.Blob'), isNotNull);

      database.close();
    });

    test('introspects compound primary key and unique constraints', () {
      final schema = const SchemaParser().parse('''
model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, slug])
  @@unique([tenantId, role])
}
''');
      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);

      final introspected = const SqliteSchemaIntrospector().introspect(
        database,
      );
      final membership = introspected.findModel('Membership')!;

      expect(membership.primaryKeyFields, <String>['tenantId', 'slug']);
      expect(
        membership.compoundUniqueFieldSets.toList(growable: false),
        <List<String>>[
          <String>['tenantId', 'role'],
        ],
      );

      database.close();
    });

    test('warns when compound model constraints change', () {
      final from = const SchemaParser().parse('''
model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, slug])
}
''');
      final to = const SchemaParser().parse('''
model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, role])
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(
        plan.warnings,
        contains(
          'Altering model-level constraints on Membership requires manual migration.',
        ),
      );
    });

    test('marks rebuild when referential actions change', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: SetNull)
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: Cascade)
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isTrue);
    });

    test('marks rebuild when relation reference field sets change', () {
      final from = const SchemaParser().parse('''
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id        Int    @id @default(autoincrement())
  userId    Int?
  userEmail String?
  user      User? @relation(fields: [userId], references: [id])
}
''');
      final to = const SchemaParser().parse('''
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id        Int    @id @default(autoincrement())
  userId    Int?
  userEmail String?
  user      User? @relation(fields: [userEmail], references: [email])
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isTrue);
    });

    test('marks rebuild without warnings for mapped column rename', () {
      final from = const SchemaParser().parse('''
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
      final to = const SchemaParser().parse('''
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

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isTrue);
    });

    test('marks rebuild without warnings for mapped table rename', () {
      final from = const SchemaParser().parse('''
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
      final to = const SchemaParser().parse('''
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

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isTrue);
    });

    test('treats sqlite native type changes as incompatible field changes', () {
      final from = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final to = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String @db.Text
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);

      final compatibleTo = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String @db.Blob
}
''');

      final changedPlan = const SqliteMigrationPlanner().plan(
        from: from,
        to: compatibleTo,
      );

      expect(
        changedPlan.warnings,
        contains('Altering User.name requires manual migration.'),
      );
    });

    test('treats Decimal and @db.Numeric as the same sqlite native shape', () {
      final from = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model Ledger {
  id     Int     @id @default(autoincrement())
  amount Decimal @db.Numeric
}
''');
      final to = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model Ledger {
  id     Int     @id @default(autoincrement())
  amount Decimal @db.Numeric
}
''');

      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
    });

    test('creates synthetic join table for added implicit many-to-many', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}

model Tag {
  id Int @id @default(autoincrement())
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  tags Tag[]
}

model Tag {
  id Int @id @default(autoincrement())
  users User[]
}
''');

      final storage = collectImplicitManyToManyStorages(to).single;
      final plan = const SqliteMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isFalse);
      expect(plan.statements, hasLength(1));
      expect(
        plan.statements.single,
        contains('CREATE TABLE IF NOT EXISTS "${storage.tableName}"'),
      );
      expect(
        plan.statements.single,
        contains(
          'PRIMARY KEY ("${[...storage.sourceJoinColumns, ...storage.targetJoinColumns].join('", "')}")',
        ),
      );
    });

    test('introspects synthetic join tables back into implicit relations', () {
      final schema = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  tags Tag[]
}

model Tag {
  id Int @id @default(autoincrement())
  users User[]
}
''');
      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);

      final introspected = const SqliteSchemaIntrospector().introspect(
        database,
      );
      expect(introspected.findModel('User')?.findField('tags')?.isList, isTrue);
      expect(introspected.findModel('Tag')?.findField('users')?.isList, isTrue);

      database.close();
    });
  });
}
