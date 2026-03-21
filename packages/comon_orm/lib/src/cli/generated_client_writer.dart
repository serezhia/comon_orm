import 'dart:io';

import '../codegen/client_generator.dart';
import '../schema/schema_workflow_web.dart'
    if (dart.library.io) '../schema/schema_workflow.dart';

/// Result of writing generated client code to disk.
class GeneratedClientWriteResult {
  /// Creates a write result.
  const GeneratedClientWriteResult({
    required this.outputPath,
    required this.updated,
  });

  /// Absolute path to the generated client file.
  final String outputPath;

  /// Whether the file content changed on disk.
  final bool updated;
}

/// Writes generated client output for a loaded schema.
class GeneratedClientWriter {
  /// Creates a writer with configurable schema workflow.
  const GeneratedClientWriter({this.workflow = const SchemaWorkflow()});

  /// Workflow used to resolve generator configuration.
  final SchemaWorkflow workflow;

  /// Generates and writes client code for [loaded].
  Future<GeneratedClientWriteResult> writeForLoadedSchema(
    LoadedSchemaDocument loaded, {
    String? generatorName,
    String? outputPath,
  }) async {
    final generator = workflow.resolveGenerator(
      loaded,
      generatorName: generatorName,
    );
    final effectiveOutputPath = outputPath == null || outputPath.isEmpty
        ? generator.outputPath
        : File(outputPath).absolute.path;
    final outputFile = File(effectiveOutputPath);
    final schemaSource = await File(loaded.filePath).readAsString();
    final content = ClientGenerator(
      options: resolveClientGeneratorOptions(
        generator: generator,
        anchorDirectory: outputFile.parent,
      ),
    ).generateClient(loaded.schema, schemaSource: schemaSource);

    final existing = outputFile.existsSync()
        ? await outputFile.readAsString()
        : null;
    if (existing == content) {
      return GeneratedClientWriteResult(
        outputPath: outputFile.path,
        updated: false,
      );
    }

    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(content);
    return GeneratedClientWriteResult(
      outputPath: outputFile.path,
      updated: true,
    );
  }

  /// Synchronously generates and writes client code for [loaded].
  GeneratedClientWriteResult writeForLoadedSchemaSync(
    LoadedSchemaDocument loaded, {
    String? generatorName,
    String? outputPath,
  }) {
    final generator = workflow.resolveGenerator(
      loaded,
      generatorName: generatorName,
    );
    final effectiveOutputPath = outputPath == null || outputPath.isEmpty
        ? generator.outputPath
        : File(outputPath).absolute.path;
    final outputFile = File(effectiveOutputPath);
    final schemaSource = File(loaded.filePath).readAsStringSync();
    final content = ClientGenerator(
      options: resolveClientGeneratorOptions(
        generator: generator,
        anchorDirectory: outputFile.parent,
      ),
    ).generateClient(loaded.schema, schemaSource: schemaSource);

    final existing = outputFile.existsSync()
        ? outputFile.readAsStringSync()
        : null;
    if (existing == content) {
      return GeneratedClientWriteResult(
        outputPath: outputFile.path,
        updated: false,
      );
    }

    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync(content);
    return GeneratedClientWriteResult(
      outputPath: outputFile.path,
      updated: true,
    );
  }
}

/// Resolves generator options for a concrete output location.
ClientGeneratorOptions resolveClientGeneratorOptions({
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

  final pubspec = findNearestPubspec(anchorDirectory);
  if (pubspec == null) {
    return const ClientGeneratorOptions();
  }

  final source = pubspec.readAsStringSync();
  final sqliteHelperKind =
      pubspecReferencesPackage(source, 'comon_orm_sqlite_flutter')
      ? SqliteClientHelperKind.flutter
      : SqliteClientHelperKind.vm;
  return ClientGeneratorOptions(sqliteHelperKind: sqliteHelperKind);
}

/// Finds the nearest `pubspec.yaml` walking upwards from [start].
File? findNearestPubspec(Directory start) {
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

/// Returns whether a pubspec references [packageName].
bool pubspecReferencesPackage(String source, String packageName) {
  for (final line in source.split('\n')) {
    final trimmed = line.trim();
    if (trimmed == 'name: $packageName' ||
        trimmed.startsWith('$packageName:')) {
      return true;
    }
  }
  return false;
}
