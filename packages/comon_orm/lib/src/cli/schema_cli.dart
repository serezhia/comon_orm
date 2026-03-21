import 'dart:io';

import '../codegen/client_generator.dart';
import '../schema/schema_parser.dart';
import '../schema/schema_workflow_web.dart'
    if (dart.library.io) '../schema/schema_workflow.dart';
import 'cli_output.dart';
import 'cli_paths.dart';
import 'generated_client_writer.dart';
import 'migration_cli_dispatcher.dart';

/// Top-level command runner for the `comon_orm` executable.
class ComonOrmCli {
  /// Creates a CLI runner with injectable workflow, dispatcher, and sinks.
  ComonOrmCli({
    SchemaWorkflow workflow = const SchemaWorkflow(),
    MigrationCliDispatcher? migrationDispatcher,
    GeneratedClientWriter clientWriter = const GeneratedClientWriter(),
    StringSink? out,
    StringSink? err,
  }) : _workflow = workflow,
       _migrationDispatcher =
           migrationDispatcher ?? MigrationCliDispatcher(out: out, err: err),
       _clientWriter = clientWriter,
       _out = out ?? stdout,
       _err = err ?? stderr;

  final SchemaWorkflow _workflow;
  final MigrationCliDispatcher _migrationDispatcher;
  final GeneratedClientWriter _clientWriter;
  final StringSink _out;
  final StringSink _err;

  bool get _outAnsiEnabled => sinkSupportsAnsi(_out);
  bool get _errAnsiEnabled => sinkSupportsAnsi(_err);

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
            commandName: 'migrate',
          );
        case 'db':
          return _migrationDispatcher.run(
            arguments.skip(1).toList(growable: false),
            commandName: 'db',
          );
        default:
          _err.writeln(
            cliError('Unknown command: $command', ansiEnabled: _errAnsiEnabled),
          );
          _printUsage();
          return 64;
      }
    } on FormatException catch (error) {
      _err.writeln(cliError(error.message, ansiEnabled: _errAnsiEnabled));
      return 64;
    }
  }

  int _check(List<String> arguments) {
    final parsed = _parseArguments(arguments, supportedOptions: {'schema'});
    final target = _resolveSchemaTarget(parsed);
    final loaded = _loadValidatedSchema(target.schemaPath);
    if (loaded == null) {
      return 1;
    }

    _out.writeln(cliSuccess('Schema is valid.', ansiEnabled: _outAnsiEnabled));
    return 0;
  }

  int _format(List<String> arguments) {
    final parsed = _parseArguments(arguments, supportedOptions: {'schema'});
    final target = _resolveSchemaTarget(parsed);

    try {
      final file = File(target.schemaPath).absolute;
      _workflow.formatSchemaSync(file.path);
      _out.writeln(
        cliSuccess(
          'Formatted schema: ${file.path}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      return 0;
    } on Object catch (error) {
      _err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return 1;
    }
  }

  Future<int> _generate(List<String> arguments) async {
    final parsed = _parseArguments(
      arguments,
      supportedOptions: {'generator', 'schema'},
    );
    final target = _resolveSchemaTarget(parsed);
    final loaded = _loadValidatedSchema(target.schemaPath);
    if (loaded == null) {
      return 1;
    }
    final outputPath = target.remainingPositionals.isNotEmpty
        ? File(target.remainingPositionals.first).absolute.path
        : null;
    final result = await _clientWriter.writeForLoadedSchema(
      loaded,
      generatorName: parsed.options['generator'],
      outputPath: outputPath,
    );
    _out.writeln(
      result.updated
          ? cliSuccess(
              'Generated client: ${result.outputPath}',
              ansiEnabled: _outAnsiEnabled,
            )
          : cliInfo(
              'Generated client up to date: ${result.outputPath}',
              ansiEnabled: _outAnsiEnabled,
            ),
    );
    return 0;
  }

  int _generatePreview(List<String> arguments) {
    final parsed = _parseArguments(
      arguments,
      supportedOptions: {'generator', 'schema'},
    );
    final target = _resolveSchemaTarget(parsed);
    final loaded = _loadValidatedSchema(target.schemaPath);
    if (loaded == null) {
      return 1;
    }
    final generator = _workflow.resolveGenerator(
      loaded,
      generatorName: parsed.options['generator'],
    );

    _out.write(
      ClientGenerator(
        options: resolveClientGeneratorOptions(
          generator: generator,
          anchorDirectory: File(target.schemaPath).absolute.parent,
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
        _err.writeln(cliError('$issue', ansiEnabled: _errAnsiEnabled));
      }
      return null;
    } on SchemaParseException catch (error) {
      _err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return null;
    } on FormatException catch (error) {
      _err.writeln(cliError(error.message, ansiEnabled: _errAnsiEnabled));
      return null;
    } on Object catch (error) {
      _err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return null;
    }
  }

  _SchemaCommandTarget _resolveSchemaTarget(_ParsedArguments parsed) {
    final optionSchema = parsed.options['schema'];
    final positionalSchema = parsed.positionals.isEmpty
        ? null
        : parsed.positionals.first;
    if (optionSchema != null && positionalSchema != null) {
      throw const FormatException(
        'Pass the schema path either positionally or with --schema, not both.',
      );
    }

    final schemaPath = discoverSchemaPath(
      explicitPath: optionSchema ?? positionalSchema,
    );
    final remainingPositionals = optionSchema != null
        ? parsed.positionals
        : parsed.positionals
              .skip(positionalSchema == null ? 0 : 1)
              .toList(growable: false);
    return _SchemaCommandTarget(
      schemaPath: schemaPath,
      remainingPositionals: remainingPositionals,
    );
  }

  void _printUsage() {
    _out.writeln(cliTitle('comon_orm CLI', ansiEnabled: _outAnsiEnabled));
    _out.writeln(
      cliMuted(
        'Usage: dart run bin/comon_orm.dart <command> [schema-path] [output-path] [--schema <path>] [--generator <name>]',
        ansiEnabled: _outAnsiEnabled,
      ),
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
    _out.writeln(
      '  db                Delegate database utility commands such as push to the adapter package selected from datasource.provider.',
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

class _SchemaCommandTarget {
  const _SchemaCommandTarget({
    required this.schemaPath,
    required this.remainingPositionals,
  });

  final String schemaPath;
  final List<String> remainingPositionals;
}
