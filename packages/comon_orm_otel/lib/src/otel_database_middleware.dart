import 'package:comon_orm/comon_orm.dart';
import 'package:comon_otel/comon_otel.dart' as otel;

import 'db_semantic_attributes.dart';

/// Creates OpenTelemetry spans and metrics for comon_orm operations.
class OtelDatabaseMiddleware
    implements DatabaseMiddleware, DatabaseExecutionMiddleware {
  OtelDatabaseMiddleware({
    String tracerName = 'comon_orm',
    String meterName = 'comon_orm',
    this.recordSqlStatements = false,
    this.recordParameters = false,
    this.dbSystem,
    this.dbName,
    otel.Tracer? tracer,
    otel.Meter? meter,
  }) : _tracer =
           tracer ?? otel.Otel.instance.tracerProvider.getTracer(tracerName),
       _meter = meter ?? otel.Otel.instance.meterProvider.getMeter(meterName),
       _operationDuration =
           (meter ?? otel.Otel.instance.meterProvider.getMeter(meterName))
               .createHistogram(
                 ComonOrmOtelAttributes.operationDurationMetric,
                 unit: 'ms',
                 description: 'Duration of database operations.',
               ),
       _operationCount =
           (meter ?? otel.Otel.instance.meterProvider.getMeter(meterName))
               .createIntCounter(
                 ComonOrmOtelAttributes.operationCountMetric,
                 description: 'Total number of database operations.',
               ),
       _operationErrors =
           (meter ?? otel.Otel.instance.meterProvider.getMeter(meterName))
               .createIntCounter(
                 ComonOrmOtelAttributes.operationErrorCountMetric,
                 description: 'Number of failed database operations.',
               ),
       _activeOperations =
           (meter ?? otel.Otel.instance.meterProvider.getMeter(meterName))
               .createIntUpDownCounter(
                 ComonOrmOtelAttributes.activeOperationMetric,
                 description: 'Number of active database operations.',
               );

  final otel.Tracer _tracer;
  final otel.Meter _meter;
  final bool recordSqlStatements;
  final bool recordParameters;
  final String? dbSystem;
  final String? dbName;
  final otel.Histogram<double> _operationDuration;
  final otel.Counter<int> _operationCount;
  final otel.Counter<int> _operationErrors;
  final otel.UpDownCounter<int> _activeOperations;

  @override
  Future<void> beforeQuery(DatabaseMiddlewareContext context) async {}

  @override
  Future<void> afterQuery(DatabaseMiddlewareResult result) async {}

  @override
  Future<T> runQuery<T>({
    required DatabaseMiddlewareContext context,
    required Future<T> Function(DatabaseMiddlewareContext context) next,
  }) async {
    final metricAttributes = _buildMetricAttributes(context);
    final span = _tracer.startSpan(
      _buildSpanName(context),
      kind: otel.SpanKind.client,
      attributes: _buildSpanAttributes(context),
    );
    final stopwatch = Stopwatch()..start();

    _activeOperations.add(1, attributes: metricAttributes);
    _operationCount.add(1, attributes: metricAttributes);

    return otel.OtelContext.withSpan(span, () async {
      try {
        final result = await next(context);
        _attachResultAttributes(span, result);
        span.setStatus(otel.SpanStatus.ok);
        return result;
      } catch (error, stackTrace) {
        span.recordException(error, stackTrace: stackTrace);
        span.setStatus(otel.SpanStatus.error, description: error.toString());
        _operationErrors.add(1, attributes: metricAttributes);
        rethrow;
      } finally {
        stopwatch.stop();
        _operationDuration.record(
          stopwatch.elapsedMicroseconds / 1000,
          attributes: metricAttributes,
        );
        _activeOperations.add(-1, attributes: metricAttributes);
        await span.end();
      }
    });
  }

  String get meterName => _meter.name;

  String _buildSpanName(DatabaseMiddlewareContext context) {
    final operation = _mapOperation(context.operation);
    final model = context.model;
    if (model == null || model.isEmpty) {
      return operation;
    }
    return '$operation $model';
  }

  Map<String, Object> _buildSpanAttributes(DatabaseMiddlewareContext context) {
    final attributes = <String, Object>{
      otel.SemanticAttributes.dbOperation: _mapOperation(context.operation),
    };

    if (dbSystem != null && dbSystem!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbSystem] = dbSystem!;
    }
    if (dbName != null && dbName!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbName] = dbName!;
    }
    if (context.model != null && context.model!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbTable] = context.model!;
    }
    if (recordSqlStatements && context.sql != null && context.sql!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbStatement] = context.sql!;
    }
    if (context.parameters.isNotEmpty) {
      attributes[ComonOrmOtelAttributes.parameterCount] =
          context.parameters.length;
    }
    if (recordParameters && context.parameters.isNotEmpty) {
      for (var index = 0; index < context.parameters.length; index++) {
        final value = context.parameters[index];
        if (value == null) {
          continue;
        }
        attributes['db.query.parameter.$index'] = value.toString();
      }
    }

    return attributes;
  }

  Map<String, Object> _buildMetricAttributes(
    DatabaseMiddlewareContext context,
  ) {
    final attributes = <String, Object>{
      otel.SemanticAttributes.dbOperation: _mapOperation(context.operation),
    };
    if (dbSystem != null && dbSystem!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbSystem] = dbSystem!;
    }
    if (context.model != null && context.model!.isNotEmpty) {
      attributes[otel.SemanticAttributes.dbTable] = context.model!;
    }
    return attributes;
  }

  void _attachResultAttributes(otel.Span span, Object? result) {
    if (result is List) {
      span.setAttribute(ComonOrmOtelAttributes.resultRows, result.length);
      return;
    }
    if (result is Map<String, Object?>) {
      span.setAttribute(ComonOrmOtelAttributes.resultRows, 1);
      return;
    }
    if (result is int) {
      span.setAttribute(ComonOrmOtelAttributes.resultRows, result);
    }
  }

  String _mapOperation(DatabaseMiddlewareOperation operation) {
    return switch (operation) {
      DatabaseMiddlewareOperation.findMany ||
      DatabaseMiddlewareOperation.findUnique ||
      DatabaseMiddlewareOperation.findFirst => 'SELECT',
      DatabaseMiddlewareOperation.count => 'COUNT',
      DatabaseMiddlewareOperation.aggregate => 'AGGREGATE',
      DatabaseMiddlewareOperation.groupBy => 'GROUP_BY',
      DatabaseMiddlewareOperation.create ||
      DatabaseMiddlewareOperation.createMany => 'INSERT',
      DatabaseMiddlewareOperation.update ||
      DatabaseMiddlewareOperation.updateMany => 'UPDATE',
      DatabaseMiddlewareOperation.delete ||
      DatabaseMiddlewareOperation.deleteMany => 'DELETE',
      DatabaseMiddlewareOperation.upsert => 'UPSERT',
      DatabaseMiddlewareOperation.rawQuery => 'RAW_QUERY',
      DatabaseMiddlewareOperation.rawExecute => 'RAW_EXECUTE',
      DatabaseMiddlewareOperation.transaction => 'TRANSACTION',
      DatabaseMiddlewareOperation.addImplicitManyToManyLink => 'LINK',
      DatabaseMiddlewareOperation.removeImplicitManyToManyLinks => 'UNLINK',
    };
  }
}
