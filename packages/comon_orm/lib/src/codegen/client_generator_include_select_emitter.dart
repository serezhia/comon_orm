part of 'client_generator.dart';

extension on ClientGenerator {
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
}
