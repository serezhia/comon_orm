# Changelog

## 0.0.1-alpha.2

- Added native provider-side upsert and `createMany(skipDuplicates)` execution paths instead of transaction-heavy fallbacks.
- Added include planning plus JOIN/batch eager-loading improvements across SQL adapters and generated clients.
- Added middleware decoration APIs, SQL pushdown for `distinct + cursor`, and CI/pub.dev release validation updates.

## 0.0.1-alpha.1

- Added generated runtime metadata so generated clients can open adapters without re-reading `schema.prisma` at normal runtime.
- Added generated convenience helpers like `GeneratedComonOrmClient.openInMemory()`, runtime schema accessors, and close support on generated clients.
- Added runtime metadata bridge and datasource resolution APIs shared by adapters and generated clients.
- Updated the generator and examples toward generated-metadata-first runtime flows.

## 0.0.1-alpha

- First public alpha release.
- Added schema parsing, validation, formatting, and client generation from `schema.prisma`.
- Added provider-agnostic query models, migration metadata helpers, and the in-memory adapter.
- Added the unified `comon_orm` CLI with `check`, `format`, `generate`, and `migrate` commands.
