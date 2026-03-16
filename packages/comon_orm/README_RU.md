[English](README.md) | **Русский**

# comon_orm

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm` это provider-agnostic core для всей линейки пакетов: парсинг схемы, валидация, форматирование, codegen, query models и in-memory runtime.

Используйте этот пакет, если вам нужно работать с `schema.prisma`, генерировать типизированный Dart client или запускать быстрые schema-driven тесты без реальной базы.

## ✨ Что дает пакет

- schema AST, parser, validator и workflow helpers
- форматирование схемы и разрешение output для generator-а
- генерация typed client кода
- provider-agnostic query models и контракты `DatabaseAdapter`
- `InMemoryDatabaseAdapter` для тестов и локальных сценариев
- migration artifacts и risk-analysis helpers, не привязанные к конкретному SQL dialect

Когда нужен реальный database adapter, introspection или выполнение миграций, используйте `comon_orm_postgresql` или `comon_orm_sqlite`.

## 🚀 Быстрый старт

Добавьте зависимость:

```yaml
dependencies:
	comon_orm: ^0.0.2-alpha
```

Провалидируйте, отформатируйте и сгенерируйте client из схемы:

```bash
dart run comon_orm check schema.prisma
dart run comon_orm format schema.prisma
dart run comon_orm generate schema.prisma
```

`validate` по-прежнему доступен как alias для `check`.

Минимальный пример с generated client:

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

Если меняется схема в примере, пересоберите client:

```bash
dart run comon_orm generate example/schema.prisma
```

## 🎯 Ключевые фичи

### 🧬 Schema workflow

- parsing, validation и canonical formatting для `schema.prisma`
- разрешение `generator client { output = ... }`
- явный выбор SQLite helper target через `generator client { sqliteHelper = "vm" | "flutter" }`
- file-aware diagnostics через `SchemaWorkflow`
- единый CLI для `check`, `format` и `generate`

### 🤖 Generated client

- типизированные модели, input-ы и delegates
- `findUnique`, `findFirst`, `findMany`, `count`
- `create`, `update`, `updateMany`, `delete`, `deleteMany`
- `upsert`, `createMany` и `createMany(skipDuplicates: true)`
- `transaction`
- `select`, `include`, nested relation create inputs, а также generated nested `connect`, `disconnect`, `set` и `connectOrCreate`, когда это допускают relation semantics
- `distinct`, `orderBy`, `skip`, `take`
- `aggregate` и `groupBy`
- scalar и compound `WhereUniqueInput`

Продвинутая generated surface сейчас сознательно остается generated-layer-first:

- `createMany(...)` и `updateMany(...)` работают как транзакционные delegate conveniences поверх уже существующих runtime primitives, что сохраняет одинаковую semantics между in-memory и SQL provider-ами вместо расхождения поведения по backend-ам.
- `findMany(cursor: ...)` и `findFirst(cursor: ...)` пока режут результат на уровне generated delegate, а не обещают adapter-native cursor pushdown.

Короткий advanced example на схеме из package example:

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

### 🧪 In-memory runtime

- быстрые тесты без реальной базы
- schema-driven runtime semantics при создании adapter-а из generated metadata или со `schema:`
- удобно для проверки generated client поведения и query workflows

### 🧱 Общие building blocks

- provider-agnostic query models
- контракты `DatabaseAdapter` для кастомных backend-ов
- shared migration artifact и risk-analysis helpers для provider packages
- web-safe parsing, validation и formatting схемы из in-memory source текста

## 📚 Типовые сценарии

- валидировать и форматировать `schema.prisma` перед коммитом generator или migration изменений
- генерировать typed client из схемы
- гонять тесты на `InMemoryDatabaseAdapter`
- реализовывать свой adapter поверх `DatabaseAdapter`, если нужный backend не покрыт provider packages

## 📱 Платформы

| Платформа / сценарий | Статус | Комментарий |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Основной сценарий | Это главная поддерживаемая цель |
| Flutter mobile / desktop | ✅ Core package работает | Query models, parser, validator, codegen types и in-memory runtime можно использовать; file-based tooling все еще рассчитывает на VM filesystem |
| Dart Web / Flutter Web | ✅ Импорт core package поддерживается | Используйте source-based API вроде `loadValidatedSchemaSource(...)`; file-backed workflow и загрузка migration artifacts на web недоступны |

## 🧱 Границы пакета

- Пакет сам по себе не поставляет production SQL adapter.
- Реальные миграции и schema introspection живут в provider packages.
- `comon_orm_postgresql` и текущий `comon_orm_sqlite` остаются VM-ориентированными runtime packages; для браузера нужны отдельные adapter packages.
- Проект вдохновлен Prisma, но не заявляет full Prisma parity.
