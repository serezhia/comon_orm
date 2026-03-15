import 'package:comon_orm/comon_orm.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_flutter_database_factory.dart';

/// Loads the default database factory for the current platform.
typedef SqliteFlutterDatabaseFactoryLoader = Future<DatabaseFactory> Function();

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

/// Schema-aware bootstrap helper for Flutter SQLite runtimes.
class SqliteFlutterBootstrap {
  /// Creates a Flutter-oriented SQLite bootstrap helper.
  const SqliteFlutterBootstrap({
    this.workflow = const SchemaWorkflow(),
    SqliteFlutterDatabaseFactoryLoader? databaseFactoryLoader,
  }) : _databaseFactoryLoader =
           databaseFactoryLoader ?? createDefaultSqliteFlutterDatabaseFactory;

  /// Workflow used for schema parsing and datasource resolution.
  final SchemaWorkflow workflow;

  final SqliteFlutterDatabaseFactoryLoader _databaseFactoryLoader;

  /// Resolves database config from a schema file.
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

  /// Resolves database config from raw schema source.
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

  /// Opens a database from a schema file using the selected database factory.
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

  /// Opens a database from raw schema source using the selected database factory.
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
