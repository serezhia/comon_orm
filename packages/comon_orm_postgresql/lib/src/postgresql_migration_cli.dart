import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_migration_service.dart';

const _workflow = SchemaWorkflow();

/// Opens a PostgreSQL session used by the migration CLI.
typedef PostgresqlCliConnectionOpener =
    Future<PostgresqlCliSession> Function(String connectionUrl);

/// Open PostgreSQL session and its close hook.
class PostgresqlCliSession {
  /// Creates a CLI session wrapper.
  const PostgresqlCliSession({required this.executor, required this.close});

  /// Session executor used by the migration commands.
  final pg.SessionExecutor executor;

  /// Closes the underlying connection or pool.
  final Future<void> Function() close;
}

/// Command-line entry point for PostgreSQL migration workflows.
class PostgresqlMigrationCli {
  /// Creates a PostgreSQL migration CLI.
  PostgresqlMigrationCli({
    PostgresqlMigrationService? service,
    PostgresqlCliConnectionOpener? openConnection,
    StringSink? out,
    StringSink? err,
  }) : service = service ?? const PostgresqlMigrationService(),
       openConnection = openConnection ?? _defaultOpenConnection,
       out = out ?? stdout,
       err = err ?? stderr;

  /// Migration service used for planning and applying changes.
  final PostgresqlMigrationService service;

  /// Connection opener used by CLI commands.
  final PostgresqlCliConnectionOpener openConnection;

  /// Standard output sink.
  final StringSink out;

  /// Standard error sink.
  final StringSink err;

  /// Runs a PostgreSQL migration command.
  Future<int> run(List<String> args) async {
    if (args.isEmpty || args.contains('--help') || args.contains('-h')) {
      _writeUsage();
      return 0;
    }

    final command = args.first;
    final options = _parseOptions(args.skip(1).toList(growable: false));

    try {
      return switch (command) {
        'diff' => _runDiff(options),
        'apply' => _runApply(options),
        'rollback' => _runRollback(options),
        'history' => _runHistory(options),
        'status' => _runStatus(options),
        _ => Future<int>.value(_unknownCommand(command)),
      };
    } on FormatException catch (error) {
      err.writeln(error.message);
      return 2;
    } on Object catch (error) {
      err.writeln(error);
      return 1;
    }
  }

  Future<int> _runDiff(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final outputPath = _requireOption(options, 'out');

    final connection = await openConnection(connectionUrl);
    try {
      final draft = await service.draftFromDatabase(
        executor: connection.executor,
        target: loaded.schema,
        migrationName: migrationName,
      );
      final directory = service.writeDraft(
        draft: draft,
        directoryPath: outputPath,
      );

      out.writeln('Migration draft written: ${directory.path}');
      out.writeln('Statements: ${draft.plan.statements.length}');
      out.writeln('Warnings: ${draft.plan.warnings.length}');
      _writeWarnings(draft.plan.warnings);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runApply(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final allowWarnings = options['allow-warnings'] == 'true';

    final connection = await openConnection(connectionUrl);
    try {
      final result = await service.applySchema(
        executor: connection.executor,
        target: loaded.schema,
        migrationName: migrationName,
        allowWarnings: allowWarnings,
      );

      out.writeln('Applied: ${result.applied}');
      out.writeln('Statements: ${result.plan.statements.length}');
      out.writeln('Warnings: ${result.plan.warnings.length}');
      _writeWarnings(result.plan.warnings);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runRollback(Map<String, String> options) async {
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrlFromSchema(options);
    final migrationsPath = _requireOption(options, 'from');
    final migrationName = options['name'];
    final rollbackName = options['rollback-name'];
    final allowWarnings = options['allow-warnings'] == 'true';

    final connection = await openConnection(connectionUrl);
    try {
      final result = await service.rollbackMigration(
        executor: connection.executor,
        migrationsDirectory: migrationsPath,
        migrationName: migrationName,
        rollbackName: rollbackName,
        allowWarnings: allowWarnings,
      );

      out.writeln('Rolled back: ${result.rolledBack}');
      out.writeln('Target migration: ${result.targetMigrationName}');
      out.writeln('Statements: ${result.statementCount}');
      out.writeln('Warnings: ${result.warnings.length}');
      _writeWarnings(result.warnings);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runStatus(Map<String, String> options) async {
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrlFromSchema(options);
    final migrationsPath = options['from'] ?? 'prisma/migrations';

    final connection = await openConnection(connectionUrl);
    try {
      final status = await service.status(
        executor: connection.executor,
        migrationsDirectory: migrationsPath,
      );
      out.writeln('Active migrations: ${status.activeMigrationCount}');
      out.writeln('Local migrations: ${status.localMigrationCount}');
      out.writeln('Issues: ${status.issues.length}');
      for (final issue in status.issues) {
        out.writeln('${issue.code} | ${issue.message}');
      }
      return status.isClean ? 0 : 1;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runHistory(Map<String, String> options) async {
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrlFromSchema(options);
    final connection = await openConnection(connectionUrl);
    try {
      final history = await service.runner.loadHistory(connection.executor);
      if (history.isEmpty) {
        out.writeln('No migrations applied.');
        return 0;
      }

      for (final record in history) {
        out.writeln(
          '${record.kind.name} | ${record.name} | ${record.appliedAt.toIso8601String()} | ${record.statementCount}${record.targetName == null ? '' : ' | ${record.targetName}'}',
        );
      }
      return 0;
    } finally {
      await connection.close();
    }
  }

  int _unknownCommand(String command) {
    err.writeln('Unknown command: $command');
    _writeUsage();
    return 2;
  }

  LoadedSchemaDocument _loadSchema(String schemaPath) {
    return _workflow.loadValidatedSchemaSync(schemaPath);
  }

  String _requireOption(Map<String, String> options, String name) {
    final value = options[name];
    if (value == null || value.isEmpty) {
      throw FormatException('Missing required option --$name');
    }
    return value;
  }

  Map<String, String> _parseOptions(List<String> args) {
    final options = <String, String>{};
    for (var index = 0; index < args.length; index++) {
      final token = args[index];
      if (!token.startsWith('--')) {
        throw FormatException('Unexpected argument: $token');
      }

      final name = token.substring(2);
      if (name == 'allow-warnings') {
        options[name] = 'true';
        continue;
      }

      if (index + 1 >= args.length) {
        throw FormatException('Missing value for --$name');
      }

      options[name] = args[index + 1];
      index++;
    }
    return options;
  }

  void _writeUsage() {
    out.writeln('Usage: comon_orm_postgresql <command> [options]');
    out.writeln('Commands:');
    out.writeln(
      '  diff [--url <connection>] [--schema <path>] [--datasource <name>] --name <migration> --out <dir>',
    );
    out.writeln(
      '  apply [--url <connection>] [--schema <path>] [--datasource <name>] --name <migration> [--allow-warnings]',
    );
    out.writeln(
      '  rollback [--url <connection>] [--schema <path>] [--datasource <name>] --from <dir> [--name <migration>] [--rollback-name <name>] [--allow-warnings]',
    );
    out.writeln(
      '  history [--url <connection>] [--schema <path>] [--datasource <name>]',
    );
    out.writeln(
      '  status [--url <connection>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
  }

  void _writeWarnings(List<String> warnings) {
    for (final warning in warnings) {
      out.writeln('Warning: $warning');
    }
  }

  String _resolveConnectionUrlFromSchema(Map<String, String> options) {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    return _resolveConnectionUrl(options, loaded);
  }

  String _resolveConnectionUrl(
    Map<String, String> options,
    LoadedSchemaDocument loaded,
  ) {
    return _workflow
        .resolveDatasource(
          loaded,
          datasourceName: options['datasource'],
          expectedProvider: 'postgresql',
        )
        .url;
  }
}

Future<PostgresqlCliSession> _defaultOpenConnection(
  String connectionUrl,
) async {
  final connection = await pg.Connection.openFromUrl(connectionUrl);
  return PostgresqlCliSession(executor: connection, close: connection.close);
}
