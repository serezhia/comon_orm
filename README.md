**English** | [Русский](README_RU.md)

# comon_orm

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm` is a schema-first ORM toolkit for Dart inspired by Prisma.

The core idea is simple: define your models in `schema.prisma`, generate a typed Dart client, and work through the generated API instead of hand-written maps, raw SQL strings, and implicit runtime conventions.

## ✨ Packages

| Package | Purpose |
| --- | --- |
| `packages/comon_orm` | core: parser, validator, formatter, codegen, query models, in-memory adapter, migration metadata |
| `packages/comon_orm_postgresql` | runtime adapter, introspection, and migrations for PostgreSQL |
| `packages/comon_orm_sqlite` | runtime adapter, introspection, and rebuild-based migrations for SQLite |
| `packages/comon_orm_sqlite_flutter` | Flutter-oriented SQLite runtime adapter built on the `sqflite` ecosystem |
| `examples/postgres` | runnable PostgreSQL-backed example application |
| `examples/flutter_sqlite` | runnable Flutter example using the Flutter-oriented SQLite runtime |

## 🚀 Quick Start

The base flow looks like this:

```bash
dart run comon_orm check schema.prisma
dart run comon_orm format schema.prisma
dart run comon_orm generate schema.prisma
```

After that, you work through the generated client.

Example with `sqlite`, without building query models manually and without dropping down to low-level APIs:

```dart
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final adapter = await SqliteDatabaseAdapter.openFromSchemaPath(
		schemaPath: 'schema.prisma',
	);

	try {
		final db = GeneratedComonOrmClient(adapter: adapter);

		final user = await db.user.create(
			data: const UserCreateInput(
				email: 'alice@example.com',
				name: 'Alice',
			),
		);

		final users = await db.user.findMany();

		print(user.email);
		print(users.length);
	} finally {
		adapter.dispose();
	}
}
```

The PostgreSQL version is the same, only the adapter changes:

```dart
final adapter = await PostgresqlDatabaseAdapter.openFromSchemaPath(
	schemaPath: 'schema.prisma',
);
```

## 🎯 Key Features

### 🧬 Schema-first workflow

- `schema.prisma` as the source of truth
- parsing, validation, and canonical formatting
- resolution of `generator client { output = ... }`
- unified CLI for `check`, `format`, and `generate`

### 🤖 Generated client

- typed models, inputs, and delegate APIs
- `findUnique`, `findFirst`, `findMany`, `count`
- `create`, `update`, `updateMany`, `delete`, `deleteMany`
- `transaction`
- `select`, `include`, nested create inputs
- `distinct`, `orderBy`, `skip`, `take`
- `aggregate` and `groupBy`
- scalar and compound `WhereUniqueInput`

### 🔗 Relations and schema

- `@id`, `@unique`, `@@id`, `@@unique`, `@@index`
- `@map`, `@@map`, `@updatedAt`, defaults, enums
- one-to-one and one-to-many relations
- named relations and self-relations
- compound references
- implicit many-to-many, including compound key scenarios
- referential actions: `onDelete` and `onUpdate`

### 🐘 PostgreSQL

- runtime adapter built on `package:postgres`
- bootstrap from `schema.prisma` via `openFromSchemaPath(...)`
- schema introspection
- DDL and migration workflow
- `diff`, `apply`, `rollback`, `status`, and migration history
- SQL pushdown for aggregate and group-by queries
- support for part of the native type surface and enum workflows

### 🪶 SQLite

- embedded runtime built on `sqlite3`
- bootstrap from `schema.prisma` via `openFromSchemaPath(...)`
- schema introspection
- `diff`, `apply`, `rollback`, and migration history
- rebuild-based migrations for schema changes SQLite cannot express with `ALTER TABLE`
- support for part of the SQLite native type surface

### 🧪 Tests and local development

- `InMemoryDatabaseAdapter` in the core package
- schema-driven runtime semantics, including `@updatedAt`, when the adapter is created with schema metadata
- fast test scenarios without starting a real database

## 🧭 Migrations

The preferred user flow goes through the unified CLI in the core package:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

Important:

- the dispatcher reads `datasource.provider` and delegates to `comon_orm_postgresql` or `comon_orm_sqlite`
- `openAndApplyFromSchemaPath(...)` is a convenient local-development bootstrap, not the recommended strategy for shared or production environments
- destructive changes and warning-bearing migration plans require manual review

Details are documented in [MIGRATIONS.md](MIGRATIONS.md).

## 📱 Platforms

The current project focus is Dart VM and server-side use cases.

| Platform / scenario | Status | Notes |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Primary target | This is the main target platform for the repository today |
| Flutter mobile / desktop | ⚠️ Mixed support | `comon_orm` core is usable, SQLite can fit VM-based embedded scenarios, and PostgreSQL is possible only in niche direct-connection architectures |
| Dart Web / Flutter Web | ⚠️ Core + Flutter SQLite path | The `comon_orm` core package is import-safe on web, and `comon_orm_sqlite_flutter` now provides the intended browser/mobile/desktop SQLite runtime path; PostgreSQL remains non-browser |

In short: the repository now has a web-safe core layer, VM-oriented PostgreSQL/SQLite packages for server and tooling workflows, and a separate Flutter-first SQLite package for mobile, desktop, and web embeddings.

## 📚 Where To Start

- Need parser, validator, codegen, or an in-memory runtime: see `packages/comon_orm/README.md`
- Need a PostgreSQL runtime: see `packages/comon_orm_postgresql/README.md`
- Need a SQLite runtime: see `packages/comon_orm_sqlite/README.md`
- Need a Flutter-oriented SQLite runtime: see `packages/comon_orm_sqlite_flutter/README.md`
- Need an example application: see `examples/postgres/README.md`
- Need a Flutter SQLite example application: see `examples/flutter_sqlite/README.md`
- Need the migration workflow: see [MIGRATIONS.md](MIGRATIONS.md)
- Need the schema DSL reference: see [SCHEMA_REFERENCE.md](SCHEMA_REFERENCE.md)
- Need the release flow: see [RELEASING.md](RELEASING.md)

## 🧱 Current Boundaries

`comon_orm` is inspired by Prisma, but it does not claim full Prisma parity.

In practice, that means:

- a broad and useful feature surface is already available for real work
- some advanced Prisma features are not implemented yet
- `@db.*` coverage is currently selective and provider-specific
- some provider-specific edge cases are still possible

It is best understood as a pragmatic schema-first ORM for Dart with real migrations and a generated client, not as a line-by-line Prisma clone.

## 🛠️ Monorepo Development

This repository uses a Dart pub workspace from the root.

Baseline validation before publishing:

```bash
dart pub get

dart run tool/format_all.dart
dart run tool/analyze_all.dart
dart run tool/test_all.dart
dart run tool/dry_run_all.dart

dart run tool/pre_publish.dart
```

Available root helpers:

- `dart run tool/format_all.dart`
- `dart run tool/analyze_all.dart`
- `dart run tool/test_all.dart`
- `dart run tool/dry_run_all.dart`
- `dart run tool/pre_publish.dart`

The same flows are available in VS Code tasks:

- `format: all packages`
- `analyze: all packages`
- `test: all packages`
- `publish: dry-run all`
- `pre-publish`
