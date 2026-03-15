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
- adapter bootstrap directly from `schema.prisma`

## 🚀 Quick Start

Add dependencies:

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_sqlite: ^0.0.1-alpha
```

Generated-client-first example:

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

For local bootstrap that also creates missing tables, you can use:

```dart
final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
	schemaPath: 'schema.prisma',
);
```

## 🎯 Key Features

### 🪶 Embedded SQLite Runtime

- runtime adapter on top of `sqlite3`
- file-backed and in-memory workflows
- bootstrap through `openFromSchemaPath(...)`
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
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate rollback --schema schema.prisma --from prisma/migrations
```

Important:

- the dispatcher reads `datasource.provider` and forwards to this package automatically
- `openAndApplyFromSchemaPath(...)` is convenient for local development, but it is not the same thing as a reviewed migration workflow
- some schema transitions require rebuilds because SQLite cannot express them with `ALTER TABLE`

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
