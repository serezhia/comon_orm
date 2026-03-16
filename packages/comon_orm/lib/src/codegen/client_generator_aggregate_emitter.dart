part of 'client_generator.dart';

extension on ClientGenerator {
  void _writeAggregateInputClasses(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final scalarFields = _scalarFields(schema, model);
    final numericFields = _numericAggregateFields(schema, model);
    final comparableFields = _comparableAggregateFields(schema, model);

    _writeCountAggregateInputClass(buffer, model, scalarFields);
    _writeFieldSelectionInputClass(
      buffer,
      className: '${model.name}AvgAggregateInput',
      fields: numericFields,
    );
    _writeFieldSelectionInputClass(
      buffer,
      className: '${model.name}SumAggregateInput',
      fields: numericFields,
    );
    _writeFieldSelectionInputClass(
      buffer,
      className: '${model.name}MinAggregateInput',
      fields: comparableFields,
    );
    _writeFieldSelectionInputClass(
      buffer,
      className: '${model.name}MaxAggregateInput',
      fields: comparableFields,
    );
  }

  void _writeCountAggregateInputClass(
    StringBuffer buffer,
    ModelDefinition model,
    List<FieldDefinition> scalarFields,
  ) {
    final className = '${model.name}CountAggregateInput';

    buffer
      ..writeln('class $className {')
      ..write('  const $className({this.all = false, ');

    for (final field in scalarFields) {
      buffer.write('this.${field.name} = false, ');
    }

    buffer
      ..writeln('});')
      ..writeln()
      ..writeln('  final bool all;');

    for (final field in scalarFields) {
      buffer.writeln('  final bool ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  QueryCountSelection toQueryCountSelection() {')
      ..writeln('    final fields = <String>{};');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name}) {')
        ..writeln('      fields.add(${_stringLiteral(field.name)});')
        ..writeln('    }');
    }

    buffer
      ..writeln(
        '    return QueryCountSelection(all: all, fields: Set<String>.unmodifiable(fields));',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeFieldSelectionInputClass(
    StringBuffer buffer, {
    required String className,
    required List<FieldDefinition> fields,
  }) {
    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in fields) {
      buffer.write('this.${field.name} = false, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in fields) {
      buffer.writeln('  final bool ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  Set<String> toFields() {')
      ..writeln('    final fields = <String>{};');

    for (final field in fields) {
      buffer
        ..writeln('    if (${field.name}) {')
        ..writeln('      fields.add(${_stringLiteral(field.name)});')
        ..writeln('    }');
    }

    buffer
      ..writeln('    return Set<String>.unmodifiable(fields);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeAggregateResultClasses(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final scalarFields = _scalarFields(schema, model);
    final numericFields = _numericAggregateFields(schema, model);
    final comparableFields = _comparableAggregateFields(schema, model);

    _writeCountAggregateResultClass(buffer, model, scalarFields);
    _writeAggregateValueResultClass(
      buffer,
      schema,
      className: '${model.name}AvgAggregateResult',
      fields: numericFields,
      mapType: 'Map<String, double?>',
      valueExpression: (field, access) => _aggregateValueExpression(
        schema,
        field,
        access,
        aggregateKind: 'avg',
      ),
    );
    _writeAggregateValueResultClass(
      buffer,
      schema,
      className: '${model.name}SumAggregateResult',
      fields: numericFields,
      mapType: 'Map<String, num?>',
      valueExpression: (field, access) => _aggregateValueExpression(
        schema,
        field,
        access,
        aggregateKind: 'sum',
      ),
    );
    _writeAggregateValueResultClass(
      buffer,
      schema,
      className: '${model.name}MinAggregateResult',
      fields: comparableFields,
      mapType: 'Map<String, Object?>',
      valueExpression: (field, access) => _aggregateValueExpression(
        schema,
        field,
        access,
        aggregateKind: 'min',
      ),
    );
    _writeAggregateValueResultClass(
      buffer,
      schema,
      className: '${model.name}MaxAggregateResult',
      fields: comparableFields,
      mapType: 'Map<String, Object?>',
      valueExpression: (field, access) => _aggregateValueExpression(
        schema,
        field,
        access,
        aggregateKind: 'max',
      ),
    );

    final aggregateClassName = '${model.name}AggregateResult';
    buffer
      ..writeln('class $aggregateClassName {')
      ..writeln('  const $aggregateClassName({')
      ..writeln('    this.count,')
      ..writeln('    this.avg,')
      ..writeln('    this.sum,')
      ..writeln('    this.min,')
      ..writeln('    this.max,')
      ..writeln('  });')
      ..writeln()
      ..writeln('  final ${model.name}CountAggregateResult? count;')
      ..writeln('  final ${model.name}AvgAggregateResult? avg;')
      ..writeln('  final ${model.name}SumAggregateResult? sum;')
      ..writeln('  final ${model.name}MinAggregateResult? min;')
      ..writeln('  final ${model.name}MaxAggregateResult? max;')
      ..writeln()
      ..writeln(
        '  factory $aggregateClassName.fromQueryResult(AggregateQueryResult result) {',
      )
      ..writeln('    return $aggregateClassName(')
      ..writeln(
        '      count: result.count == null ? null : ${model.name}CountAggregateResult.fromQueryCountResult(result.count!),',
      )
      ..writeln(
        '      avg: result.avg == null ? null : ${model.name}AvgAggregateResult.fromMap(result.avg!),',
      )
      ..writeln(
        '      sum: result.sum == null ? null : ${model.name}SumAggregateResult.fromMap(result.sum!),',
      )
      ..writeln(
        '      min: result.min == null ? null : ${model.name}MinAggregateResult.fromMap(result.min!),',
      )
      ..writeln(
        '      max: result.max == null ? null : ${model.name}MaxAggregateResult.fromMap(result.max!),',
      )
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeCountAggregateResultClass(
    StringBuffer buffer,
    ModelDefinition model,
    List<FieldDefinition> scalarFields,
  ) {
    final className = '${model.name}CountAggregateResult';

    buffer
      ..writeln('class $className {')
      ..write('  const $className({this.all, ');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln()
      ..writeln('  final int? all;');

    for (final field in scalarFields) {
      buffer.writeln('  final int? ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln(
        '  factory $className.fromQueryCountResult(QueryCountAggregateResult result) {',
      )
      ..writeln('    return $className(')
      ..writeln('      all: result.all,');

    for (final field in scalarFields) {
      buffer.writeln(
        '      ${field.name}: result.fields[${_stringLiteral(field.name)}],',
      );
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeAggregateValueResultClass(
    StringBuffer buffer,
    SchemaDocument schema, {
    required String className,
    required List<FieldDefinition> fields,
    required String mapType,
    required String Function(FieldDefinition field, String access)
    valueExpression,
  }) {
    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in fields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in fields) {
      buffer.writeln(
        '  final ${_aggregateResultFieldType(schema, field, className)} ${field.name};',
      );
    }

    buffer
      ..writeln()
      ..writeln('  factory $className.fromMap($mapType values) {')
      ..writeln('    return $className(');

    for (final field in fields) {
      buffer.writeln(
        '      ${field.name}: ${valueExpression(field, "values[${_stringLiteral(field.name)}]")},',
      );
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeGroupBySupportClasses(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final scalarFields = _scalarFields(schema, model);
    final numericFields = _numericAggregateFields(schema, model);
    final comparableFields = _comparableAggregateFields(schema, model);

    _writeGroupByHavingInputClass(buffer, model, numericFields);
    _writeAggregateOrderByInputClass(
      buffer,
      className: '${model.name}CountAggregateOrderByInput',
      fields: scalarFields,
      includeAll: true,
    );
    _writeAggregateOrderByInputClass(
      buffer,
      className: '${model.name}AvgAggregateOrderByInput',
      fields: numericFields,
    );
    _writeAggregateOrderByInputClass(
      buffer,
      className: '${model.name}SumAggregateOrderByInput',
      fields: numericFields,
    );
    _writeAggregateOrderByInputClass(
      buffer,
      className: '${model.name}MinAggregateOrderByInput',
      fields: comparableFields,
    );
    _writeAggregateOrderByInputClass(
      buffer,
      className: '${model.name}MaxAggregateOrderByInput',
      fields: comparableFields,
    );
    _writeGroupByOrderByInputClass(buffer, schema, model);
    _writeGroupByRowClass(buffer, schema, model);
  }

  void _writeGroupByHavingInputClass(
    StringBuffer buffer,
    ModelDefinition model,
    List<FieldDefinition> numericFields,
  ) {
    final className = '${model.name}GroupByHavingInput';

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in numericFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in numericFields) {
      buffer.writeln('  final NumericAggregatesFilter? ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  List<QueryAggregatePredicate> toAggregatePredicates() {')
      ..writeln('    final predicates = <QueryAggregatePredicate>[];');

    for (final field in numericFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      predicates.addAll(${field.name}!.toPredicates(${_stringLiteral(field.name)}));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln(
        '    return List<QueryAggregatePredicate>.unmodifiable(predicates);',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeAggregateOrderByInputClass(
    StringBuffer buffer, {
    required String className,
    required List<FieldDefinition> fields,
    bool includeAll = false,
  }) {
    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    if (includeAll) {
      buffer.write('this.all, ');
    }
    for (final field in fields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    if (includeAll) {
      buffer.writeln('  final SortOrder? all;');
    }
    for (final field in fields) {
      buffer.writeln('  final SortOrder? ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln(
        '  List<GroupByOrderBy> toGroupByOrderBy(QueryAggregateFunction function) {',
      )
      ..writeln('    final orderings = <GroupByOrderBy>[];');

    if (includeAll) {
      buffer
        ..writeln('    if (all != null) {')
        ..writeln(
          '      orderings.add(GroupByOrderBy.aggregate(aggregate: function, direction: all!));',
        )
        ..writeln('    }');
    }

    for (final field in fields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      orderings.add(GroupByOrderBy.aggregate(aggregate: function, field: ${_stringLiteral(field.name)}, direction: ${field.name}!));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return List<GroupByOrderBy>.unmodifiable(orderings);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeGroupByOrderByInputClass(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}GroupByOrderByInput';
    final scalarFields = _scalarFields(schema, model);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer.write('this.count, this.avg, this.sum, this.min, this.max');
    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln('  final SortOrder? ${field.name};');
    }
    buffer
      ..writeln('  final ${model.name}CountAggregateOrderByInput? count;')
      ..writeln('  final ${model.name}AvgAggregateOrderByInput? avg;')
      ..writeln('  final ${model.name}SumAggregateOrderByInput? sum;')
      ..writeln('  final ${model.name}MinAggregateOrderByInput? min;')
      ..writeln('  final ${model.name}MaxAggregateOrderByInput? max;')
      ..writeln()
      ..writeln('  List<GroupByOrderBy> toGroupByOrderBy() {')
      ..writeln('    final orderings = <GroupByOrderBy>[];');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      orderings.add(GroupByOrderBy.field(field: ${_stringLiteral(field.name)}, direction: ${field.name}!));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    if (count != null) {')
      ..writeln(
        '      orderings.addAll(count!.toGroupByOrderBy(QueryAggregateFunction.count));',
      )
      ..writeln('    }')
      ..writeln('    if (avg != null) {')
      ..writeln(
        '      orderings.addAll(avg!.toGroupByOrderBy(QueryAggregateFunction.avg));',
      )
      ..writeln('    }')
      ..writeln('    if (sum != null) {')
      ..writeln(
        '      orderings.addAll(sum!.toGroupByOrderBy(QueryAggregateFunction.sum));',
      )
      ..writeln('    }')
      ..writeln('    if (min != null) {')
      ..writeln(
        '      orderings.addAll(min!.toGroupByOrderBy(QueryAggregateFunction.min));',
      )
      ..writeln('    }')
      ..writeln('    if (max != null) {')
      ..writeln(
        '      orderings.addAll(max!.toGroupByOrderBy(QueryAggregateFunction.max));',
      )
      ..writeln('    }')
      ..writeln('    return List<GroupByOrderBy>.unmodifiable(orderings);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeGroupByRowClass(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}GroupByRow';
    final scalarFields = _scalarFields(schema, model);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('this.count, this.avg, this.sum, this.min, this.max});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: true)} ${field.name};',
      );
    }
    buffer
      ..writeln('  final ${model.name}CountAggregateResult? count;')
      ..writeln('  final ${model.name}AvgAggregateResult? avg;')
      ..writeln('  final ${model.name}SumAggregateResult? sum;')
      ..writeln('  final ${model.name}MinAggregateResult? min;')
      ..writeln('  final ${model.name}MaxAggregateResult? max;')
      ..writeln()
      ..writeln(
        '  factory $className.fromQueryResultRow(GroupByQueryResultRow row) {',
      )
      ..writeln('    return $className(');

    for (final field in scalarFields) {
      buffer.writeln(
        '      ${field.name}: ${_fromScalarRecordExpression(schema, field, "row.group[${_stringLiteral(field.name)}]")},',
      );
    }

    buffer
      ..writeln(
        '      count: row.aggregates.count == null ? null : ${model.name}CountAggregateResult.fromQueryCountResult(row.aggregates.count!),',
      )
      ..writeln(
        '      avg: row.aggregates.avg == null ? null : ${model.name}AvgAggregateResult.fromMap(row.aggregates.avg!),',
      )
      ..writeln(
        '      sum: row.aggregates.sum == null ? null : ${model.name}SumAggregateResult.fromMap(row.aggregates.sum!),',
      )
      ..writeln(
        '      min: row.aggregates.min == null ? null : ${model.name}MinAggregateResult.fromMap(row.aggregates.min!),',
      )
      ..writeln(
        '      max: row.aggregates.max == null ? null : ${model.name}MaxAggregateResult.fromMap(row.aggregates.max!),',
      )
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }
}
