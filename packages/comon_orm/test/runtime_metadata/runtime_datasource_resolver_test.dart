import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('RuntimeDatasourceResolver', () {
    test('resolves sqlite relative paths from generated metadata', () {
      const schema = GeneratedRuntimeSchema(
        models: <GeneratedModelMetadata>[],
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'sqlite',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.literal,
              value: 'file:dev.db',
            ),
          ),
        ],
      );

      final resolved = const RuntimeDatasourceResolver()
          .resolveGeneratedDatasource(
            schema: schema,
            expectedProvider: 'sqlite',
            schemaPath: '/app/prisma/schema.prisma',
          );

      expect(resolved.name, 'db');
      expect(resolved.provider, 'sqlite');
      expect(resolved.url, '/app/prisma/dev.db');
    });

    test('resolves env-backed urls from runtime views', () {
      const schema = GeneratedRuntimeSchema(
        models: <GeneratedModelMetadata>[],
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'postgresql',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.env,
              value: 'DATABASE_URL',
            ),
          ),
        ],
      );

      final resolved =
          const RuntimeDatasourceResolver(
            environment: <String, String>{
              'DATABASE_URL': 'postgresql://localhost:5432/app',
            },
          ).resolveDatasource(
            schema: runtimeSchemaViewFromGeneratedSchema(schema),
            expectedProvider: 'postgresql',
          );

      expect(resolved.url, 'postgresql://localhost:5432/app');
    });
  });
}
