# comon_orm_sqlite_flutter Plan

This package is the Flutter-oriented SQLite runtime layer for `comon_orm`.

## Goals

- provide a SQLite runtime path for Flutter mobile, desktop, and web
- keep `comon_orm_sqlite` focused on Dart VM, CLI, migrations, and introspection
- avoid breaking the current pure-Dart SQLite package while adding Flutter-first support

## Phases

- [x] Phase 1: package scaffold
  - create package layout, docs, and initial public API
  - add bootstrap helpers that resolve schema + database path for Flutter runtimes
  - add database-factory selection helpers for mobile, desktop, and web
  - add smoke tests for schema resolution and injected factory opening

- [x] Phase 2: runtime adapter port
  - port the current SQLite runtime adapter from `sqlite3` to `sqflite_common`
  - keep query semantics aligned with `comon_orm_sqlite`
  - support injected `DatabaseFactory` for tests and custom embeddings

- [ ] Phase 3: schema apply and local bootstrap
  - [x] add async schema-apply helpers on top of `sqflite_common`
  - [x] expose `openAndApply...` flows appropriate for local development
  - [ ] extend migration-oriented helpers where Flutter use cases actually need them

- [x] Phase 4: examples and package integration
  - [x] add Flutter example(s)
  - [x] integrate the package into the root pub workspace and tooling
  - [x] update root docs once the adapter is ready for wider use

## Current scope

The package now ships a working `sqflite_common`-backed `DatabaseAdapter`, schema-aware bootstrap helpers, local schema-apply flows, root-workspace integration, and a global Flutter example app under `examples/flutter_sqlite`.
