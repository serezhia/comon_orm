---
name: comon-orm
description: 'Use when working with comon_orm, schema.prisma, generated Dart clients, PostgreSQL or SQLite adapters, migrations, introspection, relation modeling, status/drift checks, and migration warning analysis. Helps implement, review, debug, and explain schema-first ORM workflows in this repository and apps built on it.'
argument-hint: 'What do you want to do with comon_orm? Example: add a model, debug a migration, explain relations, or wire a runtime adapter.'
user-invocable: true
disable-model-invocation: false
---

# comon_orm Skill

## Purpose

Use this skill to work on `comon_orm` without re-discovering the repository's schema, runtime, and migration conventions every time.

This skill is optimized for low-context loading:

- load only the reference file that matches the task shape
- prefer current repository docs over assumptions about Prisma
- keep the mental model aligned with the actual implementation, especially around migrations

## What This Skill Covers

- design or update `schema.prisma`
- validate and generate the Dart client
- choose the correct runtime adapter for PostgreSQL or SQLite
- create, inspect, apply, status-check, and roll back migrations
- reason about warnings, rebuilds, drift, snapshots, and relation semantics
- find the right source files and references before changing runtime or migration code

## When To Use

Use this skill when the task mentions any of these triggers:

- `comon_orm`
- `schema.prisma`
- generated client
- `openFromSchemaPath`
- PostgreSQL adapter
- SQLite adapter
- `migrate diff`, `migrate apply`, `migrate status`, `migrate rollback`
- `_comon_orm_migrations`
- drift, checksum mismatch, schema snapshots, migration warnings
- relations, implicit many-to-many, enums, `@db.*`, `@updatedAt`

## First Decision

Before loading any reference file, decide which bucket the task belongs to:

1. app/runtime usage
2. schema authoring or relation design
3. migrations, drift, status, or rollback
4. repository internals or capability lookup

Then load only the matching reference file.

## Minimal Loading Plan

### For app/runtime usage

Load:

- [Dart usage reference](./references/dart-usage.md)

Load additionally only if needed:

- [workflow reference](./references/workflow.md) when runtime changes interact with migrations
- [repo map and capability reference](./references/repo-map.md) when changing adapter internals

### For schema authoring or relation design

Load:

- [schema authoring reference](./references/schema-authoring.md)

Load additionally only if needed:

- [repo map and capability reference](./references/repo-map.md) for support boundaries
- [command reference](./references/commands.md) if the task also needs generation or migration commands

### For migrations, drift, and rollout questions

Load:

- [workflow reference](./references/workflow.md)
- [command reference](./references/commands.md)

Load additionally only if needed:

- [repo map and capability reference](./references/repo-map.md) for provider-specific behavior

### For repository internals or capability lookup

Load:

- [repo map and capability reference](./references/repo-map.md)

Load additionally only if needed:

- whichever one of the other references matches the concrete change

## Core Rules

- Treat `schema.prisma` as the schema source of truth.
- Prefer generated clients for app-facing examples.
- Prefer `openFromSchemaPath(...)` for normal runtime bootstrap.
- Treat `openAndApplyFromSchemaPath(...)` as a local-development convenience, not a shared or production migration strategy.
- Prefer unified `dart run comon_orm migrate ...` commands before package-specific CLIs.
- Treat warning-bearing migration plans as blocked unless the task explicitly accepts risk.
- Do not assume Prisma parity. Check repository support first.

## Standard Workflow

1. Identify the provider and task shape.
   Determine whether the request is about core schema/codegen, PostgreSQL runtime, SQLite runtime, or migration behavior.

2. Load the smallest useful reference set.
   Use the Minimal Loading Plan above instead of reading every reference file.

3. Confirm the schema-first source of truth.
   Prefer reading `schema.prisma`, generator output path, datasource provider, and migration artifacts before proposing runtime or SQL changes.

4. Branch by task type.
   For schema design or relation modeling: validate supported constructs, ownership rules, native types, and relation topology.
   For runtime usage: prefer `openFromSchemaPath(...)` and generated clients when possible.
   For migration work: inspect local artifacts, DB history, warnings, and whether the plan requires `--allow-warnings`.
   For debugging: compare the requested behavior against repository capabilities and current tests before changing code.

5. Apply the provider-specific path.
   PostgreSQL uses live DDL, introspection, native enums, and in-place FK updates where supported.
   SQLite uses a narrower native type surface and may require rebuilds or manual migration handling for unsupported destructive changes.

6. Validate the outcome.
   Prefer targeted tests for the touched package. For migration work, verify at least one of: schema introspection, migration history, status output, or preserved data after rebuild or rollback.

## Decision Points

### Provider Choice

- If `datasource.provider = "postgresql"`, use `comon_orm_postgresql` references, APIs, and migration expectations.
- If `datasource.provider = "sqlite"`, use `comon_orm_sqlite` references, APIs, and rebuild/manual-migration expectations.
- If the task is about shared CLI behavior, use the unified `dart run comon_orm migrate ...` flow first.

### Runtime Adapter Choice

- Prefer `PostgresqlDatabaseAdapter.openFromSchemaPath(...)` for PostgreSQL apps.
- Prefer `SqliteDatabaseAdapter.openFromSchemaPath(...)` for SQLite apps.
- Use `openAndApplyFromSchemaPath(...)` only for disposable local bootstrap, examples, and tests.
- Use lower-level parser or workflow APIs only when the task explicitly needs direct schema loading, validation, or codegen internals.

### Migration Risk Handling

- If `diff`, `apply`, or `rollback` surfaces warnings, treat them as blocking by default.
- Use `--allow-warnings` only when the task explicitly accepts potential data loss or destructive rebuild behavior.
- Remember that `diff` writes review artifacts, while `apply` recalculates a plan from the live database to the current schema. Do not describe it as replaying a checked-in `migration.sql` file.
- If rollback is requested, check both local migration artifacts and `_comon_orm_migrations` snapshots.
- If `status` reports checksum drift or missing artifacts, explain the mismatch before changing files.

### Debugging Branch

- If behavior differs between schema and runtime, inspect generated client output path, runtime adapter construction, and schema validation first.
- If behavior differs between local files and the database, inspect `status`, migration history, and snapshots before editing migration SQL.
- If the task sounds like unsupported Prisma parity, confirm the current implementation boundary before promising a change.

## Completion Checks

Consider the task complete only when the relevant checks have been covered:

- schema changes were validated against supported syntax and provider constraints
- generated client flow or adapter bootstrap path is correct
- migration commands and artifact locations are correct for the chosen provider
- local bootstrap guidance was not conflated with shared/prod migration guidance
- warning-bearing destructive changes are explicitly acknowledged
- relevant tests, introspection, or status/history checks were run or the limitation was stated clearly

## References

- [workflow reference](./references/workflow.md)
- [command reference](./references/commands.md)
- [Dart usage reference](./references/dart-usage.md)
- [schema authoring reference](./references/schema-authoring.md)
- [repo map and capability reference](./references/repo-map.md)

## Example Prompts

- Use the comon_orm skill to add a `Todo` model with a relation to `User` and update the migration flow.
- Use the comon_orm skill to explain why `migrate status` reports checksum drift.
- Use the comon_orm skill to wire a PostgreSQL adapter from `schema.prisma` with the generated client.
- Use the comon_orm skill to review whether a schema change will require `--allow-warnings`.
- Use the comon_orm skill to find where implicit many-to-many support lives in this repo.
