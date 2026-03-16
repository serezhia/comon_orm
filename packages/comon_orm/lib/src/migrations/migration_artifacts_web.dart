import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../schema/schema_ast.dart';

/// Describes a migration artifact loaded from disk.
class LocalMigrationArtifact {
  /// Creates a local migration artifact descriptor.
  const LocalMigrationArtifact({
    required this.name,
    required this.directoryPath,
    required this.beforeSchema,
    required this.afterSchema,
    required this.migrationSql,
    required this.warnings,
    required this.checksum,
  });

  /// Directory name used as the migration identifier.
  final String name;

  /// Absolute path to the artifact directory.
  final String directoryPath;

  /// Schema snapshot before the migration.
  final String beforeSchema;

  /// Schema snapshot after the migration.
  final String afterSchema;

  /// SQL statements stored in `migration.sql`.
  final String migrationSql;

  /// Warning lines associated with the migration.
  final List<String> warnings;

  /// Content checksum used for drift detection.
  final String checksum;
}

/// Computes the stable checksum stored with a migration artifact.
String computeMigrationChecksum({
  required String provider,
  required String beforeSchema,
  required String afterSchema,
  required String migrationSql,
  required List<String> warnings,
  required bool requiresRebuild,
}) {
  final payload = jsonEncode(<String, Object>{
    'provider': provider,
    'beforeSchema': beforeSchema,
    'afterSchema': afterSchema,
    'migrationSql': migrationSql,
    'warnings': warnings,
    'requiresRebuild': requiresRebuild,
  });
  return sha256.convert(utf8.encode(payload)).toString();
}

/// Serializes warning lines into the canonical metadata representation.
String encodeMigrationWarnings(List<String> warnings) {
  return jsonEncode(warnings);
}

/// Decodes warnings from either JSON or the legacy line-based format.
List<String> decodeMigrationWarnings(String? rawWarnings) {
  if (rawWarnings == null || rawWarnings.trim().isEmpty) {
    return const <String>[];
  }

  final trimmed = rawWarnings.trim();
  try {
    final decoded = jsonDecode(trimmed);
    if (decoded is List) {
      return decoded.map((value) => '$value').toList(growable: false);
    }
  } on FormatException {
    // Fall back to the legacy line-based representation.
  }

  return trimmed
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);
}

/// Builds the `metadata.txt` payload for a migration artifact directory.
String metadataText({
  required String name,
  required DateTime generatedAt,
  required int statementCount,
  required int warningCount,
  required bool rebuildRequired,
  required String provider,
  required String checksum,
}) {
  final buffer = StringBuffer()
    ..writeln('name=$name')
    ..writeln('generated_at=${generatedAt.toIso8601String()}')
    ..writeln('statement_count=$statementCount')
    ..writeln('rebuild_required=$rebuildRequired')
    ..writeln('warning_count=$warningCount')
    ..writeln('provider=$provider')
    ..writeln('checksum=$checksum');
  return buffer.toString();
}

/// Parses `metadata.txt` content into key-value pairs.
Map<String, String> parseMetadataText(String text) {
  final values = <String, String>{};
  for (final line in text.split('\n')) {
    final separator = line.indexOf('=');
    if (separator <= 0) {
      continue;
    }
    values[line.substring(0, separator)] = line.substring(separator + 1);
  }
  return Map<String, String>.unmodifiable(values);
}

/// File-backed migration artifact loading is unavailable on web builds.
List<LocalMigrationArtifact> loadLocalMigrationArtifacts(
  String directoryPath, {
  required String provider,
}) {
  throw UnsupportedError(
    'loadLocalMigrationArtifacts is not available on web targets because it requires filesystem access.',
  );
}

/// Converts a schema AST back into `schema.prisma` source text.
String schemaToSource(SchemaDocument schema) {
  final buffer = StringBuffer();

  void writeSpacerIfNeeded() {
    if (buffer.isNotEmpty) {
      buffer.writeln();
    }
  }

  for (final datasource in schema.datasources) {
    writeSpacerIfNeeded();
    buffer.writeln('datasource ${datasource.name} {');
    for (final entry in datasource.properties.entries) {
      buffer.writeln('  ${entry.key} = ${entry.value}');
    }
    buffer.writeln('}');
  }

  for (final generator in schema.generators) {
    writeSpacerIfNeeded();
    buffer.writeln('generator ${generator.name} {');
    for (final entry in generator.properties.entries) {
      buffer.writeln('  ${entry.key} = ${entry.value}');
    }
    buffer.writeln('}');
  }

  for (final definition in schema.enums) {
    writeSpacerIfNeeded();
    buffer.writeln('enum ${definition.name} {');
    for (final value in definition.values) {
      buffer.writeln('  $value');
    }
    for (final attribute in definition.attributes) {
      buffer.writeln('  ${modelAttributeToSource(attribute)}');
    }
    buffer.writeln('}');
  }

  for (final model in schema.models) {
    writeSpacerIfNeeded();
    buffer.writeln('model ${model.name} {');
    for (final field in model.fields) {
      final rawType = field.isList
          ? '${field.type}[]'
          : field.isNullable
          ? '${field.type}?'
          : field.type;
      final attributes = field.attributes.map(attributeToSource).join(' ');
      if (attributes.isEmpty) {
        buffer.writeln('  ${field.name} $rawType');
      } else {
        buffer.writeln('  ${field.name} $rawType $attributes');
      }
    }

    for (final attribute in model.attributes) {
      buffer.writeln('  ${modelAttributeToSource(attribute)}');
    }

    buffer.writeln('}');
  }

  return buffer.toString();
}

/// Converts a model-level attribute back into schema source.
String modelAttributeToSource(ModelAttribute attribute) {
  if (attribute.arguments.isEmpty) {
    return '@@${attribute.name}';
  }

  final arguments = attribute.arguments.entries
      .map((entry) {
        if (entry.key == 'value') {
          return entry.value;
        }
        return '${entry.key}: ${entry.value}';
      })
      .join(', ');
  return '@@${attribute.name}($arguments)';
}

/// Converts a field attribute back into schema source.
String attributeToSource(FieldAttribute attribute) {
  if (attribute.arguments.isEmpty) {
    return '@${attribute.name}';
  }

  final arguments = attribute.arguments.entries
      .map((entry) {
        if (entry.key == 'value') {
          return entry.value;
        }
        return '${entry.key}: ${entry.value}';
      })
      .join(', ');

  return '@${attribute.name}($arguments)';
}
