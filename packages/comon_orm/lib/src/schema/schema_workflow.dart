import 'dart:io';

import '../migrations/migration_artifacts.dart';
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
  const LoadedSchemaDocument({required this.file, required this.schema});

  /// Absolute schema file path.
  final File file;

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
    required this.wasDeclared,
  });

  /// Selected generator block name.
  final String name;

  /// Generator provider string.
  final String provider;

  /// Absolute output path for the generated client.
  final String outputPath;

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

  /// Loads and validates a schema file asynchronously.
  Future<LoadedSchemaDocument> loadValidatedSchema(String schemaPath) async {
    final file = File(schemaPath).absolute;
    final source = await file.readAsString();
    return _validateLoadedSchema(file, source);
  }

  /// Loads and validates a schema file synchronously.
  LoadedSchemaDocument loadValidatedSchemaSync(String schemaPath) {
    final file = File(schemaPath).absolute;
    final source = file.readAsStringSync();
    return _validateLoadedSchema(file, source);
  }

  /// Formats raw schema source into the canonical serialized form.
  String formatSource(String source) {
    return schemaToSource(parser.parse(source));
  }

  /// Formats a schema file asynchronously and writes it back in place.
  Future<String> formatSchema(String schemaPath) async {
    final file = File(schemaPath).absolute;
    final formatted = formatSource(await file.readAsString());
    await file.writeAsString(formatted);
    return formatted;
  }

  /// Formats a schema file synchronously and writes it back in place.
  String formatSchemaSync(String schemaPath) {
    final file = File(schemaPath).absolute;
    final formatted = formatSource(file.readAsStringSync());
    file.writeAsStringSync(formatted);
    return formatted;
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
        outputPath: _resolveRelativePath(loaded.file.path, fallbackOutputPath),
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
        ? _resolveRelativePath(loaded.file.path, fallbackOutputPath)
        : _resolveGeneratorOutputPath(loaded.file.path, rawOutput);

    return ResolvedGeneratorConfig(
      name: generator.name,
      provider: provider,
      outputPath: outputPath,
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
          ? _resolveSqliteUrl(loaded.file.path, rawUrl)
          : rawUrl,
    );
  }

  LoadedSchemaDocument _validateLoadedSchema(File file, String source) {
    final schema = parser.parse(source);
    final issues = _attachSourceLocations(
      schema,
      validator.validate(schema),
      file.path,
    );
    if (issues.isNotEmpty) {
      throw SchemaValidationException(
        List<ValidationIssue>.unmodifiable(issues),
      );
    }

    return LoadedSchemaDocument(file: file, schema: schema);
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

    return File(
      '$resolvedPath${Platform.pathSeparator}comon_orm_client.dart',
    ).path;
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
    final envMatch = RegExp("^env\\((['\"])(.+)\\1\\)\$").firstMatch(trimmed);
    if (envMatch != null) {
      final variableName = envMatch.group(2)!;
      final environment = _environment ?? Platform.environment;
      final value = environment[variableName];
      if (value == null || value.isEmpty) {
        throw FormatException(
          'Environment variable "$variableName" referenced by $propertyName is not set.',
        );
      }
      return value;
    }

    return _stripQuotes(trimmed);
  }

  String _resolveRelativePath(String schemaPath, String configuredPath) {
    if (configuredPath.startsWith('file:')) {
      return File.fromUri(Uri.parse(configuredPath)).path;
    }

    if (_isAbsoluteFilePath(configuredPath)) {
      return File(_normalizePathSeparators(configuredPath)).path;
    }

    final schemaDirectory = File(schemaPath).absolute.parent.path;
    final normalizedConfiguredPath = _normalizePathSeparators(configuredPath);
    return File(
      '$schemaDirectory${Platform.pathSeparator}$normalizedConfiguredPath',
    ).absolute.path;
  }

  bool _isAbsoluteFilePath(String path) {
    if (path.startsWith(Platform.pathSeparator)) {
      return true;
    }

    if (Platform.isWindows) {
      return path.startsWith(r'\\') ||
          RegExp(r'^[a-zA-Z]:[/\\]').hasMatch(path);
    }

    return false;
  }

  String _normalizePathSeparators(String path) {
    if (Platform.pathSeparator == r'\') {
      return path.replaceAll('/', Platform.pathSeparator);
    }

    return path.replaceAll(r'\', Platform.pathSeparator);
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
