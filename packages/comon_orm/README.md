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
  comon_orm: ^0.0.1-alpha
```

Validate, format, and generate from a schema:

```bash
dart run comon_orm check schema.prisma
dart run comon_orm format schema.prisma
dart run comon_orm generate schema.prisma
```

`validate` is still available as an alias for `check`.

Minimal generated-client-first example:

```dart
import 'package:comon_orm/comon_orm.dart';

import 'generated/comon_orm_client.dart';

const workflow = SchemaWorkflow();

Future<void> main() async {
	final loaded = await workflow.loadValidatedSchema('schema.prisma');
	final adapter = InMemoryDatabaseAdapter(schema: loaded.schema);
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
- file-aware validation diagnostics through `SchemaWorkflow`
- unified CLI for `check`, `format`, and `generate`

### 🤖 Generated Client Surface

- typed models, inputs, and delegates
- `findUnique`, `findFirst`, `findMany`, `count`
- `create`, `update`, `updateMany`, `delete`, `deleteMany`
- `transaction`
- `select`, `include`, and nested relation create inputs
- `distinct`, `orderBy`, `skip`, and `take`
- `aggregate` and `groupBy`
- scalar and compound `WhereUniqueInput`

### 🧪 In-Memory Runtime

- fast tests without a real database
- schema-driven runtime semantics when created with `schema:`
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
