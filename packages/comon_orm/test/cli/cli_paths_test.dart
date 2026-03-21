import 'dart:io';

import 'package:comon_orm/src/cli/cli_paths.dart';
import 'package:test/test.dart';

void main() {
  group('cli_paths', () {
    test('discovers prisma/schema.prisma before schema.prisma', () {
      final tempRoot = Directory.systemTemp.createTempSync('comon_orm_paths_');
      final previousCurrent = Directory.current;
      try {
        final prismaDir = Directory(
          '${tempRoot.path}${Platform.pathSeparator}prisma',
        )..createSync(recursive: true);
        File(
          '${prismaDir.path}${Platform.pathSeparator}schema.prisma',
        ).writeAsStringSync('model User {\n  id Int @id\n}\n');
        File(
          '${tempRoot.path}${Platform.pathSeparator}schema.prisma',
        ).writeAsStringSync('model Post {\n  id Int @id\n}\n');

        Directory.current = tempRoot;
        final expectedSchemaPath = File('prisma/schema.prisma').absolute.path;

        expect(discoverSchemaPath(), expectedSchemaPath);
      } finally {
        Directory.current = previousCurrent;
        tempRoot.deleteSync(recursive: true);
      }
    });

    test(
      'builds default migrations directory next to discovered prisma schema',
      () {
        final schemaPath = '/tmp/project/prisma/schema.prisma'.replaceAll(
          '/',
          Platform.pathSeparator,
        );

        expect(
          defaultMigrationsDirectory(schemaPath),
          '/tmp/project/prisma/migrations'.replaceAll(
            '/',
            Platform.pathSeparator,
          ),
        );
      },
    );

    test(
      'builds default migrations directory under prisma for root schema',
      () {
        final schemaPath = '/tmp/project/schema.prisma'.replaceAll(
          '/',
          Platform.pathSeparator,
        );

        expect(
          defaultMigrationsDirectory(schemaPath),
          '/tmp/project/prisma/migrations'.replaceAll(
            '/',
            Platform.pathSeparator,
          ),
        );
      },
    );
  });
}
