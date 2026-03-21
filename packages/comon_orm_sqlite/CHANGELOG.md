# Changelog

## 0.0.1-alpha.2

- Added native SQLite upsert/version-gated fallbacks plus batched `createMany(...)` and native `skipDuplicates` handling.
- Split the runtime into SQL-builder, relation-materializer, and transaction modules while keeping the adapter surface stable.
- Added SQL pushdown for `distinct + cursor` queries and broader include-strategy coverage.

## 0.0.1-alpha.1

- Added generated-metadata runtime opening through `openFromGeneratedSchema(...)` and generated SQLite client helpers.
- Added runtime-metadata-backed adapter paths for embedded SQLite and in-memory workflows.
- Updated adapter/runtime tests to validate generated metadata parity and runtime behavior.
- Refreshed docs and examples to use the generated-runtime-first SQLite path.

## 0.0.1-alpha

- First public alpha release.
- Added the SQLite runtime adapter for `comon_orm`.
- Added SQLite schema application, introspection, migration planning, apply, rollback, and status workflows.
- Added embedded database and in-memory workflows for local apps and tests.
