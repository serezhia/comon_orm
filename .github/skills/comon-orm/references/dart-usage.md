# comon_orm Dart Usage Reference

This file is for application code and adapter bootstrap. If the task is about migrations or drift, load `workflow.md` instead.

## Default Runtime Path

The normal path is:

1. describe models in `schema.prisma`
2. run `check` and `generate`
3. open an adapter from generated runtime metadata
4. construct the generated client
5. call model APIs like `create`, `findMany`, `findUnique`, `update`, and `delete`

## Bootstrap Decision

Normal runtime bootstrap goes through `openFromGeneratedSchema(...)`.

If tables still need to be created locally, do that through CLI or explicit setup/bootstrap helpers before application runtime starts.

## PostgreSQL Example

```dart
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';
import 'package:your_app/generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
    schema: GeneratedComonOrmClient.runtimeSchema,
  );

  try {
    final client = GeneratedComonOrmClient(adapter: adapter);

    final created = await client.user.create(
      data: const UserCreateInput(
        email: 'alice@example.com',
        role: UserRole.admin,
      ),
    );

    final users = await client.user.findMany();

    print(created.email);
    print(users.length);
  } finally {
    await adapter.close();
  }
}
```

## SQLite Example

```dart
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';
import 'package:your_app/generated/comon_orm_client.dart';

Future<void> main() async {
  final adapter = await SqliteDatabaseAdapter.openFromGeneratedSchema(
    schema: GeneratedComonOrmClient.runtimeSchema,
  );

  try {
    final client = GeneratedComonOrmClient(adapter: adapter);

    final users = await client.user.findMany();
    print(users.length);
  } finally {
    adapter.dispose();
  }
}
```

## Local Development Setup

If a local database still needs its schema created, run setup through migration/apply tooling or an explicit bootstrap helper outside the adapter runtime surface.

For Flutter/local-first SQLite, keep one more split in mind:

- normal runtime open still goes through `GeneratedComonOrmClientFlutterSqlite.open(...)`
- explicit local upgrades now go through `SqliteFlutterMigrator` and `upgradeSqliteFlutterDatabase(...)` before runtime open

## Nested Write Example

```dart
final created = await client.user.create(
  data: UserCreateInput(
    email: 'alice@example.com',
    role: UserRole.admin,
    posts: PostCreateNestedManyWithoutUserInput(
      create: const [
        PostCreateWithoutUserInput(title: 'Hello ORM', published: true),
        PostCreateWithoutUserInput(title: 'Draft Note', published: false),
      ],
    ),
  ),
  include: const UserInclude(posts: true),
);
```

## Query Patterns

- `create(...)` to insert one record
- `findMany(...)` for lists, filters, ordering, pagination, includes, and selects
- `findUnique(...)` for unique lookups
- `update(...)` and `delete(...)` with unique selectors
- `aggregate(...)` and `groupBy(...)` for aggregate-heavy queries when generated for the schema
- nested inputs for related records when generated for the schema

## Runtime Rules

- prefer `openFromGeneratedSchema(...)` for normal app code
- keep schema apply out of the normal runtime adapter path
- adapters use the validated schema at runtime for mappings, relations, enums, and datasource settings
- use generated client types for app code when possible instead of lower-level query model APIs
- drop to lower-level `ComonOrmClient` and query models only when the task needs generic model access or engine-level debugging

## When To Use Lower-Level APIs

Use `SchemaParser`, `SchemaValidator`, `SchemaWorkflow`, or low-level query models when:

- you are implementing framework integrations
- you are debugging generator or runtime internals
- you need provider-agnostic tooling over arbitrary models
- the generated client is not available yet

## Load These Docs Next When Needed

- `workflow.md` for migration-safe rollout decisions
- `schema-authoring.md` for schema design rules
- `repo-map.md` for internal code locations and capability boundaries
