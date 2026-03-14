# comon_orm

`comon_orm` is a Prisma-inspired schema-first ORM toolkit for Dart.

This repository is a monorepo for three publishable packages plus an example application. Each package has its own README, example, and release surface.

## Packages

- `comon_orm`: provider-agnostic schema parsing, validation, formatting, code generation, query models, migration metadata, and the in-memory adapter
- `comon_orm_postgresql`: PostgreSQL runtime adapter, schema introspection, DDL, and migration workflow
- `comon_orm_sqlite`: SQLite runtime adapter, schema introspection, DDL, and rebuild-based migrations
- `examples/postgres`: runnable Dart Frog example backed by PostgreSQL

## Start Here

- For schema parsing, code generation, or in-memory testing, read `packages/comon_orm/README.md`
- For PostgreSQL-backed applications, read `packages/comon_orm_postgresql/README.md`
- For SQLite-backed applications, read `packages/comon_orm_sqlite/README.md`
- For local-vs-production migration practice, read `MIGRATIONS.md`
- For release order and pre-publish checks, read `RELEASING.md`

## Current Scope

The project is Prisma-inspired, not full Prisma parity. The stable surface today includes:

- `schema.prisma` parsing, validation, formatting, and Dart client generation
- `@id`, `@unique`, `@@id`, `@@unique`, `@@index`, `@@map`, `@map`, `@updatedAt`, defaults, enums, and mapped names
- one-to-one, one-to-many, named relations, self-relations, compound references, and implicit many-to-many relations
- PostgreSQL adapter support with schema introspection and migrations
- SQLite adapter support with schema introspection and rebuild-based migrations

Known limits still apply for advanced Prisma features, broader `@db.*` parity, and some provider-specific edge cases. The package READMEs describe the practical scope for each adapter more directly.

## Monorepo Development

This repository uses a Dart pub workspace rooted at `pubspec.yaml`.

- provider packages keep hosted constraints for publishing
- inside the workspace, inter-package dependencies resolve to local workspace packages automatically
- run `dart pub get` once at the repo root for a shared resolution

Typical validation flow:

```bash
dart pub get

dart run tool/format_all.dart
dart run tool/analyze_all.dart
dart run tool/test_all.dart
dart run tool/dry_run_all.dart

dart run tool/pre_publish.dart
```

Available root helpers:

- `dart run tool/format_all.dart`
- `dart run tool/analyze_all.dart`
- `dart run tool/test_all.dart`
- `dart run tool/dry_run_all.dart`
- `dart run tool/pre_publish.dart`

In VS Code the same flows are available as tasks:

- `format: all packages`
- `analyze: all packages`
- `test: all packages`
- `publish: dry-run all`
- `pre-publish`

These helpers replace the old manual per-package loop:

```bash

cd packages/comon_orm
dart analyze
dart test

cd ../comon_orm_postgresql
dart analyze
dart test

cd ../comon_orm_sqlite
dart analyze
dart test
```

## Documentation Map

- `SCHEMA_REFERENCE.md`: Prisma-style schema guide and support notes
- `MIGRATIONS.md`: practical migration workflow for local development, shared environments, and production
- `examples/postgres/README.md`: runnable PostgreSQL example setup
