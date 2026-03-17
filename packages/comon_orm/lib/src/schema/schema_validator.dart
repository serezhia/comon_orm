import 'schema_ast.dart';

/// Validates parsed schema documents against the supported feature set.
class SchemaValidator {
  /// Creates a stateless validator.
  const SchemaValidator();

  static const Set<String> _supportedReferentialActions = <String>{
    'Cascade',
    'Restrict',
    'NoAction',
    'SetNull',
    'SetDefault',
  };

  /// Returns validation issues for [schema].
  List<ValidationIssue> validate(SchemaDocument schema) {
    final effectiveSchema = schema.withoutIgnored();
    final issues = <ValidationIssue>[];
    final seenModels = <String>{};
    final seenEnums = <String>{};
    final seenDatasources = <String>{};
    final seenGenerators = <String>{};
    // Tracks effective database table names to catch @@map conflicts.
    final seenTableNames = <String>{};

    for (final datasource in schema.datasources) {
      if (!seenDatasources.add(datasource.name)) {
        issues.add(
          ValidationIssue(
            modelName: datasource.name,
            message: 'Duplicate datasource name.',
          ),
        );
      }
      if (!_hasNonEmptyProperty(datasource.properties, 'provider')) {
        issues.add(
          ValidationIssue(
            modelName: datasource.name,
            message: 'Datasource must declare a provider.',
          ),
        );
      }
      if (!_hasNonEmptyProperty(datasource.properties, 'url')) {
        issues.add(
          ValidationIssue(
            modelName: datasource.name,
            message: 'Datasource must declare a url.',
          ),
        );
      }
    }

    for (final generator in schema.generators) {
      if (!seenGenerators.add(generator.name)) {
        issues.add(
          ValidationIssue(
            modelName: generator.name,
            message: 'Duplicate generator name.',
          ),
        );
      }
      if (!_hasNonEmptyProperty(generator.properties, 'provider')) {
        issues.add(
          ValidationIssue(
            modelName: generator.name,
            message: 'Generator must declare a provider.',
          ),
        );
      }
    }

    for (final definition in schema.enums) {
      if (!seenEnums.add(definition.name)) {
        issues.add(
          ValidationIssue(
            modelName: definition.name,
            message: 'Duplicate enum name.',
          ),
        );
      }
      if (seenModels.contains(definition.name)) {
        issues.add(
          ValidationIssue(
            modelName: definition.name,
            message: 'Schema type name is already used by a model.',
          ),
        );
      }

      final seenValues = <String>{};
      for (final value in definition.values) {
        if (!seenValues.add(value)) {
          issues.add(
            ValidationIssue(
              modelName: definition.name,
              fieldName: value,
              message: 'Duplicate enum value.',
            ),
          );
        }
      }

      for (final attribute in definition.attributes) {
        switch (attribute.name) {
          case 'map':
            final value = attribute.arguments['value'];
            if (value == null || value.isEmpty) {
              issues.add(
                ValidationIssue(
                  modelName: definition.name,
                  message: '@@map requires a mapped type name.',
                ),
              );
            }
          default:
            issues.add(
              ValidationIssue(
                modelName: definition.name,
                message: 'Unsupported enum attribute @@${attribute.name}.',
              ),
            );
        }
      }
    }

    for (final model in effectiveSchema.models) {
      if (!seenModels.add(model.name)) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message: 'Duplicate model name.',
          ),
        );
      }
      if (!seenTableNames.add(model.databaseName)) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message:
                'Database table name "${model.databaseName}" conflicts with another model.',
          ),
        );
      }
      if (seenEnums.contains(model.name)) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message: 'Schema type name is already used by an enum.',
          ),
        );
      }

      final seenFields = <String>{};
      // Tracks effective database column names to catch @map conflicts.
      final seenDbFieldNames = <String>{};
      var idCount = 0;
      final modelId = model.attribute('id');

      if (modelId != null) {
        final idFields = _parseListArgument(
          modelId.arguments['fields'] ?? modelId.arguments['value'] ?? '',
        );
        if (idFields.isEmpty) {
          issues.add(
            ValidationIssue(
              modelName: model.name,
              message: '@@id requires at least one field.',
            ),
          );
        }
        _validateModelAttributeFields(
          model: model,
          attribute: modelId,
          issues: issues,
        );
      }

      for (final attribute in model.attributes) {
        switch (attribute.name) {
          case 'unique':
          case 'index':
            _validateModelAttributeFields(
              model: model,
              attribute: attribute,
              issues: issues,
            );
          case 'map':
            final value = attribute.arguments['value'];
            if (value == null || value.isEmpty) {
              issues.add(
                ValidationIssue(
                  modelName: model.name,
                  message: '@@map requires a mapped table name.',
                ),
              );
            }
          case 'ignore':
          case 'id':
            break;
          default:
            issues.add(
              ValidationIssue(
                modelName: model.name,
                message: 'Unsupported model attribute @@${attribute.name}.',
              ),
            );
        }
      }

      for (final field in model.fields) {
        if (!seenFields.add(field.name)) {
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message: 'Duplicate field name.',
            ),
          );
        }

        // Relation fields have no database column; skip the db-name check.
        final isColumnField =
            field.isScalar || effectiveSchema.findEnum(field.type) != null;
        if (isColumnField && !seenDbFieldNames.add(field.databaseName)) {
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message:
                  'Field database name "${field.databaseName}" conflicts with another field in model "${model.name}".',
            ),
          );
        }

        if (field.isId) {
          idCount++;
          if (field.isNullable || field.isList) {
            issues.add(
              ValidationIssue(
                modelName: model.name,
                fieldName: field.name,
                message: 'ID field must be singular and non-nullable.',
              ),
            );
          }
        }

        if (!field.isScalar &&
            effectiveSchema.findEnum(field.type) == null &&
            effectiveSchema.findModel(field.type) == null) {
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message: 'Unknown relation target model "${field.type}".',
            ),
          );
        }

        final relation = field.attribute('relation');
        if (relation != null) {
          _validateRelationArguments(
            effectiveSchema,
            model,
            field,
            relation,
            issues,
          );
        }

        final updatedAt = field.attribute('updatedAt');
        if (updatedAt != null) {
          if (updatedAt.arguments.isNotEmpty) {
            issues.add(
              ValidationIssue(
                modelName: model.name,
                fieldName: field.name,
                message: '@updatedAt does not accept arguments.',
              ),
            );
          }
          if (field.type != 'DateTime' || field.isList || field.isNullable) {
            issues.add(
              ValidationIssue(
                modelName: model.name,
                fieldName: field.name,
                message:
                    '@updatedAt field must be a singular non-nullable DateTime.',
              ),
            );
          }
        }

        final nativeType = field.nativeTypeAttribute;
        if (nativeType != null) {
          final provider = _resolveNativeTypeProvider(schema);
          final issue = _validateNativeType(
            provider: provider,
            schema: schema,
            model: model,
            field: field,
            nativeType: nativeType,
          );
          if (issue != null) {
            issues.add(issue);
          }
        }
      }

      if (idCount == 0 && modelId == null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message: 'Model must have an @id field.',
          ),
        );
      }
      if (idCount > 1) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message:
                'Use model-level @@id([fieldA, fieldB]) instead of multiple @id fields.',
          ),
        );
      }
      if (idCount > 0 && modelId != null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message:
                'Use either field-level @id or model-level @@id, not both.',
          ),
        );
      }
    }

    _validateRelationTopology(effectiveSchema, issues);

    return List<ValidationIssue>.unmodifiable(issues);
  }

  void _validateRelationArguments(
    SchemaDocument schema,
    ModelDefinition model,
    FieldDefinition field,
    FieldAttribute relation,
    List<ValidationIssue> issues,
  ) {
    final targetModel = schema.findModel(field.type);
    final fieldsValue = relation.arguments['fields'];
    final referencesValue = relation.arguments['references'];
    final onDelete = _normalizedReferentialAction(
      relation.arguments['onDelete'],
    );
    final onUpdate = _normalizedReferentialAction(
      relation.arguments['onUpdate'],
    );

    _validateReferentialAction(
      model: model,
      field: field,
      actionName: 'onDelete',
      actionValue: onDelete,
      issues: issues,
    );
    _validateReferentialAction(
      model: model,
      field: field,
      actionName: 'onUpdate',
      actionValue: onUpdate,
      issues: issues,
    );

    if ((fieldsValue == null) != (referencesValue == null)) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message: '@relation requires both fields and references or neither.',
        ),
      );
      return;
    }

    if (fieldsValue == null) {
      if (onDelete != null || onUpdate != null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@relation onDelete/onUpdate can only be declared on the side that defines fields/references.',
          ),
        );
      }
      if (field.isList) {
        return;
      }
      return;
    }

    if (field.isList) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              'List relation fields cannot declare fields/references; declare them on the singular side.',
        ),
      );
      return;
    }

    final localFields = _parseListArgument(fieldsValue);
    final referencedFields = _parseListArgument(referencesValue!);
    if (localFields.isEmpty || referencedFields.isEmpty) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message: '@relation fields/references must not be empty.',
        ),
      );
      return;
    }
    if (localFields.length != referencedFields.length) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              '@relation fields and references must contain the same number of fields.',
        ),
      );
      return;
    }

    final resolvedLocalFields = <FieldDefinition>[];
    for (final localField in localFields) {
      final localDefinition = model.findField(localField);
      if (localDefinition == null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@relation references missing local field "$localField".',
          ),
        );
        continue;
      }
      resolvedLocalFields.add(localDefinition);
      if (localDefinition.isList || !localDefinition.isScalar) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@relation local field "$localField" must be a singular scalar field.',
          ),
        );
      }
    }

    if (onDelete == 'SetNull' || onUpdate == 'SetNull') {
      for (final localField in resolvedLocalFields) {
        if (!localField.isNullable) {
          final actionName = onDelete == 'SetNull' ? 'onDelete' : 'onUpdate';
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message:
                  '@relation $actionName: SetNull requires nullable local fields.',
            ),
          );
          break;
        }
      }
    }

    if (onDelete == 'SetDefault' || onUpdate == 'SetDefault') {
      for (final localField in resolvedLocalFields) {
        if (localField.attribute('default') == null) {
          final actionName = onDelete == 'SetDefault' ? 'onDelete' : 'onUpdate';
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message:
                  '@relation $actionName: SetDefault requires defaults on all local fields.',
            ),
          );
          break;
        }
      }
    }

    if (targetModel == null) {
      return;
    }

    final resolvedReferencedFields = <FieldDefinition>[];
    for (final referencedField in referencedFields) {
      final targetField = targetModel.findField(referencedField);
      if (targetField == null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@relation references missing target field "$referencedField" on model "${targetModel.name}".',
          ),
        );
        continue;
      }
      resolvedReferencedFields.add(targetField);
      if (targetField.isList || !targetField.isScalar) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@relation target field "$referencedField" on model "${targetModel.name}" must be a singular scalar field.',
          ),
        );
      }
    }

    if (resolvedLocalFields.length != localFields.length ||
        resolvedReferencedFields.length != referencedFields.length) {
      return;
    }

    for (var index = 0; index < localFields.length; index++) {
      final localField = resolvedLocalFields[index];
      final referencedField = resolvedReferencedFields[index];
      if (localField.type != referencedField.type) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@relation field "${localField.name}" type ${localField.type} does not match referenced field "${targetModel.name}.${referencedField.name}" type ${referencedField.type}.',
          ),
        );
      }
    }

    if (!_isUniqueFieldSet(targetModel, referencedFields)) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              '@relation references on model "${targetModel.name}" must target an @id, @unique, @@id, or @@unique field set.',
        ),
      );
    }
  }

  void _validateReferentialAction({
    required ModelDefinition model,
    required FieldDefinition field,
    required String actionName,
    required String? actionValue,
    required List<ValidationIssue> issues,
  }) {
    if (actionValue == null) {
      return;
    }

    if (!_supportedReferentialActions.contains(actionValue)) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              '@relation $actionName must be one of Cascade, Restrict, NoAction, SetNull, or SetDefault.',
        ),
      );
    }
  }

  bool _isUniqueFieldSet(ModelDefinition model, List<String> fieldNames) {
    if (fieldNames.length == 1) {
      final field = model.findField(fieldNames.single);
      if (field != null && (field.isId || field.isUnique)) {
        return true;
      }
    }

    if (_sameFieldList(model.primaryKeyFields, fieldNames)) {
      return true;
    }

    for (final uniqueSet in model.compoundUniqueFieldSets) {
      if (_sameFieldList(uniqueSet, fieldNames)) {
        return true;
      }
    }

    return false;
  }

  bool _sameFieldList(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }

  void _validateRelationTopology(
    SchemaDocument schema,
    List<ValidationIssue> issues,
  ) {
    final pairGroups = <String, List<_RelationEndpoint>>{};

    for (final model in schema.models) {
      for (final field in model.fields) {
        if (field.isScalar || schema.findEnum(field.type) != null) {
          continue;
        }
        final targetModel = schema.findModel(field.type);
        if (targetModel == null) {
          continue;
        }

        final relation = field.attribute('relation');
        final relationName = _relationName(relation);
        if (model.name == targetModel.name && relationName == null) {
          issues.add(
            ValidationIssue(
              modelName: model.name,
              fieldName: field.name,
              message: 'Self-relations must declare an explicit relation name.',
            ),
          );
        }

        final pairKey = _relationPairKey(model.name, targetModel.name);
        pairGroups
            .putIfAbsent(pairKey, () => <_RelationEndpoint>[])
            .add(
              _RelationEndpoint(
                model: model,
                modelName: model.name,
                field: field,
                fieldName: field.name,
                targetModelName: targetModel.name,
                relationName: relationName,
                ownsReferences:
                    relation != null &&
                    relation.arguments['fields'] != null &&
                    relation.arguments['references'] != null,
                localFields: relation == null
                    ? const <String>[]
                    : _parseListArgument(relation.arguments['fields'] ?? ''),
              ),
            );
      }
    }

    for (final endpoints in pairGroups.values) {
      final byModelCounts = <String, int>{};
      for (final endpoint in endpoints) {
        byModelCounts[endpoint.modelName] =
            (byModelCounts[endpoint.modelName] ?? 0) + 1;
      }

      final isAmbiguous = byModelCounts.values.any((count) => count > 1);
      final inferredNamedRelation = _inferOneSidedNamedRelation(
        endpoints,
        isAmbiguous: isAmbiguous,
      );
      if (isAmbiguous) {
        for (final endpoint in endpoints) {
          if (endpoint.relationName != null) {
            continue;
          }
          issues.add(
            ValidationIssue(
              modelName: endpoint.modelName,
              fieldName: endpoint.fieldName,
              message:
                  'Ambiguous relation between "${endpoint.modelName}" and "${endpoint.targetModelName}"; add an explicit relation name.',
            ),
          );
        }
      }

      final namedGroups = <String, List<_RelationEndpoint>>{};
      for (final endpoint in endpoints) {
        final relationName = endpoint.relationName;
        if (relationName == null) {
          continue;
        }
        namedGroups
            .putIfAbsent(relationName, () => <_RelationEndpoint>[])
            .add(endpoint);
      }

      for (final entry in namedGroups.entries) {
        final relationName = entry.key;
        final relationEndpoints =
            inferredNamedRelation != null &&
                inferredNamedRelation.$1 == relationName
            ? inferredNamedRelation.$2
            : entry.value;
        final isSelfRelationGroup = relationEndpoints.every(
          (endpoint) => endpoint.modelName == endpoint.targetModelName,
        );
        final countsByModel = <String, int>{};
        for (final endpoint in relationEndpoints) {
          countsByModel[endpoint.modelName] =
              (countsByModel[endpoint.modelName] ?? 0) + 1;
        }

        for (final endpoint in relationEndpoints) {
          final modelCount = countsByModel[endpoint.modelName] ?? 0;
          final isDuplicateReuse = isSelfRelationGroup
              ? modelCount > 2
              : modelCount > 1;
          if (isDuplicateReuse) {
            issues.add(
              ValidationIssue(
                modelName: endpoint.modelName,
                fieldName: endpoint.fieldName,
                message:
                    'Relation name "$relationName" is reused multiple times between "${endpoint.modelName}" and "${endpoint.targetModelName}" on the same model side.',
              ),
            );
          }
        }

        _validateRelationGroup(
          relationEndpoints,
          relationName: relationName,
          issues: issues,
        );
      }

      if (!isAmbiguous) {
        final unnamedEndpoints = endpoints
            .where((endpoint) => endpoint.relationName == null)
            .where(
              (endpoint) =>
                  inferredNamedRelation == null ||
                  !inferredNamedRelation.$2.contains(endpoint),
            )
            .toList(growable: false);
        if (unnamedEndpoints.isNotEmpty) {
          _validateRelationGroup(unnamedEndpoints, issues: issues);
        }
      }
    }
  }

  void _validateRelationGroup(
    List<_RelationEndpoint> endpoints, {
    String? relationName,
    required List<ValidationIssue> issues,
  }) {
    if (endpoints.isEmpty) {
      return;
    }

    final label = relationName == null
        ? 'relation between "${endpoints.first.modelName}" and "${endpoints.first.targetModelName}"'
        : 'relation "$relationName" between "${endpoints.first.modelName}" and "${endpoints.first.targetModelName}"';

    if (endpoints.length != 2) {
      for (final endpoint in endpoints) {
        issues.add(
          ValidationIssue(
            modelName: endpoint.modelName,
            fieldName: endpoint.fieldName,
            message:
                'Incomplete $label; exactly two relation fields are required.',
          ),
        );
      }
      return;
    }

    final ownershipCount = endpoints
        .where((endpoint) => endpoint.ownsReferences)
        .length;
    final isImplicitManyToMany = endpoints.every(
      (endpoint) => endpoint.field.isList,
    );

    if (ownershipCount > 1) {
      for (final endpoint in endpoints.where(
        (endpoint) => endpoint.ownsReferences,
      )) {
        issues.add(
          ValidationIssue(
            modelName: endpoint.modelName,
            fieldName: endpoint.fieldName,
            message: 'Only one side of $label may declare fields/references.',
          ),
        );
      }
    }

    if (ownershipCount == 0 && !isImplicitManyToMany) {
      for (final endpoint in endpoints) {
        issues.add(
          ValidationIssue(
            modelName: endpoint.modelName,
            fieldName: endpoint.fieldName,
            message:
                'Exactly one side of $label must declare fields/references unless both relation fields are lists.',
          ),
        );
      }
      return;
    }

    if (ownershipCount == 1 &&
        endpoints.every((endpoint) => !endpoint.field.isList)) {
      final owner = endpoints.firstWhere((endpoint) => endpoint.ownsReferences);
      if (!_isUniqueFieldSet(owner.model, owner.localFields)) {
        issues.add(
          ValidationIssue(
            modelName: owner.modelName,
            fieldName: owner.fieldName,
            message:
                'One-to-one $label requires the defining fields on "${owner.modelName}" to be unique.',
          ),
        );
      }

      final isSelfRelation =
          endpoints.first.modelName == endpoints.first.targetModelName;
      if (isSelfRelation &&
          endpoints.every((endpoint) => !endpoint.field.isNullable)) {
        for (final endpoint in endpoints) {
          issues.add(
            ValidationIssue(
              modelName: endpoint.modelName,
              fieldName: endpoint.fieldName,
              message:
                  'One-to-one self-relations must have at least one optional side.',
            ),
          );
        }
      }
    }
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

    return _stripWrappingQuotes(trimmed);
  }

  (String, List<_RelationEndpoint>)? _inferOneSidedNamedRelation(
    List<_RelationEndpoint> endpoints, {
    required bool isAmbiguous,
  }) {
    if (isAmbiguous || endpoints.length != 2) {
      return null;
    }

    final first = endpoints.first;
    final second = endpoints.last;
    if (first.modelName == first.targetModelName) {
      return null;
    }

    final firstName = first.relationName;
    final secondName = second.relationName;
    if (firstName == null && secondName == null) {
      return null;
    }
    if (firstName != null && secondName != null) {
      return null;
    }

    return (
      firstName ?? secondName!,
      List<_RelationEndpoint>.unmodifiable(endpoints),
    );
  }

  String _relationPairKey(String left, String right) {
    if (left.compareTo(right) <= 0) {
      return '$left::$right';
    }
    return '$right::$left';
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

  String? _normalizedReferentialAction(String? value) {
    if (value == null) {
      return null;
    }
    return _stripWrappingQuotes(value.trim());
  }

  void _validateModelAttributeFields({
    required ModelDefinition model,
    required ModelAttribute attribute,
    required List<ValidationIssue> issues,
  }) {
    final rawFields =
        attribute.arguments['fields'] ?? attribute.arguments['value'] ?? '';
    final fields = _parseListArgument(rawFields);
    if (fields.isEmpty) {
      issues.add(
        ValidationIssue(
          modelName: model.name,
          message: '@@${attribute.name} requires at least one field.',
        ),
      );
      return;
    }

    for (final fieldName in fields) {
      if (model.findField(fieldName) == null) {
        issues.add(
          ValidationIssue(
            modelName: model.name,
            message:
                '@@${attribute.name} references missing field "$fieldName".',
          ),
        );
      }
    }
  }

  List<String> _parseListArgument(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return const <String>[];
    }
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

  bool _hasNonEmptyProperty(Map<String, String> properties, String key) {
    final value = properties[key];
    return value != null && value.trim().isNotEmpty;
  }

  String? _resolveNativeTypeProvider(SchemaDocument schema) {
    if (schema.datasources.isEmpty) {
      return null;
    }

    final providers = schema.datasources
        .map((datasource) => datasource.properties['provider'])
        .whereType<String>()
        .map(_unquote)
        .where((provider) => provider.isNotEmpty)
        .toSet();

    if (providers.length != 1) {
      return '__ambiguous__';
    }

    return providers.single;
  }

  ValidationIssue? _validateNativeType({
    required String? provider,
    required SchemaDocument schema,
    required ModelDefinition model,
    required FieldDefinition field,
    required FieldAttribute nativeType,
  }) {
    if (provider == null) {
      return ValidationIssue(
        modelName: model.name,
        fieldName: field.name,
        message:
            '${_nativeTypeLabel(nativeType)} requires a datasource provider.',
      );
    }

    if (provider == '__ambiguous__') {
      return ValidationIssue(
        modelName: model.name,
        fieldName: field.name,
        message:
            '${_nativeTypeLabel(nativeType)} requires exactly one datasource provider.',
      );
    }

    if (provider != 'postgresql') {
      if (provider == 'sqlite') {
        return _validateSqliteNativeType(schema, model, field, nativeType);
      }
      return ValidationIssue(
        modelName: model.name,
        fieldName: field.name,
        message:
            '${_nativeTypeLabel(nativeType)} is not supported for datasource provider "$provider".',
      );
    }

    return _validatePostgresqlNativeType(model, field, nativeType);
  }

  ValidationIssue? _validateSqliteNativeType(
    SchemaDocument schema,
    ModelDefinition model,
    FieldDefinition field,
    FieldAttribute nativeType,
  ) {
    final isEnumField = schema.findEnum(field.type) != null;

    switch (nativeType.name) {
      case 'db.Integer':
        if (field.type != 'Int' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Integer is only supported on singular Int fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Integer does not accept arguments.',
          );
        }
      case 'db.Real':
        if ((field.type != 'Float' && field.type != 'Decimal') ||
            field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@db.Real is only supported on singular Float or Decimal fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Real does not accept arguments.',
          );
        }
      case 'db.Text':
        if ((!<String>{
                  'String',
                  'DateTime',
                  'Json',
                  'BigInt',
                }.contains(field.type) &&
                !isEnumField) ||
            field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@db.Text is only supported on singular String, DateTime, Json, BigInt, or enum fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Text does not accept arguments.',
          );
        }
      case 'db.Blob':
        if (field.type != 'Bytes' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Blob is only supported on singular Bytes fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Blob does not accept arguments.',
          );
        }
      case 'db.Numeric':
        if (field.type != 'Decimal' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@db.Numeric is only supported on singular Decimal fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Numeric does not accept arguments.',
          );
        }
      default:
        return ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              'Unsupported native type ${_nativeTypeLabel(nativeType)} for datasource provider "sqlite".',
        );
    }

    return null;
  }

  ValidationIssue? _validatePostgresqlNativeType(
    ModelDefinition model,
    FieldDefinition field,
    FieldAttribute nativeType,
  ) {
    final value = nativeType.arguments['value'];

    switch (nativeType.name) {
      case 'db.SmallInt':
        if (field.type != 'Int' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.SmallInt is only supported on singular Int fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.SmallInt does not accept arguments.',
          );
        }
      case 'db.BigInt':
        if (field.type != 'BigInt' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.BigInt is only supported on singular BigInt fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.BigInt does not accept arguments.',
          );
        }
      case 'db.DoublePrecision':
        if (field.type != 'Float' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@db.DoublePrecision is only supported on singular Float fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.DoublePrecision does not accept arguments.',
          );
        }
      case 'db.VarChar':
        final length = value == null ? null : int.tryParse(value.trim());
        if (field.type != 'String' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.VarChar is only supported on singular String fields.',
          );
        }
        if (length == null || length <= 0) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.VarChar requires a positive length argument.',
          );
        }
      case 'db.Char':
        final length = value == null ? null : int.tryParse(value.trim());
        if (field.type != 'String' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Char is only supported on singular String fields.',
          );
        }
        if (length == null || length <= 0) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Char requires a positive length argument.',
          );
        }
      case 'db.Text':
        if (field.type != 'String' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Text is only supported on singular String fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Text does not accept arguments.',
          );
        }
      case 'db.Json':
      case 'db.JsonB':
        if (field.type != 'Json' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '${_nativeTypeLabel(nativeType)} is only supported on singular Json fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '${_nativeTypeLabel(nativeType)} does not accept arguments.',
          );
        }
      case 'db.ByteA':
        if (field.type != 'Bytes' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.ByteA is only supported on singular Bytes fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.ByteA does not accept arguments.',
          );
        }
      case 'db.Numeric':
        if (field.type != 'Decimal' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '@db.Numeric is only supported on singular Decimal fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Numeric does not accept arguments.',
          );
        }
      case 'db.Uuid':
        if (field.type != 'String' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Uuid is only supported on singular String fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Uuid does not accept arguments.',
          );
        }
      case 'db.Xml':
        if (field.type != 'String' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Xml is only supported on singular String fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message: '@db.Xml does not accept arguments.',
          );
        }
      case 'db.Timestamp':
      case 'db.Timestamptz':
        if (field.type != 'DateTime' || field.isList) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '${_nativeTypeLabel(nativeType)} is only supported on singular DateTime fields.',
          );
        }
        if (nativeType.arguments.isNotEmpty) {
          return ValidationIssue(
            modelName: model.name,
            fieldName: field.name,
            message:
                '${_nativeTypeLabel(nativeType)} does not accept arguments.',
          );
        }
      default:
        return ValidationIssue(
          modelName: model.name,
          fieldName: field.name,
          message:
              'Unsupported native type ${_nativeTypeLabel(nativeType)} for datasource provider "postgresql".',
        );
    }

    return null;
  }

  String _nativeTypeLabel(FieldAttribute nativeType) => '@${nativeType.name}';

  String _unquote(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2) {
      final first = trimmed[0];
      final last = trimmed[trimmed.length - 1];
      if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }
    return trimmed;
  }
}

class _RelationEndpoint {
  const _RelationEndpoint({
    required this.model,
    required this.modelName,
    required this.field,
    required this.fieldName,
    required this.targetModelName,
    required this.relationName,
    required this.ownsReferences,
    required this.localFields,
  });

  final ModelDefinition model;
  final String modelName;
  final FieldDefinition field;
  final String fieldName;
  final String targetModelName;
  final String? relationName;
  final bool ownsReferences;
  final List<String> localFields;
}
