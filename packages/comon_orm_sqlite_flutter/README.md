**English** | [Русский](README_RU.md)

# comon_orm_sqlite_flutter

`comon_orm_sqlite_flutter` is the Flutter-oriented SQLite package for `comon_orm`.

It is intended to cover Flutter mobile, desktop, and web scenarios on top of the `sqflite` ecosystem, while keeping `comon_orm_sqlite` focused on Dart VM, CLI workflows, migrations, and introspection.

## Why A Separate Package

This package is separate on purpose.

The existing `comon_orm_sqlite` package already owns the current `sqlite3`-based VM runtime, CLI entrypoints, migration helpers, introspection, and file-system-oriented workflows. Flutter and browser targets need a different runtime bootstrap shape and much stricter separation from VM-only concerns.

Keeping Flutter support separate avoids turning one SQLite package into a mixed surface that tries to serve runtime embedding, CLI tooling, and migration workflows for very different platforms at once.

In practice the split is:

- `comon_orm_sqlite`: Dart VM, CLI, migrations, introspection, local tooling
- `comon_orm_sqlite_flutter`: Flutter-oriented runtime embedding for mobile, desktop, and web

This decision was made to keep platform boundaries explicit, not because SQLite itself is unavailable on web.

## Current Status

This package is in active development.

Today it provides:

- schema-aware SQLite datasource resolution for Flutter apps
- default database-factory selection for mobile, desktop, and web
- open helpers that work with injected `DatabaseFactory` instances
- a working `DatabaseAdapter` implementation on top of `sqflite_common`
- generated-metadata runtime bootstrap through `openFromGeneratedSchema(...)`
- explicit setup/bootstrap helpers outside the adapter runtime surface for local database preparation
- a lightweight app-side migration API for versioned local SQLite upgrades in Dart code

Planned next:

- wider runtime coverage tests against relation and aggregate scenarios
- alternate runtime backends if the project later wants to support something beyond the current `sqflite` path

Implementation phases are tracked in [PLAN.md](PLAN.md).

## Quick Start

Add dependencies:

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha.1
  comon_orm_sqlite_flutter: ^0.0.1-alpha.1
```

Open a Flutter SQLite runtime directly through the generated client helper:

```dart
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final db = await GeneratedComonOrmClientFlutterSqlite.open(
    databasePath: 'app.db',
  );

  try {
    final created = await db.todo.create(
      data: TodoCreateInput(
        title: 'Ship Flutter runtime metadata',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    print(created.title);
  } finally {
    await db.close();
  }
}
```

That path keeps normal runtime startup on generated metadata only. Local database bootstrap lives in explicit setup helpers outside the adapter runtime surface.

## Runtime Paths

- Runtime path: `GeneratedComonOrmClientFlutterSqlite.open(...)`
- Setup path: `SqliteFlutterBootstrap` plus `SqliteFlutterSchemaApplier` for explicit local database preparation outside normal runtime startup
- Local upgrade path: `SqliteFlutterMigrator` plus `upgradeSqliteFlutterDatabase(...)` for versioned app-side SQLite upgrades before runtime open

## Local Flutter Migrations

The package now also exposes a lightweight migration layer for local Flutter SQLite databases.

This is meant for app-side upgrades when the database is local to the device and the upgrade logic should stay in Dart code.

Use it for:

- additive local schema changes
- backfills on local rows
- rebuild-heavy migrations where data must be copied into a replacement table
- offline-first apps with important local SQLite data

Do not use it as a replacement for reviewed shared-database migrations.

The intended startup shape is:

```dart
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

import 'generated/comon_orm_client.dart';

final migrator = SqliteFlutterMigrator(
  currentVersion: 3,
  migrations: <SqliteFlutterMigration>[
    SqliteFlutterMigration.sql(
      fromVersion: 1,
      toVersion: 2,
      debugName: 'add_user_names',
      statements: <String>[
        'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
        'ALTER TABLE users ADD COLUMN last_name TEXT NOT NULL DEFAULT "";',
      ],
    ),
    SqliteFlutterMigration.rebuildTable(
      fromVersion: 2,
      toVersion: 3,
      debugName: 'rebuild_todos',
      tableName: 'todos',
      createReplacementTableSql: '''
        CREATE TABLE todos_new (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          note TEXT,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      ''',
      replacementTableName: 'todos_new',
      copyData: (tx, sourceTable, targetTable) async {
        final oldRows = await tx.rawQuery(
          'SELECT id, title, description, is_done, created_at, updated_at FROM $sourceTable;',
        );
        for (final row in oldRows) {
          await tx.insert(targetTable, <String, Object?>{
            'id': row['id'],
            'title': row['title'],
            'note': row['description'],
            'status': row['is_done'] == 1 ? 'done' : 'todo',
            'created_at': row['created_at'],
            'updated_at': row['updated_at'],
          });
        }
      },
    ),
  ],
);

Future<void> main() async {
  await upgradeSqliteFlutterDatabase(
    databasePath: 'app.db',
    migrator: migrator,
  );

  final db = await GeneratedComonOrmClientFlutterSqlite.open(
    databasePath: 'app.db',
  );

  try {
    print(await db.todo.count());
  } finally {
    await db.close();
  }
}
```

Practical rules:

- use CLI-reviewed migrations for shared, staging, and production databases
- prefer reset over complex migration code when local data is disposable
- use `SqliteFlutterMigration.sql(...)` for simple additive steps
- use `SqliteFlutterMigration.rebuildTable(...)` or a custom migration callback for rebuild-heavy local upgrades
- keep upgrade first and runtime open second

## Scope

- The existing `comon_orm_sqlite` package remains the source of truth for CLI, migration, and introspection flows.
- Flutter and web runtime support are being added here incrementally instead of retrofitting those constraints into the VM-oriented SQLite package.
- The package now participates in the root pub workspace and monorepo validation scripts.
