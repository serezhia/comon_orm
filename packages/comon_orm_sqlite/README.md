**English** | [Русский](README_RU.md)

# comon_orm_sqlite

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm_sqlite` is the SQLite runtime package for `comon_orm`.

Use it when your schema declares `provider = "sqlite"` and you want an embedded database workflow with schema-aware runtime behavior, introspection, and migrations.

## ✨ What This Package Gives You

- runtime `DatabaseAdapter` built on `sqlite3`
- file-backed and in-memory SQLite workflows
- schema application and introspection for the supported SQLite surface
- migration planning, apply, rollback, history, and status helpers
- generated-metadata-first runtime bootstrap for file-backed and in-memory adapters

## 🚀 Quick Start

Add dependencies:

```yaml
dependencies:
	comon_orm: ^0.0.1-alpha.2
	comon_orm_sqlite: ^0.0.1-alpha.2
```

Generated-client-first example:

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

That path is the preferred runtime flow once the database has already been migrated or created.

```dart
final db = await GeneratedComonOrmClientSqlite.open();
```

## Runtime Paths

- Runtime path: `GeneratedComonOrmClient.openInMemory()` or `GeneratedComonOrmClientSqlite.open(...)`
- Tooling/setup path: schema-driven migrate/apply flows through the CLI and schema tools
- runtime opens performed by this package enable SQLite foreign key enforcement with `PRAGMA foreign_keys = ON` by default

## Internal Runtime Layout

- `sqlite_database_adapter.dart` currently owns the public adapter surface together with SQL clause building, relation loading, and savepoint-based transaction coordination
- the public runtime entry points stay `GeneratedComonOrmClient.openInMemory()` and `GeneratedComonOrmClientSqlite.open(...)`, even as internal adapter responsibilities are split over time

## 🎯 Key Features

### 🪶 Embedded SQLite Runtime

- runtime adapter on top of `sqlite3`
- file-backed and in-memory workflows
- compiled-metadata runtime bootstrap through `openFromGeneratedSchema(...)`
- a natural fit for local tools, desktop utilities, tests, and lightweight applications

### 🧭 Migrations

- `diff`, `apply`, `rollback`, `status`, and migration history helpers
- rebuild-aware planning for SQLite limitations
- schema-aware warnings for destructive changes
- migration metadata compatible with the unified CLI flow

### 🔍 Introspection and Schema Apply

- introspect supported SQLite schema back into `schema.prisma` concepts
- apply supported schema changes to the database
- preserve mapped names and relation metadata across the supported surface

## 🧭 Recommended Migration Flow

The preferred flow is the unified core CLI:

```bash
dart run comon_orm check
dart run comon_orm generate
dart run comon_orm migrate dev --name 20260315_init
dart run comon_orm migrate status
dart run comon_orm migrate deploy
```

Important:

- the dispatcher reads `datasource.provider` and forwards to this package automatically
- the preferred application runtime path is `GeneratedComonOrmClient.runtimeSchema` plus `openFromGeneratedSchema(...)`
- schema apply stays in tooling/setup flows instead of runtime adapter convenience APIs
- some schema transitions require rebuilds because SQLite cannot express them with `ALTER TABLE`
- `db push` or `migrate reset` can be fine for disposable local databases, but shared or long-lived SQLite should still use reviewed migrations

## 📱 Platform Notes

| Platform / scenario | Status | Notes |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Primary target | Main supported use case |
| Flutter mobile / desktop | ⚠️ Reasonable in selected app architectures | SQLite can fit local-first or embedded scenarios, but the package is still documented primarily around Dart VM workflows |
| Dart Web / Flutter Web | ❌ Not supported | The SQLite runtime here is not a browser-targeted package |

## 🧱 Scope

- Some schema changes still require table rebuilds, so warnings matter.
- SQLite keeps a narrower native type surface than PostgreSQL.
- Enum support uses SQLite-compatible storage rather than native enum types.
