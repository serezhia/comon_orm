import '../schema/implicit_many_to_many.dart';
import '../schema/schema_ast.dart';

/// Returns human-readable warnings for schema transitions that may lose data.
List<String> detectPotentialDataLossWarnings({
  required SchemaDocument from,
  required SchemaDocument to,
}) {
  from = from.withoutIgnored();
  to = to.withoutIgnored();
  final warnings = <String>[];
  final matchedSourceEnumNames = <String>{};
  final matchedEnumPairs = <String>{};

  final sourceEnumsByName = {
    for (final definition in from.enums) definition.name: definition,
  };
  final sourceEnumsByDatabaseName = {
    for (final definition in from.enums) definition.databaseName: definition,
  };
  for (final targetEnum in to.enums) {
    final sourceEnum =
        sourceEnumsByName.remove(targetEnum.name) ??
        sourceEnumsByDatabaseName.remove(targetEnum.databaseName) ??
        _inferRenamedSourceEnum(
          sourceSchema: from,
          targetSchema: to,
          targetEnum: targetEnum,
          matchedSourceEnumNames: matchedSourceEnumNames,
        );
    if (sourceEnum == null) {
      continue;
    }
    matchedSourceEnumNames.add(sourceEnum.name);
    matchedEnumPairs.add(_enumPairKey(sourceEnum, targetEnum));
    sourceEnumsByName.remove(sourceEnum.name);
    sourceEnumsByDatabaseName.remove(sourceEnum.databaseName);
    final removedValues = sourceEnum.values
        .where((value) => !targetEnum.values.contains(value))
        .toList(growable: false);
    if (removedValues.isNotEmpty &&
        !_isSafeEnumTransition(sourceEnum, targetEnum)) {
      warnings.add(
        'Potential data loss: enum ${targetEnum.name} removes values ${removedValues.join(', ')}.',
      );
    }
  }
  for (final removedEnum in sourceEnumsByName.keys) {
    warnings.add(
      'Potential data loss: enum $removedEnum is removed from the target schema.',
    );
  }

  final sourceModelsByName = {
    for (final model in from.models) model.name: model,
  };
  final sourceModelsByDatabaseName = {
    for (final model in from.models) model.databaseName: model,
  };
  final targetModels = {for (final model in to.models) model.name: model};

  for (final entry in targetModels.entries) {
    final targetModel = entry.value;
    final sourceModel =
        sourceModelsByName.remove(entry.key) ??
        sourceModelsByDatabaseName.remove(targetModel.databaseName);
    if (sourceModel == null) {
      continue;
    }
    sourceModelsByName.remove(sourceModel.name);
    sourceModelsByDatabaseName.remove(sourceModel.databaseName);

    final sourceFieldsByName = {
      for (final field in sourceModel.fields) field.name: field,
    };
    final sourceFieldsByDatabaseName = {
      for (final field in sourceModel.fields) field.databaseName: field,
    };
    for (final targetField in targetModel.fields) {
      final sourceField =
          sourceFieldsByName.remove(targetField.name) ??
          sourceFieldsByDatabaseName.remove(targetField.databaseName);
      if (sourceField == null) {
        continue;
      }
      sourceFieldsByName.remove(sourceField.name);
      sourceFieldsByDatabaseName.remove(sourceField.databaseName);
      final warning = _fieldRiskWarning(
        modelName: targetModel.name,
        sourceField: sourceField,
        targetField: targetField,
        sourceSchema: from,
        targetSchema: to,
        matchedEnumPairs: matchedEnumPairs,
      );
      if (warning != null) {
        warnings.add(warning);
      }
    }

    for (final removedField in sourceModel.fields.where(
      (field) =>
          sourceFieldsByName.containsKey(field.name) ||
          sourceFieldsByDatabaseName.containsKey(field.databaseName),
    )) {
      if (_isRelationField(from, removedField)) {
        continue;
      }
      warnings.add(
        'Potential data loss: field ${sourceModel.name}.${removedField.name} is removed from the target schema.',
      );
    }
  }

  for (final removedModel in from.models.where(
    (model) =>
        sourceModelsByName.containsKey(model.name) ||
        sourceModelsByDatabaseName.containsKey(model.databaseName),
  )) {
    warnings.add(
      'Potential data loss: model ${removedModel.name} is removed from the target schema.',
    );
  }

  final sourceStorages = {
    for (final storage in collectImplicitManyToManyStorages(from))
      storage.tableName: storage,
  };
  final targetStorages = {
    for (final storage in collectImplicitManyToManyStorages(to))
      storage.tableName: storage,
  };

  for (final removedStorage in sourceStorages.keys.where(
    (name) => !targetStorages.containsKey(name),
  )) {
    warnings.add(
      'Potential data loss: implicit relation storage $removedStorage is removed from the target schema.',
    );
  }

  return List<String>.unmodifiable(_dedupe(warnings));
}

String? _fieldRiskWarning({
  required String modelName,
  required FieldDefinition sourceField,
  required FieldDefinition targetField,
  required SchemaDocument sourceSchema,
  required SchemaDocument targetSchema,
  required Set<String> matchedEnumPairs,
}) {
  if (sourceField.type != targetField.type) {
    final sourceEnum =
        sourceSchema.findEnum(sourceField.type) ??
        sourceSchema.findEnumByDatabaseName(sourceField.type);
    final targetEnum =
        targetSchema.findEnum(targetField.type) ??
        targetSchema.findEnumByDatabaseName(targetField.type);
    if (sourceEnum != null &&
        targetEnum != null &&
        matchedEnumPairs.contains(_enumPairKey(sourceEnum, targetEnum))) {
      return null;
    }
    return 'Potential data loss: field $modelName.${targetField.name} changes type from ${sourceField.type} to ${targetField.type}.';
  }
  if (sourceField.isList != targetField.isList) {
    return 'Potential data loss: field $modelName.${targetField.name} changes collection shape.';
  }
  if (sourceField.isNullable && !targetField.isNullable) {
    return 'Potential data loss: field $modelName.${targetField.name} changes from optional to required.';
  }
  return null;
}

bool _isRelationField(SchemaDocument schema, FieldDefinition field) {
  return !field.isScalar &&
      schema.findEnum(field.type) == null &&
      schema.findEnumByDatabaseName(field.type) == null;
}

EnumDefinition? _inferRenamedSourceEnum({
  required SchemaDocument sourceSchema,
  required SchemaDocument targetSchema,
  required EnumDefinition targetEnum,
  required Set<String> matchedSourceEnumNames,
}) {
  final candidates = <EnumDefinition>{};

  for (final targetModel in targetSchema.models) {
    final sourceModel = sourceSchema.findModel(targetModel.name);
    if (sourceModel == null) {
      continue;
    }

    for (final targetField in targetModel.fields) {
      if (targetField.type != targetEnum.name) {
        continue;
      }

      final sourceField = sourceModel.findField(targetField.name);
      if (sourceField == null) {
        continue;
      }

      final sourceEnum =
          sourceSchema.findEnum(sourceField.type) ??
          sourceSchema.findEnumByDatabaseName(sourceField.type);
      if (sourceEnum == null ||
          matchedSourceEnumNames.contains(sourceEnum.name)) {
        continue;
      }

      candidates.add(sourceEnum);
    }
  }

  if (candidates.length != 1) {
    return null;
  }

  return candidates.single;
}

String _enumPairKey(EnumDefinition source, EnumDefinition target) {
  return '${source.name}->${target.name}';
}

bool _isSafeEnumTransition(EnumDefinition source, EnumDefinition target) {
  return _hasCompatibleEnumDefinition(source, target) ||
      _renamedEnumValues(source, target) != null ||
      _appendedEnumValues(source, target) != null ||
      _combinedRenameInsertTransition(source, target);
}

bool _hasCompatibleEnumDefinition(
  EnumDefinition source,
  EnumDefinition target,
) {
  if (source.values.length != target.values.length) {
    return false;
  }

  for (var index = 0; index < source.values.length; index++) {
    if (source.values[index] != target.values[index]) {
      return false;
    }
  }

  return true;
}

List<(String, String)>? _renamedEnumValues(
  EnumDefinition source,
  EnumDefinition target,
) {
  if (source.values.length != target.values.length) {
    return null;
  }

  final sourceSet = source.values.toSet();
  final targetSet = target.values.toSet();
  final renames = <(String, String)>[];

  for (var index = 0; index < source.values.length; index++) {
    final before = source.values[index];
    final after = target.values[index];
    if (before == after) {
      continue;
    }
    if (sourceSet.contains(after) || targetSet.contains(before)) {
      return null;
    }
    renames.add((before, after));
  }

  return renames.isEmpty ? null : renames;
}

List<String>? _appendedEnumValues(
  EnumDefinition source,
  EnumDefinition target,
) {
  if (target.values.length < source.values.length) {
    return null;
  }

  final current = List<String>.of(source.values);

  for (var targetIndex = 0; targetIndex < target.values.length; targetIndex++) {
    final value = target.values[targetIndex];

    if (targetIndex < current.length && current[targetIndex] == value) {
      continue;
    }

    if (current.contains(value)) {
      return null;
    }

    current.insert(targetIndex, value);
  }

  if (current.length != target.values.length) {
    return null;
  }

  return current;
}

bool _combinedRenameInsertTransition(
  EnumDefinition source,
  EnumDefinition target,
) {
  final unchangedSet = source.values.toSet().intersection(
    target.values.toSet(),
  );
  final sourceOnly = source.values
      .where((value) => !unchangedSet.contains(value))
      .toList(growable: false);
  final targetOnly = target.values
      .where((value) => !unchangedSet.contains(value))
      .toList(growable: false);

  if (sourceOnly.isEmpty || targetOnly.length <= sourceOnly.length) {
    return false;
  }

  final sourceSet = source.values.toSet();
  final targetSet = target.values.toSet();
  final renamedValues = <String, String>{};
  for (var index = 0; index < sourceOnly.length; index++) {
    final from = sourceOnly[index];
    final to = targetOnly[index];
    if (targetSet.contains(from) || sourceSet.contains(to)) {
      return false;
    }
    renamedValues[from] = to;
  }

  final intermediateValues = source.values
      .map((value) => renamedValues[value] ?? value)
      .toList(growable: false);
  final intermediateEnum = EnumDefinition(
    name: target.name,
    values: intermediateValues,
  );
  return _appendedEnumValues(intermediateEnum, target) != null;
}

List<String> _dedupe(List<String> warnings) {
  final unique = <String>[];
  final seen = <String>{};
  for (final warning in warnings) {
    if (seen.add(warning)) {
      unique.add(warning);
    }
  }
  return unique;
}
