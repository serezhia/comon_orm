import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

/// Builds PostgreSQL DDL statements from schema definitions.
class PostgresqlSchemaApplier {
  /// Creates a PostgreSQL schema applier.
  const PostgresqlSchemaApplier();

  /// Returns DDL for every enum in [schema].
  List<String> createEnumStatements(SchemaDocument schema) {
    return schema.enums
        .map((definition) => createEnumStatement(definition))
        .toList(growable: false);
  }

  /// Returns DDL needed to create the whole schema.
  List<String> createSchemaStatements(SchemaDocument schema) {
    final effectiveSchema = schema.withoutIgnored();
    return <String>[
      ...createEnumStatements(effectiveSchema),
      ...createTableStatements(effectiveSchema),
      ...createImplicitManyToManyTableStatements(effectiveSchema),
    ];
  }

  /// Returns table creation statements for every model in [schema].
  List<String> createTableStatements(SchemaDocument schema) {
    final effectiveSchema = schema.withoutIgnored();
    return effectiveSchema.models
        .map(
          (model) =>
              createTableStatementForModel(model, schema: effectiveSchema),
        )
        .toList(growable: false);
  }

  /// Returns creation statements for implicit many-to-many tables.
  List<String> createImplicitManyToManyTableStatements(SchemaDocument schema) {
    final effectiveSchema = schema.withoutIgnored();
    return collectImplicitManyToManyStorages(
      effectiveSchema,
    ).map(createImplicitManyToManyTableStatement).toList(growable: false);
  }

  /// Returns a PostgreSQL enum creation statement.
  String createEnumStatement(EnumDefinition definition) {
    final values = definition.values
        .map((value) => _quoteString(value))
        .join(', ');
    return 'DO \$\$ BEGIN '
        'CREATE TYPE ${_quoteIdentifier(definition.databaseName)} AS ENUM ($values); '
        'EXCEPTION WHEN duplicate_object THEN NULL; '
        'END \$\$;';
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
        '${_quoteIdentifier(storage.sourceJoinColumns[index])} ${postgresTypeForField(sourceKeyFields[index]!)}',
      );
    }
    final targetColumns = <String>[];
    for (var index = 0; index < targetKeyFields.length; index++) {
      targetColumns.add(
        '${_quoteIdentifier(storage.targetJoinColumns[index])} ${postgresTypeForField(targetKeyFields[index]!)}',
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
        'CONSTRAINT ${_quoteIdentifier('${storage.tableName}_source_fkey')} '
        'FOREIGN KEY ($sourceJoinColumns) '
        'REFERENCES ${_quoteIdentifier(storage.sourceModel.databaseName)} ($sourceTargetColumns) '
        'ON DELETE CASCADE ON UPDATE CASCADE, '
        'CONSTRAINT ${_quoteIdentifier('${storage.tableName}_target_fkey')} '
        'FOREIGN KEY ($targetJoinColumns) '
        'REFERENCES ${_quoteIdentifier(storage.targetModel.databaseName)} ($targetTargetColumns) '
        'ON DELETE CASCADE ON UPDATE CASCADE'
        ')';
  }

  /// Returns a table creation statement for [model].
  String createTableStatementForModel(
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
      final foreignKey = foreignKeyConstraintDefinitionForModel(
        model,
        field,
        schema: schema,
      );
      if (foreignKey != null) {
        definitions.add(foreignKey);
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

  /// Returns an add-constraint statement for a relation field, if applicable.
  String? addForeignKeyConstraintStatementForModel(
    ModelDefinition model,
    FieldDefinition field, {
    SchemaDocument? schema,
  }) {
    final definition = foreignKeyConstraintDefinitionForModel(
      model,
      field,
      schema: schema,
    );
    if (definition == null) {
      return null;
    }

    return 'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
        'ADD $definition';
  }

  /// Returns a drop-constraint statement for a relation field, if applicable.
  String? dropForeignKeyConstraintStatementForModel(
    ModelDefinition model,
    FieldDefinition field,
  ) {
    final constraintName = foreignKeyConstraintNameForModel(model, field);
    if (constraintName == null) {
      return null;
    }

    return 'ALTER TABLE ${_quoteIdentifier(model.databaseName)} '
        'DROP CONSTRAINT IF EXISTS ${_quoteIdentifier(constraintName)}';
  }

  /// Returns the foreign key definition fragment for [field], if any.
  String? foreignKeyConstraintDefinitionForModel(
    ModelDefinition model,
    FieldDefinition field, {
    SchemaDocument? schema,
  }) {
    final relation = field.attribute('relation');
    if (relation == null) {
      return null;
    }

    final localFields = _parseListArgument(relation.arguments['fields']);
    final targetFields = _parseListArgument(relation.arguments['references']);
    if (localFields.isEmpty || localFields.length != targetFields.length) {
      return null;
    }

    final constraintName = foreignKeyConstraintNameForModel(model, field);
    if (constraintName == null) {
      return null;
    }

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
    return 'CONSTRAINT ${_quoteIdentifier(constraintName)} '
        'FOREIGN KEY ($localColumns) '
        'REFERENCES ${_quoteIdentifier(targetTable)} ($targetColumns)$onDelete$onUpdate';
  }

  /// Returns the conventional foreign key constraint name for [field].
  String? foreignKeyConstraintNameForModel(
    ModelDefinition model,
    FieldDefinition field,
  ) {
    final relation = field.attribute('relation');
    if (relation == null) {
      return null;
    }

    final localFields = _parseListArgument(relation.arguments['fields']);
    if (localFields.isEmpty) {
      return null;
    }

    final columnSuffix = localFields
        .map(
          (fieldName) => model.findField(fieldName)?.databaseName ?? fieldName,
        )
        .join('_');
    return '${model.databaseName}_${columnSuffix}_fkey';
  }

  /// Returns a PostgreSQL column definition for [field].
  String columnDefinition(FieldDefinition field, {SchemaDocument? schema}) {
    return _columnDefinition(
      field,
      schema: schema,
      includeInlinePrimaryKey: true,
    );
  }

  /// Applies the schema to [executor] using create-if-missing semantics.
  Future<void> apply(pg.SessionExecutor executor, SchemaDocument schema) async {
    await executor.run((session) async {
      for (final statement in createSchemaStatements(schema)) {
        await session.execute(statement, ignoreRows: true);
      }
    });
  }

  String _columnDefinition(
    FieldDefinition field, {
    SchemaDocument? schema,
    required bool includeInlinePrimaryKey,
  }) {
    final parts = <String>[_quoteIdentifier(field.databaseName)];
    final defaultValue = field.attribute('default')?.arguments['value'];
    final isAutoincrementId =
        field.isId && field.type == 'Int' && defaultValue == 'autoincrement()';

    if (isAutoincrementId && includeInlinePrimaryKey) {
      parts.add('INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY');
      return parts.join(' ');
    }

    if (isAutoincrementId) {
      parts.add('INTEGER GENERATED BY DEFAULT AS IDENTITY');
      parts.add('NOT NULL');
      return parts.join(' ');
    }

    parts.add(postgresTypeForField(field, schema: schema));

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

  /// Returns the PostgreSQL column type used for [field].
  String postgresTypeForField(FieldDefinition field, {SchemaDocument? schema}) {
    final enumDefinition = schema == null
        ? null
        : schema.findEnum(field.type) ??
              schema.findEnumByDatabaseName(field.type);
    if (enumDefinition != null) {
      return _quoteIdentifier(enumDefinition.databaseName);
    }

    final nativeType = field.nativeTypeAttribute;
    if (nativeType != null) {
      switch (nativeType.name) {
        case 'db.SmallInt':
          return 'SMALLINT';
        case 'db.BigInt':
          return 'BIGINT';
        case 'db.DoublePrecision':
          return 'DOUBLE PRECISION';
        case 'db.VarChar':
          return 'VARCHAR(${nativeType.arguments['value']!.trim()})';
        case 'db.Char':
          return 'CHAR(${nativeType.arguments['value']!.trim()})';
        case 'db.Text':
          return 'TEXT';
        case 'db.Json':
          return 'JSON';
        case 'db.JsonB':
          return 'JSONB';
        case 'db.ByteA':
          return 'BYTEA';
        case 'db.Numeric':
          return 'NUMERIC';
        case 'db.Uuid':
          return 'UUID';
        case 'db.Xml':
          return 'XML';
        case 'db.Timestamp':
          return 'TIMESTAMP';
        case 'db.Timestamptz':
          return 'TIMESTAMPTZ';
      }
    }

    return switch (field.type) {
      'Int' => 'INTEGER',
      'BigInt' => 'BIGINT',
      'Boolean' => 'BOOLEAN',
      'Float' => 'DOUBLE PRECISION',
      'Decimal' => 'NUMERIC',
      'DateTime' => 'TIMESTAMPTZ',
      'Bytes' => 'BYTEA',
      'Json' => 'JSONB',
      'String' => 'TEXT',
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

    if (_isRawDefaultExpression(rawValue)) {
      return 'DEFAULT $rawValue';
    }

    return switch (type) {
      'Boolean' => 'DEFAULT ${rawValue == 'true' ? 'TRUE' : 'FALSE'}',
      'Int' || 'BigInt' || 'Float' || 'Decimal' => 'DEFAULT $rawValue',
      'Json' => 'DEFAULT ${_quoteJsonLiteral(rawValue)}::jsonb',
      _ => 'DEFAULT ${_quoteString(_unquote(rawValue))}',
    };
  }

  bool _isRawDefaultExpression(String rawValue) {
    return rawValue == 'CURRENT_TIMESTAMP' ||
        rawValue == 'now()' ||
        rawValue.endsWith('()');
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
    return '\'${value.replaceAll("'", "''")}\'';
  }

  String _quoteJsonLiteral(String value) {
    final normalized = _unquote(value);
    return _quoteString(normalized);
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
