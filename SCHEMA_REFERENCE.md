# Schema Reference For comon_orm

This document explains the Prisma-style schema language used by `comon_orm`.

It has two goals:

- show the common schema cases you can model
- list the important keywords, attributes, and arguments you will see in a Prisma-like schema

This is a practical reference for this repository, not a claim of full upstream Prisma parity.

## Top-Level Blocks

Supported top-level blocks:

- `model`
- `enum`
- `datasource`
- `generator`

Example:

```prisma
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}

generator client {
  provider = "comon_orm"
  output = "lib/generated/comon_orm_client.dart"
}

enum Role {
  admin
  member
}

model User {
  id   Int   @id @default(autoincrement())
  role Role
}
```

## Scalar Types

Main scalar types recognized by `comon_orm`:

- `Int`
- `String`
- `Boolean`
- `DateTime`
- `Float`
- `Decimal`
- `Json`
- `Bytes`
- `BigInt`

Example:

```prisma
model ScalarSample {
  id        Int      @id
  createdAt DateTime
  amount    Decimal
  payload   Json?
  blob      Bytes?
  big       BigInt?
  enabled   Boolean
}
```

## Enums

Enums are supported in schema parsing, validation, generated client code, runtime handling, and PostgreSQL storage.

```prisma
enum TodoStatus {
  pending
  inProgress
  done
}

model Todo {
  id     Int        @id @default(autoincrement())
  title  String
  status TodoStatus
}
```

## Datasource Block

Typical keys:

- `provider`
- `url`

Examples:

```prisma
datasource db {
  provider = "postgresql"
  url = env("DATABASE_URL")
}
```

```prisma
datasource db {
  provider = "sqlite"
  url = "dev.db"
}
```

### Common Datasource Keywords

- `datasource`
- `provider`
- `url`
- `env(...)`

## Generator Block

Typical keys:

- `provider`
- `output`

Example:

```prisma
generator client {
  provider = "comon_orm"
  output = "lib/generated/comon_orm_client.dart"
}
```

### Common Generator Keywords

- `generator`
- `provider`
- `output`

## Field Attributes

### `@id`

Marks a field as a primary key.

```prisma
id Int @id
```

### `@default(...)`

Common cases:

- `@default(autoincrement())`
- `@default(now())`
- scalar literals
- enum values

```prisma
id        Int      @id @default(autoincrement())
createdAt DateTime @default(now())
enabled   Boolean  @default(false)
```

### `@unique`

Marks a field as unique.

```prisma
email String @unique
```

### `@updatedAt`

Marks a field to be refreshed automatically on update.

```prisma
updatedAt DateTime @updatedAt
```

### `@map`

Maps a logical field name to a database column name.

```prisma
email String @map("email_address")
```

### `@relation(...)`

Used for relations. Common arguments:

- `fields`
- `references`
- `name`
- `onDelete`
- `onUpdate`

Example:

```prisma
user User @relation(fields: [userId], references: [id], onDelete: Cascade)
```

### `@db.*`

Provider-specific native types.

PostgreSQL currently supports:

- `@db.VarChar(n)`
- `@db.Text`
- `@db.Json`
- `@db.JsonB`
- `@db.ByteA`
- `@db.Numeric`
- `@db.Timestamp`
- `@db.Timestamptz`
- `@db.Uuid`

SQLite currently supports:

- `@db.Integer`
- `@db.Numeric`
- `@db.Real`
- `@db.Text`
- `@db.Blob`

## Model Attributes

### `@@id([...])`

Compound primary key.

```prisma
model Membership {
  tenantId Int
  slug     String

  @@id([tenantId, slug])
}
```

### `@@unique([...])`

Compound unique constraint.

```prisma
model Membership {
  tenantId Int
  role     String

  @@unique([tenantId, role])
}
```

### `@@index([...])`

Schema keyword recognized as part of Prisma-style model attributes. If you use it, keep in mind migration/runtime support may lag behind `@@id` and `@@unique`.

```prisma
@@index([createdAt])
```

### `@@map("...")`

Maps a logical model name to a database table name.

```prisma
model User {
  id Int @id

  @@map("app_users")
}
```

## Relation Cases

### One-To-Many

```prisma
model User {
  id    Int    @id @default(autoincrement())
  posts Post[]
}

model Post {
  id     Int  @id @default(autoincrement())
  userId Int
  user   User @relation(fields: [userId], references: [id])
}
```

### One-To-One

Owning side must reference a unique field set.

```prisma
model User {
  id      Int      @id @default(autoincrement())
  profile Profile?
}

model Profile {
  id     Int  @id @default(autoincrement())
  userId Int  @unique
  user   User @relation(fields: [userId], references: [id])
}
```

### Named Relations

Useful when two models are related in more than one way.

```prisma
model User {
  id        Int    @id @default(autoincrement())
  manager   User?  @relation("Management", fields: [managerId], references: [id])
  managerId Int?
  reports   User[] @relation("Management")
}
```

### Self-Relations

Self-relations must be explicitly named.

```prisma
model User {
  id        Int    @id @default(autoincrement())
  mentorId  Int?
  mentor    User?  @relation("Mentorship", fields: [mentorId], references: [id])
  mentees   User[] @relation("Mentorship")
}
```

### Implicit Many-To-Many

List-to-list relations without explicit join model. In `comon_orm`, current support expects a single-field id on both sides.

```prisma
model User {
  id   Int   @id @default(autoincrement())
  tags Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  label String
  users User[]
}
```

### Compound References

```prisma
model Organization {
  tenantId Int
  slug     String

  @@id([tenantId, slug])
}

model Project {
  id           Int          @id @default(autoincrement())
  tenantId     Int
  orgSlug      String
  organization Organization @relation(fields: [tenantId, orgSlug], references: [tenantId, slug])
}
```

## Referential Actions

Supported relation action keywords:

- `Cascade`
- `Restrict`
- `NoAction`
- `SetNull`
- `SetDefault`

Example:

```prisma
user User? @relation(fields: [userId], references: [id], onDelete: SetNull, onUpdate: Cascade)
```

## Common Schema Keywords And Tokens

Top-level keywords:

- `model`
- `enum`
- `datasource`
- `generator`

Block property keywords:

- `provider`
- `url`
- `output`

Field and model attribute keywords:

- `@id`
- `@default`
- `@unique`
- `@updatedAt`
- `@map`
- `@relation`
- `@@id`
- `@@unique`
- `@@index`
- `@@map`

Relation argument keywords:

- `fields`
- `references`
- `name`
- `onDelete`
- `onUpdate`

Default function keywords:

- `autoincrement()`
- `now()`
- `env(...)`

Provider-specific prefixes:

- `@db.*`

Sort and query-related concepts you will see in generated client code:

- `equals`
- `not`
- `contains`
- `startsWith`
- `endsWith`
- `in`
- `gt`
- `gte`
- `lt`
- `lte`
- `relationSome`
- `relationNone`
- `relationEvery`
- `relationIs`
- `relationIsNot`
- `AND`
- `OR`
- `NOT`

## Usage Patterns

## Generated Client Query Surface

The schema DSL is only half of the user-facing API. After you run `generate`, the generated client also exposes a Prisma-like query surface for CRUD, filtering, relation traversal, aggregation, and grouping.

### Core Read Operations

Generated delegates support:

- `findUnique(...)`
- `findFirst(...)`
- `findMany(...)`
- `count(...)`

Example:

```dart
final user = await client.user.findUnique(
  where: const UserWhereUniqueInput(email: 'alice@prisma.io'),
  include: const UserInclude(posts: true),
);

final firstBob = await client.user.findFirst(
  where: const UserWhereInput(name: 'Bob'),
  select: const UserSelect(name: true, email: true),
);

final allUsers = await client.user.findMany(
  orderBy: const <UserOrderByInput>[UserOrderByInput(name: SortOrder.asc)],
  skip: 10,
  take: 20,
);
```

### Write Operations

Generated delegates support:

- `create(...)`
- `update(...)`
- `updateMany(...)`
- `delete(...)`
- `deleteMany(...)`
- `transaction(...)`

Example:

```dart
await client.transaction((tx) async {
  await tx.user.create(
    data: const UserCreateInput(name: 'Alice', email: 'alice@prisma.io'),
  );

  await tx.user.updateMany(
    where: const UserWhereInput(name: 'Alice'),
    data: const UserUpdateInput(name: 'Alice Updated'),
  );
});
```

### Select, Include, And Nested Create

Generated clients support field projection with `select`, relation loading with `include`, and nested create inputs for relations.

```dart
final created = await client.user.create(
  data: UserCreateInput(
    name: 'Alice',
    email: 'alice@prisma.io',
    posts: PostCreateNestedManyWithoutUserInput(
      create: const <PostCreateWithoutUserInput>[
        PostCreateWithoutUserInput(title: 'Hello World', published: true),
      ],
    ),
  ),
  include: const UserInclude(posts: true),
);

final projected = await client.user.findMany(
  select: const UserSelect(name: true, email: true),
);
```

### Scalar Filtering

Generated `WhereInput` classes support typed filter objects.

Common filters:

- `StringFilter`
- `IntFilter`
- `BoolFilter`
- `DoubleFilter` for aggregate and numeric query surfaces

Common scalar operators:

- `equals`
- `not`
- `contains`
- `startsWith`
- `endsWith`
- `inList`
- `notInList`
- `gt`
- `gte`
- `lt`
- `lte`

Example:

```dart
final filtered = await client.user.findMany(
  where: const UserWhereInput(
    nameFilter: StringFilter(
      contains: 'ali',
      mode: QueryStringMode.insensitive,
    ),
    idFilter: IntFilter(gte: 2, lte: 10),
  ),
  select: const UserSelect(name: true, email: true),
);
```

`QueryStringMode.insensitive` is supported for case-insensitive `contains`, `startsWith`, and `endsWith` matching.

### Relation Filtering

Generated `WhereInput` classes also support relation predicates:

- `relationSome`
- `relationNone`
- `relationEvery`
- `relationIs`
- `relationIsNot`

Generated field names usually look like:

- `postsSome`
- `postsNone`
- `postsEvery`
- `managerIs`
- `managerIsNot`

Example:

```dart
final publishedAuthors = await client.user.findMany(
  where: const UserWhereInput(
    postsSome: PostWhereInput(
      publishedFilter: BoolFilter(equals: true),
    ),
  ),
);

final childrenOfAlice = await client.user.findMany(
  where: const UserWhereInput(
    managerIs: UserWhereInput(name: 'Alice'),
  ),
);
```

### Distinct, Ordering, And Pagination

`findMany(...)` supports:

- `orderBy`
- `skip`
- `take`
- `distinct`

Example:

```dart
final distinctCountries = await client.user.findMany(
  orderBy: const <UserOrderByInput>[
    UserOrderByInput(country: SortOrder.asc),
    UserOrderByInput(profileViews: SortOrder.desc),
  ],
  distinct: const <UserScalarField>[UserScalarField.country],
  select: const UserSelect(name: true, country: true, profileViews: true),
);
```

### Aggregate Queries

Generated delegates support `aggregate(...)` with:

- `count`
- `avg`
- `sum`
- `min`
- `max`
- `where`
- `orderBy`
- `skip`
- `take`

Example:

```dart
final aggregate = await client.user.aggregate(
  where: const UserWhereInput(
    countryFilter: StringFilter(inList: <String>['US', 'FR']),
  ),
  count: const UserCountAggregateInput(all: true, profileViews: true),
  avg: const UserAvgAggregateInput(profileViews: true),
  sum: const UserSumAggregateInput(profileViews: true),
  min: const UserMinAggregateInput(profileViews: true),
  max: const UserMaxAggregateInput(profileViews: true),
);
```

### GroupBy And Having

Generated delegates support `groupBy(...)` with:

- `by`
- `having`
- `orderBy`
- `count`
- `avg`
- `sum`
- `min`
- `max`
- `skip`
- `take`

Example:

```dart
final grouped = await client.user.groupBy(
  by: const <UserScalarField>[UserScalarField.country],
  having: const UserGroupByHavingInput(
    profileViews: NumericAggregatesFilter(avg: DoubleFilter(gte: 10)),
  ),
  orderBy: const <UserGroupByOrderByInput>[
    UserGroupByOrderByInput(
      avg: UserAvgAggregateOrderByInput(profileViews: SortOrder.desc),
    ),
  ],
  count: const UserCountAggregateInput(all: true, profileViews: true),
  avg: const UserAvgAggregateInput(profileViews: true),
  sum: const UserSumAggregateInput(profileViews: true),
);
```

### Unique Selectors

Generated `WhereUniqueInput` types support both scalar unique fields and compound unique selectors.

Scalar example:

```dart
const UserWhereUniqueInput(email: 'alice@prisma.io')
```

Compound example:

```dart
const MembershipWhereUniqueInput(
  tenantId_slug: MembershipTenantIdSlugCompoundUniqueInput(
    tenantId: 1,
    slug: 'alice',
  ),
)
```

Exactly one unique selector must be provided for each `WhereUniqueInput`.

### Validate Schema

```bash
dart run packages/comon_orm/bin/comon_orm.dart validate schema.prisma
```

### Generate Client

```bash
dart run packages/comon_orm/bin/comon_orm.dart generate schema.prisma
```

### Preview Generated Client To Stdout

```bash
dart run packages/comon_orm/bin/comon_orm.dart generate-preview schema.prisma
```

### Draft PostgreSQL Migration

```bash
dart run packages/comon_orm_postgresql/bin/comon_orm_postgresql.dart diff \
  --schema schema.prisma \
  --name 20260314_add_users \
  --out prisma/migrations
```

### Apply PostgreSQL Migration

```bash
dart run packages/comon_orm_postgresql/bin/comon_orm_postgresql.dart apply \
  --schema schema.prisma \
  --name 20260314_add_users
```

### Draft SQLite Migration

```bash
dart run packages/comon_orm_sqlite/bin/comon_orm_sqlite.dart diff \
  --schema schema.prisma \
  --name 20260314_add_users \
  --out prisma/migrations
```

### Apply SQLite Migration

```bash
dart run packages/comon_orm_sqlite/bin/comon_orm_sqlite.dart apply \
  --schema schema.prisma \
  --name 20260314_add_users
```

## Practical Notes

- If you want the current implementation status and remaining gaps, use [PRISMA_COMPATIBILITY_PLAN.md](/Users/serezhia/Documents/GitHub/comon_orm/PRISMA_COMPATIBILITY_PLAN.md).
- If you need a runnable example, use [examples/postgres/README.md](/Users/serezhia/Documents/GitHub/comon_orm/examples/postgres/README.md).
- If you need the smallest working path: write `schema.prisma`, run `validate`, run `generate`, then open a PostgreSQL or SQLite adapter with the parsed schema.
