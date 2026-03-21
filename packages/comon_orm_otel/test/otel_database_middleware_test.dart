import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_otel/comon_orm_otel.dart';
import 'package:comon_otel/comon_otel.dart' as otel;
import 'package:test/test.dart';

void main() {
  group('OtelDatabaseMiddleware', () {
    test('creates spans and metrics for successful operations', () async {
      final spanProcessor = _RecordingSpanProcessor();
      final meterProvider = otel.MeterProvider(
        resource: otel.Resource(serviceName: 'orm-test'),
        readers: const <otel.MetricReader>[],
      );
      final tracerProvider = otel.TracerProvider(
        resource: otel.Resource(serviceName: 'orm-test'),
        spanProcessors: <otel.SpanProcessor>[spanProcessor],
        sampler: const otel.AlwaysOnSampler(),
      );
      final middleware = OtelDatabaseMiddleware(
        dbSystem: 'sqlite',
        dbName: 'memory',
        tracer: tracerProvider.getTracer('comon_orm'),
        meter: meterProvider.getMeter('comon_orm'),
      );
      final adapter = MiddlewareDatabaseAdapter(
        adapter: _FakeDatabaseAdapter(),
        middlewares: <DatabaseMiddleware>[middleware],
      );

      final rows = await adapter.findMany(
        const FindManyQuery(model: 'User', where: <QueryPredicate>[]),
      );

      expect(rows, hasLength(1));

      final span = spanProcessor.ended.single;
      expect(span.name, 'SELECT User');
      expect(span.attributes[otel.SemanticAttributes.dbSystem], 'sqlite');
      expect(span.attributes[otel.SemanticAttributes.dbName], 'memory');
      expect(span.attributes[otel.SemanticAttributes.dbTable], 'User');
      expect(span.attributes[ComonOrmOtelAttributes.resultRows], 1);
      expect(span.status, otel.SpanStatus.ok);

      final metrics = meterProvider.collectAll();
      expect(
        metrics.map((metric) => metric.name),
        containsAll(<String>[
          ComonOrmOtelAttributes.operationDurationMetric,
          ComonOrmOtelAttributes.operationCountMetric,
          ComonOrmOtelAttributes.activeOperationMetric,
        ]),
      );
    });

    test('records exceptions and nests spans inside transactions', () async {
      final spanProcessor = _RecordingSpanProcessor();
      final tracerProvider = otel.TracerProvider(
        resource: otel.Resource(serviceName: 'orm-test'),
        spanProcessors: <otel.SpanProcessor>[spanProcessor],
        sampler: const otel.AlwaysOnSampler(),
      );
      final meterProvider = otel.MeterProvider(
        resource: otel.Resource(serviceName: 'orm-test'),
        readers: const <otel.MetricReader>[],
      );
      final middleware = OtelDatabaseMiddleware(
        dbSystem: 'sqlite',
        tracer: tracerProvider.getTracer('comon_orm'),
        meter: meterProvider.getMeter('comon_orm'),
      );
      final adapter = MiddlewareDatabaseAdapter(
        adapter: _FakeDatabaseAdapter(throwOnFindMany: true),
        middlewares: <DatabaseMiddleware>[middleware],
      );

      await expectLater(
        () => adapter.transaction((tx) async {
          await tx.findMany(
            const FindManyQuery(model: 'User', where: <QueryPredicate>[]),
          );
          return 0;
        }),
        throwsA(isA<StateError>()),
      );

      expect(spanProcessor.ended, hasLength(2));
      final transactionSpan = spanProcessor.ended[1];
      final querySpan = spanProcessor.ended[0];
      expect(transactionSpan.name, 'TRANSACTION');
      expect(querySpan.name, 'SELECT User');
      expect(querySpan.parentSpanId, transactionSpan.spanId);
      expect(querySpan.status, otel.SpanStatus.error);

      final errorMetric = meterProvider.collectAll().firstWhere(
        (metric) =>
            metric.name == ComonOrmOtelAttributes.operationErrorCountMetric,
      );
        expect(errorMetric.points, hasLength(2));

        final transactionErrorPoint = errorMetric.points.firstWhere(
          (point) =>
              point.attributes[otel.SemanticAttributes.dbOperation] ==
              'TRANSACTION',
        );
        final queryErrorPoint = errorMetric.points.firstWhere(
          (point) =>
              point.attributes[otel.SemanticAttributes.dbOperation] == 'SELECT' &&
              point.attributes[otel.SemanticAttributes.dbTable] == 'User',
        );

        expect(transactionErrorPoint.value, 1);
        expect(queryErrorPoint.value, 1);
    });
  });
}

class _RecordingSpanProcessor implements otel.SpanProcessor {
  final List<otel.SpanData> ended = <otel.SpanData>[];

  @override
  void onStart(otel.Span span) {}

  @override
  void onEnd(otel.Span span) {
    ended.add(span.toSpanData());
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {}
}

class _FakeDatabaseAdapter implements DatabaseAdapter {
  _FakeDatabaseAdapter({this.throwOnFindMany = false});

  final bool throwOnFindMany;

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
    if (throwOnFindMany) {
      throw StateError('query failed');
    }
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
