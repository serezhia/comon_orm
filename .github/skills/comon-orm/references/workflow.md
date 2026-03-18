# comon_orm Workflow Reference

This file is for choosing the right workflow. If the task only needs commands, load `commands.md` instead.

## Choose The Correct Workflow First

There are two valid workflows in this repository:

1. local setup/bootstrap for disposable databases
2. real migrations for shared, staging, and production databases

Most mistakes happen when they get mixed.

## Standard App Workflow

1. Create or update `schema.prisma`.
2. Run validation.
3. Generate the Dart client.
4. Use the adapter that matches `datasource.provider`.
5. For schema changes, create a migration draft before applying it.
6. Run `status` or `history` when drift, rollback, or local artifact mismatches are suspected.

## Core Commands

```bash
dart run comon_orm check
dart run comon_orm generate
```

## Local Setup Workflow

Use this only for local development, throwaway databases, tests, and examples.

Rules:

- runtime should still open through generated metadata after setup is done
- not the recommended production rollout path
- do not recommend startup auto-apply for shared environments

## Shared And Production Migration Workflow

Use this for any database that matters.

```bash
dart run comon_orm migrate dev --name <migration_name>
dart run comon_orm migrate status
dart run comon_orm migrate deploy
dart run comon_orm migrate resolve --applied <migration_name>
```

Recommended sequence:

1. edit `schema.prisma`
2. run `check` and `generate`
3. run `migrate dev --create-only` when you want to review artifacts before applying
4. review `migration.sql`, `warnings.txt`, `before.prisma`, and `after.prisma`
5. commit schema changes and migration artifacts together
6. run `status` against the target database before applying
7. run `migrate deploy` in the target environment
8. verify with `status`

## Important Migration Semantics

- `diff` writes migration artifacts to disk for review, status checks, and rollback metadata.
- `migrate dev` applies pending local migrations first, then drafts and optionally applies the next migration.
- `apply` recalculates the plan from the live database to the current schema.
- do not describe `apply` as replaying the exact checked-in `migration.sql`
- migration artifacts are still important and should stay in git

## Runtime Bootstrap Patterns

Normal runtime usage after the database is already in the expected shape:

PostgreSQL:

```dart
final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
  schema: GeneratedComonOrmClient.runtimeSchema,
);
```

SQLite:

```dart
final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(
  schema: GeneratedComonOrmClient.runtimeSchema,
);
```

## Migration Safety Rules

- `apply` and `rollback` stop by default when warnings are present.
- Warnings often indicate possible data loss or a destructive rebuild.
- `status` is the first check when local migration files and the live database may have diverged.
- Rollback first looks for local `before.prisma`; if missing, newer history rows can fall back to stored DB snapshots.
- For production incidents, a forward fix is often safer than repeated rollback and roll-forward churn.

## Good Validation Endpoints

- run focused tests in the relevant package
- introspect the live schema after apply or rollback
- inspect `_comon_orm_migrations` through `history` or package-level services
- confirm data preservation after rebuild or rollback when destructive changes are involved

## Load These Docs Next When Needed

- `commands.md` for exact CLI forms
- `dart-usage.md` for app code patterns
- `repo-map.md` for capability boundaries
