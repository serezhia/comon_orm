import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_migration_service.dart';

const _workflow = SchemaWorkflow();

/// Command-line entry point for SQLite migration workflows.
class SqliteMigrationCli {
  /// Creates a SQLite migration CLI.
  SqliteMigrationCli({
    SqliteMigrationService? service,
    StringSink? out,
    StringSink? err,
  }) : service = service ?? const SqliteMigrationService(),
       out = out ?? stdout,
       err = err ?? stderr;

  /// Migration service used for planning and applying changes.
  final SqliteMigrationService service;

  /// Standard output sink.
  final StringSink out;

  /// Standard error sink.
  final StringSink err;

  /// Runs a SQLite migration command.
  int run(List<String> args) {
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
        _ => _unknownCommand(command),
      };
    } on FormatException catch (error) {
      err.writeln(error.message);
      return 2;
    } on Object catch (error) {
      err.writeln(error);
      return 1;
    }
  }

  int _runDiff(Map<String, String> options) {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final outputPath = _requireOption(options, 'out');

    final database = _openDatabase(databasePath);
    try {
      final draft = service.draftFromDatabase(
        database: database,
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
      database.dispose();
    }
  }

  int _runApply(Map<String, String> options) {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final allowWarnings = options['allow-warnings'] == 'true';

    final database = _openDatabase(databasePath);
    try {
      final result = service.applySchema(
        database: database,
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
      database.dispose();
    }
  }

  int _runHistory(Map<String, String> options) {
    final databasePath =
        options['db'] ?? _resolveDatabasePathFromSchema(options);
    final database = _openDatabase(databasePath);
    try {
      final history = service.runner.loadHistory(database);
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
      database.dispose();
    }
  }

  int _runRollback(Map<String, String> options) {
    final databasePath =
        options['db'] ?? _resolveDatabasePathFromSchema(options);
    final migrationsPath = _requireOption(options, 'from');
    final migrationName = options['name'];
    final rollbackName = options['rollback-name'];
    final allowWarnings = options['allow-warnings'] == 'true';

    final database = _openDatabase(databasePath);
    try {
      final result = service.rollbackMigration(
        database: database,
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
      database.dispose();
    }
  }

  int _runStatus(Map<String, String> options) {
    final databasePath =
        options['db'] ?? _resolveDatabasePathFromSchema(options);
    final migrationsPath = options['from'] ?? 'prisma/migrations';
    final database = _openDatabase(databasePath);
    try {
      final status = service.status(
        database: database,
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
      database.dispose();
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

  sqlite.Database _openDatabase(String databasePath) {
    if (databasePath == ':memory:') {
      return sqlite.sqlite3.openInMemory();
    }
    return sqlite.sqlite3.open(databasePath);
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
    out.writeln('Usage: comon_orm_sqlite <command> [options]');
    out.writeln('Commands:');
    out.writeln(
      '  diff [--db <path>] [--schema <path>] [--datasource <name>] --name <migration> --out <dir>',
    );
    out.writeln(
      '  apply [--db <path>] [--schema <path>] [--datasource <name>] --name <migration> [--allow-warnings]',
    );
    out.writeln(
      '  rollback [--db <path>] [--schema <path>] [--datasource <name>] --from <dir> [--name <migration>] [--rollback-name <name>] [--allow-warnings]',
    );
    out.writeln(
      '  history [--db <path>] [--schema <path>] [--datasource <name>]',
    );
    out.writeln(
      '  status [--db <path>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
  }

  void _writeWarnings(List<String> warnings) {
    for (final warning in warnings) {
      out.writeln('Warning: $warning');
    }
  }

  String _resolveDatabasePathFromSchema(Map<String, String> options) {
    final loaded = _loadSchema(options['schema'] ?? 'schema.prisma');
    return _resolveDatabasePath(options, loaded);
  }

  String _resolveDatabasePath(
    Map<String, String> options,
    LoadedSchemaDocument loaded,
  ) {
    return _workflow
        .resolveDatasource(
          loaded,
          datasourceName: options['datasource'],
          expectedProvider: 'sqlite',
        )
        .url;
  }
}
