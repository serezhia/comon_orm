import 'dart:io';

import '../schema/schema_ast.dart';
import '../schema/schema_workflow.dart';
import 'cli_output.dart';
import 'cli_paths.dart';

/// Runs a provider-specific migration CLI for a validated invocation.
typedef MigrationCliDelegate =
    Future<int> Function(MigrationCliInvocation invocation);

/// Resolved migration delegation target for a datasource provider.
class MigrationCliInvocation {
  /// Creates a provider-specific CLI invocation.
  const MigrationCliInvocation({
    required this.provider,
    required this.packageExecutable,
    required this.arguments,
  });

  /// Datasource provider selected from the schema.
  final String provider;

  /// `dart run` target used to launch the provider CLI.
  final String packageExecutable;

  /// Original migration arguments forwarded to the provider CLI.
  final List<String> arguments;
}

/// Validates a schema and delegates `migrate` commands to the right package.
class MigrationCliDispatcher {
  /// Creates a migration dispatcher.
  MigrationCliDispatcher({
    SchemaWorkflow workflow = const SchemaWorkflow(),
    MigrationCliDelegate? delegate,
    StringSink? out,
    StringSink? err,
  }) : _workflow = workflow,
       _delegate = delegate ?? _runProviderCli,
       _out = out ?? stdout,
       _err = err ?? stderr;

  final SchemaWorkflow _workflow;
  final MigrationCliDelegate _delegate;
  final StringSink _out;
  final StringSink _err;

  bool get _outAnsiEnabled => sinkSupportsAnsi(_out);
  bool get _errAnsiEnabled => sinkSupportsAnsi(_err);

  /// Dispatches [arguments] to the provider-specific migration executable.
  Future<int> run(
    List<String> arguments, {
    String commandName = 'migrate',
  }) async {
    if (arguments.isEmpty ||
        arguments.contains('--help') ||
        arguments.contains('-h')) {
      _writeUsage(commandName: commandName);
      return 0;
    }

    try {
      final schemaPath = discoverSchemaPath(
        explicitPath: _readOption(arguments, 'schema'),
      );
      final datasourceName = _readOption(arguments, 'datasource');
      final loaded = _workflow.loadValidatedSchemaSync(schemaPath);
      final provider = _resolveProvider(
        loaded.schema,
        datasourceName: datasourceName,
      );
      final packageExecutable = _packageExecutableFor(provider);
      final forwardedArguments = _upsertOption(arguments, 'schema', schemaPath);

      return _delegate(
        MigrationCliInvocation(
          provider: provider,
          packageExecutable: packageExecutable,
          arguments: List<String>.unmodifiable(forwardedArguments),
        ),
      );
    } on SchemaValidationException catch (error) {
      for (final issue in error.issues) {
        _err.writeln(cliError('$issue', ansiEnabled: _errAnsiEnabled));
      }
      return 1;
    } on FormatException catch (error) {
      _err.writeln(cliError(error.message, ansiEnabled: _errAnsiEnabled));
      return 2;
    } on Object catch (error) {
      _err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return 1;
    }
  }

  void _writeUsage({required String commandName}) {
    _out.writeln(
      cliTitle('comon_orm $commandName', ansiEnabled: _outAnsiEnabled),
    );
    _out.writeln(
      cliMuted(
        'Usage: comon_orm $commandName <command> [options]',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    _out.writeln('Commands:');
    switch (commandName) {
      case 'db':
        _out.writeln(
          '  push      Push the current schema without creating migration history.',
        );
      case 'migrate':
        _out.writeln(
          '  diff      Compare schema sources and print or write an SQL diff.',
        );
        _out.writeln(
          '  dev       Create and apply a local migration, then regenerate the client.',
        );
        _out.writeln(
          '  deploy    Apply reviewed local migrations to the target database.',
        );
        _out.writeln(
          '  rollback  Revert to a recorded schema snapshot for recovery scenarios.',
        );
        _out.writeln(
          '  reset     Reset the database from the schema and regenerate the client.',
        );
        _out.writeln(
          '  resolve   Mark migrations applied or rolled back in migration history.',
        );
        _out.writeln(
          '  status    Compare local migration artifacts with database history.',
        );
    }
    _out.writeln('Options:');
    _out.writeln(
      '  --schema <path>        Schema file to inspect before delegating. Defaults to auto-discovery: prisma/schema.prisma, schema.prisma.',
    );
    _out.writeln(
      '  --datasource <name>    Select datasource when the schema declares multiple datasource blocks.',
    );
    _out.writeln(
      '  Remaining options are forwarded unchanged to the provider-specific CLI.',
    );
  }

  String? _readOption(List<String> arguments, String name) {
    final token = '--$name';
    for (var index = 0; index < arguments.length; index++) {
      if (arguments[index] != token) {
        continue;
      }
      if (index + 1 >= arguments.length) {
        throw FormatException('Missing value for $token');
      }
      return arguments[index + 1];
    }
    return null;
  }

  List<String> _upsertOption(
    List<String> arguments,
    String name,
    String value,
  ) {
    final token = '--$name';
    final normalized = <String>[];
    var replaced = false;

    for (var index = 0; index < arguments.length; index++) {
      final current = arguments[index];
      if (current != token) {
        normalized.add(current);
        continue;
      }

      if (index + 1 >= arguments.length) {
        throw FormatException('Missing value for $token');
      }

      if (!replaced) {
        normalized
          ..add(token)
          ..add(value);
        replaced = true;
      }
      index++;
    }

    if (!replaced) {
      normalized
        ..add(token)
        ..add(value);
    }
    return normalized;
  }

  String _resolveProvider(SchemaDocument schema, {String? datasourceName}) {
    final datasource = _selectDatasource(schema, datasourceName);
    if (datasource == null) {
      throw const FormatException(
        'Schema does not declare a datasource block, so migration provider cannot be selected.',
      );
    }

    return _resolveScalarValue(
      datasource.properties['provider'],
      propertyName: 'datasource ${datasource.name}.provider',
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

    throw const FormatException(
      'Schema declares multiple datasource blocks. Pass --datasource <name>.',
    );
  }

  String _resolveScalarValue(String? rawValue, {required String propertyName}) {
    if (rawValue == null || rawValue.trim().isEmpty) {
      throw FormatException('$propertyName must not be empty.');
    }

    final trimmed = rawValue.trim();
    final envMatch = RegExp(r'''^env\((['"])(.+)\1\)$''').firstMatch(trimmed);
    if (envMatch != null) {
      final variableName = envMatch.group(2)!;
      final value = Platform.environment[variableName];
      if (value == null || value.isEmpty) {
        throw FormatException(
          'Environment variable "$variableName" referenced by $propertyName is not set.',
        );
      }
      return value;
    }

    return _stripQuotes(trimmed);
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

  String _packageExecutableFor(String provider) {
    return switch (provider) {
      'postgresql' => 'comon_orm_postgresql:comon_orm_postgresql',
      'sqlite' => 'comon_orm_sqlite:comon_orm_sqlite',
      _ => throw FormatException(
        'Unsupported datasource provider "$provider" for migrations. Add a dispatcher mapping for this provider first.',
      ),
    };
  }
}

Future<int> _runProviderCli(MigrationCliInvocation invocation) async {
  final process = await Process.start(
    Platform.resolvedExecutable,
    <String>['run', invocation.packageExecutable, ...invocation.arguments],
    mode: ProcessStartMode.inheritStdio,
    workingDirectory: Directory.current.path,
  );
  return process.exitCode;
}
