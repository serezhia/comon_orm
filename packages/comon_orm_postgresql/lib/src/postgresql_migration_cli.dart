import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:postgres/postgres.dart' as pg;

import 'postgresql_migration_runner.dart';
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
    CliReadLine? readLine,
    bool? interactiveInput,
    GeneratedClientWriter? clientWriter,
    StringSink? out,
    StringSink? err,
  }) : service = service ?? const PostgresqlMigrationService(),
       openConnection = openConnection ?? _defaultOpenConnection,
       clientWriter = clientWriter ?? const GeneratedClientWriter(),
       out = out ?? stdout,
       err = err ?? stderr,
       prompter = CliPrompter(
         out: out ?? stdout,
         readLine: readLine,
         interactive: interactiveInput,
       );

  /// Migration service used for planning and applying changes.
  final PostgresqlMigrationService service;

  /// Connection opener used by CLI commands.
  final PostgresqlCliConnectionOpener openConnection;

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
        'deploy' => _runDeploy(options),
        'dev' => _runDev(options),
        'rollback' => _runRollback(options),
        'reset' => _runReset(options),
        'resolve' => _runResolve(options),
        'push' => _runPush(options),
        'status' => _runStatus(options),
        _ => Future<int>.value(_unknownCommand(command)),
      };
    } on FormatException catch (error) {
      err.writeln(cliError(error.message, ansiEnabled: _errAnsiEnabled));
      return 2;
    } on Object catch (error) {
      err.writeln(cliError('$error', ansiEnabled: _errAnsiEnabled));
      return 1;
    }
  }

  Future<int> _runDiff(Map<String, String> options) async {
    if (_usesEnhancedDiff(options)) {
      return _runEnhancedDiff(options);
    }

    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationName = _requireOption(options, 'name');
    final outputPath =
        options['out'] ?? defaultMigrationsDirectory(loaded.filePath);

    out.writeln(
      cliWarning(
        '`migrate diff --name` is deprecated. Use `migrate dev --name` instead.',
        ansiEnabled: _outAnsiEnabled,
      ),
    );

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
      await connection.close();
    }
  }

  Future<int> _runEnhancedDiff(Map<String, String> options) async {
    final needsDatabase =
        _flag(options, 'from-database') || _flag(options, 'to-database');
    final loaded = needsDatabase || options.containsKey('schema')
        ? _loadSchema(options['schema'])
        : null;
    final connection = needsDatabase
        ? await openConnection(
            options['url'] ?? _resolveConnectionUrl(options, loaded!),
          )
        : null;

    try {
      final fromSchema = await _resolveDiffSchemaSource(
        options,
        prefix: 'from',
        loaded: loaded,
        connection: connection,
      );
      final toSchema = await _resolveDiffSchemaSource(
        options,
        prefix: 'to',
        loaded: loaded,
        connection: connection,
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
      await _writeDiffOutput(output, options['output']);
      if (_flag(options, 'exit-code') && !plan.isEmpty) {
        return 2;
      }
      return 0;
    } finally {
      await connection?.close();
    }
  }

  Future<int> _runRollback(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationsPath =
        options['from'] ?? defaultMigrationsDirectory(loaded.filePath);
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
      await connection.close();
    }
  }

  Future<int> _runStatus(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationsPath =
        options['from'] ?? defaultMigrationsDirectory(loaded.filePath);

    final connection = await openConnection(connectionUrl);
    try {
      final status = await service.status(
        executor: connection.executor,
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
      await connection.close();
    }
  }

  Future<int> _runDeploy(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationsPath = _resolveMigrationsDirectory(options, loaded);
    final connection = await openConnection(connectionUrl);
    try {
      final result = await service.deployMigrations(
        executor: connection.executor,
        migrationsDirectory: migrationsPath,
      );
      _writeDeploySummary(result, migrationsPath: migrationsPath);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runDev(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final migrationsPath = _resolveMigrationsDirectory(options, loaded);
    final createOnly = _flag(options, 'create-only');
    final connection = await openConnection(connectionUrl);
    try {
      final deployResult = await service.deployMigrations(
        executor: connection.executor,
        migrationsDirectory: migrationsPath,
      );
      if (deployResult.appliedAny) {
        _writeDeploySummary(deployResult, migrationsPath: migrationsPath);
      }

      final driftMessage = await _detectDrift(connection.executor);
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

      final status = await service.status(
        executor: connection.executor,
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
      var draft = await service.draftFromDatabase(
        executor: connection.executor,
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
        draft = await service.draftFromDatabase(
          executor: connection.executor,
          target: loaded.schema,
          migrationName: migrationName,
        );
      }

      final requiresManualMigration = containsManualMigrationWarnings(
        draft.plan.warnings,
      );
      if (requiresManualMigration && !createOnly) {
        _writeWarnings(draft.plan.warnings);
        err.writeln(
          cliError(
            'This schema change requires a manual migration and cannot be applied automatically.',
            ansiEnabled: _errAnsiEnabled,
          ),
        );
        err.writeln(
          cliWarning(
            'Run `migrate dev --create-only --name $migrationName`, complete the change manually, then run `migrate resolve --applied $migrationName`.',
            ansiEnabled: _errAnsiEnabled,
          ),
        );
        return 1;
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
        if (requiresManualMigration) {
          out.writeln(
            cliWarning(
              'Draft requires manual migration. Complete the change manually, then run `migrate resolve --applied $migrationName`.',
              ansiEnabled: _outAnsiEnabled,
            ),
          );
        }
        return 0;
      }

      final result = await service.applySchema(
        executor: connection.executor,
        target: loaded.schema,
        migrationName: migrationName,
        allowWarnings: draft.plan.warnings.isNotEmpty,
      );
      out.writeln(
        cliSuccess('Applied: ${result.applied}', ansiEnabled: _outAnsiEnabled),
      );
      final generated = await clientWriter.writeForLoadedSchema(loaded);
      _writeGeneratedClientSummary(generated);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runReset(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
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

    final connection = await openConnection(connectionUrl);
    try {
      await _resetDatabase(connection.executor);
      final result = await service.deployMigrations(
        executor: connection.executor,
        migrationsDirectory: migrationsPath,
      );
      _writeDeploySummary(result, migrationsPath: migrationsPath);
      final generated = await clientWriter.writeForLoadedSchema(loaded);
      _writeGeneratedClientSummary(generated);
      return 0;
    } finally {
      await connection.close();
    }
  }

  Future<int> _runResolve(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final appliedMigration = options['applied'];
    final rolledBackMigration = options['rolled-back'];
    if ((appliedMigration == null) == (rolledBackMigration == null)) {
      throw const FormatException(
        'Pass exactly one of --applied <migration> or --rolled-back <migration>.',
      );
    }

    final connection = await openConnection(connectionUrl);
    try {
      final result = appliedMigration != null
          ? await service.resolveApplied(
              executor: connection.executor,
              migrationsDirectory: _resolveMigrationsDirectory(options, loaded),
              migrationName: appliedMigration,
            )
          : await service.resolveRolledBack(
              executor: connection.executor,
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
      await connection.close();
    }
  }

  Future<int> _runPush(Map<String, String> options) async {
    final loaded = _loadSchema(options['schema']);
    final connectionUrl =
        options['url'] ?? _resolveConnectionUrl(options, loaded);
    final acceptDataLoss = _flag(options, 'accept-data-loss');
    final forceReset = _flag(options, 'force-reset');
    final connection = await openConnection(connectionUrl);
    try {
      if (forceReset) {
        await _resetDatabase(connection.executor);
      }

      final result = await service.pushSchema(
        executor: connection.executor,
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
      await connection.close();
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
      cliTitle('comon_orm_postgresql migrations', ansiEnabled: _outAnsiEnabled),
    );
    out.writeln(
      cliMuted(
        'Usage: comon_orm_postgresql <command> [options]',
        ansiEnabled: _outAnsiEnabled,
      ),
    );
    out.writeln('Commands:');
    out.writeln(
      '  diff [--url <connection>] [--schema <path>] [--datasource <name>] --name <migration> [--out <dir>]',
    );
    out.writeln(
      '  dev [--url <connection>] [--schema <path>] [--datasource <name>] [--name <migration>] [--create-only]',
    );
    out.writeln(
      '  deploy [--url <connection>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
    out.writeln(
      '  rollback [--url <connection>] [--schema <path>] [--datasource <name>] [--from <dir>] [--name <migration>] [--rollback-name <name>] [--allow-warnings]',
    );
    out.writeln(
      '  reset [--url <connection>] [--schema <path>] [--datasource <name>] [--from <dir>] [--force]',
    );
    out.writeln(
      '  resolve [--url <connection>] [--schema <path>] [--datasource <name>] (--applied <migration> | --rolled-back <migration>) [--from <dir>]',
    );
    out.writeln(
      '  push [--url <connection>] [--schema <path>] [--datasource <name>] [--accept-data-loss] [--force-reset]',
    );
    out.writeln(
      '  status [--url <connection>] [--schema <path>] [--datasource <name>] [--from <dir>]',
    );
  }

  void _writeWarnings(List<String> warnings) {
    for (final warning in warnings) {
      out.writeln(cliWarning(warning, ansiEnabled: _outAnsiEnabled));
    }
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

  Future<SchemaDocument> _resolveDiffSchemaSource(
    Map<String, String> options, {
    required String prefix,
    required LoadedSchemaDocument? loaded,
    required PostgresqlCliSession? connection,
  }) async {
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
      if (connection == null) {
        throw FormatException(
          '--$databaseKey requires datasource resolution via --schema or auto-discovery.',
        );
      }
      return filterSchemaForUserModels(
        await service.planner.schemaIntrospector.introspect(
          connection.executor,
        ),
        historyTableName: PostgresqlMigrationRunner.historyTableName,
      );
    }

    final artifacts = loadLocalMigrationArtifacts(
      options[migrationsKey]!,
      provider: PostgresqlMigrationRunner.providerName,
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

  Future<void> _writeDiffOutput(String output, String? outputPath) async {
    if (outputPath != null && outputPath.isNotEmpty) {
      final file = File(outputPath).absolute;
      await file.parent.create(recursive: true);
      await file.writeAsString(output);
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

  Future<void> _resetDatabase(pg.SessionExecutor executor) async {
    await executor.run((session) async {
      await session.execute(
        'DROP SCHEMA IF EXISTS public CASCADE',
        ignoreRows: true,
      );
      await session.execute('CREATE SCHEMA public', ignoreRows: true);
    });
  }

  Future<String?> _detectDrift(pg.SessionExecutor executor) async {
    final activeHistory = await service.runner.loadActiveHistory(executor);
    if (activeHistory.isEmpty) {
      return null;
    }

    final latest = activeHistory.last;
    final snapshot = latest.afterSchema;
    if (snapshot == null || snapshot.trim().isEmpty) {
      return null;
    }

    final current = filterSchemaForUserModels(
      await service.planner.schemaIntrospector.introspect(executor),
      historyTableName: PostgresqlMigrationRunner.historyTableName,
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

Future<PostgresqlCliSession> _defaultOpenConnection(
  String connectionUrl,
) async {
  final connection = await pg.Connection.openFromUrl(connectionUrl);
  return PostgresqlCliSession(executor: connection, close: connection.close);
}
