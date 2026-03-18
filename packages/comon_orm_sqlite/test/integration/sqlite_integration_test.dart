import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

void main() {
  group('SqliteIntegration', () {
    test(
      'reports clean status and checksum drift for file-backed migrations',
      () {
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

        final tempRoot = Directory.systemTemp.createTempSync(
          'comon_orm_sqlite_',
        );
        final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';
        final database = sqlite.sqlite3.open(databasePath);
        const service = SqliteMigrationService();

        try {
          const SqliteSchemaApplier().apply(database, initial);
          final draft = service.draftFromDatabase(
            database: database,
            target: target,
            migrationName: '20260314_status_drift',
          );
          final migrationDir = service.writeDraft(
            draft: draft,
            directoryPath: tempRoot.path,
          );
          service.applySchema(
            database: database,
            target: target,
            migrationName: '20260314_status_drift',
          );

          final cleanStatus = service.status(
            database: database,
            migrationsDirectory: tempRoot.path,
          );
          expect(cleanStatus.isClean, isTrue);
          expect(cleanStatus.issues, isEmpty);

          File(
            '${migrationDir.path}${Platform.pathSeparator}migration.sql',
          ).writeAsStringSync('-- modified locally\n');

          final driftStatus = service.status(
            database: database,
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
          final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);
          final targetSchemaPath =
              '${tempRoot.path}${Platform.pathSeparator}target.prisma';
          File(targetSchemaPath).writeAsStringSync('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');
          final exitCode = cli.run(<String>[
            'status',
            '--db',
            databasePath,
            '--schema',
            targetSchemaPath,
            '--from',
            tempRoot.path,
          ]);

          expect(exitCode, 1);
          expect(errBuffer.toString(), isEmpty);
          expect(outBuffer.toString(), contains('checksum-mismatch'));
        } finally {
          database.close();
          tempRoot.deleteSync(recursive: true);
        }
      },
    );

    test(
      'blocks destructive rollback without override and uses DB snapshots',
      () {
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

        final tempRoot = Directory.systemTemp.createTempSync(
          'comon_orm_sqlite_',
        );
        final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';
        final database = sqlite.sqlite3.open(databasePath);
        const service = SqliteMigrationService();

        try {
          const SqliteSchemaApplier().apply(database, initial);
          final draft = service.draftFromDatabase(
            database: database,
            target: target,
            migrationName: '20260314_snapshot_rollback',
          );
          service.writeDraft(draft: draft, directoryPath: tempRoot.path);
          service.applySchema(
            database: database,
            target: target,
            migrationName: '20260314_snapshot_rollback',
          );

          database.execute(
            'INSERT INTO "User" ("name", "nickname") VALUES (?, ?)',
            <Object?>['Ada', 'first'],
          );

          expect(
            () => service.rollbackMigration(
              database: database,
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

          final result = service.rollbackMigration(
            database: database,
            migrationsDirectory: tempRoot.path,
            allowWarnings: true,
          );

          expect(result.rolledBack, isTrue);
          expect(result.warnings, isNotEmpty);

          final columns = database.select('PRAGMA table_info("User")');
          expect(columns.any((row) => row['name'] == 'nickname'), isFalse);

          final rows = database.select(
            'SELECT name FROM "User" ORDER BY id ASC',
          );
          expect(rows.single['name'], 'Ada');
        } finally {
          database.close();
          tempRoot.deleteSync(recursive: true);
        }
      },
    );

    test(
      'blocks destructive apply without override and reports unsupported manual migration when allowed',
      () {
        final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');
        final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  name String
}
''');

        final tempRoot = Directory.systemTemp.createTempSync(
          'comon_orm_sqlite_',
        );
        final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';
        final database = sqlite.sqlite3.open(databasePath);
        const service = SqliteMigrationService();

        try {
          const SqliteSchemaApplier().apply(database, initial);
          database.execute(
            'INSERT INTO "User" ("name", "nickname") VALUES (?, ?)',
            <Object?>['Ada', 'first'],
          );

          expect(
            () => service.applySchema(
              database: database,
              target: target,
              migrationName: '20260314_drop_nickname',
            ),
            throwsA(
              isA<StateError>().having(
                (error) => error.message,
                'message',
                contains('Migration plan contains warnings'),
              ),
            ),
          );

          final result = service.applySchema(
            database: database,
            target: target,
            migrationName: '20260314_drop_nickname',
            allowWarnings: true,
          );

          expect(result.applied, isFalse);
          expect(result.plan.warnings, isNotEmpty);

          final columns = database.select('PRAGMA table_info("User")');
          expect(columns.any((row) => row['name'] == 'nickname'), isTrue);

          final rows = database.select(
            'SELECT name, nickname FROM "User" ORDER BY id ASC',
          );
          expect(rows.single['name'], 'Ada');
          expect(rows.single['nickname'], 'first');
        } finally {
          database.close();
          tempRoot.deleteSync(recursive: true);
        }
      },
    );
  });
}
