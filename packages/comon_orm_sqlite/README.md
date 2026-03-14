# comon_orm_sqlite

SQLite adapter for `comon_orm`.

Use this package when your schema declares `provider = "sqlite"` and you want an embedded database workflow with schema-aware runtime behavior, introspection, and migrations.

## Why This Package

`comon_orm_sqlite` is the local-database companion for the core package. It gives you:

- runtime `DatabaseAdapter` implementation backed by `sqlite3`
- in-memory and file-backed SQLite workflows
- schema application and introspection for the supported SQLite surface
- migration planning, apply, rollback, history, and status helpers
- adapter bootstrap from `schema.prisma` datasource settings

## Quick Start

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_sqlite: ^0.0.1-alpha
```

```dart
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await SqliteDatabaseAdapter.openFromSchemaPath(
    schemaPath: 'schema.prisma',
  );
  try {
    final client = GeneratedComonOrmClient(adapter: adapter);

    final user = await client.user.create(
      data: const UserCreateInput(
        email: 'alice@example.com',
        name: 'Alice',
      ),
    );

    print(user.email);
  } finally {
    adapter.dispose();
  }
}
```

If you want a single helper for local development that also creates missing tables, use `openAndApplyFromSchemaPath(...)`:

```dart
final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
  schemaPath: 'schema.prisma',
);
```

The package `example/` folder uses this simpler development bootstrap flow and keeps a generated client checked in for readability. Regenerate it with `dart run comon_orm generate example/schema.prisma` when the schema changes.

## Migrations

The preferred flow is the unified core CLI:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260314_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260314_init
dart run comon_orm migrate rollback --schema schema.prisma --from prisma/migrations
```

The dispatcher reads `datasource.provider` and forwards the command to this package. The package-level executable is still available when you need it directly.

For the full recommended workflow, including local bootstrap vs real migrations and rebuild-related cautions, read `../../MIGRATIONS.md` from the repo root.

## Capabilities

- embedded runtime built on `sqlite3`
- schema application and introspection for the supported SQLite surface
- migration planning, apply, rollback, history, and status helpers
- bootstrap from `schema.prisma` through `openFromSchemaPath(...)`
- one-call development bootstrap through `openAndApplyFromSchemaPath(...)`

## Scope

- Some schema transitions still require table rebuilds, so warnings matter for destructive changes.
- SQLite keeps a narrower native type surface than PostgreSQL.
- Enum support uses SQLite-compatible storage rather than native enum types.

## Rebuild Semantics

SQLite cannot express every schema change with `ALTER TABLE`. When the planner detects one of those cases, it marks the migration as rebuild-required and copies scalar data into a recreated table. That keeps local workflows predictable, but destructive changes still need review before apply or rollback.

## Related Packages

- `comon_orm` for schema parsing, generation, query models, and the unified CLI
- `comon_orm_postgresql` for PostgreSQL-backed applications
