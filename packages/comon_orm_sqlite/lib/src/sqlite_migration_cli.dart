import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'sqlite_migration_runner.dart';
import 'sqlite_migration_service.dart';

const _workflow = SchemaWorkflow();

/// Command-line entry point for SQLite migration workflows.
class SqliteMigrationCli {
  /// Creates a SQLite migration CLI.
  SqliteMigrationCli({
    SqliteMigrationService? service,
    CliReadLine? readLine,
    bool? interactiveInput,
    GeneratedClientWriter? clientWriter,
    StringSink? out,
    StringSink? err,
  }) : service = service ?? const SqliteMigrationService(),
       clientWriter = clientWriter ?? const GeneratedClientWriter(),
       out = out ?? stdout,
       err = err ?? stderr,
       prompter = CliPrompter(
         out: out ?? stdout,
         readLine: readLine,
         interactive: interactiveInput,
       );

  /// Migration service used for planning and applying changes.
  final SqliteMigrationService service;

  /// Writes generated clients after schema-changing workflows.
  final GeneratedClientWriter clientWriter;

  /// Standard output sink.
  final StringSink out;

  /// Standard error sink.
  final StringSink err;

  /// Interactive prompt helper.
  final CliPrompter prompter;

  bool get _outAnsiEnabled => sinkSupportsAnsi(out);
  bool get _errAnsiEnabled => sinkSupportsAnsi(err);

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
        'deploy' => _runDeploy(options),
        'dev' => _runDev(options),
        'rollback' => _runRollback(options),
        'reset' => _runReset(options),
        'resolve' => _runResolve(options),
        'history' => _runHistory(options),
        'push' => _runPush(options),
        'status' => _runStatus(options),
        _ => _unknownCommand(command),
      };
    } on FormatException catch (error) {
      err.writeln(cliError(error.message, ansiEnabled: _errAnsiEnabled));
      return 2;
    } on Object catch (error) {
      err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return 1;
    }
  }

  int _runDiff(Map<String, String> options) {
    if (_usesEnhancedDiff(options)) {
      return _runEnhancedDiff(options);
    }

    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final outputPath =
        options['out'] ?? defaultMigrationsDirectory(loaded.filePath);

    out.writeln(
      cliWarning(
        '`migrate diff --name` is deprecated. Use `migrate dev --name` instead.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );

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

      out.writeln(
        cliSuccess(
          'Migration draft written: ${directory.path}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Statements: ${draft.plan.statements.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Warnings: ${draft.plan.warnings.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      _writeWarnings(draft.plan.warnings);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runEnhancedDiff(Map<String, String> options) {
    final needsDatabase =
        _flag(options, 'from-database') || _flag(options, 'to-database');
    final loaded = needsDatabase || options.containsKey('schema')
        ? _loadSchema(options['schema'])
        : null;
    final database = needsDatabase
        ? _openDatabase(options['db'] ?? _resolveDatabasePath(options, loaded!))
        : null;

    try {
      final fromSchema = _resolveDiffSchemaSource(
        options,
        prefix: 'from',
        loaded: loaded,
        database: database,
      );
      final toSchema = _resolveDiffSchemaSource(
        options,
        prefix: 'to',
        loaded: loaded,
        database: database,
      );
      final plan = service.planner.plan(from: fromSchema, to: toSchema);
      final scriptMode = _flag(options, 'script');
      final output = scriptMode
          ? buildMigrationSqlScript(plan)
          : _renderDiffSummary(
              isEmpty: plan.isEmpty,
              statements: plan.statements,
              warnings: plan.warnings,
              requiresRebuild: plan.requiresRebuild,
            );
      _writeDiffOutput(output, options['output']);
      if (_flag(options, 'exit-code') && !plan.isEmpty) {
        return 2;
      }
      return 0;
    } finally {
      database?.close();
    }
  }

  int _runApply(Map<String, String> options) {
    out.writeln(
      cliWarning(
        '`migrate apply` is a legacy command. Prefer `migrate dev` or `migrate deploy`.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    final loaded = _loadSchema(options['schema']);
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

      out.writeln(
        cliSuccess('Applied: ${result.applied}', ansiEnabled: _outAnsiEnabled),
      );
      out.writeln(
        cliInfo(
          'Statements: ${result.plan.statements.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Warnings: ${result.plan.warnings.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      _writeWarnings(result.plan.warnings);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runHistory(Map<String, String> options) {
    out.writeln(
      cliWarning(
        '`migrate history` is a legacy command. Prefer `migrate status`.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final database = _openDatabase(databasePath);
    try {
      final history = service.runner.loadHistory(database);
      if (history.isEmpty) {
        out.writeln(
          cliInfo('No migrations applied.', ansiEnabled: _outAnsiEnabled),
        );
        return 0;
      }

      for (final record in history) {
        out.writeln(
          '${record.kind.name} | ${record.name} | ${record.appliedAt.toIso8601String()} | ${record.statementCount}${record.targetName == null ? '' : ' | ${record.targetName}'}',
        );
      }
      return 0;
    } finally {
      database.close();
    }
  }

  int _runRollback(Map<String, String> options) {
    out.writeln(
      cliWarning(
        '`migrate rollback` is a legacy command. Prefer `migrate resolve --rolled-back` and a forward fix when possible.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationsPath =
        options['from'] ?? defaultMigrationsDirectory(loaded.filePath);
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

      out.writeln(
        cliSuccess(
          'Rolled back: ${result.rolledBack}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Target migration: ${result.targetMigrationName}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Statements: ${result.statementCount}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Warnings: ${result.warnings.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      _writeWarnings(result.warnings);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runStatus(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationsPath =
        options['from'] ?? defaultMigrationsDirectory(loaded.filePath);
    final database = _openDatabase(databasePath);
    try {
      final status = service.status(
        database: database,
        migrationsDirectory: migrationsPath,
      );
      out.writeln(
        cliInfo(
          'Active migrations: ${status.activeMigrationCount}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Local migrations: ${status.localMigrationCount}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      out.writeln(
        cliInfo(
          'Issues: ${status.issues.length}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      for (final issue in status.issues) {
        out.writeln(
          cliWarning(
            '${issue.code} | ${issue.message}',
            ansiEnabled: _outAnsiEnabled,
          ),
        );
      }
      return status.isClean ? 0 : 1;
    } finally {
      database.close();
    }
  }

  int _runDeploy(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationsPath = _resolveMigrationsDirectory(options, loaded);
    final database = _openDatabase(databasePath);
    try {
      final result = service.deployMigrations(
        database: database,
        migrationsDirectory: migrationsPath,
      );
      _writeDeploySummary(result, migrationsPath: migrationsPath);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runDev(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationsPath = _resolveMigrationsDirectory(options, loaded);
    final createOnly = _flag(options, 'create-only');
    final database = _openDatabase(databasePath);

    try {
      final deployResult = service.deployMigrations(
        database: database,
        migrationsDirectory: migrationsPath,
      );
      if (deployResult.appliedAny) {
        _writeDeploySummary(deployResult, migrationsPath: migrationsPath);
      }

      final driftMessage = _detectDrift(database);
      if (driftMessage != null) {
        err.writeln(cliError(driftMessage, ansiEnabled: _errAnsiEnabled));
        err.writeln(
          cliWarning(
            'Run `migrate reset` to realign the database before creating a new migration.',
            ansiEnabled: _errAnsiEnabled,
          ),
        );
        return 1;
      }

      final status = service.status(
        database: database,
        migrationsDirectory: migrationsPath,
      );
      final blockingIssues = status.issues
          .where((issue) => issue.code != 'local-migration-not-applied')
          .toList(growable: false);
      if (blockingIssues.isNotEmpty) {
        for (final issue in blockingIssues) {
          err.writeln(cliError(issue.message, ansiEnabled: _errAnsiEnabled));
        }
        err.writeln(
          cliWarning(
            'Migration history drift detected. Resolve it or run migrate reset before migrate dev.',
            ansiEnabled: _errAnsiEnabled,
          ),
        );
        return 1;
      }

      var migrationName = options['name'];
      var draft = service.draftFromDatabase(
        database: database,
        target: loaded.schema,
        migrationName: migrationName ?? '__pending__',
      );
      if (draft.plan.isEmpty) {
        out.writeln(
          cliSuccess(
            'Already in sync, no schema changes detected.',
            ansiEnabled: _outAnsiEnabled,
          ),
        );
        return 0;
      }

      migrationName ??= prompter.promptRequired(
        'Migration name',
        errorMessage:
            'Missing migration name. Pass --name <migration> when stdin is not interactive.',
      );
      if (draft.name != migrationName) {
        draft = service.draftFromDatabase(
          database: database,
          target: loaded.schema,
          migrationName: migrationName,
        );
      }

      if (draft.plan.warnings.isNotEmpty &&
          !prompter.confirm(
            'Apply this migration despite warnings?',
            defaultValue: false,
          )) {
        out.writeln(
          cliWarning(
            'Migration creation cancelled.',
            ansiEnabled: _outAnsiEnabled,
          ),
        );
        return 1;
      }

      final directory = service.writeDraft(
        draft: draft,
        directoryPath: migrationsPath,
      );
      out.writeln(
        cliSuccess(
          'Migration draft written: ${directory.path}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      _writeWarnings(draft.plan.warnings);

      if (createOnly) {
        return 0;
      }

      final result = service.applySchema(
        database: database,
        target: loaded.schema,
        migrationName: migrationName,
        allowWarnings: draft.plan.warnings.isNotEmpty,
      );
      out.writeln(
        cliSuccess('Applied: ${result.applied}', ansiEnabled: _outAnsiEnabled),
      );
      final generated = clientWriter.writeForLoadedSchemaSync(loaded);
      _writeGeneratedClientSummary(generated);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runReset(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final migrationsPath = _resolveMigrationsDirectory(options, loaded);
    final force = _flag(options, 'force');
    if (!force &&
        !prompter.confirm(
          'Are you sure you want to reset your database? All data will be lost.',
          defaultValue: false,
        )) {
      out.writeln(cliWarning('Reset cancelled.', ansiEnabled: _outAnsiEnabled));
      return 1;
    }

    final database = _resetDatabase(databasePath);
    try {
      final result = service.deployMigrations(
        database: database,
        migrationsDirectory: migrationsPath,
      );
      _writeDeploySummary(result, migrationsPath: migrationsPath);
      final generated = clientWriter.writeForLoadedSchemaSync(loaded);
      _writeGeneratedClientSummary(generated);
      return 0;
    } finally {
      database.close();
    }
  }

  int _runResolve(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final appliedMigration = options['applied'];
    final rolledBackMigration = options['rolled-back'];
    if ((appliedMigration == null) == (rolledBackMigration == null)) {
      throw const FormatException(
        'Pass exactly one of --applied <migration> or --rolled-back <migration>.',
      );
    }

    final database = _openDatabase(databasePath);
    try {
      final result = appliedMigration != null
          ? service.resolveApplied(
              database: database,
              migrationsDirectory: _resolveMigrationsDirectory(options, loaded),
              migrationName: appliedMigration,
            )
          : service.resolveRolledBack(
              database: database,
              migrationName: rolledBackMigration!,
            );
      out.writeln(
        result.changed
            ? cliSuccess(
                'Migration ${result.migrationName} has been marked as ${result.action}.',
                ansiEnabled: _outAnsiEnabled,
              )
            : cliInfo(
                'Migration ${result.migrationName} was already marked as ${result.action}.',
                ansiEnabled: _outAnsiEnabled,
              ),
      );
      return 0;
    } finally {
      database.close();
    }
  }

  int _runPush(Map<String, String> options) {
    final loaded = _loadSchema(options['schema']);
    final databasePath = options['db'] ?? _resolveDatabasePath(options, loaded);
    final acceptDataLoss = _flag(options, 'accept-data-loss');
    final forceReset = _flag(options, 'force-reset');
    final database = forceReset
        ? _resetDatabase(databasePath)
        : _openDatabase(databasePath);
    try {
      final result = service.pushSchema(
        database: database,
        target: loaded.schema,
        allowWarnings: acceptDataLoss,
      );
      if (!result.applied && result.plan.warnings.isEmpty) {
        out.writeln(
          cliSuccess(
            'Your database is already in sync with your Prisma schema.',
            ansiEnabled: _outAnsiEnabled,
          ),
        );
        return 0;
      }

      out.writeln(
        cliSuccess(
          'Your database is now in sync with your Prisma schema.',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      _writeWarnings(result.plan.warnings);
      return 0;
    } finally {
      database.close();
    }
  }

  int _unknownCommand(String command) {
    err.writeln(
      cliError('Unknown command: $command', ansiEnabled: _errAnsiEnabled),
    );
    _writeUsage();
    return 2;
  }

  LoadedSchemaDocument _loadSchema(String? schemaPath) {
    return _workflow.loadValidatedSchemaSync(
      discoverSchemaPath(explicitPath: schemaPath),
    );
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
    const aliases = <String, String>{
      '-n': 'name',
      '-f': 'force',
      '-o': 'output',
    };
    const booleanOptions = <String>{
      'allow-warnings',
      'create-only',
      'accept-data-loss',
      'force-reset',
      'force',
      'script',
      'exit-code',
      'from-empty',
      'to-empty',
      'from-database',
      'to-database',
    };

    final options = <String, String>{};
    for (var index = 0; index < args.length; index++) {
      final token = args[index];
      final normalizedName =
          aliases[token] ??
          (token.startsWith('--') ? token.substring(2) : null);
      if (normalizedName == null) {
        throw FormatException('Unexpected argument: $token');
      }

      if (booleanOptions.contains(normalizedName)) {
        options[normalizedName] = 'true';
        continue;
      }

      if (index + 1 >= args.length) {
        throw FormatException(
          'Missing value for ${token.startsWith('--') ? token : '--$normalizedName'}',
        );
      }

      options[normalizedName] = args[index + 1];
      index++;
    }
    return options;
  }

  void _writeUsage() {
    out.writeln(
      cliTitle('comon_orm_sqlite migrations', ansiEnabled: _outAnsiEnabled),
    );
    out.writeln(
      cliMuted(
        'Usage: comon_orm_sqlite <command> [options]',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    out.writeln('Commands:');
    out.writeln(
      '  diff [--db <path>] [--schema <path>] [--datasource <name>] --name <migration> [--out <dir>]',
    );
    out.writeln(
      '  dev [--db <path>] [--schema <path>] [--datasource <name>] [--name <migration>] [--create-only]',
    );
    out.writeln(
      '  deploy [--db <path>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
    out.writeln(
      '  apply [--db <path>] [--schema <path>] [--datasource <name>] --name <migration> [--allow-warnings]',
    );
    out.writeln(
      '  rollback [--db <path>] [--schema <path>] [--datasource <name>] [--from <dir>] [--name <migration>] [--rollback-name <name>] [--allow-warnings]',
    );
    out.writeln(
      '  history [--db <path>] [--schema <path>] [--datasource <name>]',
    );
    out.writeln(
      '  reset [--db <path>] [--schema <path>] [--datasource <name>] [--from <dir>] [--force]',
    );
    out.writeln(
      '  resolve [--db <path>] [--schema <path>] [--datasource <name>] (--applied <migration> | --rolled-back <migration>) [--from <dir>]',
    );
    out.writeln(
      '  push [--db <path>] [--schema <path>] [--datasource <name>] [--accept-data-loss] [--force-reset]',
    );
    out.writeln(
      '  status [--db <path>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
  }

  void _writeWarnings(List<String> warnings) {
    for (final warning in warnings) {
      out.writeln(cliWarning(warning, ansiEnabled: _outAnsiEnabled));
    }
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

  bool _flag(Map<String, String> options, String name) {
    return options[name] == 'true';
  }

  bool _usesEnhancedDiff(Map<String, String> options) {
    const sourceKeys = <String>{
      'from-empty',
      'from-schema',
      'from-database',
      'from-migrations',
      'to-empty',
      'to-schema',
      'to-database',
      'to-migrations',
    };
    return options.keys.any(sourceKeys.contains);
  }

  String _resolveMigrationsDirectory(
    Map<String, String> options,
    LoadedSchemaDocument loaded,
  ) {
    return options['from'] ??
        options['out'] ??
        defaultMigrationsDirectory(loaded.filePath);
  }

  SchemaDocument _resolveDiffSchemaSource(
    Map<String, String> options, {
    required String prefix,
    required LoadedSchemaDocument? loaded,
    required sqlite.Database? database,
  }) {
    final emptyKey = '$prefix-empty';
    final schemaKey = '$prefix-schema';
    final databaseKey = '$prefix-database';
    final migrationsKey = '$prefix-migrations';

    final selected = <String>[
      if (_flag(options, emptyKey)) emptyKey,
      if (options[schemaKey] != null) schemaKey,
      if (_flag(options, databaseKey)) databaseKey,
      if (options[migrationsKey] != null) migrationsKey,
    ];
    if (selected.length != 1) {
      throw FormatException(
        'Pass exactly one of --$emptyKey, --$schemaKey, --$databaseKey, or --$migrationsKey.',
      );
    }

    if (selected.single == emptyKey) {
      return const SchemaDocument(models: <ModelDefinition>[]);
    }
    if (selected.single == schemaKey) {
      return _loadSchema(options[schemaKey]).schema;
    }
    if (selected.single == databaseKey) {
      if (database == null) {
        throw FormatException(
          '--$databaseKey requires datasource resolution via --schema or auto-discovery.',
        );
      }
      return filterSchemaForUserModels(
        service.planner.schemaIntrospector.introspect(database),
        historyTableName: SqliteMigrationRunner.historyTableName,
      );
    }

    final artifacts = loadLocalMigrationArtifacts(
      options[migrationsKey]!,
      provider: SqliteMigrationRunner.providerName,
    );
    if (artifacts.isEmpty) {
      return const SchemaDocument(models: <ModelDefinition>[]);
    }
    return const SchemaParser().parse(artifacts.last.afterSchema);
  }

  String _renderDiffSummary({
    required bool isEmpty,
    required List<String> statements,
    required List<String> warnings,
    required bool requiresRebuild,
  }) {
    if (isEmpty) {
      return 'No schema differences detected.\n';
    }

    final buffer = StringBuffer();
    buffer.writeln('Schema differences detected.');
    if (requiresRebuild) {
      buffer.writeln('Rebuild required: true');
    }
    if (statements.isNotEmpty) {
      buffer.writeln('Statements:');
      for (final statement in statements) {
        buffer.writeln('- $statement');
      }
    }
    if (warnings.isNotEmpty) {
      buffer.writeln('Warnings:');
      for (final warning in warnings) {
        buffer.writeln('- $warning');
      }
    }
    return buffer.toString();
  }

  void _writeDiffOutput(String output, String? outputPath) {
    if (outputPath != null && outputPath.isNotEmpty) {
      final file = File(outputPath).absolute;
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(output);
      out.writeln(
        cliSuccess(
          'Diff output written: ${file.path}',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      return;
    }
    out.write(output.endsWith('\n') ? output : '$output\n');
  }

  sqlite.Database _resetDatabase(String databasePath) {
    if (databasePath == ':memory:') {
      return sqlite.sqlite3.openInMemory();
    }

    final file = File(databasePath);
    file.parent.createSync(recursive: true);
    if (file.existsSync()) {
      file.deleteSync();
    }
    return sqlite.sqlite3.open(databasePath);
  }

  String? _detectDrift(sqlite.Database database) {
    final activeHistory = service.runner.loadActiveHistory(database);
    if (activeHistory.isEmpty) {
      return null;
    }

    final latest = activeHistory.last;
    final snapshot = latest.afterSchema;
    if (snapshot == null || snapshot.trim().isEmpty) {
      return null;
    }

    final current = filterSchemaForUserModels(
      service.planner.schemaIntrospector.introspect(database),
      historyTableName: SqliteMigrationRunner.historyTableName,
    );
    final expected = const SchemaParser().parse(snapshot);
    final driftPlan = service.planner.plan(from: expected, to: current);
    if (driftPlan.isEmpty) {
      return null;
    }
    return 'Drift detected between the live database and the latest recorded migration `${latest.name}`.';
  }

  void _writeDeploySummary(
    DeployResult result, {
    required String migrationsPath,
  }) {
    out.writeln(
      cliInfo(
        '${result.localMigrationCount} migrations found in $migrationsPath',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    if (!result.appliedAny) {
      out.writeln(
        cliSuccess(
          'No pending migrations to apply.',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
      return;
    }
    for (final migrationName in result.appliedMigrationNames) {
      out.writeln(
        cliSuccess(
          'Applying migration `$migrationName`',
          ansiEnabled: _outAnsiEnabled,
        ),
      );
    }
    out.writeln(
      cliSuccess(
        'All migrations have been successfully applied.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
  }

  void _writeGeneratedClientSummary(GeneratedClientWriteResult result) {
    out.writeln(
      result.updated
          ? cliSuccess(
              'Generated comon_orm client to ${result.outputPath}',
              ansiEnabled: _outAnsiEnabled,
            )
          : cliInfo(
              'Generated client up to date: ${result.outputPath}',
              ansiEnabled: _outAnsiEnabled,
            ),
    );
  }
}
