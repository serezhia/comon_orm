part of 'client_generator.dart';

extension on ClientGenerator {
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
      ..writeln()
      ..writeln('  bool matchesRecord(Map<String, Object?> record) {')
      ..writeln('    var selectorCount = 0;')
      ..writeln('    var matches = false;');

    for (final field in scalarUniqueFields) {
      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln('      selectorCount++;')
        ..writeln(
          '      matches = record[${_stringLiteral(field.name)}] == ${_queryValueExpression(schema, field, field.name)};',
        )
        ..writeln('    }');
    }

    for (final fieldNames in compoundUniqueFieldSets) {
      final selectorName = _compoundUniqueSelectorName(fieldNames);
      buffer
        ..writeln('    if ($selectorName != null) {')
        ..writeln('      selectorCount++;')
        ..writeln('      matches = $selectorName!.matchesRecord(record);')
        ..writeln('    }');
    }

    buffer
      ..writeln('    if (selectorCount != 1) {')
      ..writeln(
        '      throw StateError(${_stringLiteral('Exactly one unique selector must be provided for $className.')});',
      )
      ..writeln('    }')
      ..writeln('    return matches;')
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
      ..writeln()
      ..writeln('  bool matchesRecord(Map<String, Object?> record) {')
      ..write('    return ');

    for (var index = 0; index < fields.length; index++) {
      final field = fields[index];
      if (index > 0) {
        buffer.write(' && ');
      }
      buffer.write(
        'record[${_stringLiteral(field.name)}] == ${_queryValueExpression(schema, field, field.name)}',
      );
    }

    buffer
      ..writeln(';')
      ..writeln('  }')
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
}
