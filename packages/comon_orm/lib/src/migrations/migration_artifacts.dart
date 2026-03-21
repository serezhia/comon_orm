import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import '../schema/schema_ast.dart';

const _manualMigrationWarningSuffix = 'requires manual migration.';

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
    required this.statementCount,
    required this.rebuildRequired,
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

  /// Statement count declared in metadata or derived from the script.
  final int statementCount;

  /// Whether the artifact represents a rebuild migration.
  final bool rebuildRequired;

  /// Content checksum used for drift detection.
  final String checksum;
}

/// Exception raised when a migration requires manual intervention.
class ManualMigrationRequiredException implements Exception {
  /// Creates a manual-migration exception.
  const ManualMigrationRequiredException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => message;
}

/// Whether [warning] indicates that the migration cannot be applied automatically.
bool isManualMigrationWarning(String warning) {
  return warning.trim().endsWith(_manualMigrationWarningSuffix);
}

/// Whether any warning indicates that the migration requires manual intervention.
bool containsManualMigrationWarnings(Iterable<String> warnings) {
  return warnings.any(isManualMigrationWarning);
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

/// Loads and validates migration artifacts from [directoryPath].
List<LocalMigrationArtifact> loadLocalMigrationArtifacts(
  String directoryPath, {
  required String provider,
}) {
  final root = Directory(directoryPath);
  if (!root.existsSync()) {
    return const <LocalMigrationArtifact>[];
  }

  final artifacts = <LocalMigrationArtifact>[];
  final directories = root.listSync().whereType<Directory>().toList(
    growable: false,
  )..sort((left, right) => left.path.compareTo(right.path));

  for (final directory in directories) {
    final name = directory.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    final beforeSchema = File(
      '${directory.path}${Platform.pathSeparator}before.prisma',
    );
    final afterSchema = File(
      '${directory.path}${Platform.pathSeparator}after.prisma',
    );
    final migrationSql = File(
      '${directory.path}${Platform.pathSeparator}migration.sql',
    );
    final warnings = File(
      '${directory.path}${Platform.pathSeparator}warnings.txt',
    );

    if (!beforeSchema.existsSync() ||
        !afterSchema.existsSync() ||
        !migrationSql.existsSync()) {
      throw StateError(
        'Migration artifact "$name" is incomplete in ${directory.path}. Expected before.prisma, after.prisma, and migration.sql.',
      );
    }

    final warningLines = warnings.existsSync()
        ? warnings
              .readAsStringSync()
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList(growable: false)
        : const <String>[];
    final beforeText = beforeSchema.readAsStringSync();
    final afterText = afterSchema.readAsStringSync();
    final sqlText = migrationSql.readAsStringSync();
    final metadataFile = File(
      '${directory.path}${Platform.pathSeparator}metadata.txt',
    );
    final metadata = metadataFile.existsSync()
        ? parseMetadataText(metadataFile.readAsStringSync())
        : const <String, String>{};
    final rebuildRequired =
        metadata['rebuild_required'] == 'true' ||
        sqlText.startsWith(
          '-- Schema rebuild required to apply this migration safely.',
        );
    final statementCount =
        int.tryParse(metadata['statement_count'] ?? '') ??
        _estimateStatementCount(sqlText, rebuildRequired: rebuildRequired);

    artifacts.add(
      LocalMigrationArtifact(
        name: name,
        directoryPath: directory.path,
        beforeSchema: beforeText,
        afterSchema: afterText,
        migrationSql: sqlText,
        warnings: warningLines,
        statementCount: statementCount,
        rebuildRequired: rebuildRequired,
        checksum: computeMigrationChecksum(
          provider: provider,
          beforeSchema: beforeText,
          afterSchema: afterText,
          migrationSql: sqlText,
          warnings: warningLines,
          requiresRebuild: rebuildRequired,
        ),
      ),
    );
  }

  return List<LocalMigrationArtifact>.unmodifiable(artifacts);
}

int _estimateStatementCount(
  String migrationSql, {
  required bool rebuildRequired,
}) {
  if (rebuildRequired) {
    return 0;
  }
  return migrationSql
      .split(';')
      .map((statement) => statement.trim())
      .where((statement) => statement.isNotEmpty && !statement.startsWith('--'))
      .length;
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
