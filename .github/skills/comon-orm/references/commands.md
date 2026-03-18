# comon_orm Command Reference

This file is for commands only. If the task is about workflow decisions or migration semantics, load `workflow.md` instead of expanding this file in your answer.

## Core Schema Commands

```bash
dart run comon_orm check
dart run comon_orm validate
dart run comon_orm format
dart run comon_orm generate
```

Notes:

- `check` is the preferred command name.
- `validate` still works as an alias.

## Unified Migration Commands

Use these first. The dispatcher resolves `datasource.provider` from `schema.prisma` and forwards to the matching provider package.

```bash
dart run comon_orm migrate dev --name 20260315_init
dart run comon_orm migrate dev --create-only
dart run comon_orm migrate deploy
dart run comon_orm migrate status
dart run comon_orm migrate reset --force
dart run comon_orm migrate resolve --applied 20260315_init
dart run comon_orm migrate diff --from-database --to-schema prisma/schema.prisma --script
dart run comon_orm db push
```

Legacy commands still exist with deprecation warnings:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init --out prisma/migrations
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate history --schema schema.prisma
dart run comon_orm migrate rollback --schema schema.prisma --from prisma/migrations --allow-warnings
```

## Provider-Specific Migration Commands

Use these only when the task explicitly needs provider-level debugging.

PostgreSQL:

```bash
dart run comon_orm_postgresql:comon_orm_postgresql dev --name 20260315_init
dart run comon_orm_postgresql:comon_orm_postgresql deploy
dart run comon_orm_postgresql:comon_orm_postgresql push
```

SQLite:

```bash
dart run comon_orm_sqlite:comon_orm_sqlite dev --name 20260315_init
dart run comon_orm_sqlite:comon_orm_sqlite deploy
dart run comon_orm_sqlite:comon_orm_sqlite push
```

## Runtime Bootstrap Commands

These are the normal codegen and app bootstrap steps, not deployment steps.

```bash
dart run comon_orm generate
```

Normal runtime bootstrap in app code:

- `PostgresqlDatabaseAdapter.openFromGeneratedSchema(...)`
- `SqliteDatabaseAdapter.openFromGeneratedSchema(...)`

## Package-Level Test Commands

Core:

```bash
cd packages/comon_orm
dart test
```

PostgreSQL:

```bash
cd packages/comon_orm_postgresql
dart test
```

SQLite:

```bash
cd packages/comon_orm_sqlite
dart test
```

## Common Investigation Targets

- `packages/comon_orm/lib/comon_orm.dart`
- `packages/comon_orm_postgresql/lib/comon_orm_postgresql.dart`
- `packages/comon_orm_sqlite/lib/comon_orm_sqlite.dart`
- `README.md`
- `site/content/docs/migrations/index.mdx`
- `site/content/docs/schema/reference.mdx`

## Status And Drift Interpretation

- `checksum-mismatch`: the local migration artifact differs from what was recorded in the database
- `applied-migration-missing-locally`: DB history references a migration not present on disk
- `local-migration-not-applied`: local migration exists but is not active in the database
- `missing-db-snapshot`: migration was applied before snapshot fields were stored in `_comon_orm_migrations`
- `invalid-local-artifacts`: local migration metadata or files are malformed or incomplete

## Command Selection Rules

- Use `check` for new docs and examples.
- Use unified `comon_orm migrate ...` commands by default.
- `schema.prisma` is auto-discovered from `prisma/schema.prisma` or `schema.prisma` when `--schema` is omitted.
- Mention provider-specific executables only when debugging dispatcher behavior or provider CLIs directly.
- Do not describe `migrate apply` as replaying checked-in `migration.sql` files.
