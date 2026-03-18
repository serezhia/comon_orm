# comon_orm Schema Authoring Reference

This file is for `schema.prisma` design. If the task is about runtime adapter code or rollout workflow, load a narrower reference file instead.

## How To Build `schema.prisma`

Write the schema in four logical sections when relevant:

1. `datasource`
2. `generator`
3. `enum` definitions
4. `model` definitions

## Minimal PostgreSQL Schema

```prisma
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

generator client {
  provider = "comon_orm"
  output = "lib/generated/comon_orm_client.dart"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
}
```

For SQLite-family generated helpers, prefer explicit helper selection in the generator block.

## Minimal SQLite Schema

```prisma
datasource db {
  provider = "sqlite"
  url = "dev.db"
}

generator client {
  provider = "comon_orm"
  output = "lib/generated/comon_orm_client.dart"
  sqliteHelper = "vm"
}

model User {
  id   Int    @id @default(autoincrement())
  name String
}
```

Use `sqliteHelper = "flutter"` when the generated client should emit the Flutter SQLite opener instead.

## Model Design Pattern

Start from fields and keys first:

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

Then add enums when a field has a fixed domain:

```prisma
enum UserRole {
  admin
  member
}

model User {
  id    Int      @id @default(autoincrement())
  email String   @unique
  role  UserRole
}
```

Then add relations:

```prisma
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id     Int    @id @default(autoincrement())
  title  String
  userId Int
  user   User   @relation(fields: [userId], references: [id])
}
```

## Relation Rules

- the owning side carries `fields` and `references`
- the referenced field set must be unique
- relation scalar field types must match the referenced field types
- ambiguous multiple relations between the same model pair need explicit relation names
- self-relations need explicit names
- one-to-one ownership must point through a unique local field set
- relation ownership must exist on exactly one side unless it is an implicit many-to-many list-to-list relation
- implicit many-to-many is supported for single-field and compound key sets, but keep the modeling explicit and test provider behavior when changing key shapes

## Useful Attributes

- `@id`
- `@unique`
- `@default(autoincrement())`
- `@default(now())`
- `@updatedAt`
- `@map`
- `@relation(...)`
- `@@id`, `@@unique`, `@@index`, `@@map`

## Native Types

PostgreSQL currently supports:

- `@db.VarChar(n)`
- `@db.Text`
- `@db.Json`
- `@db.JsonB`
- `@db.ByteA`
- `@db.Timestamp`
- `@db.Timestamptz`
- `@db.Uuid`

SQLite currently supports:

- `@db.Integer`
- `@db.Numeric`
- `@db.Real`
- `@db.Text`
- `@db.Blob`

## Authoring Loop

After changing the schema:

```bash
dart run comon_orm check
dart run comon_orm generate
dart run comon_orm migrate dev --name <migration_name>
```

If the migration warns about destructive changes, review the warnings before continuing.

Do not confuse local setup/bootstrap with real migrations: schema apply belongs to tooling or explicit setup helpers, not the normal runtime adapter path.

## Good Design Defaults

- use explicit relation field names like `userId`, `authorId`, `ownerId`
- keep enum names and values stable when possible
- use nullable fields only when optionality is real in the domain
- introduce compound keys only when access patterns truly require them
- check provider-specific support before adding new `@db.*` types

## Load These Docs When Needed

- `README.md` for top-level workflow and runtime examples
- `site/content/docs/schema/reference.mdx` for syntax and supported constructs
- `site/content/docs/migrations/index.mdx` for local-vs-production migration guidance
- `workflow.md` for the operational migration sequence
