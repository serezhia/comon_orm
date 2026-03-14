import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// Introspects live SQLite schemas into `SchemaDocument` values.
class SqliteSchemaIntrospector {
  /// Creates a SQLite schema introspector.
  const SqliteSchemaIntrospector();

  /// Reads schema metadata from [database].
  SchemaDocument introspect(sqlite.Database database) {
    final tableRows = database.select('''
      SELECT name, sql
      FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name ASC
    ''');

    final explicitRows = <sqlite.Row>[];
    final implicitRelationTables = <String>[];
    for (final row in tableRows) {
      final tableName = row['name'] as String;
      if (isImplicitManyToManyTableName(tableName)) {
        implicitRelationTables.add(tableName);
        continue;
      }
      explicitRows.add(row);
    }

    final models = explicitRows
        .map(
          (row) => _introspectModel(
            database,
            row['name'] as String,
            row['sql'] as String? ?? '',
          ),
        )
        .toList(growable: false);

    final modelsWithImplicitRelations = _attachImplicitManyToManyRelations(
      models,
      implicitRelationTables,
    );

    return SchemaDocument(
      models: List<ModelDefinition>.unmodifiable(modelsWithImplicitRelations),
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
            attributes: List<ModelAttribute>.unmodifiable(model.attributes),
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

  ModelDefinition _introspectModel(
    sqlite.Database database,
    String tableName,
    String createSql,
  ) {
    final tableInfo = database.select(
      'PRAGMA table_info(${_quoteSqlString(tableName)})',
    );
    final indexList = database.select(
      'PRAGMA index_list(${_quoteSqlString(tableName)})',
    );
    final foreignKeys = database.select(
      'PRAGMA foreign_key_list(${_quoteSqlString(tableName)})',
    );

    final uniqueColumns = <String>{};
    final compoundUniqueConstraints = <ModelAttribute>[];
    final primaryKeyColumns =
        tableInfo
            .where((column) => (column['pk'] as int? ?? 0) > 0)
            .toList(growable: false)
          ..sort(
            (left, right) => (left['pk'] as int).compareTo(right['pk'] as int),
          );
    final hasCompoundPrimaryKey = primaryKeyColumns.length > 1;
    for (final index in indexList) {
      final isUnique = (index['unique'] as int?) == 1;
      if (!isUnique) {
        continue;
      }
      if ((index['origin'] as String?) == 'pk') {
        continue;
      }

      final indexName = index['name'] as String;
      final indexInfo = database.select(
        'PRAGMA index_info(${_quoteSqlString(indexName)})',
      );
      if (indexInfo.length == 1) {
        uniqueColumns.add(indexInfo.single['name'] as String);
        continue;
      }

      final fields = indexInfo.toList(growable: false)
        ..sort(
          (left, right) =>
              (left['seqno'] as int).compareTo(right['seqno'] as int),
        );
      compoundUniqueConstraints.add(
        ModelAttribute(
          name: 'unique',
          arguments: Map<String, String>.unmodifiable(<String, String>{
            'value':
                '[${fields.map((row) => row['name'] as String).join(', ')}]',
          }),
        ),
      );
    }

    final relationFields = <FieldDefinition>[];
    final groupedForeignKeys = <int, List<sqlite.Row>>{};
    for (final foreignKey in foreignKeys) {
      final id = foreignKey['id'] as int? ?? 0;
      groupedForeignKeys.putIfAbsent(id, () => <sqlite.Row>[]).add(foreignKey);
    }

    for (final entries in groupedForeignKeys.values) {
      entries.sort(
        (left, right) => (left['seq'] as int).compareTo(right['seq'] as int),
      );

      final localFields = entries
          .map((entry) => entry['from'] as String)
          .toList(growable: false);
      final targetFields = entries
          .map((entry) => entry['to'] as String)
          .toList(growable: false);
      final targetModel = entries.first['table'] as String;
      final relationArguments = <String, String>{
        'fields': '[${localFields.join(', ')}]',
        'references': '[${targetFields.join(', ')}]',
      };

      final onDelete = _referentialActionArgument(
        entries.first['on_delete'] as String?,
      );
      if (onDelete != null) {
        relationArguments['onDelete'] = onDelete;
      }

      final onUpdate = _referentialActionArgument(
        entries.first['on_update'] as String?,
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

    final scalarFields = tableInfo
        .map(
          (column) => _introspectScalarField(
            column: column,
            uniqueColumns: uniqueColumns,
            createSql: createSql,
            hasCompoundPrimaryKey: hasCompoundPrimaryKey,
          ),
        )
        .toList(growable: false);

    final allFields = <FieldDefinition>[...scalarFields, ...relationFields];

    final modelAttributes = <ModelAttribute>[
      if (primaryKeyColumns.length > 1)
        ModelAttribute(
          name: 'id',
          arguments: Map<String, String>.unmodifiable(<String, String>{
            'value':
                '[${primaryKeyColumns.map((column) => column['name'] as String).join(', ')}]',
          }),
        ),
      ...compoundUniqueConstraints,
    ];

    return ModelDefinition(
      name: tableName,
      fields: List<FieldDefinition>.unmodifiable(allFields),
      attributes: List<ModelAttribute>.unmodifiable(modelAttributes),
    );
  }

  FieldDefinition _introspectScalarField({
    required sqlite.Row column,
    required Set<String> uniqueColumns,
    required String createSql,
    required bool hasCompoundPrimaryKey,
  }) {
    final name = column['name'] as String;
    final type = _dslScalarType(column['type'] as String? ?? 'TEXT');
    final isPrimaryKey = (column['pk'] as int? ?? 0) > 0;
    final isNullable = (column['notnull'] as int? ?? 0) == 0 && !isPrimaryKey;
    final attributes = <FieldAttribute>[];

    if (isPrimaryKey && !hasCompoundPrimaryKey) {
      attributes.add(
        const FieldAttribute(name: 'id', arguments: <String, String>{}),
      );
    }

    if (uniqueColumns.contains(name) && !isPrimaryKey) {
      attributes.add(
        const FieldAttribute(name: 'unique', arguments: <String, String>{}),
      );
    }

    final defaultValue = column['dflt_value'] as String?;
    final defaultAttribute = _defaultAttributeFor(
      fieldName: name,
      type: type,
      rawDefault: defaultValue,
      isPrimaryKey: isPrimaryKey,
      createSql: createSql,
    );
    if (defaultAttribute != null) {
      attributes.add(defaultAttribute);
    }

    final nativeTypeAttribute = _nativeTypeAttributeFor(
      sqliteType: column['type'] as String? ?? 'TEXT',
      dslType: type,
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
    required String fieldName,
    required String type,
    required String? rawDefault,
    required bool isPrimaryKey,
    required String createSql,
  }) {
    if (rawDefault == null) {
      if (_isAutoincrementPrimaryKey(
        fieldName: fieldName,
        type: type,
        isPrimaryKey: isPrimaryKey,
        createSql: createSql,
      )) {
        return const FieldAttribute(
          name: 'default',
          arguments: <String, String>{'value': 'autoincrement()'},
        );
      }
      return null;
    }

    final normalizedValue = switch (type) {
      'Boolean' =>
        rawDefault == '1'
            ? 'true'
            : rawDefault == '0'
            ? 'false'
            : rawDefault,
      _ => _stripWrappingQuotes(rawDefault),
    };

    return FieldAttribute(
      name: 'default',
      arguments: Map<String, String>.unmodifiable(<String, String>{
        'value': normalizedValue,
      }),
    );
  }

  bool _isAutoincrementPrimaryKey({
    required String fieldName,
    required String type,
    required bool isPrimaryKey,
    required String createSql,
  }) {
    if (!isPrimaryKey || type != 'Int') {
      return false;
    }

    final normalizedSql = createSql.toUpperCase();
    return normalizedSql.contains('"${fieldName.toUpperCase()}"') &&
        normalizedSql.contains('AUTOINCREMENT');
  }

  String _dslScalarType(String sqliteType) {
    final normalized = sqliteType.toUpperCase();
    if (normalized.contains('INT')) {
      return 'Int';
    }
    if (normalized.contains('NUM') || normalized.contains('DEC')) {
      return 'Decimal';
    }
    if (normalized.contains('REAL') ||
        normalized.contains('FLOA') ||
        normalized.contains('DOUB')) {
      return 'Float';
    }
    if (normalized.contains('BLOB')) {
      return 'Bytes';
    }
    if (normalized.contains('BOOL')) {
      return 'Boolean';
    }
    return 'String';
  }

  FieldAttribute? _nativeTypeAttributeFor({
    required String sqliteType,
    required String dslType,
  }) {
    final normalized = sqliteType.toUpperCase().trim();
    if (normalized.isEmpty) {
      return null;
    }

    if (normalized.contains('BLOB')) {
      return const FieldAttribute(
        name: 'db.Blob',
        arguments: <String, String>{},
      );
    }
    if (normalized.contains('REAL') ||
        normalized.contains('FLOA') ||
        normalized.contains('DOUB')) {
      return const FieldAttribute(
        name: 'db.Real',
        arguments: <String, String>{},
      );
    }
    if (normalized.contains('INT') && dslType == 'Int') {
      return const FieldAttribute(
        name: 'db.Integer',
        arguments: <String, String>{},
      );
    }
    if ((normalized.contains('NUM') || normalized.contains('DEC')) &&
        dslType == 'Decimal') {
      return const FieldAttribute(
        name: 'db.Numeric',
        arguments: <String, String>{},
      );
    }
    if (normalized.contains('TEXT')) {
      return const FieldAttribute(
        name: 'db.Text',
        arguments: <String, String>{},
      );
    }

    return null;
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

  String _quoteSqlString(String value) {
    return "'${value.replaceAll("'", "''")}'";
  }

  String _lowercaseFirst(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toLowerCase() + value.substring(1);
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
}
