import 'package:postgres/postgres.dart' as pg;

/// Connection settings used to create PostgreSQL sessions and pools.
class PostgresqlConnectionConfig {
  /// Creates a connection config.
  const PostgresqlConnectionConfig({
    required this.host,
    required this.database,
    required this.username,
    this.password,
    this.port = 5432,
    this.sslMode = pg.SslMode.disable,
  });

  /// Server hostname.
  final String host;

  /// Database name.
  final String database;

  /// Login username.
  final String username;

  /// Optional login password.
  final String? password;

  /// Server port.
  final int port;

  /// SSL mode used for new connections.
  final pg.SslMode sslMode;

  /// Endpoint descriptor used by `package:postgres`.
  pg.Endpoint get endpoint => pg.Endpoint(
    host: host,
    database: database,
    username: username,
    password: password,
    port: port,
  );

  /// Connection settings used by `package:postgres`.
  pg.ConnectionSettings get settings => pg.ConnectionSettings(sslMode: sslMode);

  /// Opens a direct PostgreSQL connection.
  Future<pg.Connection> open() {
    return pg.Connection.open(endpoint, settings: settings);
  }
}
