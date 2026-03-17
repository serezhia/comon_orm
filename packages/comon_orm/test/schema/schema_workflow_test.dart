import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('SchemaWorkflow', () {
    test('resolves generator output relative to schema file', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
generator client {
  provider = "comon_orm"
  output = "lib/generated"
}

model User {
  id Int @id
}
''');

        const workflow = SchemaWorkflow();
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);
        final generator = workflow.resolveGenerator(loaded);

        expect(
          generator.outputPath,
          File(
            '${tempRoot.path}${Platform.pathSeparator}lib${Platform.pathSeparator}generated${Platform.pathSeparator}comon_orm_client.dart',
          ).path,
        );
        expect(generator.sqliteHelper, isNull);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('resolves explicit sqlite helper target from generator config', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
generator client {
  provider = "comon_orm"
  output = "lib/generated"
  sqliteHelper = "flutter"
}

model User {
  id Int @id
}
''');

        const workflow = SchemaWorkflow();
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);
        final generator = workflow.resolveGenerator(loaded);

        expect(generator.sqliteHelper, 'flutter');
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('rejects unsupported sqlite helper target', () {
      const workflow = SchemaWorkflow();
      final loaded = workflow.loadValidatedSchemaSource(
        source: '''
generator client {
  provider = "comon_orm"
  sqliteHelper = "desktop"
}

model User {
  id Int @id
}
''',
        filePath: '/virtual/project/prisma/schema.prisma',
      );

      expect(
        () => workflow.resolveGenerator(loaded),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('unsupported sqliteHelper'),
          ),
        ),
      );
    });

    test('resolves postgres datasource url from environment', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
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

        const workflow = SchemaWorkflow(
          environment: <String, String>{
            'DATABASE_URL': 'postgresql://localhost:5432/app',
          },
        );
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);
        final datasource = workflow.resolveDatasource(
          loaded,
          expectedProvider: 'postgresql',
        );

        expect(datasource.url, 'postgresql://localhost:5432/app');
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('validates source text without relying on filesystem reads', () {
      const workflow = SchemaWorkflow();
      final loaded = workflow.loadValidatedSchemaSource(
        source: '''
generator client {
  provider = "comon_orm"
  output = "lib/generated"
}

model User {
  id Int @id
}
''',
        filePath: '/virtual/project/prisma/schema.prisma',
      );
      final generator = workflow.resolveGenerator(loaded);

      expect(loaded.filePath, '/virtual/project/prisma/schema.prisma');
      expect(
        generator.outputPath,
        '/virtual/project/prisma/lib/generated/comon_orm_client.dart',
      );
    });

    test('resolves sqlite datasource file path relative to schema file', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
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

        const workflow = SchemaWorkflow();
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);
        final datasource = workflow.resolveDatasource(
          loaded,
          expectedProvider: 'sqlite',
        );

        expect(
          datasource.url,
          File('${tempRoot.path}${Platform.pathSeparator}dev.db').path,
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('preserves absolute sqlite datasource file paths', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        final databasePath = '${tempRoot.path}${Platform.pathSeparator}app.db';
        final normalizedDatabasePath = databasePath.replaceAll(r'\\', '/');
        File(schemaPath).writeAsStringSync('''
datasource db {
  provider = "sqlite"
  url = "$normalizedDatabasePath"
}

model User {
  id Int @id
}
''');

        const workflow = SchemaWorkflow();
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);
        final datasource = workflow.resolveDatasource(
          loaded,
          expectedProvider: 'sqlite',
        );

        expect(datasource.url, databasePath);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('reports missing env variables in datasource config', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
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

        const workflow = SchemaWorkflow(environment: <String, String>{});
        final loaded = workflow.loadValidatedSchemaSync(schemaPath);

        expect(
          () => workflow.resolveDatasource(
            loaded,
            expectedProvider: 'postgresql',
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('DATABASE_URL'),
            ),
          ),
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('attaches source file and line to validation issues', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model Post {
  id Int @id
  author Userz
}
''');

        const workflow = SchemaWorkflow();

        expect(
          () => workflow.loadValidatedSchemaSync(schemaPath),
          throwsA(
            isA<SchemaValidationException>().having(
              (error) {
                final issue = error.issues.singleWhere(
                  (value) => value.message.contains('Unknown relation target'),
                );
                return (
                  issue.filePath,
                  issue.line,
                  issue.column,
                  issue.fieldName,
                );
              },
              'issue tuple',
              (File(schemaPath).absolute.path, 3, 3, 'author'),
            ),
          ),
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('formats schema files into canonical source order and spacing', () {
      final tempRoot = Directory.systemTemp.createTempSync(
        'comon_orm_workflow_',
      );
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model User {
  id Int @id
  email String @unique
}
''');

        const workflow = SchemaWorkflow();
        final formatted = workflow.formatSchemaSync(schemaPath);

        expect(formatted, '''model User {
  id Int @id
  email String @unique
}
''');
        expect(File(schemaPath).readAsStringSync(), formatted);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });
  });
}
