import 'package:sqflite_common/sqlite_api.dart';

// ── Column type ──────────────────────────────────────────────────────────

/// SQL column type emitted in migration DDL.
enum MigrationColumnType {
  /// SQLite `INTEGER`.
  integer('INTEGER'),

  /// SQLite `TEXT`.
  text('TEXT'),

  /// SQLite `REAL`.
  real('REAL'),

  /// SQLite `BLOB`.
  blob('BLOB'),

  /// SQLite `NUMERIC`.
  numeric('NUMERIC');

  const MigrationColumnType(this.sql);

  /// The SQL type name.
  final String sql;
}

// ── Foreign key reference ────────────────────────────────────────────────

/// A foreign-key reference attached to a column.
class MigrationForeignKeyRef {
  /// Creates a foreign-key reference.
  const MigrationForeignKeyRef({
    required this.table,
    required this.column,
    this.onDelete,
    this.onUpdate,
  });

  /// Referenced table.
  final String table;

  /// Referenced column.
  final String column;

  /// Referential action on delete (e.g. `'CASCADE'`).
  final String? onDelete;

  /// Referential action on update.
  final String? onUpdate;
}

// ── Column definition ────────────────────────────────────────────────────

/// Immutable column description produced by [ColumnBuilder].
class MigrationColumnDefinition {
  /// Creates a column definition.
  const MigrationColumnDefinition({
    required this.name,
    required this.type,
    this.isPrimaryKey = false,
    this.isAutoIncrement = false,
    this.isNotNull = false,
    this.isUnique = false,
    this.defaultValue,
    this.checkExpression,
    this.references,
  });

  /// Column name.
  final String name;

  /// SQL type.
  final MigrationColumnType type;

  /// Whether this column is a primary key.
  final bool isPrimaryKey;

  /// Whether this column auto-increments.
  final bool isAutoIncrement;

  /// Whether this column is `NOT NULL`.
  final bool isNotNull;

  /// Whether this column has a `UNIQUE` constraint.
  final bool isUnique;

  /// Default value, or `null` if none.
  final Object? defaultValue;

  /// CHECK expression, or `null`.
  final String? checkExpression;

  /// Foreign-key reference, or `null`.
  final MigrationForeignKeyRef? references;

  /// Renders the column fragment for use inside `CREATE TABLE (...)`.
  String toSql({bool inlinePrimaryKey = true}) {
    final parts = <String>[_q(name)];

    if (isAutoIncrement && isPrimaryKey && inlinePrimaryKey) {
      parts.add('INTEGER PRIMARY KEY AUTOINCREMENT');
      return parts.join(' ');
    }

    if (isAutoIncrement) {
      parts.add('INTEGER NOT NULL');
      return parts.join(' ');
    }

    parts.add(type.sql);

    if (isPrimaryKey && inlinePrimaryKey) {
      parts.add('PRIMARY KEY');
    }
    if (isNotNull) {
      parts.add('NOT NULL');
    }
    if (isUnique) {
      parts.add('UNIQUE');
    }
    if (defaultValue != null) {
      parts.add('DEFAULT ${_renderDefault(defaultValue!)}');
    }
    if (checkExpression != null) {
      parts.add('CHECK ($checkExpression)');
    }

    return parts.join(' ');
  }
}

// ── Column builder ───────────────────────────────────────────────────────

/// Fluent builder for a single column.
class ColumnBuilder {
  /// @nodoc
  ColumnBuilder(this._name, this._type);

  final String _name;
  final MigrationColumnType _type;
  bool _isPrimaryKey = false;
  bool _isAutoIncrement = false;
  bool _isNotNull = false;
  bool _isUnique = false;
  Object? _defaultValue;
  String? _checkExpression;
  MigrationForeignKeyRef? _references;

  /// Marks the column as a primary key.
  ColumnBuilder primaryKey() {
    _isPrimaryKey = true;
    return this;
  }

  /// Marks the column as auto-incrementing (implies primary key).
  ColumnBuilder autoIncrement() {
    _isAutoIncrement = true;
    _isPrimaryKey = true;
    return this;
  }

  /// Marks the column as `NOT NULL`.
  ColumnBuilder notNull() {
    _isNotNull = true;
    return this;
  }

  /// Marks the column as nullable (the default).
  ColumnBuilder nullable() {
    _isNotNull = false;
    return this;
  }

  /// Adds a `UNIQUE` constraint.
  ColumnBuilder unique() {
    _isUnique = true;
    return this;
  }

  /// Sets a `DEFAULT` value.
  ///
  /// Dart [bool], [int], and [double] values are rendered as SQL literals.
  /// All other values are rendered as quoted strings.
  ColumnBuilder defaultValue(Object value) {
    _defaultValue = value;
    return this;
  }

  /// Adds a `CHECK` constraint with the given SQL [expression].
  ColumnBuilder check(String expression) {
    _checkExpression = expression;
    return this;
  }

  /// Adds a foreign-key reference to [table].[column].
  ColumnBuilder foreignKey(
    String table,
    String column, {
    String? onDelete,
    String? onUpdate,
  }) {
    _references = MigrationForeignKeyRef(
      table: table,
      column: column,
      onDelete: onDelete,
      onUpdate: onUpdate,
    );
    return this;
  }

  /// Builds the immutable [MigrationColumnDefinition].
  MigrationColumnDefinition build() {
    return MigrationColumnDefinition(
      name: _name,
      type: _type,
      isPrimaryKey: _isPrimaryKey,
      isAutoIncrement: _isAutoIncrement,
      isNotNull: _isNotNull || _isPrimaryKey,
      isUnique: _isUnique,
      defaultValue: _defaultValue,
      checkExpression: _checkExpression,
      references: _references,
    );
  }
}

// ── Column methods mixin ─────────────────────────────────────────────────

/// Typed column factory methods shared by [CreateTableBuilder] and
/// [AlterTableBuilder].
mixin _ColumnMethods {
  /// Adds an `INTEGER` column.
  ColumnBuilder integer(String name) =>
      _addColumn(name, MigrationColumnType.integer);

  /// Adds a `TEXT` column.
  ColumnBuilder text(String name) => _addColumn(name, MigrationColumnType.text);

  /// Adds a `REAL` column.
  ColumnBuilder real(String name) => _addColumn(name, MigrationColumnType.real);

  /// Adds a `BLOB` column.
  ColumnBuilder blob(String name) => _addColumn(name, MigrationColumnType.blob);

  /// Adds a `NUMERIC` column.
  ColumnBuilder numeric(String name) =>
      _addColumn(name, MigrationColumnType.numeric);

  /// Adds a boolean column (stored as `INTEGER`).
  ColumnBuilder boolean(String name) =>
      _addColumn(name, MigrationColumnType.integer);

  /// Adds a datetime column (stored as `TEXT` in ISO-8601 format).
  ColumnBuilder datetime(String name) =>
      _addColumn(name, MigrationColumnType.text);

  ColumnBuilder _addColumn(String name, MigrationColumnType type);
}

// ── Create table builder ─────────────────────────────────────────────────

/// Builder for `CREATE TABLE` statements.
///
/// Column methods ([integer], [text], [boolean], etc.) define new columns
/// with a fluent API:
///
/// ```dart
/// schema.createTable('users', (table) {
///   table.id();
///   table.text('email').notNull().unique();
///   table.text('name');
///   table.boolean('active').notNull().defaultValue(true);
///   table.timestamps();
/// });
/// ```
class CreateTableBuilder with _ColumnMethods {
  final _builders = <ColumnBuilder>[];
  final _compoundPKs = <List<String>>[];
  final _compoundUniques = <List<String>>[];
  final _rawConstraints = <String>[];

  @override
  ColumnBuilder _addColumn(String name, MigrationColumnType type) {
    final builder = ColumnBuilder(name, type);
    _builders.add(builder);
    return builder;
  }

  /// Shortcut: auto-incrementing `INTEGER PRIMARY KEY` column.
  ///
  /// Defaults to `id` but accepts a custom [name].
  ColumnBuilder id([String name = 'id']) =>
      integer(name).primaryKey().autoIncrement();

  /// Shortcut: adds `created_at TEXT NOT NULL` and `updated_at TEXT NOT NULL`.
  void timestamps({
    String createdAt = 'created_at',
    String updatedAt = 'updated_at',
  }) {
    datetime(createdAt).notNull();
    datetime(updatedAt).notNull();
  }

  /// Shortcut: adds a nullable `deleted_at TEXT` column for soft-deletes.
  void softDeletes({String column = 'deleted_at'}) {
    datetime(column);
  }

  /// Defines a compound primary key over the given [columns].
  void primaryKey(List<String> columns) {
    _compoundPKs.add(columns);
  }

  /// Defines a compound unique constraint over the given [columns].
  void unique(List<String> columns) {
    _compoundUniques.add(columns);
  }

  /// Adds a raw SQL table-level constraint.
  void rawConstraint(String sql) {
    _rawConstraints.add(sql);
  }

  /// Builds the `CREATE TABLE IF NOT EXISTS` SQL statement.
  String buildSql(String tableName) {
    final columns = _builders.map((b) => b.build()).toList();
    final defs = <String>[];
    final hasCompoundPK = _compoundPKs.isNotEmpty;

    for (final column in columns) {
      defs.add(column.toSql(inlinePrimaryKey: !hasCompoundPK));
    }

    for (final column in columns) {
      if (column.references != null) {
        final ref = column.references!;
        final buffer = StringBuffer(
          'FOREIGN KEY (${_q(column.name)}) '
          'REFERENCES ${_q(ref.table)} (${_q(ref.column)})',
        );
        if (ref.onDelete != null) {
          buffer.write(' ON DELETE ${ref.onDelete}');
        }
        if (ref.onUpdate != null) {
          buffer.write(' ON UPDATE ${ref.onUpdate}');
        }
        defs.add(buffer.toString());
      }
    }

    for (final pk in _compoundPKs) {
      defs.add('PRIMARY KEY (${pk.map(_q).join(', ')})');
    }
    for (final uq in _compoundUniques) {
      defs.add('UNIQUE (${uq.map(_q).join(', ')})');
    }
    for (final c in _rawConstraints) {
      defs.add(c);
    }

    return 'CREATE TABLE IF NOT EXISTS ${_q(tableName)} '
        '(${defs.join(', ')})';
  }
}

// ── Alter table operations ───────────────────────────────────────────────

sealed class _AlterOp {}

final class _AddColumnOp extends _AlterOp {
  _AddColumnOp(this.builder);
  final ColumnBuilder builder;
}

final class _DropColumnOp extends _AlterOp {
  _DropColumnOp(this.name);
  final String name;
}

final class _RenameColumnOp extends _AlterOp {
  _RenameColumnOp(this.from, this.to);
  final String from;
  final String to;
}

// ── Alter table builder ──────────────────────────────────────────────────

/// Builder for `ALTER TABLE` operations.
///
/// Column methods ([integer], [text], [boolean], etc.) add new columns.
/// Use [dropColumn] and [renameColumn] for destructive changes.
///
/// ```dart
/// schema.alterTable('todos', (table) {
///   table.text('status').notNull().defaultValue('pending');
///   table.renameColumn('description', to: 'note');
///   table.dropColumn('legacy_field');
/// });
/// ```
class AlterTableBuilder with _ColumnMethods {
  final _ops = <_AlterOp>[];

  @override
  ColumnBuilder _addColumn(String name, MigrationColumnType type) {
    final builder = ColumnBuilder(name, type);
    _ops.add(_AddColumnOp(builder));
    return builder;
  }

  /// Drops an existing column.
  void dropColumn(String name) {
    _ops.add(_DropColumnOp(name));
  }

  /// Renames an existing column.
  void renameColumn(String from, {required String to}) {
    _ops.add(_RenameColumnOp(from, to));
  }

  /// Builds `ALTER TABLE` statements in declaration order.
  List<String> buildStatements(String tableName) {
    return _ops.map((op) {
      return switch (op) {
        _AddColumnOp(:final builder) =>
          'ALTER TABLE ${_q(tableName)} ADD COLUMN ${builder.build().toSql()}',
        _DropColumnOp(:final name) =>
          'ALTER TABLE ${_q(tableName)} DROP COLUMN ${_q(name)}',
        _RenameColumnOp(:final from, :final to) =>
          'ALTER TABLE ${_q(tableName)} '
              'RENAME COLUMN ${_q(from)} TO ${_q(to)}',
      };
    }).toList();
  }
}

// ── Schema operations ────────────────────────────────────────────────────

sealed class _SchemaOp {}

final class _CreateTableOp extends _SchemaOp {
  _CreateTableOp(this.name, this.define);
  final String name;
  final void Function(CreateTableBuilder) define;
}

final class _AlterTableOp extends _SchemaOp {
  _AlterTableOp(this.name, this.alter);
  final String name;
  final void Function(AlterTableBuilder) alter;
}

final class _RenameTableOp extends _SchemaOp {
  _RenameTableOp(this.from, this.to);
  final String from;
  final String to;
}

final class _DropTableOp extends _SchemaOp {
  _DropTableOp(this.name, this.ifExists);
  final String name;
  final bool ifExists;
}

final class _ExecuteOp extends _SchemaOp {
  _ExecuteOp(this.sql);
  final String sql;
}

final class _CreateIndexOp extends _SchemaOp {
  _CreateIndexOp(this.name, this.table, this.columns, this.unique);
  final String name;
  final String table;
  final List<String> columns;
  final bool unique;
}

final class _DropIndexOp extends _SchemaOp {
  _DropIndexOp(this.name);
  final String name;
}

// ── Migration schema ─────────────────────────────────────────────────────

/// Dart-coded schema migration builder.
///
/// Collects DDL and data operations in declaration order and executes them
/// sequentially against a SQLite transaction.
///
/// ```dart
/// SqliteFlutterMigration.schema(
///   fromVersion: 0,
///   toVersion: 1,
///   debugName: 'create_users',
///   run: (schema) {
///     schema.createTable('users', (table) {
///       table.id();
///       table.text('email').notNull().unique();
///       table.text('name');
///       table.boolean('active').notNull().defaultValue(true);
///       table.timestamps();
///     });
///   },
/// );
/// ```
class MigrationSchema {
  final _ops = <_SchemaOp>[];

  /// Creates a new table with the structure defined by [define].
  void createTable(
    String name,
    void Function(CreateTableBuilder table) define,
  ) {
    _ops.add(_CreateTableOp(name, define));
  }

  /// Alters an existing table using the operations defined by [alter].
  void alterTable(String name, void Function(AlterTableBuilder table) alter) {
    _ops.add(_AlterTableOp(name, alter));
  }

  /// Renames a table.
  void renameTable(String from, {required String to}) {
    _ops.add(_RenameTableOp(from, to));
  }

  /// Drops a table. Throws if the table does not exist.
  void dropTable(String name) {
    _ops.add(_DropTableOp(name, false));
  }

  /// Drops a table only if it exists.
  void dropTableIfExists(String name) {
    _ops.add(_DropTableOp(name, true));
  }

  /// Executes a raw SQL statement.
  void execute(String sql) {
    _ops.add(_ExecuteOp(sql));
  }

  /// Creates an index on [table] over [columns].
  void createIndex(
    String name, {
    required String on,
    required List<String> columns,
    bool unique = false,
  }) {
    _ops.add(_CreateIndexOp(name, on, columns, unique));
  }

  /// Drops an index.
  void dropIndex(String name) {
    _ops.add(_DropIndexOp(name));
  }

  /// Executes all collected operations against the given [executor].
  Future<void> applyTo(DatabaseExecutor executor) async {
    for (final op in _ops) {
      switch (op) {
        case _CreateTableOp(:final name, :final define):
          final builder = CreateTableBuilder();
          define(builder);
          await executor.execute(builder.buildSql(name));

        case _AlterTableOp(:final name, :final alter):
          final builder = AlterTableBuilder();
          alter(builder);
          for (final statement in builder.buildStatements(name)) {
            await executor.execute(statement);
          }

        case _RenameTableOp(:final from, :final to):
          await executor.execute('ALTER TABLE ${_q(from)} RENAME TO ${_q(to)}');

        case _DropTableOp(:final name, :final ifExists):
          final clause = ifExists ? 'DROP TABLE IF EXISTS' : 'DROP TABLE';
          await executor.execute('$clause ${_q(name)}');

        case _ExecuteOp(:final sql):
          await executor.execute(sql);

        case _CreateIndexOp(
          :final name,
          :final table,
          :final columns,
          :final unique,
        ):
          final uniqueClause = unique ? 'UNIQUE ' : '';
          await executor.execute(
            'CREATE ${uniqueClause}INDEX IF NOT EXISTS ${_q(name)} '
            'ON ${_q(table)} (${columns.map(_q).join(', ')})',
          );

        case _DropIndexOp(:final name):
          await executor.execute('DROP INDEX IF EXISTS ${_q(name)}');
      }
    }
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────

String _q(String value) => '"${value.replaceAll('"', '""')}"';

String _renderDefault(Object value) {
  if (value is bool) return value ? '1' : '0';
  if (value is int) return '$value';
  if (value is double) return '$value';
  return "'${value.toString().replaceAll("'", "''")}'";
}
