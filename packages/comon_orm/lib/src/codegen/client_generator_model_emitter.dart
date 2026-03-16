part of 'client_generator.dart';

extension on ClientGenerator {
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
}
