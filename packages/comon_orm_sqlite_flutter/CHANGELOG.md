# Changelog

## 0.0.1-alpha.1

- Added generated-metadata runtime opening through `openFromGeneratedSchema(...)` and generated Flutter SQLite client helpers.
- Added explicit local migration APIs with `SqliteFlutterMigration`, `SqliteFlutterMigrator`, and `upgradeSqliteFlutterDatabase(...)`.
- Added rebuild-table and SQL-first migration helpers for offline-first local SQLite upgrades.
- Updated docs, tests, and examples to separate local setup/migration flows from normal runtime opening.

## 0.0.1-alpha

- Initial Flutter-oriented SQLite package scaffold.
- Added schema-aware bootstrap helpers and platform database-factory selection.
- Ported the SQLite runtime adapter to `sqflite_common`.
- Added async schema apply and `openAndApply...` flows.
- Integrated the package into the root pub workspace and validation tooling.
