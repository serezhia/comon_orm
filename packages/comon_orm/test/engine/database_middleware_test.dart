import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

void main() {
  group('MiddlewareDatabaseAdapter', () {
    test(
      'wraps adapter queries and allows replacing the query payload',
      () async {
        final middleware = _RecordingMiddleware(
          before: (context) {
            if (context.operation == DatabaseMiddlewareOperation.findMany) {
              context.payload = const FindManyQuery(
                model: 'Post',
                where: <QueryPredicate>[],
              );
            }
          },
        );
        final adapter = MiddlewareDatabaseAdapter(
          adapter: _FakeDatabaseAdapter(),
          middlewares: <DatabaseMiddleware>[middleware],
        );

        final rows = await adapter.findMany(
          const FindManyQuery(model: 'User', where: <QueryPredicate>[]),
        );

        expect(rows.single['model'], 'Post');
        expect(middleware.events, <String>[
          'before:findMany:User',
          'after:findMany:true',
        ]);
      },
    );

    test(
      'wraps nested transaction adapters with the same middleware chain',
      () async {
        final middleware = _RecordingMiddleware();
        final adapter = MiddlewareDatabaseAdapter(
          adapter: _FakeDatabaseAdapter(),
          middlewares: <DatabaseMiddleware>[middleware],
        );

        final rows = await adapter.transaction((tx) {
          return tx.findMany(
            const FindManyQuery(model: 'User', where: <QueryPredicate>[]),
          );
        });

        expect(rows.single['model'], 'User');
        expect(middleware.events, <String>[
          'before:transaction:null',
          'before:findMany:User',
          'after:findMany:true',
          'after:transaction:true',
        ]);
      },
    );

    test('exposes raw SQL and parameters to middleware', () async {
      final middleware = _RecordingMiddleware(
        before: (context) {
          if (context.operation == DatabaseMiddlewareOperation.rawQuery) {
            context.sql = 'SELECT changed';
            context.parameters
              ..clear()
              ..add('patched');
          }
        },
      );
      final adapter = MiddlewareDatabaseAdapter(
        adapter: _FakeDatabaseAdapter(),
        middlewares: <DatabaseMiddleware>[middleware],
      );

      final rows = await adapter.rawQuery('SELECT original', <Object?>['keep']);

      expect(rows.single['sql'], 'SELECT changed');
      expect(rows.single['parameters'], <Object?>['patched']);
    });
  });
}

class _RecordingMiddleware implements DatabaseMiddleware {
  _RecordingMiddleware({this.before});

  final void Function(DatabaseMiddlewareContext context)? before;
  final List<String> events = <String>[];

  @override
  Future<void> beforeQuery(DatabaseMiddlewareContext context) async {
    events.add('before:${context.operation.name}:${context.model}');
    before?.call(context);
  }

  @override
  Future<void> afterQuery(DatabaseMiddlewareResult result) async {
    events.add('after:${result.context.operation.name}:${result.isSuccess}');
  }
}

class _FakeDatabaseAdapter implements DatabaseAdapter {
  @override
  Future<void> addImplicitManyToManyLink({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    required Map<String, Object?> targetKeyValues,
  }) async {}

  @override
  Future<AggregateQueryResult> aggregate(AggregateQuery query) async {
    return const AggregateQueryResult();
  }

  @override
  Future<void> close() async {}

  @override
  Future<int> count(CountQuery query) async => 0;

  @override
  Future<Map<String, Object?>> create(CreateQuery query) async =>
      <String, Object?>{'model': query.model};

  @override
  Future<int> createMany(CreateManyQuery query) async => query.data.length;

  @override
  Future<Map<String, Object?>> delete(DeleteQuery query) async =>
      <String, Object?>{'model': query.model};

  @override
  Future<int> deleteMany(DeleteManyQuery query) async => 0;

  @override
  Future<Map<String, Object?>?> findFirst(FindFirstQuery query) async =>
      <String, Object?>{'model': query.model};

  @override
  Future<List<Map<String, Object?>>> findMany(FindManyQuery query) async {
    return <Map<String, Object?>>[
      <String, Object?>{'model': query.model},
    ];
  }

  @override
  Future<Map<String, Object?>?> findUnique(FindUniqueQuery query) async =>
      <String, Object?>{'model': query.model};

  @override
  Future<List<GroupByQueryResultRow>> groupBy(GroupByQuery query) async =>
      const <GroupByQueryResultRow>[];

  @override
  Future<int> rawExecute(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) async => parameters.length;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?> parameters = const <Object?>[],
  ]) async {
    return <Map<String, Object?>>[
      <String, Object?>{'sql': sql, 'parameters': parameters},
    ];
  }

  @override
  Future<int> removeImplicitManyToManyLinks({
    required String sourceModel,
    required QueryRelation relation,
    required Map<String, Object?> sourceKeyValues,
    Map<String, Object?>? targetKeyValues,
  }) async => 0;

  @override
  Future<T> transaction<T>(Future<T> Function(DatabaseAdapter tx) action) {
    return action(this);
  }

  @override
  Future<Map<String, Object?>> update(UpdateQuery query) async =>
      <String, Object?>{'model': query.model};

  @override
  Future<int> updateMany(UpdateManyQuery query) async => 0;

  @override
  Future<Map<String, Object?>> upsert(UpsertQuery query) async =>
      <String, Object?>{'model': query.model};
}
