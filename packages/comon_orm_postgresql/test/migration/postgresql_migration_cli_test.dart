import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

void main() {
  group('Postgresql migration workflows', () {
    test('deploy applies only pending local artifacts', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
      try {
        _writeMigrationArtifact(
          tempRoot,
          name: '20260314_init',
          beforeSchema: 'model A {\n  id Int @id\n}\n',
          afterSchema: 'model A {\n  id Int @id\n}\n',
        );
        _writeMigrationArtifact(
          tempRoot,
          name: '20260315_add_user',
          beforeSchema: 'model A {\n  id Int @id\n}\n',
          afterSchema: 'model User {\n  id Int @id\n}\n',
        );

        final runner = _RecordingPostgresqlMigrationRunner(
          activeHistory: <PostgresqlMigrationRecord>[
            PostgresqlMigrationRecord(
              name: '20260314_init',
              appliedAt: DateTime.utc(2026, 3, 14),
              statementCount: 1,
              kind: PostgresqlMigrationRecordKind.apply,
              warnings: const <String>[],
              rebuildRequired: false,
            ),
          ],
        );
        final service = PostgresqlMigrationService(runner: runner);

        final result = await service.deployMigrations(
          executor: _FakeSessionExecutor(),
          migrationsDirectory: tempRoot.path,
        );

        expect(result.localMigrationCount, 2);
        expect(result.appliedMigrationNames, <String>['20260315_add_user']);
        expect(runner.appliedMigrationNames, <String>['20260315_add_user']);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('deploy rejects artifacts that require manual migration', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
      try {
        _writeMigrationArtifact(
          tempRoot,
          name: '20260315_require_last_name',
          beforeSchema: 'model User {\n  id Int @id\n  lastName String?\n}\n',
          afterSchema: 'model User {\n  id Int @id\n  lastName String\n}\n',
          warnings: const <String>[
            'Altering User.lastName requires manual migration.',
          ],
        );

        final service = PostgresqlMigrationService(
          runner: _RecordingPostgresqlMigrationRunner(),
        );

        await expectLater(
          () => service.deployMigrations(
            executor: _FakeSessionExecutor(),
            migrationsDirectory: tempRoot.path,
          ),
          throwsA(
            isA<ManualMigrationRequiredException>().having(
              (error) => error.message,
              'message',
              contains('20260315_require_last_name'),
            ),
          ),
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('resolve delegates applied and rolled-back actions', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
      try {
        _writeMigrationArtifact(
          tempRoot,
          name: '20260315_baseline',
          beforeSchema: 'model A {\n  id Int @id\n}\n',
          afterSchema: 'model User {\n  id Int @id\n}\n',
        );

        final runner = _RecordingPostgresqlMigrationRunner();
        final service = PostgresqlMigrationService(runner: runner);

        final applied = await service.resolveApplied(
          executor: _FakeSessionExecutor(),
          migrationsDirectory: tempRoot.path,
          migrationName: '20260315_baseline',
        );
        final rolledBack = await service.resolveRolledBack(
          executor: _FakeSessionExecutor(),
          migrationName: '20260315_baseline',
        );

        expect(applied.changed, isTrue);
        expect(rolledBack.changed, isTrue);
        expect(runner.lastMarkedAppliedName, '20260315_baseline');
        expect(runner.lastMarkedRolledBackName, '20260315_baseline');
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('cli supports enhanced diff source pairs', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_pg_');
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model User {
  id Int @id
}
''');

        final out = StringBuffer();
        final err = StringBuffer();
        final cli = PostgresqlMigrationCli(out: out, err: err);

        final exitCode = await cli.run(<String>[
          'diff',
          '--from-empty',
          '--to-schema',
          schemaPath,
          '--script',
          '--exit-code',
        ]);

        expect(exitCode, 2);
        expect(err.toString(), isEmpty);
        expect(out.toString(), contains('CREATE TABLE'));
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });
  });
}

class _RecordingPostgresqlMigrationRunner extends PostgresqlMigrationRunner {
  _RecordingPostgresqlMigrationRunner({
    this.activeHistory = const <PostgresqlMigrationRecord>[],
  });

  final List<PostgresqlMigrationRecord> activeHistory;
  final List<String> appliedMigrationNames = <String>[];
  String? lastMarkedAppliedName;
  String? lastMarkedRolledBackName;

  @override
  Future<List<PostgresqlMigrationRecord>> loadActiveHistory(
    pg.SessionExecutor executor,
  ) async {
    return activeHistory;
  }

  @override
  Future<PostgresqlMigrationResult> migrateToSchema({
    required pg.SessionExecutor executor,
    required SchemaDocument target,
    required String migrationName,
    bool allowWarnings = false,
  }) async {
    appliedMigrationNames.add(migrationName);
    return const PostgresqlMigrationResult(
      plan: PostgresqlMigrationPlan(
        statements: <String>['SELECT 1'],
        warnings: <String>[],
      ),
      applied: true,
    );
  }

  @override
  Future<bool> markMigrationApplied({
    required pg.SessionExecutor executor,
    required String migrationName,
    required int statementCount,
    required String checksum,
    required String beforeSchema,
    required String afterSchema,
    required List<String> warnings,
    required bool rebuildRequired,
  }) async {
    lastMarkedAppliedName = migrationName;
    return true;
  }

  @override
  Future<bool> markMigrationRolledBack({
    required pg.SessionExecutor executor,
    required String migrationName,
    String? rollbackName,
  }) async {
    lastMarkedRolledBackName = migrationName;
    return true;
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

void _writeMigrationArtifact(
  Directory root, {
  required String name,
  required String beforeSchema,
  required String afterSchema,
  List<String> warnings = const <String>[],
}) {
  final directory = Directory('${root.path}${Platform.pathSeparator}$name')
    ..createSync(recursive: true);
  File(
    '${directory.path}${Platform.pathSeparator}before.prisma',
  ).writeAsStringSync(beforeSchema);
  File(
    '${directory.path}${Platform.pathSeparator}after.prisma',
  ).writeAsStringSync(afterSchema);
  File(
    '${directory.path}${Platform.pathSeparator}migration.sql',
  ).writeAsStringSync('-- noop\n');
  if (warnings.isNotEmpty) {
    File(
      '${directory.path}${Platform.pathSeparator}warnings.txt',
    ).writeAsStringSync('${warnings.join('\n')}\n');
  }
}
