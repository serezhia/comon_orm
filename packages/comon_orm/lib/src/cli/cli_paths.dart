import 'dart:io';

/// Discovers `schema.prisma` or validates an explicit schema path.
String discoverSchemaPath({String? explicitPath}) {
  if (explicitPath != null) {
    final file = File(explicitPath).absolute;
    if (!file.existsSync()) {
      throw FormatException('Schema file not found: ${file.path}');
    }
    return file.path;
  }

  const candidates = <String>['prisma/schema.prisma', 'schema.prisma'];
  for (final candidate in candidates) {
    final file = File(candidate).absolute;
    if (file.existsSync()) {
      return file.path;
    }
  }

  throw const FormatException(
    'Could not find Prisma schema file.\n\n'
    'Checked the following paths:\n'
    '  - prisma/schema.prisma: file not found\n'
    '  - schema.prisma: file not found\n\n'
    'You can specify the schema path with --schema <path>.',
  );
}

/// Returns the default migrations directory for a given schema path.
String defaultMigrationsDirectory(String schemaPath) {
  final schemaDirectory = File(schemaPath).absolute.parent;
  if (_baseName(schemaDirectory.path) == 'prisma') {
    return '${schemaDirectory.path}${Platform.pathSeparator}migrations';
  }

  return '${schemaDirectory.path}${Platform.pathSeparator}prisma${Platform.pathSeparator}migrations';
}

String _baseName(String path) {
  final normalized = path.replaceAll(RegExp(r'[\\/]+4'), '');
  final segments = normalized.split(RegExp(r'[\\/]'));
  return segments.isEmpty ? normalized : segments.last;
}
