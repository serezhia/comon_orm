import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_schema_applier.dart';
import 'postgresql_schema_introspector.dart';

/// PostgreSQL schema diff result.
class PostgresqlMigrationPlan implements PlannedMigration {
  /// Creates a migration plan.
  const PostgresqlMigrationPlan({
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

/// Computes PostgreSQL migration plans from schema diffs or live databases.
class PostgresqlMigrationPlanner {
  /// Creates a PostgreSQL migration planner.
  const PostgresqlMigrationPlanner({
    this.schemaApplier = const PostgresqlSchemaApplier(),
    this.schemaIntrospector = const PostgresqlSchemaIntrospector(),
  });

  /// Helper used to render PostgreSQL DDL statements.
  final PostgresqlSchemaApplier schemaApplier;

  /// Helper used to introspect live PostgreSQL schemas.
  final PostgresqlSchemaIntrospector schemaIntrospector;

  /// Builds a plan by introspecting the live database first.
  Future<PostgresqlMigrationPlan> planFromDatabase({
    required pg.SessionExecutor executor,
    required SchemaDocument to,
  }) async {
    return plan(from: await schemaIntrospector.introspect(executor), to: to);
  }

  /// Builds a plan from two schema snapshots.
  PostgresqlMigrationPlan plan({
    required SchemaDocument from,
    required SchemaDocument to,
  }) {
    from = from.withoutIgnored();
    to = to.withoutIgnored();
    final statements = <String>[];
    final warnings = <String>[];
    var requiresRebuild = false;
    final matchedSourceEnumNames = <String>{};
    final matchedEnumPairs = <String>{};

    final fromEnumsByName = {
      for (final definition in from.enums) definition.name: definition,
    };
    final fromEnumsByDatabaseName = {
      for (final definition in from.enums) definition.databaseName: definition,
    };
    for (final targetEnum in to.enums) {
      final sourceEnum =
          fromEnumsByName.remove(targetEnum.name) ??
          fromEnumsByDatabaseName.remove(targetEnum.databaseName) ??
          _inferRenamedSourceEnum(
            sourceSchema: from,
            targetSchema: to,
            targetEnum: targetEnum,
            matchedSourceEnumNames: matchedSourceEnumNames,
          );
      if (sourceEnum == null) {
        statements.add(schemaApplier.createEnumStatement(targetEnum));
        continue;
      }

      matchedSourceEnumNames.add(sourceEnum.name);
      matchedEnumPairs.add(_enumPairKey(sourceEnum, targetEnum));
      fromEnumsByName.remove(sourceEnum.name);
      fromEnumsByDatabaseName.remove(sourceEnum.databaseName);

      // Handle DB-level type rename when @@map changes.
      if (sourceEnum.databaseName != targetEnum.databaseName) {
        final escapedOld = sourceEnum.databaseName.replaceAll('"', '""');
        final escapedNew = targetEnum.databaseName.replaceAll('"', '""');
        statements.add('ALTER TYPE "$escapedOld" RENAME TO "$escapedNew"');
      }

      if (_hasCompatibleEnumDefinition(sourceEnum, targetEnum)) {
        continue;
      }

      final renamedValues = _renamedEnumValues(sourceEnum, targetEnum);
      if (renamedValues != null) {
        for (final rename in renamedValues) {
          statements.add(
            _createRenameEnumValueStatement(
              targetEnum.databaseName,
              rename.$1,
              rename.$2,
            ),
          );
        }
        continue;
      }

      final appendedValues = _appendedEnumValues(sourceEnum, targetEnum);
      if (appendedValues != null) {
        for (final statement in appendedValues) {
          statements.add(statement);
        }
        continue;
      }

      final combinedValues = _combinedRenameInsertStatements(
        sourceEnum,
        targetEnum,
      );
      if (combinedValues != null) {
        for (final statement in combinedValues) {
          statements.add(statement);
        }
        continue;
      }

      requiresRebuild = true;
      warnings.add(
        'Altering enum ${targetEnum.databaseName} requires schema rebuild and data compatibility review.',
      );
    }

    for (final removedEnum in fromEnumsByName.values) {
      requiresRebuild = true;
      warnings.add(
        'Dropping enum ${removedEnum.databaseName} requires schema rebuild and data compatibility review.',
      );
    }

    final fromModelsByName = {
      for (final model in from.models) model.name: model,
    };
    final fromModelsByDatabaseName = {
      for (final model in from.models) model.databaseName: model,
    };

    for (final targetModel in to.models) {
      final sourceModel =
          fromModelsByName.remove(targetModel.name) ??
          fromModelsByDatabaseName.remove(targetModel.databaseName);
      if (sourceModel == null) {
        statements.add(
          schemaApplier.createTableStatementForModel(targetModel, schema: to),
        );
        continue;
      }
      fromModelsByName.remove(sourceModel.name);
      fromModelsByDatabaseName.remove(sourceModel.databaseName);

      _planModelDiff(
        sourceSchema: from,
        targetSchema: to,
        sourceModel: sourceModel,
        targetModel: targetModel,
        matchedEnumPairs: matchedEnumPairs,
        statements: statements,
        warnings: warnings,
      );
    }

    for (final removedModel in from.models.where(
      (model) =>
          fromModelsByName.containsKey(model.name) ||
          fromModelsByDatabaseName.containsKey(model.databaseName),
    )) {
      warnings.add(
        'Dropping model ${removedModel.name} requires manual migration.',
      );
    }

    _planImplicitManyToManyDiffs(
      from: from,
      to: to,
      statements: statements,
      warnings: warnings,
    );

    return PostgresqlMigrationPlan(
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
        warnings.add(
          'Altering implicit many-to-many relation storage ${entry.key} requires manual migration.',
        );
      }
    }

    for (final removedStorage in sourceStorages.values) {
      warnings.add(
        'Dropping implicit many-to-many relation storage ${removedStorage.tableName} requires manual migration.',
      );
    }
  }

  void _planModelDiff({
    required SchemaDocument sourceSchema,
    required SchemaDocument targetSchema,
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
    required Set<String> matchedEnumPairs,
    required List<String> statements,
    required List<String> warnings,
  }) {
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
        _planAddedField(
          targetSchema: targetSchema,
          model: targetModel,
          field: targetField,
          statements: statements,
          warnings: warnings,
        );
        continue;
      }
      sourceFieldsByName.remove(sourceField.name);
      sourceFieldsByDatabaseName.remove(sourceField.databaseName);

      if (_isRelationField(targetSchema, targetField)) {
        continue;
      }

      if (!_isCompatibleField(
        sourceField,
        targetField,
        sourceSchema: sourceSchema,
        targetSchema: targetSchema,
        matchedEnumPairs: matchedEnumPairs,
      )) {
        warnings.add(
          'Altering ${targetModel.name}.${targetField.name} requires manual migration.',
        );
      }
    }

    _planRelationConstraintDiffs(
      sourceSchema: sourceSchema,
      targetSchema: targetSchema,
      sourceModel: sourceModel,
      targetModel: targetModel,
      statements: statements,
    );

    for (final removedField in sourceModel.fields.where(
      (field) =>
          sourceFieldsByName.containsKey(field.name) ||
          sourceFieldsByDatabaseName.containsKey(field.databaseName),
    )) {
      if (_isRelationField(sourceSchema, removedField)) {
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
  }

  void _planAddedField({
    required SchemaDocument targetSchema,
    required ModelDefinition model,
    required FieldDefinition field,
    required List<String> statements,
    required List<String> warnings,
  }) {
    if (_isRelationField(targetSchema, field)) {
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

  void _planRelationConstraintDiffs({
    required SchemaDocument sourceSchema,
    required SchemaDocument targetSchema,
    required ModelDefinition sourceModel,
    required ModelDefinition targetModel,
    required List<String> statements,
  }) {
    final sourceRelations = {
      for (final relation in _relationConstraints(sourceModel, sourceSchema))
        relation.key: relation,
    };
    final targetRelations = {
      for (final relation in _relationConstraints(targetModel, targetSchema))
        relation.key: relation,
    };

    final dropStatements = <String>[];
    final addStatements = <String>[];

    for (final entry in targetRelations.entries) {
      final sourceRelation = sourceRelations.remove(entry.key);
      final targetRelation = entry.value;
      if (sourceRelation == null) {
        final statement = schemaApplier
            .addForeignKeyConstraintStatementForModel(
              targetModel,
              targetRelation.field,
              schema: targetSchema,
            );
        if (statement != null) {
          addStatements.add(statement);
        }
        continue;
      }

      if (sourceRelation.signature == targetRelation.signature) {
        continue;
      }

      final dropStatement = schemaApplier
          .dropForeignKeyConstraintStatementForModel(
            sourceModel,
            sourceRelation.field,
          );
      if (dropStatement != null) {
        dropStatements.add(dropStatement);
      }

      final addStatement = schemaApplier
          .addForeignKeyConstraintStatementForModel(
            targetModel,
            targetRelation.field,
            schema: targetSchema,
          );
      if (addStatement != null) {
        addStatements.add(addStatement);
      }
    }

    for (final sourceRelation in sourceRelations.values) {
      final dropStatement = schemaApplier
          .dropForeignKeyConstraintStatementForModel(
            sourceModel,
            sourceRelation.field,
          );
      if (dropStatement != null) {
        dropStatements.add(dropStatement);
      }
    }

    statements
      ..addAll(dropStatements)
      ..addAll(addStatements);
  }

  bool _isRelationField(SchemaDocument schema, FieldDefinition field) {
    return !field.isScalar &&
        schema.findEnum(field.type) == null &&
        schema.findEnumByDatabaseName(field.type) == null;
  }

  bool _isCompatibleField(
    FieldDefinition source,
    FieldDefinition target, {
    required SchemaDocument sourceSchema,
    required SchemaDocument targetSchema,
    required Set<String> matchedEnumPairs,
  }) {
    final sourceEnum =
        sourceSchema.findEnum(source.type) ??
        sourceSchema.findEnumByDatabaseName(source.type);
    final targetEnum =
        targetSchema.findEnum(target.type) ??
        targetSchema.findEnumByDatabaseName(target.type);

    if (source.type != target.type) {
      if (sourceEnum == null || targetEnum == null) {
        return false;
      }
      if (sourceEnum.databaseName != targetEnum.databaseName &&
          !matchedEnumPairs.contains(_enumPairKey(sourceEnum, targetEnum))) {
        return false;
      }
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
    final areEnumFields = sourceEnum != null && targetEnum != null;
    if (!areEnumFields &&
        _effectivePostgresqlType(source, schema: sourceSchema) !=
            _effectivePostgresqlType(target, schema: targetSchema)) {
      return false;
    }

    final sourceDefault = source.attribute('default')?.arguments['value'];
    final targetDefault = target.attribute('default')?.arguments['value'];
    if (sourceDefault == targetDefault) {
      return true;
    }

    if (_isCompatibleIdentityDefault(
      source,
      target,
      sourceDefault,
      targetDefault,
    )) {
      return true;
    }

    return false;
  }

  bool _isCompatibleIdentityDefault(
    FieldDefinition source,
    FieldDefinition target,
    String? sourceDefault,
    String? targetDefault,
  ) {
    if (!source.isId || !target.isId) {
      return false;
    }

    if (targetDefault != 'autoincrement()') {
      return false;
    }

    return sourceDefault == null || sourceDefault == 'autoincrement()';
  }

  String _effectivePostgresqlType(
    FieldDefinition field, {
    required SchemaDocument schema,
  }) {
    return schemaApplier.postgresTypeForField(field, schema: schema);
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
    final statements = <String>[];

    for (
      var targetIndex = 0;
      targetIndex < target.values.length;
      targetIndex++
    ) {
      final value = target.values[targetIndex];

      if (targetIndex < current.length && current[targetIndex] == value) {
        continue;
      }

      if (current.contains(value)) {
        return null;
      }

      if (targetIndex < current.length) {
        statements.add(
          _createAddEnumValueBeforeStatement(
            target.databaseName,
            value,
            current[targetIndex],
          ),
        );
        current.insert(targetIndex, value);
        continue;
      }

      final after = current.isEmpty ? null : current.last;
      statements.add(
        _createAddEnumValueStatement(target.databaseName, value, after: after),
      );
      current.add(value);
    }

    if (current.length != target.values.length) {
      return null;
    }

    return statements;
  }

  /// Handles the case where an enum both renames existing values and adds new
  /// ones in the same migration step. Returns SQL statements, or `null` if the
  /// diff cannot be resolved without a schema rebuild.
  List<String>? _combinedRenameInsertStatements(
    EnumDefinition source,
    EnumDefinition target,
  ) {
    final unchangedSet = source.values.toSet().intersection(
      target.values.toSet(),
    );
    final sourceOnly = source.values
        .where((v) => !unchangedSet.contains(v))
        .toList();
    final targetOnly = target.values
        .where((v) => !unchangedSet.contains(v))
        .toList();

    // Needs at least one rename and at least one truly new insertion.
    if (sourceOnly.isEmpty || targetOnly.length <= sourceOnly.length) {
      return null;
    }

    // Pair renames positionally: sourceOnly[i] → targetOnly[i].
    final renames = <(String, String)>[];
    final sourceSet = source.values.toSet();
    final targetSet = target.values.toSet();
    for (var i = 0; i < sourceOnly.length; i++) {
      final from = sourceOnly[i];
      final to = targetOnly[i];
      if (targetSet.contains(from) || sourceSet.contains(to)) return null;
      renames.add((from, to));
    }

    // Build intermediate state: source values with renames applied.
    final intermediateValues = source.values.map((v) {
      for (final (from, to) in renames) {
        if (v == from) return to;
      }
      return v;
    }).toList();

    // Compute insert statements from intermediate state to target.
    final intermediateEnum = EnumDefinition(
      name: target.name,
      values: intermediateValues,
    );
    final addStatements = _appendedEnumValues(intermediateEnum, target);
    if (addStatements == null) return null;

    return [
      for (final (from, to) in renames)
        _createRenameEnumValueStatement(target.databaseName, from, to),
      ...addStatements,
    ];
  }

  String _createAddEnumValueStatement(
    String enumName,
    String value, {
    String? after,
  }) {
    final escapedEnumName = enumName.replaceAll('"', '""');
    final escapedValue = value.replaceAll("'", "''");
    final afterClause = after == null
        ? ''
        : " AFTER '${after.replaceAll("'", "''")}'";
    return "ALTER TYPE \"$escapedEnumName\" ADD VALUE IF NOT EXISTS '$escapedValue'$afterClause";
  }

  String _createAddEnumValueBeforeStatement(
    String enumName,
    String value,
    String before,
  ) {
    final escapedEnumName = enumName.replaceAll('"', '""');
    final escapedValue = value.replaceAll("'", "''");
    final escapedBefore = before.replaceAll("'", "''");
    return "ALTER TYPE \"$escapedEnumName\" ADD VALUE IF NOT EXISTS '$escapedValue' BEFORE '$escapedBefore'";
  }

  String _createRenameEnumValueStatement(
    String enumName,
    String before,
    String after,
  ) {
    final escapedEnumName = enumName.replaceAll('"', '""');
    final escapedBefore = before.replaceAll("'", "''");
    final escapedAfter = after.replaceAll("'", "''");
    return "ALTER TYPE \"$escapedEnumName\" RENAME VALUE '$escapedBefore' TO '$escapedAfter'";
  }

  bool _samePrimaryAndUniqueConstraints(
    ModelDefinition source,
    ModelDefinition target,
  ) {
    if (!_sameFieldSets(
      _canonicalFieldSet(source, source.primaryKeyFields),
      _canonicalFieldSet(target, target.primaryKeyFields),
    )) {
      return false;
    }

    final sourceUnique =
        source.compoundUniqueFieldSets
            .where((fields) => fields.length > 1)
            .map((fields) => _canonicalFieldSet(source, fields).join('|'))
            .toList(growable: false)
          ..sort();
    final targetUnique =
        target.compoundUniqueFieldSets
            .where((fields) => fields.length > 1)
            .map((fields) => _canonicalFieldSet(target, fields).join('|'))
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

  List<String> _canonicalFieldSet(ModelDefinition model, List<String> fields) {
    return fields
        .map(
          (fieldName) =>
              model.findField(fieldName)?.databaseName ??
              model.findFieldByDatabaseName(fieldName)?.databaseName ??
              fieldName,
        )
        .toList(growable: false);
  }

  List<_RelationConstraint> _relationConstraints(
    ModelDefinition model,
    SchemaDocument schema,
  ) {
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
              if (localFields.isEmpty ||
                  localFields.length != references.length) {
                return null;
              }

              final localDatabaseFields = _canonicalFieldSet(
                model,
                localFields,
              );
              final targetModel =
                  schema.findModel(field.type) ??
                  schema.findModelByDatabaseName(field.type);
              final targetDatabaseName =
                  targetModel?.databaseName ?? field.type;
              final referenceDatabaseFields = references
                  .map(
                    (fieldName) =>
                        targetModel?.findField(fieldName)?.databaseName ??
                        targetModel
                            ?.findFieldByDatabaseName(fieldName)
                            ?.databaseName ??
                        fieldName,
                  )
                  .toList(growable: false);

              return _RelationConstraint(
                key:
                    '$targetDatabaseName|fields=${localDatabaseFields.join(',')}',
                field: field,
                signature:
                    '$targetDatabaseName|fields=${localDatabaseFields.join(',')}|refs=${referenceDatabaseFields.join(',')}|onDelete=${_normalizedRelationArgument(relation.arguments['onDelete']) ?? ''}|onUpdate=${_normalizedRelationArgument(relation.arguments['onUpdate']) ?? ''}',
              );
            })
            .whereType<_RelationConstraint>()
            .toList(growable: false)
          ..sort((left, right) => left.key.compareTo(right.key));

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

    return trimmed == 'NoAction' ? null : trimmed;
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
}

class _RelationConstraint {
  const _RelationConstraint({
    required this.key,
    required this.field,
    required this.signature,
  });

  final String key;
  final FieldDefinition field;
  final String signature;
}
