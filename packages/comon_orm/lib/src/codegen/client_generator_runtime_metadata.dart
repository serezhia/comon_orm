part of 'client_generator.dart';

extension on ClientGenerator {
  void _writeGeneratedRuntimeMetadata(
    StringBuffer buffer,
    SchemaDocument schema,
  ) {
    buffer
      ..writeln('class GeneratedComonOrmMetadata {')
      ..writeln('  const GeneratedComonOrmMetadata._();')
      ..writeln()
      ..writeln(
        '  static const GeneratedRuntimeSchema schema = GeneratedRuntimeSchema(',
      )
      ..writeln('    datasources: <GeneratedDatasourceMetadata>[');

    for (final datasource in schema.datasources) {
      buffer.writeln(_datasourceMetadataLiteral(datasource, indent: '      '));
    }

    buffer
      ..writeln('    ],')
      ..writeln('    enums: <GeneratedEnumMetadata>[');

    for (final definition in schema.enums) {
      buffer.writeln(_enumMetadataLiteral(definition, indent: '      '));
    }

    buffer
      ..writeln('    ],')
      ..writeln('    models: <GeneratedModelMetadata>[');

    for (final model in schema.models) {
      buffer.writeln(_modelMetadataLiteral(schema, model, indent: '      '));
    }

    buffer
      ..writeln('    ],')
      ..writeln('  );')
      ..writeln('}')
      ..writeln();
  }

  String _datasourceMetadataLiteral(
    DatasourceDefinition definition, {
    required String indent,
  }) {
    final provider = _resolvedDatasourceProvider(definition);
    final url = _datasourceUrlLiteral(definition.properties['url'] ?? '');
    return '${indent}GeneratedDatasourceMetadata(\n'
        '$indent  name: ${_stringLiteral(definition.name)},\n'
        '$indent  provider: ${_stringLiteral(provider)},\n'
        '$indent  url: $url,\n'
        '$indent),';
  }

  String _enumMetadataLiteral(
    EnumDefinition definition, {
    required String indent,
  }) {
    return '${indent}GeneratedEnumMetadata(\n'
        '$indent  name: ${_stringLiteral(definition.name)},\n'
        '$indent  databaseName: ${_stringLiteral(definition.databaseName)},\n'
        '$indent  values: ${_generatedStringListLiteral(definition.values)},\n'
        '$indent),';
  }

  String _modelMetadataLiteral(
    SchemaDocument schema,
    ModelDefinition model, {
    required String indent,
  }) {
    final fieldLiterals = model.fields
        .map(
          (field) => _fieldMetadataLiteral(
            schema,
            model,
            field,
            indent: '$indent    ',
          ),
        )
        .join('\n');
    return '${indent}GeneratedModelMetadata(\n'
        '$indent  name: ${_stringLiteral(model.name)},\n'
        '$indent  databaseName: ${_stringLiteral(model.databaseName)},\n'
        '$indent  primaryKeyFields: ${_generatedStringListLiteral(_primaryKeyFields(model))},\n'
        '$indent  compoundUniqueFieldSets: ${_generatedNestedStringListLiteral(model.compoundUniqueFieldSets.toList(growable: false))},\n'
        '$indent  fields: <GeneratedFieldMetadata>[\n'
        '$fieldLiterals\n'
        '$indent  ],\n'
        '$indent),';
  }

  String _fieldMetadataLiteral(
    SchemaDocument schema,
    ModelDefinition model,
    FieldDefinition field, {
    required String indent,
  }) {
    final buffer = StringBuffer()
      ..writeln('${indent}GeneratedFieldMetadata(')
      ..writeln('$indent  name: ${_stringLiteral(field.name)},')
      ..writeln('$indent  databaseName: ${_stringLiteral(field.databaseName)},')
      ..writeln('$indent  kind: ${_generatedFieldKindLiteral(schema, field)},')
      ..writeln('$indent  type: ${_stringLiteral(field.type)},')
      ..writeln('$indent  isNullable: ${field.isNullable},')
      ..writeln('$indent  isList: ${field.isList},')
      ..writeln('$indent  isId: ${field.isId},')
      ..writeln('$indent  isUnique: ${field.isUnique},')
      ..writeln('$indent  isUpdatedAt: ${field.isUpdatedAt},');

    final nativeType = field.nativeTypeAttribute?.name;
    if (nativeType != null) {
      buffer.writeln('$indent  nativeType: ${_stringLiteral(nativeType)},');
    }

    final defaultLiteral = _fieldDefaultLiteral(field);
    if (defaultLiteral != null) {
      buffer.writeln('$indent  defaultValue: $defaultLiteral,');
    }

    final relationLiteral = _generatedRelationLiteral(
      schema,
      model,
      field,
      indent: '$indent  ',
    );
    if (relationLiteral != null) {
      buffer.writeln('$indent  relation: $relationLiteral,');
    }

    buffer.write('$indent),');
    return buffer.toString();
  }

  String _generatedFieldKindLiteral(
    SchemaDocument schema,
    FieldDefinition field,
  ) {
    if (field.isScalar) {
      return 'GeneratedRuntimeFieldKind.scalar';
    }
    if (schema.findEnum(field.type) != null) {
      return 'GeneratedRuntimeFieldKind.enumeration';
    }
    return 'GeneratedRuntimeFieldKind.relation';
  }

  String? _fieldDefaultLiteral(FieldDefinition field) {
    final defaultAttribute = field.attribute('default');
    if (defaultAttribute == null) {
      return null;
    }

    final rawValue = (defaultAttribute.arguments['value'] ?? '').trim();
    if (rawValue.isEmpty) {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.none)';
    }
    if (rawValue == 'now()') {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.now)';
    }
    if (rawValue == 'autoincrement()') {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.autoincrement)';
    }
    if (rawValue == 'cuid()') {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.cuid)';
    }
    if (rawValue == 'uuid()') {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.uuid)';
    }
    if (rawValue.startsWith('dbgenerated(')) {
      return 'GeneratedFieldDefaultMetadata(kind: GeneratedRuntimeDefaultKind.dbGenerated, value: ${_stringLiteral(rawValue)})';
    }

    final stripped = _stripWrappingQuotes(rawValue);
    final isLiteral =
        stripped != rawValue ||
        RegExp(r'^-?\d+(\.\d+)?$').hasMatch(rawValue) ||
        rawValue == 'true' ||
        rawValue == 'false' ||
        rawValue == 'null';
    final kind = isLiteral
        ? 'GeneratedRuntimeDefaultKind.literal'
        : 'GeneratedRuntimeDefaultKind.expression';
    return 'GeneratedFieldDefaultMetadata(kind: $kind, value: ${_stringLiteral(stripped != rawValue ? stripped : rawValue)})';
  }

  String? _generatedRelationLiteral(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField, {
    required String indent,
  }) {
    if (_generatedFieldKindLiteral(schema, relationField) !=
        'GeneratedRuntimeFieldKind.relation') {
      return null;
    }

    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final relationName =
        _relationName(relationField.attribute('relation')) ??
        _relationName(opposite?.attribute('relation'));
    final cardinality = relationField.isList
        ? 'GeneratedRuntimeRelationCardinality.many'
        : 'GeneratedRuntimeRelationCardinality.one';
    final storage = resolveImplicitManyToManyStorage(
      schema: schema,
      sourceModelName: sourceModel.name,
      relationFieldName: relationField.name,
    );

    final localFields = storage != null
        ? storage.sourceKeyFields
        : _relationFieldLists(schema, sourceModel, relationField).$1;
    final targetFields = storage != null
        ? storage.targetKeyFields
        : _relationFieldLists(schema, sourceModel, relationField).$2;
    final storageKind = storage != null
        ? 'GeneratedRuntimeRelationStorageKind.implicitManyToMany'
        : 'GeneratedRuntimeRelationStorageKind.direct';

    final buffer = StringBuffer()
      ..writeln('GeneratedRelationMetadata(')
      ..writeln('${indent}targetModel: ${_stringLiteral(relationField.type)},')
      ..writeln('${indent}cardinality: $cardinality,')
      ..writeln('${indent}storageKind: $storageKind,')
      ..writeln(
        '${indent}localFields: ${_generatedStringListLiteral(localFields)},',
      )
      ..writeln(
        '${indent}targetFields: ${_generatedStringListLiteral(targetFields)},',
      );

    if (relationName != null) {
      buffer.writeln('${indent}relationName: ${_stringLiteral(relationName)},');
    }
    if (opposite != null) {
      buffer.writeln(
        '${indent}inverseField: ${_stringLiteral(opposite.name)},',
      );
    }
    if (storage != null) {
      buffer
        ..writeln(
          '${indent}storageTableName: ${_stringLiteral(storage.tableName)},',
        )
        ..writeln(
          '${indent}sourceJoinColumns: ${_generatedStringListLiteral(storage.sourceJoinColumns)},',
        )
        ..writeln(
          '${indent}targetJoinColumns: ${_generatedStringListLiteral(storage.targetJoinColumns)},',
        );
    }

    buffer.write('${indent.substring(2)})');
    return buffer.toString();
  }

  (List<String>, List<String>) _relationFieldLists(
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
      if (fields.isNotEmpty && references.isNotEmpty) {
        return (
          List<String>.unmodifiable(fields),
          List<String>.unmodifiable(references),
        );
      }
    }

    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final oppositeRelation = opposite?.attribute('relation');
    if (oppositeRelation != null) {
      final fields = _parseRelationList(oppositeRelation.arguments['fields']);
      final references = _parseRelationList(
        oppositeRelation.arguments['references'],
      );
      if (fields.isNotEmpty && references.isNotEmpty) {
        return (
          List<String>.unmodifiable(references),
          List<String>.unmodifiable(fields),
        );
      }
    }

    return (const <String>[], const <String>[]);
  }

  String _datasourceUrlLiteral(String rawValue) {
    final trimmed = rawValue.trim();
    final envMatch = RegExp("^env\\((['\"])(.+)\\1\\)").firstMatch(trimmed);
    if (envMatch != null) {
      return 'GeneratedDatasourceUrl(kind: GeneratedDatasourceUrlKind.env, value: ${_stringLiteral(envMatch.group(2)!)} )'
          .replaceFirst(' )', ')');
    }

    if (trimmed.isEmpty) {
      return 'GeneratedDatasourceUrl(kind: GeneratedDatasourceUrlKind.expression, value: \'\')';
    }

    final stripped = _stripWrappingQuotes(trimmed);
    if (stripped != trimmed || !trimmed.contains('(')) {
      return 'GeneratedDatasourceUrl(kind: GeneratedDatasourceUrlKind.literal, value: ${_stringLiteral(stripped)})';
    }

    return 'GeneratedDatasourceUrl(kind: GeneratedDatasourceUrlKind.expression, value: ${_stringLiteral(trimmed)})';
  }

  String _resolvedDatasourceProvider(DatasourceDefinition definition) {
    return _stripWrappingQuotes(
      (definition.properties['provider'] ?? '').trim(),
    );
  }

  List<String> _primaryKeyFields(ModelDefinition model) {
    final fieldLevelIds = model.fields
        .where((field) => field.isId)
        .map((field) => field.name)
        .toList(growable: false);
    if (fieldLevelIds.isNotEmpty) {
      return List<String>.unmodifiable(fieldLevelIds);
    }

    return List<String>.unmodifiable(model.primaryKeyFields);
  }

  String _generatedNestedStringListLiteral(List<List<String>> values) {
    if (values.isEmpty) {
      return '<List<String>>[]';
    }

    final items = values.map(_generatedStringListLiteral).join(', ');
    return '<List<String>>[$items]';
  }

  String _generatedStringListLiteral(List<String> values) {
    if (values.isEmpty) {
      return '<String>[]';
    }

    return '<String>[${values.map(_stringLiteral).join(', ')}]';
  }

  String _stripWrappingQuotes(String value) {
    if (value.length >= 2) {
      final first = value[0];
      final last = value[value.length - 1];
      if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
        return value.substring(1, value.length - 1);
      }
    }
    return value;
  }
}
