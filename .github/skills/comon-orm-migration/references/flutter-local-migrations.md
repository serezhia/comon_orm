# Flutter Local Migrations Reference

Use this file when the task is about local Flutter database upgrades.

## The Core Split

There are two separate steps:

1. explicit local upgrade
2. normal runtime open

The correct startup shape is:

```dart
final migrator = SqliteFlutterMigrator(
  currentVersion: 3,
  migrations: <SqliteFlutterMigration>[
    SqliteFlutterMigration.schema(
      fromVersion: 1,
      toVersion: 2,
      debugName: 'add_user_names',
      run: (schema) {
        schema.alterTable('users', (table) {
          table.text('first_name').notNull().defaultValue('');
          table.text('last_name').notNull().defaultValue('');
        });
      },
    ),
  ],
);

await upgradeSqliteFlutterDatabase(
  databasePath: 'app.db',
  migrator: migrator,
);

final db = await GeneratedComonOrmClientFlutterSqlite.open(
  databasePath: 'app.db',
);
```

Do not hide migration logic inside normal runtime `open(...)`.

## Three Migration Types

### Reset

Use when:

- local data is disposable
- the database is a cache
- recovery is cheap

Preferred action:

- delete and recreate the local database

### Additive Migration

Use when:

- adding nullable columns
- adding safe defaults
- creating new tables
- backfilling existing rows without changing table shape destructively

Preferred action:

- a small versioned migration in Dart code
- `SqliteFlutterMigration.schema(...)` is the default fit for all structural changes
- `SqliteFlutterMigration.sql(...)` for raw SQL when needed

### Destructive Migration

Use when:

- removing columns
- renaming columns or tables
- reshaping data
- changing constraints SQLite cannot update in place

Preferred action:

- `SqliteFlutterMigration.schema(...)` with `dropColumn`, `renameColumn`, or `renameTable`
- `SqliteFlutterMigration.rebuildTable(...)` when the change is a complex rebuild with data transformation
- fall back to `SqliteFlutterMigration(...)` with a custom callback when the rebuild needs special logic

## Safety Rules

- store a schema version locally, for example via `PRAGMA user_version`
- run migrations in order
- keep one transaction per migration step when practical
- treat destructive local upgrades as reviewed application code
- if user data matters, consider backup/export paths for risky upgrades

## Good API Shape

- one migration object per version step
- a Dart-coded schema builder for most structural changes
- a SQL-first constructor for raw statements
- a rebuild helper for common SQLite replacement-table flows
- a custom callback for complex data moves
- one migrator that runs before generated runtime open

## Current Wrapper API

Use these names when the repository already depends on `comon_orm_sqlite_flutter`:

- `SqliteFlutterMigration.schema(...)` — Dart-coded builder API (preferred)
- `SqliteFlutterMigration.sql(...)` — raw SQL statements
- `SqliteFlutterMigration.rebuildTable(...)` — SQLite 12-step table rebuild
- `SqliteFlutterMigration.schemaDiff(...)` — auto-diff from schema snapshots
- `SqliteFlutterMigration(...)` — fully custom callback
- `SqliteFlutterMigrator`
- `upgradeSqliteFlutterDatabase(...)`

Good recommendation pattern:

- create/alter/rename/drop tables: `SqliteFlutterMigration.schema(...)`
- raw SQL with optional post-callback: `SqliteFlutterMigration.sql(...)`
- complex rebuild with data transform: `SqliteFlutterMigration.rebuildTable(...)`
- custom data move: `SqliteFlutterMigration(...)` with `run: (tx) async { ... }`

## What Not To Promise

- not full Prisma migrate parity inside Flutter runtime
- not automatic safe generation of complex data-move code from schema diffs
- not hidden startup auto-mutations on a normal runtime open path
