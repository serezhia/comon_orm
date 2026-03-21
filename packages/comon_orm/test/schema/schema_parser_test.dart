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

    test('parses @ignore and @@ignore attributes', () {
      const source = '''
model User {
  id     Int    @id
  name   String
  secret String @ignore
}

model AuditLog {
  id Int @id

  @@ignore
}
''';

      final schema = const SchemaParser().parse(source);
      final user = schema.findModel('User');
      final auditLog = schema.findModel('AuditLog');

      expect(user, isNotNull);
      expect(user!.findField('secret')!.attribute('ignore'), isNotNull);
      expect(auditLog, isNotNull);
      expect(auditLog!.attribute('ignore'), isNotNull);
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
  id         Int      @id
  rank       Int      @db.SmallInt
  total      BigInt   @db.BigInt
  rating     Float    @db.DoublePrecision
  name       String   @db.VarChar(255)
  code       String   @db.Char(4)
  bio        String?  @db.Text
  document   String?  @db.Xml
  externalId String?  @db.Uuid
  createdAt  DateTime @db.Timestamp
}
''';

      final schema = const SchemaParser().parse(source);
      final user = schema.findModel('User')!;

      expect(user.findField('rank')!.attribute('db.SmallInt'), isNotNull);
      expect(user.findField('total')!.attribute('db.BigInt'), isNotNull);
      expect(
        user.findField('rating')!.attribute('db.DoublePrecision'),
        isNotNull,
      );
      expect(user.findField('name')!.attribute('db.VarChar'), isNotNull);
      expect(
        user.findField('name')!.attribute('db.VarChar')!.arguments['value'],
        '255',
      );
      expect(user.findField('code')!.attribute('db.Char'), isNotNull);
      expect(
        user.findField('code')!.attribute('db.Char')!.arguments['value'],
        '4',
      );
      expect(user.findField('bio')!.attribute('db.Text'), isNotNull);
      expect(user.findField('document')!.attribute('db.Xml'), isNotNull);
      expect(user.findField('externalId')!.attribute('db.Uuid'), isNotNull);
      expect(user.findField('createdAt')!.attribute('db.Timestamp'), isNotNull);
    });

    // ── Edge cases ────────────────────────────────────────────────────────

    test('handles multiple consecutive comment-only lines between blocks', () {
      const source = '''
// This is the User model.
// It stores user accounts.
// Each user may have many posts.
model User {
  id   Int    @id
  name String
}

// The Post model lives below.
// It belongs to a User via userId.
//
model Post {
  id     Int  @id
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);

      expect(schema.models, hasLength(2));
      expect(schema.findModel('User'), isNotNull);
      expect(schema.findModel('Post'), isNotNull);
    });

    test('preserves unicode characters in string attribute values', () {
      // Unicode inside string literals (e.g. @default, @map values) must
      // pass through verbatim because the parser captures them as raw strings.
      const source = r'''
model Greeting {
  id      Int    @id
  message String @default("Привет, мир!")
  label   String @map("étiquette")
}
''';

      final schema = const SchemaParser().parse(source);
      final model = schema.findModel('Greeting')!;

      expect(
        model.findField('message')!.attribute('default')!.arguments['value'],
        '"Привет, мир!"',
      );
      expect(model.findField('label')!.databaseName, 'étiquette');
    });

    test('throws SchemaParseException for a unicode enum value identifier', () {
      // Prisma schema identifiers are ASCII-only; unicode identifiers cause a
      // parse error rather than silent data corruption.
      const source = '''
enum Status {
  активный
  неактивный
}

model Item {
  id     Int    @id
  status Status
}
''';

      expect(
        () => const SchemaParser().parse(source),
        throwsA(isA<SchemaParseException>()),
      );
    });

    test('throws SchemaParseException for a unicode field name', () {
      const source = '''
model User {
  id   Int    @id
  имя  String
}
''';

      expect(
        () => const SchemaParser().parse(source),
        throwsA(isA<SchemaParseException>()),
      );
    });
  });

  // ── Multi-error collection (4.3) ────────────────────────────────────────────

  group('parseResult', () {
    test('returns document with no errors for valid schema', () {
      const source = '''
model User {
  id   Int    @id
  name String
}
''';
      final result = const SchemaParser().parseResult(source);

      expect(result.hasErrors, isFalse);
      expect(result.errors, isEmpty);
      expect(result.document.findModel('User'), isNotNull);
    });

    test('collects multiple field errors without throwing', () {
      // Two invalid field names in separate models.
      const source = '''
model Alpha {
  имя String
  id  Int @id
}

model Beta {
  имя String
  id  Int @id
}
''';
      final result = const SchemaParser().parseResult(source);

      expect(result.hasErrors, isTrue);
      expect(result.errors.length, greaterThanOrEqualTo(2));
      for (final error in result.errors) {
        expect(error.message, isNotEmpty);
        expect(error.line, isNotNull);
      }
    });

    test('returns partial document when some blocks have errors', () {
      // Block 2 has a unicode field name; block 1 should still parse.
      const source = '''
model Good {
  id   Int    @id
  name String
}

model Bad {
  имя String
}
''';
      final result = const SchemaParser().parseResult(source);

      expect(result.hasErrors, isTrue);
      // The good model should still be present.
      expect(result.document.findModel('Good'), isNotNull);
    });

    test('SchemaParseError exposes line and column', () {
      const source = '''
enum Status {
  активный
}
''';
      final result = const SchemaParser().parseResult(source);

      expect(result.hasErrors, isTrue);
      final error = result.errors.first;
      expect(error.line, isNotNull);
      expect(error.column, isNotNull);
      expect(error.toString(), contains('SchemaParseError'));
    });
  });

  // ── Lexer (4.1) ─────────────────────────────────────────────────────────────

  group('SchemaLexer', () {
    test('emits basic tokens with correct kinds', () {
      const source = 'model User { id Int @id }';
      final tokens = const SchemaLexer().tokenize(source);

      final kinds = tokens.map((t) => t.kind).toList();
      expect(kinds, contains(TokenKind.identifier));
      expect(kinds, contains(TokenKind.leftBrace));
      expect(kinds, contains(TokenKind.rightBrace));
      expect(kinds, contains(TokenKind.at));
      expect(kinds, contains(TokenKind.eof));
    });

    test('tracks line numbers across newlines', () {
      const source = 'model User {\n  id Int\n}';
      final tokens = const SchemaLexer().tokenize(source);

      final openBrace = tokens.firstWhere((t) => t.kind == TokenKind.leftBrace);
      expect(openBrace.line, 1);

      final closeBrace = tokens.firstWhere(
        (t) => t.kind == TokenKind.rightBrace,
      );
      expect(closeBrace.line, 3);
    });

    test('discards // comments and does not emit them as tokens', () {
      const source = '// this is a comment\nmodel User { id Int }';
      final tokens = const SchemaLexer().tokenize(source);

      // No token with kind 'comment' should appear (comments are discarded).
      // After the newline, the first identifier should be 'model'.
      final identifiers = tokens
          .where((t) => t.kind == TokenKind.identifier)
          .map((t) => t.value)
          .toList();
      expect(identifiers.first, 'model');
    });

    test('emits doubleAt for @@ and single at for @', () {
      const source = '@@map("x") @id';
      final tokens = const SchemaLexer().tokenize(source);

      expect(tokens.first.kind, TokenKind.doubleAt);
      expect(
        tokens.firstWhere((t) => t.kind == TokenKind.at).kind,
        TokenKind.at,
      );
    });

    test('emits string token including surrounding quotes', () {
      const source = '"hello world"';
      final tokens = const SchemaLexer().tokenize(source);

      expect(tokens.first.kind, TokenKind.string);
      expect(tokens.first.value, '"hello world"');
    });

    test('emits newline tokens for each line break', () {
      const source = 'a\nb\nc';
      final tokens = const SchemaLexer().tokenize(source);
      final newlines = tokens.where((t) => t.kind == TokenKind.newline);
      expect(newlines.length, 2);
    });

    test('eof token always present at end', () {
      final tokens = const SchemaLexer().tokenize('');
      expect(tokens.last.kind, TokenKind.eof);
    });
  });
}
