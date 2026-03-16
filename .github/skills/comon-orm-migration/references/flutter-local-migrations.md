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
    SqliteFlutterMigration.sql(
      fromVersion: 1,
      toVersion: 2,
      debugName: 'add_user_names',
      statements: <String>[
        'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
      ],
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
- `SqliteFlutterMigration.sql(...)` is the default fit

### Rebuild Migration

Use when:

- removing columns
- reshaping data
- renaming or splitting fields
- changing constraints SQLite cannot update in place

Preferred action:

- explicit Dart-coded migration with one transaction
- prefer `SqliteFlutterMigration.rebuildTable(...)` when the change is a standard create or copy or drop or rename flow
- fall back to `SqliteFlutterMigration(...)` with a custom callback when the rebuild needs special logic

## Safety Rules

- store a schema version locally, for example via `PRAGMA user_version`
- run migrations in order
- keep one transaction per migration step when practical
- treat destructive local upgrades as reviewed application code
- if user data matters, consider backup/export paths for risky upgrades

## Good API Shape

- one migration object per version step
- a convenience constructor for simple SQL-first steps
- a rebuild helper for common SQLite replacement-table flows
- a custom callback for complex data moves
- one migrator that runs before generated runtime open

## Current Wrapper API

Use these names when the repository already depends on `comon_orm_sqlite_flutter`:

- `SqliteFlutterMigration.sql(...)`
- `SqliteFlutterMigration.rebuildTable(...)`
- `SqliteFlutterMigration(...)`
- `SqliteFlutterMigrator`
- `upgradeSqliteFlutterDatabase(...)`

Good recommendation pattern:

- additive change: `SqliteFlutterMigration.sql(...)`
- common rebuild: `SqliteFlutterMigration.rebuildTable(...)`
- custom data move: `SqliteFlutterMigration(...)` with `run: (tx) async { ... }`

## What Not To Promise

- not full Prisma migrate parity inside Flutter runtime
- not automatic safe generation of complex data-move code from schema diffs
- not hidden startup auto-mutations on a normal runtime open path
