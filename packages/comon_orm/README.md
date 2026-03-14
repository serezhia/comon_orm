# comon_orm

Prisma-inspired schema-first ORM core for Dart.

Use this package when you want to validate or format `schema.prisma`, generate a Dart client, or run schema-driven tests on top of the in-memory adapter.

## Why This Package

`comon_orm` is the provider-agnostic foundation for the package family. It gives you:

- schema AST, parser, validator, and workflow helpers
- schema formatting and generator resolution helpers
- generated client code emission
- provider-agnostic query models and `DatabaseAdapter` contracts
- the in-memory adapter for tests and local workflows
- migration artifact and risk-analysis helpers that are not tied to a SQL dialect

Use `comon_orm_postgresql` or `comon_orm_sqlite` when you need a real database adapter, schema introspection, or migration execution.

## Quick Start

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

`validate` remains available as an alias for `check`.

Minimal end-to-end example:

```dart
import 'package:comon_orm/comon_orm.dart';
import 'generated/comon_orm_client.dart';

const workflow = SchemaWorkflow();

Future<void> main() async {
  final loaded = await workflow.loadValidatedSchema('schema.prisma');

  final adapter = InMemoryDatabaseAdapter(schema: loaded.schema);
  final client = GeneratedComonOrmClient(adapter: adapter);

  final user = await client.user.create(
    data: const UserCreateInput(
      email: 'alice@example.com',
      name: 'Alice',
    ),
  );

  print(user.email);
}
```

Run `dart run comon_orm generate example/schema.prisma` once to refresh the generated client when the example schema changes. The package `example/` folder already contains a generated client so the example stays readable out of the box.

## Common Workflows

- Validate and format schema files before committing migration or generator changes.
- Generate a typed client file from `generator client { output = ... }`.
- Implement custom adapters against `DatabaseAdapter` when you need a backend that is not covered by the provider packages.
- Run fast tests against `InMemoryDatabaseAdapter`, optionally passing `schema:` when you want runtime semantics such as `@updatedAt`.

## Capabilities

- schema parsing, validation, and canonical formatting
- generator output resolution from `schema.prisma`
- generated client code emission
- provider-agnostic query models for filtering, relation includes, transactions, aggregate, and group-by queries
- migration metadata and risk-analysis helpers

## Query Features

The generated client surface includes more than basic CRUD. Current query features include:

- `findUnique`, `findFirst`, `findMany`, `count`, `create`, `update`, `updateMany`, `delete`, `deleteMany`, and `transaction`
- typed scalar filters such as `StringFilter`, `IntFilter`, `BoolFilter`, and numeric aggregate filters
- case-insensitive string matching with `QueryStringMode.insensitive`
- `select`, `include`, and nested relation create inputs
- relation filters for `some`, `none`, `every`, `is`, and `isNot`
- `distinct`, `orderBy`, `skip`, and `take`
- `aggregate` and `groupBy` with `having` and aggregate ordering
- scalar and compound `WhereUniqueInput` selectors

See `SCHEMA_REFERENCE.md` for a fuller reference with concrete examples.

## Scope

- This package does not ship a production SQL adapter on its own.
- Real migrations and schema introspection live in the provider packages.
- The project is Prisma-inspired and intentionally does not claim full Prisma parity.

## Related Packages

- `comon_orm_postgresql` for PostgreSQL runtime, introspection, and migrations
- `comon_orm_sqlite` for SQLite runtime, introspection, and rebuild-based migrations
- repository example app in `examples/postgres` for a larger end-to-end flow
