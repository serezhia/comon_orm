part of 'client_generator.dart';

extension on ClientGenerator {
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

  String _nestedUpdateInputClassName(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final targetModel = _targetModel(schema, relationField);
    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final cardinality = relationField.isList ? 'Many' : 'One';
    final suffix = _pascalCase(opposite?.name ?? sourceModel.name);
    return '${targetModel.name}UpdateNested${cardinality}Without${suffix}Input';
  }

  String _connectOrCreateInputClassName(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final targetModel = _targetModel(schema, relationField);
    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    final suffix = _pascalCase(opposite?.name ?? sourceModel.name);
    return '${targetModel.name}ConnectOrCreateWithout${suffix}Input';
  }

  bool _relationOwnsForeignKey(FieldDefinition relationField) {
    final relation = relationField.attribute('relation');
    if (relation == null) {
      return false;
    }

    return _parseRelationList(relation.arguments['fields']).isNotEmpty;
  }

  bool _isImplicitManyToManyRelation(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    return relationField.isList &&
        _oppositeRelationField(schema, sourceModel, relationField)?.isList ==
            true;
  }

  FieldDefinition _owningRelationField(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    if (_relationOwnsForeignKey(relationField)) {
      return relationField;
    }

    final opposite = _oppositeRelationFieldOrThrow(
      schema,
      sourceModel,
      relationField,
    );
    if (_relationOwnsForeignKey(opposite)) {
      return opposite;
    }

    throw StateError(
      'Unable to infer owning relation field for ${sourceModel.name}.${relationField.name}.',
    );
  }

  ModelDefinition _owningRelationModel(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final owner = _owningRelationField(schema, sourceModel, relationField);
    return identical(owner, relationField)
        ? sourceModel
        : _targetModel(schema, relationField);
  }

  List<String> _owningRelationForeignKeyFieldNames(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final owner = _owningRelationField(schema, sourceModel, relationField);
    final fields = _parseRelationList(
      owner.attribute('relation')?.arguments['fields'],
    );
    if (fields.isEmpty) {
      throw StateError(
        'Unable to infer owning foreign key fields for ${sourceModel.name}.${relationField.name}.',
      );
    }

    return fields;
  }

  List<String> _owningRelationReferenceFieldNames(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final owner = _owningRelationField(schema, sourceModel, relationField);
    final references = _parseRelationList(
      owner.attribute('relation')?.arguments['references'],
    );
    if (references.isEmpty) {
      throw StateError(
        'Unable to infer owning reference fields for ${sourceModel.name}.${relationField.name}.',
      );
    }

    final foreignKeyFields = _owningRelationForeignKeyFieldNames(
      schema,
      sourceModel,
      relationField,
    );
    if (references.length != foreignKeyFields.length) {
      throw StateError(
        'Owning relation field count mismatch for ${sourceModel.name}.${relationField.name}.',
      );
    }

    return references;
  }

  bool _relationSupportsDisconnect(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final ownerModel = _owningRelationModel(schema, sourceModel, relationField);
    final foreignKeyFields = _owningRelationForeignKeyFieldNames(
      schema,
      sourceModel,
      relationField,
    );
    return foreignKeyFields.every(
      (fieldName) => ownerModel.findField(fieldName)?.isNullable == true,
    );
  }

  FieldDefinition _oppositeRelationFieldOrThrow(
    SchemaDocument schema,
    ModelDefinition sourceModel,
    FieldDefinition relationField,
  ) {
    final opposite = _oppositeRelationField(schema, sourceModel, relationField);
    if (opposite == null) {
      throw StateError(
        'Unable to infer opposite relation field for ${sourceModel.name}.${relationField.name}.',
      );
    }

    return opposite;
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

    return 'QueryRelation(field: ${_stringLiteral(relationField.name)}, targetModel: ${_stringLiteral(relationField.type)}, cardinality: $cardinality, localKeyField: ${_stringLiteral(metadata.$1.first)}, targetKeyField: ${_stringLiteral(metadata.$2.first)}, localKeyFields: ${_stringListLiteral(metadata.$1)}, targetKeyFields: ${_stringListLiteral(metadata.$2)})';
  }

  (List<String>, List<String>) _relationMetadata(
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

  String? _datasourceProvider(DatasourceDefinition datasource) {
    final provider = datasource.properties['provider'];
    if (provider == null || provider.isEmpty) {
      return null;
    }

    if ((provider.startsWith('"') && provider.endsWith('"')) ||
        (provider.startsWith("'") && provider.endsWith("'"))) {
      return provider.substring(1, provider.length - 1);
    }

    return provider;
  }

  String _lowercaseFirst(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toLowerCase() + value.substring(1);
  }
}
