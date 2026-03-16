import 'package:meta/meta.dart';

/// Parser-independent URL source kinds for generated datasource metadata.
enum GeneratedDatasourceUrlKind {
  /// URL is embedded directly in generated metadata.
  literal,

  /// URL is resolved from an environment variable.
  env,

  /// URL expression exists but is not yet classified more specifically.
  expression,
}

/// Runtime field categories used by generated metadata.
enum GeneratedRuntimeFieldKind {
  /// Scalar field such as `Int` or `String`.
  scalar,

  /// Enum-backed field.
  enumeration,

  /// Relation field.
  relation,
}

/// Runtime default-value strategies relevant to adapters.
enum GeneratedRuntimeDefaultKind {
  /// No default is declared.
  none,

  /// Default is a literal value emitted in metadata.
  literal,

  /// Default uses `now()`.
  now,

  /// Default uses `autoincrement()`.
  autoincrement,

  /// Default uses `cuid()`.
  cuid,

  /// Default uses `uuid()`.
  uuid,

  /// Default uses `dbgenerated(...)`.
  dbGenerated,

  /// Default exists but is represented as an opaque expression.
  expression,
}

/// Cardinality of a generated relation from the source field point of view.
enum GeneratedRuntimeRelationCardinality {
  /// Relation points to at most one record.
  one,

  /// Relation points to many records.
  many,
}

/// Physical storage strategy for a generated relation.
enum GeneratedRuntimeRelationStorageKind {
  /// Relation is stored through regular foreign-key columns.
  direct,

  /// Relation is stored through an implicit join table.
  implicitManyToMany,
}

@immutable
/// Generated datasource URL description for runtime bootstrap.
class GeneratedDatasourceUrl {
  /// Creates generated datasource URL metadata.
  const GeneratedDatasourceUrl({required this.kind, required this.value});

  /// URL source kind.
  final GeneratedDatasourceUrlKind kind;

  /// Literal URL, env var name, or raw expression depending on [kind].
  final String value;
}

@immutable
/// Generated datasource metadata for runtime bootstrap.
class GeneratedDatasourceMetadata {
  /// Creates generated datasource metadata.
  const GeneratedDatasourceMetadata({
    required this.name,
    required this.provider,
    required this.url,
  });

  /// Datasource block name.
  final String name;

  /// Datasource provider such as `postgresql` or `sqlite`.
  final String provider;

  /// URL source description for runtime resolution.
  final GeneratedDatasourceUrl url;
}

@immutable
/// Generated default metadata for a field.
class GeneratedFieldDefaultMetadata {
  /// Creates generated field default metadata.
  const GeneratedFieldDefaultMetadata({required this.kind, this.value});

  /// Default strategy.
  final GeneratedRuntimeDefaultKind kind;

  /// Optional literal or expression payload.
  final String? value;
}

@immutable
/// Generated relation metadata attached to a relation field.
class GeneratedRelationMetadata {
  /// Creates generated relation metadata.
  const GeneratedRelationMetadata({
    required this.targetModel,
    required this.cardinality,
    required this.storageKind,
    required this.localFields,
    required this.targetFields,
    this.relationName,
    this.inverseField,
    this.storageTableName,
    this.sourceJoinColumns = const <String>[],
    this.targetJoinColumns = const <String>[],
  });

  /// Related model name.
  final String targetModel;

  /// Relation cardinality from the source field point of view.
  final GeneratedRuntimeRelationCardinality cardinality;

  /// Storage strategy used by the relation.
  final GeneratedRuntimeRelationStorageKind storageKind;

  /// Source-side local fields used to resolve the relation.
  final List<String> localFields;

  /// Target-side referenced fields.
  final List<String> targetFields;

  /// Optional relation name for explicit or disambiguated relations.
  final String? relationName;

  /// Optional inverse field name on the target model.
  final String? inverseField;

  /// Join table name for implicit many-to-many relations.
  final String? storageTableName;

  /// Source-side join columns for implicit many-to-many storage.
  final List<String> sourceJoinColumns;

  /// Target-side join columns for implicit many-to-many storage.
  final List<String> targetJoinColumns;
}

@immutable
/// Generated field metadata used by runtime bridge and adapters.
class GeneratedFieldMetadata {
  /// Creates generated field metadata.
  const GeneratedFieldMetadata({
    required this.name,
    required this.databaseName,
    required this.kind,
    required this.type,
    required this.isNullable,
    required this.isList,
    this.isId = false,
    this.isUnique = false,
    this.isUpdatedAt = false,
    this.nativeType,
    this.defaultValue,
    this.relation,
  });

  /// Field name in generated client APIs.
  final String name;

  /// Mapped database column or relation-field name.
  final String databaseName;

  /// Runtime field category.
  final GeneratedRuntimeFieldKind kind;

  /// Scalar type, enum name, or related model name.
  final String type;

  /// Whether the field is nullable.
  final bool isNullable;

  /// Whether the field is a list.
  final bool isList;

  /// Whether the field participates as a scalar `@id`.
  final bool isId;

  /// Whether the field declares scalar `@unique`.
  final bool isUnique;

  /// Whether the field declares `@updatedAt`.
  final bool isUpdatedAt;

  /// Optional provider-specific native type name.
  final String? nativeType;

  /// Optional default metadata.
  final GeneratedFieldDefaultMetadata? defaultValue;

  /// Relation metadata when [kind] is `relation`.
  final GeneratedRelationMetadata? relation;
}

@immutable
/// Generated enum metadata for runtime lookup and normalization.
class GeneratedEnumMetadata {
  /// Creates generated enum metadata.
  const GeneratedEnumMetadata({
    required this.name,
    required this.databaseName,
    required this.values,
  });

  /// Logical enum name.
  final String name;

  /// Mapped database enum type name.
  final String databaseName;

  /// Enum values in declaration order.
  final List<String> values;
}

@immutable
/// Generated model metadata for runtime lookup and relation resolution.
class GeneratedModelMetadata {
  /// Creates generated model metadata.
  const GeneratedModelMetadata({
    required this.name,
    required this.databaseName,
    required this.fields,
    this.primaryKeyFields = const <String>[],
    this.compoundUniqueFieldSets = const <List<String>>[],
  });

  /// Logical model name.
  final String name;

  /// Mapped database table name.
  final String databaseName;

  /// Fields declared on the model.
  final List<GeneratedFieldMetadata> fields;

  /// Ordered field names that form the model primary key.
  final List<String> primaryKeyFields;

  /// Ordered compound unique field sets.
  final List<List<String>> compoundUniqueFieldSets;

  /// Finds a field by its logical name.
  GeneratedFieldMetadata? findField(String name) {
    for (final field in fields) {
      if (field.name == name) {
        return field;
      }
    }

    return null;
  }

  /// Finds a field by its mapped database name.
  GeneratedFieldMetadata? findFieldByDatabaseName(String databaseName) {
    for (final field in fields) {
      if (field.databaseName == databaseName) {
        return field;
      }
    }

    return null;
  }
}

@immutable
/// Root generated runtime schema emitted by generated clients.
class GeneratedRuntimeSchema {
  /// Creates generated runtime schema metadata.
  const GeneratedRuntimeSchema({
    required this.models,
    this.enums = const <GeneratedEnumMetadata>[],
    this.datasources = const <GeneratedDatasourceMetadata>[],
  });

  /// Generated models in declaration order.
  final List<GeneratedModelMetadata> models;

  /// Generated enums in declaration order.
  final List<GeneratedEnumMetadata> enums;

  /// Generated datasources in declaration order.
  final List<GeneratedDatasourceMetadata> datasources;

  /// Finds model metadata by logical name.
  GeneratedModelMetadata? findModel(String name) {
    for (final model in models) {
      if (model.name == name) {
        return model;
      }
    }

    return null;
  }

  /// Finds enum metadata by logical name.
  GeneratedEnumMetadata? findEnum(String name) {
    for (final definition in enums) {
      if (definition.name == name) {
        return definition;
      }
    }

    return null;
  }

  /// Finds enum metadata by mapped database name.
  GeneratedEnumMetadata? findEnumByDatabaseName(String databaseName) {
    for (final definition in enums) {
      if (definition.databaseName == databaseName) {
        return definition;
      }
    }

    return null;
  }

  /// Finds datasource metadata by block name.
  GeneratedDatasourceMetadata? findDatasource(String name) {
    for (final datasource in datasources) {
      if (datasource.name == name) {
        return datasource;
      }
    }

    return null;
  }
}
