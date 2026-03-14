import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaParser', () {
    test('parses models and fields from schema.prisma style source', () {
      const source = '''
model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  posts Post[]
}

model Post {
  id     Int  @id @default(autoincrement())
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);

      expect(schema.models, hasLength(2));
      expect(schema.findModel('User'), isNotNull);
      expect(
        schema.findModel('Post')?.findField('user')?.attribute('relation'),
        isNotNull,
      );
      expect(schema.findModel('User')?.findField('posts')?.isList, isTrue);
    });

    test('parses enums and enum-backed fields', () {
      const source = '''
enum TodoStatus {
  pending
  done
}

model Todo {
  id     Int        @id
  title  String
  status TodoStatus
}
''';

      final schema = const SchemaParser().parse(source);

      expect(schema.enums, hasLength(1));
      expect(schema.findEnum('TodoStatus'), isNotNull);
      expect(schema.findEnum('TodoStatus')?.values, <String>[
        'pending',
        'done',
      ]);
      expect(schema.findModel('Todo')?.findField('status')?.type, 'TodoStatus');
    });

    test('parses enum @@map attribute into databaseName', () {
      const source = '''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}
''';

      final schema = const SchemaParser().parse(source);
      final enumDef = schema.findEnum('TodoStatus');

      expect(enumDef, isNotNull);
      expect(enumDef!.values, <String>['pending', 'done']);
      expect(enumDef.databaseName, 'todo_status');
      expect(enumDef.attribute('map')?.arguments['value'], '"todo_status"');
    });

    test('parses datasource and generator blocks', () {
      const source = '''
datasource db {
  provider = "postgresql"
  url      = "postgresql://localhost:5432/app"
}

generator client {
  provider      = "comon_orm"
  output        = "lib/generated"
  binaryTargets = ["native"]
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);

      expect(schema.datasources, hasLength(1));
      expect(schema.generators, hasLength(1));
      expect(
        schema.findDatasource('db')?.properties['provider'],
        '"postgresql"',
      );
      expect(
        schema.findDatasource('db')?.properties['url'],
        '"postgresql://localhost:5432/app"',
      );
      expect(
        schema.findGenerator('client')?.properties['output'],
        '"lib/generated"',
      );
      expect(
        schema.findGenerator('client')?.properties['binaryTargets'],
        '["native"]',
      );
    });

    test('parses model-level attributes', () {
      const source = '''
model User {
  id    Int    @id
  name  String
  email String

  @@unique([email, name])
  @@index([name])
  @@map("users")
}
''';

      final schema = const SchemaParser().parse(source);
      final model = schema.findModel('User');

      expect(model, isNotNull);
      expect(model!.attributes, hasLength(3));
      expect(model.attribute('unique')?.arguments['value'], '[email, name]');
      expect(model.attribute('index')?.arguments['value'], '[name]');
      expect(model.attribute('map')?.arguments['value'], '"users"');
    });

    test('exposes mapped database names for models and fields', () {
      const source = '''
model User {
  id Int @id @map("user_id")
  name String @map("full_name")

  @@map("users")
}
''';

      final schema = const SchemaParser().parse(source);
      final model = schema.findModel('User')!;

      expect(model.databaseName, 'users');
      expect(model.findField('id')!.databaseName, 'user_id');
      expect(model.findField('name')!.databaseName, 'full_name');
      expect(model.findFieldByDatabaseName('full_name')?.name, 'name');
    });

    test('keeps url-like values intact when stripping comments', () {
      const source = '''
datasource db {
  provider = "postgresql" // provider comment
  url = "postgresql://localhost:5432/app"
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);

      expect(
        schema.findDatasource('db')?.properties['url'],
        '"postgresql://localhost:5432/app"',
      );
    });

    test('parses dotted native type attributes', () {
      const source = '''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id        Int      @id
  name      String   @db.VarChar(255)
  bio       String?  @db.Text
  externalId String? @db.Uuid
  createdAt DateTime @db.Timestamp
}
''';

      final schema = const SchemaParser().parse(source);
      final user = schema.findModel('User')!;

      expect(user.findField('name')!.attribute('db.VarChar'), isNotNull);
      expect(
        user.findField('name')!.attribute('db.VarChar')!.arguments['value'],
        '255',
      );
      expect(user.findField('bio')!.attribute('db.Text'), isNotNull);
      expect(user.findField('externalId')!.attribute('db.Uuid'), isNotNull);
      expect(user.findField('createdAt')!.attribute('db.Timestamp'), isNotNull);
    });
  });
}
