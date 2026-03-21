import '../migrations/migration_artifacts_web.dart';
import 'schema_ast.dart';
import 'schema_parser.dart';
import 'schema_validator.dart';

/// Exception thrown when schema validation returns one or more issues.
class SchemaValidationException implements Exception {
  /// Creates a validation exception.
  const SchemaValidationException(this.issues);

  /// Validation issues returned by the workflow.
  final List<ValidationIssue> issues;

  @override
  String toString() => issues.join('\n');
}

/// Validated schema together with its source file path.
class LoadedSchemaDocument {
  /// Creates a loaded schema document.
  const LoadedSchemaDocument({required this.filePath, required this.schema});

  /// Absolute or logical schema file path.
  final String filePath;

  /// Parsed and validated schema document.
  final SchemaDocument schema;
}

/// Resolved generator settings used by code generation commands.
class ResolvedGeneratorConfig {
  /// Creates a resolved generator config.
  const ResolvedGeneratorConfig({
    required this.name,
    required this.provider,
    required this.outputPath,
    required this.sqliteHelper,
    required this.wasDeclared,
  });

  /// Selected generator block name.
  final String name;

  /// Generator provider string.
  final String provider;

  /// Absolute output path for the generated client.
  final String outputPath;

  /// Explicit SQLite helper target from the generator block, if configured.
  final String? sqliteHelper;

  /// Whether the generator came from an explicit schema block.
  final bool wasDeclared;
}

/// Resolved datasource settings used by runtime adapters and CLIs.
class ResolvedDatasourceConfig {
  /// Creates a resolved datasource config.
  const ResolvedDatasourceConfig({
    required this.name,
    required this.provider,
    required this.url,
  });

  /// Selected datasource block name.
  final String name;

  /// Datasource provider string.
  final String provider;

  /// Resolved connection string or database path.
  final String url;
}

/// Convenience workflow for loading, validating, and resolving schema config.
class SchemaWorkflow {
  /// Creates a workflow with optional parser, validator, and environment.
  const SchemaWorkflow({
    this.parser = const SchemaParser(),
    this.validator = const SchemaValidator(),
    Map<String, String>? environment,
  }) : _environment = environment;

  /// Parser used to convert source text into a schema AST.
  final SchemaParser parser;

  /// Validator used after parsing.
  final SchemaValidator validator;
  final Map<String, String>? _environment;

  /// File-backed loading is unavailable on web builds.
  Future<LoadedSchemaDocument> loadValidatedSchema(String schemaPath) {
    throw UnsupportedError(
      'SchemaWorkflow.loadValidatedSchema is not available on web targets. '
      'Use loadValidatedSchemaSource(...) with schema text instead.',
    );
  }

  /// File-backed loading is unavailable on web builds.
  LoadedSchemaDocument loadValidatedSchemaSync(String schemaPath) {
    throw UnsupportedError(
      'SchemaWorkflow.loadValidatedSchemaSync is not available on web targets. '
      'Use loadValidatedSchemaSource(...) with schema text instead.',
    );
  }

  /// Validates raw schema source without relying on a filesystem.
  LoadedSchemaDocument loadValidatedSchemaSource({
    required String source,
    String filePath = 'schema.prisma',
  }) {
    return _validateLoadedSchema(filePath, source);
  }

  /// Formats raw schema source into the canonical serialized form.
  String formatSource(String source) {
    return schemaToSource(parser.parse(source));
  }

  /// File-backed formatting is unavailable on web builds.
  Future<String> formatSchema(String schemaPath) {
    throw UnsupportedError(
      'SchemaWorkflow.formatSchema is not available on web targets. '
      'Use formatSource(...) and persist the result with your own storage layer.',
    );
  }

  /// File-backed formatting is unavailable on web builds.
  String formatSchemaSync(String schemaPath) {
    throw UnsupportedError(
      'SchemaWorkflow.formatSchemaSync is not available on web targets. '
      'Use formatSource(...) and persist the result with your own storage layer.',
    );
  }

  /// Resolves generator settings for a loaded schema.
  ResolvedGeneratorConfig resolveGenerator(
    LoadedSchemaDocument loaded, {
    String? generatorName,
    String expectedProvider = 'comon_orm',
    String fallbackOutputPath = 'lib/generated/comon_orm_client.dart',
  }) {
    final generator = _selectGenerator(loaded.schema, generatorName);
    if (generator == null) {
      return ResolvedGeneratorConfig(
        name: generatorName ?? 'client',
        provider: expectedProvider,
        outputPath: _resolveRelativePath(loaded.filePath, fallbackOutputPath),
        sqliteHelper: null,
        wasDeclared: false,
      );
    }

    final provider = _resolveScalarValue(
      generator.properties['provider'],
      propertyName: 'generator ${generator.name}.provider',
    );
    if (provider != expectedProvider) {
      throw FormatException(
        'Generator "${generator.name}" uses provider "$provider", expected "$expectedProvider".',
      );
    }

    final rawOutput = generator.properties['output'];
    final outputPath = rawOutput == null || rawOutput.trim().isEmpty
        ? _resolveRelativePath(loaded.filePath, fallbackOutputPath)
        : _resolveGeneratorOutputPath(loaded.filePath, rawOutput);
    final sqliteHelper = _resolveOptionalSqliteHelper(
      generator.properties['sqliteHelper'],
      generatorName: generator.name,
    );

    return ResolvedGeneratorConfig(
      name: generator.name,
      provider: provider,
      outputPath: outputPath,
      sqliteHelper: sqliteHelper,
      wasDeclared: true,
    );
  }

  /// Resolves datasource settings for a loaded schema.
  ResolvedDatasourceConfig resolveDatasource(
    LoadedSchemaDocument loaded, {
    String? datasourceName,
    required String expectedProvider,
  }) {
    final datasource = _selectDatasource(loaded.schema, datasourceName);
    if (datasource == null) {
      throw FormatException(
        'Schema does not declare a datasource block and no connection override was provided.',
      );
    }

    final provider = _resolveScalarValue(
      datasource.properties['provider'],
      propertyName: 'datasource ${datasource.name}.provider',
    );
    if (provider != expectedProvider) {
      throw FormatException(
        'Datasource "${datasource.name}" uses provider "$provider", expected "$expectedProvider".',
      );
    }

    final rawUrl = _resolveScalarValue(
      datasource.properties['url'],
      propertyName: 'datasource ${datasource.name}.url',
    );

    return ResolvedDatasourceConfig(
      name: datasource.name,
      provider: provider,
      url: expectedProvider == 'sqlite'
          ? _resolveSqliteUrl(loaded.filePath, rawUrl)
          : rawUrl,
    );
  }

  LoadedSchemaDocument _validateLoadedSchema(String filePath, String source) {
    final normalizedFilePath = _normalizePathSeparators(filePath);
    final schema = parser.parse(source);
    final issues = _attachSourceLocations(
      schema,
      validator.validate(schema),
      normalizedFilePath,
    );
    if (issues.isNotEmpty) {
      throw SchemaValidationException(
        List<ValidationIssue>.unmodifiable(issues),
      );
    }

    return LoadedSchemaDocument(filePath: normalizedFilePath, schema: schema);
  }

  List<ValidationIssue> _attachSourceLocations(
    SchemaDocument schema,
    List<ValidationIssue> issues,
    String filePath,
  ) {
    return issues
        .map(
          (issue) => ValidationIssue(
            message: issue.message,
            modelName: issue.modelName,
            fieldName: issue.fieldName,
            filePath: filePath,
            line: issue.line ?? _resolveIssueLine(schema, issue),
            column: issue.column ?? _resolveIssueColumn(schema, issue),
          ),
        )
        .toList(growable: false);
  }

  int? _resolveIssueLine(SchemaDocument schema, ValidationIssue issue) {
    final modelName = issue.modelName;
    if (modelName == null) {
      return issue.line;
    }

    final model = schema.findModel(modelName);
    if (model != null) {
      if (issue.fieldName != null) {
        final field = model.findField(issue.fieldName!);
        if (field != null) {
          return field.line ?? model.line;
        }
      }
      return model.line;
    }

    final enumDefinition = schema.findEnum(modelName);
    if (enumDefinition != null) {
      return enumDefinition.line;
    }

    final datasource = schema.findDatasource(modelName);
    if (datasource != null) {
      return datasource.line;
    }

    final generator = schema.findGenerator(modelName);
    if (generator != null) {
      return generator.line;
    }

    return issue.line;
  }

  int? _resolveIssueColumn(SchemaDocument schema, ValidationIssue issue) {
    final modelName = issue.modelName;
    if (modelName == null) {
      return issue.column;
    }

    final model = schema.findModel(modelName);
    if (model != null) {
      if (issue.fieldName != null) {
        final field = model.findField(issue.fieldName!);
        if (field != null) {
          return field.column ?? model.column;
        }
      }
      return model.column;
    }

    final enumDefinition = schema.findEnum(modelName);
    if (enumDefinition != null) {
      return enumDefinition.column;
    }

    final datasource = schema.findDatasource(modelName);
    if (datasource != null) {
      return datasource.column;
    }

    final generator = schema.findGenerator(modelName);
    if (generator != null) {
      return generator.column;
    }

    return issue.column;
  }

  GeneratorDefinition? _selectGenerator(
    SchemaDocument schema,
    String? generatorName,
  ) {
    if (schema.generators.isEmpty) {
      return null;
    }

    if (generatorName != null) {
      final generator = schema.findGenerator(generatorName);
      if (generator == null) {
        throw FormatException('Unknown generator "$generatorName".');
      }
      return generator;
    }

    if (schema.generators.length == 1) {
      return schema.generators.first;
    }

    final clientGenerator = schema.findGenerator('client');
    if (clientGenerator != null) {
      return clientGenerator;
    }

    throw FormatException(
      'Schema declares multiple generator blocks. Pass --generator <name>.',
    );
  }

  DatasourceDefinition? _selectDatasource(
    SchemaDocument schema,
    String? datasourceName,
  ) {
    if (schema.datasources.isEmpty) {
      return null;
    }

    if (datasourceName != null) {
      final datasource = schema.findDatasource(datasourceName);
      if (datasource == null) {
        throw FormatException('Unknown datasource "$datasourceName".');
      }
      return datasource;
    }

    if (schema.datasources.length == 1) {
      return schema.datasources.first;
    }

    final defaultDatasource = schema.findDatasource('db');
    if (defaultDatasource != null) {
      return defaultDatasource;
    }

    throw FormatException(
      'Schema declares multiple datasource blocks. Pass --datasource <name>.',
    );
  }

  String _resolveGeneratorOutputPath(String schemaPath, String rawOutput) {
    final configuredPath = _resolveScalarValue(
      rawOutput,
      propertyName: 'generator.output',
    );
    final resolvedPath = _resolveRelativePath(schemaPath, configuredPath);
    if (resolvedPath.endsWith('.dart')) {
      return resolvedPath;
    }

    return _joinPathSegments(resolvedPath, 'comon_orm_client.dart');
  }

  String _resolveSqliteUrl(String schemaPath, String rawUrl) {
    if (rawUrl == ':memory:' || rawUrl == 'file::memory:') {
      return ':memory:';
    }

    if (rawUrl.startsWith('file:')) {
      final path = rawUrl.substring(5);
      if (path.isEmpty) {
        throw const FormatException('SQLite datasource url must not be empty.');
      }
      return _resolveRelativePath(schemaPath, path);
    }

    return _resolveRelativePath(schemaPath, rawUrl);
  }

  String _resolveScalarValue(String? rawValue, {required String propertyName}) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      throw FormatException('$propertyName must not be empty.');
    }

    final trimmed = rawValue.trim();
    final envMatch = RegExp("^env\\((['\"])(.+)\\1\\)").firstMatch(trimmed);
    if (envMatch != null) {
      final variableName = envMatch.group(2)!;
      final environment = _environment;
      final value = environment?[variableName];
      if (value == null || value.isEmpty) {
        throw FormatException(
          'Environment variable "$variableName" referenced by $propertyName is not set. '
          'Pass SchemaWorkflow(environment: ...) on web targets.',
        );
      }
      return value;
    }

    return _stripQuotes(trimmed);
  }

  String? _resolveOptionalSqliteHelper(
    String? rawValue, {
    required String generatorName,
  }) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    final value = _resolveScalarValue(
      rawValue,
      propertyName: 'generator $generatorName.sqliteHelper',
    );
    switch (value) {
      case 'vm':
      case 'flutter':
        return value;
    }

    throw FormatException(
      'Generator "$generatorName" uses unsupported sqliteHelper "$value". '
      'Expected one of: vm, flutter.',
    );
  }

  String _resolveRelativePath(String schemaPath, String configuredPath) {
    if (configuredPath.startsWith('file:')) {
      final uri = Uri.parse(configuredPath);
      if (uri.scheme == 'file') {
        return _normalizePathSeparators(uri.path);
      }
    }

    final normalizedConfiguredPath = _normalizePathSeparators(configuredPath);
    if (_isAbsoluteFilePath(normalizedConfiguredPath)) {
      return normalizedConfiguredPath;
    }

    final schemaDirectory = _dirname(_normalizePathSeparators(schemaPath));
    return _joinPathSegments(schemaDirectory, normalizedConfiguredPath);
  }

  bool _isAbsoluteFilePath(String path) {
    return path.startsWith('/') ||
        path.startsWith('//') ||
        RegExp(r'^[a-zA-Z]:/').hasMatch(path);
  }

  String _normalizePathSeparators(String path) {
    return path.replaceAll(r'\', '/');
  }

  String _dirname(String path) {
    final normalized = _normalizePathSeparators(path);
    final separator = normalized.lastIndexOf('/');
    if (separator < 0) {
      return '.';
    }
    if (separator == 0) {
      return '/';
    }
    return normalized.substring(0, separator);
  }

  String _joinPathSegments(String left, String right) {
    final normalizedLeft = _normalizePathSeparators(left);
    final normalizedRight = _normalizePathSeparators(right);
    final joined = normalizedLeft == '.' || normalizedLeft.isEmpty
        ? normalizedRight
        : normalizedLeft.endsWith('/')
        ? '$normalizedLeft$normalizedRight'
        : '$normalizedLeft/$normalizedRight';
    return _collapsePath(joined);
  }

  String _collapsePath(String path) {
    final normalized = _normalizePathSeparators(path);
    final prefixMatch = RegExp(r'^(?:[a-zA-Z]:/|//|/)').firstMatch(normalized);
    final prefix = prefixMatch?.group(0) ?? '';
    final tail = prefix.isEmpty
        ? normalized
        : normalized.substring(prefix.length);
    final collapsed = <String>[];
    for (final segment in tail.split('/')) {
      if (segment.isEmpty || segment == '.') {
        continue;
      }
      if (segment == '..') {
        if (collapsed.isNotEmpty && collapsed.last != '..') {
          collapsed.removeLast();
        } else if (prefix.isEmpty) {
          collapsed.add(segment);
        }
        continue;
      }
      collapsed.add(segment);
    }

    final collapsedTail = collapsed.join('/');
    if (prefix.isNotEmpty) {
      return collapsedTail.isEmpty ? prefix : '$prefix$collapsedTail';
    }

    return collapsedTail.isEmpty ? '.' : collapsedTail;
  }

  String _stripQuotes(String value) {
    if (value.length < 2) {
      return value;
    }

    final first = value[0];
    final last = value[value.length - 1];
    if ((first == '"' && last == '"') || (first == '\'' && last == '\'')) {
      return value.substring(1, value.length - 1);
    }

    return value;
  }
}
