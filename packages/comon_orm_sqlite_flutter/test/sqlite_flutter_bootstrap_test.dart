import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SqliteFlutterBootstrap', () {
    test('resolves sqlite datasource path from schema source', () {
      const bootstrap = SqliteFlutterBootstrap();
      final resolved = bootstrap.resolveFromSchemaSource(
        source: '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id
}
''',
        filePath: '/app/prisma/schema.prisma',
      );

      expect(resolved.databasePath, '/app/prisma/dev.db');
      expect(resolved.datasource.provider, 'sqlite');
      expect(resolved.schema.models.single.name, 'User');
    });

    test('opens an in-memory database with an injected ffi factory', () async {
      sqfliteFfiInit();

      const bootstrap = SqliteFlutterBootstrap();
      final opened = await bootstrap.openFromSchemaSource(
        source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id Int @id
}
''',
        databaseFactory: databaseFactoryFfi,
      );

      try {
        final rows = await opened.database.rawQuery('PRAGMA foreign_keys');
        expect(rows.single['foreign_keys'], 1);
      } finally {
        await opened.database.close();
      }
    });

    test(
      'explicit database path override wins over schema datasource url',
      () async {
        const bootstrap = SqliteFlutterBootstrap();
        final resolved = bootstrap.resolveFromSchemaSource(
          source: '''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id
}
''',
          filePath: '/app/prisma/schema.prisma',
          databasePath: '/tmp/custom.db',
        );

        expect(resolved.databasePath, '/tmp/custom.db');
      },
    );

    test(
      'opens, applies schema, and runs basic CRUD through the adapter',
      () async {
        sqfliteFfiInit();

        final adapter =
            await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
              source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id      Int     @id @default(autoincrement())
  email   String  @unique
  enabled Boolean @default(false)
}
''',
              databaseFactory: databaseFactoryFfi,
            );

        try {
          final created = await adapter.create(
            const CreateQuery(
              model: 'User',
              data: <String, Object?>{'email': 'alice@example.com'},
            ),
          );

          expect(created['id'], isA<int>());
          expect(created['enabled'], isFalse);

          expect(await adapter.count(const CountQuery(model: 'User')), 1);

          final fetched = await adapter.findUnique(
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
          expect(fetched!['enabled'], isFalse);

          final updated = await adapter.update(
            UpdateQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'id',
                  operator: 'equals',
                  value: created['id'],
                ),
              ],
              data: const <String, Object?>{'enabled': true},
            ),
          );

          expect(updated['enabled'], isTrue);

          final deleted = await adapter.delete(
            DeleteQuery(
              model: 'User',
              where: <QueryPredicate>[
                QueryPredicate(
                  field: 'id',
                  operator: 'equals',
                  value: created['id'],
                ),
              ],
            ),
          );

          expect(deleted['email'], 'alice@example.com');
          expect(await adapter.count(const CountQuery(model: 'User')), 0);
        } finally {
          await adapter.close();
        }
      },
    );

    test('supports aggregate and groupBy queries', () async {
      sqfliteFfiInit();

      final adapter =
          await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
            source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id           Int    @id @default(autoincrement())
  email        String @unique
  name         String
  country      String
  profileViews Int
}
''',
            databaseFactory: databaseFactoryFfi,
          );

      try {
        for (final user in const <Map<String, Object?>>[
          <String, Object?>{
            'email': 'alice@example.com',
            'name': 'Alice',
            'country': 'US',
            'profileViews': 10,
          },
          <String, Object?>{
            'email': 'bob@example.com',
            'name': 'Bob',
            'country': 'US',
            'profileViews': 20,
          },
          <String, Object?>{
            'email': 'claire@example.com',
            'name': 'Claire',
            'country': 'FR',
            'profileViews': 5,
          },
          <String, Object?>{
            'email': 'dan@example.com',
            'name': 'Dan',
            'country': 'FR',
            'profileViews': 15,
          },
        ]) {
          await adapter.create(CreateQuery(model: 'User', data: user));
        }

        final aggregate = await adapter.aggregate(
          const AggregateQuery(
            model: 'User',
            count: QueryCountSelection(
              all: true,
              fields: <String>{'profileViews'},
            ),
            avg: <String>{'profileViews'},
            sum: <String>{'profileViews'},
          ),
        );

        expect(aggregate.count, isNotNull);
        expect(aggregate.count!.all, 4);
        expect(aggregate.count!.fields['profileViews'], 4);
        expect(aggregate.avg!['profileViews'], 12.5);
        expect(aggregate.sum!['profileViews'], 50);

        final grouped = await adapter.groupBy(
          const GroupByQuery(
            model: 'User',
            by: <String>['country'],
            orderBy: <GroupByOrderBy>[
              GroupByOrderBy.aggregate(
                aggregate: QueryAggregateFunction.avg,
                field: 'profileViews',
                direction: SortOrder.desc,
              ),
            ],
            count: QueryCountSelection(all: true),
            avg: <String>{'profileViews'},
          ),
        );

        expect(grouped, hasLength(2));
        expect(grouped.first.group['country'], 'US');
        expect(grouped.first.aggregates.count!.all, 2);
        expect(grouped.first.aggregates.avg!['profileViews'], 15);
        expect(grouped.last.group['country'], 'FR');
        expect(grouped.last.aggregates.avg!['profileViews'], 10);
      } finally {
        await adapter.close();
      }
    });

    test(
      'supports implicit many-to-many nested create include and filters',
      () async {
        sqfliteFfiInit();

        final adapter =
            await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
              source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

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
''',
              databaseFactory: databaseFactoryFfi,
            );

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

        try {
          final created = await adapter.create(
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

          expect(created['tags'], isA<List<Object?>>());
          expect(created['tags'] as List<Object?>, hasLength(2));

          final filteredUsers = await adapter.findMany(
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
          expect(filteredUsers.single['name'], 'Alice');

          final tags = await adapter.findMany(
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
          expect(tags.first['label'], 'backend');
          expect(tags.first['users'], isA<List<Object?>>());
          expect(tags.first['users'] as List<Object?>, hasLength(1));
          expect(tags.last['label'], 'urgent');
        } finally {
          await adapter.close();
        }
      },
    );

    test('auto-populates and refreshes updatedAt fields', () async {
      sqfliteFfiInit();

      final adapter =
          await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
            source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id        Int      @id
  name      String
  updatedAt DateTime @updatedAt
}
''',
            databaseFactory: databaseFactoryFfi,
          );

      final createdAt = DateTime.utc(2026, 3, 14, 9, 0, 0);
      final updatedAt = DateTime.utc(2026, 3, 14, 9, 5, 0);

      try {
        adapter.now = () => createdAt;

        final created = await adapter.create(
          const CreateQuery(
            model: 'User',
            data: <String, Object?>{'id': 1, 'name': 'Alice'},
          ),
        );

        expect(created['updatedAt'], createdAt);

        adapter.now = () => updatedAt;

        final updated = await adapter.update(
          const UpdateQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(field: 'id', operator: 'equals', value: 1),
            ],
            data: <String, Object?>{'name': 'Alice Updated'},
          ),
        );

        expect(updated['updatedAt'], updatedAt);
      } finally {
        await adapter.close();
      }
    });

    test(
      'supports implicit many-to-many nested create include and filters with compound ids',
      () async {
        sqfliteFfiInit();

        final adapter =
            await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
              source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

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
''',
              databaseFactory: databaseFactoryFfi,
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

        try {
          final created = await adapter.create(
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

          expect(created['tags'], isA<List<Object?>>());
          expect(created['tags'] as List<Object?>, hasLength(2));

          final filteredUsers = await adapter.findMany(
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
          expect(filteredUsers.single['slug'], 'alice');

          final tags = await adapter.findMany(
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
          expect(tags.first['users'], isA<List<Object?>>());
          expect(tags.first['users'] as List<Object?>, hasLength(1));
          expect(
            ((tags.first['users'] as List<Object?>).single
                as Map<String, Object?>)['slug'],
            'alice',
          );
        } finally {
          await adapter.close();
        }
      },
    );

    test('updates and deletes rows selected by compound predicates', () async {
      sqfliteFfiInit();

      final adapter =
          await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
            source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model Membership {
  tenantId Int
  slug     String
  role     String

  @@id([tenantId, slug])
}
''',
            databaseFactory: databaseFactoryFfi,
          );

      try {
        await adapter.create(
          const CreateQuery(
            model: 'Membership',
            data: <String, Object?>{
              'tenantId': 1,
              'slug': 'alice',
              'role': 'member',
            },
          ),
        );
        await adapter.create(
          const CreateQuery(
            model: 'Membership',
            data: <String, Object?>{
              'tenantId': 1,
              'slug': 'bob',
              'role': 'admin',
            },
          ),
        );

        final updated = await adapter.update(
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

        final deleted = await adapter.delete(
          const DeleteQuery(
            model: 'Membership',
            where: <QueryPredicate>[
              QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
              QueryPredicate(field: 'slug', operator: 'equals', value: 'bob'),
            ],
          ),
        );

        expect(deleted['slug'], 'bob');

        final remaining = await adapter.findMany(
          const FindManyQuery(
            model: 'Membership',
            orderBy: <QueryOrderBy>[
              QueryOrderBy(field: 'slug', direction: SortOrder.asc),
            ],
          ),
        );

        expect(remaining, hasLength(1));
        expect(remaining.single['slug'], 'alice');
        expect(remaining.single['role'], 'owner');
      } finally {
        await adapter.close();
      }
    });

    test('supports updateMany and deleteMany flows', () async {
      sqfliteFfiInit();

      final adapter =
          await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
            source: '''
datasource db {
  provider = "sqlite"
  url = ":memory:"
}

model User {
  id      Int     @id @default(autoincrement())
  email   String  @unique
  enabled Boolean @default(false)
}
''',
            databaseFactory: databaseFactoryFfi,
          );

      try {
        for (final email in const <String>[
          'alice@example.com',
          'bob@example.com',
          'claire@example.com',
        ]) {
          await adapter.create(
            CreateQuery(model: 'User', data: <String, Object?>{'email': email}),
          );
        }

        final updatedCount = await adapter.updateMany(
          const UpdateManyQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'contains',
                value: '@example.com',
              ),
            ],
            data: <String, Object?>{'enabled': true},
          ),
        );

        expect(updatedCount, 3);

        final enabledUsers = await adapter.findMany(
          const FindManyQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(field: 'enabled', operator: 'equals', value: true),
            ],
          ),
        );

        expect(enabledUsers, hasLength(3));

        final deletedCount = await adapter.deleteMany(
          const DeleteManyQuery(
            model: 'User',
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'startsWith',
                value: 'c',
              ),
            ],
          ),
        );

        expect(deletedCount, 1);
        expect(await adapter.count(const CountQuery(model: 'User')), 2);
      } finally {
        await adapter.close();
      }
    });
  });
}
