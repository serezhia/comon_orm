import 'package:comon_orm/src/migrations/migration_artifacts_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('migration_artifacts_web', () {
    test('computes stable checksums without filesystem access', () {
      final checksum = web.computeMigrationChecksum(
        provider: 'sqlite',
        beforeSchema: 'model User {\n  id Int @id\n}\n',
        afterSchema: 'model User {\n  id Int @id\n  name String\n}\n',
        migrationSql: 'ALTER TABLE "User" ADD COLUMN "name" TEXT;\n',
        warnings: const <String>['review required'],
        requiresRebuild: false,
      );

      expect(
        checksum,
        web.computeMigrationChecksum(
          provider: 'sqlite',
          beforeSchema: 'model User {\n  id Int @id\n}\n',
          afterSchema: 'model User {\n  id Int @id\n  name String\n}\n',
          migrationSql: 'ALTER TABLE "User" ADD COLUMN "name" TEXT;\n',
          warnings: const <String>['review required'],
          requiresRebuild: false,
        ),
      );
    });

    test('reports file-backed artifact loading as unsupported on web', () {
      expect(
        () => web.loadLocalMigrationArtifacts(
          'prisma/migrations',
          provider: 'sqlite',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
