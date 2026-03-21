/// Attribute keys and metric names used by comon_orm_otel.
final class ComonOrmOtelAttributes {
  const ComonOrmOtelAttributes._();

  static const String parameterCount = 'db.query.parameter.count';
  static const String resultRows = 'db.response.rows';

  static const String operationDurationMetric = 'db.client.operation.duration';
  static const String operationCountMetric = 'db.client.operation.count';
  static const String operationErrorCountMetric =
      'db.client.operation.error.count';
  static const String activeOperationMetric = 'db.client.connection.active';
}
