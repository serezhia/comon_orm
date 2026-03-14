# comon_orm_postgresql

PostgreSQL adapter for `comon_orm`.

Use this package when your schema declares `provider = "postgresql"` and you need a real runtime adapter, schema introspection, and migrations against PostgreSQL-compatible infrastructure.

## Why This Package

`comon_orm_postgresql` bundles the PostgreSQL-specific parts that do not belong in the provider-agnostic core:

- runtime `DatabaseAdapter` implementation backed by `package:postgres`
- connection helpers for opening adapters from a URL or directly from `schema.prisma`
- schema application and introspection
- migration planning, apply, rollback, history, and status helpers
- the provider implementation targeted by `dart run comon_orm migrate ...`

## Quick Start

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_postgresql: ^0.0.1-alpha
```

```dart
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await PostgresqlDatabaseAdapter.openFromSchemaPath(
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
    await adapter.close();
  }
}
```

If you want a single helper for local development that also creates missing tables, use `openAndApplyFromSchemaPath(...)`:

```dart
final adapter = await PostgresqlDatabaseAdapter.openAndApplyFromSchemaPath(
  schemaPath: 'schema.prisma',
);
```

The package `example/` folder uses this simpler development bootstrap flow and keeps a generated client checked in for readability. Regenerate it with `dart run comon_orm generate example/schema.prisma` when the schema changes.

## Migrations

Most users should call migrations through the unified core CLI:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260314_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260314_init
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

The dispatcher reads `datasource.provider` and forwards the command to this package. The package-level executable is still useful for direct debugging, but it is not the main user story.

For the full recommended workflow, including why `openAndApplyFromSchemaPath(...)` is for local development only and how `diff` vs `apply` behaves, read `../../MIGRATIONS.md` from the repo root.

## Capabilities

- PostgreSQL runtime adapter backed by pooled `package:postgres` sessions
- adapter bootstrap from `schema.prisma` via `openFromSchemaPath(...)`
- one-call development bootstrap via `openAndApplyFromSchemaPath(...)`
- schema application and introspection for the supported PostgreSQL surface
- migration planning, apply, rollback, history, and status helpers
- SQL pushdown for aggregate and group-by queries

## Scope

- The package targets PostgreSQL semantics, not generic SQL semantics.
- Destructive enum transitions and other risky changes still surface warnings and may require manual review.
- The project does not promise CockroachDB or full Prisma parity at this stage.

## Related Packages

- `comon_orm` for the schema parser, generator, query models, and unified CLI
- `comon_orm_sqlite` for the embedded SQLite workflow
