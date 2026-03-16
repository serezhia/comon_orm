import 'dart:convert';

import 'package:meta/meta.dart';

import '../schema/schema_ast.dart';
import 'generated_runtime_schema.dart';

/// Bridge-level datasource URL kinds used by runtime metadata consumers.
enum RuntimeDatasourceUrlKind {
  /// URL is embedded directly in metadata.
  literal,

  /// URL comes from an environment variable reference.
  env,

  /// URL exists as a non-classified raw expression.
  expression,
}

/// Bridge-level field categories used by runtime consumers.
enum RuntimeFieldKind {
  /// Scalar field.
  scalar,

  /// Enum-backed field.
  enumeration,

  /// Relation field.
  relation,
}

/// Bridge-level default strategies relevant to runtime behavior.
enum RuntimeDefaultKind {
  /// No default.
  none,

  /// Literal default.
  literal,

  /// `now()` default.
  now,

  /// `autoincrement()` default.
  autoincrement,

  /// `cuid()` default.
  cuid,

  /// `uuid()` default.
  uuid,

  /// `dbgenerated(...)` default.
  dbGenerated,

  /// Opaque default expression.
  expression,
}

/// Bridge-level relation cardinality.
enum RuntimeRelationCardinality {
  /// Single target.
  one,

  /// Multiple targets.
  many,
}

/// Bridge-level relation storage kind.
enum RuntimeRelationStorageKind {
  /// Relation is stored directly through foreign keys.
  direct,

  /// Relation is stored through an implicit join table.
  implicitManyToMany,
}

@immutable
/// Runtime view of a datasource URL.
class RuntimeDatasourceUrlView {
  /// Creates a datasource URL view.
  const RuntimeDatasourceUrlView({required this.kind, required this.value});

  /// URL source kind.
  final RuntimeDatasourceUrlKind kind;

  /// Literal URL, env variable name, or raw expression.
  final String value;
}

@immutable
/// Runtime view of a field default.
class RuntimeFieldDefaultView {
  /// Creates a field default view.
  const RuntimeFieldDefaultView({required this.kind, this.value});

  /// Default kind.
  final RuntimeDefaultKind kind;

  /// Optional literal or expression payload.
  final String? value;
}

@immutable
/// Runtime relation view resolved from AST or generated metadata.
class RuntimeRelationView {
  /// Creates a relation view.
  const RuntimeRelationView({
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

  /// Target model name.
  final String targetModel;

  /// Cardinality from the source field point of view.
  final RuntimeRelationCardinality cardinality;

  /// Relation storage strategy.
  final RuntimeRelationStorageKind storageKind;

  /// Source-side local fields.
  final List<String> localFields;

  /// Target-side referenced fields.
  final List<String> targetFields;

  /// Optional explicit relation name.
  final String? relationName;

  /// Optional inverse field on the target model.
  final String? inverseField;

  /// Join table name for implicit many-to-many.
  final String? storageTableName;

  /// Source-side join columns for implicit many-to-many.
  final List<String> sourceJoinColumns;

  /// Target-side join columns for implicit many-to-many.
  final List<String> targetJoinColumns;
}

@immutable
/// Bridge-level implicit many-to-many storage description.
class RuntimeImplicitManyToManyStorage {
  /// Creates implicit many-to-many runtime storage metadata.
  const RuntimeImplicitManyToManyStorage({
    required this.tableName,
    required this.sourceModel,
    required this.sourceModelDatabaseName,
    required this.sourceField,
    required this.sourceFieldDatabaseName,
    required this.sourceKeyFields,
    required this.sourceJoinColumns,
    required this.targetModel,
    required this.targetModelDatabaseName,
    required this.targetField,
    required this.targetFieldDatabaseName,
    required this.targetKeyFields,
    required this.targetJoinColumns,
  });

  /// Join table name.
  final String tableName;

  /// Source model name.
  final String sourceModel;

  /// Source model database name.
  final String sourceModelDatabaseName;

  /// Source relation field name.
  final String sourceField;

  /// Source relation field database name.
  final String sourceFieldDatabaseName;

  /// Source key fields used in the join table.
  final List<String> sourceKeyFields;

  /// Source join columns stored in [tableName].
  final List<String> sourceJoinColumns;

  /// Target model name.
  final String targetModel;

  /// Target model database name.
  final String targetModelDatabaseName;

  /// Target relation field name.
  final String targetField;

  /// Target relation field database name.
  final String targetFieldDatabaseName;

  /// Target key fields used in the join table.
  final List<String> targetKeyFields;

  /// Target join columns stored in [tableName].
  final List<String> targetJoinColumns;

  /// Stable relation name for this storage mapping.
  String get relationName => tableName;

  /// Stable storage signature.
  String get signature =>
      '$sourceModelDatabaseName.$sourceFieldDatabaseName|${sourceKeyFields.join(',')}|${sourceJoinColumns.join(',')}|'
      '$targetModelDatabaseName.$targetFieldDatabaseName|${targetKeyFields.join(',')}|${targetJoinColumns.join(',')}';
}

/// Runtime schema bridge used by adapters and bootstrap helpers.
abstract interface class RuntimeSchemaView {
  /// Models in declaration order.
  List<RuntimeModelView> get models;

  /// Enums in declaration order.
  List<RuntimeEnumView> get enums;

  /// Datasources in declaration order.
  List<RuntimeDatasourceView> get datasources;

  /// Finds a model by logical name.
  RuntimeModelView? findModel(String name);

  /// Finds an enum by logical name.
  RuntimeEnumView? findEnum(String name);

  /// Finds an enum by database name.
  RuntimeEnumView? findEnumByDatabaseName(String databaseName);

  /// Finds a datasource by name.
  RuntimeDatasourceView? findDatasource(String name);
}

/// Runtime model bridge.
abstract interface class RuntimeModelView {
  /// Logical model name.
  String get name;

  /// Database table name.
  String get databaseName;

  /// Fields in declaration order.
  List<RuntimeFieldView> get fields;

  /// Primary key fields.
  List<String> get primaryKeyFields;

  /// Compound unique field sets.
  List<List<String>> get compoundUniqueFieldSets;

  /// Finds a field by logical name.
  RuntimeFieldView? findField(String name);

  /// Finds a field by database name.
  RuntimeFieldView? findFieldByDatabaseName(String databaseName);
}

/// Runtime field bridge.
abstract interface class RuntimeFieldView {
  /// Logical field name.
  String get name;

  /// Database field name.
  String get databaseName;

  /// Field category.
  RuntimeFieldKind get kind;

  /// Scalar type, enum name, or related model name.
  String get type;

  /// Whether the field is nullable.
  bool get isNullable;

  /// Whether the field is a list.
  bool get isList;

  /// Whether the field is marked as id.
  bool get isId;

  /// Whether the field is unique.
  bool get isUnique;

  /// Whether the field is marked `@updatedAt`.
  bool get isUpdatedAt;

  /// Provider-specific native type.
  String? get nativeType;

  /// Optional default metadata.
  RuntimeFieldDefaultView? get defaultValue;

  /// Optional resolved relation metadata.
  RuntimeRelationView? get relation;
}

/// Runtime enum bridge.
abstract interface class RuntimeEnumView {
  /// Logical enum name.
  String get name;

  /// Database enum type name.
  String get databaseName;

  /// Enum values in declaration order.
  List<String> get values;
}

/// Runtime datasource bridge.
abstract interface class RuntimeDatasourceView {
  /// Datasource name.
  String get name;

  /// Datasource provider.
  String get provider;

  /// Datasource URL view.
  RuntimeDatasourceUrlView get url;
}

/// Creates a runtime schema bridge over [schema].
RuntimeSchemaView runtimeSchemaViewFromSchemaDocument(SchemaDocument schema) {
  return _AstRuntimeSchemaView(schema);
}

/// Creates a runtime schema bridge over [schema].
RuntimeSchemaView runtimeSchemaViewFromGeneratedSchema(
  GeneratedRuntimeSchema schema,
) {
  return _GeneratedRuntimeSchemaView(schema);
}

/// Collects all implicit many-to-many storages from a runtime schema view.
List<RuntimeImplicitManyToManyStorage> collectRuntimeImplicitManyToManyStorages(
  RuntimeSchemaView schema,
) {
  final storages = <RuntimeImplicitManyToManyStorage>[];
  final seenTableNames = <String>{};

  for (final model in schema.models) {
    for (final field in model.fields) {
      final storage = resolveRuntimeImplicitManyToManyStorage(
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
  return List<RuntimeImplicitManyToManyStorage>.unmodifiable(storages);
}

/// Resolves the storage mapping for a runtime implicit many-to-many relation.
RuntimeImplicitManyToManyStorage? resolveRuntimeImplicitManyToManyStorage({
  required RuntimeSchemaView schema,
  required String sourceModelName,
  required String relationFieldName,
}) {
  final sourceModel = schema.findModel(sourceModelName);
  final sourceField = sourceModel?.findField(relationFieldName);
  if (sourceModel == null || sourceField == null) {
    return null;
  }

  final relation = sourceField.relation;
  if (relation == null ||
      relation.storageKind != RuntimeRelationStorageKind.implicitManyToMany) {
    return null;
  }

  final targetModel = schema.findModel(relation.targetModel);
  final targetField = relation.inverseField == null
      ? null
      : targetModel?.findField(relation.inverseField!);
  if (targetModel == null || targetField == null) {
    return null;
  }

  final sourceJoinColumns = relation.sourceJoinColumns.isEmpty
      ? relation.localFields
            .map(
              (keyField) => _implicitManyToManyJoinColumn(
                modelDatabaseName: sourceModel.databaseName,
                relationFieldDatabaseName: sourceField.databaseName,
                keyFieldDatabaseName:
                    sourceModel.findField(keyField)?.databaseName ?? keyField,
              ),
            )
            .toList(growable: false)
      : relation.sourceJoinColumns;
  final targetJoinColumns = relation.targetJoinColumns.isEmpty
      ? relation.targetFields
            .map(
              (keyField) => _implicitManyToManyJoinColumn(
                modelDatabaseName: targetModel.databaseName,
                relationFieldDatabaseName: targetField.databaseName,
                keyFieldDatabaseName:
                    targetModel.findField(keyField)?.databaseName ?? keyField,
              ),
            )
            .toList(growable: false)
      : relation.targetJoinColumns;

  final left = _RuntimeImplicitRelationEndpoint(
    modelName: sourceModel.name,
    modelDatabaseName: sourceModel.databaseName,
    fieldName: sourceField.name,
    fieldDatabaseName: sourceField.databaseName,
  );
  final right = _RuntimeImplicitRelationEndpoint(
    modelName: targetModel.name,
    modelDatabaseName: targetModel.databaseName,
    fieldName: targetField.name,
    fieldDatabaseName: targetField.databaseName,
  );
  final ordered = <_RuntimeImplicitRelationEndpoint>[left, right]
    ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

  return RuntimeImplicitManyToManyStorage(
    tableName:
        relation.storageTableName ??
        _implicitManyToManyTableName(ordered[0], ordered[1]),
    sourceModel: sourceModel.name,
    sourceModelDatabaseName: sourceModel.databaseName,
    sourceField: sourceField.name,
    sourceFieldDatabaseName: sourceField.databaseName,
    sourceKeyFields: List<String>.unmodifiable(relation.localFields),
    sourceJoinColumns: List<String>.unmodifiable(sourceJoinColumns),
    targetModel: targetModel.name,
    targetModelDatabaseName: targetModel.databaseName,
    targetField: targetField.name,
    targetFieldDatabaseName: targetField.databaseName,
    targetKeyFields: List<String>.unmodifiable(relation.targetFields),
    targetJoinColumns: List<String>.unmodifiable(targetJoinColumns),
  );
}

final class _AstRuntimeSchemaView implements RuntimeSchemaView {
  const _AstRuntimeSchemaView(this._schema);

  final SchemaDocument _schema;

  @override
  List<RuntimeModelView> get models => _schema.models
      .map((model) => _AstRuntimeModelView(schema: _schema, model: model))
      .toList(growable: false);

  @override
  List<RuntimeEnumView> get enums => _schema.enums
      .map((definition) => _AstRuntimeEnumView(definition))
      .toList(growable: false);

  @override
  List<RuntimeDatasourceView> get datasources => _schema.datasources
      .map((definition) => _AstRuntimeDatasourceView(definition))
      .toList(growable: false);

  @override
  RuntimeModelView? findModel(String name) {
    final model = _schema.findModel(name);
    if (model == null) {
      return null;
    }
    return _AstRuntimeModelView(schema: _schema, model: model);
  }

  @override
  RuntimeEnumView? findEnum(String name) {
    final definition = _schema.findEnum(name);
    return definition == null ? null : _AstRuntimeEnumView(definition);
  }

  @override
  RuntimeEnumView? findEnumByDatabaseName(String databaseName) {
    final definition = _schema.findEnumByDatabaseName(databaseName);
    return definition == null ? null : _AstRuntimeEnumView(definition);
  }

  @override
  RuntimeDatasourceView? findDatasource(String name) {
    final datasource = _schema.findDatasource(name);
    return datasource == null ? null : _AstRuntimeDatasourceView(datasource);
  }
}

final class _AstRuntimeModelView implements RuntimeModelView {
  const _AstRuntimeModelView({
    required SchemaDocument schema,
    required ModelDefinition model,
  }) : _schema = schema,
       _model = model;

  final SchemaDocument _schema;
  final ModelDefinition _model;

  @override
  String get name => _model.name;

  @override
  String get databaseName => _model.databaseName;

  @override
  List<RuntimeFieldView> get fields => _model.fields
      .map(
        (field) =>
            _AstRuntimeFieldView(schema: _schema, model: _model, field: field),
      )
      .toList(growable: false);

  @override
  List<String> get primaryKeyFields {
    final fieldLevelIds = _model.fields
        .where((field) => field.isId)
        .map((field) => field.name)
        .toList(growable: false);
    if (fieldLevelIds.isNotEmpty) {
      return List<String>.unmodifiable(fieldLevelIds);
    }

    return List<String>.unmodifiable(_model.primaryKeyFields);
  }

  @override
  List<List<String>> get compoundUniqueFieldSets => _model
      .compoundUniqueFieldSets
      .map((fieldSet) => List<String>.unmodifiable(fieldSet))
      .toList(growable: false);

  @override
  RuntimeFieldView? findField(String name) {
    final field = _model.findField(name);
    if (field == null) {
      return null;
    }
    return _AstRuntimeFieldView(schema: _schema, model: _model, field: field);
  }

  @override
  RuntimeFieldView? findFieldByDatabaseName(String databaseName) {
    final field = _model.findFieldByDatabaseName(databaseName);
    if (field == null) {
      return null;
    }
    return _AstRuntimeFieldView(schema: _schema, model: _model, field: field);
  }
}

final class _AstRuntimeFieldView implements RuntimeFieldView {
  const _AstRuntimeFieldView({
    required SchemaDocument schema,
    required ModelDefinition model,
    required FieldDefinition field,
  }) : _schema = schema,
       _model = model,
       _field = field;

  final SchemaDocument _schema;
  final ModelDefinition _model;
  final FieldDefinition _field;

  @override
  String get name => _field.name;

  @override
  String get databaseName => _field.databaseName;

  @override
  RuntimeFieldKind get kind {
    if (_field.isScalar) {
      return RuntimeFieldKind.scalar;
    }
    if (_schema.findEnum(_field.type) != null) {
      return RuntimeFieldKind.enumeration;
    }
    return RuntimeFieldKind.relation;
  }

  @override
  String get type => _field.type;

  @override
  bool get isNullable => _field.isNullable;

  @override
  bool get isList => _field.isList;

  @override
  bool get isId => _field.isId;

  @override
  bool get isUnique => _field.isUnique;

  @override
  bool get isUpdatedAt => _field.isUpdatedAt;

  @override
  String? get nativeType => _field.nativeTypeAttribute?.name;

  @override
  RuntimeFieldDefaultView? get defaultValue {
    final attribute = _field.attribute('default');
    if (attribute == null) {
      return null;
    }

    final rawValue = (attribute.arguments['value'] ?? '').trim();
    if (rawValue.isEmpty) {
      return const RuntimeFieldDefaultView(kind: RuntimeDefaultKind.none);
    }

    return _runtimeDefaultFromRaw(rawValue);
  }

  @override
  RuntimeRelationView? get relation {
    if (kind != RuntimeFieldKind.relation) {
      return null;
    }

    final targetModel = _schema.findModel(_field.type);
    if (targetModel == null) {
      return null;
    }
    final opposite = _astOppositeRelationField(_schema, _model, _field);
    final relationName =
        _astRelationName(_field.attribute('relation')) ??
        (opposite == null
            ? null
            : _astRelationName(opposite.attribute('relation')));

    if (_field.isList && opposite?.isList == true) {
      return RuntimeRelationView(
        targetModel: targetModel.name,
        cardinality: RuntimeRelationCardinality.many,
        storageKind: RuntimeRelationStorageKind.implicitManyToMany,
        localFields: _implicitManyToManyKeyFields(
          _AstRuntimeModelView(schema: _schema, model: _model),
        ),
        targetFields: _implicitManyToManyKeyFields(
          _AstRuntimeModelView(schema: _schema, model: targetModel),
        ),
        relationName: relationName,
        inverseField: opposite?.name,
      );
    }

    final directFields = _astDirectRelationFields(
      schema: _schema,
      sourceModel: _model,
      relationField: _field,
    );
    return RuntimeRelationView(
      targetModel: targetModel.name,
      cardinality: _field.isList
          ? RuntimeRelationCardinality.many
          : RuntimeRelationCardinality.one,
      storageKind: RuntimeRelationStorageKind.direct,
      localFields: directFields.$1,
      targetFields: directFields.$2,
      relationName: relationName,
      inverseField: opposite?.name,
    );
  }
}

final class _AstRuntimeEnumView implements RuntimeEnumView {
  const _AstRuntimeEnumView(this._definition);

  final EnumDefinition _definition;

  @override
  String get name => _definition.name;

  @override
  String get databaseName => _definition.databaseName;

  @override
  List<String> get values => List<String>.unmodifiable(_definition.values);
}

final class _AstRuntimeDatasourceView implements RuntimeDatasourceView {
  const _AstRuntimeDatasourceView(this._definition);

  final DatasourceDefinition _definition;

  @override
  String get name => _definition.name;

  @override
  String get provider =>
      _stripWrappingQuotes((_definition.properties['provider'] ?? '').trim());

  @override
  RuntimeDatasourceUrlView get url => _runtimeDatasourceUrlFromRaw(
    (_definition.properties['url'] ?? '').trim(),
  );
}

final class _GeneratedRuntimeSchemaView implements RuntimeSchemaView {
  const _GeneratedRuntimeSchemaView(this._schema);

  final GeneratedRuntimeSchema _schema;

  @override
  List<RuntimeModelView> get models => _schema.models
      .map((model) => _GeneratedRuntimeModelView(model))
      .toList(growable: false);

  @override
  List<RuntimeEnumView> get enums => _schema.enums
      .map((definition) => _GeneratedRuntimeEnumView(definition))
      .toList(growable: false);

  @override
  List<RuntimeDatasourceView> get datasources => _schema.datasources
      .map((definition) => _GeneratedRuntimeDatasourceView(definition))
      .toList(growable: false);

  @override
  RuntimeModelView? findModel(String name) {
    final model = _schema.findModel(name);
    return model == null ? null : _GeneratedRuntimeModelView(model);
  }

  @override
  RuntimeEnumView? findEnum(String name) {
    final definition = _schema.findEnum(name);
    return definition == null ? null : _GeneratedRuntimeEnumView(definition);
  }

  @override
  RuntimeEnumView? findEnumByDatabaseName(String databaseName) {
    final definition = _schema.findEnumByDatabaseName(databaseName);
    return definition == null ? null : _GeneratedRuntimeEnumView(definition);
  }

  @override
  RuntimeDatasourceView? findDatasource(String name) {
    final datasource = _schema.findDatasource(name);
    return datasource == null
        ? null
        : _GeneratedRuntimeDatasourceView(datasource);
  }
}

final class _GeneratedRuntimeModelView implements RuntimeModelView {
  const _GeneratedRuntimeModelView(this._model);

  final GeneratedModelMetadata _model;

  @override
  String get name => _model.name;

  @override
  String get databaseName => _model.databaseName;

  @override
  List<RuntimeFieldView> get fields => _model.fields
      .map((field) => _GeneratedRuntimeFieldView(field))
      .toList(growable: false);

  @override
  List<String> get primaryKeyFields =>
      List<String>.unmodifiable(_model.primaryKeyFields);

  @override
  List<List<String>> get compoundUniqueFieldSets => _model
      .compoundUniqueFieldSets
      .map((fieldSet) => List<String>.unmodifiable(fieldSet))
      .toList(growable: false);

  @override
  RuntimeFieldView? findField(String name) {
    final field = _model.findField(name);
    return field == null ? null : _GeneratedRuntimeFieldView(field);
  }

  @override
  RuntimeFieldView? findFieldByDatabaseName(String databaseName) {
    final field = _model.findFieldByDatabaseName(databaseName);
    return field == null ? null : _GeneratedRuntimeFieldView(field);
  }
}

final class _GeneratedRuntimeFieldView implements RuntimeFieldView {
  const _GeneratedRuntimeFieldView(this._field);

  final GeneratedFieldMetadata _field;

  @override
  String get name => _field.name;

  @override
  String get databaseName => _field.databaseName;

  @override
  RuntimeFieldKind get kind => switch (_field.kind) {
    GeneratedRuntimeFieldKind.scalar => RuntimeFieldKind.scalar,
    GeneratedRuntimeFieldKind.enumeration => RuntimeFieldKind.enumeration,
    GeneratedRuntimeFieldKind.relation => RuntimeFieldKind.relation,
  };

  @override
  String get type => _field.type;

  @override
  bool get isNullable => _field.isNullable;

  @override
  bool get isList => _field.isList;

  @override
  bool get isId => _field.isId;

  @override
  bool get isUnique => _field.isUnique;

  @override
  bool get isUpdatedAt => _field.isUpdatedAt;

  @override
  String? get nativeType => _field.nativeType;

  @override
  RuntimeFieldDefaultView? get defaultValue {
    final defaultValue = _field.defaultValue;
    if (defaultValue == null) {
      return null;
    }
    return RuntimeFieldDefaultView(
      kind: switch (defaultValue.kind) {
        GeneratedRuntimeDefaultKind.none => RuntimeDefaultKind.none,
        GeneratedRuntimeDefaultKind.literal => RuntimeDefaultKind.literal,
        GeneratedRuntimeDefaultKind.now => RuntimeDefaultKind.now,
        GeneratedRuntimeDefaultKind.autoincrement =>
          RuntimeDefaultKind.autoincrement,
        GeneratedRuntimeDefaultKind.cuid => RuntimeDefaultKind.cuid,
        GeneratedRuntimeDefaultKind.uuid => RuntimeDefaultKind.uuid,
        GeneratedRuntimeDefaultKind.dbGenerated =>
          RuntimeDefaultKind.dbGenerated,
        GeneratedRuntimeDefaultKind.expression => RuntimeDefaultKind.expression,
      },
      value: defaultValue.value,
    );
  }

  @override
  RuntimeRelationView? get relation {
    final relation = _field.relation;
    if (relation == null) {
      return null;
    }
    return RuntimeRelationView(
      targetModel: relation.targetModel,
      cardinality: switch (relation.cardinality) {
        GeneratedRuntimeRelationCardinality.one =>
          RuntimeRelationCardinality.one,
        GeneratedRuntimeRelationCardinality.many =>
          RuntimeRelationCardinality.many,
      },
      storageKind: switch (relation.storageKind) {
        GeneratedRuntimeRelationStorageKind.direct =>
          RuntimeRelationStorageKind.direct,
        GeneratedRuntimeRelationStorageKind.implicitManyToMany =>
          RuntimeRelationStorageKind.implicitManyToMany,
      },
      localFields: List<String>.unmodifiable(relation.localFields),
      targetFields: List<String>.unmodifiable(relation.targetFields),
      relationName: relation.relationName,
      inverseField: relation.inverseField,
      storageTableName: relation.storageTableName,
      sourceJoinColumns: List<String>.unmodifiable(relation.sourceJoinColumns),
      targetJoinColumns: List<String>.unmodifiable(relation.targetJoinColumns),
    );
  }
}

final class _GeneratedRuntimeEnumView implements RuntimeEnumView {
  const _GeneratedRuntimeEnumView(this._definition);

  final GeneratedEnumMetadata _definition;

  @override
  String get name => _definition.name;

  @override
  String get databaseName => _definition.databaseName;

  @override
  List<String> get values => List<String>.unmodifiable(_definition.values);
}

final class _GeneratedRuntimeDatasourceView implements RuntimeDatasourceView {
  const _GeneratedRuntimeDatasourceView(this._definition);

  final GeneratedDatasourceMetadata _definition;

  @override
  String get name => _definition.name;

  @override
  String get provider => _definition.provider;

  @override
  RuntimeDatasourceUrlView get url => RuntimeDatasourceUrlView(
    kind: switch (_definition.url.kind) {
      GeneratedDatasourceUrlKind.literal => RuntimeDatasourceUrlKind.literal,
      GeneratedDatasourceUrlKind.env => RuntimeDatasourceUrlKind.env,
      GeneratedDatasourceUrlKind.expression =>
        RuntimeDatasourceUrlKind.expression,
    },
    value: _definition.url.value,
  );
}

FieldDefinition? _astOppositeRelationField(
  SchemaDocument schema,
  ModelDefinition sourceModel,
  FieldDefinition relationField,
) {
  final targetModel = schema.findModel(relationField.type);
  if (targetModel == null) {
    return null;
  }

  final relationName = _astRelationName(relationField.attribute('relation'));
  final candidates = targetModel.fields
      .where((candidate) => !candidate.isScalar)
      .where((candidate) => schema.findEnum(candidate.type) == null)
      .where((candidate) => candidate.type == sourceModel.name)
      .where(
        (candidate) =>
            targetModel.name != sourceModel.name ||
            candidate.name != relationField.name,
      )
      .where((candidate) {
        final candidateRelationName = _astRelationName(
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

(List<String>, List<String>) _astDirectRelationFields({
  required SchemaDocument schema,
  required ModelDefinition sourceModel,
  required FieldDefinition relationField,
}) {
  final ownRelation = relationField.attribute('relation');
  if (ownRelation != null) {
    final fields = _parseRelationList(ownRelation.arguments['fields']);
    final references = _parseRelationList(ownRelation.arguments['references']);
    if (fields.isNotEmpty && references.isNotEmpty) {
      return (
        List<String>.unmodifiable(fields),
        List<String>.unmodifiable(references),
      );
    }
  }

  final opposite = _astOppositeRelationField(
    schema,
    sourceModel,
    relationField,
  );
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

String? _astRelationName(FieldAttribute? relation) {
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

RuntimeDatasourceUrlView _runtimeDatasourceUrlFromRaw(String rawValue) {
  final trimmed = rawValue.trim();
  final envMatch = RegExp("^env\\((['\"])(.+)\\1\\)").firstMatch(trimmed);
  if (envMatch != null) {
    return RuntimeDatasourceUrlView(
      kind: RuntimeDatasourceUrlKind.env,
      value: envMatch.group(2)!,
    );
  }

  if (trimmed.isEmpty) {
    return const RuntimeDatasourceUrlView(
      kind: RuntimeDatasourceUrlKind.expression,
      value: '',
    );
  }

  final stripped = _stripWrappingQuotes(trimmed);
  if (stripped != trimmed || !trimmed.contains('(')) {
    return RuntimeDatasourceUrlView(
      kind: RuntimeDatasourceUrlKind.literal,
      value: stripped,
    );
  }

  return RuntimeDatasourceUrlView(
    kind: RuntimeDatasourceUrlKind.expression,
    value: trimmed,
  );
}

RuntimeFieldDefaultView _runtimeDefaultFromRaw(String rawValue) {
  final trimmed = rawValue.trim();
  if (trimmed == 'now()') {
    return const RuntimeFieldDefaultView(kind: RuntimeDefaultKind.now);
  }
  if (trimmed == 'autoincrement()') {
    return const RuntimeFieldDefaultView(
      kind: RuntimeDefaultKind.autoincrement,
    );
  }
  if (trimmed == 'cuid()') {
    return const RuntimeFieldDefaultView(kind: RuntimeDefaultKind.cuid);
  }
  if (trimmed == 'uuid()') {
    return const RuntimeFieldDefaultView(kind: RuntimeDefaultKind.uuid);
  }
  if (trimmed.startsWith('dbgenerated(')) {
    return RuntimeFieldDefaultView(
      kind: RuntimeDefaultKind.dbGenerated,
      value: trimmed,
    );
  }

  final stripped = _stripWrappingQuotes(trimmed);
  final isLiteral =
      stripped != trimmed ||
      RegExp(r'^-?\d+(\.\d+)?$').hasMatch(trimmed) ||
      trimmed == 'true' ||
      trimmed == 'false' ||
      trimmed == 'null';
  if (isLiteral) {
    return RuntimeFieldDefaultView(
      kind: RuntimeDefaultKind.literal,
      value: stripped,
    );
  }

  return RuntimeFieldDefaultView(
    kind: RuntimeDefaultKind.expression,
    value: trimmed,
  );
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

List<String> _implicitManyToManyKeyFields(RuntimeModelView model) {
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
  _RuntimeImplicitRelationEndpoint first,
  _RuntimeImplicitRelationEndpoint second,
) {
  return '_comon_orm_m2m__'
      '${_encodeIdentifierSegment(first.modelDatabaseName)}__'
      '${_encodeIdentifierSegment(first.fieldDatabaseName)}__'
      '${_encodeIdentifierSegment(second.modelDatabaseName)}__'
      '${_encodeIdentifierSegment(second.fieldDatabaseName)}';
}

String _encodeIdentifierSegment(String value) {
  return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
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

class _RuntimeImplicitRelationEndpoint {
  const _RuntimeImplicitRelationEndpoint({
    required this.modelName,
    required this.modelDatabaseName,
    required this.fieldName,
    required this.fieldDatabaseName,
  });

  final String modelName;
  final String modelDatabaseName;
  final String fieldName;
  final String fieldDatabaseName;

  String get sortKey => '$modelDatabaseName.$fieldDatabaseName';
}
