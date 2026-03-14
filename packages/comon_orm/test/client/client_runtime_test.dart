import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

import '../generated/comon_orm_client.dart';

void main() {
  group('ComonOrmClient', () {
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
}
