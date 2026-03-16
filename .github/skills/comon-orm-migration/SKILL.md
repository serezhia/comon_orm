---
name: comon-orm-migration
description: 'Use when choosing or documenting migration strategy for comon_orm projects, especially across backend/shared databases, Flutter local SQLite, offline-first apps, and Flutter web. Helps decide between CLI-reviewed migrations, local reset/bootstrap, and Dart-coded app-side upgrade layers.'
argument-hint: 'What kind of project is this and what migration change are you making? Example: offline-first Flutter app, disposable local cache, production PostgreSQL rollout, or rebuild migration for local SQLite.'
user-invocable: true
disable-model-invocation: false
---

# comon_orm Migration Skill

## Purpose

Use this skill when the main problem is not schema syntax itself, but choosing the correct migration approach for a specific project shape.

This skill exists to stop three common mistakes:

- mixing shared-database migrations with local app bootstrap
- treating Flutter local upgrades like production CLI migration rollout
- over-engineering disposable local caches that should just be reset

## What This Skill Covers

- selecting a migration strategy by project type
- deciding between reset, additive local upgrade, and rebuild migration
- Flutter mobile and desktop local SQLite upgrades
- Flutter web migration boundaries
- shared database rollout guidance for PostgreSQL or SQLite
- startup flow separation: upgrade first, runtime open second
- the concrete Flutter migration wrapper API: `SqliteFlutterMigration`, `SqliteFlutterMigrator`, and `upgradeSqliteFlutterDatabase(...)`
- documentation guidance for migration decisions in this repository

## When To Use

Use this skill when the task mentions any of these triggers:

- offline-first
- Flutter migration
- local SQLite migration
- reset versus migrate
- rebuild table
- backfill local data
- startup upgrade flow
- disposable cache
- shared database rollout
- `migrate diff`, `status`, `apply`, or `rollback` together with app-side upgrade questions

## First Decision

Before loading references, classify the project into one of these buckets:

1. backend or shared database
2. Flutter app with disposable local SQLite cache
3. Flutter offline-first app with important local SQLite data
4. Flutter web app backed by a remote API only
5. Flutter web app with browser-local storage that must be upgraded in place

Then load only the matching references.

## Minimal Loading Plan

### For strategy selection by project type

Load:

- [project matrix](./references/project-matrix.md)
- [playbooks](./references/playbooks.md)

### For Flutter local SQLite migrations

Load:

- [Flutter local migrations](./references/flutter-local-migrations.md)
- [project matrix](./references/project-matrix.md)

### For shared database rollout and reviewed migrations

Load:

- [shared database migrations](./references/shared-db-migrations.md)
- [playbooks](./references/playbooks.md)

## Core Rules

- Treat `schema.prisma` as the schema source of truth.
- Keep reviewed CLI migrations and local app-side upgrades as separate layers.
- Keep normal runtime `open(...)` separate from schema-changing upgrade code.
- Prefer reset over complex migrations for disposable local caches.
- Use Dart-coded versioned migrations only when local data matters.
- For Flutter/local SQLite, prefer the package wrapper API instead of inventing an app-specific migration mini-framework from scratch.
- Treat risky destructive local upgrades as explicit application code, not framework magic.
- Do not describe Flutter app-side migrations as full Prisma-style migration parity.

## Standard Workflow

1. Identify the project shape.
2. Decide whether the database is disposable or important.
3. Confirm whether the change is additive, backfill-only, or rebuild/destructive.
4. Choose the correct owner:
   CLI migration tooling for shared databases, or explicit app-side upgrade code for local Flutter databases.
5. Keep startup split explicit:
   upgrade first, open generated runtime second.
6. When the task is Flutter/local SQLite, map the recommendation onto the actual wrapper API:
   `SqliteFlutterMigration.sql(...)`, `SqliteFlutterMigration.rebuildTable(...)`, `SqliteFlutterMigrator`, and `upgradeSqliteFlutterDatabase(...)`.
7. Validate the chosen path against docs, tests, and safety rules.

## Completion Checks

Consider the task complete only when the following are true:

- the project type was classified correctly
- reset versus migrate was decided explicitly
- shared database rollout was not conflated with local app startup
- startup flow is described as upgrade first and runtime open second when local upgrades exist
- risky rebuilds or destructive changes were called out clearly
- the recommendation uses the real package API names when the task is about Flutter/local SQLite
- referenced docs and examples match the chosen migration path

## References

- [project matrix](./references/project-matrix.md)
- [Flutter local migrations](./references/flutter-local-migrations.md)
- [shared database migrations](./references/shared-db-migrations.md)
- [playbooks](./references/playbooks.md)

## Example Prompts

- Use the comon-orm-migration skill to decide whether a Flutter app should reset local SQLite or run a rebuild migration.
- Use the comon-orm-migration skill to explain the correct rollout path for a shared PostgreSQL database.
- Use the comon-orm-migration skill to design a startup flow for an offline-first Flutter app.
- Use the comon-orm-migration skill to document the difference between CLI migrations and local app-side upgrades.
