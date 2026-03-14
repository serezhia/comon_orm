import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'package:test/test.dart';

void main() {
  group('PostgresqlMigrationPlanner', () {
    test('plans new tables and additive columns', () {
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

model Post {
  id Int @id @default(autoincrement())
  title String
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(plan.statements, hasLength(2));
      expect(
        plan.statements.first,
        contains('ALTER TABLE "User" ADD COLUMN "nickname" TEXT'),
      );
      expect(
        plan.statements.last,
        contains('CREATE TABLE IF NOT EXISTS "Post"'),
      );
    });

    test('warns about destructive or incompatible changes', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name Int
  email String @unique
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.statements, isEmpty);
      expect(plan.warnings, hasLength(2));
    });

    test('treats Decimal and @db.Numeric as the same postgresql shape', () {
      final initial = const SchemaParser().parse('''
model Invoice {
  id Int @id @default(autoincrement())
  amount Decimal
}
''');
      final target = const SchemaParser().parse('''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model Invoice {
  id Int @id @default(autoincrement())
  amount Decimal @db.Numeric
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.statements, isEmpty);
      expect(plan.warnings, isEmpty);
      expect(plan.requiresRebuild, isFalse);
    });

    test('plans enum creation before tables that use it', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model User {
  id Int @id @default(autoincrement())
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(plan.statements, hasLength(2));
      expect(
        plan.statements.first,
        contains('CREATE TYPE "TodoStatus" AS ENUM'),
      );
      expect(
        plan.statements.last,
        contains('CREATE TABLE IF NOT EXISTS "Todo"'),
      );
      expect(plan.statements.last, contains('"status" "TodoStatus" NOT NULL'));
    });

    test('plans additive enum value changes', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  archived
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains(
          'ALTER TYPE "TodoStatus" ADD VALUE IF NOT EXISTS \'archived\' AFTER \'done\'',
        ),
      );
    });

    test('plans inserted enum values with BEFORE ordering', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  inProgress
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains(
          'ALTER TYPE "TodoStatus" ADD VALUE IF NOT EXISTS \'inProgress\' BEFORE \'done\'',
        ),
      );
    });

    test('plans enum value renames when order is otherwise unchanged', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  completed
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains(
          'ALTER TYPE "TodoStatus" RENAME VALUE \'done\' TO \'completed\'',
        ),
      );
    });

    test('warns when enum definitions are reordered or removed', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  done
  pending
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final changedPlan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );
      final removedPlan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: const SchemaParser().parse('''
model Todo {
  id Int @id @default(autoincrement())
  status String
}
'''),
      );

      expect(
        changedPlan.warnings,
        contains(
          'Altering enum TodoStatus requires schema rebuild and data compatibility review.',
        ),
      );
      expect(changedPlan.requiresRebuild, isTrue);
      expect(
        removedPlan.warnings,
        contains(
          'Dropping enum TodoStatus requires schema rebuild and data compatibility review.',
        ),
      );
      expect(removedPlan.requiresRebuild, isTrue);
    });

    test('plans combined enum value rename and insert without rebuild', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  completed
  archived
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.requiresRebuild, isFalse);
      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains(
          "ALTER TYPE \"TodoStatus\" RENAME VALUE 'done' TO 'completed'",
        ),
      );
      expect(
        plan.statements,
        contains(
          "ALTER TYPE \"TodoStatus\" ADD VALUE IF NOT EXISTS 'archived' AFTER 'completed'",
        ),
      );
    });

    test('emits ALTER TYPE RENAME TO when enum @@map changes', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.requiresRebuild, isFalse);
      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains('ALTER TYPE "todo_status" RENAME TO "task_status"'),
      );
    });

    test('plans mapped enum rename and insert transitions without rebuild', () {
      final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');
      final target = const SchemaParser().parse('''
enum TaskStatus {
  pending
  completed
  archived
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TaskStatus
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.requiresRebuild, isFalse);
      expect(plan.warnings, isEmpty);
      expect(
        plan.statements,
        contains('ALTER TYPE "todo_status" RENAME TO "task_status"'),
      );
      expect(
        plan.statements,
        contains(
          "ALTER TYPE \"task_status\" RENAME VALUE 'done' TO 'completed'",
        ),
      );
      expect(
        plan.statements,
        contains(
          "ALTER TYPE \"task_status\" ADD VALUE IF NOT EXISTS 'archived' AFTER 'completed'",
        ),
      );
    });

    test(
      'matches enum fields by databaseName when introspected names differ',
      () {
        final from = const SchemaParser().parse('''
enum TaskStatus {
  pending
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TaskStatus
}
''');
        final to = const SchemaParser().parse('''
enum TodoStatus {
  pending
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  status TodoStatus
}
''');

        final plan = const PostgresqlMigrationPlanner().plan(
          from: from,
          to: to,
        );

        expect(plan.requiresRebuild, isFalse);
        expect(plan.warnings, isEmpty);
        expect(plan.statements, isEmpty);
      },
    );

    test('plans foreign key recreation when referential actions change', () {
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

      final plan = const PostgresqlMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.statements, <String>[
        'ALTER TABLE "Post" DROP CONSTRAINT IF EXISTS "Post_userId_fkey"',
        'ALTER TABLE "Post" ADD CONSTRAINT "Post_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE',
      ]);
    });

    test('plans foreign key recreation when relation references change', () {
      final from = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  userId Int?
  userEmail String?
  user User? @relation(fields: [userId], references: [id])
}
''');
      final to = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  userId Int?
  userEmail String?
  user User? @relation(fields: [userEmail], references: [email])
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
      expect(plan.statements, <String>[
        'ALTER TABLE "Post" DROP CONSTRAINT IF EXISTS "Post_userId_fkey"',
        'ALTER TABLE "Post" ADD CONSTRAINT "Post_userEmail_fkey" FOREIGN KEY ("userEmail") REFERENCES "User" ("email")',
      ]);
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
      final plan = const PostgresqlMigrationPlanner().plan(from: from, to: to);

      expect(plan.warnings, isEmpty);
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

    test('treats native type changes as incompatible field changes', () {
      final initial = const SchemaParser().parse('''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');
      final target = const SchemaParser().parse('''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id Int @id @default(autoincrement())
  name String @db.VarChar(255)
}
''');

      final plan = const PostgresqlMigrationPlanner().plan(
        from: initial,
        to: target,
      );

      expect(plan.statements, isEmpty);
      expect(
        plan.warnings,
        contains('Altering User.name requires manual migration.'),
      );
    });
  });
}
