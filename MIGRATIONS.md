# Migrations

This project supports two different schema workflows, and mixing them is where most mistakes come from:

- local bootstrap for disposable databases
- real migrations for shared, staging, and production databases

If the database matters, use migrations. Do not rely on runtime auto-apply in production.

## The Short Version

- `openAndApplyFromSchemaPath(...)` is for local development, examples, tests, and throwaway databases.
- `dart run comon_orm migrate diff ...` creates a reviewed migration artifact on disk.
- `dart run comon_orm migrate apply ...` applies the current schema to the live database and records migration history.
- `dart run comon_orm migrate status ...` is the first command to run when local files and the database may have diverged.
- `rollback` exists, but the safer default in production is usually a forward fix.

## Recommended Local Development Flow

Use this flow when you are developing alone against a disposable local database.

1. Edit `schema.prisma`.
2. Run validation and code generation.
3. Start the app against a local database.
4. Let the app bootstrap missing tables with `openAndApplyFromSchemaPath(...)` if you want the fastest loop.

Typical commands:

```bash
dart run comon_orm validate schema.prisma
dart run comon_orm generate schema.prisma
```

Typical bootstrap usage:

```dart
final adapter = await PostgresqlDatabaseAdapter.openAndApplyFromSchemaPath(
  schemaPath: 'schema.prisma',
);
```

or:

```dart
final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
  schemaPath: 'schema.prisma',
);
```

This is intentionally convenient, but it is not the disciplined deployment path.

## Recommended Shared Dev, Staging, And Production Flow

Use the same migration process for any database that is shared, long-lived, or contains data you care about.

1. Edit `schema.prisma`.
2. Run `validate` and `generate`.
3. Draft a migration with `migrate diff`.
4. Review the generated `migration.sql`, `warnings.txt`, `before.prisma`, and `after.prisma`.
5. Commit the schema change, generated client, and migration directory together.
6. Before applying to production, take a backup or ensure point-in-time recovery exists.
7. Run `migrate status` against the target database.
8. Apply with `migrate apply`.
9. Verify with `migrate history` and `migrate status`.

Typical commands:

```bash
dart run comon_orm validate schema.prisma
dart run comon_orm generate schema.prisma

dart run comon_orm migrate diff \
  --schema schema.prisma \
  --name 20260315_add_user_role \
  --out prisma/migrations

dart run comon_orm migrate status \
  --schema schema.prisma \
  --from prisma/migrations

dart run comon_orm migrate apply \
  --schema schema.prisma \
  --name 20260315_add_user_role

dart run comon_orm migrate history \
  --schema schema.prisma
```

## Important Nuance: `diff` And `apply` Are Not The Same Step

This project does not currently replay the checked-in `migration.sql` file during `apply`.

The current model is:

- `diff` compares the live database to the current schema and writes a migration artifact to disk
- `apply` compares the live database to the current schema again and executes the plan against the database
- migration artifacts on disk are still important for review, audit, `status`, and `rollback`

That means the right mental model is not "generate SQL once and blindly replay that exact file later".

The right mental model is "review the planned transition, keep the artifact in git, then apply the same schema target deliberately to the real database".

Because of that:

- do not edit checked-in migration artifacts after they were applied
- do not treat `migration.sql` as the only source of truth
- keep `schema.prisma` and migration artifacts in sync in the same commit

## Warnings And `--allow-warnings`

`apply` and `rollback` stop by default when the planner detects risky changes.

Examples:

- dropping a column or model
- changing a type in a way that may lose data
- shrinking enum values
- SQLite rebuild scenarios
- manual-migration cases that the planner cannot safely express

Use `--allow-warnings` only after reviewing the plan and explicitly accepting the risk.

If you need `--allow-warnings` in production, the bar should be higher:

- inspect the draft SQL and warnings
- confirm backup/restore exists
- understand whether data copy, cast, or rebuild will happen
- schedule the change with enough operational room

## What `status` Is For

`status` compares local migration artifacts with active migration history stored in `_comon_orm_migrations`.

Common issue codes:

- `checksum-mismatch`: the local migration artifact was changed after being applied
- `applied-migration-missing-locally`: the database has a migration record that does not exist on disk
- `local-migration-not-applied`: the repo has a migration that is not active in the database
- `missing-db-snapshot`: an older applied migration predates stored before/after schema snapshots
- `invalid-local-artifacts`: local migration metadata is incomplete or malformed

If `status` is not clean, stop and resolve the mismatch before applying new changes.

## Rollback Guidance

Rollback works by restoring a previous schema target using local `before.prisma` or snapshots stored in `_comon_orm_migrations`.

Typical command:

```bash
dart run comon_orm migrate rollback \
  --schema schema.prisma \
  --from prisma/migrations
```

Important points:

- rollback may also surface warnings and require `--allow-warnings`
- rollback is not guaranteed to be harmless if the forward migration was destructive
- for production incidents, a new forward migration is often safer than repeated rollback/roll-forward churn

Use rollback when you understand the target state and the data implications.

## Provider-Specific Nuances

### PostgreSQL

- supports richer in-place changes than SQLite
- enum changes are supported in more cases, but destructive enum transitions still need review
- some operations still surface manual-migration warnings instead of being auto-applied

### SQLite

- many schema changes require table rebuilds instead of simple `ALTER TABLE`
- rebuild-required plans copy scalar data into a recreated table
- destructive changes deserve extra review because local file-backed databases are easy to damage permanently

For SQLite especially, keep backups of real data files before applying risky changes.

## Practical Rules

- Use `openFromSchemaPath(...)` for normal runtime bootstrap.
- Use `openAndApplyFromSchemaPath(...)` only for disposable local environments.
- Never auto-apply schema on application startup in production.
- Always run `status` before applying to a shared environment.
- Review warnings before using `--allow-warnings`.
- Keep migration directories in git.
- Do not rewrite migration artifacts that are already recorded in a live database.

## Related Docs

- `README.md`
- `packages/comon_orm/README.md`
- `packages/comon_orm_postgresql/README.md`
- `packages/comon_orm_sqlite/README.md`
- `examples/postgres/README.md`
- `SCHEMA_REFERENCE.md`
