# Troubleshooting

Common problems in `comon_orm` usually come from mixing schema/tooling flows with runtime flows, or from treating local app-side SQLite upgrades like reviewed shared-database migrations.

## I Migrated And Data Disappeared

This usually means one of two things happened:

1. a destructive change was applied after warnings were accepted
2. a SQLite rebuild plan recreated a table and only copied compatible scalar columns

What to check:

- inspect `warnings.txt` in the drafted migration directory
- run `dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations`
- inspect `_comon_orm_migrations` history and look at `before_schema`, `after_schema`, and `rebuild_required`
- for Flutter local SQLite, review your `SqliteFlutterMigration` steps or `SqliteFlutterMigration.schemaDiff(...)` source and confirm the replacement table still contains the columns you expected to preserve

Important:

- `--allow-warnings` means the planner detected a risky transition and you accepted it explicitly
- SQLite rebuild paths preserve compatible scalar columns, not arbitrary dropped or reshaped data
- reviewed shared-database migrations and app-side local upgrades are different workflows

## Status Reports `checksum-mismatch`

The local migration artifact on disk no longer matches what was recorded in the database.

Typical causes:

- someone edited an applied migration directory after it had already been used
- the repo and the database point at different migration histories

What to do:

- stop before applying anything new
- compare the local migration directory with the migration record in `_comon_orm_migrations`
- restore the checked-in migration artifact or create a new forward migration instead of mutating old artifacts

## Status Reports `applied-migration-missing-locally`

The database has an active migration record that does not exist in the local migration directory.

What to do:

- fetch the missing migration from version control if it should exist
- if the database was migrated from a different branch or environment, reconcile history before proceeding

## Status Reports `local-migration-not-applied`

The repo contains a migration artifact that is not active in the database.

This can mean:

- the database is behind the repo
- you are pointed at the wrong database
- a rollback removed that migration from the active set

## Status Reports `local-artifacts-unavailable`

This appears on web targets when a status flow tries to inspect file-backed migration directories.

Meaning:

- the web-safe artifact layer is available
- direct filesystem-backed migration artifact loading is not available in browser targets

What to do:

- for browser-local SQLite, use app-side upgrade code through `comon_orm_sqlite_flutter`
- for shared database rollout, run CLI migration tooling in a VM/server environment

## Generated Client Compiles But Runtime Fails On Missing Tables

`generate` only emits the client. It does not apply schema changes to a real database.

What to do:

- use reviewed CLI migrations for shared PostgreSQL or shared SQLite databases
- use explicit local setup/bootstrap for disposable local databases
- use `SqliteFlutterMigrator` or `SqliteFlutterMigration.schemaDiff(...)` before opening the normal Flutter SQLite runtime when local data must be upgraded in place

## Cursor Pagination Is Slow Or Behaves Differently With `distinct`

Current behavior:

- cursor pagination is pushed into SQLite and PostgreSQL adapters for the normal ordered path
- `distinct + cursor` still uses the fallback path because the adapter-native pushdown is not used for that combination yet

What to do:

- prefer stable `orderBy` without `distinct` for large datasets when possible
- keep cursor selectors unique and aligned with the ordered fields

## PostgreSQL `@db.Xml` Returns Unexpected Bytes Wrappers

Current behavior already normalizes PostgreSQL XML values from `pg.UndecodedBytes` into `String` in the adapter layer.

If you still see byte-like values:

- confirm you are using the current adapter package version
- confirm the field is declared as `String @db.Xml`

## Flutter SQLite Migration Strategy Is Unclear

Use this decision rule:

- disposable local cache: reset is often better than migration code
- important device-local data: use explicit app-side upgrades
- shared backend database: use reviewed CLI migrations outside the app

## Recommended Commands

Shared database check:

```bash
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

Workspace validation:

```bash
dart run tool/analyze_all.dart
dart run tool/test_all.dart
```