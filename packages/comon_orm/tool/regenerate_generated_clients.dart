import 'dart:io';

import 'package:comon_orm/comon_orm.dart';

void main() {
  const fixtures = <MapEntry<String, String>>[
    MapEntry(
      'test/generated/_runtime_fixture_schema.prisma',
      'test/generated/comon_orm_client.dart',
    ),
    MapEntry(
      'test/generated/_runtime_rich_parity_schema.prisma',
      'test/generated/runtime_rich_parity_client.dart',
    ),
    MapEntry(
      'test/generated/_runtime_compound_direct_schema.prisma',
      'test/generated/runtime_compound_direct_client.dart',
    ),
    MapEntry(
      'test/generated/_runtime_required_inverse_schema.prisma',
      'test/generated/runtime_required_inverse_client.dart',
    ),
    MapEntry(
      'example/schema.prisma',
      'example/generated/comon_orm_client.dart',
    ),
    MapEntry(
      '../comon_orm_postgresql/example/schema.prisma',
      '../comon_orm_postgresql/example/generated/comon_orm_client.dart',
    ),
    MapEntry(
      '../comon_orm_sqlite/example/schema.prisma',
      '../comon_orm_sqlite/example/generated/comon_orm_client.dart',
    ),
    MapEntry(
      '../../examples/postgres/schema.prisma',
      '../../examples/postgres/lib/generated/comon_orm_client.dart',
    ),
    MapEntry(
      '../../examples/flutter_sqlite/schema.prisma',
      '../../examples/flutter_sqlite/lib/generated/comon_orm_client.dart',
    ),
  ];

  for (final fixture in fixtures) {
    final generated = _generateClientForFixture(
      schemaPath: fixture.key,
      outputPath: fixture.value,
    );
    final outputFile = File(_fixturePath(fixture.value));
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync(generated);
    stdout.writeln('Updated ${fixture.value}');
  }
}

String _generateClientForFixture({
  required String schemaPath,
  required String outputPath,
}) {
  final workflow = const SchemaWorkflow();
  final loaded = workflow.loadValidatedSchemaSync(_fixturePath(schemaPath));
  final generator = workflow.resolveGenerator(loaded);
  final outputFile = File(_fixturePath(outputPath));
  final schemaSource = File(loaded.filePath).readAsStringSync();

  return ClientGenerator(
    options: _resolveClientGeneratorOptions(
      generator: generator,
      anchorDirectory: outputFile.parent,
    ),
  ).generateClient(loaded.schema, schemaSource: schemaSource);
}

String _fixturePath(String relativePath) {
  final normalized = relativePath.replaceAll('/', Platform.pathSeparator);
  return '${_comonOrmPackageRoot.path}${Platform.pathSeparator}$normalized';
}

final Directory _workspaceRoot = _resolveWorkspaceRoot();
final Directory _comonOrmPackageRoot = Directory(
  '${_workspaceRoot.path}${Platform.pathSeparator}packages${Platform.pathSeparator}comon_orm',
);

ClientGeneratorOptions _resolveClientGeneratorOptions({
  required ResolvedGeneratorConfig generator,
  required Directory anchorDirectory,
}) {
  final explicitSqliteHelper = generator.sqliteHelper;
  if (explicitSqliteHelper != null) {
    return ClientGeneratorOptions(
      sqliteHelperKind: switch (explicitSqliteHelper) {
        'flutter' => SqliteClientHelperKind.flutter,
        _ => SqliteClientHelperKind.vm,
      },
    );
  }

  final pubspec = _findNearestPubspec(anchorDirectory);
  if (pubspec == null) {
    return const ClientGeneratorOptions();
  }

  final source = pubspec.readAsStringSync();
  final sqliteHelperKind =
      _pubspecReferencesPackage(source, 'comon_orm_sqlite_flutter')
      ? SqliteClientHelperKind.flutter
      : SqliteClientHelperKind.vm;
  return ClientGeneratorOptions(sqliteHelperKind: sqliteHelperKind);
}

File? _findNearestPubspec(Directory start) {
  var current = start.absolute;
  while (true) {
    final candidate = File(
      '${current.path}${Platform.pathSeparator}pubspec.yaml',
    );
    if (candidate.existsSync()) {
      return candidate;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      return null;
    }
    current = parent;
  }
}

bool _pubspecReferencesPackage(String source, String packageName) {
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed == 'name: $packageName' ||
        trimmed.startsWith('$packageName:')) {
      return true;
    }
  }
  return false;
}

Directory _resolveWorkspaceRoot() {
  var current = Directory.current.absolute;
  while (true) {
    final packagePubspec = File(
      '${current.path}${Platform.pathSeparator}packages${Platform.pathSeparator}comon_orm${Platform.pathSeparator}pubspec.yaml',
    );
    if (packagePubspec.existsSync()) {
      return current;
    }

    final parent = current.parent;
    if (parent.path == current.path) {
      throw StateError(
        'Could not resolve workspace root for generator fixture regeneration.',
      );
    }
    current = parent;
  }
}
