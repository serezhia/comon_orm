import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

void main() {
  group('SqliteMigrationService', () {
    test('builds migration draft from live database', () {
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

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);

      final draft = const SqliteMigrationService().draftFromDatabase(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );

      expect(draft.name, '20260313_add_user_nickname');
      expect(draft.plan.warnings, isEmpty);
      expect(draft.plan.statements, hasLength(1));
      expect(
        draft.sqlScript,
        contains('ALTER TABLE "User" ADD COLUMN "nickname" TEXT'),
      );
      expect(draft.beforeSchema, contains('name String'));
      expect(draft.afterSchema, contains('nickname String?'));

      database.close();
    });

    test('writes migration draft files to disk', () {
      final draft = SqliteMigrationDraft(
        name: '20260313_add_user_nickname',
        generatedAt: DateTime.utc(2026, 3, 13, 12),
        plan: const SqliteMigrationPlan(
          statements: <String>['ALTER TABLE "User" ADD COLUMN "nickname" TEXT'],
          warnings: <String>['manual review recommended'],
        ),
        beforeSchema: 'model User {\n  id Int @id\n}\n',
        afterSchema: 'model User {\n  id Int @id\n  nickname String?\n}\n',
      );

      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_sqlite_');
      try {
        final migrationDir = const SqliteMigrationService().writeDraft(
          draft: draft,
          directoryPath: tempRoot.path,
        );

        final sqlFile = File(
          '${migrationDir.path}${Platform.pathSeparator}migration.sql',
        );
        final metadataFile = File(
          '${migrationDir.path}${Platform.pathSeparator}metadata.txt',
        );
        final warningsFile = File(
          '${migrationDir.path}${Platform.pathSeparator}warnings.txt',
        );
        final beforeSchemaFile = File(
          '${migrationDir.path}${Platform.pathSeparator}before.prisma',
        );
        final afterSchemaFile = File(
          '${migrationDir.path}${Platform.pathSeparator}after.prisma',
        );

        expect(sqlFile.existsSync(), isTrue);
        expect(metadataFile.existsSync(), isTrue);
        expect(warningsFile.existsSync(), isTrue);
        expect(beforeSchemaFile.existsSync(), isTrue);
        expect(afterSchemaFile.existsSync(), isTrue);
        expect(
          sqlFile.readAsStringSync(),
          contains('ALTER TABLE "User" ADD COLUMN "nickname" TEXT;'),
        );
        expect(
          metadataFile.readAsStringSync(),
          contains('name=20260313_add_user_nickname'),
        );
        expect(
          metadataFile.readAsStringSync(),
          contains('rebuild_required=false'),
        );
        expect(metadataFile.readAsStringSync(), contains('provider=sqlite'));
        expect(metadataFile.readAsStringSync(), contains('checksum='));
        expect(
          warningsFile.readAsStringSync(),
          contains('manual review recommended'),
        );
        expect(beforeSchemaFile.readAsStringSync(), contains('model User {'));
        expect(afterSchemaFile.readAsStringSync(), contains('model User {'));
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('describes rebuild-required drafts without empty SQL', () {
      final draft = SqliteMigrationDraft(
        name: '20260314_update_post_user_fk',
        generatedAt: DateTime.utc(2026, 3, 14, 12),
        plan: const SqliteMigrationPlan(
          statements: <String>[],
          warnings: <String>[],
          requiresRebuild: true,
        ),
        beforeSchema: 'model Post {\n  id Int @id\n}\n',
        afterSchema: 'model Post {\n  id Int @id\n  userId Int?\n}\n',
      );

      expect(
        draft.sqlScript,
        '-- Schema rebuild required to apply this migration safely.\n',
      );
    });

    test('applies target schema through runner facade', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  nickname String?
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);

      final result = const SqliteMigrationService().applySchema(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );

      expect(result.applied, isTrue);
      final columns = database.select('PRAGMA table_info("User")');
      expect(columns.any((row) => row['name'] == 'nickname'), isTrue);

      database.close();
    });

    test('rolls back the latest applied migration from DB snapshot fallback', () {
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

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const service = SqliteMigrationService();

      final draft = service.draftFromDatabase(
        database: database,
        target: target,
        migrationName: '20260313_add_user_nickname',
      );
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_sqlite_');

      try {
        service.writeDraft(draft: draft, directoryPath: tempRoot.path);
        service.applySchema(
          database: database,
          target: target,
          migrationName: '20260313_add_user_nickname',
        );

        database.execute(
          'INSERT INTO "User" (name, nickname) VALUES (?, ?)',
          <Object?>['Ada', 'first'],
        );

        expect(
          () => service.rollbackMigration(
            database: database,
            migrationsDirectory: tempRoot.path,
          ),
          throwsStateError,
        );

        Directory(
          '${tempRoot.path}${Platform.pathSeparator}20260313_add_user_nickname',
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
        final rows = database.select('SELECT name FROM "User"');
        expect(rows.single['name'], 'Ada');
      } finally {
        tempRoot.deleteSync(recursive: true);
        database.close();
      }
    });

    test(
      'reports clean status when local artifacts match database history',
      () {
        final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
        final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  nickname String?
}
''');

        final database = sqlite.sqlite3.openInMemory();
        const SqliteSchemaApplier().apply(database, initial);
        const service = SqliteMigrationService();
        final tempRoot = Directory.systemTemp.createTempSync(
          'comon_orm_sqlite_',
        );
        try {
          final draft = service.draftFromDatabase(
            database: database,
            target: target,
            migrationName: '20260313_add_user_nickname',
          );
          service.writeDraft(draft: draft, directoryPath: tempRoot.path);
          service.applySchema(
            database: database,
            target: target,
            migrationName: '20260313_add_user_nickname',
          );

          final status = service.status(
            database: database,
            migrationsDirectory: tempRoot.path,
          );

          expect(status.isClean, isTrue);
          expect(status.issues, isEmpty);
        } finally {
          tempRoot.deleteSync(recursive: true);
          database.close();
        }
      },
    );

    test('reports checksum drift when local migration changes', () {
      final initial = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
}
''');
      final target = const SchemaParser().parse('''
model User {
  id Int @id @default(autoincrement())
  nickname String?
}
''');

      final database = sqlite.sqlite3.openInMemory();
      const SqliteSchemaApplier().apply(database, initial);
      const service = SqliteMigrationService();
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_sqlite_');
      try {
        final draft = service.draftFromDatabase(
          database: database,
          target: target,
          migrationName: '20260313_add_user_nickname',
        );
        final migrationDir = service.writeDraft(
          draft: draft,
          directoryPath: tempRoot.path,
        );
        service.applySchema(
          database: database,
          target: target,
          migrationName: '20260313_add_user_nickname',
        );

        File(
          '${migrationDir.path}${Platform.pathSeparator}migration.sql',
        ).writeAsStringSync('-- changed on disk\n');

        final status = service.status(
          database: database,
          migrationsDirectory: tempRoot.path,
        );

        expect(status.isClean, isFalse);
        expect(
          status.issues.any((issue) => issue.code == 'checksum-mismatch'),
          isTrue,
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
        database.close();
      }
    });
  });
}
