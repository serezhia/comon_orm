import '../schema/schema_ast.dart';

/// Generates a typed Dart client from a validated schema AST.
class ClientGenerator {
  /// Creates a stateless generator.
  const ClientGenerator();

  /// Returns the generated client source for [schema].
  String generateClient(SchemaDocument schema) {
    final buffer = StringBuffer()
      ..writeln('// Generated code. Do not edit by hand.')
      ..writeln(
        '// ignore_for_file: unused_element, non_constant_identifier_names',
      )
      ..writeln("import 'package:comon_orm/comon_orm.dart';")
      ..writeln()
      ..writeln('class GeneratedComonOrmClient {')
      ..writeln('  GeneratedComonOrmClient({required DatabaseAdapter adapter})')
      ..writeln('    : _client = ComonOrmClient(adapter: adapter);')
      ..writeln()
      ..writeln('  GeneratedComonOrmClient._fromClient(this._client);')
      ..writeln()
      ..writeln('  final ComonOrmClient _client;');

    for (final model in schema.models) {
      final delegateName = '${model.name}Delegate';
      final propertyName = _lowercaseFirst(model.name);
      buffer.writeln(
        '  late final $delegateName $propertyName = $delegateName(_client.model(${_stringLiteral(model.name)}));',
      );
    }

    buffer
      ..writeln()
      ..writeln('  Future<T> transaction<T>(')
      ..writeln('    Future<T> Function(GeneratedComonOrmClient tx) action,')
      ..writeln('  ) {')
      ..writeln(
        '    return _client.transaction((tx) => action(GeneratedComonOrmClient._fromClient(tx)));',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln();

    for (final definition in schema.enums) {
      _writeEnumClass(buffer, definition);
    }

    for (final model in schema.models) {
      _writeModelClass(buffer, schema, model);
    }

    for (final model in schema.models) {
      _writeDelegate(buffer, schema, model);
      _writeWhereInput(buffer, schema, model);
      _writeWhereUniqueInput(buffer, schema, model);
      _writeOrderByInput(buffer, schema, model);
      _writeScalarFieldEnum(buffer, schema, model);
      _writeAggregateInputClasses(buffer, schema, model);
      _writeAggregateResultClasses(buffer, schema, model);
      _writeGroupBySupportClasses(buffer, schema, model);
      _writeInclude(buffer, schema, model);
      _writeSelect(buffer, schema, model);
      _writeCreateInput(buffer, schema, model);
      _writeUpdateInput(buffer, schema, model);
      _writeCreateWithoutInputs(buffer, schema, model);
      _writeNestedCreateInputs(buffer, schema, model);
    }

    buffer
      ..writeln('DateTime? _asDateTime(Object? value) {')
      ..writeln('  if (value is DateTime) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is String) {')
      ..writeln('    return DateTime.tryParse(value);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('double? _asDouble(Object? value) {')
      ..writeln('  if (value is num) {')
      ..writeln('    return value.toDouble();')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('List<int>? _asBytes(Object? value) {')
      ..writeln('  if (value is List<int>) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return value.whereType<int>().toList(growable: false);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('BigInt? _asBigInt(Object? value) {')
      ..writeln('  if (value is BigInt) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is int) {')
      ..writeln('    return BigInt.from(value);')
      ..writeln('  }')
      ..writeln('  if (value is String) {')
      ..writeln('    return BigInt.tryParse(value);')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('String? _enumName(Object? value) {')
      ..writeln('  if (value is Enum) {')
      ..writeln('    return value.name;')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('class _Undefined {')
      ..writeln('  const _Undefined();')
      ..writeln('}')
      ..writeln()
      ..writeln('const Object _undefined = _Undefined();')
      ..writeln()
      ..writeln('bool _deepEquals(Object? left, Object? right) {')
      ..writeln('  if (identical(left, right)) {')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  if (left is List<Object?> && right is List<Object?>) {')
      ..writeln('    if (left.length != right.length) {')
      ..writeln('      return false;')
      ..writeln('    }')
      ..writeln('    for (var index = 0; index < left.length; index++) {')
      ..writeln('      if (!_deepEquals(left[index], right[index])) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('    }')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln(
        '  if (left is Map<Object?, Object?> && right is Map<Object?, Object?>) {',
      )
      ..writeln('    if (left.length != right.length) {')
      ..writeln('      return false;')
      ..writeln('    }')
      ..writeln('    for (final entry in left.entries) {')
      ..writeln('      if (!right.containsKey(entry.key)) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('      if (!_deepEquals(entry.value, right[entry.key])) {')
      ..writeln('        return false;')
      ..writeln('      }')
      ..writeln('    }')
      ..writeln('    return true;')
      ..writeln('  }')
      ..writeln('  return left == right;')
      ..writeln('}')
      ..writeln()
      ..writeln('int _deepHash(Object? value) {')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return Object.hashAll(value.map(_deepHash));')
      ..writeln('  }')
      ..writeln('  if (value is Map<Object?, Object?>) {')
      ..writeln('    final entries = value.entries')
      ..writeln(
        '        .map((entry) => Object.hash(_deepHash(entry.key), _deepHash(entry.value)))',
      )
      ..writeln('        .toList(growable: false)')
      ..writeln('      ..sort();')
      ..writeln('    return Object.hashAll(entries);')
      ..writeln('  }')
      ..writeln('  return value.hashCode;')
      ..writeln('}')
      ..writeln()
      ..writeln('Object? _jsonEncodable(Object? value) {')
      ..writeln(
        '  if (value == null || value is String || value is num || value is bool) {',
      )
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  if (value is DateTime) {')
      ..writeln('    return value.toIso8601String();')
      ..writeln('  }')
      ..writeln('  if (value is BigInt) {')
      ..writeln('    return value.toString();')
      ..writeln('  }')
      ..writeln('  if (value is Enum) {')
      ..writeln('    return value.name;')
      ..writeln('  }')
      ..writeln('  if (value is List<Object?>) {')
      ..writeln('    return value.map(_jsonEncodable).toList(growable: false);')
      ..writeln('  }')
      ..writeln('  if (value is Map<Object?, Object?>) {')
      ..writeln('    final json = <String, Object?>{};')
      ..writeln('    for (final entry in value.entries) {')
      ..writeln(
        '      json[entry.key.toString()] = _jsonEncodable(entry.value);',
      )
      ..writeln('    }')
      ..writeln('    return Map<String, Object?>.unmodifiable(json);')
      ..writeln('  }')
      ..writeln('  return value;')
      ..writeln('}')
      ..writeln();

    return buffer.toString();
  }

  void _writeEnumClass(StringBuffer buffer, EnumDefinition definition) {
    buffer.writeln('enum ${definition.name} {');

    for (var index = 0; index < definition.values.length; index++) {
      final suffix = index == definition.values.length - 1 ? '' : ',';
      buffer.writeln('  ${definition.values[index]}$suffix');
    }

    buffer
      ..writeln('}')
      ..writeln();
  }

  void _writeDelegate(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final delegateName = '${model.name}Delegate';
    final modelClassName = model.name;
    final whereInputName = '${model.name}WhereInput';
    final whereUniqueInputName = '${model.name}WhereUniqueInput';
    final orderByName = '${model.name}OrderByInput';
    final scalarFieldName = '${model.name}ScalarField';
    final countAggregateInputName = '${model.name}CountAggregateInput';
    final avgAggregateInputName = '${model.name}AvgAggregateInput';
    final sumAggregateInputName = '${model.name}SumAggregateInput';
    final minAggregateInputName = '${model.name}MinAggregateInput';
    final maxAggregateInputName = '${model.name}MaxAggregateInput';
    final aggregateResultName = '${model.name}AggregateResult';
    final groupByOrderByName = '${model.name}GroupByOrderByInput';
    final groupByHavingName = '${model.name}GroupByHavingInput';
    final groupByRowName = '${model.name}GroupByRow';
    final includeName = '${model.name}Include';
    final selectName = '${model.name}Select';
    final createInputName = '${model.name}CreateInput';
    final updateInputName = '${model.name}UpdateInput';

    buffer
      ..writeln('class $delegateName {')
      ..writeln('  const $delegateName(this._delegate);')
      ..writeln()
      ..writeln('  final ModelDelegate _delegate;')
      ..writeln()
      ..writeln('  Future<$modelClassName?> findUnique({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.findUnique(')
      ..writeln('      FindUniqueQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('      ),')
      ..writeln(
        '    ).then((record) => record == null ? null : $modelClassName.fromRecord(record));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName?> findFirst({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('    int? skip,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.findFirst(')
      ..writeln('      FindFirstQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln(
        '        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],',
      )
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('        skip: skip,')
      ..writeln('      ),')
      ..writeln(
        '    ).then((record) => record == null ? null : $modelClassName.fromRecord(record));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<List<$modelClassName>> findMany({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    List<$scalarFieldName>? distinct,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('    int? skip,')
      ..writeln('    int? take,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.findMany(')
      ..writeln('      FindManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln(
        '        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],',
      )
      ..writeln(
        '        distinct: distinct?.map((field) => field.name).toSet() ?? const <String>{},',
      )
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('        skip: skip,')
      ..writeln('        take: take,')
      ..writeln('      ),')
      ..writeln(
        '    ).then((records) => records.map($modelClassName.fromRecord).toList(growable: false));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> count({$whereInputName? where}) {')
      ..writeln('    return _delegate.count(')
      ..writeln('      CountQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$aggregateResultName> aggregate({')
      ..writeln('    $whereInputName? where,')
      ..writeln('    List<$orderByName>? orderBy,')
      ..writeln('    int? skip,')
      ..writeln('    int? take,')
      ..writeln('    $countAggregateInputName? count,')
      ..writeln('    $avgAggregateInputName? avg,')
      ..writeln('    $sumAggregateInputName? sum,')
      ..writeln('    $minAggregateInputName? min,')
      ..writeln('    $maxAggregateInputName? max,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.aggregate(')
      ..writeln('      AggregateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln(
        '        orderBy: orderBy?.expand((entry) => entry.toQueryOrderBy()).toList(growable: false) ?? const <QueryOrderBy>[],',
      )
      ..writeln('        skip: skip,')
      ..writeln('        take: take,')
      ..writeln(
        '        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),',
      )
      ..writeln('        avg: avg?.toFields() ?? const <String>{},')
      ..writeln('        sum: sum?.toFields() ?? const <String>{},')
      ..writeln('        min: min?.toFields() ?? const <String>{},')
      ..writeln('        max: max?.toFields() ?? const <String>{},')
      ..writeln('      ),')
      ..writeln('    ).then($aggregateResultName.fromQueryResult);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<List<$groupByRowName>> groupBy({')
      ..writeln('    required List<$scalarFieldName> by,')
      ..writeln('    $whereInputName? where,')
      ..writeln('    List<$groupByOrderByName>? orderBy,')
      ..writeln('    $groupByHavingName? having,')
      ..writeln('    int? skip,')
      ..writeln('    int? take,')
      ..writeln('    $countAggregateInputName? count,')
      ..writeln('    $avgAggregateInputName? avg,')
      ..writeln('    $sumAggregateInputName? sum,')
      ..writeln('    $minAggregateInputName? min,')
      ..writeln('    $maxAggregateInputName? max,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.groupBy(')
      ..writeln('      GroupByQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln(
        '        by: by.map((field) => field.name).toList(growable: false),',
      )
      ..writeln(
        '        where: where?.toPredicates() ?? const <QueryPredicate>[],',
      )
      ..writeln(
        '        having: having?.toAggregatePredicates() ?? const <QueryAggregatePredicate>[],',
      )
      ..writeln(
        '        orderBy: orderBy?.expand((entry) => entry.toGroupByOrderBy()).toList(growable: false) ?? const <GroupByOrderBy>[],',
      )
      ..writeln('        skip: skip,')
      ..writeln('        take: take,')
      ..writeln(
        '        count: count?.toQueryCountSelection() ?? const QueryCountSelection(),',
      )
      ..writeln('        avg: avg?.toFields() ?? const <String>{},')
      ..writeln('        sum: sum?.toFields() ?? const <String>{},')
      ..writeln('        min: min?.toFields() ?? const <String>{},')
      ..writeln('        max: max?.toFields() ?? const <String>{},')
      ..writeln('      ),')
      ..writeln(
        '    ).then((rows) => rows.map($groupByRowName.fromQueryResultRow).toList(growable: false));',
      )
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> create({')
      ..writeln('    required $createInputName data,')
      ..writeln('    $includeName? include,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.create(')
      ..writeln('      CreateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        data: data.toData(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        nestedCreates: data.toNestedCreates(),')
      ..writeln('      ),')
      ..writeln('    ).then($modelClassName.fromRecord);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> update({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    required $updateInputName data,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.update(')
      ..writeln('      UpdateQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        data: data.toData(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('      ),')
      ..writeln('    ).then($modelClassName.fromRecord);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> updateMany({')
      ..writeln('    required $whereInputName where,')
      ..writeln('    required $updateInputName data,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.updateMany(')
      ..writeln('      UpdateManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        data: data.toData(),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<$modelClassName> delete({')
      ..writeln('    required $whereUniqueInputName where,')
      ..writeln('    $includeName? include,')
      ..writeln('    $selectName? select,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.delete(')
      ..writeln('      DeleteQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('        include: include?.toQueryInclude(),')
      ..writeln('        select: select?.toQuerySelect(),')
      ..writeln('      ),')
      ..writeln('    ).then($modelClassName.fromRecord);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Future<int> deleteMany({')
      ..writeln('    required $whereInputName where,')
      ..writeln('  }) {')
      ..writeln('    return _delegate.deleteMany(')
      ..writeln('      DeleteManyQuery(')
      ..writeln('        model: ${_stringLiteral(model.name)},')
      ..writeln('        where: where.toPredicates(),')
      ..writeln('      ),')
      ..writeln('    );')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeWhereUniqueInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}WhereUniqueInput';
    final scalarUniqueFields = _scalarUniqueFields(schema, model);
    final compoundUniqueFieldSets = _compoundUniqueFieldSets(model);

    for (final fieldNames in compoundUniqueFieldSets) {
      _writeCompoundUniqueInput(buffer, schema, model, fieldNames);
    }

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarUniqueFields) {
      buffer.write('this.${field.name}, ');
    }

    for (final fieldNames in compoundUniqueFieldSets) {
      buffer.write('this.${_compoundUniqueSelectorName(fieldNames)}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarUniqueFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: true)} ${field.name};',
      );
    }

    for (final fieldNames in compoundUniqueFieldSets) {
      buffer.writeln(
        '  final ${_compoundUniqueInputClassName(model, fieldNames)}? ${_compoundUniqueSelectorName(fieldNames)};',
      );
    }

    buffer
      ..writeln()
      ..writeln('  List<QueryPredicate> toPredicates() {')
      ..writeln('    final selectors = <List<QueryPredicate>>[];');

    for (final field in scalarUniqueFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln('      selectors.add(<QueryPredicate>[')
        ..writeln(
          '        QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('equals')}, value: ${_queryValueExpression(schema, field, field.name)}),',
        )
        ..writeln('      ]);')
        ..writeln('    }');
    }

    for (final fieldNames in compoundUniqueFieldSets) {
      final selectorName = _compoundUniqueSelectorName(fieldNames);
      buffer
        ..writeln('    if ($selectorName != null) {')
        ..writeln('      selectors.add($selectorName!.toPredicates());')
        ..writeln('    }');
    }

    buffer
      ..writeln('    if (selectors.length != 1) {')
      ..writeln(
        '      throw StateError(${_stringLiteral('Exactly one unique selector must be provided for $className.')});',
      )
      ..writeln('    }')
      ..writeln(
        '    return List<QueryPredicate>.unmodifiable(selectors.single);',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeCompoundUniqueInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
    List<String> fieldNames,
  ) {
    final className = _compoundUniqueInputClassName(model, fieldNames);
    final fields = fieldNames
        .map((name) => model.findField(name))
        .whereType<FieldDefinition>()
        .toList(growable: false);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in fields) {
      buffer.write('required this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in fields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: false)} ${field.name};',
      );
    }

    buffer
      ..writeln()
      ..writeln('  List<QueryPredicate> toPredicates() {')
      ..writeln(
        '    return List<QueryPredicate>.unmodifiable(<QueryPredicate>[',
      );

    for (final field in fields) {
      buffer.writeln(
        '      QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('equals')}, value: ${_queryValueExpression(schema, field, field.name)}),',
      );
    }

    buffer
      ..writeln('    ]);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeModelClass(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    buffer
      ..writeln('class ${model.name} {')
      ..write('  const ${model.name}({');

    for (final field in model.fields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in model.fields) {
      buffer.writeln(
        '  final ${_modelFieldType(schema, field)} ${field.name};',
      );
    }

    buffer
      ..writeln()
      ..writeln(
        '  factory ${model.name}.fromRecord(Map<String, Object?> record) {',
      )
      ..writeln('    return ${model.name}(');

    for (final field in model.fields) {
      buffer.writeln(
        '      ${field.name}: ${_fromRecordExpression(schema, field)},',
      );
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  factory ${model.name}.fromJson(Map<String, Object?> json) {')
      ..writeln('    return ${model.name}(');

    for (final field in model.fields) {
      buffer.writeln(
        '      ${field.name}: ${_fromJsonExpression(schema, field)},',
      );
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  ${model.name} copyWith({');

    for (final field in model.fields) {
      buffer.writeln('    Object? ${field.name} = _undefined,');
    }

    buffer
      ..writeln('  }) {')
      ..writeln('    return ${model.name}(');

    for (final field in model.fields) {
      buffer.writeln(
        '      ${field.name}: ${field.name} == _undefined ? this.${field.name} : ${field.name} as ${_modelFieldType(schema, field)},',
      );
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Map<String, Object?> toRecord() {')
      ..writeln('    final record = <String, Object?>{};');

    for (final field in model.fields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      record[${_stringLiteral(field.name)}] = ${_toRecordExpression(schema, field)};',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(record);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Map<String, Object?> toJson() {')
      ..writeln('    final json = <String, Object?>{};');

    for (final field in model.fields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      json[${_stringLiteral(field.name)}] = ${_toJsonExpression(schema, field)};',
        )
        ..writeln('    }');
    }

    final toStringFields = model.fields
        .map((field) => '${field.name}: \$${field.name}')
        .join(', ');

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(json);')
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln("  String toString() => '${model.name}($toStringFields)';")
      ..writeln()
      ..writeln('  @override')
      ..writeln('  bool operator ==(Object other) {')
      ..writeln('    return identical(this, other) ||')
      ..writeln('        other is ${model.name} &&');

    for (var index = 0; index < model.fields.length; index++) {
      final field = model.fields[index];
      final suffix = index == model.fields.length - 1 ? ';' : ' &&';
      buffer.writeln(
        '        _deepEquals(${field.name}, other.${field.name})$suffix',
      );
    }

    buffer
      ..writeln('  }')
      ..writeln()
      ..writeln('  @override')
      ..writeln('  int get hashCode => Object.hashAll(<Object?>[')
      ..writeln('    runtimeType,');

    for (final field in model.fields) {
      buffer.writeln('    _deepHash(${field.name}),');
    }

    buffer
      ..writeln('  ]);')
      ..writeln('}')
      ..writeln();
  }

  void _writeWhereInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}WhereInput';
    final scalarFields = _scalarFields(schema, model);
    final relationFields = _relationFields(schema, model);
    final listRelationFields = relationFields
        .where((field) => field.isList)
        .toList(growable: false);
    final singleRelationFields = relationFields
        .where((field) => !field.isList)
        .toList(growable: false);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    buffer.write('this.AND = const <$className>[], ');
    buffer.write('this.OR = const <$className>[], ');
    buffer.write('this.NOT = const <$className>[], ');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
      final filterType = _whereFilterType(schema, field);
      if (filterType != null) {
        buffer.write('this.${field.name}Filter, ');
      }
    }

    for (final field in listRelationFields) {
      buffer.write('this.${field.name}Some, ');
      buffer.write('this.${field.name}None, ');
      buffer.write('this.${field.name}Every, ');
    }

    for (final field in singleRelationFields) {
      buffer.write('this.${field.name}Is, ');
      buffer.write('this.${field.name}IsNot, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    buffer.writeln('  final List<$className> AND;');
    buffer.writeln('  final List<$className> OR;');
    buffer.writeln('  final List<$className> NOT;');

    for (final field in scalarFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: true)} ${field.name};',
      );
      final filterType = _whereFilterType(schema, field);
      if (filterType != null) {
        buffer.writeln('  final $filterType? ${field.name}Filter;');
      }
    }

    for (final field in listRelationFields) {
      buffer.writeln('  final ${field.type}WhereInput? ${field.name}Some;');
      buffer.writeln('  final ${field.type}WhereInput? ${field.name}None;');
      buffer.writeln('  final ${field.type}WhereInput? ${field.name}Every;');
    }

    for (final field in singleRelationFields) {
      buffer.writeln('  final ${field.type}WhereInput? ${field.name}Is;');
      buffer.writeln('  final ${field.type}WhereInput? ${field.name}IsNot;');
    }

    buffer
      ..writeln()
      ..writeln('  List<QueryPredicate> toPredicates() {')
      ..writeln('    final predicates = <QueryPredicate>[];');

    buffer
      ..writeln('    if (AND.isNotEmpty) {')
      ..writeln(
        '      predicates.add(QueryPredicate(field: ${_stringLiteral('AND')}, operator: ${_stringLiteral('logicalAnd')}, value: QueryLogicalGroup(branches: AND.map((entry) => entry.toPredicates()).toList(growable: false))));',
      )
      ..writeln('    }')
      ..writeln('    if (OR.isNotEmpty) {')
      ..writeln(
        '      predicates.add(QueryPredicate(field: ${_stringLiteral('OR')}, operator: ${_stringLiteral('logicalOr')}, value: QueryLogicalGroup(branches: OR.map((entry) => entry.toPredicates()).toList(growable: false))));',
      )
      ..writeln('    }')
      ..writeln('    if (NOT.isNotEmpty) {')
      ..writeln(
        '      predicates.add(QueryPredicate(field: ${_stringLiteral('NOT')}, operator: ${_stringLiteral('logicalNot')}, value: QueryLogicalGroup(branches: NOT.map((entry) => entry.toPredicates()).toList(growable: false))));',
      )
      ..writeln('    }');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('equals')}, value: ${_queryValueExpression(schema, field, field.name)}));',
        )
        ..writeln('    }');
      final filterType = _whereFilterType(schema, field);
      if (filterType != null) {
        buffer
          ..writeln('    if (${field.name}Filter != null) {')
          ..writeln(
            '      predicates.addAll(${field.name}Filter!.toPredicates(${_stringLiteral(field.name)}));',
          )
          ..writeln('    }');
      }
    }

    for (final field in listRelationFields) {
      buffer
        ..writeln('    if (${field.name}Some != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('relationSome')}, value: QueryRelationFilter(relation: ${_relationLiteral(schema, model, field)}, predicates: ${field.name}Some!.toPredicates())));',
        )
        ..writeln('    }');
      buffer
        ..writeln('    if (${field.name}None != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('relationNone')}, value: QueryRelationFilter(relation: ${_relationLiteral(schema, model, field)}, predicates: ${field.name}None!.toPredicates())));',
        )
        ..writeln('    }');
      buffer
        ..writeln('    if (${field.name}Every != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('relationEvery')}, value: QueryRelationFilter(relation: ${_relationLiteral(schema, model, field)}, predicates: ${field.name}Every!.toPredicates())));',
        )
        ..writeln('    }');
    }

    for (final field in singleRelationFields) {
      buffer
        ..writeln('    if (${field.name}Is != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('relationIs')}, value: QueryRelationFilter(relation: ${_relationLiteral(schema, model, field)}, predicates: ${field.name}Is!.toPredicates())));',
        )
        ..writeln('    }')
        ..writeln('    if (${field.name}IsNot != null) {')
        ..writeln(
          '      predicates.add(QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('relationIsNot')}, value: QueryRelationFilter(relation: ${_relationLiteral(schema, model, field)}, predicates: ${field.name}IsNot!.toPredicates())));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return List<QueryPredicate>.unmodifiable(predicates);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeOrderByInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}OrderByInput';
    final scalarFields = _scalarFields(schema, model);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln('  final SortOrder? ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  List<QueryOrderBy> toQueryOrderBy() {')
      ..writeln('    final orderings = <QueryOrderBy>[];');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      orderings.add(QueryOrderBy(field: ${_stringLiteral(field.name)}, direction: ${field.name}!));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return List<QueryOrderBy>.unmodifiable(orderings);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeScalarFieldEnum(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final scalarFields = _scalarFields(schema, model);
    final enumName = '${model.name}ScalarField';

    buffer.writeln('enum $enumName {');
    for (var index = 0; index < scalarFields.length; index++) {
      final suffix = index == scalarFields.length - 1 ? '' : ',';
      buffer.writeln('  ${scalarFields[index].name}$suffix');
    }
    buffer
      ..writeln('}')
      ..writeln();
  }

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

  String? _whereFilterType(SchemaDocument schema, FieldDefinition field) {
    if (_isEnumField(schema, field)) {
      return null;
    }

    return switch (field.type) {
      'String' => 'StringFilter',
      'Int' => 'IntFilter',
      'Float' || 'Decimal' => 'DoubleFilter',
      'Boolean' => 'BoolFilter',
      _ => null,
    };
  }

  void _writeInclude(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}Include';
    final relationFields = _relationFields(schema, model);

    buffer.writeln('class $className {');

    if (relationFields.isEmpty) {
      buffer.writeln('  const $className();');
    } else {
      buffer.write('  const $className({');
      for (final field in relationFields) {
        buffer.write('this.${field.name} = false, ');
      }
      buffer.writeln('});');
    }

    buffer.writeln();

    for (final field in relationFields) {
      buffer.writeln('  final bool ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  QueryInclude? toQueryInclude() {');

    if (relationFields.isEmpty) {
      buffer
        ..writeln('    return null;')
        ..writeln('  }')
        ..writeln('}')
        ..writeln();
      return;
    }

    buffer.writeln('    final relations = <String, QueryIncludeEntry>{};');

    for (final field in relationFields) {
      buffer
        ..writeln('    if (${field.name}) {')
        ..writeln(
          '      relations[${_stringLiteral(field.name)}] = QueryIncludeEntry(relation: ${_relationLiteral(schema, model, field)});',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    if (relations.isEmpty) {')
      ..writeln('      return null;')
      ..writeln('    }')
      ..writeln(
        '    return QueryInclude(Map<String, QueryIncludeEntry>.unmodifiable(relations));',
      )
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeSelect(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}Select';
    final scalarFields = _scalarFields(schema, model);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      buffer.write('this.${field.name} = false, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln('  final bool ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  QuerySelect? toQuerySelect() {')
      ..writeln('    final fields = <String>{};');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name}) {')
        ..writeln('      fields.add(${_stringLiteral(field.name)});')
        ..writeln('    }');
    }

    buffer
      ..writeln('    if (fields.isEmpty) {')
      ..writeln('      return null;')
      ..writeln('    }')
      ..writeln('    return QuerySelect(Set<String>.unmodifiable(fields));')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeCreateInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}CreateInput';
    final scalarFields = _scalarFields(schema, model);
    final relationFields = _relationFields(schema, model);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      if (_isRequiredCreateScalar(field)) {
        buffer.write('required this.${field.name}, ');
      } else {
        buffer.write('this.${field.name}, ');
      }
    }

    for (final field in relationFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: !_isRequiredCreateScalar(field))} ${field.name};',
      );
    }

    for (final field in relationFields) {
      final nestedType = _nestedCreateInputClassName(schema, model, field);
      buffer.writeln('  final $nestedType? ${field.name};');
    }

    _writeToDataMethod(buffer, schema, scalarFields);

    buffer
      ..writeln()
      ..writeln('  List<CreateRelationWrite> toNestedCreates() {')
      ..writeln('    final writes = <CreateRelationWrite>[];');

    for (final field in relationFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      writes.addAll(${field.name}!.toRelationWrites(${_relationLiteral(schema, model, field)}));',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return List<CreateRelationWrite>.unmodifiable(writes);')
      ..writeln('  }')
      ..writeln('}')
      ..writeln();
  }

  void _writeCreateWithoutInputs(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final emittedNames = <String>{};
    for (final relationField in _relationFields(schema, model)) {
      final className = _createWithoutInputClassName(
        schema,
        model,
        relationField,
      );
      if (!emittedNames.add(className)) {
        continue;
      }

      final scalarFields = _scalarFields(schema, model)
          .where(
            (field) => !_omittedRelationScalarFields(
              relationField,
            ).contains(field.name),
          )
          .toList(growable: false);
      buffer
        ..writeln('class $className {')
        ..write('  const $className({');

      for (final field in scalarFields) {
        if (_isRequiredCreateScalar(field)) {
          buffer.write('required this.${field.name}, ');
        } else {
          buffer.write('this.${field.name}, ');
        }
      }

      buffer
        ..writeln('});')
        ..writeln();

      for (final field in scalarFields) {
        buffer.writeln(
          '  final ${_dartFieldType(schema, field, optional: !_isRequiredCreateScalar(field))} ${field.name};',
        );
      }

      _writeToDataMethod(buffer, schema, scalarFields);

      buffer
        ..writeln()
        ..writeln(
          '  List<CreateRelationWrite> toNestedCreates() => const <CreateRelationWrite>[];',
        )
        ..writeln('}')
        ..writeln();
    }
  }

  void _writeUpdateInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}UpdateInput';
    final scalarFields = _scalarFields(
      schema,
      model,
    ).where((field) => !field.isId).toList(growable: false);

    buffer
      ..writeln('class $className {')
      ..write('  const $className({');

    for (final field in scalarFields) {
      buffer.write('this.${field.name}, ');
    }

    buffer
      ..writeln('});')
      ..writeln();

    for (final field in scalarFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: true)} ${field.name};',
      );
    }

    _writeOptionalToDataMethod(buffer, schema, scalarFields);

    buffer
      ..writeln('}')
      ..writeln();
  }

  void _writeNestedCreateInputs(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final emittedNames = <String>{};
    for (final relationField in _relationFields(schema, model)) {
      final className = _nestedCreateInputClassName(
        schema,
        model,
        relationField,
      );
      if (!emittedNames.add(className)) {
        continue;
      }

      final nestedItemClass = _createWithoutInputClassName(
        schema,
        _targetModel(schema, relationField),
        _oppositeRelationField(schema, model, relationField),
      );

      if (relationField.isList) {
        buffer
          ..writeln('class $className {')
          ..writeln(
            '  const $className({this.create = const <$nestedItemClass>[]});',
          )
          ..writeln()
          ..writeln('  final List<$nestedItemClass> create;')
          ..writeln()
          ..writeln(
            '  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {',
          )
          ..writeln('    if (create.isEmpty) {')
          ..writeln('      return const <CreateRelationWrite>[];')
          ..writeln('    }')
          ..writeln('    return <CreateRelationWrite>[')
          ..writeln('      CreateRelationWrite(')
          ..writeln('        relation: relation,')
          ..writeln(
            '        records: create.map((item) => item.toData()).toList(growable: false),',
          )
          ..writeln('      ),')
          ..writeln('    ];')
          ..writeln('  }')
          ..writeln('}')
          ..writeln();
      } else {
        buffer
          ..writeln('class $className {')
          ..writeln('  const $className({this.create});')
          ..writeln()
          ..writeln('  final $nestedItemClass? create;')
          ..writeln()
          ..writeln(
            '  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {',
          )
          ..writeln('    if (create == null) {')
          ..writeln('      return const <CreateRelationWrite>[];')
          ..writeln('    }')
          ..writeln('    return <CreateRelationWrite>[')
          ..writeln('      CreateRelationWrite(')
          ..writeln('        relation: relation,')
          ..writeln(
            '        records: <Map<String, Object?>>[create!.toData()],',
          )
          ..writeln('      ),')
          ..writeln('    ];')
          ..writeln('  }')
          ..writeln('}')
          ..writeln();
      }
    }
  }

  Set<String> _omittedRelationScalarFields(FieldDefinition relationField) {
    final relation = relationField.attribute('relation');
    if (relation == null) {
      return const <String>{};
    }

    return _parseRelationList(relation.arguments['fields']).toSet();
  }

  void _writeToDataMethod(
    StringBuffer buffer,
    SchemaDocument schema,
    List<FieldDefinition> scalarFields,
  ) {
    buffer
      ..writeln()
      ..writeln('  Map<String, Object?> toData() {')
      ..writeln('    final data = <String, Object?>{};');

    for (final field in scalarFields) {
      if (_isRequiredCreateScalar(field)) {
        buffer.writeln(
          '    data[${_stringLiteral(field.name)}] = ${_queryValueExpression(schema, field, field.name)};',
        );
      } else {
        buffer
          ..writeln('    if (${field.name} != null) {')
          ..writeln(
            '      data[${_stringLiteral(field.name)}] = ${_queryValueExpression(schema, field, field.name)};',
          )
          ..writeln('    }');
      }
    }

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(data);')
      ..writeln('  }');
  }

  void _writeOptionalToDataMethod(
    StringBuffer buffer,
    SchemaDocument schema,
    List<FieldDefinition> scalarFields,
  ) {
    buffer
      ..writeln()
      ..writeln('  Map<String, Object?> toData() {')
      ..writeln('    final data = <String, Object?>{};');

    for (final field in scalarFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      data[${_stringLiteral(field.name)}] = ${_queryValueExpression(schema, field, field.name)};',
        )
        ..writeln('    }');
    }

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(data);')
      ..writeln('  }');
  }

  List<FieldDefinition> _scalarFields(
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    return model.fields
        .where((field) => _isScalarLikeField(schema, field) && !field.isList)
        .toList(growable: false);
  }

  List<FieldDefinition> _relationFields(
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    return model.fields
        .where((field) => !_isScalarLikeField(schema, field))
        .toList(growable: false);
  }

  bool _isEnumField(SchemaDocument schema, FieldDefinition field) {
    return schema.findEnum(field.type) != null;
  }

  bool _isScalarLikeField(SchemaDocument schema, FieldDefinition field) {
    return field.isScalar || _isEnumField(schema, field);
  }

  bool _isRequiredCreateScalar(FieldDefinition field) {
    final hasDefault = field.attribute('default') != null;
    return !field.isNullable && !hasDefault && !field.isUpdatedAt;
  }

  ModelDefinition _targetModel(
    SchemaDocument schema,
    FieldDefinition relationField,
  ) {
    final targetModel = schema.findModel(relationField.type);
    if (targetModel == null) {
      throw StateError('Unknown model ${relationField.type} in generator.');
    }

    return targetModel;
  }

  FieldDefinition? _oppositeRelationField(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final targetModel = _targetModel(schema, relationField);
    final relationName = _relationName(relationField.attribute('relation'));
    final candidates = _relationFields(schema, targetModel)
        .where((candidate) => candidate.type == sourceModel.name)
        .where(
          (candidate) =>
              targetModel.name != sourceModel.name ||
              candidate.name != relationField.name,
        )
        .where((candidate) {
          final candidateRelationName = _relationName(
            candidate.attribute('relation'),
          );
          if (relationName != null && candidateRelationName != null) {
            return relationName == candidateRelationName;
          }
          return true;
        })
        .toList(growable: false);

    if (candidates.length == 1) {
      return candidates.single;
    }

    return null;
  }

  String? _relationName(FieldAttribute? relation) {
    if (relation == null) {
      return null;
    }

    final rawValue = relation.arguments['name'] ?? relation.arguments['value'];
    if (rawValue == null) {
      return null;
    }

    final trimmed = rawValue.trim();
    if (trimmed.startsWith('[')) {
      return null;
    }

    if (trimmed.length >= 2) {
      final first = trimmed[0];
      final last = trimmed[trimmed.length - 1];
      if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }

    return trimmed;
  }

  String _createWithoutInputClassName(
    SchemaDocument schema,
    ModelDefinition model,
    FieldDefinition? omittedRelation,
  ) {
    final suffix = omittedRelation == null
        ? 'Relations'
        : _pascalCase(omittedRelation.name);
    return '${model.name}CreateWithout${suffix}Input';
  }

  String _nestedCreateInputClassName(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final targetModel = _targetModel(schema, relationField);
    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final cardinality = relationField.isList ? 'Many' : 'One';
    final suffix = _pascalCase(opposite?.name ?? sourceModel.name);
    return '${targetModel.name}CreateNested${cardinality}Without${suffix}Input';
  }

  String _dartFieldType(
    SchemaDocument schema,
    FieldDefinition field, {
    required bool optional,
  }) {
    final String baseType;
    if (_isEnumField(schema, field)) {
      baseType = field.type;
    } else {
      baseType = switch (field.type) {
        'Int' => 'int',
        'String' => 'String',
        'Boolean' => 'bool',
        'DateTime' => 'DateTime',
        'Float' || 'Decimal' => 'double',
        'Bytes' => 'List<int>',
        'BigInt' => 'BigInt',
        'Json' => 'Object?',
        _ => 'Object?',
      };
    }

    if (!optional || baseType.endsWith('?')) {
      return baseType;
    }

    return '$baseType?';
  }

  String _modelFieldType(SchemaDocument schema, FieldDefinition field) {
    if (_isScalarLikeField(schema, field)) {
      return _dartFieldType(schema, field, optional: true);
    }

    if (field.isList) {
      return 'List<${field.type}>?';
    }

    return '${field.type}?';
  }

  String _fromRecordExpression(SchemaDocument schema, FieldDefinition field) {
    final recordAccess = "record[${_stringLiteral(field.name)}]";
    if (_isScalarLikeField(schema, field)) {
      return _fromScalarRecordExpression(schema, field, recordAccess);
    }

    if (field.isList) {
      return '($recordAccess as List<Object?>?)?.map((item) => ${field.type}.fromRecord(item as Map<String, Object?>)).toList(growable: false)';
    }

    return '$recordAccess == null ? null : ${field.type}.fromRecord($recordAccess as Map<String, Object?>)';
  }

  String _fromJsonExpression(SchemaDocument schema, FieldDefinition field) {
    final jsonAccess = "json[${_stringLiteral(field.name)}]";
    if (_isScalarLikeField(schema, field)) {
      return _fromScalarRecordExpression(schema, field, jsonAccess);
    }

    if (field.isList) {
      return '($jsonAccess as List<Object?>?)?.map((item) => ${field.type}.fromJson(item as Map<String, Object?>)).toList(growable: false)';
    }

    return '$jsonAccess == null ? null : ${field.type}.fromJson($jsonAccess as Map<String, Object?>)';
  }

  String _fromScalarRecordExpression(
    SchemaDocument schema,
    FieldDefinition field,
    String recordAccess,
  ) {
    if (_isEnumField(schema, field)) {
      return '$recordAccess == null ? null : ${field.type}.values.byName($recordAccess as String)';
    }

    return switch (field.type) {
      'Int' => '$recordAccess as int?',
      'String' => '$recordAccess as String?',
      'Boolean' => '$recordAccess as bool?',
      'DateTime' => '_asDateTime($recordAccess)',
      'Float' || 'Decimal' => '_asDouble($recordAccess)',
      'Bytes' => '_asBytes($recordAccess)',
      'BigInt' => '_asBigInt($recordAccess)',
      'Json' => recordAccess,
      _ => '$recordAccess as ${field.type}?',
    };
  }

  String _toRecordExpression(SchemaDocument schema, FieldDefinition field) {
    if (_isEnumField(schema, field)) {
      return '${field.name}!.name';
    }

    if (_isScalarLikeField(schema, field)) {
      return field.name;
    }

    if (field.isList) {
      return '${field.name}!.map((item) => item.toRecord()).toList(growable: false)';
    }

    return '${field.name}!.toRecord()';
  }

  String _toJsonExpression(SchemaDocument schema, FieldDefinition field) {
    if (_isEnumField(schema, field)) {
      return '${field.name}!.name';
    }

    if (_isScalarLikeField(schema, field)) {
      return switch (field.type) {
        'DateTime' => '${field.name}!.toIso8601String()',
        'BigInt' => '${field.name}!.toString()',
        'Json' => '_jsonEncodable(${field.name})',
        _ => field.name,
      };
    }

    if (field.isList) {
      return '${field.name}!.map((item) => item.toJson()).toList(growable: false)';
    }

    return '${field.name}!.toJson()';
  }

  String _queryValueExpression(
    SchemaDocument schema,
    FieldDefinition field,
    String variableName,
  ) {
    if (_isEnumField(schema, field)) {
      return '_enumName($variableName)';
    }
    return variableName;
  }

  List<FieldDefinition> _numericAggregateFields(
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    return _scalarFields(schema, model)
        .where(
          (field) =>
              !_isEnumField(schema, field) &&
              (field.type == 'Int' ||
                  field.type == 'Float' ||
                  field.type == 'Decimal'),
        )
        .toList(growable: false);
  }

  List<FieldDefinition> _comparableAggregateFields(
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    return _scalarFields(schema, model)
        .where(
          (field) =>
              _isEnumField(schema, field) ||
              field.type == 'Int' ||
              field.type == 'Float' ||
              field.type == 'Decimal' ||
              field.type == 'String' ||
              field.type == 'Boolean' ||
              field.type == 'DateTime' ||
              field.type == 'BigInt',
        )
        .toList(growable: false);
  }

  String _aggregateResultFieldType(
    SchemaDocument schema,
    FieldDefinition field,
    String className,
  ) {
    if (className.endsWith('CountAggregateResult')) {
      return 'int?';
    }
    if (className.endsWith('AvgAggregateResult')) {
      return 'double?';
    }
    if (className.endsWith('SumAggregateResult')) {
      return field.type == 'Int' ? 'int?' : 'double?';
    }
    return _dartFieldType(schema, field, optional: true);
  }

  String _aggregateValueExpression(
    SchemaDocument schema,
    FieldDefinition field,
    String access, {
    required String aggregateKind,
  }) {
    switch (aggregateKind) {
      case 'avg':
        return '_asDouble($access)';
      case 'sum':
        if (field.type == 'Int') {
          return '$access?.toInt()';
        }
        return '_asDouble($access)';
      case 'min':
      case 'max':
        return _fromScalarRecordExpression(schema, field, access);
      default:
        return access;
    }
  }

  String _pascalCase(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String _relationLiteral(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    if (relationField.isList && opposite?.isList == true) {
      final targetModel = _targetModel(schema, relationField);
      final sourceKeyFields = _implicitManyToManyKeyFields(sourceModel);
      final targetKeyFields = _implicitManyToManyKeyFields(targetModel);
      return 'QueryRelation(field: ${_stringLiteral(relationField.name)}, targetModel: ${_stringLiteral(relationField.type)}, cardinality: QueryRelationCardinality.many, localKeyField: ${_stringLiteral(sourceKeyFields.first)}, targetKeyField: ${_stringLiteral(targetKeyFields.first)}, localKeyFields: ${_stringListLiteral(sourceKeyFields)}, targetKeyFields: ${_stringListLiteral(targetKeyFields)}, storageKind: QueryRelationStorageKind.implicitManyToMany, sourceModel: ${_stringLiteral(sourceModel.name)}, inverseField: ${_stringLiteral(opposite!.name)})';
    }

    final metadata = _relationMetadata(schema, sourceModel, relationField);
    final cardinality = relationField.isList
        ? 'QueryRelationCardinality.many'
        : 'QueryRelationCardinality.one';

    return 'QueryRelation(field: ${_stringLiteral(relationField.name)}, targetModel: ${_stringLiteral(relationField.type)}, cardinality: $cardinality, localKeyField: ${_stringLiteral(metadata.$1)}, targetKeyField: ${_stringLiteral(metadata.$2)})';
  }

  (String, String) _relationMetadata(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final ownRelation = relationField.attribute('relation');
    if (ownRelation != null) {
      final fields = _parseRelationList(ownRelation.arguments['fields']);
      final references = _parseRelationList(
        ownRelation.arguments['references'],
      );
      if (fields.length == 1 && references.length == 1) {
        return (fields.single, references.single);
      }
    }

    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final oppositeRelation = opposite?.attribute('relation');
    if (oppositeRelation != null) {
      final fields = _parseRelationList(oppositeRelation.arguments['fields']);
      final references = _parseRelationList(
        oppositeRelation.arguments['references'],
      );
      if (fields.length == 1 && references.length == 1) {
        return (references.single, fields.single);
      }
    }

    throw StateError(
      'Unable to infer relation metadata for ${sourceModel.name}.${relationField.name}.',
    );
  }

  List<String> _implicitManyToManyKeyFields(ModelDefinition model) {
    final fieldLevelIds = model.fields
        .where((field) => field.isId)
        .map((field) => field.name)
        .toList(growable: false);
    if (fieldLevelIds.isNotEmpty) {
      return List<String>.unmodifiable(fieldLevelIds);
    }

    if (model.primaryKeyFields.isNotEmpty) {
      return List<String>.unmodifiable(model.primaryKeyFields);
    }

    throw StateError(
      'Implicit many-to-many relations require an @id or @@id on model ${model.name}.',
    );
  }

  String _stringListLiteral(List<String> values) {
    return 'const <String>[${values.map(_stringLiteral).join(', ')}]';
  }

  List<String> _parseRelationList(String? raw) {
    if (raw == null) {
      return const <String>[];
    }

    final trimmed = raw.trim();
    if (!trimmed.startsWith('[') || !trimmed.endsWith(']')) {
      return <String>[trimmed];
    }

    final inner = trimmed.substring(1, trimmed.length - 1).trim();
    if (inner.isEmpty) {
      return const <String>[];
    }

    return inner
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<FieldDefinition> _scalarUniqueFields(
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final byName = <String, FieldDefinition>{};

    for (final field in _scalarFields(schema, model)) {
      if (field.isId || field.isUnique) {
        byName[field.name] = field;
      }
    }

    for (final fieldNames in <List<String>>[
      model.primaryKeyFields,
      ...model.compoundUniqueFieldSets,
    ]) {
      if (fieldNames.length != 1) {
        continue;
      }
      final field = model.findField(fieldNames.single);
      if (field != null && _isScalarLikeField(schema, field) && !field.isList) {
        byName[field.name] = field;
      }
    }

    return byName.values.toList(growable: false);
  }

  List<List<String>> _compoundUniqueFieldSets(ModelDefinition model) {
    final uniqueSets = <String, List<String>>{};

    if (model.primaryKeyFields.length > 1) {
      uniqueSets[model.primaryKeyFields.join('|')] = model.primaryKeyFields;
    }

    for (final fieldNames in model.compoundUniqueFieldSets) {
      if (fieldNames.length <= 1) {
        continue;
      }
      uniqueSets[fieldNames.join('|')] = fieldNames;
    }

    return uniqueSets.values.toList(growable: false);
  }

  String _compoundUniqueInputClassName(
    ModelDefinition model,
    List<String> fieldNames,
  ) {
    final suffix = fieldNames.map(_pascalCase).join();
    return '${model.name}${suffix}CompoundUniqueInput';
  }

  String _compoundUniqueSelectorName(List<String> fieldNames) {
    return fieldNames.join('_');
  }

  String _stringLiteral(String value) => "'${value.replaceAll("'", r"\'")}'";

  String _lowercaseFirst(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toLowerCase() + value.substring(1);
  }
}
