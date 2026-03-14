import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_schema_introspector.dart';
import 'sqlite_schema_applier.dart';

/// SQLite schema diff result.
class SqliteMigrationPlan implements PlannedMigration {
  /// Creates a migration plan.
  const SqliteMigrationPlan({
    required this.statements,
    required this.warnings,
    this.requiresRebuild = false,
  });

  /// SQL statements that can be applied directly.
  @override
  final List<String> statements;

  /// Human-readable warnings that require operator review.
  @override
  final List<String> warnings;

  /// Whether the change requires a schema rebuild.
  @override
  final bool requiresRebuild;

  /// Whether the plan contains no statements, warnings, or rebuilds.
  bool get isEmpty =>
      statements.isEmpty && warnings.isEmpty && !requiresRebuild;
}

/// Computes SQLite migration plans from schema diffs or live databases.
class SqliteMigrationPlanner {
  /// Creates a SQLite migration planner.
  const SqliteMigrationPlanner({
    this.schemaApplier = const SqliteSchemaApplier(),
    this.schemaIntrospector = const SqliteSchemaIntrospector(),
  });

  /// Helper used to render SQLite DDL statements.
  final SqliteSchemaApplier schemaApplier;

  /// Helper used to introspect live SQLite schemas.
  final SqliteSchemaIntrospector schemaIntrospector;

  /// Builds a plan by introspecting the live database first.
  SqliteMigrationPlan planFromDatabase({
    required sqlite.Database database,
    required SchemaDocument to,
  }) {
    return plan(from: schemaIntrospector.introspect(database), to: to);
  }

  /// Builds a plan from two schema snapshots.
  SqliteMigrationPlan plan({
    required SchemaDocument from,
    required SchemaDocument to,
  }) {
    final statements = <String>[];
    final warnings = <String>[];
    var requiresRebuild = false;

    final fromModels = {for (final model in from.models) model.name: model};

    for (final targetModel in to.models) {
      final sourceModel =
          fromModels.remove(targetModel.name) ??
          _removeModelByDatabaseName(fromModels, targetModel.databaseName);
      if (sourceModel == null) {
        statements.add(
          schemaApplier.createTableStatementForModel(targetModel, schema: to),
        );
        continue;
      }

      _planModelDiff(
        targetSchema: to,
        sourceModel: sourceModel,
        targetModel: targetModel,
        statements: statements,
        warnings: warnings,
        markRequiresRebuild: () => requiresRebuild = true,
      );
    }

    for (final removedModel in fromModels.values) {
      warnings.add(
        'Dropping model ${removedModel.name} requires manual migration.',
      );
    }

    _planImplicitManyToManyDiffs(
      from: from,
      to: to,
      statements: statements,
      warnings: warnings,
      markRequiresRebuild: () => requiresRebuild = true,
    );

    return SqliteMigrationPlan(
      statements: List<String>.unmodifiable(statements),
      warnings: List<String>.unmodifiable(warnings),
      requiresRebuild: requiresRebuild,
    );
  }

  void _planImplicitManyToManyDiffs({
    required SchemaDocument from,
    required SchemaDocument to,
    required List<String> statements,
    required List<String> warnings,
    required void Function() markRequiresRebuild,
  }) {
    final sourceStorages = {
      for (final storage in collectImplicitManyToManyStorages(from))
        storage.tableName: storage,
    };
    final targetStorages = {
      for (final storage in collectImplicitManyToManyStorages(to))
        storage.tableName: storage,
    };

    for (final entry in targetStorages.entries) {
      final sourceStorage = sourceStorages.remove(entry.key);
      if (sourceStorage == null) {
        statements.add(
          schemaApplier.createImplicitManyToManyTableStatement(entry.value),
        );
        continue;
      }

      if (sourceStorage.signature != entry.value.signature) {
        markRequiresRebuild();
      }
    }

    if (sourceStorages.isNotEmpty) {
      for (final removedStorage in sourceStorages.values) {
        warnings.add(
          'Dropping implicit many-to-many relation storage ${removedStorage.tableName} requires manual migration.',
        );
      }
      markRequiresRebuild();
    }
  }

  void _planModelDiff({
    required SchemaDocument targetSchema,
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
    required List<String> statements,
    required List<String> warnings,
    required void Function() markRequiresRebuild,
  }) {
    final sourceFields = {
      for (final field in sourceModel.fields) field.name: field,
    };

    if (sourceModel.databaseName != targetModel.databaseName) {
      markRequiresRebuild();
    }

    for (final targetField in targetModel.fields) {
      final sourceField =
          sourceFields.remove(targetField.name) ??
          _removeFieldByDatabaseName(sourceFields, targetField.databaseName);
      if (sourceField == null) {
        _planAddedField(
          targetSchema: targetSchema,
          model: targetModel,
          field: targetField,
          statements: statements,
          warnings: warnings,
        );
        continue;
      }

      if (sourceField.databaseName != targetField.databaseName) {
        markRequiresRebuild();
      }

      if (!_isCompatibleField(sourceField, targetField)) {
        warnings.add(
          'Altering ${targetModel.name}.${targetField.name} requires manual migration.',
        );
      }
    }

    for (final removedField in sourceFields.values) {
      if (_isVirtualRelationField(removedField)) {
        continue;
      }
      warnings.add(
        'Dropping ${sourceModel.name}.${removedField.name} requires manual migration.',
      );
    }

    if (!_samePrimaryAndUniqueConstraints(sourceModel, targetModel)) {
      warnings.add(
        'Altering model-level constraints on ${targetModel.name} requires manual migration.',
      );
    }

    if (!_sameRelationConstraints(sourceModel, targetModel)) {
      markRequiresRebuild();
    }
  }

  void _planAddedField({
    required SchemaDocument targetSchema,
    required ModelDefinition model,
    required FieldDefinition field,
    required List<String> statements,
    required List<String> warnings,
  }) {
    if (_isVirtualRelationField(field)) {
      return;
    }

    if ((!field.isScalar && targetSchema.findEnum(field.type) == null) ||
        field.isList) {
      warnings.add(
        'Adding relation field ${model.name}.${field.name} requires manual migration.',
      );
      return;
    }

    if (field.isId) {
      warnings.add(
        'Adding primary key field ${model.name}.${field.name} requires manual migration.',
      );
      return;
    }

    if (field.isUnique) {
      warnings.add(
        'Adding unique field ${model.name}.${field.name} requires manual migration.',
      );
      return;
    }

    if (!field.isNullable && field.attribute('default') == null) {
      warnings.add(
        'Adding required field ${model.name}.${field.name} without default requires manual migration.',
      );
      return;
    }

    statements.add(
      schemaApplier.addColumnStatementForModel(
        model,
        field,
        schema: targetSchema,
      ),
    );
  }

  bool _isCompatibleField(FieldDefinition source, FieldDefinition target) {
    if (source.type != target.type) {
      return false;
    }
    if (source.isList != target.isList) {
      return false;
    }
    if (source.isNullable != target.isNullable) {
      return false;
    }
    if (source.isId != target.isId) {
      return false;
    }
    if (source.isUnique != target.isUnique) {
      return false;
    }
    if (_effectiveSqliteType(source) != _effectiveSqliteType(target)) {
      return false;
    }

    final sourceDefault = source.attribute('default')?.arguments['value'];
    final targetDefault = target.attribute('default')?.arguments['value'];
    return sourceDefault == targetDefault;
  }

  String _effectiveSqliteType(FieldDefinition field) {
    return schemaApplier.sqliteTypeForField(field);
  }

  bool _isVirtualRelationField(FieldDefinition field) {
    if (field.isScalar) {
      return false;
    }

    if (field.isList) {
      return true;
    }

    final relation = field.attribute('relation');
    final localFields = _parseFieldList(relation?.arguments['fields']);
    return localFields.isEmpty;
  }

  bool _samePrimaryAndUniqueConstraints(
    ModelDefinition source,
    ModelDefinition target,
  ) {
    if (!_sameFieldSets(source.primaryKeyFields, target.primaryKeyFields)) {
      return false;
    }

    final sourceUnique =
        source.compoundUniqueFieldSets
            .where((fields) => fields.length > 1)
            .map((fields) => fields.join('|'))
            .toList(growable: false)
          ..sort();
    final targetUnique =
        target.compoundUniqueFieldSets
            .where((fields) => fields.length > 1)
            .map((fields) => fields.join('|'))
            .toList(growable: false)
          ..sort();

    if (sourceUnique.length != targetUnique.length) {
      return false;
    }

    for (var index = 0; index < sourceUnique.length; index++) {
      if (sourceUnique[index] != targetUnique[index]) {
        return false;
      }
    }

    return true;
  }

  bool _sameRelationConstraints(
    ModelDefinition source,
    ModelDefinition target,
  ) {
    final sourceRelations = _normalizedRelationConstraints(source);
    final targetRelations = _normalizedRelationConstraints(target);
    if (sourceRelations.length != targetRelations.length) {
      return false;
    }

    for (var index = 0; index < sourceRelations.length; index++) {
      if (sourceRelations[index] != targetRelations[index]) {
        return false;
      }
    }

    return true;
  }

  List<String> _normalizedRelationConstraints(ModelDefinition model) {
    final constraints =
        model.fields
            .where((field) => !field.isScalar)
            .map((field) {
              final relation = field.attribute('relation');
              if (relation == null) {
                return null;
              }

              final localFields = _parseFieldList(relation.arguments['fields']);
              final references = _parseFieldList(
                relation.arguments['references'],
              );
              if (localFields.isEmpty && references.isEmpty) {
                return null;
              }

              return '${field.name}|${field.type}|fields=${localFields.join(',')}|refs=${references.join(',')}|onDelete=${_normalizedRelationArgument(relation.arguments['onDelete']) ?? ''}|onUpdate=${_normalizedRelationArgument(relation.arguments['onUpdate']) ?? ''}';
            })
            .whereType<String>()
            .toList(growable: false)
          ..sort();

    return constraints;
  }

  List<String> _parseFieldList(String? rawValue) {
    if (rawValue == null) {
      return const <String>[];
    }

    final trimmed = rawValue.trim();
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

  String? _normalizedRelationArgument(String? rawValue) {
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

  bool _sameFieldSets(List<String> left, List<String> right) {
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

  ModelDefinition? _removeModelByDatabaseName(
    Map<String, ModelDefinition> sourceModels,
    String databaseName,
  ) {
    String? sourceName;
    for (final entry in sourceModels.entries) {
      if (entry.value.databaseName == databaseName) {
        sourceName = entry.key;
        break;
      }
    }
    if (sourceName == null) {
      return null;
    }
    return sourceModels.remove(sourceName);
  }

  FieldDefinition? _removeFieldByDatabaseName(
    Map<String, FieldDefinition> sourceFields,
    String databaseName,
  ) {
    String? sourceName;
    for (final entry in sourceFields.entries) {
      if (entry.value.databaseName == databaseName) {
        sourceName = entry.key;
        break;
      }
    }
    if (sourceName == null) {
      return null;
    }
    return sourceFields.remove(sourceName);
  }
}
