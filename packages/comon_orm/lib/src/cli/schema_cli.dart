import 'dart:io';

import '../codegen/client_generator.dart';
import '../schema/schema_parser.dart';
import '../schema/schema_workflow.dart';
import 'migration_cli_dispatcher.dart';

/// Top-level command runner for the `comon_orm` executable.
class ComonOrmCli {
  /// Creates a CLI runner with injectable workflow, dispatcher, and sinks.
  ComonOrmCli({
    SchemaWorkflow workflow = const SchemaWorkflow(),
    MigrationCliDispatcher? migrationDispatcher,
    StringSink? out,
    StringSink? err,
  }) : _workflow = workflow,
       _migrationDispatcher =
           migrationDispatcher ?? MigrationCliDispatcher(out: out, err: err),
       _out = out ?? stdout,
       _err = err ?? stderr;

  final SchemaWorkflow _workflow;
  final MigrationCliDispatcher _migrationDispatcher;
  final StringSink _out;
  final StringSink _err;

  /// Runs the CLI with the provided raw [arguments] and returns an exit code.
  Future<int> run(List<String> arguments) async {
    if (arguments.isEmpty) {
      _printUsage();
      return 64;
    }

    try {
      final command = arguments.first;
      switch (command) {
        case 'check':
        case 'validate':
          return _check(arguments.skip(1).toList(growable: false));
        case 'format':
          return _format(arguments.skip(1).toList(growable: false));
        case 'generate':
          return _generate(arguments.skip(1).toList(growable: false));
        case 'generate-preview':
          return _generatePreview(arguments.skip(1).toList(growable: false));
        case 'migrate':
          return _migrationDispatcher.run(
            arguments.skip(1).toList(growable: false),
          );
        default:
          _err.writeln('Unknown command: $command');
          _printUsage();
          return 64;
      }
    } on FormatException catch (error) {
      _err.writeln(error.message);
      return 64;
    }
  }

  int _check(List<String> arguments) {
    final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
    final loaded = _loadValidatedSchema(
      parsed.positionals.isEmpty ? 'schema.prisma' : parsed.positionals.first,
    );
    if (loaded == null) {
      return 1;
    }

    _out.writeln('Schema is valid.');
    return 0;
  }

  int _format(List<String> arguments) {
    final parsed = _parseArguments(arguments);
    final schemaPath = parsed.positionals.isEmpty
        ? 'schema.prisma'
        : parsed.positionals.first;

    try {
      final file = File(schemaPath).absolute;
      _workflow.formatSchemaSync(file.path);
      _out.writeln('Formatted schema: ${file.path}');
      return 0;
    } on Object catch (error) {
      _err.writeln(error);
      return 1;
    }
  }

  Future<int> _generate(List<String> arguments) async {
    final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
    final schemaPath = parsed.positionals.isEmpty
        ? 'schema.prisma'
        : parsed.positionals.first;
    final loaded = _loadValidatedSchema(schemaPath);
    if (loaded == null) {
      return 1;
    }
    final generator = _workflow.resolveGenerator(
      loaded,
      generatorName: parsed.options['generator'],
    );

    final outputPath = parsed.positionals.length >= 2
        ? File(parsed.positionals[1]).absolute.path
        : generator.outputPath;

    final outputFile = File(outputPath);
    final schemaSource = await File(loaded.filePath).readAsString();

    if (outputFile.existsSync()) {
      final content = ClientGenerator(
        options: _resolveClientGeneratorOptions(
          generator: generator,
          anchorDirectory: outputFile.parent,
        ),
      ).generateClient(loaded.schema, schemaSource: schemaSource);
      final existing = await outputFile.readAsString();
      if (existing == content) {
        _out.writeln('Generated client up to date: ${outputFile.path}');
        return 0;
      }
      await outputFile.parent.create(recursive: true);
      await outputFile.writeAsString(content);
      _out.writeln('Generated client: ${outputFile.path}');
      return 0;
    }

    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsString(
      ClientGenerator(
        options: _resolveClientGeneratorOptions(
          generator: generator,
          anchorDirectory: outputFile.parent,
        ),
      ).generateClient(loaded.schema, schemaSource: schemaSource),
    );
    _out.writeln('Generated client: ${outputFile.path}');
    return 0;
  }

  int _generatePreview(List<String> arguments) {
    final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
    final schemaPath = parsed.positionals.isEmpty
        ? 'schema.prisma'
        : parsed.positionals.first;
    final loaded = _loadValidatedSchema(schemaPath);
    if (loaded == null) {
      return 1;
    }
    final generator = _workflow.resolveGenerator(
      loaded,
      generatorName: parsed.options['generator'],
    );

    _out.write(
      ClientGenerator(
        options: _resolveClientGeneratorOptions(
          generator: generator,
          anchorDirectory: File(schemaPath).absolute.parent,
        ),
      ).generateClient(loaded.schema),
    );
    return 0;
  }

  LoadedSchemaDocument? _loadValidatedSchema(String schemaPath) {
    try {
      return _workflow.loadValidatedSchemaSync(schemaPath);
    } on SchemaValidationException catch (error) {
      for (final issue in error.issues) {
        _err.writeln(issue);
      }
      return null;
    } on SchemaParseException catch (error) {
      _err.writeln(error);
      return null;
    } on Object catch (error) {
      _err.writeln(error);
      return null;
    }
  }

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

  void _printUsage() {
    _out.writeln(
      'Usage: dart run bin/comon_orm.dart <command> [schema-path] [output-path] [--generator <name>]',
    );
    _out.writeln('Commands:');
    _out.writeln('  check             Parse and validate a schema file.');
    _out.writeln('  validate          Alias for check.');
    _out.writeln(
      '  format            Rewrite a schema file into canonical formatting.',
    );
    _out.writeln(
      '  generate          Write generated client code using generator.output when present.',
    );
    _out.writeln('  generate-preview  Print a generated client preview.');
    _out.writeln(
      '  migrate           Delegate migration commands to the adapter package selected from datasource.provider.',
    );
  }
}

_ParsedArguments _parseArguments(
  List<String> arguments, {
  Set<String> supportedOptions = const <String>{},
}) {
  final options = <String, String>{};
  final positionals = <String>[];

  for (var index = 0; index < arguments.length; index++) {
    final token = arguments[index];
    if (!token.startsWith('--')) {
      positionals.add(token);
      continue;
    }

    final name = token.substring(2);
    if (!supportedOptions.contains(name)) {
      throw FormatException('Unknown option --$name');
    }
    if (index + 1 >= arguments.length) {
      throw FormatException('Missing value for --$name');
    }

    options[name] = arguments[index + 1];
    index++;
  }

  return _ParsedArguments(
    options: Map<String, String>.unmodifiable(options),
    positionals: List<String>.unmodifiable(positionals),
  );
}

class _ParsedArguments {
  const _ParsedArguments({required this.options, required this.positionals});

  final Map<String, String> options;
  final List<String> positionals;
}
