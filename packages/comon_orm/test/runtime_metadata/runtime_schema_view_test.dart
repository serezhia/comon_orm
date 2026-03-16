import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

import '../generated/comon_orm_client.dart' as generated_fixture;
import '../generated/runtime_compound_direct_client.dart'
    as generated_compound_fixture;
import '../generated/runtime_rich_parity_client.dart' as generated_rich_fixture;

void main() {
  group('RuntimeSchemaView', () {
    test('AST-backed and generated-backed views stay aligned', () {
      final astSchema = const SchemaParser().parse('''
datasource db {
  provider = "sqlite"
  url = env("DATABASE_URL")
}

enum UserRole {
  admin
  member

  @@map("user_role")
}

model User {
  id Int @id @default(autoincrement())
  email String @unique @map("email_address")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  role UserRole
  posts Post[]
  groups Group[]

  @@unique([email, role])
  @@map("users")
}

model Post {
  id Int @id
  authorId Int @map("author_id")
  author User @relation("UserPosts", fields: [authorId], references: [id])

  @@map("posts")
}

model Group {
  id Int @id
  users User[]

  @@map("groups")
}
''');

      const generatedSchema = GeneratedRuntimeSchema(
        datasources: <GeneratedDatasourceMetadata>[
          GeneratedDatasourceMetadata(
            name: 'db',
            provider: 'sqlite',
            url: GeneratedDatasourceUrl(
              kind: GeneratedDatasourceUrlKind.env,
              value: 'DATABASE_URL',
            ),
          ),
        ],
        enums: <GeneratedEnumMetadata>[
          GeneratedEnumMetadata(
            name: 'UserRole',
            databaseName: 'user_role',
            values: <String>['admin', 'member'],
          ),
        ],
        models: <GeneratedModelMetadata>[
          GeneratedModelMetadata(
            name: 'User',
            databaseName: 'users',
            primaryKeyFields: <String>['id'],
            compoundUniqueFieldSets: <List<String>>[
              <String>['email', 'role'],
            ],
            fields: <GeneratedFieldMetadata>[
              GeneratedFieldMetadata(
                name: 'id',
                databaseName: 'id',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Int',
                isNullable: false,
                isList: false,
                isId: true,
                defaultValue: GeneratedFieldDefaultMetadata(
                  kind: GeneratedRuntimeDefaultKind.autoincrement,
                ),
              ),
              GeneratedFieldMetadata(
                name: 'email',
                databaseName: 'email_address',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'String',
                isNullable: false,
                isList: false,
                isUnique: true,
              ),
              GeneratedFieldMetadata(
                name: 'createdAt',
                databaseName: 'createdAt',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'DateTime',
                isNullable: false,
                isList: false,
                defaultValue: GeneratedFieldDefaultMetadata(
                  kind: GeneratedRuntimeDefaultKind.now,
                ),
              ),
              GeneratedFieldMetadata(
                name: 'updatedAt',
                databaseName: 'updatedAt',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'DateTime',
                isNullable: false,
                isList: false,
                isUpdatedAt: true,
              ),
              GeneratedFieldMetadata(
                name: 'role',
                databaseName: 'role',
                kind: GeneratedRuntimeFieldKind.enumeration,
                type: 'UserRole',
                isNullable: false,
                isList: false,
              ),
              GeneratedFieldMetadata(
                name: 'posts',
                databaseName: 'posts',
                kind: GeneratedRuntimeFieldKind.relation,
                type: 'Post',
                isNullable: false,
                isList: true,
                relation: GeneratedRelationMetadata(
                  targetModel: 'Post',
                  cardinality: GeneratedRuntimeRelationCardinality.many,
                  storageKind: GeneratedRuntimeRelationStorageKind.direct,
                  localFields: <String>['id'],
                  targetFields: <String>['authorId'],
                  relationName: 'UserPosts',
                  inverseField: 'author',
                ),
              ),
              GeneratedFieldMetadata(
                name: 'groups',
                databaseName: 'groups',
                kind: GeneratedRuntimeFieldKind.relation,
                type: 'Group',
                isNullable: false,
                isList: true,
                relation: GeneratedRelationMetadata(
                  targetModel: 'Group',
                  cardinality: GeneratedRuntimeRelationCardinality.many,
                  storageKind:
                      GeneratedRuntimeRelationStorageKind.implicitManyToMany,
                  localFields: <String>['id'],
                  targetFields: <String>['id'],
                  inverseField: 'users',
                ),
              ),
            ],
          ),
          GeneratedModelMetadata(
            name: 'Post',
            databaseName: 'posts',
            primaryKeyFields: <String>['id'],
            fields: <GeneratedFieldMetadata>[
              GeneratedFieldMetadata(
                name: 'id',
                databaseName: 'id',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Int',
                isNullable: false,
                isList: false,
                isId: true,
              ),
              GeneratedFieldMetadata(
                name: 'authorId',
                databaseName: 'author_id',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Int',
                isNullable: false,
                isList: false,
              ),
              GeneratedFieldMetadata(
                name: 'author',
                databaseName: 'author',
                kind: GeneratedRuntimeFieldKind.relation,
                type: 'User',
                isNullable: false,
                isList: false,
                relation: GeneratedRelationMetadata(
                  targetModel: 'User',
                  cardinality: GeneratedRuntimeRelationCardinality.one,
                  storageKind: GeneratedRuntimeRelationStorageKind.direct,
                  localFields: <String>['authorId'],
                  targetFields: <String>['id'],
                  relationName: 'UserPosts',
                  inverseField: 'posts',
                ),
              ),
            ],
          ),
          GeneratedModelMetadata(
            name: 'Group',
            databaseName: 'groups',
            primaryKeyFields: <String>['id'],
            fields: <GeneratedFieldMetadata>[
              GeneratedFieldMetadata(
                name: 'id',
                databaseName: 'id',
                kind: GeneratedRuntimeFieldKind.scalar,
                type: 'Int',
                isNullable: false,
                isList: false,
                isId: true,
              ),
              GeneratedFieldMetadata(
                name: 'users',
                databaseName: 'users',
                kind: GeneratedRuntimeFieldKind.relation,
                type: 'User',
                isNullable: false,
                isList: true,
                relation: GeneratedRelationMetadata(
                  targetModel: 'User',
                  cardinality: GeneratedRuntimeRelationCardinality.many,
                  storageKind:
                      GeneratedRuntimeRelationStorageKind.implicitManyToMany,
                  localFields: <String>['id'],
                  targetFields: <String>['id'],
                  inverseField: 'groups',
                ),
              ),
            ],
          ),
        ],
      );

      final astView = runtimeSchemaViewFromSchemaDocument(astSchema);
      final generatedView = runtimeSchemaViewFromGeneratedSchema(
        generatedSchema,
      );

      expect(
        _snapshotRuntimeSchema(astView),
        _snapshotRuntimeSchema(generatedView),
      );
      expect(
        _snapshotImplicitStorages(astView),
        _snapshotImplicitStorages(generatedView),
      );
    });

    test('parsed fixture schema matches real generated client metadata', () {
      final source = File(
        'test/generated/_runtime_fixture_schema.prisma',
      ).readAsStringSync();
      final astSchema = const SchemaParser().parse(source);

      final astView = runtimeSchemaViewFromSchemaDocument(astSchema);
      final generatedView = runtimeSchemaViewFromGeneratedSchema(
        generated_fixture.GeneratedComonOrmClient.runtimeSchema,
      );

      expect(
        _snapshotRuntimeSchema(astView),
        _snapshotRuntimeSchema(generatedView),
      );
      expect(
        _snapshotImplicitStorages(astView),
        _snapshotImplicitStorages(generatedView),
      );
    });

    test(
      'rich parsed fixture schema matches real generated client metadata',
      () {
        final source = File(
          'test/generated/_runtime_rich_parity_schema.prisma',
        ).readAsStringSync();
        final astSchema = const SchemaParser().parse(source);

        final astView = runtimeSchemaViewFromSchemaDocument(astSchema);
        final generatedView = runtimeSchemaViewFromGeneratedSchema(
          generated_rich_fixture.GeneratedComonOrmClient.runtimeSchema,
        );

        expect(
          _snapshotRuntimeSchema(astView),
          _snapshotRuntimeSchema(generatedView),
        );
        expect(
          _snapshotImplicitStorages(astView),
          _snapshotImplicitStorages(generatedView),
        );
      },
    );

    test(
      'compound direct parsed fixture schema matches real generated client metadata',
      () {
        final source = File(
          'test/generated/_runtime_compound_direct_schema.prisma',
        ).readAsStringSync();
        final astSchema = const SchemaParser().parse(source);

        final astView = runtimeSchemaViewFromSchemaDocument(astSchema);
        final generatedView = runtimeSchemaViewFromGeneratedSchema(
          generated_compound_fixture.GeneratedComonOrmClient.runtimeSchema,
        );

        expect(
          _snapshotRuntimeSchema(astView),
          _snapshotRuntimeSchema(generatedView),
        );
        expect(
          _snapshotImplicitStorages(astView),
          _snapshotImplicitStorages(generatedView),
        );
      },
    );
  });
}

Map<String, Object?> _snapshotRuntimeSchema(RuntimeSchemaView schema) {
  return <String, Object?>{
    'datasources': schema.datasources
        .map(
          (datasource) => <String, Object?>{
            'name': datasource.name,
            'provider': datasource.provider,
            'urlKind': datasource.url.kind.name,
            'urlValue': datasource.url.value,
          },
        )
        .toList(growable: false),
    'enums': schema.enums
        .map(
          (definition) => <String, Object?>{
            'name': definition.name,
            'databaseName': definition.databaseName,
            'values': definition.values,
          },
        )
        .toList(growable: false),
    'models': schema.models
        .map(
          (model) => <String, Object?>{
            'name': model.name,
            'databaseName': model.databaseName,
            'primaryKeyFields': model.primaryKeyFields,
            'compoundUniqueFieldSets': model.compoundUniqueFieldSets,
            'fields': model.fields
                .map(
                  (field) => <String, Object?>{
                    'name': field.name,
                    'databaseName': field.databaseName,
                    'kind': field.kind.name,
                    'type': field.type,
                    'isNullable': field.isNullable,
                    'isList': field.isList,
                    'isId': field.isId,
                    'isUnique': field.isUnique,
                    'isUpdatedAt': field.isUpdatedAt,
                    'nativeType': field.nativeType,
                    'default': field.defaultValue == null
                        ? null
                        : <String, Object?>{
                            'kind': field.defaultValue!.kind.name,
                            'value': field.defaultValue!.value,
                          },
                    'relation': field.relation == null
                        ? null
                        : <String, Object?>{
                            'targetModel': field.relation!.targetModel,
                            'cardinality': field.relation!.cardinality.name,
                            'storageKind': field.relation!.storageKind.name,
                            'localFields': field.relation!.localFields,
                            'targetFields': field.relation!.targetFields,
                            'relationName': field.relation!.relationName,
                            'inverseField': field.relation!.inverseField,
                          },
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false),
  };
}

List<Map<String, Object?>> _snapshotImplicitStorages(RuntimeSchemaView schema) {
  return collectRuntimeImplicitManyToManyStorages(schema)
      .map(
        (storage) => <String, Object?>{
          'tableName': storage.tableName,
          'sourceModel': storage.sourceModel,
          'sourceField': storage.sourceField,
          'sourceKeyFields': storage.sourceKeyFields,
          'sourceJoinColumns': storage.sourceJoinColumns,
          'targetModel': storage.targetModel,
          'targetField': storage.targetField,
          'targetKeyFields': storage.targetKeyFields,
          'targetJoinColumns': storage.targetJoinColumns,
        },
      )
      .toList(growable: false);
}
