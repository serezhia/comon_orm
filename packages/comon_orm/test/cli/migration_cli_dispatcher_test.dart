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

    test('delegates SQLite migrations to comon_orm_sqlite', () async {
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
          'history',
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
          'history',
          '--schema',
          schemaPath,
        ]);
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
  });
}
