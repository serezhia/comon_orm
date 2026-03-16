# Changelog

## 0.0.1-alpha.1

- Added generated-metadata runtime opening through `openFromGeneratedSchema(...)` and generated PostgreSQL client helpers.
- Moved normal runtime usage away from schema-path bootstrap toward generated metadata plus runtime datasource resolution.
- Updated adapter/runtime tests to cover generated runtime metadata flows.
- Refreshed docs and examples to match the generated-runtime-first PostgreSQL path.

## 0.0.1-alpha

- First public alpha release.
- Added the PostgreSQL runtime adapter for `comon_orm`.
- Added PostgreSQL schema application, introspection, migration planning, apply, rollback, and status workflows.
- Added adapter bootstrap helpers from `schema.prisma` and PostgreSQL connection URLs.
