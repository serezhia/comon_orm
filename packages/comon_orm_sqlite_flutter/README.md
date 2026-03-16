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
- local `openAndApply...` helpers for schema-driven bootstrap

Planned next:

- wider runtime coverage tests against relation and aggregate scenarios
- alternate runtime backends if the project later wants to support something beyond the current `sqflite` path

Implementation phases are tracked in [PLAN.md](PLAN.md).

## Quick Start

Add dependencies:

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_sqlite_flutter: ^0.0.1-alpha
```

Resolve a database path from `schema.prisma`, apply the schema, and use the adapter:

```dart
import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

Future<void> main() async {
  final adapter = await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaPath(
    schemaPath: 'schema.prisma',
  );

  try {
    final created = await adapter.create(
      const CreateQuery(
        model: 'User',
        data: <String, Object?>{'email': 'alice@example.com'},
      ),
    );

    print(created['email']);
  } finally {
    await adapter.close();
  }
}
```

## Scope

- The existing `comon_orm_sqlite` package remains the source of truth for CLI, migration, and introspection flows.
- Flutter and web runtime support are being added here incrementally instead of retrofitting those constraints into the VM-oriented SQLite package.
- The package now participates in the root pub workspace and monorepo validation scripts.
