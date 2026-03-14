import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:test/test.dart';

void main() {
  group('SqliteMigrationCli', () {
    test('runs diff apply and history against a file-backed database', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      try {
        final dbPath = '${tempRoot.path}${Platform.pathSeparator}test.db';
        final migrationsPath =
            '${tempRoot.path}${Platform.pathSeparator}migrations';
        final initialSchemaPath =
            '${tempRoot.path}${Platform.pathSeparator}initial.prisma';
        final targetSchemaPath =
            '${tempRoot.path}${Platform.pathSeparator}target.prisma';

        File(initialSchemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:test.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');
        File(targetSchemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:test.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
  nickname String?
}
''');

        final database = sqlite.sqlite3.open(dbPath);
        try {
          const SqliteSchemaApplier().apply(
            database,
            const SchemaParser().parse(
              File(initialSchemaPath).readAsStringSync(),
            ),
          );
        } finally {
          database.dispose();
        }

        final outBuffer = StringBuffer();
        final errBuffer = StringBuffer();
        final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);

        final diffExitCode = cli.run(<String>[
          'diff',
          '--schema',
          targetSchemaPath,
          '--name',
          '20260313_add_user_nickname',
          '--out',
          migrationsPath,
        ]);

        expect(diffExitCode, 0);
        expect(errBuffer.toString(), isEmpty);
        expect(
          File(
            '$migrationsPath${Platform.pathSeparator}20260313_add_user_nickname${Platform.pathSeparator}migration.sql',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '$migrationsPath${Platform.pathSeparator}20260313_add_user_nickname${Platform.pathSeparator}before.prisma',
          ).existsSync(),
          isTrue,
        );

        outBuffer.clear();
        final applyExitCode = cli.run(<String>[
          'apply',
          '--schema',
          targetSchemaPath,
          '--name',
          '20260313_add_user_nickname',
        ]);

        expect(applyExitCode, 0);
        expect(outBuffer.toString(), contains('Applied: true'));

        final rollbackExitCode = cli.run(<String>[
          'rollback',
          '--schema',
          targetSchemaPath,
          '--from',
          migrationsPath,
          '--allow-warnings',
        ]);

        expect(rollbackExitCode, 0);
        expect(outBuffer.toString(), contains('Rolled back: true'));
        expect(outBuffer.toString(), contains('Warnings:'));

        final revertedDatabase = sqlite.sqlite3.open(dbPath);
        try {
          final columns = revertedDatabase.select('PRAGMA table_info("User")');
          expect(columns.any((row) => row['name'] == 'nickname'), isFalse);
        } finally {
          revertedDatabase.dispose();
        }

        outBuffer.clear();
        final historyExitCode = cli.run(<String>[
          'history',
          '--schema',
          targetSchemaPath,
        ]);

        expect(historyExitCode, 0);
        expect(outBuffer.toString(), contains('20260313_add_user_nickname'));
        expect(outBuffer.toString(), contains('rollback'));

        outBuffer.clear();
        final statusExitCode = cli.run(<String>[
          'status',
          '--schema',
          targetSchemaPath,
          '--from',
          migrationsPath,
        ]);

        expect(statusExitCode, 1);
        expect(outBuffer.toString(), contains('local-migration-not-applied'));
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('returns usage error on unknown command', () {
      final outBuffer = StringBuffer();
      final errBuffer = StringBuffer();
      final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);

      final exitCode = cli.run(<String>['unknown']);

      expect(exitCode, 2);
      expect(errBuffer.toString(), contains('Unknown command: unknown'));
      expect(outBuffer.toString(), contains('Usage: comon_orm_sqlite'));
    });
  });
}
