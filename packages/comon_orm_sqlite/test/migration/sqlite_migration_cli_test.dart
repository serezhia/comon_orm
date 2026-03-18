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
          database.close();
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
          revertedDatabase.close();
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

    test('auto-discovers schema and uses default migrations directory', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      final previousCurrent = Directory.current;
      try {
        final prismaDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}prisma',
        )..createSync(recursive: true);
        final schemaPath =
            '${prismaDir.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');

        Directory.current = tempRoot;
        final outBuffer = StringBuffer();
        final errBuffer = StringBuffer();
        final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);

        final exitCode = cli.run(<String>['diff', '--name', '20260313_init']);

        expect(exitCode, 0);
        expect(errBuffer.toString(), isEmpty);
        expect(
          File(
            '${prismaDir.path}${Platform.pathSeparator}migrations${Platform.pathSeparator}20260313_init${Platform.pathSeparator}migration.sql',
          ).existsSync(),
          isTrue,
        );
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('dev creates applies and generates using default paths', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      final previousCurrent = Directory.current;
      try {
        final prismaDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}prisma',
        )..createSync(recursive: true);
        File(
          '${prismaDir.path}${Platform.pathSeparator}schema.prisma',
        ).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');

        Directory.current = tempRoot;
        final outBuffer = StringBuffer();
        final errBuffer = StringBuffer();
        final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);

        final exitCode = cli.run(<String>['dev', '--name', '20260318_init']);

        expect(exitCode, 0);
        expect(errBuffer.toString(), isEmpty);
        expect(
          File(
            '${prismaDir.path}${Platform.pathSeparator}migrations${Platform.pathSeparator}20260318_init${Platform.pathSeparator}migration.sql',
          ).existsSync(),
          isTrue,
        );
        expect(
          File(
            '${prismaDir.path}${Platform.pathSeparator}lib${Platform.pathSeparator}generated${Platform.pathSeparator}comon_orm_client.dart',
          ).existsSync(),
          isTrue,
        );

        final database = sqlite.sqlite3.open(
          '${prismaDir.path}${Platform.pathSeparator}dev.db',
        );
        try {
          final history = const SqliteMigrationService().runner.loadHistory(
            database,
          );
          expect(history.single.name, '20260318_init');
        } finally {
          database.close();
        }
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('push syncs schema without writing migration history', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      final previousCurrent = Directory.current;
      try {
        final prismaDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}prisma',
        )..createSync(recursive: true);
        File(
          '${prismaDir.path}${Platform.pathSeparator}schema.prisma',
        ).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');

        Directory.current = tempRoot;
        final cli = SqliteMigrationCli(
          out: StringBuffer(),
          err: StringBuffer(),
        );

        final exitCode = cli.run(<String>['push']);

        expect(exitCode, 0);
        final database = sqlite.sqlite3.open(
          '${prismaDir.path}${Platform.pathSeparator}dev.db',
        );
        try {
          final history = const SqliteMigrationService().runner.loadHistory(
            database,
          );
          expect(history, isEmpty);
          final tables = database.select(
            "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'User'",
          );
          expect(tables, isNotEmpty);
        } finally {
          database.close();
        }
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('resolve marks migrations as applied and rolled back', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      final previousCurrent = Directory.current;
      try {
        final prismaDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}prisma',
        )..createSync(recursive: true);
        File(
          '${prismaDir.path}${Platform.pathSeparator}schema.prisma',
        ).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id @default(autoincrement())
  name String
}
''');

        Directory.current = tempRoot;
        final cli = SqliteMigrationCli(
          out: StringBuffer(),
          err: StringBuffer(),
        );

        expect(
          cli.run(<String>['dev', '--name', '20260318_init', '--create-only']),
          0,
        );
        expect(cli.run(<String>['resolve', '--applied', '20260318_init']), 0);
        expect(
          cli.run(<String>['resolve', '--rolled-back', '20260318_init']),
          0,
        );

        final database = sqlite.sqlite3.open(
          '${prismaDir.path}${Platform.pathSeparator}dev.db',
        );
        try {
          final runner = const SqliteMigrationService().runner;
          expect(runner.loadHistory(database), hasLength(2));
          expect(runner.loadActiveHistory(database), isEmpty);
        } finally {
          database.close();
        }
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('supports enhanced diff source pairs with exit-code and script', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model User {
  id Int @id
}
''');

        final outBuffer = StringBuffer();
        final errBuffer = StringBuffer();
        final cli = SqliteMigrationCli(out: outBuffer, err: errBuffer);

        final exitCode = cli.run(<String>[
          'diff',
          '--from-empty',
          '--to-schema',
          schemaPath,
          '--script',
          '--exit-code',
        ]);

        expect(exitCode, 2);
        expect(errBuffer.toString(), isEmpty);
        expect(outBuffer.toString(), contains('CREATE TABLE'));
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });
  });
}
