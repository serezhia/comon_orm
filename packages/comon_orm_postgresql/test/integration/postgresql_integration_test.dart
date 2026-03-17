import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

import '../../../comon_orm/test/generated/comon_orm_client.dart';

const String _schemaSource = '''
model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  posts Post[]
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
  group('PostgresqlIntegration', () {
    late bool dockerAvailable;
    _DockerPostgresHarness? harness;

    setUpAll(() async {
      dockerAvailable = await _DockerPostgresHarness.isDockerAvailable();
      if (dockerAvailable) {
        harness = await _DockerPostgresHarness.start();
      }
    });

    tearDownAll(() async {
      await harness?.dispose();
    });

    setUp(() async {
      if (dockerAvailable) {
        await harness!.reset();
      }
    });

    test('reopens a stale idle PostgreSQL session on the next query', () async {
      if (!dockerAvailable) {
        return;
      }

      final schema = const SchemaParser().parse(_schemaSource);
      final adminConnection = await harness!.openConnection();
      try {
        await const PostgresqlSchemaApplier().apply(adminConnection, schema);
      } finally {
        await adminConnection.close();
      }

      final adapter = await PostgresqlDatabaseAdapter.openFromUrl(
        connectionUrl: harness!.connectionUrl,
        schema: schema,
      );
      final client = GeneratedComonOrmClient(adapter: adapter);

      try {
        await client.user.create(
          data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
        );

        final terminator = await harness!.openConnection();
        try {
          await terminator.execute('''
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = current_database()
  AND pid <> pg_backend_pid()
''', ignoreRows: true);
        } finally {
          await terminator.close();
        }

        final users = await client.user.findMany(
          orderBy: const <UserOrderByInput>[
            UserOrderByInput(name: SortOrder.asc),
          ],
        );

        expect(users, hasLength(1));
        expect(users.single.email, 'alice@prisma.io');
      } finally {
        await adapter.close();
      }
    });

    test(
      'runs live adapter CRUD and scalar roundtrip against PostgreSQL',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final schema = const SchemaParser().parse(_schemaSource);
        final adminConnection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(adminConnection, schema);
        } finally {
          await adminConnection.close();
        }

        final adapter = await PostgresqlDatabaseAdapter.openFromUrl(
          connectionUrl: harness!.connectionUrl,
          schema: schema,
        );
        final client = GeneratedComonOrmClient(adapter: adapter);

        try {
          final alice = await client.user.create(
            data: UserCreateInput(
              name: 'Alice',
              email: 'alice@prisma.io',
              posts: PostCreateNestedManyWithoutUserInput(
                create: const <PostCreateWithoutUserInput>[
                  PostCreateWithoutUserInput(
                    title: 'Hello ORM',
                    published: true,
                  ),
                  PostCreateWithoutUserInput(
                    title: 'Draft Note',
                    published: false,
                  ),
                ],
              ),
            ),
            include: const UserInclude(posts: true),
          );

          expect(alice.id, 1);
          expect(alice.posts, hasLength(2));

          final filteredUsers = await client.user.findMany(
            where: const UserWhereInput(
              postsSome: PostWhereInput(
                publishedFilter: BoolFilter(equals: true),
              ),
            ),
            orderBy: const <UserOrderByInput>[
              UserOrderByInput(name: SortOrder.asc),
            ],
            select: const UserSelect(name: true, email: true),
          );

          expect(filteredUsers, hasLength(1));
          expect(filteredUsers.single.name, 'Alice');

          final scalarSchema = const SchemaParser().parse('''
model ScalarSample {
  id         Int      @id
  rank       Int      @db.SmallInt
  createdAt  DateTime @default(now()) @db.Timestamp
  rating     Float    @db.DoublePrecision
  amount     Decimal  @db.Numeric
  payload    Json     @db.JsonB
  metadata   Json?    @db.Json
  blob       Bytes    @db.ByteA
  big        BigInt   @db.BigInt
  code       String   @db.Char(4)
  document   String?  @db.Xml
  enabled    Boolean  @default(false)
  externalId String? @db.Uuid
  nickname   String?  @db.VarChar(64)
}
''');
          final scalarConnection = await harness!.openConnection();
          await const PostgresqlSchemaApplier().apply(
            scalarConnection,
            scalarSchema,
          );

          final scalarAdapter = await PostgresqlDatabaseAdapter.openFromUrl(
            connectionUrl: harness!.connectionUrl,
            schema: scalarSchema,
          );
          final scalarClient = ComonOrmClient(adapter: scalarAdapter);

          try {
            final createdAt = DateTime.utc(2026, 3, 13, 10, 30, 0);
            await scalarClient
                .model('ScalarSample')
                .create(
                  CreateQuery(
                    model: 'ScalarSample',
                    data: <String, Object?>{
                      'id': 1,
                      'rank': 7,
                      'createdAt': createdAt,
                      'rating': 4.5,
                      'amount': 12.75,
                      'payload': <String, Object?>{'name': 'alpha'},
                      'metadata': <String, Object?>{'kind': 'sample'},
                      'blob': <int>[1, 2, 3],
                      'big': BigInt.parse('9223372036854775806'),
                      'code': 'ABCD',
                      'document': '<root kind="sample"/>',
                      'enabled': true,
                      'externalId': 'd290f1ee-6c54-4b01-90e6-d701748f0851',
                      'nickname': 'alpha',
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
            final fetchedRow = fetched!;
            expect(fetchedRow['rank'], 7);
            expect(fetchedRow['createdAt'], createdAt);
            expect(fetchedRow['amount'], 12.75);
            expect(fetchedRow['payload'], <String, Object?>{'name': 'alpha'});
            expect(fetchedRow['metadata'], <String, Object?>{'kind': 'sample'});
            expect(fetchedRow['blob'], <int>[1, 2, 3]);
            expect(fetchedRow['big'], BigInt.parse('9223372036854775806'));
            expect(fetchedRow['code'], 'ABCD');
            expect(fetchedRow['document'], '<root kind="sample"/>');
            expect(
              fetchedRow['externalId'],
              'd290f1ee-6c54-4b01-90e6-d701748f0851',
            );
            expect(fetchedRow['nickname'], 'alpha');

            final introspected = await const PostgresqlSchemaIntrospector()
                .introspect(scalarConnection);
            final scalarModel = introspected.findModel('ScalarSample');
            expect(scalarModel, isNotNull);
            final scalar = scalarModel!;
            expect(
              scalar.findField('rank')?.attribute('db.SmallInt'),
              isNotNull,
            );
            expect(
              scalar.findField('rating')?.attribute('db.DoublePrecision'),
              isNotNull,
            );
            expect(
              scalar.findField('payload')?.attribute('db.JsonB'),
              isNotNull,
            );
            expect(
              scalar.findField('metadata')?.attribute('db.Json'),
              isNotNull,
            );
            expect(scalar.findField('blob')?.attribute('db.ByteA'), isNotNull);
            expect(scalar.findField('big')?.attribute('db.BigInt'), isNotNull);
            expect(scalar.findField('code')?.attribute('db.Char'), isNotNull);
            expect(
              scalar
                  .findField('code')
                  ?.attribute('db.Char')
                  ?.arguments['value'],
              '4',
            );
            expect(
              scalar.findField('document')?.attribute('db.Xml'),
              isNotNull,
            );
            expect(
              scalar.findField('amount')?.attribute('db.Numeric'),
              isNotNull,
            );
          } finally {
            await scalarAdapter.close();
            await scalarConnection.close();
          }
        } finally {
          await adapter.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'runs live introspection migrations rollback and CLI',
      () async {
        if (!dockerAvailable) {
          return;
        }

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
  createdAt DateTime @default(now())
}
''');

        final connection = await harness!.openConnection();
        final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);

          final service = const PostgresqlMigrationService();
          final draft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260313_add_user_nickname',
          );

          expect(draft.plan.warnings, isEmpty);
          expect(draft.beforeSchema, contains('name String'));
          expect(draft.afterSchema, contains('nickname String?'));

          final migrationDir = service.writeDraft(
            draft: draft,
            directoryPath: tempRoot.path,
          );
          expect(
            File(
              '${migrationDir.path}${Platform.pathSeparator}before.prisma',
            ).existsSync(),
            isTrue,
          );

          final applyResult = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260313_add_user_nickname',
          );
          expect(applyResult.applied, isTrue);

          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "User" ("name", "nickname", "createdAt") VALUES (\$1, \$2, \$3)',
              parameters: <Object?>['Ada', 'first', DateTime.utc(2026, 3, 13)],
              ignoreRows: true,
            );
          });

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final userModel = introspected.findModel('User');
          expect(userModel, isNotNull);
          expect(userModel!.findField('createdAt')?.type, 'DateTime');
          expect(
            userModel.findField('createdAt')?.attribute('db.Timestamptz'),
            isNotNull,
          );
          expect(
            userModel
                .findField('createdAt')
                ?.attribute('default')
                ?.arguments['value'],
            'now()',
          );

          final rollbackResult = await service.rollbackMigration(
            executor: connection,
            migrationsDirectory: tempRoot.path,
            allowWarnings: true,
          );
          expect(rollbackResult.rolledBack, isTrue);

          final reverted = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          expect(reverted.findModel('User')?.findField('nickname'), isNull);

          final rows = await connection.run((session) async {
            final result = await session.execute('SELECT name FROM "User"');
            return result
                .map((row) => Map<String, Object?>.from(row.toColumnMap()))
                .toList(growable: false);
          });
          expect(rows.single['name'], 'Ada');

          final history = await service.runner.loadHistory(connection);
          expect(history, hasLength(2));
          expect(history.first.kind, PostgresqlMigrationRecordKind.apply);
          expect(history.last.kind, PostgresqlMigrationRecordKind.rollback);

          final outBuffer = StringBuffer();
          final errBuffer = StringBuffer();
          final cli = PostgresqlMigrationCli(out: outBuffer, err: errBuffer);
          final targetSchemaPath =
              '${tempRoot.path}${Platform.pathSeparator}target.prisma';
          File(targetSchemaPath).writeAsStringSync('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');

          outBuffer.clear();
          final diffExit = await cli.run(<String>[
            'diff',
            '--url',
            harness!.connectionUrl,
            '--schema',
            targetSchemaPath,
            '--name',
            '20260313_cli_add_user_nickname',
            '--out',
            tempRoot.path,
          ]);
          expect(diffExit, 0);
          expect(errBuffer.toString(), isEmpty);

          outBuffer.clear();
          final applyExit = await cli.run(<String>[
            'apply',
            '--url',
            harness!.connectionUrl,
            '--schema',
            targetSchemaPath,
            '--name',
            '20260313_cli_add_user_nickname',
          ]);
          expect(applyExit, 0);
          expect(outBuffer.toString(), contains('Applied: true'));

          outBuffer.clear();
          final historyExit = await cli.run(<String>[
            'history',
            '--url',
            harness!.connectionUrl,
          ]);
          expect(historyExit, 0);
          expect(
            outBuffer.toString(),
            contains('20260313_cli_add_user_nickname'),
          );

          outBuffer.clear();
          final rollbackExit = await cli.run(<String>[
            'rollback',
            '--url',
            harness!.connectionUrl,
            '--from',
            tempRoot.path,
            '--allow-warnings',
          ]);
          expect(rollbackExit, 0);
          expect(outBuffer.toString(), contains('Rolled back: true'));
        } finally {
          tempRoot.deleteSync(recursive: true);
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'reports clean status and checksum drift for live PostgreSQL migrations',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final connection = await harness!.openConnection();
        final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);

          const service = PostgresqlMigrationService();
          final draft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260314_status_drift',
          );
          final migrationDir = service.writeDraft(
            draft: draft,
            directoryPath: tempRoot.path,
          );
          await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_status_drift',
          );

          final cleanStatus = await service.status(
            executor: connection,
            migrationsDirectory: tempRoot.path,
          );
          expect(cleanStatus.isClean, isTrue);
          expect(cleanStatus.issues, isEmpty);

          File(
            '${migrationDir.path}${Platform.pathSeparator}migration.sql',
          ).writeAsStringSync('-- modified locally\n');

          final driftStatus = await service.status(
            executor: connection,
            migrationsDirectory: tempRoot.path,
          );
          expect(driftStatus.isClean, isFalse);
          expect(
            driftStatus.issues.any(
              (issue) => issue.code == 'checksum-mismatch',
            ),
            isTrue,
          );

          final outBuffer = StringBuffer();
          final errBuffer = StringBuffer();
          final cli = PostgresqlMigrationCli(out: outBuffer, err: errBuffer);
          final exitCode = await cli.run(<String>[
            'status',
            '--url',
            harness!.connectionUrl,
            '--from',
            tempRoot.path,
          ]);

          expect(exitCode, 1);
          expect(errBuffer.toString(), isEmpty);
          expect(outBuffer.toString(), contains('checksum-mismatch'));
        } finally {
          tempRoot.deleteSync(recursive: true);
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'produces empty live diff after apply for the same mapped schema',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final target = const SchemaParser().parse('''
model User {
  id          Int      @id @default(autoincrement()) @map("user_id")
  email       String   @unique @map("email_address")
  displayName String   @map("display_name")
  createdAt   DateTime @default(now()) @db.Timestamptz @map("created_at")
  posts       Post[]

  @@map("users")
}

model Post {
  id        Int      @id @default(autoincrement()) @map("post_id")
  title     String   @map("post_title")
  ownerId   Int      @map("owner_id")
  createdAt DateTime @default(now()) @db.Timestamptz @map("created_at")
  owner     User     @relation(fields: [ownerId], references: [id], onDelete: Cascade)

  @@map("posts")
}
''');

        final connection = await harness!.openConnection();
        try {
          const service = PostgresqlMigrationService();

          final initialDraft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260317_init_mapped_schema',
          );
          expect(initialDraft.plan.statements, isNotEmpty);

          final applyResult = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260317_init_mapped_schema',
          );
          expect(applyResult.applied, isTrue);
          expect(applyResult.plan.warnings, isEmpty);

          final repeatedDraft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260317_repeat_mapped_schema',
          );

          expect(
            repeatedDraft.plan.statements,
            isEmpty,
            reason: repeatedDraft.plan.statements.join(' | '),
          );
          expect(
            repeatedDraft.plan.warnings,
            isEmpty,
            reason: repeatedDraft.plan.warnings.join(' | '),
          );
          expect(repeatedDraft.plan.isEmpty, isTrue);
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'produces empty live diff after apply for the same simple schema',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  email String @unique
  name String
  createdAt DateTime @default(now())
}
''');

        final connection = await harness!.openConnection();
        try {
          const service = PostgresqlMigrationService();
          await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260317_simple_init',
          );

          final repeatedDraft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260317_simple_repeat',
          );

          expect(repeatedDraft.plan.isEmpty, isTrue);
          expect(repeatedDraft.plan.statements, isEmpty);
          expect(repeatedDraft.plan.warnings, isEmpty);
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'blocks destructive rollback without override and falls back to DB snapshots',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final connection = await harness!.openConnection();
        final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);

          const service = PostgresqlMigrationService();
          final draft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260314_snapshot_rollback',
          );
          service.writeDraft(draft: draft, directoryPath: tempRoot.path);
          await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_snapshot_rollback',
          );

          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "User" ("name", "nickname") VALUES (\$1, \$2)',
              parameters: <Object?>['Ada', 'first'],
              ignoreRows: true,
            );
          });

          await expectLater(
            () => service.rollbackMigration(
              executor: connection,
              migrationsDirectory: tempRoot.path,
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                contains('Rollback plan contains warnings'),
              ),
            ),
          );

          Directory(
            '${tempRoot.path}${Platform.pathSeparator}20260314_snapshot_rollback',
          ).deleteSync(recursive: true);

          final result = await service.rollbackMigration(
            executor: connection,
            migrationsDirectory: tempRoot.path,
            allowWarnings: true,
          );

          expect(result.rolledBack, isTrue);
          expect(result.warnings, isNotEmpty);

          final reverted = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          expect(reverted.findModel('User')?.findField('nickname'), isNull);

          final rows = await connection.run((session) async {
            final result = await session.execute(
              'SELECT "name" FROM "User" ORDER BY "id" ASC',
            );
            return result
                .map((row) => Map<String, Object?>.from(row.toColumnMap()))
                .toList(growable: false);
          });
          expect(rows.single['name'], 'Ada');
        } finally {
          tempRoot.deleteSync(recursive: true);
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );

    test(
      'introspects native PostgreSQL enums back into schema',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final schema = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus @default(pending)
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, schema);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final enumDefinition = introspected.findEnum('TodoStatus');
          final todoModel = introspected.findModel('Todo');

          expect(enumDefinition, isNotNull);
          expect(enumDefinition!.values, <String>['pending', 'done']);
          expect(todoModel, isNotNull);
          expect(todoModel!.findField('status')?.type, 'TodoStatus');
          expect(
            todoModel
                .findField('status')
                ?.attribute('default')
                ?.arguments['value'],
            'pending',
          );
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'introspects mapped PostgreSQL enums back into @@map schema metadata',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final schema = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus @default(pending)
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, schema);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final enumDefinition = introspected.findEnum('TodoStatus');
          final todoModel = introspected.findModel('Todo');

          expect(enumDefinition, isNotNull);
          expect(enumDefinition!.databaseName, 'todo_status');
          expect(
            enumDefinition.attribute('map')?.arguments['value'],
            '"todo_status"',
          );
          expect(enumDefinition.values, <String>['pending', 'done']);
          expect(todoModel, isNotNull);
          expect(todoModel!.findField('status')?.type, 'TodoStatus');
          expect(
            todoModel
                .findField('status')
                ?.attribute('default')
                ?.arguments['value'],
            'pending',
          );
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'round-trips mapped PostgreSQL enums back to the original target without extra migration statements',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus @default(pending)
}
''');

        final connection = await harness!.openConnection();
        try {
          final service = const PostgresqlMigrationService();
          final applyResult = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260318_mapped_enum_roundtrip_bootstrap',
          );

          expect(applyResult.applied, isTrue);
          expect(applyResult.plan.warnings, isEmpty);

          final introspected = filterSchemaForUserModels(
            await const PostgresqlSchemaIntrospector().introspect(connection),
            historyTableName: PostgresqlMigrationRunner.historyTableName,
          );
          final introspectedEnum = introspected.findEnumByDatabaseName(
            'task_status',
          );
          expect(introspectedEnum, isNotNull);
          expect(introspectedEnum!.name, 'TaskStatus');
          expect(
            introspectedEnum.attribute('map')?.arguments['value'],
            '"task_status"',
          );

          final planner = const PostgresqlMigrationPlanner();
          final directPlan = planner.plan(from: introspected, to: target);
          expect(directPlan.statements, isEmpty);
          expect(directPlan.warnings, isEmpty);
          expect(directPlan.requiresRebuild, isFalse);

          final draft = await service.draftFromDatabase(
            executor: connection,
            target: target,
            migrationName: '20260318_mapped_enum_roundtrip_noop',
          );
          expect(draft.plan.statements, isEmpty);
          expect(draft.plan.warnings, isEmpty);
          expect(draft.plan.requiresRebuild, isFalse);
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'introspects PostgreSQL referential actions back into relation attributes',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final schema = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  posts Post[]
}

model Post {
  id Int @id @default(autoincrement())
  userId Int?
  user User? @relation(fields: [userId], references: [id], onDelete: SetNull, onUpdate: Cascade)
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, schema);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final postModel = introspected.findModel('Post');
          final relation = postModel?.findField('user')?.attribute('relation');

          expect(relation, isNotNull);
          expect(relation!.arguments['onDelete'], 'SetNull');
          expect(relation.arguments['onUpdate'], 'Cascade');
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'applies PostgreSQL foreign key action changes without rebuild',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
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
        final target = const SchemaParser().parse('''
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

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);

          final service = const PostgresqlMigrationService();
          final result = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_update_post_user_fk',
          );

          expect(result.applied, isTrue);
          expect(result.plan.requiresRebuild, isFalse);
          expect(result.plan.warnings, isEmpty);
          expect(result.plan.statements, <String>[
            'ALTER TABLE "Post" DROP CONSTRAINT IF EXISTS "Post_userId_fkey"',
            'ALTER TABLE "Post" ADD CONSTRAINT "Post_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE',
          ]);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final relation = introspected
              .findModel('Post')
              ?.findField('user')
              ?.attribute('relation');

          expect(relation, isNotNull);
          expect(relation!.arguments['onDelete'], 'Cascade');
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'supports implicit many-to-many nested create include and filters',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final adminConnection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(
            adminConnection,
            relationSchema,
          );
        } finally {
          await adminConnection.close();
        }

        final adapter = await PostgresqlDatabaseAdapter.openFromUrl(
          connectionUrl: harness!.connectionUrl,
          schema: relationSchema,
        );
        final client = ComonOrmClient(adapter: adapter);
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
          final created = await client
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

          final filtered = await client
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
          expect(filtered, hasLength(1));

          final tags = await client
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
        } finally {
          await adapter.close();
        }
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'supports implicit many-to-many nested create include and filters with compound ids',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final adminConnection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(
            adminConnection,
            relationSchema,
          );
        } finally {
          await adminConnection.close();
        }

        final adapter = await PostgresqlDatabaseAdapter.openFromUrl(
          connectionUrl: harness!.connectionUrl,
          schema: relationSchema,
        );
        final client = ComonOrmClient(adapter: adapter);
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
          final created = await client
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

          final filtered = await client
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
          expect(filtered, hasLength(1));

          final tags = await client
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
        } finally {
          await adapter.close();
        }
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'introspects implicit many-to-many storage back into list relations',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(
            connection,
            relationSchema,
          );

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          expect(
            introspected.findModel('User')?.findField('tags')?.isList,
            isTrue,
          );
          expect(
            introspected.findModel('Tag')?.findField('users')?.isList,
            isTrue,
          );
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'introspects compound-id implicit many-to-many storage back into list relations',
      () async {
        if (!dockerAvailable) {
          return;
        }

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

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(
            connection,
            relationSchema,
          );

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          expect(
            introspected.findModel('User')?.findField('tags')?.isList,
            isTrue,
          );
          expect(
            introspected.findModel('Tag')?.findField('users')?.isList,
            isTrue,
          );
          expect(introspected.findModel('User')?.primaryKeyFields, <String>[
            'tenantId',
            'slug',
          ]);
          expect(introspected.findModel('Tag')?.primaryKeyFields, <String>[
            'scope',
            'code',
          ]);
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'rebuilds schema for destructive enum transitions when data is compatible',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');
        final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);
          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "Todo" ("title", "status") VALUES (\$1, \$2)',
              parameters: <Object?>['Keep me', 'pending'],
              ignoreRows: true,
            );
          });

          final service = const PostgresqlMigrationService();
          final result = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_enum_rebuild',
            allowWarnings: true,
          );

          expect(result.applied, isTrue);
          expect(result.plan.requiresRebuild, isTrue);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          expect(introspected.findEnum('TodoStatus')?.values, <String>[
            'pending',
          ]);

          final rows = await connection.run((session) async {
            final result = await session.execute(
              'SELECT "title", "status"::text AS "status" '
              'FROM "Todo" ORDER BY "id" ASC',
            );
            return result
                .map((row) => Map<String, Object?>.from(row.toColumnMap()))
                .toList(growable: false);
          });
          expect(rows, hasLength(1));
          expect(rows.single['title'], 'Keep me');
          expect(rows.single['status'], 'pending');
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'rebuilds mapped enum transitions and preserves @@map after introspection',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');
        final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
  @@map("task_status")
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);
          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "Todo" ("title", "status") VALUES (\$1, \$2)',
              parameters: <Object?>['Keep me', 'pending'],
              ignoreRows: true,
            );
          });

          final service = const PostgresqlMigrationService();
          final result = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_mapped_enum_rebuild',
            allowWarnings: true,
          );

          expect(result.applied, isTrue);
          expect(result.plan.requiresRebuild, isTrue);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final enumDefinition = introspected.findEnumByDatabaseName(
            'task_status',
          );
          expect(enumDefinition, isNotNull);
          final resolvedEnum = enumDefinition!;
          expect(resolvedEnum.name, 'TaskStatus');
          expect(resolvedEnum.databaseName, 'task_status');
          expect(
            resolvedEnum.attribute('map')?.arguments['value'],
            '"task_status"',
          );
          expect(resolvedEnum.values, <String>['pending']);
          expect(
            introspected.findModel('Todo')?.findField('status')?.type,
            'TaskStatus',
          );

          final rows = await connection.run((session) async {
            final result = await session.execute(
              'SELECT "title", "status"::text AS "status" '
              'FROM "Todo" ORDER BY "id" ASC',
            );
            return result
                .map((row) => Map<String, Object?>.from(row.toColumnMap()))
                .toList(growable: false);
          });
          expect(rows, hasLength(1));
          expect(rows.single['title'], 'Keep me');
          expect(rows.single['status'], 'pending');
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'applies mapped enum rename and insert transitions without rebuild',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
  @@map("todo_status")
}

model Todo {
  id Int @id @default(autoincrement())
  title String
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
  title String
  status TaskStatus
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);
          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "Todo" ("title", "status") VALUES (\$1, \$2)',
              parameters: <Object?>['Rename me', 'done'],
              ignoreRows: true,
            );
          });

          final service = const PostgresqlMigrationService();
          final result = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_mapped_enum_non_rebuild',
          );

          expect(result.applied, isTrue);
          expect(result.plan.requiresRebuild, isFalse);
          expect(result.plan.warnings, isEmpty);

          final introspected = await const PostgresqlSchemaIntrospector()
              .introspect(connection);
          final enumDefinition = introspected.findEnumByDatabaseName(
            'task_status',
          );
          expect(enumDefinition, isNotNull);
          expect(enumDefinition!.name, 'TaskStatus');
          expect(enumDefinition.values, <String>[
            'pending',
            'completed',
            'archived',
          ]);
          expect(
            introspected.findModel('Todo')?.findField('status')?.type,
            'TaskStatus',
          );

          final rows = await connection.run((session) async {
            final result = await session.execute(
              'SELECT "title", "status"::text AS "status" '
              'FROM "Todo" ORDER BY "id" ASC',
            );
            return result
                .map((row) => Map<String, Object?>.from(row.toColumnMap()))
                .toList(growable: false);
          });
          expect(rows, hasLength(1));
          expect(rows.single['title'], 'Rename me');
          expect(rows.single['status'], 'completed');
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'blocks destructive apply without override and succeeds with warnings allowed',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');
        final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);
          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "Todo" ("title", "status") VALUES (\$1, \$2)',
              parameters: <Object?>['Keep me', 'pending'],
              ignoreRows: true,
            );
          });

          const service = PostgresqlMigrationService();
          await expectLater(
            () => service.applySchema(
              executor: connection,
              target: target,
              migrationName: '20260314_enum_warning_gate',
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                contains('Migration plan contains warnings'),
              ),
            ),
          );

          final result = await service.applySchema(
            executor: connection,
            target: target,
            migrationName: '20260314_enum_warning_gate',
            allowWarnings: true,
          );

          expect(result.applied, isTrue);
          expect(result.plan.requiresRebuild, isTrue);
          expect(result.plan.warnings, isNotEmpty);
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'fails destructive enum rebuild with explicit error for incompatible live values',
      () async {
        if (!dockerAvailable) {
          return;
        }

        final initial = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');
        final target = const SchemaParser().parse('''
enum TodoStatus {
  pending
}

model Todo {
  id Int @id @default(autoincrement())
  title String
  status TodoStatus
}
''');

        final connection = await harness!.openConnection();
        try {
          await const PostgresqlSchemaApplier().apply(connection, initial);
          await connection.run((session) async {
            await session.execute(
              'INSERT INTO "Todo" ("title", "status") VALUES (\$1, \$2)',
              parameters: <Object?>['Break me', 'done'],
              ignoreRows: true,
            );
          });

          final service = const PostgresqlMigrationService();
          await expectLater(
            () => service.applySchema(
              executor: connection,
              target: target,
              migrationName: '20260314_enum_rebuild_invalid',
              allowWarnings: true,
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                contains(
                  'rows contain values not present in target enum: done',
                ),
              ),
            ),
          );
        } finally {
          await connection.close();
        }
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );
  });
}

class _DockerPostgresHarness {
  _DockerPostgresHarness._({required this.containerName, required this.port});

  final String containerName;
  final int port;

  String get connectionUrl =>
      'postgresql://postgres:postgres@127.0.0.1:$port/comon_orm_test?sslmode=disable';

  static Future<bool> isDockerAvailable() async {
    try {
      final result = await Process.run('docker', <String>['--version']);
      return result.exitCode == 0;
    } on Object {
      return false;
    }
  }

  static Future<_DockerPostgresHarness> start() async {
    final port = await _findFreePort();
    final harness = _DockerPostgresHarness._(
      containerName:
          'comon_orm_pg_${DateTime.now().toUtc().millisecondsSinceEpoch}',
      port: port,
    );

    final runResult = await Process.run('docker', <String>[
      'run',
      '--rm',
      '-d',
      '--name',
      harness.containerName,
      '-e',
      'POSTGRES_PASSWORD=postgres',
      '-e',
      'POSTGRES_USER=postgres',
      '-e',
      'POSTGRES_DB=comon_orm_test',
      '-p',
      '127.0.0.1:${harness.port}:5432',
      'postgres:16-alpine',
    ]);
    if (runResult.exitCode != 0) {
      throw StateError(
        'Unable to start Docker PostgreSQL container: ${runResult.stderr}',
      );
    }

    await harness._waitUntilReady();
    return harness;
  }

  Future<pg.Connection> openConnection() {
    return pg.Connection.openFromUrl(connectionUrl);
  }

  Future<void> reset() async {
    final connection = await openConnection();
    try {
      await connection.run((session) async {
        await session.execute(
          'DROP SCHEMA IF EXISTS public CASCADE',
          ignoreRows: true,
        );
        await session.execute('CREATE SCHEMA public', ignoreRows: true);
        await session.execute(
          'GRANT ALL ON SCHEMA public TO CURRENT_USER',
          ignoreRows: true,
        );
        await session.execute(
          'GRANT ALL ON SCHEMA public TO PUBLIC',
          ignoreRows: true,
        );
      });
    } finally {
      await connection.close();
    }
  }

  Future<void> dispose() async {
    await Process.run('docker', <String>['stop', containerName]);
  }

  Future<void> _waitUntilReady() async {
    final deadline = DateTime.now().add(const Duration(minutes: 1));
    Object? lastError;
    while (DateTime.now().isBefore(deadline)) {
      try {
        final connection = await openConnection();
        await connection.close();
        return;
      } on Object catch (error) {
        lastError = error;
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    throw StateError(
      'PostgreSQL Docker container did not become ready: $lastError',
    );
  }

  static Future<int> _findFreePort() async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    await server.close();
    return port;
  }
}
