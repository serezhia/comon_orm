import 'dart:io';

import 'package:comon_orm/src/cli/schema_cli.dart';
import 'package:test/test.dart';

void main() {
  group('ComonOrmCli', () {
    test('check prints success for a valid schema', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
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
        final cli = ComonOrmCli(out: out, err: err);

        final exitCode = await cli.run(<String>['check', schemaPath]);

        expect(exitCode, 0);
        expect(out.toString(), contains('Schema is valid.'));
        expect(err.toString(), isEmpty);
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('check prints line and column for validation errors', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model Post {
  id Int @id
  author Userz
}
''');

        final out = StringBuffer();
        final err = StringBuffer();
        final cli = ComonOrmCli(out: out, err: err);

        final exitCode = await cli.run(<String>['check', schemaPath]);

        expect(exitCode, 1);
        expect(out.toString(), isEmpty);
        expect(
          err.toString(),
          contains('${File(schemaPath).absolute.path}:3:3'),
        );
        expect(
          err.toString(),
          contains('Unknown relation target model "Userz"'),
        );
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });

    test('format rewrites schema files into canonical formatting', () async {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_cli_');
      try {
        final schemaPath =
            '${tempRoot.path}${Platform.pathSeparator}schema.prisma';
        File(schemaPath).writeAsStringSync('''
model User {
  id Int @id
  email String @unique
}
''');

        final out = StringBuffer();
        final err = StringBuffer();
        final cli = ComonOrmCli(out: out, err: err);

        final exitCode = await cli.run(<String>['format', schemaPath]);

        expect(exitCode, 0);
        expect(out.toString(), contains('Formatted schema:'));
        expect(err.toString(), isEmpty);
        expect(File(schemaPath).readAsStringSync(), '''model User {
  id Int @id
  email String @unique
}
''');
      } finally {
        tempRoot.deleteSync(recursive: true);
      }
    });
  });
}
