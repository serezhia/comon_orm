import 'package:comon_orm/comon_orm.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_flutter_database_factory.dart';

/// Result of resolving a SQLite datasource for Flutter-oriented runtimes.
class ResolvedSqliteFlutterDatabaseConfig {
  /// Creates a resolved database config.
  const ResolvedSqliteFlutterDatabaseConfig({
    required this.databasePath,
    required this.datasource,
    required this.schema,
  });

  /// Resolved database path or in-memory marker.
  final String databasePath;

  /// Resolved datasource settings from the schema.
  final ResolvedDatasourceConfig datasource;

  /// Parsed and validated schema document.
  final SchemaDocument schema;
}

/// Result of resolving a SQLite datasource from runtime metadata.
class ResolvedSqliteFlutterRuntimeDatabaseConfig {
  /// Creates a resolved runtime database config.
  const ResolvedSqliteFlutterRuntimeDatabaseConfig({
    required this.databasePath,
    required this.datasource,
    required this.schema,
  });

  /// Resolved database path or in-memory marker.
  final String databasePath;

  /// Resolved datasource settings from runtime metadata.
  final ResolvedRuntimeDatasourceConfig datasource;

  /// Runtime schema bridge used for bootstrap resolution.
  final RuntimeSchemaView schema;
}

/// Opened SQLite database together with the resolved schema metadata.
class OpenedSqliteFlutterDatabase {
  /// Creates an opened database bundle.
  const OpenedSqliteFlutterDatabase({
    required this.database,
    required this.databasePath,
    required this.schema,
    required this.datasource,
  });

  /// Open sqflite database handle.
  final Database database;

  /// Resolved database path or in-memory marker.
  final String databasePath;

  /// Parsed and validated schema document.
  final SchemaDocument schema;

  /// Resolved datasource settings from the schema.
  final ResolvedDatasourceConfig datasource;
}

/// Opened SQLite database together with runtime metadata.
class OpenedSqliteFlutterRuntimeDatabase {
  /// Creates an opened runtime database bundle.
  const OpenedSqliteFlutterRuntimeDatabase({
    required this.database,
    required this.databasePath,
    required this.schema,
    required this.datasource,
  });

  /// Open sqflite database handle.
  final Database database;

  /// Resolved database path or in-memory marker.
  final String databasePath;

  /// Runtime schema bridge used during bootstrap.
  final RuntimeSchemaView schema;

  /// Resolved datasource settings from runtime metadata.
  final ResolvedRuntimeDatasourceConfig datasource;
}

/// Schema-aware bootstrap helper for Flutter SQLite runtimes.
class SqliteFlutterBootstrap {
  /// Creates a Flutter-oriented SQLite bootstrap helper.
  const SqliteFlutterBootstrap({
    this.workflow = const SchemaWorkflow(),
    this.datasourceResolver = const RuntimeDatasourceResolver(),
    SqliteFlutterDatabaseFactoryLoader? databaseFactoryLoader,
  }) : _databaseFactoryLoader =
           databaseFactoryLoader ?? createDefaultSqliteFlutterDatabaseFactory;

  /// Workflow used for schema parsing and datasource resolution.
  final SchemaWorkflow workflow;

  /// Resolver used by runtime-metadata bootstrap methods.
  final RuntimeDatasourceResolver datasourceResolver;

  final SqliteFlutterDatabaseFactoryLoader _databaseFactoryLoader;

  /// Compatibility helper that resolves database config from a schema file.
  Future<ResolvedSqliteFlutterDatabaseConfig> resolveFromSchemaPath({
    required String schemaPath,
    String? databasePath,
    String? datasourceName,
  }) async {
    final loaded = await workflow.loadValidatedSchema(schemaPath);
    return _resolveLoaded(
      loaded,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
  }

  /// Compatibility helper that resolves database config from raw schema source.
  ResolvedSqliteFlutterDatabaseConfig resolveFromSchemaSource({
    required String source,
    String filePath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
  }) {
    final loaded = workflow.loadValidatedSchemaSource(
      source: source,
      filePath: filePath,
    );
    return _resolveLoaded(
      loaded,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
  }

  /// Resolves database config from a runtime schema bridge.
  ResolvedSqliteFlutterRuntimeDatabaseConfig resolveFromRuntimeSchema({
    required RuntimeSchemaView schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
  }) {
    final datasource = datasourceResolver.resolveDatasource(
      schema: schema,
      datasourceName: datasourceName,
      expectedProvider: 'sqlite',
      schemaPath: schemaPath,
    );
    return ResolvedSqliteFlutterRuntimeDatabaseConfig(
      databasePath: databasePath ?? datasource.url,
      datasource: datasource,
      schema: schema,
    );
  }

  /// Resolves database config from generated runtime metadata.
  ResolvedSqliteFlutterRuntimeDatabaseConfig resolveFromGeneratedSchema({
    required GeneratedRuntimeSchema schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
  }) {
    return resolveFromRuntimeSchema(
      schema: runtimeSchemaViewFromGeneratedSchema(schema),
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
  }

  /// Compatibility helper that opens a database from a schema file using the
  /// selected database factory.
  Future<OpenedSqliteFlutterDatabase> openFromSchemaPath({
    required String schemaPath,
    String? databasePath,
    String? datasourceName,
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final resolved = await resolveFromSchemaPath(
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
    return openResolvedDatabase(
      resolved,
      databaseFactory: databaseFactory,
      options: options,
    );
  }

  /// Compatibility helper that opens a database from raw schema source using
  /// the selected database factory.
  Future<OpenedSqliteFlutterDatabase> openFromSchemaSource({
    required String source,
    String filePath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final resolved = resolveFromSchemaSource(
      source: source,
      filePath: filePath,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
    return openResolvedDatabase(
      resolved,
      databaseFactory: databaseFactory,
      options: options,
    );
  }

  /// Opens a database from runtime metadata using the selected database factory.
  Future<OpenedSqliteFlutterRuntimeDatabase> openFromRuntimeSchema({
    required RuntimeSchemaView schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final resolved = resolveFromRuntimeSchema(
      schema: schema,
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
    return openResolvedRuntimeDatabase(
      resolved,
      databaseFactory: databaseFactory,
      options: options,
    );
  }

  /// Opens a database from generated runtime metadata.
  Future<OpenedSqliteFlutterRuntimeDatabase> openFromGeneratedSchema({
    required GeneratedRuntimeSchema schema,
    String schemaPath = 'schema.prisma',
    String? databasePath,
    String? datasourceName,
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final resolved = resolveFromGeneratedSchema(
      schema: schema,
      schemaPath: schemaPath,
      databasePath: databasePath,
      datasourceName: datasourceName,
    );
    return openResolvedRuntimeDatabase(
      resolved,
      databaseFactory: databaseFactory,
      options: options,
    );
  }

  /// Opens a database from already resolved schema and datasource metadata.
  Future<OpenedSqliteFlutterDatabase> openResolvedDatabase(
    ResolvedSqliteFlutterDatabaseConfig resolved, {
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final factory = databaseFactory ?? await _databaseFactoryLoader();
    final database = await factory.openDatabase(
      resolved.databasePath == ':memory:'
          ? inMemoryDatabasePath
          : resolved.databasePath,
      options: _mergeOpenOptions(options),
    );

    return OpenedSqliteFlutterDatabase(
      database: database,
      databasePath: resolved.databasePath,
      schema: resolved.schema,
      datasource: resolved.datasource,
    );
  }

  /// Opens a database from already resolved runtime metadata.
  Future<OpenedSqliteFlutterRuntimeDatabase> openResolvedRuntimeDatabase(
    ResolvedSqliteFlutterRuntimeDatabaseConfig resolved, {
    DatabaseFactory? databaseFactory,
    OpenDatabaseOptions? options,
  }) async {
    final factory = databaseFactory ?? await _databaseFactoryLoader();
    final database = await factory.openDatabase(
      resolved.databasePath == ':memory:'
          ? inMemoryDatabasePath
          : resolved.databasePath,
      options: _mergeOpenOptions(options),
    );

    return OpenedSqliteFlutterRuntimeDatabase(
      database: database,
      databasePath: resolved.databasePath,
      schema: resolved.schema,
      datasource: resolved.datasource,
    );
  }

  ResolvedSqliteFlutterDatabaseConfig _resolveLoaded(
    LoadedSchemaDocument loaded, {
    String? databasePath,
    String? datasourceName,
  }) {
    final datasource = workflow.resolveDatasource(
      loaded,
      datasourceName: datasourceName,
      expectedProvider: 'sqlite',
    );
    return ResolvedSqliteFlutterDatabaseConfig(
      databasePath: databasePath ?? datasource.url,
      datasource: datasource,
      schema: loaded.schema,
    );
  }

  OpenDatabaseOptions _mergeOpenOptions(OpenDatabaseOptions? options) {
    return OpenDatabaseOptions(
      version: options?.version,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        final onConfigure = options?.onConfigure;
        if (onConfigure != null) {
          await onConfigure(database);
        }
      },
      onCreate: options?.onCreate,
      onUpgrade: options?.onUpgrade,
      onDowngrade: options?.onDowngrade,
      onOpen: options?.onOpen,
      readOnly: options?.readOnly ?? false,
      singleInstance: options?.singleInstance ?? true,
    );
  }
}
