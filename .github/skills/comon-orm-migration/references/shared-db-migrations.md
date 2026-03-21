# Shared Database Migrations Reference

Use this file when the database is shared, long-lived, or production-like.

## Correct Owner

Shared databases are owned by CLI and VM migration tooling, not by Flutter app runtime code.

## Recommended Flow

1. edit `schema.prisma`
2. run `check` and `generate`
3. run `migrate dev`
4. review `migration.sql`, `warnings.txt`, `before.prisma`, `after.prisma`, and `metadata.txt`
5. commit schema and migration artifacts together
6. run `migrate status` against the target database
7. run `migrate deploy`
8. verify with `migrate status`

## Commands

```bash
dart run comon_orm check
dart run comon_orm generate
dart run comon_orm migrate dev --name <migration_name>
dart run comon_orm migrate status
dart run comon_orm migrate deploy
```

## Important Semantics

- `dev` creates the next local migration artifact, applies it locally, and refreshes generated code
- `deploy` applies already-created local migrations to the target database
- warnings are blocking by default
- production runtime should not auto-apply schema changes on startup

## Rollout Rules

- run `status` before shared-environment deploy
- keep migration artifacts in git
- do not rewrite artifacts that were already applied
- prefer a forward fix over panic rollback when data risk is unclear
