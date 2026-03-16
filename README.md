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
| `packages/comon_orm_sqlite_flutter` | Flutter-oriented SQLite runtime adapter built on the `sqflite` ecosystem, plus lightweight app-side local migration helpers |
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
import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final db = await GeneratedComonOrmClientSqlite.open();

	try {
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
		await db.close();
	}
}
```

That path assumes the database schema was already created through your migration or local bootstrap flow. The PostgreSQL version is the same, only the adapter changes:

```dart
final db = await GeneratedComonOrmClientPostgresql.open();
```

Runtime surface summary:

- Runtime path: generated metadata through `GeneratedComonOrmClient.openInMemory()`, `GeneratedComonOrmClientSqlite.open(...)`, and `GeneratedComonOrmClientPostgresql.open(...)`
- Tooling path: schema-driven `generate`, `check`, `format`, `migrate`, `introspect`, and schema-apply flows stay on `schema.prisma`
- Setup path: provider-specific bootstrap/setup helpers can prepare local databases outside adapter runtime surfaces when runtime metadata alone is not enough
- Flutter local upgrade path: `SqliteFlutterMigrator` and `upgradeSqliteFlutterDatabase(...)` provide explicit app-side local SQLite upgrades before `GeneratedComonOrmClientFlutterSqlite.open(...)`

## 🎯 Key Features

### 🧬 Schema-first workflow

- `schema.prisma` as the source of truth
- parsing, validation, and canonical formatting
- resolution of `generator client { output = ... }`
- explicit SQLite helper selection through `generator client { sqliteHelper = "vm" | "flutter" }`
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
- compiled-metadata runtime bootstrap via `openFromGeneratedSchema(...)`
- schema introspection
- DDL and migration workflow
- `diff`, `apply`, `rollback`, `status`, and migration history
- SQL pushdown for aggregate and group-by queries
- support for part of the native type surface and enum workflows

### 🪶 SQLite

- embedded runtime built on `sqlite3`
- compiled-metadata runtime bootstrap via `openFromGeneratedSchema(...)`
- schema introspection
- `diff`, `apply`, `rollback`, and migration history
- rebuild-based migrations for schema changes SQLite cannot express with `ALTER TABLE`
- support for part of the SQLite native type surface

### 🧪 Tests and local development

- `InMemoryDatabaseAdapter` in the core package
- schema-driven runtime semantics, including `@updatedAt`, when the adapter is created with generated or parsed schema metadata
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
- the preferred application runtime path is generated metadata through `GeneratedComonOrmClient.runtimeSchema` plus `openFromGeneratedSchema(...)`
- schema apply remains a tooling/setup concern, not a normal runtime adapter entrypoint
- Flutter/local-first SQLite upgrades can now also be expressed as explicit Dart-coded local migrations through `comon_orm_sqlite_flutter`, but that path is for app-local databases, not shared reviewed rollout
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

For Flutter/local-first SQLite specifically, the intended split is:

- reviewed CLI migrations for shared databases and operational rollout
- explicit app-side local upgrades for device-local SQLite files when data must be migrated in place
- reset or rebuild for disposable local caches when migration code is not worth the complexity

## 📚 Where To Start

- Need parser, validator, codegen, or an in-memory runtime: see `packages/comon_orm/README.md`
- Need a PostgreSQL runtime: see `packages/comon_orm_postgresql/README.md`
- Need a SQLite runtime: see `packages/comon_orm_sqlite/README.md`
- Need a Flutter-oriented SQLite runtime: see `packages/comon_orm_sqlite_flutter/README.md`
- Need an example application: see `examples/postgres/README.md`
- Need a Flutter SQLite example application: see `examples/flutter_sqlite/README.md`
- Need the migration workflow: see [MIGRATIONS.md](MIGRATIONS.md)
- Need the schema DSL reference: see [SCHEMA_REFERENCE.md](SCHEMA_REFERENCE.md)
- Need the current refactor and Prisma-like roadmap: see [REFACTOR_PLAN.md](REFACTOR_PLAN.md)
- Need the release flow: see [RELEASING.md](RELEASING.md)

## 🧱 Current Boundaries

`comon_orm` is inspired by Prisma, but it does not claim full Prisma parity.

In practice, that means:

- a broad and useful feature surface is already available for real work
- some advanced Prisma features are not implemented yet
- `@db.*` coverage is currently selective and provider-specific
- some provider-specific edge cases are still possible

It is best understood as a pragmatic schema-first ORM for Dart with real migrations and a generated client, not as a line-by-line Prisma clone.

## 🧩 Prisma-like Compatibility Snapshot

Already solid:

- typed generated client with delegates, models, inputs, `select`, and `include`
- CRUD flow with `findUnique`, `findFirst`, `findMany`, `count`, `create`, `update`, `updateMany`, `delete`, and `deleteMany`, including generated `distinct` support on `findMany(...)` and `findFirst(...)`
- transactions, aggregates, and `groupBy`
- compound ids and compound unique selectors
- nested create flows
- generated-metadata-first runtime startup for in-memory, SQLite, PostgreSQL, and Flutter SQLite paths
- real migration workflow for PostgreSQL and SQLite

Implemented, but still partial or provider-sensitive:

- `upsert`, currently implemented through generated delegate transactions over existing `findUnique`, `create`, and `update` primitives
- `createMany`, currently implemented as a transactional generated bulk-write convenience over repeated `create` operations
- `createMany(skipDuplicates: true)`, currently implemented through schema-derived unique selector checks plus provider-aware duplicate-conflict handling on the generated bulk path
- scalar field update operators: generated `set` for scalar-like fields and `increment` / `decrement` for numeric fields are supported in `update(...)`, `upsert(...)`, and `updateMany(...)`; bulk computed updates are resolved transactionally per matching record instead of using adapter-native arithmetic
- nested `connect`, `disconnect`, `set`, and `connectOrCreate`: generated update flows support these across direct relations, including compound direct foreign-key relations, implicit many-to-many relations, and inverse one-to-one relations when replacement semantics are valid; `updateMany(...)` reuses the same per-record relation-write path, and create-path relation writes now defer to that same machinery once the parent record exists inside the transaction where the target relation semantics allow it
- cursor pagination: generated `findMany(cursor: ...)` now supports forward and backward pagination over the current ordered/distinct result set through positive and negative `take` values, and generated `findFirst(cursor: ...)` now reuses the same cursor-slicing path for first-record semantics; both remain generated-client-layer features, interact correctly with generated `distinct`, reload projected rows by primary key when `include` or `select` is requested, and still do not add adapter-native cursor pushdown
- `@db.*` coverage remains selective and provider-specific
- some aggregate, predicate, and relation edge cases still differ by provider
- Flutter and web support is intentionally narrower than the main Dart VM/server path

Bulk and provider-behavior notes:

- `createMany(...)` and `updateMany(...)` currently prioritize cross-provider semantic parity over adapter-native bulk SQL. Generated delegates execute these flows transactionally on top of the existing runtime primitives, so PostgreSQL, SQLite, Flutter SQLite, and in-memory keep the same behavioral contract even when the underlying database could support a more specialized shortcut.
- `createMany(skipDuplicates: true)` first uses generated unique selectors when the input exposes them, then still treats provider duplicate-conflict errors as skippable on the insert path. In practice this means duplicate races are swallowed consistently across the SQL providers instead of leaking adapter-specific errors back through the generated delegate surface.
- cursor pagination remains a generated-client feature today. `findMany(cursor: ...)` and `findFirst(cursor: ...)` slice the already ordered/distinct result set and then reload projected rows by primary key when needed; they do not currently claim adapter-native cursor pushdown.

Advanced generated-client example:

```dart
final user = await db.user.create(
	data: const UserCreateInput(
		name: 'Alice',
		role: UserRole.manager,
	),
);

await db.user.update(
	where: UserWhereUniqueInput(id: user.id!),
	data: UserUpdateInput(
		todos: TodoUpdateNestedManyWithoutUserInput(
			connectOrCreate: [
				TodoConnectOrCreateWithoutUserInput(
					where: const TodoWhereUniqueInput(id: 1001),
					create: const TodoCreateWithoutUserInput(
						id: 1001,
						title: 'Ship docs',
						status: TodoStatus.inProgress,
					),
				),
			],
		),
	),
);

await db.todo.updateMany(
	where: const TodoWhereInput(status: TodoStatus.pending),
	data: const TodoUpdateInput(status: TodoStatus.done),
);

final nextTodo = await db.todo.findFirst(
	cursor: const TodoWhereUniqueInput(id: 1001),
	orderBy: const [TodoOrderByInput(id: SortOrder.asc)],
	distinct: const [TodoScalarField.id],
);
```

Not implemented yet:

- some required-disconnect, required-set, or required-replacement relation cases when satisfying the nested write would orphan already attached required relation targets; additive/reassign direct-list `set` and unrelated direct-list `disconnect` no-ops are now allowed

The active roadmap for those gaps lives in [REFACTOR_PLAN.md](REFACTOR_PLAN.md).

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
