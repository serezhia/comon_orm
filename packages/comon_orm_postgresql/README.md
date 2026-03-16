**English** | [Русский](README_RU.md)

# comon_orm_postgresql

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm_postgresql` is the PostgreSQL runtime package for `comon_orm`.

Use it when your schema declares `provider = "postgresql"` and you need a real adapter, schema introspection, and migrations against PostgreSQL-compatible infrastructure.

## ✨ What This Package Gives You

- runtime `DatabaseAdapter` built on `package:postgres`
- generated-metadata-first runtime bootstrap from connection config
- schema application and introspection for the supported PostgreSQL surface
- migration planning, apply, rollback, history, and status helpers
- the provider implementation behind `dart run comon_orm migrate ...`

## 🚀 Quick Start

Add dependencies:

```yaml
dependencies:
	comon_orm: ^0.0.1-alpha.1
	comon_orm_postgresql: ^0.0.1-alpha.1
```

Generated-client-first example:

```dart
import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final db = await GeneratedComonOrmClientPostgresql.open();

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

That path is the preferred runtime flow once the database schema was already applied.

```dart
final db = await GeneratedComonOrmClientPostgresql.open();
```

## Runtime Paths

- Runtime path: `GeneratedComonOrmClientPostgresql.open(...)`
- Tooling/setup path: schema-driven migrate/apply flows through the CLI and schema tools

## 🎯 Key Features

### 🐘 PostgreSQL Runtime

- pooled `package:postgres` sessions
- compiled-metadata runtime bootstrap via `openFromGeneratedSchema(...)`
- SQL-backed query execution for generated client operations
- aggregate and group-by pushdown

### 🧭 Migrations

- `diff`, `apply`, `rollback`, `status`, and migration history helpers
- schema-aware warnings for risky changes
- introspection-backed planning and provider-specific DDL generation
- support for enum workflows, mapped names, foreign keys, and relation diffs across the supported surface

### 🔍 Introspection and Schema Apply

- introspect live PostgreSQL schema back into `schema.prisma` concepts
- apply supported schema changes to the database
- preserve migration metadata used by the unified workflow

## 🧭 Recommended Migration Flow

Most users should call migrations through the unified core CLI:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

Important:

- the dispatcher reads `datasource.provider` and forwards to this package automatically
- the preferred application runtime path is `GeneratedComonOrmClient.runtimeSchema` plus `openFromGeneratedSchema(...)`
- schema apply stays in tooling/setup flows instead of runtime adapter convenience APIs
- destructive enum transitions and other risky changes still require manual review

## 📱 Platform Notes

| Platform / scenario | Status | Notes |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Primary target | Main supported use case |
| Flutter mobile / desktop | ⚠️ Niche / VM-only scenarios | Possible only in special cases where PostgreSQL access and runtime model fit your app architecture |
| Dart Web / Flutter Web | ❌ Not supported | PostgreSQL runtime flow is not a browser target |

## 🧱 Scope

- This package targets PostgreSQL semantics, not generic SQL semantics.
- The supported surface is practical, but not full Prisma parity.
- CockroachDB compatibility is not promised.
