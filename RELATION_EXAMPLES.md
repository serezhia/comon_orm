# Relation Examples

These examples focus on the generated-client surface, not the low-level query model layer.

## One-To-One

Schema:

```prisma
model User {
  id      Int      @id @default(autoincrement())
  email   String   @unique
  profile Profile?
}

model Profile {
  id     Int  @id @default(autoincrement())
  bio    String?
  userId Int  @unique
  user   User @relation(fields: [userId], references: [id])
}
```

Create with nested relation:

```dart
final user = await db.user.create(
  data: const UserCreateInput(
    email: 'alice@example.com',
    profile: ProfileCreateNestedOneWithoutUserInput(
      create: ProfileCreateWithoutUserInput(
        bio: 'Ships docs and migrations',
      ),
    ),
  ),
  include: const UserInclude(profile: true),
);
```

## One-To-Many

Schema:

```prisma
model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  posts Post[]
}

model Post {
  id      Int    @id @default(autoincrement())
  title   String
  userId  Int
  user    User   @relation(fields: [userId], references: [id])
}
```

Nested create and include:

```dart
await db.user.create(
  data: const UserCreateInput(
    email: 'alice@example.com',
    posts: PostCreateNestedManyWithoutUserInput(
      create: <PostCreateWithoutUserInput>[
        PostCreateWithoutUserInput(title: 'First post'),
        PostCreateWithoutUserInput(title: 'Second post'),
      ],
    ),
  ),
);

final users = await db.user.findMany(
  include: const UserInclude(posts: true),
);
```

Filter by relation:

```dart
final authorsWithDrafts = await db.user.findMany(
  where: UserWhereInput(
    posts: PostListRelationFilter(
      some: PostWhereInput(title: StringFilter(contains: 'post')),
    ),
  ),
);
```

## Implicit Many-To-Many

Schema:

```prisma
model Post {
  id    Int    @id @default(autoincrement())
  title String
  tags  Tag[]
}

model Tag {
  id    Int    @id @default(autoincrement())
  name  String @unique
  posts Post[]
}
```

Connect existing tags:

```dart
await db.post.create(
  data: PostCreateInput(
    title: 'Ship relation docs',
    tags: TagCreateNestedManyWithoutPostsInput(
      connect: <TagWhereUniqueInput>[
        const TagWhereUniqueInput(name: 'docs'),
        const TagWhereUniqueInput(name: 'orm'),
      ],
    ),
  ),
);
```

## Self-Relation

Schema:

```prisma
model Category {
  id        Int        @id @default(autoincrement())
  name      String
  parentId  Int?
  parent    Category?  @relation("CategoryTree", fields: [parentId], references: [id])
  children  Category[] @relation("CategoryTree")
}
```

Include parent and children:

```dart
final categories = await db.category.findMany(
  include: const CategoryInclude(parent: true, children: true),
);
```

## Compound Relation Reference

Schema:

```prisma
model Account {
  tenantId Int
  slug     String
  name     String
  profiles Profile[]

  @@id([tenantId, slug])
}

model Profile {
  id          Int     @id @default(autoincrement())
  tenantId    Int
  accountSlug String
  bio         String?
  account     Account @relation(fields: [tenantId, accountSlug], references: [tenantId, slug])
}
```

Connect through a compound unique selector:

```dart
await db.profile.create(
  data: ProfileCreateInput(
    bio: 'Compound relation example',
    account: AccountCreateNestedOneWithoutProfilesInput(
      connect: const AccountWhereUniqueInput.tenantIdSlug(
        tenantId: 7,
        slug: 'main',
      ),
    ),
  ),
);
```