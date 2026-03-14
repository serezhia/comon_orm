import 'dart:convert';

import 'package:meta/meta.dart';

import 'schema_ast.dart';

/// Prefix used for generated implicit many-to-many storage tables.
const String kImplicitManyToManyTablePrefix = '_comon_orm_m2m__';

@immutable
/// Resolved storage mapping for an implicit many-to-many relation.
class ImplicitManyToManyStorageDefinition {
  /// Creates a resolved implicit relation storage description.
  const ImplicitManyToManyStorageDefinition({
    required this.tableName,
    required this.sourceModel,
    required this.sourceField,
    required this.sourceKeyFields,
    required this.sourceJoinColumns,
    required this.targetModel,
    required this.targetField,
    required this.targetKeyFields,
    required this.targetJoinColumns,
  });

  /// Join table name.
  final String tableName;

  /// Source-side model definition.
  final ModelDefinition sourceModel;

  /// Source-side relation field.
  final FieldDefinition sourceField;

  /// Source-side primary key fields used in the join table.
  final List<String> sourceKeyFields;

  /// Source-side join columns stored in [tableName].
  final List<String> sourceJoinColumns;

  /// Target-side model definition.
  final ModelDefinition targetModel;

  /// Target-side relation field.
  final FieldDefinition targetField;

  /// Target-side primary key fields used in the join table.
  final List<String> targetKeyFields;

  /// Target-side join columns stored in [tableName].
  final List<String> targetJoinColumns;

  /// Stable relation name used in migration and introspection flows.
  String get relationName => tableName;

  /// Stable identifier that captures both sides of the storage mapping.
  String get signature =>
      '${sourceModel.databaseName}.${sourceField.databaseName}|${sourceKeyFields.join(',')}|${sourceJoinColumns.join(',')}|'
      '${targetModel.databaseName}.${targetField.databaseName}|${targetKeyFields.join(',')}|${targetJoinColumns.join(',')}';
}

@immutable
/// Parsed components extracted from an implicit many-to-many table name.
class ParsedImplicitManyToManyTableName {
  /// Creates a parsed implicit relation table name.
  const ParsedImplicitManyToManyTableName({
    required this.firstModelName,
    required this.firstFieldName,
    required this.secondModelName,
    required this.secondFieldName,
  });

  /// Model name encoded on the first side of the storage table.
  final String firstModelName;

  /// Relation field encoded on the first side of the storage table.
  final String firstFieldName;

  /// Model name encoded on the second side of the storage table.
  final String secondModelName;

  /// Relation field encoded on the second side of the storage table.
  final String secondFieldName;
}

/// Collects all implicit many-to-many storages declared by [schema].
List<ImplicitManyToManyStorageDefinition> collectImplicitManyToManyStorages(
  SchemaDocument schema,
) {
  final storages = <ImplicitManyToManyStorageDefinition>[];
  final seenTableNames = <String>{};

  for (final model in schema.models) {
    for (final field in model.fields) {
      final storage = resolveImplicitManyToManyStorage(
        schema: schema,
        sourceModelName: model.name,
        relationFieldName: field.name,
      );
      if (storage == null || !seenTableNames.add(storage.tableName)) {
        continue;
      }
      storages.add(storage);
    }
  }

  storages.sort((left, right) => left.tableName.compareTo(right.tableName));
  return List<ImplicitManyToManyStorageDefinition>.unmodifiable(storages);
}

/// Resolves the join-table storage used by an implicit relation field.
ImplicitManyToManyStorageDefinition? resolveImplicitManyToManyStorage({
  required SchemaDocument schema,
  required String sourceModelName,
  required String relationFieldName,
}) {
  final sourceModel = schema.findModel(sourceModelName);
  final sourceField = sourceModel?.findField(relationFieldName);
  if (sourceModel == null || sourceField == null) {
    return null;
  }

  if (!_isImplicitManyToManyRelationField(schema, sourceField)) {
    return null;
  }

  final targetModel = schema.findModel(sourceField.type);
  if (targetModel == null) {
    return null;
  }

  final opposite = _oppositeRelationField(schema, sourceModel, sourceField);
  if (opposite == null || !opposite.isList) {
    return null;
  }

  final sourceKeyFields = _implicitManyToManyKeyFields(sourceModel);
  final targetKeyFields = _implicitManyToManyKeyFields(targetModel);
  final sourceJoinColumns = sourceKeyFields
      .map(
        (keyField) => _implicitManyToManyJoinColumn(
          modelDatabaseName: sourceModel.databaseName,
          relationFieldDatabaseName: sourceField.databaseName,
          keyFieldDatabaseName:
              sourceModel.findField(keyField)?.databaseName ?? keyField,
        ),
      )
      .toList(growable: false);
  final targetJoinColumns = targetKeyFields
      .map(
        (keyField) => _implicitManyToManyJoinColumn(
          modelDatabaseName: targetModel.databaseName,
          relationFieldDatabaseName: opposite.databaseName,
          keyFieldDatabaseName:
              targetModel.findField(keyField)?.databaseName ?? keyField,
        ),
      )
      .toList(growable: false);

  final left = _ImplicitRelationEndpoint(
    model: sourceModel,
    field: sourceField,
  );
  final right = _ImplicitRelationEndpoint(model: targetModel, field: opposite);
  final ordered = [left, right]..sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return ImplicitManyToManyStorageDefinition(
    tableName: _implicitManyToManyTableName(ordered[0], ordered[1]),
    sourceModel: sourceModel,
    sourceField: sourceField,
    sourceKeyFields: List<String>.unmodifiable(sourceKeyFields),
    sourceJoinColumns: List<String>.unmodifiable(sourceJoinColumns),
    targetModel: targetModel,
    targetField: opposite,
    targetKeyFields: List<String>.unmodifiable(targetKeyFields),
    targetJoinColumns: List<String>.unmodifiable(targetJoinColumns),
  );
}

/// Returns whether [tableName] belongs to implicit relation storage.
bool isImplicitManyToManyTableName(String tableName) {
  return tableName.startsWith(kImplicitManyToManyTablePrefix);
}

/// Parses an implicit relation table name produced by this package.
ParsedImplicitManyToManyTableName? parseImplicitManyToManyTableName(
  String tableName,
) {
  if (!isImplicitManyToManyTableName(tableName)) {
    return null;
  }

  final encoded = tableName.substring(kImplicitManyToManyTablePrefix.length);
  final segments = encoded.split('__');
  if (segments.length != 4 || segments.any((segment) => segment.isEmpty)) {
    return null;
  }

  return ParsedImplicitManyToManyTableName(
    firstModelName: _decodeIdentifierSegment(segments[0]),
    firstFieldName: _decodeIdentifierSegment(segments[1]),
    secondModelName: _decodeIdentifierSegment(segments[2]),
    secondFieldName: _decodeIdentifierSegment(segments[3]),
  );
}

bool _isImplicitManyToManyRelationField(
  SchemaDocument schema,
  FieldDefinition field,
) {
  if (field.isScalar || !field.isList) {
    return false;
  }
  return schema.findEnum(field.type) == null;
}

FieldDefinition? _oppositeRelationField(
  SchemaDocument schema,
  ModelDefinition sourceModel,
  FieldDefinition relationField,
) {
  final targetModel = schema.findModel(relationField.type);
  if (targetModel == null) {
    return null;
  }

  final relationName = _relationName(relationField.attribute('relation'));
  for (final candidate in targetModel.fields) {
    if (candidate.isScalar || candidate.type != sourceModel.name) {
      continue;
    }
    if (sourceModel.name == targetModel.name &&
        candidate.name == relationField.name) {
      continue;
    }

    final candidateRelationName = _relationName(
      candidate.attribute('relation'),
    );
    if (relationName != null && candidateRelationName != null) {
      if (relationName == candidateRelationName) {
        return candidate;
      }
      continue;
    }

    return candidate;
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

  return _stripWrappingQuotes(trimmed);
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

String _implicitManyToManyJoinColumn({
  required String modelDatabaseName,
  required String relationFieldDatabaseName,
  required String keyFieldDatabaseName,
}) {
  return 'm2m__${_encodeIdentifierSegment(modelDatabaseName)}__${_encodeIdentifierSegment(relationFieldDatabaseName)}__${_encodeIdentifierSegment(keyFieldDatabaseName)}';
}

String _implicitManyToManyTableName(
  _ImplicitRelationEndpoint first,
  _ImplicitRelationEndpoint second,
) {
  return '$kImplicitManyToManyTablePrefix'
      '${_encodeIdentifierSegment(first.model.databaseName)}__'
      '${_encodeIdentifierSegment(first.field.databaseName)}__'
      '${_encodeIdentifierSegment(second.model.databaseName)}__'
      '${_encodeIdentifierSegment(second.field.databaseName)}';
}

String _encodeIdentifierSegment(String value) {
  return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
}

String _decodeIdentifierSegment(String value) {
  final remainder = value.length % 4;
  final normalized = remainder == 0 ? value : '$value${'=' * (4 - remainder)}';
  return utf8.decode(base64Url.decode(normalized));
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

class _ImplicitRelationEndpoint {
  const _ImplicitRelationEndpoint({required this.model, required this.field});

  final ModelDefinition model;
  final FieldDefinition field;

  String get sortKey => '${model.databaseName}.${field.databaseName}';
}
