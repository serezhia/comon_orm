import 'package:meta/meta.dart';

/// Scalar types recognized by the core schema layer.
const Set<String> kScalarTypes = <String>{
  'Int',
  'String',
  'Boolean',
  'DateTime',
  'Float',
  'Decimal',
  'Json',
  'Bytes',
  'BigInt',
};

@immutable
/// Parsed `schema.prisma` document.
class SchemaDocument {
  /// Creates a schema document.
  const SchemaDocument({
    required this.models,
    this.enums = const <EnumDefinition>[],
    this.datasources = const <DatasourceDefinition>[],
    this.generators = const <GeneratorDefinition>[],
  });

  /// Model declarations in source order.
  final List<ModelDefinition> models;

  /// Enum declarations in source order.
  final List<EnumDefinition> enums;

  /// Datasource declarations in source order.
  final List<DatasourceDefinition> datasources;

  /// Generator declarations in source order.
  final List<GeneratorDefinition> generators;

  /// Finds a model definition by [name].
  ModelDefinition? findModel(String name) {
    for (final model in models) {
      if (model.name == name) {
        return model;
      }
    }

    return null;
  }

  /// Finds a model definition by its mapped database table name.
  ModelDefinition? findModelByDatabaseName(String databaseName) {
    for (final model in models) {
      if (model.databaseName == databaseName) {
        return model;
      }
    }

    return null;
  }

  /// Finds an enum definition by [name].
  EnumDefinition? findEnum(String name) {
    for (final definition in enums) {
      if (definition.name == name) {
        return definition;
      }
    }

    return null;
  }

  /// Finds an enum definition by its mapped database type name.
  EnumDefinition? findEnumByDatabaseName(String databaseName) {
    for (final definition in enums) {
      if (definition.databaseName == databaseName) {
        return definition;
      }
    }

    return null;
  }

  /// Finds a datasource definition by [name].
  DatasourceDefinition? findDatasource(String name) {
    for (final definition in datasources) {
      if (definition.name == name) {
        return definition;
      }
    }

    return null;
  }

  /// Finds a generator definition by [name].
  GeneratorDefinition? findGenerator(String name) {
    for (final definition in generators) {
      if (definition.name == name) {
        return definition;
      }
    }

    return null;
  }

  /// Returns a copy of the schema with `@ignore` / `@@ignore` members removed.
  SchemaDocument withoutIgnored() {
    return SchemaDocument(
      models: models
          .where((model) => !model.isIgnored)
          .map((model) => model.withoutIgnoredFields())
          .toList(growable: false),
      enums: enums,
      datasources: datasources,
      generators: generators,
    );
  }
}

@immutable
/// Parsed datasource block.
class DatasourceDefinition {
  /// Creates a datasource definition.
  const DatasourceDefinition({
    required this.name,
    required this.properties,
    this.line,
    this.column,
  });

  /// Datasource block name.
  final String name;

  /// Raw datasource properties keyed by property name.
  final Map<String, String> properties;

  /// One-based source line where the datasource block starts, if known.
  final int? line;

  /// One-based source column where the datasource block starts, if known.
  final int? column;
}

@immutable
/// Parsed generator block.
class GeneratorDefinition {
  /// Creates a generator definition.
  const GeneratorDefinition({
    required this.name,
    required this.properties,
    this.line,
    this.column,
  });

  /// Generator block name.
  final String name;

  /// Raw generator properties keyed by property name.
  final Map<String, String> properties;

  /// One-based source line where the generator block starts, if known.
  final int? line;

  /// One-based source column where the generator block starts, if known.
  final int? column;
}

@immutable
/// Parsed enum declaration.
class EnumDefinition {
  /// Creates an enum definition.
  const EnumDefinition({
    required this.name,
    required this.values,
    this.attributes = const <ModelAttribute>[],
    this.line,
    this.column,
  });

  /// Enum name.
  final String name;

  /// Enum values in source order.
  final List<String> values;

  /// Enum-level attributes such as `@@map`.
  final List<ModelAttribute> attributes;

  /// One-based source line where the enum block starts, if known.
  final int? line;

  /// One-based source column where the enum block starts, if known.
  final int? column;

  /// Database type name after applying `@@map`, if present.
  String get databaseName =>
      _mappedIdentifier(attribute('map')?.arguments['value']) ?? name;

  /// Finds the first enum-level attribute named [name].
  ModelAttribute? attribute(String name) {
    for (final attribute in attributes) {
      if (attribute.name == name) {
        return attribute;
      }
    }
    return null;
  }
}

@immutable
/// Parsed model declaration.
class ModelDefinition {
  /// Creates a model definition.
  const ModelDefinition({
    required this.name,
    required this.fields,
    this.attributes = const <ModelAttribute>[],
    this.line,
    this.column,
  });

  /// Model name from the schema.
  final String name;

  /// Field declarations in source order.
  final List<FieldDefinition> fields;

  /// Model-level attributes such as `@@id` and `@@unique`.
  final List<ModelAttribute> attributes;

  /// One-based source line where the model block starts, if known.
  final int? line;

  /// One-based source column where the model block starts, if known.
  final int? column;

  /// Database table name after applying `@@map`, if present.
  String get databaseName =>
      _mappedIdentifier(attribute('map')?.arguments['value']) ?? name;

  /// Whether this model is excluded with `@@ignore`.
  bool get isIgnored => attribute('ignore') != null;

  /// Finds a field by its schema name.
  FieldDefinition? findField(String name) {
    for (final field in fields) {
      if (field.name == name) {
        return field;
      }
    }

    return null;
  }

  /// Finds the first model-level attribute named [name].
  ModelAttribute? attribute(String name) {
    for (final attribute in attributes) {
      if (attribute.name == name) {
        return attribute;
      }
    }

    return null;
  }

  /// Finds a field by its mapped database column name.
  FieldDefinition? findFieldByDatabaseName(String databaseName) {
    for (final field in fields) {
      if (field.databaseName == databaseName) {
        return field;
      }
    }

    return null;
  }

  /// Iterates over model-level attributes named [name].
  Iterable<ModelAttribute> attributesNamed(String name) sync* {
    for (final attribute in attributes) {
      if (attribute.name == name) {
        yield attribute;
      }
    }
  }

  /// Returns field names declared by a list-style model attribute.
  List<String> attributeFieldNames(String name) {
    final target = attribute(name);
    if (target == null) {
      return const <String>[];
    }

    return _parseAttributeFieldList(
      target.arguments['fields'] ?? target.arguments['value'] ?? '',
    );
  }

  /// Returns a copy of this model without `@ignore` fields.
  ModelDefinition withoutIgnoredFields() {
    final visibleFields = fields
        .where((field) => !field.isIgnored)
        .toList(growable: false);
    final declaredFieldNames = fields.map((field) => field.name).toSet();
    final visibleFieldNames = visibleFields.map((field) => field.name).toSet();

    return ModelDefinition(
      name: name,
      fields: visibleFields,
      attributes: _filterIgnoredModelAttributes(
        attributes,
        declaredFieldNames,
        visibleFieldNames,
      ),
      line: line,
      column: column,
    );
  }

  /// Field names that make up the model primary key.
  List<String> get primaryKeyFields => attributeFieldNames('id');

  /// Compound unique field sets declared through `@@unique`.
  Iterable<List<String>> get compoundUniqueFieldSets =>
      attributesNamed('unique').map(
        (attribute) => _parseAttributeFieldList(
          attribute.arguments['fields'] ?? attribute.arguments['value'] ?? '',
        ),
      );
}

@immutable
/// Parsed model-level attribute.
class ModelAttribute {
  /// Creates a model attribute.
  const ModelAttribute({
    required this.name,
    required this.arguments,
    this.line,
    this.column,
  });

  /// Attribute name without the `@@` prefix.
  final String name;

  /// Parsed attribute arguments keyed by argument name.
  final Map<String, String> arguments;

  /// One-based source line where the attribute appears, if known.
  final int? line;

  /// One-based source column where the attribute appears, if known.
  final int? column;
}

@immutable
/// Parsed field declaration.
class FieldDefinition {
  /// Creates a field definition.
  const FieldDefinition({
    required this.name,
    required this.type,
    required this.isList,
    required this.isNullable,
    required this.attributes,
    this.line,
    this.column,
  });

  /// Field name from the schema.
  final String name;

  /// Scalar, enum, or relation target type.
  final String type;

  /// Whether the field is declared as a list.
  final bool isList;

  /// Whether the field is nullable.
  final bool isNullable;

  /// Field-level attributes such as `@id` or `@relation`.
  final List<FieldAttribute> attributes;

  /// One-based source line where the field appears, if known.
  final int? line;

  /// One-based source column where the field appears, if known.
  final int? column;

  /// Database column name after applying `@map`, if present.
  String get databaseName =>
      _mappedIdentifier(attribute('map')?.arguments['value']) ?? name;

  /// Whether this field is excluded with `@ignore`.
  bool get isIgnored => attribute('ignore') != null;

  /// Whether this field uses a known scalar type.
  bool get isScalar => kScalarTypes.contains(type);

  /// Finds the first field-level attribute named [name].
  FieldAttribute? attribute(String name) {
    for (final attribute in attributes) {
      if (attribute.name == name) {
        return attribute;
      }
    }

    return null;
  }

  /// Whether the field declares `@id`.
  bool get isId => attribute('id') != null;

  /// Whether the field declares `@unique`.
  bool get isUnique => attribute('unique') != null;

  /// Whether the field declares `@updatedAt`.
  bool get isUpdatedAt => attribute('updatedAt') != null;

  /// Provider-specific native type attribute such as `@db.Text`.
  FieldAttribute? get nativeTypeAttribute {
    for (final attribute in attributes) {
      if (attribute.name.startsWith('db.')) {
        return attribute;
      }
    }

    return null;
  }
}

@immutable
/// Parsed field-level attribute.
class FieldAttribute {
  /// Creates a field attribute.
  const FieldAttribute({
    required this.name,
    required this.arguments,
    this.line,
    this.column,
  });

  /// Attribute name without the `@` prefix.
  final String name;

  /// Parsed attribute arguments keyed by argument name.
  final Map<String, String> arguments;

  /// One-based source line where the attribute appears, if known.
  final int? line;

  /// One-based source column where the attribute appears, if known.
  final int? column;
}

@immutable
/// Validation issue emitted by the schema validator.
class ValidationIssue {
  /// Creates a validation issue.
  const ValidationIssue({
    required this.message,
    this.modelName,
    this.fieldName,
    this.filePath,
    this.line,
    this.column,
  });

  /// Human-readable issue message.
  final String message;

  /// Model name associated with the issue, if any.
  final String? modelName;

  /// Field name associated with the issue, if any.
  final String? fieldName;

  /// Source file path associated with the issue, if any.
  final String? filePath;

  /// One-based source line associated with the issue, if any.
  final int? line;

  /// One-based source column associated with the issue, if any.
  final int? column;

  @override
  String toString() {
    final buffer = StringBuffer();

    if (filePath != null) {
      buffer.write(filePath);
      if (line != null) {
        buffer.write(':$line');
        if (column != null) {
          buffer.write(':$column');
        }
      }
      buffer.write(': ');
    } else if (line != null) {
      buffer.write('line $line: ');
      if (column != null) {
        buffer.write('$column: ');
      }
    }

    if (modelName != null) {
      buffer.write(modelName);
    }
    if (fieldName != null) {
      if (buffer.isNotEmpty) {
        buffer.write('.');
      }
      buffer.write(fieldName);
    }
    if (buffer.isNotEmpty) {
      buffer.write(': ');
    }

    buffer.write(message);
    return buffer.toString();
  }
}

String? _mappedIdentifier(String? rawValue) {
  if (rawValue == null) {
    return null;
  }

  final trimmed = rawValue.trim();
  if (trimmed.length >= 2) {
    final first = trimmed[0];
    final last = trimmed[trimmed.length - 1];
    if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
      return trimmed.substring(1, trimmed.length - 1);
    }
  }

  return trimmed;
}

List<ModelAttribute> _filterIgnoredModelAttributes(
  List<ModelAttribute> attributes,
  Set<String> declaredFieldNames,
  Set<String> visibleFieldNames,
) {
  return attributes
      .where((attribute) {
        switch (attribute.name) {
          case 'id':
          case 'unique':
          case 'index':
            final fieldNames = _parseAttributeFieldList(
              attribute.arguments['fields'] ??
                  attribute.arguments['value'] ??
                  '',
            );
            return !fieldNames.any(
              (fieldName) =>
                  declaredFieldNames.contains(fieldName) &&
                  !visibleFieldNames.contains(fieldName),
            );
          default:
            return true;
        }
      })
      .toList(growable: false);
}

List<String> _parseAttributeFieldList(String rawValue) {
  final trimmed = rawValue.trim();
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
