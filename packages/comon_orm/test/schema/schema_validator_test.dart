import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaValidator', () {
    test('accepts a valid schema', () {
      const source = '''
model User {
  id    Int    @id
  email String @unique
  posts Post[]
}

model Post {
  id     Int  @id
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports unknown relation targets and missing ids', () {
      const source = '''
model User {
  email String
  posts Post[]
}

model Post {
  id   Int   @id
  user Userz
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('Model must have an @id field.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('Unknown relation target model "Userz".'),
      );
    });

    test('skips relation validation for ignored models and fields', () {
      const source = '''
model User {
  id     Int     @id
  hidden Missing @ignore
}

model AuditLog {
  broken Missing

  @@ignore
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('validates relation references against unique target fields', () {
      const source = '''
model Account {
  id       Int    @id
  tenantId Int
  slug     String
  sessions Session[]

  @@unique([tenantId, slug])
}

model Session {
  id        Int    @id
  tenantId  Int
  accountSlug String
  account   Account @relation(fields: [tenantId, accountSlug], references: [tenantId, slug])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports invalid relation reference definitions', () {
      const source = '''
model User {
  id      Int    @id
  email   String
  handle  String @unique
}

model Post {
  id        Int    @id
  userId    String
  userEmail String
  tags      String[]
  author    User   @relation(fields: [userId, tags], references: [id])
  editor    User   @relation(fields: [userEmail], references: [email])
  reviewer  User   @relation(fields: [userId], references: [missing])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          '@relation fields and references must contain the same number of fields.',
        ),
      );
      expect(
        messages,
        contains(
          '@relation references on model "User" must target an @id, @unique, @@id, or @@unique field set.',
        ),
      );
      expect(
        messages,
        contains(
          '@relation references missing target field "missing" on model "User".',
        ),
      );
    });

    test('reports list relation ownership and relation type mismatches', () {
      const source = '''
model User {
  id      Int    @id
  posts   Post[] @relation(fields: [id], references: [authorId])
}

model Post {
  id       Int    @id
  authorId String
  author   User   @relation(fields: [authorId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          'List relation fields cannot declare fields/references; declare them on the singular side.',
        ),
      );
      expect(
        messages,
        contains(
          '@relation field "authorId" type String does not match referenced field "User.id" type Int.',
        ),
      );
    });

    test('accepts explicit relation names for multiple relations', () {
      const source = '''
model User {
  id            Int    @id
  writtenPosts  Post[] @relation("WrittenPosts")
  reviewedPosts Post[] @relation("ReviewedPosts")
}

model Post {
  id          Int  @id
  authorId    Int
  reviewerId  Int
  author      User @relation("WrittenPosts", fields: [authorId], references: [id])
  reviewer    User @relation("ReviewedPosts", fields: [reviewerId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test(
      'accepts relation names declared on only one side when pairing is unambiguous',
      () {
        const source = '''
model User {
  id    Int    @id
  posts Post[] @relation("Posts")
}

model Post {
  id     Int  @id
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''';

        final schema = const SchemaParser().parse(source);
        final issues = const SchemaValidator().validate(schema);

        expect(issues, isEmpty);
      },
    );

    test('reports ambiguous unnamed multiple relations', () {
      const source = '''
model User {
  id            Int    @id
  writtenPosts  Post[]
  reviewedPosts Post[]
}

model Post {
  id          Int  @id
  authorId    Int
  reviewerId  Int
  author      User @relation(fields: [authorId], references: [id])
  reviewer    User @relation(fields: [reviewerId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          'Ambiguous relation between "User" and "Post"; add an explicit relation name.',
        ),
      );
      expect(
        messages,
        contains(
          'Ambiguous relation between "Post" and "User"; add an explicit relation name.',
        ),
      );
    });

    test('reports unnamed self relations and duplicate named relation reuse', () {
      const source = '''
model User {
  id        Int    @id
  managerId Int?
  mentorId  Int?
  manager   User?  @relation(fields: [managerId], references: [id])
  mentor    User?  @relation("Career", fields: [mentorId], references: [id])
  reports   User[] @relation("Career")
  peers     User[] @relation("Career")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains('Self-relations must declare an explicit relation name.'),
      );
      expect(
        messages,
        contains(
          'Relation name "Career" is reused multiple times between "User" and "User" on the same model side.',
        ),
      );
    });

    test('reports incomplete relation pairs without an opposite field', () {
      const source = '''
model User {
  id      Int   @id
  profile Profile?
}

model Profile {
  id      Int   @id
  userId  Int   @unique
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          'Incomplete relation between "User" and "Profile"; exactly two relation fields are required.',
        ),
      );
    });

    test('reports fields/references ownership on both sides of a relation', () {
      const source = '''
model User {
  id        Int     @id
  profileId Int     @unique
  profile   Profile @relation(fields: [profileId], references: [id])
}

model Profile {
  id      Int  @id
  userId  Int  @unique
  user    User @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          'Only one side of relation between "User" and "Profile" may declare fields/references.',
        ),
      );
    });

    test('reports non-unique owning side for one-to-one relations', () {
      const source = '''
model User {
  id      Int      @id
  profile Profile?
}

model Profile {
  id      Int   @id
  userId  Int
  user    User  @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'One-to-one relation between "User" and "Profile" requires the defining fields on "Profile" to be unique.',
        ),
      );
    });

    test('accepts unique owning side for one-to-one relations', () {
      const source = '''
model User {
  id      Int      @id
  profile Profile?
}

model Profile {
  id      Int   @id
  userId  Int   @unique
  user    User  @relation(fields: [userId], references: [id])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports required one-to-one self relations on both sides', () {
      const source = '''
model User {
  id           Int   @id
  successorId  Int   @unique
  successor    User  @relation("Chain", fields: [successorId], references: [id])
  predecessor  User  @relation("Chain")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'One-to-one self-relations must have at least one optional side.',
        ),
      );
    });

    test('accepts one-to-one self relations with an optional side', () {
      const source = '''
model User {
  id           Int    @id
  successorId  Int?   @unique
  successor    User?  @relation("Chain", fields: [successorId], references: [id])
  predecessor  User?  @relation("Chain")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports missing owning side for non-list relations', () {
      const source = '''
model User {
  id    Int    @id
  posts Post[]
}

model Post {
  id   Int   @id
  user User?
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Exactly one side of relation between "User" and "Post" must declare fields/references unless both relation fields are lists.',
        ),
      );
    });

    test(
      'accepts implicit many-to-many list relations without owner fields',
      () {
        const source = '''
model User {
  id   Int    @id
  tags Tag[]
}

model Tag {
  id    Int    @id
  users User[]
}
''';

        final schema = const SchemaParser().parse(source);
        final issues = const SchemaValidator().validate(schema);

        expect(issues, isEmpty);
      },
    );

    test('accepts supported referential actions on relations', () {
      const source = '''
model User {
  id    Int    @id
  posts Post[] @relation("Posts")
  ownedPosts Post[] @relation("Owner")
}

model Post {
  id      Int   @id
  userId  Int?
  ownerId Int   @default(1)
  user    User? @relation("Posts", fields: [userId], references: [id], onDelete: SetNull, onUpdate: Cascade)
  owner   User  @relation("Owner", fields: [ownerId], references: [id], onDelete: SetDefault, onUpdate: Restrict)
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports invalid referential action usage', () {
      const source = '''
model User {
  id      Int    @id
  posts   Post[] @relation("Posts")
  owned   Post[] @relation("Owner", onDelete: Cascade)
}

model Post {
  id      Int   @id
  userId  Int
  ownerId Int
  user    User  @relation("Posts", fields: [userId], references: [id], onDelete: SetNull, onUpdate: Nope)
  owner   User  @relation("Owner", fields: [ownerId], references: [id], onDelete: SetDefault)
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);
      final messages = issues
          .map((issue) => issue.message)
          .toList(growable: false);

      expect(
        messages,
        contains(
          '@relation onDelete/onUpdate can only be declared on the side that defines fields/references.',
        ),
      );
      expect(
        messages,
        contains('@relation onDelete: SetNull requires nullable local fields.'),
      );
      expect(
        messages,
        contains(
          '@relation onUpdate must be one of Cascade, Restrict, NoAction, SetNull, or SetDefault.',
        ),
      );
      expect(
        messages,
        contains(
          '@relation onDelete: SetDefault requires defaults on all local fields.',
        ),
      );
    });

    test('accepts valid enum fields', () {
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
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('accepts valid datasource and generator blocks', () {
      const source = '''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

generator client {
  provider = "comon_orm"
  output = "lib/generated"
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports missing required datasource and generator properties', () {
      const source = '''
datasource db {
  provider = "sqlite"
}

generator client {
  output = "lib/generated"
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('Datasource must declare a url.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('Generator must declare a provider.'),
      );
    });

    test('reports duplicate datasource and generator names', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

generator client {
  provider = "comon_orm"
}

generator client {
  provider = "comon_orm"
}

model User {
  id Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('Duplicate datasource name.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('Duplicate generator name.'),
      );
    });

    test('reports duplicate enum values', () {
      const source = '''
enum TodoStatus {
  pending
  pending
}

model Todo {
  id     Int        @id
  status TodoStatus
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('Duplicate enum value.'),
      );
    });

    test('accepts supported model-level attributes', () {
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
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports missing fields in model-level attributes', () {
      const source = '''
model User {
  id   Int    @id
  name String

  @@unique([email])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('@@unique references missing field "email".'),
      );
    });

    test('accepts composite model id', () {
      const source = '''
model Membership {
  userId Int
  orgId  Int

  @@id([userId, orgId])
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports multiple field-level ids instead of @@id', () {
      const source = '''
model Membership {
  userId Int @id
  orgId  Int @id
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Use model-level @@id([fieldA, fieldB]) instead of multiple @id fields.',
        ),
      );
    });

    test('accepts valid updatedAt field', () {
      const source = '''
model User {
  id        Int      @id
  updatedAt DateTime @updatedAt
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports invalid updatedAt usage', () {
      const source = '''
model User {
  id        Int     @id
  updatedAt String? @updatedAt(now())
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('@updatedAt does not accept arguments.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@updatedAt field must be a singular non-nullable DateTime.'),
      );
    });

    test('accepts supported postgresql native types', () {
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
  payload    Json     @db.JsonB
  metadata   Json?    @db.Json
  blob       Bytes    @db.ByteA
  amount     Decimal  @db.Numeric
  externalId String?  @db.Uuid
  createdAt  DateTime @db.Timestamp
  updatedAt  DateTime @db.Timestamptz
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports invalid native type usage and unsupported providers', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id        Int    @id
  name      Int    @db.VarChar(foo)
  createdAt String @db.Timestamp
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Unsupported native type @db.VarChar for datasource provider "sqlite".',
        ),
      );
      expect(
        issues.map((issue) => issue.message),
        contains(
          'Unsupported native type @db.Timestamp for datasource provider "sqlite".',
        ),
      );
    });

    test('reports unsupported or malformed postgresql native types', () {
      const source = '''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id        Int      @id
  name      String   @db.DoesNotExist
  rank      String   @db.SmallInt
  total     Int      @db.BigInt
  rating    Decimal  @db.DoublePrecision
  nickname  String   @db.VarChar(foo)
  code      String   @db.Char(foo)
  amount    String   @db.Numeric(10,2)
  document  Int      @db.Xml
  createdAt DateTime @db.Timestamp(3)
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Unsupported native type @db.DoesNotExist for datasource provider "postgresql".',
        ),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.VarChar requires a positive length argument.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.SmallInt is only supported on singular Int fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.BigInt is only supported on singular BigInt fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains(
          '@db.DoublePrecision is only supported on singular Float fields.',
        ),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Char requires a positive length argument.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Numeric is only supported on singular Decimal fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Xml is only supported on singular String fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Timestamp does not accept arguments.'),
      );
    });

    test('accepts supported sqlite native types', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

enum Status {
  pending
  done
}

model Sample {
  id        Int      @id @db.Integer
  amount    Decimal  @db.Numeric
  rating    Float    @db.Real
  payload   Json?    @db.Text
  createdAt DateTime @db.Text
  blob      Bytes    @db.Blob
  status    Status   @db.Text
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports invalid sqlite native type usage', () {
      const source = '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model Sample {
  id      String @id @db.Integer(foo)
  amount  String @db.Numeric
  rating  String @db.Real
  payload Bytes  @db.Text
  createdAt DateTime @db.Blob
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains('@db.Integer is only supported on singular Int fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Numeric is only supported on singular Decimal fields.'),
      );
      expect(
        issues.map((issue) => issue.message),
        contains(
          '@db.Real is only supported on singular Float or Decimal fields.',
        ),
      );
      expect(
        issues.map((issue) => issue.message),
        contains(
          '@db.Text is only supported on singular String, DateTime, Json, BigInt, or enum fields.',
        ),
      );
      expect(
        issues.map((issue) => issue.message),
        contains('@db.Blob is only supported on singular Bytes fields.'),
      );
    });

    // ── @map conflict detection ───────────────────────────────────────────

    test('reports two fields in the same model mapping to the same column', () {
      const source = '''
model User {
  id       Int    @id
  name     String @map("display_name")
  nickname String @map("display_name")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Field database name "display_name" conflicts with another field in model "User".',
        ),
      );
    });

    test(
      'reports a field whose implicit name clashes with another field @map',
      () {
        const source = '''
model User {
  id           Int    @id
  display_name String
  nickname     String @map("display_name")
}
''';

        final schema = const SchemaParser().parse(source);
        final issues = const SchemaValidator().validate(schema);

        expect(
          issues.map((issue) => issue.message),
          contains(
            'Field database name "display_name" conflicts with another field in model "User".',
          ),
        );
      },
    );

    test('accepts two fields in different models sharing a column name', () {
      // @map conflicts are only relevant within the same model.
      const source = '''
model User {
  id    Int    @id
  value String @map("col")
}

model Post {
  id    Int    @id
  value String @map("col")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(issues, isEmpty);
    });

    test('reports two models mapping to the same database table', () {
      const source = '''
model User {
  id Int @id

  @@map("accounts")
}

model Account {
  id Int @id

  @@map("accounts")
}
''';

      final schema = const SchemaParser().parse(source);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues.map((issue) => issue.message),
        contains(
          'Database table name "accounts" conflicts with another model.',
        ),
      );
    });

    test(
      'reports a model whose implicit name clashes with another model @@map',
      () {
        const source = '''
model User {
  id Int @id
}

model Member {
  id Int @id

  @@map("User")
}
''';

        final schema = const SchemaParser().parse(source);
        final issues = const SchemaValidator().validate(schema);

        expect(
          issues.map((issue) => issue.message),
          contains('Database table name "User" conflicts with another model.'),
        );
      },
    );
  });
}
