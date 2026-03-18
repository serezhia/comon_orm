import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

import '../../../comon_orm/test/generated/comon_orm_client.dart';

const String _schemaSource = '''
model User {
  id           Int    @id @default(autoincrement())
  name         String
  email        String @unique
  country      String?
  profileViews Int?
  posts        Post[]
}

model Post {
  id        Int     @id @default(autoincrement())
  title     String
  content   String?
  published Boolean @default(false)
  userId    Int
  user      User    @relation(fields: [userId], references: [id])
}
''';

void main() {
  group('SqliteDatabaseAdapter', () {
    late sqlite.Database database;
    late SqliteDatabaseAdapter adapter;
    late GeneratedComonOrmClient client;
    late SchemaDocument schema;

    setUp(() {
      schema = const SchemaParser().parse(_schemaSource);
      database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, schema);

      adapter = SqliteDatabaseAdapter(database: database, schema: schema);
      client = GeneratedComonOrmClient(adapter: adapter);
    });

    tearDown(() {
      adapter.close();
    });

    test(
      'supports nested create include filtering ordering and updates',
      () async {
        final alice = await client.user.create(
          data: UserCreateInput(
            name: 'Alice',
            email: 'alice@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(title: 'Hello ORM', published: true),
                PostCreateWithoutUserInput(
                  title: 'Draft Note',
                  published: false,
                ),
              ],
            ),
          ),
          include: const UserInclude(posts: true),
        );

        await client.user.create(
          data: UserCreateInput(
            name: 'Bob',
            email: 'bob@prisma.io',
            posts: PostCreateNestedManyWithoutUserInput(
              create: const <PostCreateWithoutUserInput>[
                PostCreateWithoutUserInput(
                  title: 'Second Draft',
                  published: false,
                ),
              ],
            ),
          ),
        );

        expect(alice.id, 1);
        expect(alice.posts, hasLength(2));
        expect(alice.posts!.first.published, isTrue);

        final filteredUsers = await client.user.findMany(
          where: const UserWhereInput(
            OR: <UserWhereInput>[
              UserWhereInput(
                postsSome: PostWhereInput(
                  publishedFilter: BoolFilter(equals: true),
                ),
              ),
              UserWhereInput(name: 'Carol'),
            ],
          ),
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          select: const UserSelect(name: true, email: true),
        );

        expect(filteredUsers, hasLength(1));
        expect(filteredUsers.single.name, 'Alice');
        expect(filteredUsers.single.email, 'alice@prisma.io');

        final alicePosts = await client.post.findMany(
          where: const PostWhereInput(
            userIs: UserWhereInput(
              AND: <UserWhereInput>[
                UserWhereInput(name: 'Alice'),
                UserWhereInput(
                  emailFilter: StringFilter(contains: '@prisma.io'),
                ),
              ],
            ),
          ),
          orderBy: const <PostOrderByInput>[
            PostOrderByInput(title: SortOrder.asc),
          ],
          include: const PostInclude(user: true),
        );

        expect(alicePosts, hasLength(2));
        expect(alicePosts.first.user!.name, 'Alice');
        expect(alicePosts.last.title, 'Hello ORM');

        final updated = await client.user.update(
          where: const UserWhereUniqueInput(email: 'bob@prisma.io'),
          data: const UserUpdateInput(name: 'Robert'),
          select: const UserSelect(name: true, email: true),
        );

        expect(updated.name, 'Robert');

        final deleted = await client.post.delete(
          where: PostWhereUniqueInput(id: alice.posts!.last.id!),
          include: const PostInclude(user: true),
        );

        expect(deleted.user!.name, 'Alice');

        final remainingCount = await client.post.count();
        expect(remainingCount, 2);
      },
    );

    test('rolls back transaction on failure', () async {
      await expectLater(
        client.transaction((tx) async {
          await tx.user.create(
            data: const UserCreateInput(
              name: 'Alice',
              email: 'alice@prisma.io',
            ),
          );
          throw StateError('boom');
        }),
        throwsStateError,
      );

      final userCount = await client.user.count();
      expect(userCount, 0);
    });

    test('supports distinct, aggregate and groupBy queries', () async {
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

      final distinctCountries = await client.user.findMany(
        orderBy: const <UserOrderByInput>[
          UserOrderByInput(country: SortOrder.asc),
          UserOrderByInput(profileViews: SortOrder.desc),
        ],
        distinct: const <UserScalarField>[UserScalarField.country],
        select: const UserSelect(name: true, country: true),
      );

      expect(
        distinctCountries.map((user) => user.name).toList(growable: false),
        const <String?>['Dan', 'Bob'],
      );

      final aggregate = await client.user.aggregate(
        count: const UserCountAggregateInput(all: true, profileViews: true),
        avg: const UserAvgAggregateInput(profileViews: true),
        sum: const UserSumAggregateInput(profileViews: true),
      );

      expect(aggregate.count!.all, 4);
      expect(aggregate.count!.profileViews, 4);
      expect(aggregate.avg!.profileViews, 12.5);
      expect(aggregate.sum!.profileViews, 50);

      final grouped = await client.user.groupBy(
        by: const <UserScalarField>[UserScalarField.country],
        orderBy: const <UserGroupByOrderByInput>[
          UserGroupByOrderByInput(
            avg: UserAvgAggregateOrderByInput(profileViews: SortOrder.desc),
          ),
        ],
        count: const UserCountAggregateInput(all: true),
        avg: const UserAvgAggregateInput(profileViews: true),
      );

      expect(grouped, hasLength(2));
      expect(grouped.first.country, 'US');
      expect(grouped.first.count!.all, 2);
      expect(grouped.first.avg!.profileViews, 15);
      expect(grouped.last.country, 'FR');
      expect(grouped.last.avg!.profileViews, 10);
    });

    test(
      'supports distinct cursor pagination without in-memory fallback',
      () async {
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

        final nextDistinct = await client.user.findMany(
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(country: SortOrder.asc),
            UserOrderByInput(profileViews: SortOrder.desc),
          ],
          distinct: const <UserScalarField>[UserScalarField.country],
          cursor: const UserWhereUniqueInput(email: 'dan@prisma.io'),
          skip: 1,
          take: 1,
          select: const UserSelect(name: true, country: true),
        );

        expect(nextDistinct, hasLength(1));
        expect(nextDistinct.single.name, 'Bob');
        expect(nextDistinct.single.country, 'US');

        final missingCursorRow = await client.user.findMany(
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(country: SortOrder.asc),
            UserOrderByInput(profileViews: SortOrder.desc),
          ],
          distinct: const <UserScalarField>[UserScalarField.country],
          cursor: const UserWhereUniqueInput(email: 'claire@prisma.io'),
          skip: 1,
          take: 1,
          select: const UserSelect(name: true, country: true),
        );

        expect(missingCursorRow, isEmpty);
      },
    );

    test('supports notIn and case-insensitive string filters', () async {
      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Alicia', email: 'alicia@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Bob', email: 'bob@prisma.io'),
      );
      await client.user.create(
        data: const UserCreateInput(name: 'Carol', email: 'carol@prisma.io'),
      );

      // notIn excludes the listed values
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

      // empty notIn matches everything
      final notInEmpty = await client.user.count(
        where: const UserWhereInput(
          emailFilter: StringFilter(notInList: <String>[]),
        ),
      );
      expect(notInEmpty, 4);

      // case-insensitive contains via mode
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

      // IntFilter notIn
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
    });

    test('materializes nested singular include chain', () async {
      final nestedSchema = const SchemaParser().parse('''
model User {
  id        Int    @id
  name      String
  email     String @unique
  managerId Int?
  manager   User?  @relation("Management", fields: [managerId], references: [id])
  reports   User[] @relation("Management")
  posts     Post[]
}

model Post {
  id     Int  @id
  title  String
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
''');
      final nestedDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(nestedDatabase, nestedSchema);
      final nestedAdapter = SqliteDatabaseAdapter(
        database: nestedDatabase,
        schema: nestedSchema,
      );

      nestedDatabase.execute(
        "INSERT INTO \"User\" (\"id\", \"name\", \"email\", \"managerId\") VALUES "
        "(3, 'Carol', 'carol@x.dev', NULL), "
        "(1, 'Bob', 'bob@x.dev', 3), "
        "(2, 'Alice', 'alice@x.dev', 1)",
      );
      nestedDatabase.execute(
        "INSERT INTO \"Post\" (\"id\", \"title\", \"userId\") VALUES (10, 'Hello', 2)",
      );

      final rows = await nestedAdapter.findMany(
        FindManyQuery(
          model: 'Post',
          include: QueryInclude(<String, QueryIncludeEntry>{
            'user': QueryIncludeEntry(
              relation: const QueryRelation(
                field: 'user',
                targetModel: 'User',
                cardinality: QueryRelationCardinality.one,
                localKeyField: 'userId',
                targetKeyField: 'id',
              ),
              include: QueryInclude(<String, QueryIncludeEntry>{
                'manager': QueryIncludeEntry(
                  relation: const QueryRelation(
                    field: 'manager',
                    targetModel: 'User',
                    cardinality: QueryRelationCardinality.one,
                    localKeyField: 'managerId',
                    targetKeyField: 'id',
                  ),
                  include: QueryInclude(<String, QueryIncludeEntry>{
                    'manager': QueryIncludeEntry(
                      relation: const QueryRelation(
                        field: 'manager',
                        targetModel: 'User',
                        cardinality: QueryRelationCardinality.one,
                        localKeyField: 'managerId',
                        targetKeyField: 'id',
                      ),
                    ),
                  }),
                ),
              }),
            ),
          }),
        ),
      );

      expect(rows, hasLength(1));
      expect(rows.single['user'], <String, Object?>{
        'id': 2,
        'name': 'Alice',
        'email': 'alice@x.dev',
        'managerId': 1,
        'manager': <String, Object?>{
          'id': 1,
          'name': 'Bob',
          'email': 'bob@x.dev',
          'managerId': 3,
          'manager': <String, Object?>{
            'id': 3,
            'name': 'Carol',
            'email': 'carol@x.dev',
            'managerId': null,
          },
        },
      });

      nestedAdapter.close();
    });

    test('batches implicit many-to-many include across multiple parents', () async {
      final relationSchema = const SchemaParser().parse('''
model User {
  id   Int   @id
  name String
  tags Tag[]
}

model Tag {
  id    Int    @id
  label String
  users User[]
}
''');
      final relationDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(relationDatabase, relationSchema);
      final relationAdapter = SqliteDatabaseAdapter(
        database: relationDatabase,
        schema: relationSchema,
      );
      final relationClient = ComonOrmClient(adapter: relationAdapter);
      final storage = collectImplicitManyToManyStorages(relationSchema).single;
      const userTagsRelation = QueryRelation(
        field: 'tags',
        targetModel: 'Tag',
        cardinality: QueryRelationCardinality.many,
        localKeyField: 'id',
        targetKeyField: 'id',
        storageKind: QueryRelationStorageKind.implicitManyToMany,
        sourceModel: 'User',
        inverseField: 'users',
      );

      relationDatabase.execute(
        "INSERT INTO \"User\" (\"id\", \"name\") VALUES (1, 'Alice'), (2, 'Bob')",
      );
      relationDatabase.execute(
        "INSERT INTO \"Tag\" (\"id\", \"label\") VALUES (10, 'urgent'), (11, 'backend')",
      );
      relationDatabase.execute(
        'INSERT INTO "${storage.tableName}" ("${storage.sourceJoinColumns.first}", "${storage.targetJoinColumns.first}") '
        'VALUES (1, 10), (1, 11), (2, 11)',
      );

      final rows = await relationClient
          .model('User')
          .findMany(
            const FindManyQuery(
              model: 'User',
              include: QueryInclude(<String, QueryIncludeEntry>{
                'tags': QueryIncludeEntry(relation: userTagsRelation),
              }),
              orderBy: <QueryOrderBy>[
                QueryOrderBy(field: 'name', direction: SortOrder.asc),
              ],
            ),
          );

      expect(rows, hasLength(2));
      expect(rows.first['tags'], <Map<String, Object?>>[
        <String, Object?>{'id': 10, 'label': 'urgent'},
        <String, Object?>{'id': 11, 'label': 'backend'},
      ]);
      expect(rows.last['tags'], <Map<String, Object?>>[
        <String, Object?>{'id': 11, 'label': 'backend'},
      ]);

      relationAdapter.close();
    });

    test('reads and writes all supported scalar types', () async {
      final scalarSchema = const SchemaParser().parse('''
model ScalarSample {
  id        Int      @id
  createdAt DateTime
  rating    Float
  amount    Decimal
  payload   Json
  blob      Bytes
  big       BigInt
  enabled   Boolean
}
''');
      final scalarDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(scalarDatabase, scalarSchema);

      final scalarAdapter = SqliteDatabaseAdapter(
        database: scalarDatabase,
        schema: scalarSchema,
      );
      final scalarClient = ComonOrmClient(adapter: scalarAdapter);
      final createdAt = DateTime.utc(2026, 3, 13, 10, 30, 0);

      await scalarClient
          .model('ScalarSample')
          .create(
            CreateQuery(
              model: 'ScalarSample',
              data: <String, Object?>{
                'id': 1,
                'createdAt': createdAt,
                'rating': 4.5,
                'amount': 12.75,
                'payload': <String, Object?>{
                  'name': 'alpha',
                  'flags': <bool>[true, false],
                },
                'blob': <int>[1, 2, 3, 4],
                'big': BigInt.parse('9223372036854775808'),
                'enabled': true,
              },
            ),
          );

      final fetched = await scalarClient
          .model('ScalarSample')
          .findUnique(
            const FindUniqueQuery(
              model: 'ScalarSample',
              where: <QueryPredicate>[
                QueryPredicate(field: 'id', operator: 'equals', value: 1),
              ],
            ),
          );

      expect(fetched, isNotNull);
      expect(fetched!['createdAt'], createdAt);
      expect(fetched['rating'], 4.5);
      expect(fetched['amount'], 12.75);
      expect(fetched['payload'], <String, Object?>{
        'name': 'alpha',
        'flags': <Object?>[true, false],
      });
      expect(fetched['blob'], <int>[1, 2, 3, 4]);
      expect(fetched['big'], BigInt.parse('9223372036854775808'));
      expect(fetched['enabled'], isTrue);

      final filtered = await scalarClient
          .model('ScalarSample')
          .findMany(
            const FindManyQuery(
              model: 'ScalarSample',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'enabled',
                  operator: 'equals',
                  value: true,
                ),
                QueryPredicate(field: 'rating', operator: 'gte', value: 4.0),
              ],
              orderBy: <QueryOrderBy>[
                QueryOrderBy(field: 'createdAt', direction: SortOrder.asc),
              ],
            ),
          );

      expect(filtered, hasLength(1));
      expect(filtered.single['id'], 1);

      scalarAdapter.close();
    });

    test('applies schema with defaults and foreign keys', () async {
      final postColumns = database.select('PRAGMA table_info("Post")');
      final publishedColumn = postColumns.firstWhere(
        (row) => row['name'] == 'published',
      );
      expect(publishedColumn['dflt_value'], '0');

      final foreignKeys = database.select('PRAGMA foreign_key_list("Post")');
      expect(foreignKeys, hasLength(1));
      expect(foreignKeys.single['table'], 'User');
      expect(foreignKeys.single['from'], 'userId');
      expect(foreignKeys.single['to'], 'id');

      await client.user.create(
        data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
      );
      final createdPost = await client.post.create(
        data: const PostCreateInput(title: 'Defaulted', userId: 1),
      );

      expect(createdPost.published, isFalse);
    });

    test('applies referential actions to sqlite foreign keys', () async {
      final actionSchema = const SchemaParser().parse('''
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id        Int     @id @default(autoincrement())
  userId    Int?
  user      User?   @relation(fields: [userId], references: [id], onDelete: SetNull, onUpdate: Cascade)
}
''');
      final actionDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(actionDatabase, actionSchema);

      final foreignKeys = actionDatabase.select(
        'PRAGMA foreign_key_list("Post")',
      );
      expect(foreignKeys, hasLength(1));
      expect(foreignKeys.single['on_delete'], 'SET NULL');
      expect(foreignKeys.single['on_update'], 'CASCADE');

      actionDatabase.close();
    });

    test('supports mapped table and column names at runtime', () async {
      final mappedSchema = const SchemaParser().parse('''
model User {
  id    Int    @id @default(autoincrement()) @map("user_id")
  name  String @map("display_name")
  email String @unique @map("email_address")

  @@map("app_users")
}
''');
      final mappedDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(mappedDatabase, mappedSchema);

      final mappedAdapter = SqliteDatabaseAdapter(
        database: mappedDatabase,
        schema: mappedSchema,
      );
      final mappedClient = ComonOrmClient(adapter: mappedAdapter);

      await mappedClient
          .model('User')
          .create(
            const CreateQuery(
              model: 'User',
              data: <String, Object?>{
                'name': 'Alice',
                'email': 'alice@example.com',
              },
            ),
          );

      final rawRows = mappedDatabase.select(
        'SELECT user_id, display_name, email_address FROM app_users',
      );
      expect(rawRows, hasLength(1));
      expect(rawRows.single['display_name'], 'Alice');
      expect(rawRows.single['email_address'], 'alice@example.com');

      final fetched = await mappedClient
          .model('User')
          .findUnique(
            const FindUniqueQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'email',
                  operator: 'equals',
                  value: 'alice@example.com',
                ),
              ],
            ),
          );

      expect(fetched, isNotNull);
      expect(fetched!['id'], 1);
      expect(fetched['name'], 'Alice');
      expect(fetched['email'], 'alice@example.com');

      final updatedCount = await mappedClient
          .model('User')
          .updateMany(
            const UpdateManyQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'name',
                  operator: 'equals',
                  value: 'Alice',
                ),
              ],
              data: <String, Object?>{'name': 'Alicia'},
            ),
          );

      expect(updatedCount, 1);
      expect(
        mappedDatabase
            .select('SELECT display_name FROM app_users')
            .single['display_name'],
        'Alicia',
      );

      mappedAdapter.close();
    });

    test('auto-populates and refreshes updatedAt fields', () async {
      final timestampSchema = const SchemaParser().parse('''
model User {
  id        Int      @id
  name      String
  updatedAt DateTime @updatedAt
}
''');
      final timestampDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(timestampDatabase, timestampSchema);
      final timestampAdapter = SqliteDatabaseAdapter(
        database: timestampDatabase,
        schema: timestampSchema,
      );
      final timestampClient = ComonOrmClient(adapter: timestampAdapter);

      final createdAt = DateTime.utc(2026, 3, 14, 9, 0, 0);
      final updatedAt = DateTime.utc(2026, 3, 14, 9, 5, 0);
      timestampAdapter.now = () => createdAt;

      final created = await timestampClient
          .model('User')
          .create(
            const CreateQuery(
              model: 'User',
              data: <String, Object?>{'id': 1, 'name': 'Alice'},
            ),
          );

      expect(created['updatedAt'], createdAt);

      timestampAdapter.now = () => updatedAt;
      final updated = await timestampClient
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

      expect(updated['updatedAt'], updatedAt);

      timestampAdapter.close();
    });

    test(
      'supports implicit many-to-many nested create include and filters',
      () async {
        final relationSchema = const SchemaParser().parse('''
model User {
  id   Int   @id @default(autoincrement())
  name String
  tags Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  label String
  users User[]
}
''');
        final relationDatabase = sqlite.sqlite3.openInMemory();
        const SqliteSchemaApplier().apply(relationDatabase, relationSchema);

        final relationAdapter = SqliteDatabaseAdapter(
          database: relationDatabase,
          schema: relationSchema,
        );
        final relationClient = ComonOrmClient(adapter: relationAdapter);
        const userTagsRelation = QueryRelation(
          field: 'tags',
          targetModel: 'Tag',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'id',
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'User',
          inverseField: 'users',
        );
        const tagUsersRelation = QueryRelation(
          field: 'users',
          targetModel: 'User',
          cardinality: QueryRelationCardinality.many,
          localKeyField: 'id',
          targetKeyField: 'id',
          storageKind: QueryRelationStorageKind.implicitManyToMany,
          sourceModel: 'Tag',
          inverseField: 'tags',
        );

        final created = await relationClient
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{'name': 'Alice'},
                nestedCreates: <CreateRelationWrite>[
                  CreateRelationWrite(
                    relation: userTagsRelation,
                    records: <Map<String, Object?>>[
                      <String, Object?>{'label': 'urgent'},
                      <String, Object?>{'label': 'backend'},
                    ],
                  ),
                ],
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'tags': QueryIncludeEntry(relation: userTagsRelation),
                }),
              ),
            );

        expect((created['tags'] as List<Object?>), hasLength(2));

        final filteredUsers = await relationClient
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
                          field: 'label',
                          operator: 'equals',
                          value: 'urgent',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        expect(filteredUsers, hasLength(1));

        final tags = await relationClient
            .model('Tag')
            .findMany(
              const FindManyQuery(
                model: 'Tag',
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'users': QueryIncludeEntry(relation: tagUsersRelation),
                }),
                orderBy: <QueryOrderBy>[
                  QueryOrderBy(field: 'label', direction: SortOrder.asc),
                ],
              ),
            );
        expect(tags, hasLength(2));
        expect(tags.first['users'], hasLength(1));

        final storage = collectImplicitManyToManyStorages(
          relationSchema,
        ).single;
        final joinRows = relationDatabase.select(
          'SELECT * FROM "${storage.tableName}"',
        );
        expect(joinRows, hasLength(2));

        relationAdapter.close();
      },
    );

    test(
      'supports implicit many-to-many nested create include and filters with compound ids',
      () async {
        final relationSchema = const SchemaParser().parse('''
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
        final relationDatabase = sqlite.sqlite3.openInMemory();
        const SqliteSchemaApplier().apply(relationDatabase, relationSchema);

        final relationAdapter = SqliteDatabaseAdapter(
          database: relationDatabase,
          schema: relationSchema,
        );
        final relationClient = ComonOrmClient(adapter: relationAdapter);
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

        final created = await relationClient
            .model('User')
            .create(
              const CreateQuery(
                model: 'User',
                data: <String, Object?>{
                  'tenantId': 7,
                  'slug': 'alice',
                  'name': 'Alice',
                },
                nestedCreates: <CreateRelationWrite>[
                  CreateRelationWrite(
                    relation: userTagsRelation,
                    records: <Map<String, Object?>>[
                      <String, Object?>{
                        'scope': 'global',
                        'code': 'urgent',
                        'label': 'Urgent',
                      },
                      <String, Object?>{
                        'scope': 'global',
                        'code': 'backend',
                        'label': 'Backend',
                      },
                    ],
                  ),
                ],
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'tags': QueryIncludeEntry(relation: userTagsRelation),
                }),
              ),
            );

        expect((created['tags'] as List<Object?>), hasLength(2));

        final filteredUsers = await relationClient
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
                          value: 'urgent',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
        expect(filteredUsers, hasLength(1));

        final tags = await relationClient
            .model('Tag')
            .findMany(
              const FindManyQuery(
                model: 'Tag',
                include: QueryInclude(<String, QueryIncludeEntry>{
                  'users': QueryIncludeEntry(relation: tagUsersRelation),
                }),
                orderBy: <QueryOrderBy>[
                  QueryOrderBy(field: 'code', direction: SortOrder.asc),
                ],
              ),
            );
        expect(tags, hasLength(2));
        expect(tags.first['users'], hasLength(1));
        expect(
          ((tags.first['users'] as List<Object?>).single
              as Map<String, Object?>)['slug'],
          'alice',
        );

        relationAdapter.close();
      },
    );

    test('updates and deletes rows selected by compound predicates', () async {
      final compoundSchema = const SchemaParser().parse('''
model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, slug])
}
''');
      final compoundDatabase = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(compoundDatabase, compoundSchema);

      final compoundAdapter = SqliteDatabaseAdapter(
        database: compoundDatabase,
        schema: compoundSchema,
      );

      await compoundAdapter.create(
        const CreateQuery(
          model: 'Membership',
          data: <String, Object?>{
            'tenantId': 1,
            'slug': 'alice',
            'role': 'member',
          },
        ),
      );
      await compoundAdapter.create(
        const CreateQuery(
          model: 'Membership',
          data: <String, Object?>{
            'tenantId': 1,
            'slug': 'bob',
            'role': 'admin',
          },
        ),
      );

      final updated = await compoundAdapter.update(
        const UpdateQuery(
          model: 'Membership',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
            QueryPredicate(field: 'slug', operator: 'equals', value: 'alice'),
          ],
          data: <String, Object?>{'role': 'owner'},
        ),
      );
      expect(updated['role'], 'owner');
      expect(updated['slug'], 'alice');

      final rows = compoundDatabase.select(
        'SELECT * FROM "Membership" ORDER BY slug',
      );
      expect(rows[0]['role'], 'owner');
      expect(rows[1]['role'], 'admin');

      final deleted = await compoundAdapter.delete(
        const DeleteQuery(
          model: 'Membership',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
            QueryPredicate(field: 'slug', operator: 'equals', value: 'bob'),
          ],
        ),
      );
      expect(deleted['slug'], 'bob');

      final remaining = compoundDatabase.select('SELECT * FROM "Membership"');
      expect(remaining, hasLength(1));
      expect(remaining.single['slug'], 'alice');

      compoundAdapter.close();
    });

    test('upsert creates a record when none exists', () async {
      final created = await adapter.upsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'email',
              operator: 'equals',
              value: 'new@example.com',
            ),
          ],
          create: <String, Object?>{
            'name': 'New User',
            'email': 'new@example.com',
          },
          update: <String, Object?>{'name': 'Updated User'},
        ),
      );
      expect(created['name'], 'New User');
      expect(created['email'], 'new@example.com');
    });

    test('upsert updates a record when one exists', () async {
      await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{
            'name': 'Alice',
            'email': 'alice@example.com',
          },
        ),
      );
      final updated = await adapter.upsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'email',
              operator: 'equals',
              value: 'alice@example.com',
            ),
          ],
          create: <String, Object?>{
            'name': 'Alice Created',
            'email': 'alice@example.com',
          },
          update: <String, Object?>{'name': 'Alice Updated'},
        ),
      );
      expect(updated['name'], 'Alice Updated');
      expect(updated['email'], 'alice@example.com');
    });

    test('upsert can update the conflict selector field natively', () async {
      await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{
            'name': 'Alice',
            'email': 'alice@example.com',
          },
        ),
      );

      final updated = await adapter.upsert(
        const UpsertQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'email',
              operator: 'equals',
              value: 'alice@example.com',
            ),
          ],
          create: <String, Object?>{
            'name': 'Alice Created',
            'email': 'alice@example.com',
          },
          update: <String, Object?>{
            'name': 'Alice Renamed',
            'email': 'alice+new@example.com',
          },
        ),
      );

      expect(updated['name'], 'Alice Renamed');
      expect(updated['email'], 'alice+new@example.com');

      final reloaded = await adapter.findUnique(
        const FindUniqueQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'email',
              operator: 'equals',
              value: 'alice+new@example.com',
            ),
          ],
        ),
      );
      expect(reloaded, isNotNull);
      expect(reloaded!['name'], 'Alice Renamed');
    });

    test('createMany inserts multiple records', () async {
      final count = await adapter.createMany(
        const CreateManyQuery(
          model: 'User',
          data: <Map<String, Object?>>[
            <String, Object?>{'name': 'User A', 'email': 'a@example.com'},
            <String, Object?>{'name': 'User B', 'email': 'b@example.com'},
            <String, Object?>{'name': 'User C', 'email': 'c@example.com'},
          ],
        ),
      );
      expect(count, 3);
      final all = await adapter.findMany(const FindManyQuery(model: 'User'));
      expect(all, hasLength(3));
    });

    test('createMany preserves defaults across mixed row shapes', () async {
      final user = await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{
            'name': 'Alice',
            'email': 'alice@example.com',
          },
        ),
      );

      final count = await adapter.createMany(
        CreateManyQuery(
          model: 'Post',
          data: <Map<String, Object?>>[
            <String, Object?>{'title': 'Draft', 'userId': user['id']},
            <String, Object?>{
              'title': 'Published',
              'userId': user['id'],
              'published': true,
            },
          ],
        ),
      );

      expect(count, 2);

      final posts = await adapter.findMany(
        const FindManyQuery(
          model: 'Post',
          orderBy: <QueryOrderBy>[
            QueryOrderBy(field: 'id', direction: SortOrder.asc),
          ],
        ),
      );
      expect(posts, hasLength(2));
      expect(posts[0]['published'], isFalse);
      expect(posts[1]['published'], isTrue);
    });

    test(
      'createMany skipDuplicates ignores duplicate unique conflicts',
      () async {
        final count = await adapter.createMany(
          const CreateManyQuery(
            model: 'User',
            skipDuplicates: true,
            data: <Map<String, Object?>>[
              <String, Object?>{'name': 'Alice', 'email': 'alice@example.com'},
              <String, Object?>{
                'name': 'Alice Duplicate',
                'email': 'alice@example.com',
              },
              <String, Object?>{'name': 'Bob', 'email': 'bob@example.com'},
            ],
          ),
        );

        expect(count, 2);
        final users = await adapter.findMany(
          const FindManyQuery(
            model: 'User',
            orderBy: <QueryOrderBy>[
              QueryOrderBy(field: 'email', direction: SortOrder.asc),
            ],
          ),
        );
        expect(users, hasLength(2));
        expect(users.first['name'], 'Alice');
        expect(users.last['name'], 'Bob');
      },
    );

    test('createMany returns 0 for empty list', () async {
      final count = await adapter.createMany(
        const CreateManyQuery(model: 'User', data: <Map<String, Object?>>[]),
      );
      expect(count, 0);
    });

    test('rawQuery returns rows', () async {
      await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{
            'name': 'Alice',
            'email': 'alice@example.com',
          },
        ),
      );
      final rows = await adapter.rawQuery(
        'SELECT name FROM "User" WHERE email = ?',
        ['alice@example.com'],
      );
      expect(rows, hasLength(1));
      expect(rows.first['name'], 'Alice');
    });

    test('rawExecute runs a statement and returns affected count', () async {
      await adapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{'name': 'Bob', 'email': 'bob@example.com'},
        ),
      );
      final affected = await adapter.rawExecute(
        'UPDATE "User" SET name = ? WHERE email = ?',
        ['Bobby', 'bob@example.com'],
      );
      expect(affected, 1);
      final row = await adapter.findUnique(
        const FindUniqueQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'email',
              operator: 'equals',
              value: 'bob@example.com',
            ),
          ],
        ),
      );
      expect(row!['name'], 'Bobby');
    });

    test(
      'findMany with one-to-many include returns related records for all parents',
      () async {
        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@batch.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob@batch.io'),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Post 1', userId: alice.id!),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Post 2', userId: alice.id!),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Post 3', userId: bob.id!),
        );

        final users = await client.user.findMany(
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
          include: const UserInclude(posts: true),
        );

        expect(users, hasLength(2));
        expect(users[0].posts!, hasLength(2));
        expect(
          users[0].posts!.map((p) => p.title),
          containsAll(['Post 1', 'Post 2']),
        );
        expect(users[1].posts!, hasLength(1));
        expect(users[1].posts!.single.title, 'Post 3');
      },
    );

    test(
      'findMany with many-to-one include returns correct related record per row',
      () async {
        final alice = await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice2@batch.io'),
        );
        final bob = await client.user.create(
          data: const UserCreateInput(name: 'Bob', email: 'bob2@batch.io'),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Alice Post', userId: alice.id!),
        );
        await client.post.create(
          data: PostCreateInput(title: 'Bob Post', userId: bob.id!),
        );

        final posts = await client.post.findMany(
          orderBy: const <PostOrderByInput>[
            PostOrderByInput(title: SortOrder.asc),
          ],
          include: const PostInclude(user: true),
        );

        expect(posts, hasLength(2));
        expect(posts[0].user!.name, 'Alice');
        expect(posts[1].user!.name, 'Bob');
      },
    );
  });
}
