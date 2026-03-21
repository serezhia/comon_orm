// End-to-end test that walks through the full pipeline:
//   schema text → SchemaParser → SchemaValidator → ClientGenerator
//   → pre-compiled runtime client → CRUD operations via InMemoryDatabaseAdapter
//
// The generated client imported below was produced from exactly _fixtureSchema,
// so all three phases must agree with the pre-compiled code.
import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

import '../generated/comon_orm_client.dart';

/// Schema text that matches the pre-compiled client in
/// `test/generated/comon_orm_client.dart`.
const _fixtureSchema = '''
model User {
  id           Int     @id @default(autoincrement())
  name         String?
  email        String? @unique
  country      String?
  profileViews Int?
  posts        Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String?
  content   String?
  published Boolean? @default(false)
  userId    Int
  user      User?    @relation(fields: [userId], references: [id])
}

model Membership {
  tenantId Int
  slug     String
  role     String?

  @@id([tenantId, slug])
}
''';

void main() {
  group('schema_to_runtime end-to-end', () {
    // ── Pipeline phase tests ──────────────────────────────────────────────

    test('SchemaParser produces a document with all declared models', () {
      final schema = const SchemaParser().parse(_fixtureSchema);

      expect(schema.models, hasLength(3));
      expect(schema.findModel('User'), isNotNull);
      expect(schema.findModel('Post'), isNotNull);
      expect(schema.findModel('Membership'), isNotNull);

      // Relation fields are parsed correctly.
      expect(schema.findModel('User')!.findField('posts')!.isList, isTrue);
      expect(
        schema.findModel('Post')!.findField('user')!.attribute('relation'),
        isNotNull,
      );

      // Compound id is recorded on Membership.
      expect(schema.findModel('Membership')!.attribute('id'), isNotNull);
    });

    test('SchemaValidator reports no issues for the fixture schema', () {
      final schema = const SchemaParser().parse(_fixtureSchema);
      final issues = const SchemaValidator().validate(schema);

      expect(
        issues,
        isEmpty,
        reason: 'fixture schema should be valid but got: $issues',
      );
    });

    test('ClientGenerator produces expected structural output', () {
      final schema = const SchemaParser().parse(_fixtureSchema);
      final code = const ClientGenerator().generateClient(schema);

      // Client class and delegate accessors.
      expect(code, contains('class GeneratedComonOrmClient {'));
      expect(code, contains('late final UserDelegate user'));
      expect(code, contains('late final PostDelegate post'));
      expect(code, contains('late final MembershipDelegate membership'));

      // Data model classes.
      expect(code, contains('class User {'));
      expect(code, contains('class Post {'));
      expect(code, contains('class Membership {'));

      // Input types for mutations.
      expect(code, contains('class UserCreateInput {'));
      expect(code, contains('class UserUpdateInput {'));
      expect(code, contains('class PostCreateWithoutUserInput {'));
      expect(code, contains('class PostCreateNestedManyWithoutUserInput {'));

      // Compiled runtime schema embedded in the client.
      expect(
        code,
        contains(
          'static const GeneratedRuntimeSchema runtimeSchema = GeneratedComonOrmMetadata.schema;',
        ),
      );

      // In-memory factory and transaction support.
      expect(code, contains('factory GeneratedComonOrmClient.openInMemory()'));
      expect(code, contains('Future<T> transaction<T>('));
    });

    // ── Runtime CRUD tests using the pre-compiled client ─────────────────

    late GeneratedComonOrmClient client;

    setUp(() {
      client = GeneratedComonOrmClient.openInMemory();
    });

    tearDown(() async {
      await client.close();
    });

    test('create and findMany return the created record', () async {
      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@test.com'),
      );

      final users = await client.user.findMany();
      expect(users, hasLength(1));
      expect(users.single.name, 'Alice');
      expect(users.single.email, 'alice@test.com');
    });

    test('findUnique returns a record by unique field', () async {
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'bob@test.com'),
      );

      final found = await client.user.findUnique(
        where: const UserWhereUniqueInput(email: 'bob@test.com'),
      );

      expect(found, isNotNull);
      expect(found!.name, 'Bob');
    });

    test('update changes specified fields and leaves others intact', () async {
      await client.user.create(
        data: const UserCreateInput(
          name: 'Carol',
          email: 'carol@test.com',
          country: 'US',
        ),
      );

      final updated = await client.user.update(
        where: const UserWhereUniqueInput(email: 'carol@test.com'),
        data: const UserUpdateInput(name: 'Caroline'),
      );

      expect(updated.name, 'Caroline');
      expect(updated.email, 'carol@test.com');
      expect(updated.country, 'US');
    });

    test('delete removes the record and returns its data', () async {
      await client.user.create(
        data: const UserCreateInput(name: 'Dave', email: 'dave@test.com'),
      );

      final deleted = await client.user.delete(
        where: const UserWhereUniqueInput(email: 'dave@test.com'),
      );

      expect(deleted.name, 'Dave');

      final remaining = await client.user.findMany();
      expect(remaining, isEmpty);
    });

    test(
      'nested create populates related posts and include returns them',
      () async {
        final user = await client.user.create(
          data: UserCreateInput(
            name: 'Eve',
            email: 'eve@test.com',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(
                  title: 'Hello World',
                  content: 'First post content',
                  published: true,
                ),
                PostCreateWithoutUserInput(title: 'Draft', published: false),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(user.posts, hasLength(2));
        final titles = user.posts!.map((p) => p.title).toList();
        expect(titles, containsAll(<String?>['Hello World', 'Draft']));

        // findMany with include should also return the related posts.
        final allUsers = await client.user.findMany(
          include: const UserInclude(posts: true),
        );
        expect(allUsers.single.posts, hasLength(2));
      },
    );

    test('transaction commits on success', () async {
      await client.transaction((tx) async {
        await tx.user.create(
          data: const UserCreateInput(name: 'Frank', email: 'frank@test.com'),
        );
        await tx.user.create(
          data: const UserCreateInput(name: 'Grace', email: 'grace@test.com'),
        );
      });

      final users = await client.user.findMany();
      expect(users, hasLength(2));
    });

    test('transaction rolls back on error', () async {
      await expectLater(
        client.transaction((tx) async {
          await tx.user.create(
            data: const UserCreateInput(name: 'Hank', email: 'hank@test.com'),
          );
          throw Exception('intentional failure');
        }),
        throwsException,
      );

      final users = await client.user.findMany();
      expect(users, isEmpty);
    });
  });
}
