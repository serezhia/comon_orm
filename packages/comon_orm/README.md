**English** | [Русский](README_RU.md)

# comon_orm

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm` is the provider-agnostic core of the package family: schema parsing, validation, formatting, code generation, query models, and the in-memory runtime.

Use this package when you want to work with `schema.prisma`, generate a typed Dart client, or run fast schema-driven tests without starting a real database.

## ✨ What This Package Gives You

- schema AST, parser, validator, and workflow helpers
- schema formatting and generator output resolution
- generated client code emission
- provider-agnostic query models and `DatabaseAdapter` contracts
- `InMemoryDatabaseAdapter` for tests and local workflows
- migration artifacts and risk-analysis helpers that are not tied to a SQL dialect

Use `comon_orm_postgresql` or `comon_orm_sqlite` when you need a real database adapter, introspection, or migration execution.

## 🚀 Quick Start

Add the dependency:

```yaml
dependencies:
	comon_orm: ^0.0.1-alpha.2
```

Validate, format, and generate from a schema:

```bash
dart run comon_orm check
dart run comon_orm format
dart run comon_orm generate
```

`validate` is still available as an alias for `check`.

Minimal generated-client-first example:

```dart
import 'package:comon_orm/comon_orm.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final db = GeneratedComonOrmClient.openInMemory();

	final user = await db.user.create(
		data: const UserCreateInput(
			email: 'alice@example.com',
			name: 'Alice',
		),
	);

	final users = await db.user.findMany();

	print(user.email);
	print(users.length);
}
```

If the example schema changes, regenerate the client with:

```bash
dart run comon_orm generate example/schema.prisma
```

## 🎯 Key Features

### 🧬 Schema Workflow

- `schema.prisma` parsing, validation, and canonical formatting
- generator output resolution from `generator client { output = ... }`
- explicit SQLite helper target selection from `generator client { sqliteHelper = "vm" | "flutter" }`
- file-aware validation diagnostics through `SchemaWorkflow`
- unified CLI for `check`, `format`, and `generate`

### 🤖 Generated Client Surface

- typed models, inputs, and delegates
- `findUnique`, `findFirst`, `findMany`, `count`
- `create`, `update`, `updateMany`, `delete`, `deleteMany`
- `upsert`, `createMany`, and `createMany(skipDuplicates: true)`
- `transaction`
- `select`, `include`, nested relation create inputs, and generated nested `connect`, `disconnect`, `set`, and `connectOrCreate` where relation semantics allow them
- `distinct`, `orderBy`, `skip`, and `take`
- `aggregate` and `groupBy`
- scalar and compound `WhereUniqueInput`

The advanced generated surface remains intentionally generated-layer first today:

- `createMany(...)` and `updateMany(...)` are transactional delegate conveniences over the existing runtime primitives, which keeps behavior aligned across in-memory and SQL providers instead of splitting semantics by backend.
- `findMany(cursor: ...)` and `findFirst(cursor: ...)` currently implement cursor slicing in the generated delegate layer rather than claiming adapter-native cursor pushdown.

Short advanced example using the package example schema:

```dart
await db.user.createMany(
	data: const [
		UserCreateInput(email: 'alice@example.com', name: 'Alice'),
		UserCreateInput(email: 'alice@example.com', name: 'Alice duplicate'),
		UserCreateInput(email: 'bob@example.com', name: 'Bob'),
	],
	skipDuplicates: true,
);

final firstPage = await db.user.findMany(
	orderBy: const [UserOrderByInput(id: SortOrder.asc)],
	take: 2,
);

final nextUser = await db.user.findFirst(
	cursor: UserWhereUniqueInput(id: firstPage.last.id!),
	orderBy: const [UserOrderByInput(id: SortOrder.asc)],
);
```

### 🧪 In-Memory Runtime

- fast tests without a real database
- schema-driven runtime semantics when created from generated metadata or `schema:`
- useful for validating generated client behavior and query workflows

### 🧱 Shared Building Blocks

- provider-agnostic query models
- `DatabaseAdapter` contracts for custom backends
- migration artifact and risk-analysis helpers shared by provider packages
- web-safe schema parsing, validation, and formatting from in-memory source text

## 📚 Typical Workflows

- validate and format `schema.prisma` before committing generator or migration changes
- generate a typed client file from your schema
- run tests against `InMemoryDatabaseAdapter`
- implement a custom adapter against `DatabaseAdapter` if your backend is not covered by the provider packages

## 📱 Platform Notes

| Platform / scenario | Status | Notes |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Primary target | Main supported use case |
| Flutter mobile / desktop | ✅ Core package works | Query models, parser, validator, codegen types, and in-memory runtime are usable; file-based tooling still assumes VM filesystem access |
| Dart Web / Flutter Web | ✅ Core package import is supported | Use source-based workflow APIs such as `loadValidatedSchemaSource(...)`; file-backed workflow and migration artifact loading remain unavailable on web |

## 🧱 Scope

- This package does not ship a production SQL adapter by itself.
- Real database migrations and schema introspection live in the provider packages.
- `comon_orm_postgresql` and the current `comon_orm_sqlite` package remain VM-oriented runtime adapters; browser runtimes need separate adapter packages.
- The project is Prisma-inspired and does not claim full Prisma parity.
