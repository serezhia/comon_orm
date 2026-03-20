# comon_orm

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/anomalyco/opencode)

`comon_orm` is a schema-first ORM toolkit for Dart inspired by Prisma.

The core idea is simple: define your models in `schema.prisma`, generate a typed Dart client, apply the schema to the database through the migration flow, and work through the generated API instead of hand-written maps and raw SQL strings.

## Quick Start

Minimal `schema.prisma`:

```prisma
datasource db {
  provider = "sqlite"
  url      = "dev.db"
}

generator client {
  provider = "comon_orm"
  output   = "lib/generated/comon_orm_client.dart"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String?
}
```

Generate the client:

```bash
dart run comon_orm check
dart run comon_orm generate
```

Create and apply the first migration during development:

```bash
dart run comon_orm migrate dev --name init
```

Deploy reviewed migrations in CI or production:

```bash
dart run comon_orm migrate deploy
```

Prototype quickly without migration files:

```bash
dart run comon_orm db push
```

Use the generated client in Dart:

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

## Packages

| Package | Purpose |
| --- | --- |
| `packages/comon_orm` | parser, validator, formatter, codegen, query models, in-memory adapter, migration metadata |
| `packages/comon_orm_postgresql` | PostgreSQL runtime adapter, introspection, and migrations |
| `packages/comon_orm_sqlite` | SQLite runtime adapter, introspection, and rebuild-aware migrations |
| `packages/comon_orm_sqlite_flutter` | Flutter SQLite runtime adapter and app-side local upgrade helpers |

## Documentation

Detailed documentation now lives in the Fumadocs site under `site/`.

- `site/content/docs/core`
- `site/content/docs/schema`
- `site/content/docs/dart`
- `site/content/docs/migrations`

## Workspace Commands

Bootstrap the workspace from the repository root:

```bash
dart pub get
dart run melos bootstrap
```

Common validation commands:

```bash
dart run melos run analyze
dart run melos run test
dart run melos run format
dart run melos run publish:dry-run
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, validation, and pull request expectations.

## License

This repository is distributed under the MIT License. See [LICENSE](LICENSE).
