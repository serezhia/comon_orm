import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

// Minimal generated schema with a single "Item" model that has two scalar fields.
const _schema = GeneratedRuntimeSchema(
  datasources: <GeneratedDatasourceMetadata>[],
  enums: <GeneratedEnumMetadata>[],
  models: <GeneratedModelMetadata>[
    GeneratedModelMetadata(
      name: 'Item',
      databaseName: 'Item',
      primaryKeyFields: <String>['id'],
      compoundUniqueFieldSets: <List<String>>[],
      fields: <GeneratedFieldMetadata>[
        GeneratedFieldMetadata(
          name: 'id',
          databaseName: 'id',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'Int',
          isNullable: false,
          isList: false,
          isId: true,
          isUnique: false,
          isUpdatedAt: false,
          defaultValue: GeneratedFieldDefaultMetadata(
            kind: GeneratedRuntimeDefaultKind.autoincrement,
          ),
        ),
        GeneratedFieldMetadata(
          name: 'name',
          databaseName: 'name',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'String',
          isNullable: true,
          isList: false,
          isId: false,
          isUnique: false,
          isUpdatedAt: false,
        ),
      ],
    ),
  ],
);

void main() {
  late RuntimeSchemaView schemaView;
  late InMemoryDatabaseAdapter adapter;
  late ComonOrmClient clientWithSchema;
  late ComonOrmClient clientWithoutSchema;
  late ModelDelegate delegateWithSchema;
  late ModelDelegate delegateWithoutSchema;

  setUp(() {
    schemaView = runtimeSchemaViewFromGeneratedSchema(_schema);
    adapter = InMemoryDatabaseAdapter.fromGeneratedSchema(schema: _schema);
    clientWithSchema = ComonOrmClient(adapter: adapter, schemaView: schemaView);
    clientWithoutSchema = ComonOrmClient(adapter: adapter);
    delegateWithSchema = clientWithSchema.model('Item');
    delegateWithoutSchema = clientWithoutSchema.model('Item');
  });

  tearDown(() async => adapter.close());

  group('ModelDelegate query-time field validation', () {
    group('findMany', () {
      test('throws ArgumentError for unknown field in where predicate', () {
        expect(
          () => delegateWithSchema.findMany(
            const FindManyQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 'x'),
              ],
            ),
          ),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.invalidValue,
              'invalidValue',
              'ghost',
            ),
          ),
        );
      });

      test('passes through when predicate fields are valid', () async {
        await expectLater(
          delegateWithSchema.findMany(
            const FindManyQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'name', operator: 'equals', value: 'foo'),
              ],
            ),
          ),
          completion(isA<List<Map<String, Object?>>>()),
        );
      });

      test('skips validation when no schema view is provided', () async {
        await expectLater(
          delegateWithoutSchema.findMany(
            const FindManyQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 'x'),
              ],
            ),
          ),
          completion(isA<List<Map<String, Object?>>>()),
        );
      });
    });

    group('findUnique', () {
      test('throws ArgumentError for unknown field', () {
        expect(
          () => delegateWithSchema.findUnique(
            const FindUniqueQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 1),
              ],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('findFirst', () {
      test('throws ArgumentError for unknown field', () {
        expect(
          () => delegateWithSchema.findFirst(
            const FindFirstQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 1),
              ],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('count', () {
      test('throws ArgumentError for unknown field', () {
        expect(
          () => delegateWithSchema.count(
            const CountQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 1),
              ],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('updateMany', () {
      test('throws ArgumentError for unknown field', () {
        expect(
          () => delegateWithSchema.updateMany(
            const UpdateManyQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 1),
              ],
              data: {'name': 'updated'},
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('deleteMany', () {
      test('throws ArgumentError for unknown field', () {
        expect(
          () => delegateWithSchema.deleteMany(
            const DeleteManyQuery(
              model: 'Item',
              where: [
                QueryPredicate(field: 'ghost', operator: 'equals', value: 1),
              ],
            ),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('error message identifies the unknown field', () {
      expect(
        () => delegateWithSchema.findMany(
          const FindManyQuery(
            model: 'Item',
            where: [
              QueryPredicate(field: 'badField', operator: 'equals', value: 'x'),
            ],
          ),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('badField'),
          ),
        ),
      );
    });
  });
}
