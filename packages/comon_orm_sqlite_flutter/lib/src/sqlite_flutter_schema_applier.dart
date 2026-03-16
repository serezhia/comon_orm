import 'package:comon_orm/comon_orm.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Builds and applies SQLite DDL statements for Flutter-oriented runtimes.
class SqliteFlutterSchemaApplier {
  /// Creates a SQLite schema applier.
  const SqliteFlutterSchemaApplier();

  /// Returns table creation statements for every model in [schema].
  List<String> createTableStatements(SchemaDocument schema) {
    return schema.models
        .map((model) => createTableStatementForModel(model, schema: schema))
        .toList(growable: false);
  }

  /// Returns creation statements for implicit many-to-many tables.
  List<String> createImplicitManyToManyTableStatements(SchemaDocument schema) {
    return collectImplicitManyToManyStorages(
      schema,
    ).map(createImplicitManyToManyTableStatement).toList(growable: false);
  }

  /// Returns a table creation statement for [model].
  String createTableStatementForModel(
    ModelDefinition model, {
    SchemaDocument? schema,
  }) {
    return _createTableStatement(model, schema: schema);
  }

  /// Returns an `ALTER TABLE ... ADD COLUMN` statement for [field].
  String addColumnStatement(String modelName, FieldDefinition field) {
    return 'ALTER TABLE ${_quoteIdentifier(modelName)} '
        'ADD COLUMN ${columnDefinition(field)}';
  }

  /// Returns an add-column statement using mapped model and field names.
  String addColumnStatementForModel(
    ModelDefinition model,
    FieldDefinition field, {
    SchemaDocument? schema,
  }) {
    return 'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
        'ADD COLUMN ${columnDefinition(field, schema: schema)}';
  }

  /// Returns a SQLite column definition for [field].
  String columnDefinition(FieldDefinition field, {SchemaDocument? schema}) {
    return _columnDefinition(
      field,
      schema: schema,
      includeInlinePrimaryKey: true,
    );
  }

  /// Applies the schema using create-if-missing semantics.
  Future<void> apply(DatabaseExecutor database, SchemaDocument schema) async {
    await database.execute('PRAGMA foreign_keys = ON');
    for (final statement in createTableStatements(schema)) {
      await database.execute(statement);
    }
    for (final statement in createImplicitManyToManyTableStatements(schema)) {
      await database.execute(statement);
    }
  }

  /// Returns a join-table creation statement for [storage].
  String createImplicitManyToManyTableStatement(
    ImplicitManyToManyStorageDefinition storage,
  ) {
    final sourceKeyFields = storage.sourceKeyFields
        .map((fieldName) => storage.sourceModel.findField(fieldName))
        .toList(growable: false);
    final targetKeyFields = storage.targetKeyFields
        .map((fieldName) => storage.targetModel.findField(fieldName))
        .toList(growable: false);
    if (sourceKeyFields.any((field) => field == null) ||
        targetKeyFields.any((field) => field == null)) {
      throw StateError(
        'Unable to resolve key fields for implicit many-to-many table ${storage.tableName}.',
      );
    }

    final sourceColumns = <String>[];
    for (var index = 0; index < sourceKeyFields.length; index++) {
      sourceColumns.add(
        '${_quoteIdentifier(storage.sourceJoinColumns[index])} ${sqliteTypeForField(sourceKeyFields[index]!)} NOT NULL',
      );
    }
    final targetColumns = <String>[];
    for (var index = 0; index < targetKeyFields.length; index++) {
      targetColumns.add(
        '${_quoteIdentifier(storage.targetJoinColumns[index])} ${sqliteTypeForField(targetKeyFields[index]!)} NOT NULL',
      );
    }
    final primaryKeyColumns = [
      ...storage.sourceJoinColumns,
      ...storage.targetJoinColumns,
    ].map(_quoteIdentifier).join(', ');
    final sourceJoinColumns = storage.sourceJoinColumns
        .map(_quoteIdentifier)
        .join(', ');
    final sourceTargetColumns = sourceKeyFields
        .map((field) => _quoteIdentifier(field!.databaseName))
        .join(', ');
    final targetJoinColumns = storage.targetJoinColumns
        .map(_quoteIdentifier)
        .join(', ');
    final targetTargetColumns = targetKeyFields
        .map((field) => _quoteIdentifier(field!.databaseName))
        .join(', ');

    return 'CREATE TABLE IF NOT EXISTS ${_quoteIdentifier(storage.tableName)} ('
        '${[...sourceColumns, ...targetColumns].join(', ')}, '
        'PRIMARY KEY ($primaryKeyColumns), '
        'FOREIGN KEY ($sourceJoinColumns) '
        'REFERENCES ${_quoteIdentifier(storage.sourceModel.databaseName)} ($sourceTargetColumns) '
        'ON DELETE CASCADE ON UPDATE CASCADE, '
        'FOREIGN KEY ($targetJoinColumns) '
        'REFERENCES ${_quoteIdentifier(storage.targetModel.databaseName)} ($targetTargetColumns) '
        'ON DELETE CASCADE ON UPDATE CASCADE'
        ')';
  }

  String _createTableStatement(
    ModelDefinition model, {
    SchemaDocument? schema,
  }) {
    final definitions = <String>[];
    final hasModelLevelPrimaryKey = model.primaryKeyFields.isNotEmpty;

    for (final field in model.fields.where(
      (field) => _isScalarLikeField(schema, field) && !field.isList,
    )) {
      definitions.add(
        _columnDefinition(
          field,
          schema: schema,
          includeInlinePrimaryKey: !hasModelLevelPrimaryKey,
        ),
      );
    }

    for (final field in model.fields.where(
      (field) => !_isScalarLikeField(schema, field),
    )) {
      final relation = field.attribute('relation');
      if (relation == null) {
        continue;
      }

      final localFields = _parseListArgument(relation.arguments['fields']);
      final targetFields = _parseListArgument(relation.arguments['references']);
      if (localFields.isNotEmpty && localFields.length == targetFields.length) {
        final targetModel = schema?.findModel(field.type);
        final localColumns = localFields
            .map(
              (fieldName) => _quoteIdentifier(
                model.findField(fieldName)?.databaseName ?? fieldName,
              ),
            )
            .join(', ');
        final targetColumns = targetFields
            .map(
              (fieldName) => _quoteIdentifier(
                targetModel?.findField(fieldName)?.databaseName ?? fieldName,
              ),
            )
            .join(', ');
        final targetTable = targetModel?.databaseName ?? field.type;
        final onDelete = _referentialActionClause(
          'ON DELETE',
          relation.arguments['onDelete'],
        );
        final onUpdate = _referentialActionClause(
          'ON UPDATE',
          relation.arguments['onUpdate'],
        );
        definitions.add(
          'FOREIGN KEY ($localColumns) '
          'REFERENCES ${_quoteIdentifier(targetTable)} ($targetColumns)$onDelete$onUpdate',
        );
      }
    }

    if (hasModelLevelPrimaryKey) {
      definitions.add(
        'PRIMARY KEY (${_quotedConstraintColumns(model, model.primaryKeyFields).join(', ')})',
      );
    }

    for (final uniqueFields in model.compoundUniqueFieldSets) {
      if (uniqueFields.length <= 1) {
        continue;
      }
      definitions.add(
        'UNIQUE (${_quotedConstraintColumns(model, uniqueFields).join(', ')})',
      );
    }

    return 'CREATE TABLE IF NOT EXISTS ${_quoteIdentifier(model.databaseName)} ('
        '${definitions.join(', ')}'
        ')';
  }

  String _columnDefinition(
    FieldDefinition field, {
    SchemaDocument? schema,
    required bool includeInlinePrimaryKey,
  }) {
    final parts = <String>[_quoteIdentifier(field.databaseName)];
    final defaultAttribute = field.attribute('default');
    final defaultValue = defaultAttribute?.arguments['value'];
    final isAutoincrementId =
        field.isId && field.type == 'Int' && defaultValue == 'autoincrement()';

    if (isAutoincrementId && includeInlinePrimaryKey) {
      parts.add('INTEGER PRIMARY KEY AUTOINCREMENT');
      return parts.join(' ');
    }

    if (isAutoincrementId) {
      parts.add('INTEGER NOT NULL');
      return parts.join(' ');
    }

    parts.add(sqliteTypeForField(field, schema: schema));

    if (field.isId && includeInlinePrimaryKey) {
      parts.add('PRIMARY KEY');
    }
    if (!field.isNullable) {
      parts.add('NOT NULL');
    }
    if (field.isUnique) {
      parts.add('UNIQUE');
    }

    final defaultClause = _defaultClause(field.type, defaultValue);
    if (defaultClause != null) {
      parts.add(defaultClause);
    }

    return parts.join(' ');
  }

  List<String> _quotedConstraintColumns(
    ModelDefinition model,
    List<String> fields,
  ) {
    return fields
        .map(
          (fieldName) => _quoteIdentifier(
            model.findField(fieldName)?.databaseName ?? fieldName,
          ),
        )
        .toList(growable: false);
  }

  /// Returns the SQLite column type used for [field].
  String sqliteTypeForField(FieldDefinition field, {SchemaDocument? schema}) {
    if (schema?.findEnum(field.type) != null) {
      return 'TEXT';
    }

    final nativeType = field.nativeTypeAttribute;
    if (nativeType != null) {
      switch (nativeType.name) {
        case 'db.Integer':
          return 'INTEGER';
        case 'db.Numeric':
          return 'NUMERIC';
        case 'db.Real':
          return 'REAL';
        case 'db.Text':
          return 'TEXT';
        case 'db.Blob':
          return 'BLOB';
      }
    }

    return switch (field.type) {
      'Int' => 'INTEGER',
      'Boolean' => 'BOOLEAN',
      'Float' || 'Decimal' => 'REAL',
      'Bytes' => 'BLOB',
      'String' || 'DateTime' || 'Json' || 'BigInt' => 'TEXT',
      _ => 'TEXT',
    };
  }

  bool _isScalarLikeField(SchemaDocument? schema, FieldDefinition field) {
    return field.isScalar || schema?.findEnum(field.type) != null;
  }

  String? _defaultClause(String type, String? rawValue) {
    if (rawValue == null || rawValue == 'autoincrement()') {
      return null;
    }

    return switch (type) {
      'Boolean' => 'DEFAULT ${rawValue == 'true' ? '1' : '0'}',
      'Int' || 'Float' || 'Decimal' => 'DEFAULT $rawValue',
      _ => 'DEFAULT ${_quoteString(_unquote(rawValue))}',
    };
  }

  List<String> _parseListArgument(String? raw) {
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

  String _quoteIdentifier(String value) {
    return '"${value.replaceAll('"', '""')}"';
  }

  String _quoteString(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  String _referentialActionClause(String keyword, String? rawValue) {
    final action = _normalizeReferentialAction(rawValue);
    if (action == null) {
      return '';
    }
    return ' $keyword $action';
  }

  String? _normalizeReferentialAction(String? rawValue) {
    if (rawValue == null) {
      return null;
    }
    final trimmed = _unquote(rawValue.trim());
    return switch (trimmed) {
      'Cascade' => 'CASCADE',
      'Restrict' => 'RESTRICT',
      'NoAction' => 'NO ACTION',
      'SetNull' => 'SET NULL',
      'SetDefault' => 'SET DEFAULT',
      _ => null,
    };
  }

  String _unquote(String value) {
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      return value.substring(1, value.length - 1);
    }
    return value;
  }
}
