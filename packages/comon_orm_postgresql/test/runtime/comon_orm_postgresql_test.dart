import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'dart:io';

import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

void main() {
  test('exports postgresql adapter and connection config', () {
    final config = PostgresqlConnectionConfig(
      host: 'localhost',
      database: 'postgres',
      username: 'postgres',
      sslMode: pg.SslMode.disable,
    );
    final adapter = PostgresqlDatabaseAdapter(
      executor: _FakeExecutor(),
      schema: const SchemaParser().parse('''
model User {
  id Int @id
}
'''),
    );

    expect(config.port, 5432);
    expect(adapter, isA<PostgresqlDatabaseAdapter>());
  });

  test('opens postgresql adapter from generated schema metadata', () async {
    late String openedUrl;
    late RuntimeSchemaView openedSchema;

    final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
      schema: const GeneratedRuntimeSchema(
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'postgresql',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.literal,
              value: 'postgresql://localhost:5432/app',
            ),
          ),
        ],
        models: <GeneratedModelMetadata>[],
      ),
      adapterFactory: ({required connectionUrl, required schema}) async {
        openedUrl = connectionUrl;
        openedSchema = schema;
        return PostgresqlDatabaseAdapter.fromRuntimeSchema(
          executor: _FakeExecutor(),
          schema: schema,
        );
      },
    );

    expect(adapter, isA<PostgresqlDatabaseAdapter>());
    expect(openedUrl, 'postgresql://localhost:5432/app');
    expect(openedSchema.findDatasource('db'), isNotNull);
  });

  test(
    'runtime datasource resolution still allows explicit url override',
    () async {
      late String openedUrl;

      final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
        schema: const GeneratedRuntimeSchema(
          datasources: <GeneratedDatasourceMetadata>[
            GeneratedDatasourceMetadata(
              name: 'db',
              provider: 'postgresql',
              url: GeneratedDatasourceUrl(
                kind: GeneratedDatasourceUrlKind.literal,
                value: 'postgresql://localhost:5432/app',
              ),
            ),
          ],
          models: <GeneratedModelMetadata>[],
        ),
        connectionUrl: 'postgresql://override:5432/app',
        adapterFactory: ({required connectionUrl, required schema}) async {
          openedUrl = connectionUrl;
          return PostgresqlDatabaseAdapter.fromRuntimeSchema(
            executor: _FakeExecutor(),
            schema: schema,
          );
        },
      );

      expect(adapter, isA<PostgresqlDatabaseAdapter>());
      expect(openedUrl, 'postgresql://override:5432/app');
    },
  );

  test('generated schema open accepts sslMode override', () async {
    final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
      schema: const GeneratedRuntimeSchema(
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'postgresql',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.literal,
              value: 'postgresql://localhost:5432/app',
            ),
          ),
        ],
        models: <GeneratedModelMetadata>[],
      ),
      sslMode: pg.SslMode.disable,
      adapterFactory: ({required connectionUrl, required schema}) async {
        expect(connectionUrl, 'postgresql://localhost:5432/app');
        return PostgresqlDatabaseAdapter.fromRuntimeSchema(
          executor: _FakeExecutor(),
          schema: schema,
        );
      },
    );

    expect(adapter, isA<PostgresqlDatabaseAdapter>());
  });

  test('constructs postgresql adapter from generated metadata', () {
    final adapter = PostgresqlDatabaseAdapter.fromGeneratedSchema(
      executor: _FakeExecutor(),
      schema: const GeneratedRuntimeSchema(
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
                name: 'status',
                databaseName: 'status',
                kind: GeneratedRuntimeFieldKind.enumeration,
                type: 'UserStatus',
                isNullable: false,
                isList: false,
              ),
            ],
          ),
        ],
        enums: <GeneratedEnumMetadata>[
          GeneratedEnumMetadata(
            name: 'UserStatus',
            databaseName: 'user_status',
            values: <String>['active', 'disabled'],
          ),
        ],
      ),
    );

    expect(adapter, isA<PostgresqlDatabaseAdapter>());
  });

  test('postgresql cli diff reads datasource url from schema', () async {
    final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_cli_');
    try {
      final schemaPath =
          '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
      final migrationsPath =
          '${tempRoot.path}${Platform.pathSeparator}migrations';
      File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "postgresql"
  url = "postgresql://localhost:5432/app"
}

model User {
  id Int @id
}
''');

      final openedUrls = <String>[];
      final service = _FakeMigrationService();
      final cli = PostgresqlMigrationCli(
        service: service,
        openConnection: (connectionUrl) async {
          openedUrls.add(connectionUrl);
          return PostgresqlCliSession(
            executor: _FakeSessionExecutor(),
            close: () async {},
          );
        },
        out: StringBuffer(),
        err: StringBuffer(),
      );

      final exitCode = await cli.run(<String>[
        'diff',
        '--schema',
        schemaPath,
        '--name',
        '20260314_test',
        '--out',
        migrationsPath,
      ]);

      expect(exitCode, 0);
      expect(openedUrls, <String>['postgresql://localhost:5432/app']);
      expect(service.lastMigrationName, '20260314_test');
      expect(service.lastTarget?.findModel('User'), isNotNull);
      expect(
        Directory(
          '$migrationsPath${Platform.pathSeparator}20260314_test',
        ).existsSync(),
        isTrue,
      );
    } finally {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test(
    'postgresql migration draft snapshots preserve enums and model attributes',
    () async {
      final sourceSchema = const SchemaParser().parse('''
enum TodoStatus {
  pending
  done
}

model Todo {
  id Int @id
  status TodoStatus

  @@unique([id, status])
}
''');
      final targetSchema = const SchemaParser().parse('''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

generator client {
  provider = "comon_orm"
  output = "lib/generated"
}

enum TodoStatus {
  pending
  done
  archived
}

model Todo {
  id Int @id
  status TodoStatus

  @@unique([id, status])
}
''');

      final service = PostgresqlMigrationService(
        planner: PostgresqlMigrationPlanner(
          schemaIntrospector: _FakeIntrospector(sourceSchema),
        ),
      );

      final draft = await service.draftFromDatabase(
        executor: _FakeSessionExecutor(),
        target: targetSchema,
        migrationName: '20260314_enum_snapshot',
      );

      expect(draft.beforeSchema, contains('enum TodoStatus {'));
      expect(draft.beforeSchema, contains('@@unique([id, status])'));
      expect(draft.afterSchema, contains('datasource db {'));
      expect(draft.afterSchema, contains('generator client {'));
      expect(draft.afterSchema, contains('archived'));
      expect(draft.checksum, isNotEmpty);
    },
  );

  test('postgresql status reports checksum drift', () async {
    final tempRoot = Directory.systemTemp.createTempSync(
      'comon_orm_pg_status_',
    );
    try {
      const beforeSchema = 'model User {\n  id Int @id\n}\n';
      const afterSchema = 'model User {\n  id Int @id\n  nickname String?\n}\n';
      final migrationDir = Directory(
        '${tempRoot.path}${Platform.pathSeparator}20260314_add_user_nickname',
      )..createSync(recursive: true);
      File(
        '${migrationDir.path}${Platform.pathSeparator}before.prisma',
      ).writeAsStringSync(beforeSchema);
      File(
        '${migrationDir.path}${Platform.pathSeparator}after.prisma',
      ).writeAsStringSync(afterSchema);
      File(
        '${migrationDir.path}${Platform.pathSeparator}migration.sql',
      ).writeAsStringSync('ALTER TABLE "User" ADD COLUMN "nickname" TEXT;\n');

      final service = PostgresqlMigrationService(
        runner: _FakePostgresqlMigrationRunner(
          activeHistory: <PostgresqlMigrationRecord>[
            PostgresqlMigrationRecord(
              name: '20260314_add_user_nickname',
              appliedAt: DateTime.utc(2026, 3, 14),
              statementCount: 1,
              kind: PostgresqlMigrationRecordKind.apply,
              warnings: <String>[],
              rebuildRequired: false,
              checksum: 'stale',
              beforeSchema: beforeSchema,
              afterSchema: afterSchema,
            ),
          ],
        ),
      );

      final status = await service.status(
        executor: _FakeSessionExecutor(),
        migrationsDirectory: tempRoot.path,
      );

      expect(status.isClean, isFalse);
      expect(
        status.issues.any((issue) => issue.code == 'checksum-mismatch'),
        isTrue,
      );
    } finally {
      tempRoot.deleteSync(recursive: true);
    }
  });

  test(
    'postgresql rollback falls back to schema snapshot stored in history',
    () async {
      const beforeSchema = 'model User {\n  id Int @id\n}\n';
      final runner = _FakePostgresqlMigrationRunner(
        activeHistory: <PostgresqlMigrationRecord>[
          PostgresqlMigrationRecord(
            name: '20260314_add_user_nickname',
            appliedAt: DateTime.utc(2026, 3, 14),
            statementCount: 1,
            kind: PostgresqlMigrationRecordKind.apply,
            warnings: <String>[],
            rebuildRequired: false,
            beforeSchema: beforeSchema,
            afterSchema: 'model User {\n  id Int @id\n  nickname String?\n}\n',
          ),
        ],
        rollbackResult: const PostgresqlRollbackResult(
          targetMigrationName: '20260314_add_user_nickname',
          rolledBack: true,
          statementCount: 3,
          warnings: <String>[
            'Potential data loss: field User.nickname is removed from the target schema.',
          ],
        ),
      );
      final service = PostgresqlMigrationService(runner: runner);
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_rb_');
      try {
        expect(
          () => service.rollbackMigration(
            executor: _FakeSessionExecutor(),
            migrationsDirectory: tempRoot.path,
          ),
          throwsStateError,
        );

        final result = await service.rollbackMigration(
          executor: _FakeSessionExecutor(),
          migrationsDirectory: tempRoot.path,
          allowWarnings: true,
        );

        expect(result.rolledBack, isTrue);
        expect(runner.lastRollbackTarget?.findModel('User'), isNotNull);
        expect(runner.lastAllowWarnings, isTrue);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    },
  );
}

class _FakeIntrospector extends PostgresqlSchemaIntrospector {
  const _FakeIntrospector(this.schema);

  final SchemaDocument schema;

  @override
  Future<SchemaDocument> introspect(
    pg.SessionExecutor executor, {
    String schemaName = 'public',
  }) async {
    return schema;
  }
}

class _FakeMigrationService extends PostgresqlMigrationService {
  _FakeMigrationService();

  SchemaDocument? lastTarget;
  String? lastMigrationName;

  @override
  Future<PostgresqlMigrationDraft> draftFromDatabase({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String migrationName,
  }) async {
    lastTarget = target;
    lastMigrationName = migrationName;
    return PostgresqlMigrationDraft(
      name: migrationName,
      generatedAt: DateTime.utc(2026, 3, 14),
      plan: const PostgresqlMigrationPlan(
        statements: <String>['SELECT 1'],
        warnings: <String>[],
      ),
      beforeSchema: 'model Before {\n  id Int @id\n}\n',
      afterSchema: 'model After {\n  id Int @id\n}\n',
    );
  }
}

class _FakePostgresqlMigrationRunner extends PostgresqlMigrationRunner {
  _FakePostgresqlMigrationRunner({
    this.activeHistory = const <PostgresqlMigrationRecord>[],
    this.rollbackResult = const PostgresqlRollbackResult(
      targetMigrationName: 'noop',
      rolledBack: false,
      statementCount: 0,
      warnings: <String>[],
    ),
  });

  final List<PostgresqlMigrationRecord> activeHistory;
  final PostgresqlRollbackResult rollbackResult;
  SchemaDocument? lastRollbackTarget;
  bool? lastAllowWarnings;

  @override
  Future<List<PostgresqlMigrationRecord>> loadActiveHistory(
    pg.SessionExecutor executor,
  ) async {
    return activeHistory;
  }

  @override
  Future<PostgresqlRollbackResult> rollbackToSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String targetMigrationName,
    String? rollbackName,
    bool allowWarnings = false,
  }) async {
    lastRollbackTarget = target;
    lastAllowWarnings = allowWarnings;
    if (!allowWarnings) {
      throw StateError('Rollback plan contains warnings: blocked');
    }
    return rollbackResult;
  }
}

class _FakeExecutor implements PostgresqlQueryExecutor {
  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    return 0;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    return const <Map<String, Object?>>[];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) {
    return action(this);
  }
}

class _FakeSessionExecutor implements pg.SessionExecutor {
  @override
  Future<R> run<R>(
    Future<R> Function(pg.Session session) fn, {
    pg.SessionSettings? settings,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<R> runTx<R>(
    Future<R> Function(pg.TxSession session) fn, {
    pg.TransactionSettings? settings,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> close({bool force = false}) {
    throw UnimplementedError();
  }
}
