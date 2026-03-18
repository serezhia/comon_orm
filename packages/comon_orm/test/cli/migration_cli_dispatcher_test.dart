import 'dart:io';

import 'package:comon_orm/src/cli/migration_cli_dispatcher.dart';
import 'package:test/test.dart';

void main() {
  group('MigrationCliDispatcher', () {
    test('delegates PostgreSQL migrations to comon_orm_postgresql', () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_migrate_pg_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

model User {
  id Int @id
}
''');

        late MigrationCliInvocation invocation;
        final dispatcher = MigrationCliDispatcher(
          delegate: (value) async {
            invocation = value;
            return 0;
          },
        );

        final exitCode = await dispatcher.run(<String>[
          'diff',
          '--schema',
          schemaPath,
          '--name',
          '20260314_init',
          '--out',
          'prisma/migrations',
        ]);

        expect(exitCode, 0);
        expect(invocation.provider, 'postgresql');
        expect(
          invocation.packageExecutable,
          'comon_orm_postgresql:comon_orm_postgresql',
        );
        expect(invocation.arguments, containsAll(<String>['diff', '--schema']));
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('delegates SQLite rollback to comon_orm_sqlite', () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_migrate_sqlite_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id
}
''');

        late MigrationCliInvocation invocation;
        final dispatcher = MigrationCliDispatcher(
          delegate: (value) async {
            invocation = value;
            return 0;
          },
        );

        final exitCode = await dispatcher.run(<String>[
          'rollback',
          '--schema',
          schemaPath,
        ]);

        expect(exitCode, 0);
        expect(invocation.provider, 'sqlite');
        expect(
          invocation.packageExecutable,
          'comon_orm_sqlite:comon_orm_sqlite',
        );
        expect(invocation.arguments, <String>[
          'rollback',
          '--schema',
          schemaPath,
        ]);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('auto-discovers schema and forwards absolute --schema path', () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_migrate_auto_',
      );
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
  id Int @id
}
''');

        Directory.current = tempRoot;
        final expectedSchemaPath = File('prisma/schema.prisma').absolute.path;

        late MigrationCliInvocation invocation;
        final dispatcher = MigrationCliDispatcher(
          delegate: (value) async {
            invocation = value;
            return 0;
          },
        );

        final exitCode = await dispatcher.run(<String>['status']);

        expect(exitCode, 0);
        expect(
          invocation.arguments,
          containsAll(<String>['--schema', expectedSchemaPath]),
        );
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('delegates db push to the provider executable', () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_db_push_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "file:dev.db"
}

model User {
  id Int @id
}
''');

        late MigrationCliInvocation invocation;
        final dispatcher = MigrationCliDispatcher(
          delegate: (value) async {
            invocation = value;
            return 0;
          },
        );

        final exitCode = await dispatcher.run(<String>[
          'push',
          '--schema',
          schemaPath,
        ]);

        expect(exitCode, 0);
        expect(invocation.provider, 'sqlite');
        expect(invocation.arguments.first, 'push');
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('returns usage error for unsupported providers', () async {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_migrate_mysql_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "mysql"
  url = env("DATABASE_URL")
}

model User {
  id Int @id
}
''');

        final err = StringBuffer();
        final dispatcher = MigrationCliDispatcher(err: err);

        final exitCode = await dispatcher.run(<String>[
          'diff',
          '--schema',
          schemaPath,
          '--name',
          'init',
          '--out',
          'prisma/migrations',
        ]);

        expect(exitCode, 2);
        expect(
          err.toString(),
          contains('Unsupported datasource provider "mysql"'),
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('prints migrate subcommands in help output', () async {
      final out = StringBuffer();
      final err = StringBuffer();
      final dispatcher = MigrationCliDispatcher(out: out, err: err);

      final exitCode = await dispatcher.run(<String>[], commandName: 'migrate');

      expect(exitCode, 0);
      expect(
        out.toString(),
        contains('Usage: comon_orm migrate <command> [options]'),
      );
      expect(out.toString(), contains('  diff      Compare schema sources'));
      expect(
        out.toString(),
        contains('  dev       Create and apply a local migration'),
      );
      expect(
        out.toString(),
        contains('  deploy    Apply reviewed local migrations'),
      );
      expect(
        out.toString(),
        contains('  status    Compare local migration artifacts'),
      );
      expect(
        out.toString(),
        contains('  rollback  Revert to a recorded schema snapshot'),
      );
      expect(out.toString(), isNot(contains('  apply     ')));
      expect(out.toString(), isNot(contains('  history   ')));
      expect(
        out.toString(),
        isNot(contains('  push      Push the current schema')),
      );
      expect(err.toString(), isEmpty);
    });

    test('prints db subcommands in help output', () async {
      final out = StringBuffer();
      final err = StringBuffer();
      final dispatcher = MigrationCliDispatcher(out: out, err: err);

      final exitCode = await dispatcher.run(<String>[], commandName: 'db');

      expect(exitCode, 0);
      expect(
        out.toString(),
        contains('Usage: comon_orm db <command> [options]'),
      );
      expect(
        out.toString(),
        contains(
          '  push      Push the current schema without creating migration history.',
        ),
      );
      expect(
        out.toString(),
        isNot(contains('  dev       Create and apply a new local migration')),
      );
      expect(err.toString(), isEmpty);
    });
  });
}
