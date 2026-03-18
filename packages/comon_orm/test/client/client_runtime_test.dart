import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

import '../generated/comon_orm_client.dart';
import '../generated/runtime_compound_direct_client.dart' as compound_generated;
import '../generated/runtime_required_inverse_client.dart'
    as required_inverse_generated;
import '../generated/runtime_rich_parity_client.dart' as rich_generated;

class _DuplicateOnCreateAdapter implements DatabaseAdapter {
  final List<String> createdEmails = <String>[];

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) {
    throw UnimplementedError();
  }

  @override
  void close() {}

  @override
  Future<int> count(CountQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> create(CreateQuery query) async {
    final email = query.data['email'] as String?;
    if (email != null && createdEmails.contains(email)) {
      throw const _FakeDuplicateServerException();
    }
    if (email != null) {
      createdEmails.add(email);
    }
    return Map<String, Object?>.unmodifiable(query.data);
  }

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<int> deleteMany(DeleteManyQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) async {
    return null;
  }

  @override
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action) {
    return action(this);
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<int> updateMany(UpdateManyQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object?>> upsert(UpsertQuery query) {
    throw UnimplementedError();
  }

  @override
  Future<int> createMany(CreateManyQuery query) async {
    var count = 0;
    for (final row in query.data) {
      final email = row['email'] as String?;
      if (email != null && createdEmails.contains(email)) {
        if (query.skipDuplicates) {
          continue;
        }
        throw const _FakeDuplicateServerException();
      }
      if (email != null) {
        createdEmails.add(email);
      }
      count++;
    }
    return count;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    throw UnimplementedError();
  }

  @override
  Future<int> rawExecute(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) {
    throw UnimplementedError();
  }
}

class _FakeDuplicateServerException implements Exception {
  const _FakeDuplicateServerException();

  String get code => '23505';

  @override
  String toString() {
    return 'duplicate key value violates unique constraint';
  }
}

void main() {
  group('ComonOrmClient', () {
    test('exposes compiled runtime metadata from the generated client', () {
      final schema = GeneratedComonOrmClient.runtimeSchema;
      final view = runtimeSchemaViewFromGeneratedSchema(schema);

      expect(view.findModel('User')?.findField('email')?.isUnique, isTrue);
      expect(
        view.findModel('Post')?.findField('user')?.relation?.targetModel,
        'User',
      );
      expect(view.findModel('Membership')?.primaryKeyFields, const <String>[
        'tenantId',
        'slug',
      ]);
      expect(
        GeneratedComonOrmClient.runtimeSchemaView.findModel('User'),
        isNotNull,
      );
    });

    test('opens generated client with in-memory adapter convenience', () async {
      final client = GeneratedComonOrmClient.openInMemory();

      final created = await client.user.create(
        data: const UserCreateInput(email: 'alice@example.com', name: 'Alice'),
      );

      expect(created.email, 'alice@example.com');
      final users = await client.user.findMany();
      expect(users, hasLength(1));
      await client.close();
    });

    test(
      'drives in-memory updatedAt behavior from generated metadata',
      () async {
        const schema = GeneratedRuntimeSchema(
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
                  name: 'name',
                  databaseName: 'name',
                  kind: GeneratedRuntimeFieldKind.scalar,
                  type: 'String',
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

        final adapter = InMemoryDatabaseAdapter.fromGeneratedSchema(
          schema: schema,
        );
        final client = ComonOrmClient(adapter: adapter);
        final createdAt = DateTime.utc(2026, 3, 15, 13, 0, 0);
        final updatedAt = DateTime.utc(2026, 3, 15, 13, 5, 0);

        adapter.now = () => createdAt;
        final created = await client
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{'id': 1, 'name': 'Alice'},
              ),
            );

        expect(created['updatedAt'], createdAt);

        adapter.now = () => updatedAt;
        final changed = await client
            .model('User')
            .update(
              const UpdateQuery(
                model: 'User',
                where: <QueryPredicate>[
                  QueryPredicate(field: 'id', operator: 'equals', value: 1),
                ],
                data: <String, Object?>{'name': 'Alice Updated'},
              ),
            );

        expect(changed['updatedAt'], updatedAt);
      },
    );

    test('creates and reads records through the in-memory adapter', () async {
      final client = ComonOrmClient(adapter: InMemoryDatabaseAdapter());
      final userDelegate = client.model('User');

      await userDelegate.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{'id': 1, 'email': 'alice@prisma.io'},
        ),
      );

      final users = await userDelegate.findMany(
        const FindManyQuery(model: 'User'),
      );

      expect(users, hasLength(1));
      expect(users.single['email'], 'alice@prisma.io');
    });

    test('commits transaction on success', () async {
      final client = ComonOrmClient(adapter: InMemoryDatabaseAdapter());

      await client.transaction((tx) async {
        await tx
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{'id': 1, 'email': 'alice@prisma.io'},
              ),
            );
      });

      final users = await client
          .model('User')
          .findMany(const FindManyQuery(model: 'User'));
      expect(users, hasLength(1));
    });

    test(
      'supports generated nested create, include, select and where',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: InMemoryDatabaseAdapter(),
        );

        final createdUser = await client.user.create(
          data: UserCreateInput(
            name: 'Alice',
            email: 'alice@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(
                  title: 'Hello World',
                  content: 'This is my first post!',
                  published: true,
                ),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(createdUser.id, 1);
        expect(createdUser.posts, hasLength(1));
        expect(createdUser.posts!.single, isA<Post>());
        expect(createdUser.posts!.single.userId, 1);

        final allUsers = await client.user.findMany(
          where: const UserWhereInput(email: 'alice@prisma.io'),
          include: const UserInclude(posts: true),
          select: const UserSelect(name: true, email: true),
        );

        expect(allUsers, hasLength(1));
        expect(allUsers.single.id, isNull);
        expect(allUsers.single.name, 'Alice');
        expect(allUsers.single.email, 'alice@prisma.io');
        expect(allUsers.single.posts, hasLength(1));
        expect(allUsers.single.posts!.single.title, 'Hello World');

        final fetchedUser = await client.user.findUnique(
          where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
          include: const UserInclude(posts: true),
        );

        expect(fetchedUser, isNotNull);
        expect(fetchedUser!.name, 'Alice');
        expect(fetchedUser.posts, hasLength(1));

        final updatedUser = await client.user.update(
          where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
          data: const UserUpdateInput(name: 'Alice Updated'),
          select: const UserSelect(name: true, email: true),
        );

        expect(updatedUser.name, 'Alice Updated');
        expect(updatedUser.email, 'alice@prisma.io');
        expect(updatedUser.id, isNull);

        final deletedUser = await client.user.delete(
          where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
          include: const UserInclude(posts: true),
        );

        expect(deletedUser.name, 'Alice Updated');
        expect(deletedUser.posts, hasLength(1));

        final remainingUsers = await client.user.findMany();
        expect(remainingUsers, isEmpty);
      },
    );

    test(
      'supports generated findFirst, count, updateMany and deleteMany',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: InMemoryDatabaseAdapter(),
        );

        await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        await client.user.create(
          data: const UserCreateInput(name: 'Bobby', email: 'bobby@prisma.io'),
        );

        final firstBob = await client.user.findFirst(
          where: const UserWhereInput(name: 'Bob'),
          select: const UserSelect(name: true, email: true),
        );

        expect(firstBob, isNotNull);
        expect(firstBob!.name, 'Bob');
        expect(firstBob.email, 'bob@prisma.io');

        final bobCount = await client.user.count(
          where: const UserWhereInput(name: 'Bob'),
        );
        expect(bobCount, 1);

        final updatedCount = await client.user.updateMany(
          where: const UserWhereInput(name: 'Bob'),
          data: const UserUpdateInput(name: 'Robert'),
        );
        expect(updatedCount, 1);

        final robertCount = await client.user.count(
          where: const UserWhereInput(name: 'Robert'),
        );
        expect(robertCount, 1);

        final deletedCount = await client.user.deleteMany(
          where: const UserWhereInput(name: 'Robert'),
        );
        expect(deletedCount, 1);

        final remainingCount = await client.user.count();
        expect(remainingCount, 2);
      },
    );

    test('supports generated upsert for create and update paths', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      final created = await client.user.upsert(
        where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
        create: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        update: const UserUpdateInput(name: 'Alice Updated'),
        select: const UserSelect(name: true, email: true),
      );

      expect(created.name, 'Alice');
      expect(created.email, 'alice@prisma.io');
      expect(created.id, isNull);

      final updated = await client.user.upsert(
        where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
        create: const UserCreateInput(name: 'Wrong', email: 'alice@prisma.io'),
        update: const UserUpdateInput(name: 'Alice Updated'),
        select: const UserSelect(name: true, email: true),
      );

      expect(updated.name, 'Alice Updated');
      expect(updated.email, 'alice@prisma.io');
      expect(updated.id, isNull);

      final users = await client.user.findMany();
      expect(users, hasLength(1));
    });

    test('supports generated createMany bulk writes', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      final createdCount = await client.user.createMany(
        data: const <UserCreateInput>[
          UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
          UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
          UserCreateInput(name: 'Carol', email: 'carol@prisma.io'),
        ],
      );

      expect(createdCount, 3);

      final users = await client.user.findMany(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true, email: true),
      );

      expect(users, hasLength(3));
      expect(
        users.map((user) => user.name).toList(growable: false),
        const <String?>['Alice', 'Bob', 'Carol'],
      );
    });

    test('supports generated createMany skipDuplicates', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      final createdCount = await client.user.createMany(
        skipDuplicates: true,
        data: const <UserCreateInput>[
          UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
          UserCreateInput(name: 'Alice Duplicate', email: 'alice@prisma.io'),
          UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        ],
      );

      expect(createdCount, 2);

      final users = await client.user.findMany(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(email: SortOrder.asc),
        ],
        select: const UserSelect(name: true, email: true),
      );

      expect(users, hasLength(2));
      expect(
        users.map((user) => user.email).toList(growable: false),
        const <String?>['alice@prisma.io', 'bob@prisma.io'],
      );
      expect(users.first.name, 'Alice');
    });

    test(
      'supports generated createMany skipDuplicates on duplicate provider errors',
      () async {
        final adapter = _DuplicateOnCreateAdapter();
        final client = GeneratedComonOrmClient(adapter: adapter);

        final createdCount = await client.user.createMany(
          skipDuplicates: true,
          data: const <UserCreateInput>[
            UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
            UserCreateInput(name: 'Alice Duplicate', email: 'alice@prisma.io'),
            UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
          ],
        );

        expect(createdCount, 2);
        expect(adapter.createdEmails, const <String>[
          'alice@prisma.io',
          'bob@prisma.io',
        ]);
      },
    );

    test('supports scalar update operators in update and upsert', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(
          name: 'Alice',
          email: 'alice@prisma.io',
          country: 'US',
          profileViews: 10,
        ),
      );

      final updated = await client.user.update(
        where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
        data: const UserUpdateInput(
          countryOps: StringFieldUpdateOperationsInput(set: null),
          profileViewsOps: IntFieldUpdateOperationsInput(increment: 5),
        ),
        select: const UserSelect(
          country: true,
          profileViews: true,
          email: true,
        ),
      );

      expect(updated.email, 'alice@prisma.io');
      expect(updated.country, isNull);
      expect(updated.profileViews, 15);

      final upserted = await client.user.upsert(
        where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
        create: const UserCreateInput(name: 'Wrong', email: 'alice@prisma.io'),
        update: const UserUpdateInput(
          profileViewsOps: IntFieldUpdateOperationsInput(decrement: 3),
        ),
        select: const UserSelect(profileViews: true, email: true),
      );

      expect(upserted.email, 'alice@prisma.io');
      expect(upserted.profileViews, 12);
    });

    test('supports computed scalar update operators in updateMany', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(
          name: 'Alice',
          email: 'alice@prisma.io',
          profileViews: 10,
          country: 'US',
        ),
      );
      await client.user.create(
        data: const UserCreateInput(
          name: 'Bob',
          email: 'bob@prisma.io',
          profileViews: 3,
          country: 'US',
        ),
      );

      final updatedCount = await client.user.updateMany(
        where: const UserWhereInput(email: 'alice@prisma.io'),
        data: const UserUpdateInput(
          profileViewsOps: IntFieldUpdateOperationsInput(increment: 1),
        ),
      );

      expect(updatedCount, 1);

      final updatedAlice = await client.user.findUnique(
        where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
        select: const UserSelect(profileViews: true, email: true),
      );

      expect(updatedAlice, isNotNull);
      expect(updatedAlice!.profileViews, 11);

      final updatedUsCount = await client.user.updateMany(
        where: const UserWhereInput(country: 'US'),
        data: const UserUpdateInput(
          profileViewsOps: IntFieldUpdateOperationsInput(increment: 2),
        ),
      );

      expect(updatedUsCount, 2);

      final updatedUsers = await client.user.findMany(
        where: const UserWhereInput(country: 'US'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(email: SortOrder.asc),
        ],
        select: const UserSelect(email: true, profileViews: true),
      );

      expect(updatedUsers, hasLength(2));
      expect(updatedUsers.first.email, 'alice@prisma.io');
      expect(updatedUsers.first.profileViews, 13);
      expect(updatedUsers.last.email, 'bob@prisma.io');
      expect(updatedUsers.last.profileViews, 5);

      await expectLater(
        () => client.user.updateMany(
          where: const UserWhereInput(email: 'alice@prisma.io'),
          data: const UserUpdateInput(
            profileViewsOps: IntFieldUpdateOperationsInput(
              increment: 1,
              decrement: 1,
            ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Only one scalar update operator may be provided'),
          ),
        ),
      );
    });

    test('supports nested relation writes in updateMany', () async {
      final client = GeneratedComonOrmClient(
        adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
      );

      final alice = await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
      );
      final charlie = await client.user.create(
        data: const UserCreateInput(
          name: 'Charlie',
          email: 'charlie@prisma.io',
        ),
      );

      await client.post.create(
        data: PostCreateInput(title: 'P1', userId: alice.id!),
      );
      await client.post.create(
        data: PostCreateInput(title: 'P2', userId: alice.id!),
      );

      final updatedCount = await client.post.updateMany(
        where: const PostWhereInput(userId: 1),
        data: const PostUpdateInput(
          user: UserUpdateNestedOneWithoutPostsInput(
            connect: UserWhereUniqueInput(email: 'charlie@prisma.io'),
          ),
        ),
      );

      expect(updatedCount, 2);

      final reassignedPosts = await client.post.findMany(
        where: PostWhereInput(userId: charlie.id),
        orderBy: const <PostOrderByInput>[PostOrderByInput(id: SortOrder.asc)],
        select: const PostSelect(id: true, userId: true),
      );

      expect(reassignedPosts, hasLength(2));
      expect(
        reassignedPosts.every((post) => post.userId == charlie.id),
        isTrue,
      );
    });

    test(
      'supports nested relation connect in update and upsert update branch',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        final charlie = await client.user.create(
          data: const UserCreateInput(
            name: 'Charlie',
            email: 'charlie@prisma.io',
          ),
        );

        final bobPost = await client.post.create(
          data: PostCreateInput(title: 'Bob Post', userId: bob.id!),
        );
        final alicePost = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );

        final updatedAlice = await client.user.update(
          where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
          data: UserUpdateInput(
            posts: PostUpdateNestedManyWithoutUserInput(
              connect: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: bobPost.id),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(updatedAlice.posts, hasLength(2));
        expect(
          updatedAlice.posts!.map((post) => post.title).toSet(),
          containsAll(<String>{'Alice Post', 'Bob Post'}),
        );

        final movedBobPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: bobPost.id),
          select: const PostSelect(userId: true),
        );
        expect(movedBobPost, isNotNull);
        expect(movedBobPost!.userId, alice.id);

        final reassignedPost = await client.post.upsert(
          where: PostWhereUniqueInput(id: alicePost.id),
          create: PostCreateInput(title: 'Unused', userId: alice.id!),
          update: const PostUpdateInput(
            user: UserUpdateNestedOneWithoutPostsInput(
              connect: UserWhereUniqueInput(email: 'charlie@prisma.io'),
            ),
          ),
          include: const PostInclude(user: true),
        );

        expect(reassignedPost.user, isNotNull);
        expect(reassignedPost.user!.email, 'charlie@prisma.io');

        final persistedPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: alicePost.id),
          select: const PostSelect(userId: true),
        );
        expect(persistedPost, isNotNull);
        expect(persistedPost!.userId, charlie.id);
      },
    );

    test(
      'supports nested relation connect and connectOrCreate in create',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );

        final attachedPost = await client.post.create(
          data: PostCreateInput(title: 'Attached Later', userId: alice.id!),
        );

        final charlie = await client.user.create(
          data: UserCreateInput(
            name: 'Charlie',
            email: 'charlie@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              connect: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: attachedPost.id),
              ],
              connectOrCreate: <PostConnectOrCreateWithoutUserInput>[
                PostConnectOrCreateWithoutUserInput(
                  where: const PostWhereUniqueInput(id: 999),
                  create: const PostCreateWithoutUserInput(
                    title: 'Created Inline',
                  ),
                ),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(charlie.posts, hasLength(2));
        expect(
          charlie.posts!.map((post) => post.title).toSet(),
          containsAll(<String>{'Attached Later', 'Created Inline'}),
        );

        final movedPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: attachedPost.id),
          select: const PostSelect(userId: true),
        );
        expect(movedPost, isNotNull);
        expect(movedPost!.userId, charlie.id);

        final createdInlinePost = await client.post.findMany(
          where: PostWhereInput(userId: charlie.id),
          orderBy: const <PostOrderByInput>[
            PostOrderByInput(id: SortOrder.asc),
          ],
          select: const PostSelect(userId: true, title: true),
        );
        expect(createdInlinePost, hasLength(2));
        expect(
          createdInlinePost.map((post) => post.title).toSet(),
          containsAll(<String?>{'Attached Later', 'Created Inline'}),
        );
      },
    );

    test(
      'supports create-path nested set for required direct list relations',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );

        final attachedPost = await client.post.create(
          data: PostCreateInput(title: 'Attached Later', userId: alice.id!),
        );

        final charlie = await client.user.create(
          data: UserCreateInput(
            name: 'Charlie',
            email: 'charlie@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              set: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: attachedPost.id),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(charlie.posts, hasLength(1));
        expect(charlie.posts!.single.id, attachedPost.id);

        final movedPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: attachedPost.id),
          select: const PostSelect(userId: true),
        );
        expect(movedPost, isNotNull);
        expect(movedPost!.userId, charlie.id);
      },
    );

    test(
      'supports create-path nested set for nullable direct list relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final manager = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );

        final report = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'report@prisma.io',
            role: rich_generated.UserRole.member,
            manager: rich_generated.UserCreateNestedOneWithoutReportsInput(
              connect: rich_generated.UserWhereUniqueInput(id: manager.id),
            ),
          ),
        );

        final created = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'set-list@prisma.io',
            role: rich_generated.UserRole.member,
            reports: rich_generated.UserCreateNestedManyWithoutManagerInput(
              set: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(id: report.id),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(created.reports, hasLength(1));
        expect(created.reports!.single.id, report.id);

        final movedReport = await client.user.findUnique(
          where: rich_generated.UserWhereUniqueInput(id: report.id),
          select: const rich_generated.UserSelect(managerId: true),
        );

        expect(movedReport, isNotNull);
        expect(movedReport!.managerId, created.id);
      },
    );

    test(
      'supports create-path nested disconnect as a no-op for required direct list relations',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final attachedPost = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );

        final bob = await client.user.create(
          data: UserCreateInput(
            name: 'Bob',
            email: 'bob@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              disconnect: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: attachedPost.id),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(bob.posts, isEmpty);

        final persistedPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: attachedPost.id),
          select: const PostSelect(userId: true),
        );
        expect(persistedPost, isNotNull);
        expect(persistedPost!.userId, alice.id);
      },
    );

    test(
      'supports create-path nested disconnect for nullable direct list relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final manager = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );

        final report = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'report@prisma.io',
            role: rich_generated.UserRole.member,
            manager: rich_generated.UserCreateNestedOneWithoutReportsInput(
              connect: rich_generated.UserWhereUniqueInput(id: manager.id),
            ),
          ),
        );

        final created = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'disconnect-list@prisma.io',
            role: rich_generated.UserRole.member,
            reports: rich_generated.UserCreateNestedManyWithoutManagerInput(
              disconnect: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(id: report.id),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(created.reports, isEmpty);

        final detachedReport = await client.user.findUnique(
          where: rich_generated.UserWhereUniqueInput(id: report.id),
          select: const rich_generated.UserSelect(managerId: true),
        );

        expect(detachedReport, isNotNull);
        expect(detachedReport!.managerId, isNull);
      },
    );

    test(
      'supports create-path nested writes for implicit many-to-many relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.group.create(
          data: const rich_generated.GroupCreateInput(id: 1),
        );

        final createdUser = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'alice@prisma.io',
            role: rich_generated.UserRole.admin,
            groups: const rich_generated.GroupCreateNestedManyWithoutUsersInput(
              connect: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
              ],
              connectOrCreate:
                  <rich_generated.GroupConnectOrCreateWithoutUsersInput>[
                    rich_generated.GroupConnectOrCreateWithoutUsersInput(
                      where: rich_generated.GroupWhereUniqueInput(id: 2),
                      create: rich_generated.GroupCreateWithoutUsersInput(
                        id: 2,
                      ),
                    ),
                  ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(createdUser.groups, hasLength(2));
        expect(
          createdUser.groups!.map((group) => group.id).toSet(),
          containsAll(<int>{1, 2}),
        );

        final group1 = await client.group.findUnique(
          where: const rich_generated.GroupWhereUniqueInput(id: 1),
          include: const rich_generated.GroupInclude(users: true),
        );
        final group2 = await client.group.findUnique(
          where: const rich_generated.GroupWhereUniqueInput(id: 2),
          include: const rich_generated.GroupInclude(users: true),
        );

        expect(group1, isNotNull);
        expect(group1!.users, hasLength(1));
        expect(group1.users!.single.email, 'alice@prisma.io');
        expect(group2, isNotNull);
        expect(group2!.users, hasLength(1));
        expect(group2.users!.single.email, 'alice@prisma.io');

        final createdWithSet = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'set@prisma.io',
            role: rich_generated.UserRole.member,
            groups: const rich_generated.GroupCreateNestedManyWithoutUsersInput(
              set: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
                rich_generated.GroupWhereUniqueInput(id: 2),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(createdWithSet.groups, hasLength(2));
        expect(
          createdWithSet.groups!.map((group) => group.id).toSet(),
          containsAll(<int>{1, 2}),
        );

        final createdWithDisconnect = await client.user.create(
          data: rich_generated.UserCreateInput(
            email: 'disconnect@prisma.io',
            role: rich_generated.UserRole.member,
            groups: const rich_generated.GroupCreateNestedManyWithoutUsersInput(
              connect: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
              ],
              disconnect: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(createdWithDisconnect.groups, isEmpty);
      },
    );

    test(
      'supports create-path nested writes for inverse one-to-one relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.profile.create(
          data: const rich_generated.ProfileCreateInput(id: 1),
        );

        final connectedUser = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'alice@prisma.io',
            role: rich_generated.UserRole.admin,
            profile: rich_generated.ProfileCreateNestedOneWithoutUserInput(
              connect: rich_generated.ProfileWhereUniqueInput(id: 1),
            ),
          ),
          include: const rich_generated.UserInclude(profile: true),
        );

        expect(connectedUser.profile, isNotNull);
        expect(connectedUser.profile!.id, 1);

        final profile1 = await client.profile.findUnique(
          where: const rich_generated.ProfileWhereUniqueInput(id: 1),
          select: const rich_generated.ProfileSelect(userId: true),
        );
        expect(profile1, isNotNull);
        expect(profile1!.userId, connectedUser.id);

        final connectOrCreatedUser = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'bob@prisma.io',
            role: rich_generated.UserRole.member,
            profile: rich_generated.ProfileCreateNestedOneWithoutUserInput(
              connectOrCreate:
                  rich_generated.ProfileConnectOrCreateWithoutUserInput(
                    where: rich_generated.ProfileWhereUniqueInput(id: 2),
                    create: rich_generated.ProfileCreateWithoutUserInput(id: 2),
                  ),
            ),
          ),
          include: const rich_generated.UserInclude(profile: true),
        );

        expect(connectOrCreatedUser.profile, isNotNull);
        expect(connectOrCreatedUser.profile!.id, 2);

        final profile2 = await client.profile.findUnique(
          where: const rich_generated.ProfileWhereUniqueInput(id: 2),
          select: const rich_generated.ProfileSelect(userId: true),
        );
        expect(profile2, isNotNull);
        expect(profile2!.userId, connectOrCreatedUser.id);

        final disconnectedDirect = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'disconnect-direct@prisma.io',
            role: rich_generated.UserRole.member,
            manager: rich_generated.UserCreateNestedOneWithoutReportsInput(
              disconnect: true,
            ),
          ),
          include: const rich_generated.UserInclude(manager: true),
        );

        expect(disconnectedDirect.manager, isNull);

        final disconnectedInverse = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'disconnect-inverse@prisma.io',
            role: rich_generated.UserRole.member,
            profile: rich_generated.ProfileCreateNestedOneWithoutUserInput(
              disconnect: true,
            ),
          ),
          include: const rich_generated.UserInclude(profile: true),
        );

        expect(disconnectedInverse.profile, isNull);
      },
    );

    test('supports compound direct nested relation writes', () async {
      final client = compound_generated.GeneratedComonOrmClient(
        adapter:
            compound_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
      );

      await client.account.create(
        data: const compound_generated.AccountCreateInput(
          tenantId: 1,
          slug: 'alpha',
          name: 'Alpha',
        ),
      );
      await client.account.create(
        data: const compound_generated.AccountCreateInput(
          tenantId: 1,
          slug: 'beta',
          name: 'Beta',
        ),
      );

      final session = await client.session.create(
        data: const compound_generated.SessionCreateInput(
          tenantId: 1,
          accountSlug: 'alpha',
          label: 'Session A',
        ),
      );

      final movedToBeta = await client.account.update(
        where: const compound_generated.AccountWhereUniqueInput(
          tenantId_slug:
              compound_generated.AccountTenantIdSlugCompoundUniqueInput(
                tenantId: 1,
                slug: 'beta',
              ),
        ),
        data: compound_generated.AccountUpdateInput(
          sessions:
              compound_generated.SessionUpdateNestedManyWithoutAccountInput(
                connect: <compound_generated.SessionWhereUniqueInput>[
                  compound_generated.SessionWhereUniqueInput(id: session.id),
                ],
              ),
        ),
        include: const compound_generated.AccountInclude(sessions: true),
      );

      expect(movedToBeta.sessions, hasLength(1));
      expect(movedToBeta.sessions!.single.label, 'Session A');

      final movedBackToAlpha = await client.session.update(
        where: compound_generated.SessionWhereUniqueInput(id: session.id),
        data: const compound_generated.SessionUpdateInput(
          account:
              compound_generated.AccountUpdateNestedOneWithoutSessionsInput(
                connect: compound_generated.AccountWhereUniqueInput(
                  tenantId_slug:
                      compound_generated.AccountTenantIdSlugCompoundUniqueInput(
                        tenantId: 1,
                        slug: 'alpha',
                      ),
                ),
              ),
        ),
        include: const compound_generated.SessionInclude(account: true),
      );

      expect(movedBackToAlpha.account, isNotNull);
      expect(movedBackToAlpha.account!.tenantId, 1);
      expect(movedBackToAlpha.account!.slug, 'alpha');

      await client.profile.create(
        data: const compound_generated.ProfileCreateInput(id: 1),
      );

      final connectedProfile = await client.account.update(
        where: const compound_generated.AccountWhereUniqueInput(
          tenantId_slug:
              compound_generated.AccountTenantIdSlugCompoundUniqueInput(
                tenantId: 1,
                slug: 'alpha',
              ),
        ),
        data: const compound_generated.AccountUpdateInput(
          profile: compound_generated.ProfileUpdateNestedOneWithoutAccountInput(
            connect: compound_generated.ProfileWhereUniqueInput(id: 1),
          ),
        ),
        include: const compound_generated.AccountInclude(profile: true),
      );

      expect(connectedProfile.profile, isNotNull);
      expect(connectedProfile.profile!.id, 1);

      final createdWithConnectedSession = await client.account.create(
        data: compound_generated.AccountCreateInput(
          tenantId: 2,
          slug: 'gamma',
          name: 'Gamma',
          sessions:
              compound_generated.SessionCreateNestedManyWithoutAccountInput(
                connect: <compound_generated.SessionWhereUniqueInput>[
                  compound_generated.SessionWhereUniqueInput(id: session.id),
                ],
              ),
        ),
        include: const compound_generated.AccountInclude(sessions: true),
      );

      expect(createdWithConnectedSession.sessions, hasLength(1));
      expect(createdWithConnectedSession.sessions!.single.id, session.id);

      final createdWithSetSession = await client.account.create(
        data: compound_generated.AccountCreateInput(
          tenantId: 4,
          slug: 'epsilon',
          name: 'Epsilon',
          sessions:
              compound_generated.SessionCreateNestedManyWithoutAccountInput(
                set: <compound_generated.SessionWhereUniqueInput>[
                  compound_generated.SessionWhereUniqueInput(id: session.id),
                ],
              ),
        ),
        include: const compound_generated.AccountInclude(sessions: true),
      );

      expect(createdWithSetSession.sessions, hasLength(1));
      expect(createdWithSetSession.sessions!.single.id, session.id);

      await client.session.create(
        data: const compound_generated.SessionCreateInput(
          tenantId: 4,
          accountSlug: 'epsilon',
          label: 'Session E',
        ),
      );

      await expectLater(
        client.account.update(
          where: const compound_generated.AccountWhereUniqueInput(
            tenantId_slug:
                compound_generated.AccountTenantIdSlugCompoundUniqueInput(
                  tenantId: 4,
                  slug: 'epsilon',
                ),
          ),
          data: compound_generated.AccountUpdateInput(
            sessions:
                compound_generated.SessionUpdateNestedManyWithoutAccountInput(
                  set: <compound_generated.SessionWhereUniqueInput>[
                    compound_generated.SessionWhereUniqueInput(id: session.id),
                  ],
                ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested set is not supported for required relation Account.sessions when it would disconnect already attached required related records.',
            ),
          ),
        ),
      );

      final createdWithProfile = await client.account.create(
        data: const compound_generated.AccountCreateInput(
          tenantId: 3,
          slug: 'delta',
          name: 'Delta',
          profile: compound_generated.ProfileCreateNestedOneWithoutAccountInput(
            connectOrCreate:
                compound_generated.ProfileConnectOrCreateWithoutAccountInput(
                  where: compound_generated.ProfileWhereUniqueInput(id: 2),
                  create: compound_generated.ProfileCreateWithoutAccountInput(
                    id: 2,
                    bio: 'Created inline',
                  ),
                ),
          ),
        ),
        include: const compound_generated.AccountInclude(profile: true),
      );

      expect(createdWithProfile.profile, isNotNull);
      expect(createdWithProfile.profile!.id, 2);

      final persistedProfile = await client.profile.findUnique(
        where: const compound_generated.ProfileWhereUniqueInput(id: 2),
        select: const compound_generated.ProfileSelect(
          tenantId: true,
          accountSlug: true,
          bio: true,
        ),
      );

      expect(persistedProfile, isNotNull);
      expect(persistedProfile!.tenantId, 3);
      expect(persistedProfile.accountSlug, 'delta');
      expect(persistedProfile.bio, 'Created inline');
    });

    test(
      'supports create-path nested writes for nullable direct singular relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final manager = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );

        final connectedReport = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report1@prisma.io',
            role: rich_generated.UserRole.member,
            manager: rich_generated.UserCreateNestedOneWithoutReportsInput(
              connect: rich_generated.UserWhereUniqueInput(
                email: 'manager@prisma.io',
              ),
            ),
          ),
          include: const rich_generated.UserInclude(manager: true),
        );

        expect(connectedReport.manager, isNotNull);
        expect(connectedReport.manager!.email, 'manager@prisma.io');

        final persistedConnectedReport = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report1@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );
        expect(persistedConnectedReport, isNotNull);
        expect(persistedConnectedReport!.managerId, manager.id);

        final createdManagerReport = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report2@prisma.io',
            role: rich_generated.UserRole.member,
            manager: rich_generated.UserCreateNestedOneWithoutReportsInput(
              connectOrCreate:
                  rich_generated.UserConnectOrCreateWithoutReportsInput(
                    where: rich_generated.UserWhereUniqueInput(
                      email: 'lead@prisma.io',
                    ),
                    create: rich_generated.UserCreateWithoutReportsInput(
                      email: 'lead@prisma.io',
                      role: rich_generated.UserRole.admin,
                    ),
                  ),
            ),
          ),
          include: const rich_generated.UserInclude(manager: true),
        );

        expect(createdManagerReport.manager, isNotNull);
        expect(createdManagerReport.manager!.email, 'lead@prisma.io');

        final createdManager = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'lead@prisma.io',
          ),
          include: const rich_generated.UserInclude(reports: true),
        );
        expect(createdManager, isNotNull);
        expect(createdManager!.reports, hasLength(1));
        expect(createdManager.reports!.single.email, 'report2@prisma.io');
      },
    );

    test(
      'supports nested relation connect and disconnect for nullable direct relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );
        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report1@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );
        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report2@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );

        final connectedManager = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              connect: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(email: 'report1@prisma.io'),
                rich_generated.UserWhereUniqueInput(email: 'report2@prisma.io'),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(connectedManager.reports, hasLength(2));

        final disconnectedManager = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              disconnect: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(email: 'report1@prisma.io'),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(disconnectedManager.reports, hasLength(1));
        expect(disconnectedManager.reports!.single.email, 'report2@prisma.io');

        final disconnectedReport = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report2@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            manager: rich_generated.UserUpdateNestedOneWithoutReportsInput(
              disconnect: true,
            ),
          ),
          include: const rich_generated.UserInclude(manager: true),
        );

        expect(disconnectedReport.manager, isNull);

        final persistedReport = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report1@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );
        expect(persistedReport, isNotNull);
        expect(persistedReport!.managerId, isNull);
      },
    );

    test(
      'supports nested relation connectOrCreate for nullable direct list relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final manager = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );

        final firstAttach = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              connectOrCreate:
                  <rich_generated.UserConnectOrCreateWithoutManagerInput>[
                    rich_generated.UserConnectOrCreateWithoutManagerInput(
                      where: rich_generated.UserWhereUniqueInput(
                        email: 'report@prisma.io',
                      ),
                      create: rich_generated.UserCreateWithoutManagerInput(
                        email: 'report@prisma.io',
                        role: rich_generated.UserRole.member,
                      ),
                    ),
                  ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(firstAttach.reports, hasLength(1));
        expect(firstAttach.reports!.single.email, 'report@prisma.io');

        final secondAttach = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              connectOrCreate:
                  <rich_generated.UserConnectOrCreateWithoutManagerInput>[
                    rich_generated.UserConnectOrCreateWithoutManagerInput(
                      where: rich_generated.UserWhereUniqueInput(
                        email: 'report@prisma.io',
                      ),
                      create: rich_generated.UserCreateWithoutManagerInput(
                        email: 'report@prisma.io',
                        role: rich_generated.UserRole.member,
                      ),
                    ),
                  ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(secondAttach.reports, hasLength(1));

        final persistedReport = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );

        expect(persistedReport, isNotNull);
        expect(persistedReport!.managerId, manager.id);
      },
    );

    test(
      'supports nested relation connectOrCreate for nullable direct singular relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );

        final connectedReport = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            manager: rich_generated.UserUpdateNestedOneWithoutReportsInput(
              connectOrCreate:
                  rich_generated.UserConnectOrCreateWithoutReportsInput(
                    where: rich_generated.UserWhereUniqueInput(
                      email: 'manager@prisma.io',
                    ),
                    create: rich_generated.UserCreateWithoutReportsInput(
                      email: 'manager@prisma.io',
                      role: rich_generated.UserRole.admin,
                    ),
                  ),
            ),
          ),
          include: const rich_generated.UserInclude(manager: true),
        );

        expect(connectedReport.manager, isNotNull);
        expect(connectedReport.manager!.email, 'manager@prisma.io');

        final allManagers = await client.user.findMany(
          where: const rich_generated.UserWhereInput(
            emailFilter: StringFilter(contains: 'manager@prisma.io'),
          ),
          select: const rich_generated.UserSelect(email: true),
        );
        expect(allManagers, hasLength(1));
      },
    );

    test(
      'supports nested relation set for nullable direct list relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final manager = await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'manager@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );
        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report1@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );
        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report2@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );
        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'report3@prisma.io',
            role: rich_generated.UserRole.member,
          ),
        );

        await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              connect: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(email: 'report1@prisma.io'),
                rich_generated.UserWhereUniqueInput(email: 'report2@prisma.io'),
              ],
            ),
          ),
        );

        final replacedReports = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              set: <rich_generated.UserWhereUniqueInput>[
                rich_generated.UserWhereUniqueInput(email: 'report2@prisma.io'),
                rich_generated.UserWhereUniqueInput(email: 'report3@prisma.io'),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(replacedReports.reports, hasLength(2));
        expect(
          replacedReports.reports!.map((user) => user.email).toSet(),
          containsAll(<String>{'report2@prisma.io', 'report3@prisma.io'}),
        );

        final report1 = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report1@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );
        final report2 = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report2@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );
        final report3 = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report3@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );

        expect(report1, isNotNull);
        expect(report1!.managerId, isNull);
        expect(report2, isNotNull);
        expect(report2!.managerId, manager.id);
        expect(report3, isNotNull);
        expect(report3!.managerId, manager.id);

        final clearedReports = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'manager@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            reports: rich_generated.UserUpdateNestedManyWithoutManagerInput(
              set: <rich_generated.UserWhereUniqueInput>[],
            ),
          ),
          include: const rich_generated.UserInclude(reports: true),
        );

        expect(clearedReports.reports, isEmpty);

        final clearedReport2 = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report2@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );
        final clearedReport3 = await client.user.findUnique(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'report3@prisma.io',
          ),
          select: const rich_generated.UserSelect(managerId: true),
        );

        expect(clearedReport2, isNotNull);
        expect(clearedReport2!.managerId, isNull);
        expect(clearedReport3, isNotNull);
        expect(clearedReport3!.managerId, isNull);
      },
    );

    test(
      'supports nested writes for implicit many-to-many relations',
      () async {
        final client = rich_generated.GeneratedComonOrmClient(
          adapter:
              rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.user.create(
          data: const rich_generated.UserCreateInput(
            email: 'alice@prisma.io',
            role: rich_generated.UserRole.admin,
          ),
        );
        await client.group.create(
          data: const rich_generated.GroupCreateInput(id: 1),
        );
        await client.group.create(
          data: const rich_generated.GroupCreateInput(id: 3),
        );

        final afterConnect = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'alice@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            groups: rich_generated.GroupUpdateNestedManyWithoutUsersInput(
              connect: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(afterConnect.groups, hasLength(1));
        expect(afterConnect.groups!.single.id, 1);

        final afterConnectOrCreate = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'alice@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            groups: rich_generated.GroupUpdateNestedManyWithoutUsersInput(
              connectOrCreate:
                  <rich_generated.GroupConnectOrCreateWithoutUsersInput>[
                    rich_generated.GroupConnectOrCreateWithoutUsersInput(
                      where: rich_generated.GroupWhereUniqueInput(id: 2),
                      create: rich_generated.GroupCreateWithoutUsersInput(
                        id: 2,
                      ),
                    ),
                  ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(afterConnectOrCreate.groups, hasLength(2));
        expect(
          afterConnectOrCreate.groups!.map((group) => group.id).toSet(),
          containsAll(<int>{1, 2}),
        );

        final group2 = await client.group.findUnique(
          where: const rich_generated.GroupWhereUniqueInput(id: 2),
          include: const rich_generated.GroupInclude(users: true),
        );

        expect(group2, isNotNull);
        expect(group2!.users, hasLength(1));
        expect(group2.users!.single.email, 'alice@prisma.io');

        final afterDisconnect = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'alice@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            groups: rich_generated.GroupUpdateNestedManyWithoutUsersInput(
              disconnect: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 1),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(afterDisconnect.groups, hasLength(1));
        expect(afterDisconnect.groups!.single.id, 2);

        final afterSet = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'alice@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            groups: rich_generated.GroupUpdateNestedManyWithoutUsersInput(
              set: <rich_generated.GroupWhereUniqueInput>[
                rich_generated.GroupWhereUniqueInput(id: 2),
                rich_generated.GroupWhereUniqueInput(id: 3),
              ],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(afterSet.groups, hasLength(2));
        expect(
          afterSet.groups!.map((group) => group.id).toSet(),
          containsAll(<int>{2, 3}),
        );

        final afterClear = await client.user.update(
          where: const rich_generated.UserWhereUniqueInput(
            email: 'alice@prisma.io',
          ),
          data: const rich_generated.UserUpdateInput(
            groups: rich_generated.GroupUpdateNestedManyWithoutUsersInput(
              set: <rich_generated.GroupWhereUniqueInput>[],
            ),
          ),
          include: const rich_generated.UserInclude(groups: true),
        );

        expect(afterClear.groups, isEmpty);
      },
    );

    test('supports nested writes for inverse one-to-one relations', () async {
      final client = rich_generated.GeneratedComonOrmClient(
        adapter: rich_generated.GeneratedComonOrmClient.createInMemoryAdapter(),
      );

      final user = await client.user.create(
        data: const rich_generated.UserCreateInput(
          email: 'alice@prisma.io',
          role: rich_generated.UserRole.admin,
        ),
      );
      await client.profile.create(
        data: const rich_generated.ProfileCreateInput(id: 1),
      );
      await client.profile.create(
        data: const rich_generated.ProfileCreateInput(id: 3),
      );

      final afterConnect = await client.user.update(
        where: const rich_generated.UserWhereUniqueInput(
          email: 'alice@prisma.io',
        ),
        data: const rich_generated.UserUpdateInput(
          profile: rich_generated.ProfileUpdateNestedOneWithoutUserInput(
            connect: rich_generated.ProfileWhereUniqueInput(id: 1),
          ),
        ),
        include: const rich_generated.UserInclude(profile: true),
      );

      expect(afterConnect.profile, isNotNull);
      expect(afterConnect.profile!.id, 1);

      final afterReconnect = await client.user.update(
        where: const rich_generated.UserWhereUniqueInput(
          email: 'alice@prisma.io',
        ),
        data: const rich_generated.UserUpdateInput(
          profile: rich_generated.ProfileUpdateNestedOneWithoutUserInput(
            connect: rich_generated.ProfileWhereUniqueInput(id: 3),
          ),
        ),
        include: const rich_generated.UserInclude(profile: true),
      );

      expect(afterReconnect.profile, isNotNull);
      expect(afterReconnect.profile!.id, 3);

      final profile1 = await client.profile.findUnique(
        where: const rich_generated.ProfileWhereUniqueInput(id: 1),
        select: const rich_generated.ProfileSelect(userId: true),
      );

      expect(profile1, isNotNull);
      expect(profile1!.userId, isNull);

      final afterConnectOrCreate = await client.user.update(
        where: const rich_generated.UserWhereUniqueInput(
          email: 'alice@prisma.io',
        ),
        data: const rich_generated.UserUpdateInput(
          profile: rich_generated.ProfileUpdateNestedOneWithoutUserInput(
            connectOrCreate:
                rich_generated.ProfileConnectOrCreateWithoutUserInput(
                  where: rich_generated.ProfileWhereUniqueInput(id: 2),
                  create: rich_generated.ProfileCreateWithoutUserInput(id: 2),
                ),
          ),
        ),
        include: const rich_generated.UserInclude(profile: true),
      );

      expect(afterConnectOrCreate.profile, isNotNull);
      expect(afterConnectOrCreate.profile!.id, 2);

      final profile2 = await client.profile.findUnique(
        where: const rich_generated.ProfileWhereUniqueInput(id: 2),
        select: const rich_generated.ProfileSelect(userId: true),
      );
      final profile3 = await client.profile.findUnique(
        where: const rich_generated.ProfileWhereUniqueInput(id: 3),
        select: const rich_generated.ProfileSelect(userId: true),
      );

      expect(profile2, isNotNull);
      expect(profile2!.userId, user.id);
      expect(profile3, isNotNull);
      expect(profile3!.userId, isNull);

      final afterDisconnect = await client.user.update(
        where: const rich_generated.UserWhereUniqueInput(
          email: 'alice@prisma.io',
        ),
        data: const rich_generated.UserUpdateInput(
          profile: rich_generated.ProfileUpdateNestedOneWithoutUserInput(
            disconnect: true,
          ),
        ),
        include: const rich_generated.UserInclude(profile: true),
      );

      expect(afterDisconnect.profile, isNull);

      final detachedProfile2 = await client.profile.findUnique(
        where: const rich_generated.ProfileWhereUniqueInput(id: 2),
        select: const rich_generated.ProfileSelect(userId: true),
      );

      expect(detachedProfile2, isNotNull);
      expect(detachedProfile2!.userId, isNull);
    });

    test(
      'rejects nested relation set for required direct list relations',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        final post = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Bob Post', userId: bob.id!),
        );

        await expectLater(
          client.user.update(
            where: const UserWhereUniqueInput(email: 'bob@prisma.io'),
            data: UserUpdateInput(
              posts: PostUpdateNestedManyWithoutUserInput(
                set: <PostWhereUniqueInput>[PostWhereUniqueInput(id: post.id)],
              ),
            ),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains(
                'Nested set is not supported for required relation User.posts when it would disconnect already attached required related records.',
              ),
            ),
          ),
        );
      },
    );

    test(
      'supports additive nested relation set for required direct list relations',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        final post = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );
        final bobPost = await client.post.create(
          data: PostCreateInput(title: 'Bob Post', userId: bob.id!),
        );

        final updatedBob = await client.user.update(
          where: const UserWhereUniqueInput(email: 'bob@prisma.io'),
          data: UserUpdateInput(
            posts: PostUpdateNestedManyWithoutUserInput(
              set: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: bobPost.id),
                PostWhereUniqueInput(id: post.id),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(updatedBob.posts, hasLength(2));
        expect(
          updatedBob.posts!.map((item) => item.title).toSet(),
          containsAll(<String?>{'Alice Post', 'Bob Post'}),
        );
      },
    );

    test(
      'rejects nested disconnect for attached required direct list relations',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final post = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );

        await expectLater(
          client.user.update(
            where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
            data: UserUpdateInput(
              posts: PostUpdateNestedManyWithoutUserInput(
                disconnect: <PostWhereUniqueInput>[
                  PostWhereUniqueInput(id: post.id),
                ],
              ),
            ),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains(
                'Nested disconnect is not supported for required relation User.posts when it would disconnect already attached required related records.',
              ),
            ),
          ),
        );
      },
    );

    test(
      'supports nested disconnect as a no-op for unrelated required direct list records',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        final alicePost = await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );
        final bobPost = await client.post.create(
          data: PostCreateInput(title: 'Bob Post', userId: bob.id!),
        );

        final updatedAlice = await client.user.update(
          where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
          data: UserUpdateInput(
            posts: PostUpdateNestedManyWithoutUserInput(
              disconnect: <PostWhereUniqueInput>[
                PostWhereUniqueInput(id: bobPost.id),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        expect(updatedAlice.posts, hasLength(1));
        expect(updatedAlice.posts!.single.id, alicePost.id);

        final persistedBobPost = await client.post.findUnique(
          where: PostWhereUniqueInput(id: bobPost.id),
          select: const PostSelect(userId: true),
        );
        expect(persistedBobPost, isNotNull);
        expect(persistedBobPost!.userId, bob.id);
      },
    );

    test(
      'treats required inverse one-to-one disconnect as a no-op when nothing is attached',
      () async {
        final client = required_inverse_generated.GeneratedComonOrmClient(
          adapter: required_inverse_generated
              .GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        final createdUser = await client.user.create(
          data: const required_inverse_generated.UserCreateInput(
            email: 'create-noop@prisma.io',
            profile:
                required_inverse_generated.ProfileCreateNestedOneWithoutUserInput(
                  disconnect: true,
                ),
          ),
          include: const required_inverse_generated.UserInclude(profile: true),
        );

        expect(createdUser.profile, isNull);

        final updatedUser = await client.user.update(
          where: required_inverse_generated.UserWhereUniqueInput(
            id: createdUser.id,
          ),
          data: const required_inverse_generated.UserUpdateInput(
            profile:
                required_inverse_generated.ProfileUpdateNestedOneWithoutUserInput(
                  disconnect: true,
                ),
          ),
          include: const required_inverse_generated.UserInclude(profile: true),
        );

        expect(updatedUser.profile, isNull);
      },
    );

    test('preserves required inverse one-to-one replacement guardrails', () async {
      final client = required_inverse_generated.GeneratedComonOrmClient(
        adapter: required_inverse_generated
            .GeneratedComonOrmClient.createInMemoryAdapter(),
      );

      final alice = await client.user.create(
        data: const required_inverse_generated.UserCreateInput(
          email: 'alice@prisma.io',
        ),
      );
      final bob = await client.user.create(
        data: const required_inverse_generated.UserCreateInput(
          email: 'bob@prisma.io',
        ),
      );
      await client.profile.create(
        data: required_inverse_generated.ProfileCreateInput(
          id: 1,
          userId: alice.id!,
          bio: 'Alice profile',
        ),
      );
      await client.profile.create(
        data: required_inverse_generated.ProfileCreateInput(
          id: 2,
          userId: bob.id!,
          bio: 'Bob profile',
        ),
      );

      await expectLater(
        client.user.update(
          where: required_inverse_generated.UserWhereUniqueInput(id: alice.id),
          data: const required_inverse_generated.UserUpdateInput(
            profile:
                required_inverse_generated.ProfileUpdateNestedOneWithoutUserInput(
                  connect: required_inverse_generated.ProfileWhereUniqueInput(
                    id: 2,
                  ),
                ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested connect cannot replace the existing inverse one-to-one relation User.profile because Profile.userId is required.',
            ),
          ),
        ),
      );

      await expectLater(
        client.user.update(
          where: required_inverse_generated.UserWhereUniqueInput(id: alice.id),
          data: const required_inverse_generated.UserUpdateInput(
            profile: required_inverse_generated.ProfileUpdateNestedOneWithoutUserInput(
              connectOrCreate:
                  required_inverse_generated.ProfileConnectOrCreateWithoutUserInput(
                    where: required_inverse_generated.ProfileWhereUniqueInput(
                      id: 3,
                    ),
                    create:
                        required_inverse_generated.ProfileCreateWithoutUserInput(
                          id: 3,
                          bio: 'Inline profile',
                        ),
                  ),
            ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested connectOrCreate cannot create a new inverse one-to-one relation User.profile because Profile.userId is required and already attached.',
            ),
          ),
        ),
      );

      await expectLater(
        client.user.update(
          where: required_inverse_generated.UserWhereUniqueInput(id: alice.id),
          data: const required_inverse_generated.UserUpdateInput(
            profile:
                required_inverse_generated.ProfileUpdateNestedOneWithoutUserInput(
                  disconnect: true,
                ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested disconnect is not supported for required inverse one-to-one relation User.profile.',
            ),
          ),
        ),
      );
    });

    test(
      'preserves compound required inverse one-to-one disconnect guardrails',
      () async {
        final client = required_inverse_generated.GeneratedComonOrmClient(
          adapter: required_inverse_generated
              .GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.account.create(
          data: const required_inverse_generated.AccountCreateInput(
            tenantId: 1,
            slug: 'alpha',
          ),
        );
        await client.accountProfile.create(
          data: const required_inverse_generated.AccountProfileCreateInput(
            id: 1,
            tenantId: 1,
            accountSlug: 'alpha',
            bio: 'Alpha profile',
          ),
        );

        await expectLater(
          client.account.update(
            where: const required_inverse_generated.AccountWhereUniqueInput(
              tenantId_slug:
                  required_inverse_generated.AccountTenantIdSlugCompoundUniqueInput(
                    tenantId: 1,
                    slug: 'alpha',
                  ),
            ),
            data: const required_inverse_generated.AccountUpdateInput(
              profile:
                  required_inverse_generated.AccountProfileUpdateNestedOneWithoutAccountInput(
                    disconnect: true,
                  ),
            ),
          ),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains(
                'Nested disconnect is not supported for required inverse one-to-one relation Account.profile.',
              ),
            ),
          ),
        );
      },
    );

    test('preserves compound required inverse one-to-one replacement guardrails', () async {
      final client = required_inverse_generated.GeneratedComonOrmClient(
        adapter: required_inverse_generated
            .GeneratedComonOrmClient.createInMemoryAdapter(),
      );

      await client.account.create(
        data: const required_inverse_generated.AccountCreateInput(
          tenantId: 1,
          slug: 'alpha',
        ),
      );
      await client.account.create(
        data: const required_inverse_generated.AccountCreateInput(
          tenantId: 1,
          slug: 'beta',
        ),
      );
      await client.accountProfile.create(
        data: const required_inverse_generated.AccountProfileCreateInput(
          id: 1,
          tenantId: 1,
          accountSlug: 'alpha',
          bio: 'Alpha profile',
        ),
      );
      await client.accountProfile.create(
        data: const required_inverse_generated.AccountProfileCreateInput(
          id: 2,
          tenantId: 1,
          accountSlug: 'beta',
          bio: 'Beta profile',
        ),
      );

      await expectLater(
        client.account.update(
          where: const required_inverse_generated.AccountWhereUniqueInput(
            tenantId_slug:
                required_inverse_generated.AccountTenantIdSlugCompoundUniqueInput(
                  tenantId: 1,
                  slug: 'alpha',
                ),
          ),
          data: const required_inverse_generated.AccountUpdateInput(
            profile: required_inverse_generated.AccountProfileUpdateNestedOneWithoutAccountInput(
              connectOrCreate:
                  required_inverse_generated.AccountProfileConnectOrCreateWithoutAccountInput(
                    where:
                        required_inverse_generated.AccountProfileWhereUniqueInput(
                          id: 2,
                        ),
                    create:
                        required_inverse_generated.AccountProfileCreateWithoutAccountInput(
                          id: 2,
                          bio: 'Beta profile',
                        ),
                  ),
            ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested connectOrCreate cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.',
            ),
          ),
        ),
      );

      await expectLater(
        client.account.update(
          where: const required_inverse_generated.AccountWhereUniqueInput(
            tenantId_slug:
                required_inverse_generated.AccountTenantIdSlugCompoundUniqueInput(
                  tenantId: 1,
                  slug: 'alpha',
                ),
          ),
          data: const required_inverse_generated.AccountUpdateInput(
            profile:
                required_inverse_generated.AccountProfileUpdateNestedOneWithoutAccountInput(
                  connect:
                      required_inverse_generated.AccountProfileWhereUniqueInput(
                        id: 2,
                      ),
                ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested connect cannot replace the existing inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required.',
            ),
          ),
        ),
      );

      await expectLater(
        client.account.update(
          where: const required_inverse_generated.AccountWhereUniqueInput(
            tenantId_slug:
                required_inverse_generated.AccountTenantIdSlugCompoundUniqueInput(
                  tenantId: 1,
                  slug: 'alpha',
                ),
          ),
          data: const required_inverse_generated.AccountUpdateInput(
            profile: required_inverse_generated.AccountProfileUpdateNestedOneWithoutAccountInput(
              connectOrCreate:
                  required_inverse_generated.AccountProfileConnectOrCreateWithoutAccountInput(
                    where:
                        required_inverse_generated.AccountProfileWhereUniqueInput(
                          id: 3,
                        ),
                    create:
                        required_inverse_generated.AccountProfileCreateWithoutAccountInput(
                          id: 3,
                          bio: 'Gamma profile',
                        ),
                  ),
            ),
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains(
              'Nested connectOrCreate cannot create a new inverse one-to-one relation Account.profile because AccountProfile.tenantId, accountSlug is required and already attached.',
            ),
          ),
        ),
      );
    });

    test('generated models support copyWith, json and deep equality', () {
      final original = User(
        id: 1,
        name: 'Alice',
        email: 'alice@prisma.io',
        country: 'US',
        profileViews: 10,
        posts: const <Post>[
          Post(id: 7, title: 'Hello', published: true, userId: 1),
        ],
      );

      final updated = original.copyWith(country: null, profileViews: 11);

      expect(updated.id, 1);
      expect(updated.country, isNull);
      expect(updated.profileViews, 11);
      expect(updated.posts, hasLength(1));

      final json = original.toJson();
      final decoded = User.fromJson(json);

      expect(decoded, original);
      expect(decoded.hashCode, original.hashCode);
      expect(decoded.toString(), contains('User('));
      expect(decoded.posts, hasLength(1));
      expect(decoded.posts!.single.title, 'Hello');
    });

    test('supports generated scalar filters in where inputs', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Alicia', email: 'alicia@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
      );

      final containsAli = await client.user.findMany(
        where: const UserWhereInput(nameFilter: StringFilter(contains: 'Ali')),
        select: const UserSelect(name: true),
      );
      expect(containsAli, hasLength(2));

      final startsWithAli = await client.user.count(
        where: const UserWhereInput(
          nameFilter: StringFilter(startsWith: 'Ali'),
        ),
      );
      expect(startsWithAli, 2);

      final notBob = await client.user.count(
        where: const UserWhereInput(nameFilter: StringFilter(not: 'Bob')),
      );
      expect(notBob, 2);

      final idRange = await client.user.findMany(
        where: const UserWhereInput(idFilter: IntFilter(gte: 2, lte: 3)),
        select: const UserSelect(name: true, email: true),
      );
      expect(idRange, hasLength(2));

      final inList = await client.user.count(
        where: const UserWhereInput(
          emailFilter: StringFilter(
            inList: <String>['alice@prisma.io', 'bob@prisma.io'],
          ),
        ),
      );
      expect(inList, 2);
    });

    test(
      'supports notIn and case-insensitive filters via in-memory adapter',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: InMemoryDatabaseAdapter(),
        );

        await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );
        await client.user.create(
          data: const UserCreateInput(
            name: 'Alicia',
            email: 'alicia@prisma.io',
          ),
        );
        await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
        );
        await client.user.create(
          data: const UserCreateInput(name: 'Carol', email: 'carol@prisma.io'),
        );

        // notIn — exclude specific emails
        final notInBob = await client.user.findMany(
          where: const UserWhereInput(
            emailFilter: StringFilter(
              notInList: <String>['bob@prisma.io', 'carol@prisma.io'],
            ),
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true),
        );
        expect(notInBob.map((u) => u.name).toList(), <String?>[
          'Alice',
          'Alicia',
        ]);

        // notIn on IntFilter — exclude ids 1 and 2
        final notInIds = await client.user.findMany(
          where: const UserWhereInput(
            idFilter: IntFilter(notInList: <int>[1, 2]),
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true),
        );
        expect(notInIds.map((u) => u.name).toList(), <String?>['Bob', 'Carol']);

        // case-insensitive contains
        final insensitiveContains = await client.user.findMany(
          where: const UserWhereInput(
            nameFilter: StringFilter(
              contains: 'ali',
              mode: QueryStringMode.insensitive,
            ),
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true),
        );
        expect(insensitiveContains.map((u) => u.name).toList(), <String?>[
          'Alice',
          'Alicia',
        ]);

        // case-insensitive startsWith
        final insensitiveStarts = await client.user.count(
          where: const UserWhereInput(
            nameFilter: StringFilter(
              startsWith: 'ALI',
              mode: QueryStringMode.insensitive,
            ),
          ),
        );
        expect(insensitiveStarts, 2);

        // case-insensitive endsWith
        final insensitiveEnds = await client.user.findMany(
          where: const UserWhereInput(
            nameFilter: StringFilter(
              endsWith: 'OL',
              mode: QueryStringMode.insensitive,
            ),
          ),
          select: const UserSelect(name: true),
        );
        expect(insensitiveEnds.map((u) => u.name).toList(), <String?>['Carol']);
      },
    );

    test('supports generated orderBy for findMany and findFirst', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(name: 'Charlie', email: 'c@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'a@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'b@prisma.io'),
      );

      final sortedUsers = await client.user.findMany(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true),
      );

      expect(
        sortedUsers.map((user) => user.name).toList(growable: false),
        const <String?>['Alice', 'Bob', 'Charlie'],
      );

      final secondUser = await client.user.findFirst(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        skip: 1,
        select: const UserSelect(name: true),
      );

      expect(secondUser, isNotNull);
      expect(secondUser!.name, 'Bob');

      final firstDescending = await client.user.findFirst(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.desc),
        ],
        select: const UserSelect(name: true),
      );

      expect(firstDescending, isNotNull);
      expect(firstDescending!.name, 'Charlie');
    });

    test('supports generated cursor pagination for findMany', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'a@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'b@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Charlie', email: 'c@prisma.io'),
      );

      final pageIncludingCursor = await client.user.findMany(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        take: 2,
        select: const UserSelect(name: true),
      );

      expect(
        pageIncludingCursor.map((user) => user.name).toList(growable: false),
        const <String?>['Bob', 'Charlie'],
      );

      final pageAfterCursor = await client.user.findMany(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        skip: 1,
        take: 1,
        select: const UserSelect(name: true),
      );

      expect(
        pageAfterCursor.map((user) => user.name).toList(growable: false),
        const <String?>['Charlie'],
      );

      final backwardPageIncludingCursor = await client.user.findMany(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        take: -2,
        select: const UserSelect(name: true),
      );

      expect(
        backwardPageIncludingCursor
            .map((user) => user.name)
            .toList(growable: false),
        const <String?>['Alice', 'Bob'],
      );

      final backwardPageBeforeCursor = await client.user.findMany(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        skip: 1,
        take: -1,
        select: const UserSelect(name: true),
      );

      expect(
        backwardPageBeforeCursor
            .map((user) => user.name)
            .toList(growable: false),
        const <String?>['Alice'],
      );

      final firstFromCursor = await client.user.findFirst(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true),
      );

      expect(firstFromCursor, isNotNull);
      expect(firstFromCursor!.name, 'Bob');

      final firstAfterCursor = await client.user.findFirst(
        cursor: const UserWhereUniqueInput(email: 'b@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        skip: 1,
        select: const UserSelect(name: true),
      );

      expect(firstAfterCursor, isNotNull);
      expect(firstAfterCursor!.name, 'Charlie');

      final missingFromCursor = await client.user.findFirst(
        cursor: const UserWhereUniqueInput(email: 'missing@prisma.io'),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true),
      );

      expect(missingFromCursor, isNull);
    });

    test(
      'supports generated cursor pagination with compound primary keys',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: GeneratedComonOrmClient.createInMemoryAdapter(),
        );

        await client.membership.create(
          data: const MembershipCreateInput(
            tenantId: 1,
            slug: 'alpha',
            role: 'owner',
          ),
        );
        await client.membership.create(
          data: const MembershipCreateInput(
            tenantId: 1,
            slug: 'beta',
            role: 'editor',
          ),
        );
        await client.membership.create(
          data: const MembershipCreateInput(
            tenantId: 2,
            slug: 'gamma',
            role: 'viewer',
          ),
        );

        final memberships = await client.membership.findMany(
          cursor: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'beta',
            ),
          ),
          orderBy: const <MembershipOrderByInput>[
            MembershipOrderByInput(tenantId: SortOrder.asc),
            MembershipOrderByInput(slug: SortOrder.asc),
          ],
          take: 2,
          select: const MembershipSelect(
            tenantId: true,
            slug: true,
            role: true,
          ),
        );

        expect(memberships, hasLength(2));
        expect(memberships.first.tenantId, 1);
        expect(memberships.first.slug, 'beta');
        expect(memberships.first.role, 'editor');
        expect(memberships.last.tenantId, 2);
        expect(memberships.last.slug, 'gamma');
        expect(memberships.last.role, 'viewer');

        final backwardMemberships = await client.membership.findMany(
          cursor: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'beta',
            ),
          ),
          orderBy: const <MembershipOrderByInput>[
            MembershipOrderByInput(tenantId: SortOrder.asc),
            MembershipOrderByInput(slug: SortOrder.asc),
          ],
          take: -2,
          select: const MembershipSelect(
            tenantId: true,
            slug: true,
            role: true,
          ),
        );

        expect(backwardMemberships, hasLength(2));
        expect(backwardMemberships.first.tenantId, 1);
        expect(backwardMemberships.first.slug, 'alpha');
        expect(backwardMemberships.first.role, 'owner');
        expect(backwardMemberships.last.tenantId, 1);
        expect(backwardMemberships.last.slug, 'beta');
        expect(backwardMemberships.last.role, 'editor');

        final firstMembershipFromCursor = await client.membership.findFirst(
          cursor: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'beta',
            ),
          ),
          orderBy: const <MembershipOrderByInput>[
            MembershipOrderByInput(tenantId: SortOrder.asc),
            MembershipOrderByInput(slug: SortOrder.asc),
          ],
          select: const MembershipSelect(
            tenantId: true,
            slug: true,
            role: true,
          ),
        );

        expect(firstMembershipFromCursor, isNotNull);
        expect(firstMembershipFromCursor!.tenantId, 1);
        expect(firstMembershipFromCursor.slug, 'beta');
        expect(firstMembershipFromCursor.role, 'editor');

        final firstMembershipAfterCursor = await client.membership.findFirst(
          cursor: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'beta',
            ),
          ),
          orderBy: const <MembershipOrderByInput>[
            MembershipOrderByInput(tenantId: SortOrder.asc),
            MembershipOrderByInput(slug: SortOrder.asc),
          ],
          skip: 1,
          select: const MembershipSelect(
            tenantId: true,
            slug: true,
            role: true,
          ),
        );

        expect(firstMembershipAfterCursor, isNotNull);
        expect(firstMembershipAfterCursor!.tenantId, 2);
        expect(firstMembershipAfterCursor.slug, 'gamma');
        expect(firstMembershipAfterCursor.role, 'viewer');
      },
    );

    test('supports generated distinct, aggregate and groupBy', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(
          name: 'Alice',
          email: 'alice@prisma.io',
          country: 'US',
          profileViews: 10,
        ),
      );
      await client.user.create(
        data: const UserCreateInput(
          name: 'Bob',
          email: 'bob@prisma.io',
          country: 'US',
          profileViews: 20,
        ),
      );
      await client.user.create(
        data: const UserCreateInput(
          name: 'Claire',
          email: 'claire@prisma.io',
          country: 'FR',
          profileViews: 5,
        ),
      );
      await client.user.create(
        data: const UserCreateInput(
          name: 'Dan',
          email: 'dan@prisma.io',
          country: 'FR',
          profileViews: 15,
        ),
      );
      await client.user.create(
        data: const UserCreateInput(
          name: 'Eve',
          email: 'eve@prisma.io',
          country: 'JP',
        ),
      );

      final distinctCountries = await client.user.findMany(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(country: SortOrder.asc),
          UserOrderByInput(profileViews: SortOrder.desc),
        ],
        distinct: const <UserScalarField>[UserScalarField.country],
        select: const UserSelect(name: true, country: true, profileViews: true),
      );

      expect(
        distinctCountries.map((user) => user.country).toList(growable: false),
        const <String?>['FR', 'JP', 'US'],
      );
      expect(
        distinctCountries.map((user) => user.name).toList(growable: false),
        const <String?>['Dan', 'Eve', 'Bob'],
      );

      final firstDistinctCountry = await client.user.findFirst(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(country: SortOrder.asc),
          UserOrderByInput(profileViews: SortOrder.desc),
        ],
        distinct: const <UserScalarField>[UserScalarField.country],
        select: const UserSelect(name: true, country: true, profileViews: true),
      );

      expect(firstDistinctCountry, isNotNull);
      expect(firstDistinctCountry!.country, 'FR');
      expect(firstDistinctCountry.name, 'Dan');

      final secondDistinctCountry = await client.user.findFirst(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(country: SortOrder.asc),
          UserOrderByInput(profileViews: SortOrder.desc),
        ],
        distinct: const <UserScalarField>[UserScalarField.country],
        skip: 1,
        select: const UserSelect(name: true, country: true, profileViews: true),
      );

      expect(secondDistinctCountry, isNotNull);
      expect(secondDistinctCountry!.country, 'JP');
      expect(secondDistinctCountry.name, 'Eve');

      final aggregate = await client.user.aggregate(
        where: const UserWhereInput(
          countryFilter: StringFilter(inList: <String>['US', 'FR']),
        ),
        count: const UserCountAggregateInput(all: true, profileViews: true),
        avg: const UserAvgAggregateInput(profileViews: true),
        sum: const UserSumAggregateInput(profileViews: true),
        min: const UserMinAggregateInput(profileViews: true),
        max: const UserMaxAggregateInput(profileViews: true),
      );

      expect(aggregate.count, isNotNull);
      expect(aggregate.count!.all, 4);
      expect(aggregate.count!.profileViews, 4);
      expect(aggregate.avg!.profileViews, 12.5);
      expect(aggregate.sum!.profileViews, 50);
      expect(aggregate.min!.profileViews, 5);
      expect(aggregate.max!.profileViews, 20);

      final grouped = await client.user.groupBy(
        by: const <UserScalarField>[UserScalarField.country],
        having: const UserGroupByHavingInput(
          profileViews: NumericAggregatesFilter(avg: DoubleFilter(gte: 10)),
        ),
        orderBy: const <UserGroupByOrderByInput>[
          UserGroupByOrderByInput(
            avg: UserAvgAggregateOrderByInput(profileViews: SortOrder.desc),
          ),
        ],
        count: const UserCountAggregateInput(all: true, profileViews: true),
        avg: const UserAvgAggregateInput(profileViews: true),
        sum: const UserSumAggregateInput(profileViews: true),
      );

      expect(grouped, hasLength(2));
      expect(grouped.first.country, 'US');
      expect(grouped.first.count!.all, 2);
      expect(grouped.first.avg!.profileViews, 15);
      expect(grouped.first.sum!.profileViews, 30);
      expect(grouped.last.country, 'FR');
      expect(grouped.last.avg!.profileViews, 10);
      expect(grouped.last.sum!.profileViews, 20);
    });

    test('supports relation some filters in generated where inputs', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: UserCreateInput(
          name: 'Alice',
          email: 'alice@prisma.io',
          posts: PostCreateNestedManyWithoutUserInput(
            create: const <PostCreateWithoutUserInput>[
              PostCreateWithoutUserInput(title: 'Hello ORM', published: true),
              PostCreateWithoutUserInput(title: 'Draft Note', published: false),
            ],
          ),
        ),
      );

      await client.user.create(
        data: UserCreateInput(
          name: 'Bob',
          email: 'bob@prisma.io',
          posts: PostCreateNestedManyWithoutUserInput(
            create: const <PostCreateWithoutUserInput>[
              PostCreateWithoutUserInput(
                title: 'Another Post',
                published: false,
              ),
            ],
          ),
        ),
      );

      final publishedAuthors = await client.user.findMany(
        where: const UserWhereInput(
          postsSome: PostWhereInput(publishedFilter: BoolFilter(equals: true)),
        ),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true, email: true),
      );

      expect(publishedAuthors, hasLength(1));
      expect(publishedAuthors.single.name, 'Alice');

      final helloAuthors = await client.user.findMany(
        where: const UserWhereInput(
          postsSome: PostWhereInput(
            titleFilter: StringFilter(contains: 'Hello'),
          ),
        ),
        select: const UserSelect(name: true),
      );

      expect(helloAuthors, hasLength(1));
      expect(helloAuthors.single.name, 'Alice');
    });

    test(
      'supports relation none and every filters in generated where inputs',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: InMemoryDatabaseAdapter(),
        );

        await client.user.create(
          data: UserCreateInput(
            name: 'Alice',
            email: 'alice@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(title: 'Published', published: true),
                PostCreateWithoutUserInput(title: 'Draft', published: false),
              ],
            ),
          ),
        );

        await client.user.create(
          data: UserCreateInput(
            name: 'Bob',
            email: 'bob@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(
                  title: 'Only Draft',
                  published: false,
                ),
              ],
            ),
          ),
        );

        await client.user.create(
          data: const UserCreateInput(name: 'Carol', email: 'carol@prisma.io'),
        );

        final withoutPublishedPosts = await client.user.findMany(
          where: const UserWhereInput(
            postsNone: PostWhereInput(
              publishedFilter: BoolFilter(equals: true),
            ),
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true),
        );

        expect(
          withoutPublishedPosts
              .map((user) => user.name)
              .toList(growable: false),
          const <String?>['Bob', 'Carol'],
        );

        final everyPostIsDraft = await client.user.findMany(
          where: const UserWhereInput(
            postsEvery: PostWhereInput(
              publishedFilter: BoolFilter(equals: false),
            ),
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true),
        );

        expect(
          everyPostIsDraft.map((user) => user.name).toList(growable: false),
          const <String?>['Bob', 'Carol'],
        );
      },
    );

    test('supports singular relation is and isNot filters', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
      );

      await client.post.create(
        data: const PostCreateInput(
          title: 'Alice Post',
          published: true,
          userId: 1,
        ),
      );
      await client.post.create(
        data: const PostCreateInput(
          title: 'Bob Draft',
          published: false,
          userId: 2,
        ),
      );

      final alicePosts = await client.post.findMany(
        where: const PostWhereInput(userIs: UserWhereInput(name: 'Alice')),
        orderBy: const <PostOrderByInput>[
          PostOrderByInput(title: SortOrder.asc),
        ],
        select: const PostSelect(title: true),
      );

      expect(alicePosts, hasLength(1));
      expect(alicePosts.single.title, 'Alice Post');

      final notAlicePosts = await client.post.findMany(
        where: const PostWhereInput(userIsNot: UserWhereInput(name: 'Alice')),
        select: const PostSelect(title: true),
      );

      expect(notAlicePosts, hasLength(1));
      expect(notAlicePosts.single.title, 'Bob Draft');
    });

    test('supports self relation nested create include and filters', () async {
      final schema = const SchemaParser().parse('''
model User {
  id        Int    @id @default(autoincrement())
  name      String
  managerId Int?
  manager   User?  @relation("ManagerChain", fields: [managerId], references: [id])
  reports   User[] @relation("ManagerChain")
}
''');
      final client = ComonOrmClient(
        adapter: InMemoryDatabaseAdapter(schema: schema),
      );

      final createdManager = await client
          .model('User')
          .create(
            const CreateQuery(
              model: 'User',
              data: <String, Object?>{'name': 'Alice'},
              include: QueryInclude(<String, QueryIncludeEntry>{
                'reports': QueryIncludeEntry(
                  relation: QueryRelation(
                    field: 'reports',
                    targetModel: 'User',
                    cardinality: QueryRelationCardinality.many,
                    localKeyField: 'id',
                    targetKeyField: 'managerId',
                  ),
                ),
              }),
              nestedCreates: <CreateRelationWrite>[
                CreateRelationWrite(
                  relation: QueryRelation(
                    field: 'reports',
                    targetModel: 'User',
                    cardinality: QueryRelationCardinality.many,
                    localKeyField: 'id',
                    targetKeyField: 'managerId',
                  ),
                  records: <Map<String, Object?>>[
                    <String, Object?>{'name': 'Bob'},
                  ],
                ),
              ],
            ),
          );

      expect(createdManager['id'], 1);
      expect(createdManager['reports'], hasLength(1));
      expect(
        (createdManager['reports']! as List<Object?>).single,
        isA<Map<String, Object?>>(),
      );
      expect(
        ((createdManager['reports']! as List<Object?>).single
            as Map<String, Object?>)['managerId'],
        1,
      );

      final managersWithBob = await client
          .model('User')
          .findMany(
            const FindManyQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'reports',
                  operator: 'relationSome',
                  value: QueryRelationFilter(
                    relation: QueryRelation(
                      field: 'reports',
                      targetModel: 'User',
                      cardinality: QueryRelationCardinality.many,
                      localKeyField: 'id',
                      targetKeyField: 'managerId',
                    ),
                    predicates: <QueryPredicate>[
                      QueryPredicate(
                        field: 'name',
                        operator: 'equals',
                        value: 'Bob',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

      expect(managersWithBob, hasLength(1));
      expect(managersWithBob.single['name'], 'Alice');

      final childWithManager = await client
          .model('User')
          .findFirst(
            const FindFirstQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(field: 'name', operator: 'equals', value: 'Bob'),
                QueryPredicate(
                  field: 'manager',
                  operator: 'relationIs',
                  value: QueryRelationFilter(
                    relation: QueryRelation(
                      field: 'manager',
                      targetModel: 'User',
                      cardinality: QueryRelationCardinality.one,
                      localKeyField: 'managerId',
                      targetKeyField: 'id',
                    ),
                    predicates: <QueryPredicate>[
                      QueryPredicate(
                        field: 'name',
                        operator: 'equals',
                        value: 'Alice',
                      ),
                    ],
                  ),
                ),
              ],
              include: QueryInclude(<String, QueryIncludeEntry>{
                'manager': QueryIncludeEntry(
                  relation: QueryRelation(
                    field: 'manager',
                    targetModel: 'User',
                    cardinality: QueryRelationCardinality.one,
                    localKeyField: 'managerId',
                    targetKeyField: 'id',
                  ),
                ),
              }),
            ),
          );

      expect(childWithManager, isNotNull);
      expect(childWithManager!['name'], 'Bob');
      expect(
        (childWithManager['manager'] as Map<String, Object?>)['name'],
        'Alice',
      );
    });

    test(
      'supports implicit many-to-many nested create include and filters',
      () async {
        final schema = const SchemaParser().parse('''
model User {
  id   Int    @id @default(autoincrement())
  name String
  tags Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  label String
  users User[]
}
''');
        final client = ComonOrmClient(
          adapter: InMemoryDatabaseAdapter(schema: schema),
        );

        final createdUser = await client
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{'name': 'Alice'},
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'tags': QueryIncludeEntry(
                    relation: QueryRelation(
                      field: 'tags',
                      targetModel: 'Tag',
                      cardinality: QueryRelationCardinality.many,
                      localKeyField: 'id',
                      targetKeyField: 'id',
                      storageKind: QueryRelationStorageKind.implicitManyToMany,
                      sourceModel: 'User',
                      inverseField: 'users',
                    ),
                  ),
                }),
                nestedCreates: <CreateRelationWrite>[
                  CreateRelationWrite(
                    relation: QueryRelation(
                      field: 'tags',
                      targetModel: 'Tag',
                      cardinality: QueryRelationCardinality.many,
                      localKeyField: 'id',
                      targetKeyField: 'id',
                      storageKind: QueryRelationStorageKind.implicitManyToMany,
                      sourceModel: 'User',
                      inverseField: 'users',
                    ),
                    records: <Map<String, Object?>>[
                      <String, Object?>{'label': 'orm'},
                      <String, Object?>{'label': 'dart'},
                    ],
                  ),
                ],
              ),
            );

        expect(createdUser['tags'], hasLength(2));
        expect(
          (createdUser['tags']! as List<Object?>)
              .map((tag) => (tag as Map<String, Object?>)['label'])
              .toList(growable: false),
          <Object?>['orm', 'dart'],
        );

        final usersWithOrm = await client
            .model('User')
            .findMany(
              const FindManyQuery(
                model: 'User',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'tags',
                    operator: 'relationSome',
                    value: QueryRelationFilter(
                      relation: QueryRelation(
                        field: 'tags',
                        targetModel: 'Tag',
                        cardinality: QueryRelationCardinality.many,
                        localKeyField: 'id',
                        targetKeyField: 'id',
                        storageKind:
                            QueryRelationStorageKind.implicitManyToMany,
                        sourceModel: 'User',
                        inverseField: 'users',
                      ),
                      predicates: <QueryPredicate>[
                        QueryPredicate(
                          field: 'label',
                          operator: 'equals',
                          value: 'orm',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

        expect(usersWithOrm, hasLength(1));
        expect(usersWithOrm.single['name'], 'Alice');

        final ormTag = await client
            .model('Tag')
            .findFirst(
              const FindFirstQuery(
                model: 'Tag',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'label',
                    operator: 'equals',
                    value: 'orm',
                  ),
                ],
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'users': QueryIncludeEntry(
                    relation: QueryRelation(
                      field: 'users',
                      targetModel: 'User',
                      cardinality: QueryRelationCardinality.many,
                      localKeyField: 'id',
                      targetKeyField: 'id',
                      storageKind: QueryRelationStorageKind.implicitManyToMany,
                      sourceModel: 'Tag',
                      inverseField: 'tags',
                    ),
                  ),
                }),
              ),
            );

        expect(ormTag, isNotNull);
        expect((ormTag!['users'] as List<Object?>), hasLength(1));
        expect(
          ((ormTag['users'] as List<Object?>).single
              as Map<String, Object?>)['name'],
          'Alice',
        );
      },
    );

    test(
      'supports implicit many-to-many with compound ids in in-memory runtime',
      () async {
        final schema = const SchemaParser().parse('''
model User {
  tenantId Int
  slug     String
  name     String
  tags     Tag[]

  @@id([tenantId, slug])
}

model Tag {
  scope String
  code  String
  label String
  users User[]

  @@id([scope, code])
}
''');
        final client = ComonOrmClient(
          adapter: InMemoryDatabaseAdapter(schema: schema),
        );
        const userTagsRelation = QueryRelation(
          field: 'tags',
          targetModel: 'Tag',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'tenantId',
          targetKeyField: 'scope',
          localKeyFields: <String>['tenantId', 'slug'],
          targetKeyFields: <String>['scope', 'code'],
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'User',
          inverseField: 'users',
        );
        const tagUsersRelation = QueryRelation(
          field: 'users',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'scope',
          targetKeyField: 'tenantId',
          localKeyFields: <String>['scope', 'code'],
          targetKeyFields: <String>['tenantId', 'slug'],
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'Tag',
          inverseField: 'tags',
        );

        final createdUser = await client
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{
                  'tenantId': 7,
                  'slug': 'alice',
                  'name': 'Alice',
                },
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'tags': QueryIncludeEntry(relation: userTagsRelation),
                }),
                nestedCreates: <CreateRelationWrite>[
                  CreateRelationWrite(
                    relation: userTagsRelation,
                    records: <Map<String, Object?>>[
                      <String, Object?>{
                        'scope': 'global',
                        'code': 'orm',
                        'label': 'ORM',
                      },
                      <String, Object?>{
                        'scope': 'global',
                        'code': 'dart',
                        'label': 'Dart',
                      },
                    ],
                  ),
                ],
              ),
            );

        expect(createdUser['tags'], hasLength(2));

        final usersWithOrm = await client
            .model('User')
            .findMany(
              const FindManyQuery(
                model: 'User',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'tags',
                    operator: 'relationSome',
                    value: QueryRelationFilter(
                      relation: userTagsRelation,
                      predicates: <QueryPredicate>[
                        QueryPredicate(
                          field: 'code',
                          operator: 'equals',
                          value: 'orm',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );

        expect(usersWithOrm, hasLength(1));
        expect(usersWithOrm.single['slug'], 'alice');

        final ormTag = await client
            .model('Tag')
            .findFirst(
              const FindFirstQuery(
                model: 'Tag',
                where: <QueryPredicate>[
                  QueryPredicate(
                    field: 'code',
                    operator: 'equals',
                    value: 'orm',
                  ),
                ],
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'users': QueryIncludeEntry(relation: tagUsersRelation),
                }),
              ),
            );

        expect(ormTag, isNotNull);
        expect((ormTag!['users'] as List<Object?>), hasLength(1));
        expect(
          ((ormTag['users'] as List<Object?>).single
              as Map<String, Object?>)['tenantId'],
          7,
        );
        expect(
          ((ormTag['users'] as List<Object?>).single
              as Map<String, Object?>)['slug'],
          'alice',
        );
      },
    );

    test('supports compound unique predicates in in-memory runtime', () async {
      final schema = const SchemaParser().parse('''
model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, slug])
  @@unique([tenantId, role])
}
''');
      final client = ComonOrmClient(
        adapter: InMemoryDatabaseAdapter(schema: schema),
      );

      await client
          .model('Membership')
          .create(
            const CreateQuery(
              model: 'Membership',
              data: <String, Object?>{
                'tenantId': 1,
                'slug': 'alice',
                'role': 'admin',
              },
            ),
          );
      await client
          .model('Membership')
          .create(
            const CreateQuery(
              model: 'Membership',
              data: <String, Object?>{
                'tenantId': 1,
                'slug': 'bob',
                'role': 'member',
              },
            ),
          );

      final found = await client
          .model('Membership')
          .findUnique(
            const FindUniqueQuery(
              model: 'Membership',
              where: <QueryPredicate>[
                QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
                QueryPredicate(
                  field: 'role',
                  operator: 'equals',
                  value: 'admin',
                ),
              ],
            ),
          );

      expect(found, isNotNull);
      expect(found!['slug'], 'alice');

      final updated = await client
          .model('Membership')
          .update(
            const UpdateQuery(
              model: 'Membership',
              where: <QueryPredicate>[
                QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
                QueryPredicate(
                  field: 'slug',
                  operator: 'equals',
                  value: 'alice',
                ),
              ],
              data: <String, Object?>{'role': 'owner'},
            ),
          );

      expect(updated['role'], 'owner');

      final deleted = await client
          .model('Membership')
          .delete(
            const DeleteQuery(
              model: 'Membership',
              where: <QueryPredicate>[
                QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
                QueryPredicate(
                  field: 'role',
                  operator: 'equals',
                  value: 'member',
                ),
              ],
            ),
          );

      expect(deleted['slug'], 'bob');
    });

    test('supports logical AND OR NOT in generated where inputs', () async {
      final client = GeneratedComonOrmClient(
        adapter: InMemoryDatabaseAdapter(),
      );

      await client.user.create(
        data: UserCreateInput(
          name: 'Alice',
          email: 'alice@prisma.io',
          posts: PostCreateNestedManyWithoutUserInput(
            create: const <PostCreateWithoutUserInput>[
              PostCreateWithoutUserInput(title: 'Hello ORM', published: true),
            ],
          ),
        ),
      );
      await client.user.create(
        data: UserCreateInput(
          name: 'Bob',
          email: 'bob@prisma.io',
          posts: PostCreateNestedManyWithoutUserInput(
            create: const <PostCreateWithoutUserInput>[
              PostCreateWithoutUserInput(title: 'Draft', published: false),
            ],
          ),
        ),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Carol', email: 'carol@prisma.io'),
      );

      final complexOr = await client.user.findMany(
        where: const UserWhereInput(
          OR: <UserWhereInput>[
            UserWhereInput(name: 'Alice'),
            UserWhereInput(name: 'Carol'),
          ],
        ),
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(name: SortOrder.asc),
        ],
        select: const UserSelect(name: true),
      );

      expect(
        complexOr.map((user) => user.name).toList(growable: false),
        const <String?>['Alice', 'Carol'],
      );

      final complexAnd = await client.user.findMany(
        where: const UserWhereInput(
          AND: <UserWhereInput>[
            UserWhereInput(emailFilter: StringFilter(contains: '@prisma.io')),
            UserWhereInput(
              postsSome: PostWhereInput(
                titleFilter: StringFilter(contains: 'Hello'),
              ),
            ),
          ],
        ),
        select: const UserSelect(name: true),
      );

      expect(complexAnd, hasLength(1));
      expect(complexAnd.single.name, 'Alice');

      final complexNot = await client.user.findMany(
        where: const UserWhereInput(
          NOT: <UserWhereInput>[
            UserWhereInput(name: 'Bob'),
            UserWhereInput(name: 'Carol'),
          ],
        ),
        select: const UserSelect(name: true),
      );

      expect(complexNot, hasLength(1));
      expect(complexNot.single.name, 'Alice');
    });

    test(
      'typed compound WhereUniqueInput selects correct record through delegate',
      () async {
        final client = GeneratedComonOrmClient(
          adapter: InMemoryDatabaseAdapter(),
        );

        await client.membership.create(
          data: const MembershipCreateInput(
            tenantId: 1,
            slug: 'alice',
            role: 'member',
          ),
        );
        await client.membership.create(
          data: const MembershipCreateInput(
            tenantId: 1,
            slug: 'bob',
            role: 'admin',
          ),
        );

        final found = await client.membership.findUnique(
          where: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'alice',
            ),
          ),
        );
        expect(found, isNotNull);
        expect(found!.slug, 'alice');
        expect(found.role, 'member');

        final updated = await client.membership.update(
          where: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'alice',
            ),
          ),
          data: const MembershipUpdateInput(role: 'owner'),
        );
        expect(updated.role, 'owner');

        final deleted = await client.membership.delete(
          where: const MembershipWhereUniqueInput(
            tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
              tenantId: 1,
              slug: 'bob',
            ),
          ),
        );
        expect(deleted.slug, 'bob');

        final remaining = await client.membership.findMany();
        expect(remaining, hasLength(1));
        expect(remaining.single.slug, 'alice');
        expect(remaining.single.role, 'owner');
      },
    );
  });

  group('InMemoryDatabaseAdapter — adapter-level upsert / createMany', () {
    late InMemoryDatabaseAdapter adapter;

    setUp(() {
      adapter = InMemoryDatabaseAdapter();
    });

    test('upsert creates a record when none exists', () async {
      final result = await adapter.upsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(field: 'id', operator: 'equals', value: 1),
          ],
          create: <String, Object?>{'id': 1, 'name': 'Alice'},
          update: <String, Object?>{'name': 'Alice Updated'},
        ),
      );
      expect(result['name'], 'Alice');
      final all = await adapter.findMany(const FindManyQuery(model: 'User'));
      expect(all, hasLength(1));
    });

    test('upsert updates a record when one exists', () async {
      await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{'id': 1, 'name': 'Alice'},
        ),
      );
      final result = await adapter.upsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(field: 'id', operator: 'equals', value: 1),
          ],
          create: <String, Object?>{'id': 1, 'name': 'Should Not Create'},
          update: <String, Object?>{'name': 'Alice Updated'},
        ),
      );
      expect(result['name'], 'Alice Updated');
      final all = await adapter.findMany(const FindManyQuery(model: 'User'));
      expect(all, hasLength(1));
    });

    test('createMany inserts multiple records', () async {
      final count = await adapter.createMany(
        const CreateManyQuery(
          model: 'User',
          data: <Map<String, Object?>>[
            <String, Object?>{'id': 1, 'name': 'Alice'},
            <String, Object?>{'id': 2, 'name': 'Bob'},
          ],
        ),
      );
      expect(count, 2);
      final all = await adapter.findMany(const FindManyQuery(model: 'User'));
      expect(all, hasLength(2));
    });

    test('createMany returns 0 for empty data list', () async {
      final count = await adapter.createMany(
        const CreateManyQuery(model: 'User', data: <Map<String, Object?>>[]),
      );
      expect(count, 0);
    });

    test('findMany and findFirst honor low-level cursor queries', () async {
      await adapter.createMany(
        const CreateManyQuery(
          model: 'User',
          data: <Map<String, Object?>>[
            <String, Object?>{'id': 1, 'name': 'Alice', 'email': 'a@prisma.io'},
            <String, Object?>{'id': 2, 'name': 'Bob', 'email': 'b@prisma.io'},
            <String, Object?>{
              'id': 3,
              'name': 'Charlie',
              'email': 'c@prisma.io',
            },
          ],
        ),
      );

      final page = await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          cursor: QueryCursor(
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'equals',
                value: 'b@prisma.io',
              ),
            ],
          ),
          orderBy: <QueryOrderBy>[
            QueryOrderBy(field: 'name', direction: SortOrder.asc),
          ],
          skip: 1,
          take: 1,
        ),
      );

      expect(page, hasLength(1));
      expect(page.single['name'], 'Charlie');

      final first = await adapter.findFirst(
        const FindFirstQuery(
          model: 'User',
          cursor: QueryCursor(
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'equals',
                value: 'b@prisma.io',
              ),
            ],
          ),
          orderBy: <QueryOrderBy>[
            QueryOrderBy(field: 'name', direction: SortOrder.asc),
          ],
        ),
      );

      expect(first, isNotNull);
      expect(first!['name'], 'Bob');
    });

    test('rawQuery throws UnsupportedError', () async {
      expect(
        () => adapter.rawQuery('SELECT 1'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('rawExecute throws UnsupportedError', () async {
      expect(
        () => adapter.rawExecute('UPDATE User SET id = 1'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
