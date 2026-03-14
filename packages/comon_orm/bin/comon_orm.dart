import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm/src/cli/migration_cli_dispatcher.dart';

const _workflow = SchemaWorkflow();
final _migrationDispatcher = MigrationCliDispatcher();

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    _printUsage();
    exitCode = 64;
    return;
  }

  try {
    final command = arguments.first;
    switch (command) {
      case 'check':
      case 'validate':
        await _check(arguments.skip(1).toList(growable: false));
        return;
      case 'format':
        await _format(arguments.skip(1).toList(growable: false));
        return;
      case 'generate':
        await _generate(arguments.skip(1).toList(growable: false));
        return;
      case 'generate-preview':
        await _generatePreview(arguments.skip(1).toList(growable: false));
        return;
      case 'migrate':
        exitCode = await _migrationDispatcher.run(
          arguments.skip(1).toList(growable: false),
        );
        return;
      default:
        stderr.writeln('Unknown command: $command');
        _printUsage();
        exitCode = 64;
        return;
    }
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  }
}

Future<void> _check(List<String> arguments) async {
  final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
  final loaded = await _loadValidatedSchema(
    parsed.positionals.isEmpty ? 'schema.prisma' : parsed.positionals.first,
  );
  if (loaded == null) {
    return;
  }

  stdout.writeln('Schema is valid.');
}

Future<void> _format(List<String> arguments) async {
  final parsed = _parseArguments(arguments);
  final schemaPath = parsed.positionals.isEmpty
      ? 'schema.prisma'
      : parsed.positionals.first;

  try {
    final file = File(schemaPath).absolute;
    await _workflow.formatSchema(file.path);
    stdout.writeln('Formatted schema: ${file.path}');
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
  }
}

Future<void> _generate(List<String> arguments) async {
  final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
  final schemaPath = parsed.positionals.isEmpty
      ? 'schema.prisma'
      : parsed.positionals.first;
  final loaded = await _loadValidatedSchema(schemaPath);
  if (loaded == null) {
    return;
  }

  final outputPath = parsed.positionals.length >= 2
      ? File(parsed.positionals[1]).absolute.path
      : _workflow
            .resolveGenerator(
              loaded,
              generatorName: parsed.options['generator'],
            )
            .outputPath;

  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(
    const ClientGenerator().generateClient(loaded.schema),
  );
  stdout.writeln('Generated client: ${outputFile.path}');
}

Future<LoadedSchemaDocument?> _loadValidatedSchema(String schemaPath) async {
  try {
    return await _workflow.loadValidatedSchema(schemaPath);
  } on SchemaValidationException catch (error) {
    for (final issue in error.issues) {
      stderr.writeln(issue);
    }
    exitCode = 1;
    return null;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 1;
    return null;
  }
}

Future<void> _generatePreview(List<String> arguments) async {
  final parsed = _parseArguments(arguments, supportedOptions: {'generator'});
  final loaded = await _loadValidatedSchema(
    parsed.positionals.isEmpty ? 'schema.prisma' : parsed.positionals.first,
  );
  if (loaded == null) {
    return;
  }

  stdout.write(const ClientGenerator().generateClient(loaded.schema));
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run bin/comon_orm.dart <command> [schema-path] [output-path] [--generator <name>]',
  );
  stdout.writeln('Commands:');
  stdout.writeln('  check             Parse and validate a schema file.');
  stdout.writeln('  validate          Alias for check.');
  stdout.writeln(
    '  format            Rewrite a schema file into canonical formatting.',
  );
  stdout.writeln(
    '  generate          Write generated client code using generator.output when present.',
  );
  stdout.writeln('  generate-preview  Print a generated client preview.');
  stdout.writeln(
    '  migrate           Delegate migration commands to the adapter package selected from datasource.provider.',
  );
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
