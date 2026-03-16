import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('GeneratedRuntimeSchema', () {
    const schema = GeneratedRuntimeSchema(
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
            <String>['email', 'tenantId'],
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
                storageKind:
                    GeneratedRuntimeRelationStorageKind.implicitManyToMany,
                localFields: <String>['id'],
                targetFields: <String>['id'],
                relationName: 'UserPosts',
                inverseField: 'users',
                storageTableName: '_comon_orm_m2m__User__posts__Post__users',
                sourceJoinColumns: <String>['User_posts_id'],
                targetJoinColumns: <String>['Post_users_id'],
              ),
            ),
          ],
        ),
      ],
    );

    test('finds models enums and datasources by name', () {
      expect(schema.findModel('User')?.databaseName, 'users');
      expect(schema.findEnum('UserRole')?.databaseName, 'user_role');
      expect(schema.findEnumByDatabaseName('user_role')?.name, 'UserRole');
      expect(schema.findDatasource('db')?.provider, 'sqlite');
    });

    test('finds fields by logical and database names', () {
      final model = schema.findModel('User');

      expect(model?.findField('posts')?.relation?.inverseField, 'users');
      expect(model?.findFieldByDatabaseName('role')?.type, 'UserRole');
    });

    test('preserves relation and unique metadata', () {
      final model = schema.findModel('User');
      final relation = model?.findField('posts')?.relation;

      expect(model?.primaryKeyFields, const <String>['id']);
      expect(model?.compoundUniqueFieldSets, const <List<String>>[
        <String>['email', 'tenantId'],
      ]);
      expect(
        relation?.storageKind,
        GeneratedRuntimeRelationStorageKind.implicitManyToMany,
      );
      expect(relation?.storageTableName, isNotNull);
      expect(relation?.sourceJoinColumns, const <String>['User_posts_id']);
    });
  });
}
