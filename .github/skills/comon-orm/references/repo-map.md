# comon_orm Repo Map And Capability Reference

This file is for repository layout, exports, and capability boundaries. If the task already knows it is about runtime usage, schema authoring, or commands, load the narrower reference first.

## Packages

- `packages/comon_orm`
  - schema parser, validator, workflow, codegen, query models, shared migration helpers
- `packages/comon_orm_postgresql`
  - PostgreSQL adapter, migrations, applier, introspector, provider CLI
- `packages/comon_orm_sqlite`
  - SQLite adapter, migrations, applier, introspector, provider CLI

## Key Exports

Core exports from `packages/comon_orm/lib/comon_orm.dart`:

- schema AST, parser, validator, workflow
- client base and query models
- code generator
- migration artifacts and migration risk analysis

PostgreSQL exports from `packages/comon_orm_postgresql/lib/comon_orm_postgresql.dart`:

- `PostgresqlDatabaseAdapter`
- `PostgresqlMigrationCli`
- `PostgresqlMigrationService`
- `PostgresqlMigrationRunner`
- `PostgresqlSchemaApplier`
- `PostgresqlSchemaIntrospector`

SQLite exports from `packages/comon_orm_sqlite/lib/comon_orm_sqlite.dart`:

- `SqliteDatabaseAdapter`
- `SqliteMigrationCli`
- `SqliteMigrationService`
- `SqliteMigrationRunner`
- `SqliteSchemaApplier`
- `SqliteSchemaIntrospector`

## Current Capability Highlights

- schema-first workflow inspired by Prisma
- supported top-level blocks: `model`, `enum`, `datasource`, `generator`
- relations: one-to-one, one-to-many, named relations, self-relations, compound references
- implicit many-to-many across single-field and compound key sets
- PostgreSQL native enums and provider-specific `@db.*` subset
- SQLite rebuild-based migration path and narrower native type subset
- unified `comon_orm migrate ...` dispatcher based on `datasource.provider`
- migration history metadata in `_comon_orm_migrations` with provider, checksum, warnings, rebuild flag, and before/after schema snapshots
- `openFromSchemaPath(...)` helpers for schema-driven runtime bootstrap in both SQL providers
- `openAndApplyFromSchemaPath(...)` helpers for local disposable bootstrap in both SQL providers
- generated clients emit compound `WhereUniqueInput` selectors and aggregate/groupBy surfaces

## Current Migration Model

- `migrate diff` writes migration artifacts to disk
- `migrate apply` recalculates a plan from the live database to the current schema and records history
- local artifacts remain important for review, `status`, and `rollback`
- rollback can use local `before.prisma` or snapshots stored in `_comon_orm_migrations`

## Repository Docs To Load When Needed

- `README.md` for top-level usage, migration semantics, and runtime bootstrap
- `MIGRATIONS.md` for rollout guidance and risk handling
- `SCHEMA_REFERENCE.md` for supported schema constructs and examples
- `examples/postgres/README.md` for a runnable end-to-end example

## Practical Rules

- prefer the generated client for app-facing usage examples
- prefer `openFromSchemaPath(...)` over manual schema parsing for normal adapter bootstrap
- use `openAndApplyFromSchemaPath(...)` only for local disposable startup
- prefer unified migration commands before dropping to provider-specific CLIs
- treat warning-bearing migration plans as blocked unless the task explicitly allows destructive changes
- do not describe `migrate apply` as replaying checked-in migration SQL files
- validate unsupported or partial Prisma features before implementing around them

## Typical Source Files

- `packages/comon_orm/lib/src/schema/`: parser, validator, workflow, AST
- `packages/comon_orm/lib/src/codegen/`: generated client emitter
- `packages/comon_orm/lib/src/migrations/`: shared artifact and risk-analysis helpers
- `packages/comon_orm_postgresql/lib/src/`: PostgreSQL adapter, CLI, planner, runner, service, applier, introspector
- `packages/comon_orm_sqlite/lib/src/`: SQLite adapter, CLI, planner, runner, service, applier, introspector
