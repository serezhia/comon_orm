import 'dart:convert';
import 'dart:typed_data';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

const GeneratedRuntimeSchema _generatedSchema = GeneratedRuntimeSchema(
  enums: <GeneratedEnumMetadata>[
    GeneratedEnumMetadata(
      name: 'UserRole',
      databaseName: 'UserRole',
      values: <String>['admin', 'developer', 'manager'],
    ),
  ],
  models: <GeneratedModelMetadata>[
    GeneratedModelMetadata(
      name: 'User',
      databaseName: 'User',
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
          name: 'name',
          databaseName: 'name',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'String',
          isNullable: false,
          isList: false,
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
          name: 'email',
          databaseName: 'email',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'String',
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
            targetFields: <String>['userId'],
            inverseField: 'user',
          ),
        ),
      ],
    ),
    GeneratedModelMetadata(
      name: 'Post',
      databaseName: 'Post',
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
          name: 'title',
          databaseName: 'title',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'String',
          isNullable: false,
          isList: false,
        ),
        GeneratedFieldMetadata(
          name: 'userId',
          databaseName: 'userId',
          kind: GeneratedRuntimeFieldKind.scalar,
          type: 'Int',
          isNullable: false,
          isList: false,
        ),
        GeneratedFieldMetadata(
          name: 'user',
          databaseName: 'user',
          kind: GeneratedRuntimeFieldKind.relation,
          type: 'User',
          isNullable: false,
          isList: false,
          relation: GeneratedRelationMetadata(
            targetModel: 'User',
            cardinality: GeneratedRuntimeRelationCardinality.one,
            storageKind: GeneratedRuntimeRelationStorageKind.direct,
            localFields: <String>['userId'],
            targetFields: <String>['id'],
            inverseField: 'posts',
          ),
        ),
      ],
    ),
  ],
);

void main() {
  group('PostgresqlDatabaseAdapter', () {
    late _ScriptedExecutor executor;
    late PostgresqlDatabaseAdapter adapter;

    setUp(() {
      executor = _ScriptedExecutor();
      adapter = PostgresqlDatabaseAdapter.fromGeneratedSchema(
        executor: executor,
        schema: _generatedSchema,
      );
    });

    test('builds count query with postgres aliases', () async {
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{'count': 3},
      ]);

      final count = await adapter.count(
        const CountQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(field: 'name', operator: 'equals', value: 'Alice'),
          ],
        ),
      );

      expect(count, 3);
      expect(
        executor.queries.single.sql,
        contains('SELECT COUNT(*) AS "count"'),
      );
      expect(
        executor.queries.single.sql,
        contains('WHERE ("t0"."name" = \$1)'),
      );
      expect(executor.queries.single.parameters, <Object?>['Alice']);
    });

    test('builds SQL pushdown for aggregate query', () async {
      final aggregateSchema = const SchemaParser().parse('''
model User {
  id           Int    @id
  name         String
  email        String
  country      String?
  profileViews Int?
}
''');
      final aggregateAdapter = PostgresqlDatabaseAdapter(
        executor: executor,
        schema: aggregateSchema,
      );

      // Pushdown returns ONE aggregated row, not raw rows.
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '_count__all': 3,
          '_count_profileViews': 3,
          '_avg_profileViews': 35 / 3,
          '_sum_profileViews': 35.0,
          '_min_profileViews': 5,
          '_max_profileViews': 20,
        },
      ]);

      final aggregate = await aggregateAdapter.aggregate(
        const AggregateQuery(
          model: 'User',
          orderBy: <QueryOrderBy>[
            QueryOrderBy(field: 'profileViews', direction: SortOrder.desc),
          ],
          skip: 0,
          take: 3,
          count: QueryCountSelection(
            all: true,
            fields: <String>{'profileViews'},
          ),
          avg: <String>{'profileViews'},
          sum: <String>{'profileViews'},
          min: <String>{'profileViews'},
          max: <String>{'profileViews'},
        ),
      );

      expect(aggregate.count!.all, 3);
      expect(aggregate.count!.fields['profileViews'], 3);
      expect(aggregate.avg!['profileViews'], closeTo(35 / 3, 0.001));
      expect(aggregate.sum!['profileViews'], 35.0);
      expect(aggregate.min!['profileViews'], 5);
      expect(aggregate.max!['profileViews'], 20);

      // SQL must be a CTE window query.
      final sql = executor.queries.single.sql;
      expect(sql, contains('WITH "_agg" AS'));
      expect(sql, contains('ORDER BY "t0"."profileViews" DESC'));
      expect(sql, contains('LIMIT'));
      expect(sql, contains('OFFSET'));
      expect(sql, contains('COUNT(*)'));
      expect(sql, contains('AVG'));
    });

    test('builds SQL pushdown for groupBy query', () async {
      final aggregateSchema = const SchemaParser().parse('''
model User {
  id           Int    @id
  name         String
  email        String
  country      String?
  profileViews Int?
}
''');
      final aggregateAdapter = PostgresqlDatabaseAdapter(
        executor: executor,
        schema: aggregateSchema,
      );

      // Pushdown returns one row per group with aggregate columns.
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          'country': 'US',
          '_count__all': 2,
          '_avg_profileViews': 15.0,
          '_sum_profileViews': 30.0,
        },
        <String, Object?>{
          'country': 'FR',
          '_count__all': 2,
          '_avg_profileViews': 10.0,
          '_sum_profileViews': 20.0,
        },
      ]);

      final grouped = await aggregateAdapter.groupBy(
        const GroupByQuery(
          model: 'User',
          by: <String>['country'],
          having: <QueryAggregatePredicate>[
            QueryAggregatePredicate(
              field: 'profileViews',
              function: QueryAggregateFunction.avg,
              operator: 'gte',
              value: 10,
            ),
          ],
          orderBy: <GroupByOrderBy>[
            GroupByOrderBy.aggregate(
              aggregate: QueryAggregateFunction.avg,
              field: 'profileViews',
              direction: SortOrder.desc,
            ),
          ],
          count: QueryCountSelection(all: true),
          avg: <String>{'profileViews'},
          sum: <String>{'profileViews'},
        ),
      );

      expect(grouped, hasLength(2));
      expect(grouped.first.group['country'], 'US');
      expect(grouped.first.aggregates.count!.all, 2);
      expect(grouped.first.aggregates.avg!['profileViews'], 15.0);
      expect(grouped.last.group['country'], 'FR');
      expect(grouped.last.aggregates.avg!['profileViews'], 10.0);

      final sql = executor.queries.single.sql;
      expect(sql, contains('GROUP BY'));
      expect(sql, contains('HAVING'));
      expect(sql, contains('AVG'));
      expect(sql, contains('ORDER BY'));
    });

    test('builds notIn and case-insensitive predicates in WHERE', () async {
      executor.queryResponses.add(const <Map<String, Object?>>[]); // notIn
      executor.queryResponses.add(
        const <Map<String, Object?>>[],
      ); // ILIKE contains
      executor.queryResponses.add(
        const <Map<String, Object?>>[],
      ); // ILIKE startsWith
      executor.queryResponses.add(
        const <Map<String, Object?>>[],
      ); // ILIKE endsWith

      // NOT IN
      await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'name',
              operator: 'notIn',
              value: <Object?>['Alice', 'Bob'],
            ),
          ],
        ),
      );

      expect(
        executor.queries.last.sql,
        contains('"t0"."name" NOT IN (\$1, \$2)'),
      );
      expect(executor.queries.last.parameters, <Object?>['Alice', 'Bob']);

      // ILIKE contains
      await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'name',
              operator: 'containsInsensitive',
              value: 'alice',
            ),
          ],
        ),
      );

      expect(executor.queries.last.sql, contains('ILIKE'));
      expect(executor.queries.last.parameters, <Object?>['%alice%']);

      // ILIKE startsWith
      await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'name',
              operator: 'startsWithInsensitive',
              value: 'ali',
            ),
          ],
        ),
      );

      expect(executor.queries.last.sql, contains('ILIKE'));
      expect(executor.queries.last.parameters, <Object?>['ali%']);

      // ILIKE endsWith
      await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(
              field: 'name',
              operator: 'endsWithInsensitive',
              value: 'ice',
            ),
          ],
        ),
      );

      expect(executor.queries.last.sql, contains('ILIKE'));
      expect(executor.queries.last.parameters, <Object?>['%ice']);
    });

    test('pushes cursor pagination into SQL for findMany', () async {
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,2)',
          'id': 2,
          'name': 'Bob',
          'email': 'b@x.dev',
          'role': 'developer',
        },
      ]);
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,3)',
          'id': 3,
          'name': 'Charlie',
          'email': 'c@x.dev',
          'role': 'manager',
        },
      ]);

      final rows = await adapter.findMany(
        const FindManyQuery(
          model: 'User',
          cursor: QueryCursor(
            where: <QueryPredicate>[
              QueryPredicate(
                field: 'email',
                operator: 'equals',
                value: 'b@x.dev',
              ),
            ],
          ),
          orderBy: <QueryOrderBy>[
            QueryOrderBy(field: 'name', direction: SortOrder.asc),
          ],
          skip: 1,
          take: 1,
        ),
      );

      expect(rows, hasLength(1));
      expect(rows.single['name'], 'Charlie');
      expect(executor.queries, hasLength(2));
      expect(executor.queries.first.sql, contains('WHERE ("t0"."email" = \$1)'));
      expect(executor.queries.first.sql, contains('LIMIT \$2'));
      expect(executor.queries.first.parameters, <Object?>['b@x.dev', 1]);
      expect(executor.queries.last.sql, contains('ORDER BY "t0"."name" ASC'));
      expect(executor.queries.last.sql, contains('("t0"."name" > \$1)'));
      expect(executor.queries.last.sql, contains('LIMIT \$3'));
      expect(executor.queries.last.sql, contains('OFFSET \$4'));
      expect(executor.queries.last.parameters, <Object?>['Bob', 'Bob', 1, 1]);
    });

    test('materializes include by issuing relation query', () async {
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,1)',
          'id': 1,
          'name': 'Alice',
          'email': 'a@x.dev',
        },
      ]);
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,2)',
          'id': 10,
          'title': 'Hello',
          'userId': 1,
        },
      ]);

      final rows = await adapter.findMany(
        FindManyQuery(
          model: 'User',
          include: QueryInclude(<String, QueryIncludeEntry>{
            'posts': QueryIncludeEntry(
              relation: const QueryRelation(
                field: 'posts',
                targetModel: 'Post',
                cardinality: QueryRelationCardinality.many,
                localKeyField: 'id',
                targetKeyField: 'userId',
              ),
            ),
          }),
        ),
      );

      expect(rows, hasLength(1));
      expect(rows.single['posts'], hasLength(1));
      expect(executor.queries, hasLength(2));
      expect(executor.queries.last.sql, contains('FROM "Post" AS "t0"'));
      expect(executor.queries.last.parameters, <Object?>[1]);
    });

    test('delegates transactions to executor', () async {
      executor.queryResponses.add(const <Map<String, Object?>>[
        <String, Object?>{'id': 1, 'name': 'Alice', 'email': 'alice@x.dev'},
      ]);

      final created = await adapter.transaction((tx) {
        return tx.create(
          const CreateQuery(
            model: 'User',
            data: <String, Object?>{
              'id': 1,
              'name': 'Alice',
              'email': 'alice@x.dev',
            },
          ),
        );
      });

      expect(created['name'], 'Alice');
      expect(executor.transactionCount, 1);
      expect(executor.queries.single.sql, contains('INSERT INTO "User"'));
      expect(executor.queries.single.sql, contains('RETURNING *'));
    });

    test('uses transaction scoped executor for writes', () async {
      final transactionExecutor = _TransactionAwareExecutor();
      final transactionAdapter = PostgresqlDatabaseAdapter(
        executor: transactionExecutor,
        schema: const SchemaParser().parse('''
model User {
  id Int @id
  name String
}
'''),
      );

      transactionExecutor.nestedQueryResponses.add(<Map<String, Object?>>[
        <String, Object?>{'id': 1, 'name': 'Alice'},
      ]);
      transactionExecutor.nestedQueryResponses.add(<Map<String, Object?>>[
        <String, Object?>{'id': 1, 'name': 'Alice'},
      ]);

      final created = await transactionAdapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{'id': 1, 'name': 'Alice'},
        ),
      );

      expect(created['name'], 'Alice');
      expect(transactionExecutor.outerQueryCount, 0);
      expect(transactionExecutor.nestedQueryCount, 1);
      expect(transactionExecutor.transactionCount, 1);
    });

    test('decodes enum-backed values returned as UndecodedBytes', () async {
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,3)',
          'id': 1,
          'name': 'Alice',
          'role': pg.UndecodedBytes(
            typeOid: 999999,
            isBinary: false,
            bytes: Uint8List.fromList(utf8.encode('manager')),
            encoding: utf8,
          ),
          'email': 'alice@x.dev',
        },
      ]);

      final row = await adapter.findUnique(
        const FindUniqueQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(field: 'id', operator: 'equals', value: 1),
          ],
        ),
      );

      expect(row, isNotNull);
      expect(row!['role'], 'manager');
    });

    test('auto-populates and refreshes updatedAt fields', () async {
      final createdAt = DateTime.utc(2026, 3, 14, 9, 0, 0);
      final changedAt = DateTime.utc(2026, 3, 14, 9, 5, 0);

      final timestampAdapter = PostgresqlDatabaseAdapter.fromGeneratedSchema(
        executor: executor,
        schema: const GeneratedRuntimeSchema(
          models: <GeneratedModelMetadata>[
            GeneratedModelMetadata(
              name: 'User',
              databaseName: 'User',
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
                  name: 'name',
                  databaseName: 'name',
                  kind: GeneratedRuntimeFieldKind.scalar,
                  type: 'String',
                  isNullable: false,
                  isList: false,
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
              ],
            ),
          ],
        ),
      )..now = () => createdAt;

      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{'id': 1, 'name': 'Alice', 'updatedAt': createdAt},
      ]);

      final created = await timestampAdapter.create(
        const CreateQuery(
          model: 'User',
          data: <String, Object?>{'id': 1, 'name': 'Alice'},
        ),
      );

      expect(created['updatedAt'], createdAt);
      expect(executor.queries.last.sql, contains('INSERT INTO "User"'));
      expect(executor.queries.last.parameters, contains(createdAt));

      timestampAdapter.now = () => changedAt;
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,4)',
          'id': 1,
          'name': 'Alice',
          'updatedAt': createdAt,
        },
      ]);
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,5)',
          'id': 1,
          'name': 'Alice Updated',
          'updatedAt': changedAt,
        },
      ]);
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          'id': 1,
          'name': 'Alice Updated',
          'updatedAt': changedAt,
        },
      ]);

      final updated = await timestampAdapter.update(
        const UpdateQuery(
          model: 'User',
          where: <QueryPredicate>[
            QueryPredicate(field: 'id', operator: 'equals', value: 1),
          ],
          data: <String, Object?>{'name': 'Alice Updated'},
        ),
      );

      expect(updated['updatedAt'], changedAt);
      expect(
        executor.queries.any(
          (query) =>
              query.sql.contains('SET "name" =') &&
              query.parameters.contains(changedAt),
        ),
        isTrue,
      );
    });

    test('updates and deletes rows selected by compound predicates', () async {
      final membershipAdapter = PostgresqlDatabaseAdapter.fromGeneratedSchema(
        executor: executor,
        schema: const GeneratedRuntimeSchema(
          models: <GeneratedModelMetadata>[
            GeneratedModelMetadata(
              name: 'Membership',
              databaseName: 'Membership',
              primaryKeyFields: <String>['tenantId', 'slug'],
              fields: <GeneratedFieldMetadata>[
                GeneratedFieldMetadata(
                  name: 'tenantId',
                  databaseName: 'tenantId',
                  kind: GeneratedRuntimeFieldKind.scalar,
                  type: 'Int',
                  isNullable: false,
                  isList: false,
                  isId: true,
                ),
                GeneratedFieldMetadata(
                  name: 'slug',
                  databaseName: 'slug',
                  kind: GeneratedRuntimeFieldKind.scalar,
                  type: 'String',
                  isNullable: false,
                  isList: false,
                  isId: true,
                ),
                GeneratedFieldMetadata(
                  name: 'role',
                  databaseName: 'role',
                  kind: GeneratedRuntimeFieldKind.scalar,
                  type: 'String',
                  isNullable: false,
                  isList: false,
                ),
              ],
            ),
          ],
        ),
      );

      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,1)',
          'tenantId': 1,
          'slug': 'alice',
          'role': 'member',
        },
      ]);
      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,2)',
          'tenantId': 1,
          'slug': 'alice',
          'role': 'owner',
        },
      ]);

      final updated = await membershipAdapter.update(
        const UpdateQuery(
          model: 'Membership',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
            QueryPredicate(field: 'slug', operator: 'equals', value: 'alice'),
          ],
          data: <String, Object?>{'role': 'owner'},
        ),
      );

      expect(updated['role'], 'owner');
      expect(
        executor.queries.any(
          (query) =>
              query.sql.contains('WHERE ctid =') &&
              query.parameters.contains('(0,1)'),
        ),
        isTrue,
      );

      executor.queryResponses.add(<Map<String, Object?>>[
        <String, Object?>{
          '__ctid__': '(0,3)',
          'tenantId': 1,
          'slug': 'bob',
          'role': 'member',
        },
      ]);

      final deleted = await membershipAdapter.delete(
        const DeleteQuery(
          model: 'Membership',
          where: <QueryPredicate>[
            QueryPredicate(field: 'tenantId', operator: 'equals', value: 1),
            QueryPredicate(field: 'slug', operator: 'equals', value: 'bob'),
          ],
        ),
      );

      expect(deleted['slug'], 'bob');
      expect(
        executor.queries.any(
          (query) =>
              query.sql.contains('DELETE FROM "Membership"') &&
              query.parameters.contains('(0,3)'),
        ),
        isTrue,
      );
    });
  });
}

class _RecordedQuery {
  const _RecordedQuery(this.sql, this.parameters);

  final String sql;
  final List<Object?> parameters;
}

class _ScriptedExecutor implements PostgresqlQueryExecutor {
  final List<List<Map<String, Object?>>> queryResponses =
      <List<Map<String, Object?>>>[];
  final List<_RecordedQuery> queries = <_RecordedQuery>[];
  int transactionCount = 0;

  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    queries.add(_RecordedQuery(sql, List<Object?>.from(parameters)));
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    queries.add(_RecordedQuery(sql, List<Object?>.from(parameters)));
    if (queryResponses.isEmpty) {
      return const <Map<String, Object?>>[];
    }
    return queryResponses.removeAt(0);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) {
    transactionCount++;
    return action(_NestedTransactionExecutor(this));
  }
}

class _NestedTransactionExecutor implements PostgresqlQueryExecutor {
  const _NestedTransactionExecutor(this._delegate);

  final _ScriptedExecutor _delegate;

  @override
  Future<void> close() => _delegate.close();

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) {
    return _delegate.execute(sql, parameters: parameters);
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) {
    return _delegate.query(sql, parameters: parameters);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) {
    return action(this);
  }
}

class _TransactionAwareExecutor implements PostgresqlQueryExecutor {
  final List<List<Map<String, Object?>>> nestedQueryResponses =
      <List<Map<String, Object?>>>[];
  int transactionCount = 0;
  int outerQueryCount = 0;
  int nestedQueryCount = 0;
  bool _insideTransaction = false;

  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    if (!_insideTransaction) {
      throw StateError('Write escaped the transaction scoped executor.');
    }
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    if (_insideTransaction) {
      outerQueryCount++;
      throw StateError('Query escaped the transaction scoped executor.');
    }
    outerQueryCount++;
    return const <Map<String, Object?>>[];
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) async {
    transactionCount++;
    _insideTransaction = true;
    try {
      return await action(_TransactionAwareNestedExecutor(this));
    } finally {
      _insideTransaction = false;
    }
  }
}

class _TransactionAwareNestedExecutor implements PostgresqlQueryExecutor {
  const _TransactionAwareNestedExecutor(this._delegate);

  final _TransactionAwareExecutor _delegate;

  @override
  Future<void> close() async {}

  @override
  Future<int> execute(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    return 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String sql, {
    List<Object?> parameters = const <Object?>[],
  }) async {
    _delegate.nestedQueryCount++;
    if (_delegate.nestedQueryResponses.isEmpty) {
      return const <Map<String, Object?>>[];
    }
    return _delegate.nestedQueryResponses.removeAt(0);
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(PostgresqlQueryExecutor tx) action,
  ) {
    return action(this);
  }
}
