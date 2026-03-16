part of 'client_generator.dart';

extension on ClientGenerator {
  void _writeScalarUpdateOperationHelpers(StringBuffer buffer) {
    buffer
      ..writeln('class StringFieldUpdateOperationsInput {')
      ..writeln(
        '  const StringFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln()
      ..writeln('class BoolFieldUpdateOperationsInput {')
      ..writeln(
        '  const BoolFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln()
      ..writeln('class DateTimeFieldUpdateOperationsInput {')
      ..writeln(
        '  const DateTimeFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln()
      ..writeln('class BytesFieldUpdateOperationsInput {')
      ..writeln(
        '  const BytesFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln()
      ..writeln('class JsonFieldUpdateOperationsInput {')
      ..writeln(
        '  const JsonFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln()
      ..writeln('class IntFieldUpdateOperationsInput {')
      ..writeln(
        '  const IntFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln('  final int? increment;')
      ..writeln('  final int? decrement;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln(
        '  bool get hasComputedUpdate => increment != null || decrement != null;',
      )
      ..writeln(
        '  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;',
      )
      ..writeln('}')
      ..writeln()
      ..writeln('class DoubleFieldUpdateOperationsInput {')
      ..writeln(
        '  const DoubleFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln('  final double? increment;')
      ..writeln('  final double? decrement;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln(
        '  bool get hasComputedUpdate => increment != null || decrement != null;',
      )
      ..writeln(
        '  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;',
      )
      ..writeln('}')
      ..writeln()
      ..writeln('class BigIntFieldUpdateOperationsInput {')
      ..writeln(
        '  const BigIntFieldUpdateOperationsInput({this.set = _undefined, this.increment, this.decrement});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln('  final BigInt? increment;')
      ..writeln('  final BigInt? decrement;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln(
        '  bool get hasComputedUpdate => increment != null || decrement != null;',
      )
      ..writeln(
        '  bool get hasMultipleOperations => (hasSet ? 1 : 0) + (increment != null ? 1 : 0) + (decrement != null ? 1 : 0) > 1;',
      )
      ..writeln('}')
      ..writeln()
      ..writeln('class EnumFieldUpdateOperationsInput<T extends Enum> {')
      ..writeln(
        '  const EnumFieldUpdateOperationsInput({this.set = _undefined});',
      )
      ..writeln()
      ..writeln('  final Object? set;')
      ..writeln()
      ..writeln('  bool get hasSet => !identical(set, _undefined);')
      ..writeln('}')
      ..writeln();
  }

  void _writeCreateInput(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final className = '${model.name}CreateInput';
    final updateInputName = '${model.name}UpdateInput';
    final scalarFields = _scalarFields(schema, model);
    final scalarUniqueFields = _scalarUniqueFields(schema, model);
    final compoundUniqueFieldSets = _compoundUniqueFieldSets(model);
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
      ..writeln('  List<List<QueryPredicate>> toUniqueSelectorPredicates() {')
      ..writeln('    final selectors = <List<QueryPredicate>>[];');

    for (final field in scalarUniqueFields) {
      final isOptional = !_isRequiredCreateScalar(field);
      if (isOptional) {
        buffer.writeln('    if (${field.name} != null) {');
      }
      buffer
        ..writeln('      selectors.add(<QueryPredicate>[')
        ..writeln(
          '        QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('equals')}, value: ${_queryValueExpression(schema, field, field.name)}),',
        )
        ..writeln('      ]);');
      if (isOptional) {
        buffer.writeln('    }');
      }
    }

    for (final fieldNames in compoundUniqueFieldSets) {
      final fields = fieldNames
          .map((name) => model.findField(name))
          .whereType<FieldDefinition>()
          .toList(growable: false);
      final optionalChecks = fields
          .where((field) => !_isRequiredCreateScalar(field))
          .map((field) => '${field.name} != null')
          .toList(growable: false);
      if (optionalChecks.isNotEmpty) {
        buffer.writeln('    if (${optionalChecks.join(' && ')}) {');
      }
      buffer.writeln('      selectors.add(<QueryPredicate>[');
      for (final field in fields) {
        buffer.writeln(
          '        QueryPredicate(field: ${_stringLiteral(field.name)}, operator: ${_stringLiteral('equals')}, value: ${_queryValueExpression(schema, field, field.name)}),',
        );
      }
      buffer.writeln('      ]);');
      if (optionalChecks.isNotEmpty) {
        buffer.writeln('    }');
      }
    }

    buffer
      ..writeln(
        '    return List<List<QueryPredicate>>.unmodifiable(selectors.map(List<QueryPredicate>.unmodifiable));',
      )
      ..writeln('  }');

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
      ..writeln()
      ..writeln('  bool get hasDeferredRelationWrites {');

    if (relationFields.isEmpty) {
      buffer.writeln('    return false;');
    } else {
      buffer.writeln(
        '    return ${relationFields.map((field) => '(${field.name}?.hasDeferredWrites ?? false)').join(' || ')};',
      );
    }

    buffer
      ..writeln('  }')
      ..writeln()
      ..writeln('  $updateInputName toDeferredRelationUpdateInput() {')
      ..writeln('    return $updateInputName(');

    for (final field in relationFields) {
      buffer.writeln(
        '      ${field.name}: ${field.name}?.toDeferredUpdateWrite(),',
      );
    }

    buffer
      ..writeln('    );')
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

  void _writeConnectOrCreateInputs(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final emittedNames = <String>{};
    for (final relationField in _relationFields(schema, model)) {
      final className = _connectOrCreateInputClassName(
        schema,
        model,
        relationField,
      );
      if (!emittedNames.add(className)) {
        continue;
      }

      final targetModel = _targetModel(schema, relationField);
      final opposite = _oppositeRelationField(schema, model, relationField);
      final whereUniqueName = '${targetModel.name}WhereUniqueInput';
      final createWithoutName = _createWithoutInputClassName(
        schema,
        targetModel,
        opposite,
      );

      buffer
        ..writeln('class $className {')
        ..writeln(
          '  const $className({required this.where, required this.create});',
        )
        ..writeln()
        ..writeln('  final $whereUniqueName where;')
        ..writeln('  final $createWithoutName create;')
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
    final relationFields = _relationFields(schema, model);

    buffer.writeln('class $className {');
    if (scalarFields.isEmpty && relationFields.isEmpty) {
      buffer
        ..writeln('  const $className();')
        ..writeln();
    } else {
      buffer.write('  const $className({');

      for (final field in scalarFields) {
        buffer.write('this.${field.name}, ');
        final operationType = _updateOperationInputType(schema, field);
        if (operationType != null) {
          buffer.write('this.${field.name}Ops, ');
        }
      }

      for (final field in relationFields) {
        buffer.write('this.${field.name}, ');
      }

      buffer
        ..writeln('});')
        ..writeln();
    }

    for (final field in scalarFields) {
      buffer.writeln(
        '  final ${_dartFieldType(schema, field, optional: true)} ${field.name};',
      );
      final operationType = _updateOperationInputType(schema, field);
      if (operationType != null) {
        buffer.writeln('  final $operationType? ${field.name}Ops;');
      }
    }

    for (final field in relationFields) {
      final nestedType = _nestedUpdateInputClassName(schema, model, field);
      buffer.writeln('  final $nestedType? ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  bool get hasComputedOperators {');

    final computedFields = scalarFields
        .where((field) => _supportsComputedUpdateOperator(schema, field))
        .toList(growable: false);
    if (computedFields.isEmpty) {
      buffer
        ..writeln('    return false;')
        ..writeln('  }');
    } else {
      buffer.write('    return ');
      for (var index = 0; index < computedFields.length; index++) {
        final field = computedFields[index];
        if (index > 0) {
          buffer.write(' || ');
        }
        buffer.write('${field.name}Ops?.hasComputedUpdate == true');
      }
      buffer
        ..writeln(';')
        ..writeln('  }');
    }

    buffer
      ..writeln()
      ..writeln('  bool get hasRelationWrites {');

    if (relationFields.isEmpty) {
      buffer
        ..writeln('    return false;')
        ..writeln('  }');
    } else {
      buffer.write('    return ');
      for (var index = 0; index < relationFields.length; index++) {
        if (index > 0) {
          buffer.write(' || ');
        }
        final field = relationFields[index];
        buffer.write('${field.name}?.hasWrites == true');
      }
      buffer
        ..writeln(';')
        ..writeln('  }');
    }

    buffer
      ..writeln()
      ..writeln('  Map<String, Object?> toData() {')
      ..writeln('    final data = <String, Object?>{};');

    for (final field in scalarFields) {
      final operationType = _updateOperationInputType(schema, field);
      if (operationType != null) {
        buffer
          ..writeln(
            '    if (${field.name} != null && ${field.name}Ops != null) {',
          )
          ..writeln(
            '      throw StateError(${_stringLiteral('Only one of ${field.name} or ${field.name}Ops may be provided for $className.${field.name}.')});',
          )
          ..writeln('    }');
      }

      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      data[${_stringLiteral(field.name)}] = ${_queryValueExpression(schema, field, field.name)};',
        )
        ..writeln('    }');

      if (operationType == null) {
        continue;
      }

      buffer
        ..writeln('    if (${field.name}Ops != null) {')
        ..writeln('      final ops = ${field.name}Ops!;');

      if (_supportsComputedUpdateOperator(schema, field)) {
        buffer
          ..writeln('      if (ops.hasMultipleOperations) {')
          ..writeln(
            '        throw StateError(${_stringLiteral('Only one scalar update operator may be provided for $className.${field.name}.')});',
          )
          ..writeln('      }')
          ..writeln('      if (ops.hasComputedUpdate) {')
          ..writeln(
            '        throw StateError(${_stringLiteral('Computed scalar update operators for $className.${field.name} require the current record value before they can be converted to raw update data.')});',
          )
          ..writeln('      }');
      }

      buffer
        ..writeln('      if (ops.hasSet) {')
        ..writeln(
          '        data[${_stringLiteral(field.name)}] = ${_updateOperationSetValueExpression(schema, field, 'ops.set')};',
        )
        ..writeln('      }')
        ..writeln('    }');
    }

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(data);')
      ..writeln('  }');

    buffer
      ..writeln()
      ..writeln(
        '  Map<String, Object?> resolveDataAgainstRecord(Map<String, Object?> record) {',
      )
      ..writeln('    final data = <String, Object?>{};');

    for (final field in scalarFields) {
      final operationType = _updateOperationInputType(schema, field);
      if (operationType != null) {
        buffer
          ..writeln(
            '    if (${field.name} != null && ${field.name}Ops != null) {',
          )
          ..writeln(
            '      throw StateError(${_stringLiteral('Only one of ${field.name} or ${field.name}Ops may be provided for $className.${field.name}.')});',
          )
          ..writeln('    }');
      }

      buffer
        ..writeln('    if (${field.name} != null) {')
        ..writeln(
          '      data[${_stringLiteral(field.name)}] = ${_queryValueExpression(schema, field, field.name)};',
        )
        ..writeln('    }');

      if (operationType == null) {
        continue;
      }

      buffer
        ..writeln('    if (${field.name}Ops != null) {')
        ..writeln('      final ops = ${field.name}Ops!;');

      if (_supportsComputedUpdateOperator(schema, field)) {
        final currentExpression = _fromScalarRecordExpression(
          schema,
          field,
          "record[${_stringLiteral(field.name)}]",
        );
        buffer
          ..writeln('      if (ops.hasMultipleOperations) {')
          ..writeln(
            '        throw StateError(${_stringLiteral('Only one scalar update operator may be provided for $className.${field.name}.')});',
          )
          ..writeln('      }')
          ..writeln('      if (ops.hasSet) {')
          ..writeln(
            '        data[${_stringLiteral(field.name)}] = ${_updateOperationSetValueExpression(schema, field, 'ops.set')};',
          )
          ..writeln('      } else {')
          ..writeln('        final currentValue = $currentExpression;');

        if (field.type == 'Int') {
          buffer
            ..writeln('        if (ops.increment != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot increment $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue + ops.increment!;',
            )
            ..writeln('        }')
            ..writeln('        if (ops.decrement != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot decrement $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue - ops.decrement!;',
            )
            ..writeln('        }');
        } else if (field.type == 'BigInt') {
          buffer
            ..writeln('        if (ops.increment != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot increment $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue + ops.increment!;',
            )
            ..writeln('        }')
            ..writeln('        if (ops.decrement != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot decrement $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue - ops.decrement!;',
            )
            ..writeln('        }');
        } else {
          buffer
            ..writeln('        if (ops.increment != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot increment $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue + ops.increment!;',
            )
            ..writeln('        }')
            ..writeln('        if (ops.decrement != null) {')
            ..writeln('          if (currentValue == null) {')
            ..writeln(
              '            throw StateError(${_stringLiteral('Cannot decrement $className.${field.name} because the current value is null.')});',
            )
            ..writeln('          }')
            ..writeln(
              '          data[${_stringLiteral(field.name)}] = currentValue - ops.decrement!;',
            )
            ..writeln('        }');
        }

        buffer.writeln('      }');
      } else {
        buffer
          ..writeln('      if (ops.hasSet) {')
          ..writeln(
            '        data[${_stringLiteral(field.name)}] = ${_updateOperationSetValueExpression(schema, field, 'ops.set')};',
          )
          ..writeln('      }');
      }

      buffer.writeln('    }');
    }

    buffer
      ..writeln('    return Map<String, Object?>.unmodifiable(data);')
      ..writeln('  }');

    buffer
      ..writeln('}')
      ..writeln();
  }

  void _writeNestedUpdateInputs(
    StringBuffer buffer,
    SchemaDocument schema,
    ModelDefinition model,
  ) {
    final emittedNames = <String>{};
    for (final relationField in _relationFields(schema, model)) {
      final className = _nestedUpdateInputClassName(
        schema,
        model,
        relationField,
      );
      if (!emittedNames.add(className)) {
        continue;
      }

      final targetModel = _targetModel(schema, relationField);
      final whereUniqueName = '${targetModel.name}WhereUniqueInput';
      final connectOrCreateName = _connectOrCreateInputClassName(
        schema,
        model,
        relationField,
      );

      if (relationField.isList) {
        buffer
          ..writeln('class $className {')
          ..writeln(
            '  const $className({this.connect = const <$whereUniqueName>[], this.disconnect = const <$whereUniqueName>[], this.connectOrCreate = const <$connectOrCreateName>[], this.set});',
          )
          ..writeln()
          ..writeln('  final List<$whereUniqueName> connect;')
          ..writeln('  final List<$whereUniqueName> disconnect;')
          ..writeln('  final List<$connectOrCreateName> connectOrCreate;')
          ..writeln('  final List<$whereUniqueName>? set;')
          ..writeln()
          ..writeln(
            '  bool get hasWrites => connect.isNotEmpty || disconnect.isNotEmpty || connectOrCreate.isNotEmpty || set != null;',
          )
          ..writeln('}')
          ..writeln();
      } else {
        buffer
          ..writeln('class $className {')
          ..writeln(
            '  const $className({this.connect, this.connectOrCreate, this.disconnect = false});',
          )
          ..writeln()
          ..writeln('  final $whereUniqueName? connect;')
          ..writeln('  final $connectOrCreateName? connectOrCreate;')
          ..writeln('  final bool disconnect;')
          ..writeln()
          ..writeln(
            '  bool get hasWrites => connect != null || connectOrCreate != null || disconnect;',
          )
          ..writeln('}')
          ..writeln();
      }
    }
  }

  String? _updateOperationInputType(
    SchemaDocument schema,
    FieldDefinition field,
  ) {
    if (_isEnumField(schema, field)) {
      return 'EnumFieldUpdateOperationsInput<${field.type}>';
    }

    return switch (field.type) {
      'String' => 'StringFieldUpdateOperationsInput',
      'Boolean' => 'BoolFieldUpdateOperationsInput',
      'DateTime' => 'DateTimeFieldUpdateOperationsInput',
      'Int' => 'IntFieldUpdateOperationsInput',
      'Float' || 'Decimal' => 'DoubleFieldUpdateOperationsInput',
      'BigInt' => 'BigIntFieldUpdateOperationsInput',
      'Bytes' => 'BytesFieldUpdateOperationsInput',
      'Json' => 'JsonFieldUpdateOperationsInput',
      _ => null,
    };
  }

  bool _supportsComputedUpdateOperator(
    SchemaDocument schema,
    FieldDefinition field,
  ) {
    if (_isEnumField(schema, field)) {
      return false;
    }

    return field.type == 'Int' ||
        field.type == 'Float' ||
        field.type == 'Decimal' ||
        field.type == 'BigInt';
  }

  String _updateOperationSetValueExpression(
    SchemaDocument schema,
    FieldDefinition field,
    String access,
  ) {
    if (_isEnumField(schema, field)) {
      return '_enumName($access as ${field.type}?)';
    }

    return switch (field.type) {
      'Int' => '$access as int?',
      'String' => '$access as String?',
      'Boolean' => '$access as bool?',
      'DateTime' => '$access as DateTime?',
      'Float' || 'Decimal' => '$access as double?',
      'Bytes' => '$access as List<int>?',
      'BigInt' => '$access as BigInt?',
      'Json' => access,
      _ => '$access as Object?',
    };
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

      final targetModel = _targetModel(schema, relationField);
      final whereUniqueName = '${targetModel.name}WhereUniqueInput';
      final connectOrCreateName = _connectOrCreateInputClassName(
        schema,
        model,
        relationField,
      );
      final updateNestedClassName = _nestedUpdateInputClassName(
        schema,
        model,
        relationField,
      );

      final nestedItemClass = _createWithoutInputClassName(
        schema,
        targetModel,
        _oppositeRelationField(schema, model, relationField),
      );

      if (relationField.isList) {
        buffer
          ..writeln('class $className {')
          ..writeln(
            '  const $className({this.create = const <$nestedItemClass>[], this.connect = const <$whereUniqueName>[], this.disconnect = const <$whereUniqueName>[], this.connectOrCreate = const <$connectOrCreateName>[], this.set});',
          )
          ..writeln()
          ..writeln('  final List<$nestedItemClass> create;')
          ..writeln('  final List<$whereUniqueName> connect;')
          ..writeln('  final List<$whereUniqueName> disconnect;')
          ..writeln('  final List<$connectOrCreateName> connectOrCreate;')
          ..writeln('  final List<$whereUniqueName>? set;')
          ..writeln()
          ..writeln(
            '  bool get hasDeferredWrites => connect.isNotEmpty || disconnect.isNotEmpty || connectOrCreate.isNotEmpty || set != null;',
          )
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
          ..writeln()
          ..writeln('  $updateNestedClassName? toDeferredUpdateWrite() {')
          ..writeln('    if (!hasDeferredWrites) {')
          ..writeln('      return null;')
          ..writeln('    }')
          ..writeln(
            '    return $updateNestedClassName(connect: connect, disconnect: disconnect, connectOrCreate: connectOrCreate, set: set);',
          )
          ..writeln('  }')
          ..writeln('}')
          ..writeln();
      } else {
        buffer
          ..writeln('class $className {')
          ..writeln(
            '  const $className({this.create, this.connect, this.connectOrCreate, this.disconnect = false});',
          )
          ..writeln()
          ..writeln('  final $nestedItemClass? create;')
          ..writeln('  final $whereUniqueName? connect;')
          ..writeln('  final $connectOrCreateName? connectOrCreate;')
          ..writeln('  final bool disconnect;')
          ..writeln()
          ..writeln(
            '  bool get hasDeferredWrites => connect != null || connectOrCreate != null || disconnect;',
          )
          ..writeln()
          ..writeln(
            '  List<CreateRelationWrite> toRelationWrites(QueryRelation relation) {',
          )
          ..writeln(
            '    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);',
          )
          ..writeln('    if (nestedWriteCount > 1) {')
          ..writeln(
            '      throw StateError(${_stringLiteral('Only one of create, connect, connectOrCreate or disconnect may be provided for $className.')});',
          )
          ..writeln('    }')
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
          ..writeln()
          ..writeln('  $updateNestedClassName? toDeferredUpdateWrite() {')
          ..writeln(
            '    final nestedWriteCount = (create != null ? 1 : 0) + (connect != null ? 1 : 0) + (connectOrCreate != null ? 1 : 0) + (disconnect ? 1 : 0);',
          )
          ..writeln('    if (nestedWriteCount > 1) {')
          ..writeln(
            '      throw StateError(${_stringLiteral('Only one of create, connect, connectOrCreate or disconnect may be provided for $className.')});',
          )
          ..writeln('    }')
          ..writeln('    if (!hasDeferredWrites) {')
          ..writeln('      return null;')
          ..writeln('    }')
          ..writeln(
            '    return $updateNestedClassName(connect: connect, connectOrCreate: connectOrCreate, disconnect: disconnect);',
          )
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
}
