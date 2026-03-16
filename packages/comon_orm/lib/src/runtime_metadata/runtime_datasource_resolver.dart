import 'package:meta/meta.dart';

import '../schema/schema_ast.dart';
import 'generated_runtime_schema.dart';
import 'runtime_platform_environment.dart';
import 'runtime_schema_view.dart';

@immutable
/// Datasource settings resolved from runtime metadata.
class ResolvedRuntimeDatasourceConfig {
  /// Creates a resolved runtime datasource config.
  const ResolvedRuntimeDatasourceConfig({
    required this.name,
    required this.provider,
    required this.url,
  });

  /// Selected datasource block name.
  final String name;

  /// Datasource provider such as `sqlite` or `postgresql`.
  final String provider;

  /// Resolved connection string or database path.
  final String url;
}

/// Resolves datasource configuration from runtime metadata bridges.
class RuntimeDatasourceResolver {
  /// Creates a runtime datasource resolver.
  const RuntimeDatasourceResolver({Map<String, String>? environment})
    : _environment = environment;

  final Map<String, String>? _environment;

  /// Resolves a datasource from a runtime schema bridge.
  ResolvedRuntimeDatasourceConfig resolveDatasource({
    required RuntimeSchemaView schema,
    String? datasourceName,
    required String expectedProvider,
    String schemaPath = 'schema.prisma',
  }) {
    final datasource = _selectDatasource(schema, datasourceName);
    if (datasource == null) {
      throw FormatException(
        'Schema does not declare a datasource block and no connection override was provided.',
      );
    }

    if (datasource.provider != expectedProvider) {
      throw FormatException(
        'Datasource "${datasource.name}" uses provider "${datasource.provider}", expected "$expectedProvider".',
      );
    }

    return ResolvedRuntimeDatasourceConfig(
      name: datasource.name,
      provider: datasource.provider,
      url: _resolveDatasourceUrl(
        datasource.url,
        expectedProvider: expectedProvider,
        schemaPath: schemaPath,
        propertyName: 'datasource ${datasource.name}.url',
      ),
    );
  }

  /// Resolves a datasource directly from generated runtime metadata.
  ResolvedRuntimeDatasourceConfig resolveGeneratedDatasource({
    required GeneratedRuntimeSchema schema,
    String? datasourceName,
    required String expectedProvider,
    String schemaPath = 'schema.prisma',
  }) {
    return resolveDatasource(
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      datasourceName: datasourceName,
      expectedProvider: expectedProvider,
      schemaPath: schemaPath,
    );
  }

  /// Resolves a datasource from an AST-backed schema document via the bridge.
  ResolvedRuntimeDatasourceConfig resolveSchemaDocument({
    required SchemaDocument schema,
    String? datasourceName,
    required String expectedProvider,
    String schemaPath = 'schema.prisma',
  }) {
    return resolveDatasource(
      schema: runtimeSchemaViewFromSchemaDocument(schema),
      datasourceName: datasourceName,
      expectedProvider: expectedProvider,
      schemaPath: schemaPath,
    );
  }

  RuntimeDatasourceView? _selectDatasource(
    RuntimeSchemaView schema,
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

  String _resolveDatasourceUrl(
    RuntimeDatasourceUrlView url, {
    required String expectedProvider,
    required String schemaPath,
    required String propertyName,
  }) {
    final rawUrl = switch (url.kind) {
      RuntimeDatasourceUrlKind.literal => url.value,
      RuntimeDatasourceUrlKind.expression => url.value,
      RuntimeDatasourceUrlKind.env => _resolveEnvironmentValue(
        url.value,
        propertyName: propertyName,
      ),
    };

    return expectedProvider == 'sqlite'
        ? _resolveSqliteUrl(schemaPath, rawUrl)
        : rawUrl;
  }

  String _resolveEnvironmentValue(
    String variableName, {
    required String propertyName,
  }) {
    final environment = _environment ?? defaultRuntimeEnvironment();
    final value = environment?[variableName];
    if (value == null || value.isEmpty) {
      throw FormatException(
        'Environment variable "$variableName" referenced by $propertyName is not set.',
      );
    }
    return value;
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
}
