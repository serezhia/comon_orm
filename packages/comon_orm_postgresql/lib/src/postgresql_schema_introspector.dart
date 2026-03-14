import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

/// Introspects live PostgreSQL schemas into `SchemaDocument` values.
class PostgresqlSchemaIntrospector {
  /// Creates a PostgreSQL schema introspector.
  const PostgresqlSchemaIntrospector();

  /// Reads schema metadata from [executor].
  Future<SchemaDocument> introspect(
    pg.SessionExecutor executor, {
    String schemaName = 'public',
  }) async {
    final enums = await _introspectEnums(executor, schemaName);
    final enumTypeNames = {
      for (final definition in enums) definition.databaseName: definition.name,
    };
    final tableRows = await _query(
      executor,
      '''
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = \$1
          AND table_type = 'BASE TABLE'
        ORDER BY table_name ASC
      ''',
      <Object?>[schemaName],
    );

    final explicitTableNames = <String>[];
    final implicitRelationTables = <String>[];
    for (final tableRow in tableRows) {
      final tableName = tableRow['table_name'] as String;
      if (isImplicitManyToManyTableName(tableName)) {
        implicitRelationTables.add(tableName);
        continue;
      }
      explicitTableNames.add(tableName);
    }

    final models = <ModelDefinition>[];
    for (final tableName in explicitTableNames) {
      models.add(
        await _introspectModel(
          executor,
          schemaName,
          tableName,
          enumTypeNames: enumTypeNames,
        ),
      );
    }

    final modelsWithImplicitRelations = _attachImplicitManyToManyRelations(
      models,
      implicitRelationTables,
    );

    return SchemaDocument(
      models: List<ModelDefinition>.unmodifiable(modelsWithImplicitRelations),
      enums: List<EnumDefinition>.unmodifiable(enums),
    );
  }

  List<ModelDefinition> _attachImplicitManyToManyRelations(
    List<ModelDefinition> models,
    List<String> implicitRelationTables,
  ) {
    final modelFields = {
      for (final model in models)
        model.name: List<FieldDefinition>.of(model.fields),
    };
    final modelAttributes = {
      for (final model in models)
        model.name: List<ModelAttribute>.of(model.attributes),
    };

    for (final tableName in implicitRelationTables) {
      final parsed = parseImplicitManyToManyTableName(tableName);
      if (parsed == null) {
        continue;
      }

      _appendImplicitRelationField(
        modelFields: modelFields,
        modelName: parsed.firstModelName,
        fieldName: parsed.firstFieldName,
        targetModelName: parsed.secondModelName,
        relationName: tableName,
      );
      _appendImplicitRelationField(
        modelFields: modelFields,
        modelName: parsed.secondModelName,
        fieldName: parsed.secondFieldName,
        targetModelName: parsed.firstModelName,
        relationName: tableName,
      );
    }

    return models
        .map(
          (model) => ModelDefinition(
            name: model.name,
            fields: List<FieldDefinition>.unmodifiable(
              modelFields[model.name] ?? model.fields,
            ),
            attributes: List<ModelAttribute>.unmodifiable(
              modelAttributes[model.name] ?? model.attributes,
            ),
          ),
        )
        .toList(growable: false);
  }

  void _appendImplicitRelationField({
    required Map<String, List<FieldDefinition>> modelFields,
    required String modelName,
    required String fieldName,
    required String targetModelName,
    required String relationName,
  }) {
    final fields = modelFields[modelName];
    if (fields == null || fields.any((field) => field.name == fieldName)) {
      return;
    }

    fields.add(
      FieldDefinition(
        name: fieldName,
        type: targetModelName,
        isList: true,
        isNullable: false,
        attributes: List<FieldAttribute>.unmodifiable(<FieldAttribute>[
          FieldAttribute(
            name: 'relation',
            arguments: Map<String, String>.unmodifiable(<String, String>{
              'name': '"$relationName"',
            }),
          ),
        ]),
      ),
    );
  }

  Future<List<EnumDefinition>> _introspectEnums(
    pg.SessionExecutor executor,
    String schemaName,
  ) async {
    final rows = await _query(
      executor,
      '''
        SELECT
          t.typname AS enum_name,
          e.enumlabel AS enum_value,
          e.enumsortorder AS enum_sort_order
        FROM pg_type t
        JOIN pg_enum e
          ON t.oid = e.enumtypid
        JOIN pg_namespace n
          ON n.oid = t.typnamespace
        WHERE n.nspname = \$1
        ORDER BY t.typname ASC, e.enumsortorder ASC
      ''',
      <Object?>[schemaName],
    );

    final grouped = <String, List<String>>{};
    for (final row in rows) {
      final enumName = row['enum_name'] as String;
      final enumValue = row['enum_value'] as String;
      grouped.putIfAbsent(enumName, () => <String>[]).add(enumValue);
    }

    return grouped.entries
        .map((entry) {
          final logicalName = _enumDslName(entry.key);
          final attributes = logicalName == entry.key
              ? const <ModelAttribute>[]
              : <ModelAttribute>[
                  ModelAttribute(
                    name: 'map',
                    arguments: Map<String, String>.unmodifiable(
                      <String, String>{'value': '"${entry.key}"'},
                    ),
                  ),
                ];
          return EnumDefinition(
            name: logicalName,
            values: List<String>.unmodifiable(entry.value),
            attributes: List<ModelAttribute>.unmodifiable(attributes),
          );
        })
        .toList(growable: false);
  }

  Future<ModelDefinition> _introspectModel(
    pg.SessionExecutor executor,
    String schemaName,
    String tableName, {
    required Map<String, String> enumTypeNames,
  }) async {
    final columns = await _query(
      executor,
      '''
        SELECT
          column_name,
          data_type,
          udt_name,
          character_maximum_length,
          is_nullable,
          column_default,
          is_identity
        FROM information_schema.columns
        WHERE table_schema = \$1
          AND table_name = \$2
        ORDER BY ordinal_position ASC
      ''',
      <Object?>[schemaName, tableName],
    );
    final constraints = await _query(
      executor,
      '''
        SELECT
          tc.constraint_type,
          tc.constraint_name,
          kcu.column_name,
          kcu.ordinal_position
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
         AND tc.table_schema = kcu.table_schema
         AND tc.table_name = kcu.table_name
        WHERE tc.table_schema = \$1
          AND tc.table_name = \$2
          AND tc.constraint_type IN ('PRIMARY KEY', 'UNIQUE')
      ''',
      <Object?>[schemaName, tableName],
    );
    final foreignKeys = await _query(
      executor,
      '''
        SELECT
          tc.constraint_name,
          kcu.column_name AS local_column,
          kcu.ordinal_position,
          ccu.table_name AS target_table,
          ccu.column_name AS target_column,
          rc.update_rule,
          rc.delete_rule
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
         AND tc.table_schema = kcu.table_schema
         AND tc.table_name = kcu.table_name
        JOIN information_schema.constraint_column_usage ccu
          ON tc.constraint_name = ccu.constraint_name
         AND tc.table_schema = ccu.table_schema
        JOIN information_schema.referential_constraints rc
          ON tc.constraint_name = rc.constraint_name
         AND tc.table_schema = rc.constraint_schema
        WHERE tc.table_schema = \$1
          AND tc.table_name = \$2
          AND tc.constraint_type = 'FOREIGN KEY'
        ORDER BY tc.constraint_name ASC, kcu.ordinal_position ASC
      ''',
      <Object?>[schemaName, tableName],
    );

    final primaryKeyColumns = <String>{};
    final uniqueColumns = <String>{};
    final modelAttributes = <ModelAttribute>[];
    final groupedConstraints = <String, List<Map<String, Object?>>>{};
    for (final constraint in constraints) {
      final name = constraint['constraint_name'] as String;
      groupedConstraints
          .putIfAbsent(name, () => <Map<String, Object?>>[])
          .add(constraint);
    }

    for (final entries in groupedConstraints.values) {
      entries.sort(
        (left, right) => _asInt(
          left['ordinal_position'],
        ).compareTo(_asInt(right['ordinal_position'])),
      );
      final fields = entries
          .map((entry) => entry['column_name'] as String)
          .toList(growable: false);
      final type = entries.first['constraint_type'] as String;

      if (fields.length == 1) {
        switch (type) {
          case 'PRIMARY KEY':
            primaryKeyColumns.add(fields.single);
          case 'UNIQUE':
            uniqueColumns.add(fields.single);
        }
        continue;
      }

      switch (type) {
        case 'PRIMARY KEY':
          modelAttributes.add(
            ModelAttribute(
              name: 'id',
              arguments: Map<String, String>.unmodifiable(<String, String>{
                'value': '[${fields.join(', ')}]',
              }),
            ),
          );
        case 'UNIQUE':
          modelAttributes.add(
            ModelAttribute(
              name: 'unique',
              arguments: Map<String, String>.unmodifiable(<String, String>{
                'value': '[${fields.join(', ')}]',
              }),
            ),
          );
      }
    }

    final relationFields = <FieldDefinition>[];
    final groupedForeignKeys = <String, List<Map<String, Object?>>>{};
    for (final foreignKey in foreignKeys) {
      final constraintName = foreignKey['constraint_name'] as String;
      groupedForeignKeys
          .putIfAbsent(constraintName, () => <Map<String, Object?>>[])
          .add(foreignKey);
    }

    for (final entries in groupedForeignKeys.values) {
      entries.sort(
        (left, right) => _asInt(
          left['ordinal_position'],
        ).compareTo(_asInt(right['ordinal_position'])),
      );

      final localFields = entries
          .map((entry) => entry['local_column'] as String)
          .toList(growable: false);
      final targetFields = entries
          .map((entry) => entry['target_column'] as String)
          .toList(growable: false);
      final targetModel = entries.first['target_table'] as String;
      final relationArguments = <String, String>{
        'fields': '[${localFields.join(', ')}]',
        'references': '[${targetFields.join(', ')}]',
      };

      final onDelete = _referentialActionArgument(
        entries.first['delete_rule'] as String?,
      );
      if (onDelete != null) {
        relationArguments['onDelete'] = onDelete;
      }

      final onUpdate = _referentialActionArgument(
        entries.first['update_rule'] as String?,
      );
      if (onUpdate != null) {
        relationArguments['onUpdate'] = onUpdate;
      }

      relationFields.add(
        FieldDefinition(
          name: _lowercaseFirst(targetModel),
          type: targetModel,
          isList: false,
          isNullable: true,
          attributes: List<FieldAttribute>.unmodifiable(<FieldAttribute>[
            FieldAttribute(
              name: 'relation',
              arguments: Map<String, String>.unmodifiable(relationArguments),
            ),
          ]),
        ),
      );
    }

    final scalarFields = columns
        .map((column) {
          return _introspectScalarField(
            column: column,
            enumTypeNames: enumTypeNames,
            primaryKeyColumns: primaryKeyColumns,
            uniqueColumns: uniqueColumns,
          );
        })
        .toList(growable: false);

    return ModelDefinition(
      name: tableName,
      fields: List<FieldDefinition>.unmodifiable(<FieldDefinition>[
        ...scalarFields,
        ...relationFields,
      ]),
      attributes: List<ModelAttribute>.unmodifiable(modelAttributes),
    );
  }

  FieldDefinition _introspectScalarField({
    required Map<String, Object?> column,
    required Map<String, String> enumTypeNames,
    required Set<String> primaryKeyColumns,
    required Set<String> uniqueColumns,
  }) {
    final name = column['column_name'] as String;
    final type = _dslScalarType(
      dataType: column['data_type'] as String? ?? 'text',
      udtName: column['udt_name'] as String? ?? 'text',
      enumTypeNames: enumTypeNames,
    );
    final isPrimaryKey = primaryKeyColumns.contains(name);
    final isNullable =
        (column['is_nullable'] as String? ?? 'YES') == 'YES' && !isPrimaryKey;
    final attributes = <FieldAttribute>[];

    if (isPrimaryKey) {
      attributes.add(
        const FieldAttribute(name: 'id', arguments: <String, String>{}),
      );
    }
    if (uniqueColumns.contains(name) && !isPrimaryKey) {
      attributes.add(
        const FieldAttribute(name: 'unique', arguments: <String, String>{}),
      );
    }

    final defaultAttribute = _defaultAttributeFor(
      type: type,
      rawDefault: column['column_default'] as String?,
      isPrimaryKey: isPrimaryKey,
      isIdentity: (column['is_identity'] as String? ?? 'NO') == 'YES',
    );
    if (defaultAttribute != null) {
      attributes.add(defaultAttribute);
    }

    final nativeTypeAttribute = _nativeTypeAttributeFor(
      dataType: column['data_type'] as String? ?? 'text',
      udtName: column['udt_name'] as String? ?? 'text',
      characterMaximumLength: column['character_maximum_length'],
      enumDatabaseNames: enumTypeNames.keys.toSet(),
    );
    if (nativeTypeAttribute != null) {
      attributes.add(nativeTypeAttribute);
    }

    return FieldDefinition(
      name: name,
      type: type,
      isList: false,
      isNullable: isNullable,
      attributes: List<FieldAttribute>.unmodifiable(attributes),
    );
  }

  FieldAttribute? _defaultAttributeFor({
    required String type,
    required String? rawDefault,
    required bool isPrimaryKey,
    required bool isIdentity,
  }) {
    if (isIdentity ||
        (isPrimaryKey &&
            rawDefault != null &&
            rawDefault.startsWith('nextval('))) {
      return const FieldAttribute(
        name: 'default',
        arguments: <String, String>{'value': 'autoincrement()'},
      );
    }
    if (rawDefault == null) {
      return null;
    }

    var normalized = rawDefault.trim();
    if (normalized == 'CURRENT_TIMESTAMP' || normalized.startsWith('now(')) {
      normalized = 'now()';
    } else if (type == 'Boolean') {
      normalized = normalized == 'true'
          ? 'true'
          : normalized == 'false'
          ? 'false'
          : normalized;
    } else {
      normalized = _stripTypeCast(normalized);
      normalized = _stripWrappingQuotes(normalized);
    }

    return FieldAttribute(
      name: 'default',
      arguments: Map<String, String>.unmodifiable(<String, String>{
        'value': normalized,
      }),
    );
  }

  FieldAttribute? _nativeTypeAttributeFor({
    required String dataType,
    required String udtName,
    required Object? characterMaximumLength,
    required Set<String> enumDatabaseNames,
  }) {
    if (dataType.toLowerCase() == 'user-defined' &&
        enumDatabaseNames.contains(udtName)) {
      return null;
    }

    return switch (dataType.toLowerCase()) {
      'character varying' => FieldAttribute(
        name: 'db.VarChar',
        arguments: Map<String, String>.unmodifiable(<String, String>{
          'value': '${_asInt(characterMaximumLength)}',
        }),
      ),
      'text' => const FieldAttribute(
        name: 'db.Text',
        arguments: <String, String>{},
      ),
      'json' => const FieldAttribute(
        name: 'db.Json',
        arguments: <String, String>{},
      ),
      'jsonb' => const FieldAttribute(
        name: 'db.JsonB',
        arguments: <String, String>{},
      ),
      'numeric' => const FieldAttribute(
        name: 'db.Numeric',
        arguments: <String, String>{},
      ),
      'timestamp without time zone' => const FieldAttribute(
        name: 'db.Timestamp',
        arguments: <String, String>{},
      ),
      'timestamp with time zone' => const FieldAttribute(
        name: 'db.Timestamptz',
        arguments: <String, String>{},
      ),
      _ => switch (udtName.toLowerCase()) {
        'bytea' => const FieldAttribute(
          name: 'db.ByteA',
          arguments: <String, String>{},
        ),
        'uuid' => const FieldAttribute(
          name: 'db.Uuid',
          arguments: <String, String>{},
        ),
        _ => null,
      },
    };
  }

  String _dslScalarType({
    required String dataType,
    required String udtName,
    required Map<String, String> enumTypeNames,
  }) {
    if (dataType.toLowerCase() == 'user-defined' &&
        enumTypeNames.containsKey(udtName)) {
      return enumTypeNames[udtName]!;
    }

    return switch (dataType.toLowerCase()) {
      'smallint' || 'integer' => 'Int',
      'bigint' => 'BigInt',
      'boolean' => 'Boolean',
      'double precision' || 'real' => 'Float',
      'numeric' => 'Decimal',
      'timestamp with time zone' || 'timestamp without time zone' => 'DateTime',
      'bytea' => 'Bytes',
      'json' || 'jsonb' => 'Json',
      _ => switch (udtName.toLowerCase()) {
        'json' || 'jsonb' => 'Json',
        'bytea' => 'Bytes',
        _ => 'String',
      },
    };
  }

  String _stripTypeCast(String value) {
    final castIndex = value.indexOf('::');
    if (castIndex >= 0) {
      return value.substring(0, castIndex);
    }
    return value;
  }

  String _stripWrappingQuotes(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2) {
      final first = trimmed[0];
      final last = trimmed[trimmed.length - 1];
      if ((first == '\'' && last == '\'') || (first == '"' && last == '"')) {
        return trimmed.substring(1, trimmed.length - 1);
      }
    }
    return trimmed;
  }

  String? _referentialActionArgument(String? value) {
    if (value == null) {
      return null;
    }

    return switch (value.toUpperCase()) {
      'CASCADE' => 'Cascade',
      'RESTRICT' => 'Restrict',
      'NO ACTION' => 'NoAction',
      'SET NULL' => 'SetNull',
      'SET DEFAULT' => 'SetDefault',
      _ => null,
    };
  }

  int _asInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is BigInt) {
      return value.toInt();
    }
    return int.parse('$value');
  }

  String _enumDslName(String databaseName) {
    if (RegExp(r'^[A-Z][A-Za-z0-9]*$').hasMatch(databaseName)) {
      return databaseName;
    }

    final segments = databaseName
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (segments.isEmpty) {
      return databaseName;
    }

    return segments
        .map(
          (segment) =>
              segment[0].toUpperCase() + segment.substring(1).toLowerCase(),
        )
        .join();
  }

  String _lowercaseFirst(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toLowerCase() + value.substring(1);
  }

  Future<List<Map<String, Object?>>> _query(
    pg.SessionExecutor executor,
    String sql,
    List<Object?> parameters,
  ) {
    return executor.run((session) async {
      final result = await session.execute(sql, parameters: parameters);
      return result
          .map((row) => Map<String, Object?>.from(row.toColumnMap()))
          .toList(growable: false);
    });
  }
}
