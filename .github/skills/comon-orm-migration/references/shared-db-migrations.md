# Shared Database Migrations Reference

Use this file when the database is shared, long-lived, or production-like.

## Correct Owner

Shared databases are owned by CLI and VM migration tooling, not by Flutter app runtime code.

## Recommended Flow

1. edit `schema.prisma`
2. run `check` and `generate`
3. run `migrate diff`
4. review `migration.sql`, `warnings.txt`, `before.prisma`, and `after.prisma`
5. commit schema and migration artifacts together
6. run `migrate status` against the target database
7. run `migrate apply`
8. verify with `migrate history` and `migrate status`

## Commands

```bash
dart run comon_orm check schema.prisma
dart run comon_orm generate schema.prisma
dart run comon_orm migrate diff --schema schema.prisma --name <migration_name> --out prisma/migrations
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
dart run comon_orm migrate apply --schema schema.prisma --name <migration_name>
dart run comon_orm migrate history --schema schema.prisma
```

## Important Semantics

- `diff` writes reviewed artifacts to disk
- `apply` recalculates the plan from the live database to the current schema
- warnings are blocking by default
- production runtime should not auto-apply schema changes on startup

## Rollout Rules

- run `status` before shared-environment apply
- keep migration artifacts in git
- do not rewrite artifacts that were already applied
- prefer a forward fix over panic rollback when data risk is unclear
