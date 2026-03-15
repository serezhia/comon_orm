[English](README.md) | **Русский**

# comon_orm

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm` это schema-first ORM toolkit для Dart, вдохновленный Prisma.

Главная идея простая: вы описываете модели в `schema.prisma`, генерируете типизированный Dart client и работаете дальше уже через generated API, а не через ручные map-ы, SQL-строки и неявные runtime-конвенции.

## ✨ Пакеты

| Что | Для чего |
| --- | --- |
| `packages/comon_orm` | core: parser, validator, formatter, codegen, query models, in-memory adapter, migration metadata |
| `packages/comon_orm_postgresql` | runtime adapter, introspection и migrations для PostgreSQL |
| `packages/comon_orm_sqlite` | runtime adapter, introspection и rebuild-based migrations для SQLite |
| `packages/comon_orm_sqlite_flutter` | Flutter-oriented SQLite runtime adapter на базе экосистемы `sqflite` |
| `examples/postgres` | runnable пример приложения на PostgreSQL |
| `examples/flutter_sqlite` | runnable Flutter пример с Flutter-oriented SQLite runtime |

## 🚀 Быстрый старт

Базовый старт выглядит так:

```bash
dart run comon_orm check schema.prisma
dart run comon_orm format schema.prisma
dart run comon_orm generate schema.prisma
```

После этого вы работаете через generated client.

Пример со `sqlite`, без ручной сборки query-моделей и без прямой работы с low-level API:

```dart
import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final adapter = await SqliteDatabaseAdapter.openFromSchemaPath(
		schemaPath: 'schema.prisma',
	);

	try {
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
	} finally {
		adapter.dispose();
	}
}
```

Для PostgreSQL сценарий такой же, меняется только adapter:

```dart
final adapter = await PostgresqlDatabaseAdapter.openFromSchemaPath(
	schemaPath: 'schema.prisma',
);
```

## 🎯 Ключевые фичи

### 🧬 Schema-first workflow

- `schema.prisma` как источник истины
- parsing, validation и canonical formatting
- разрешение `generator client { output = ... }`
- единый CLI для `check`, `format` и `generate`

### 🤖 Generated client

- типизированные модели, input-ы и delegate API
- `findUnique`, `findFirst`, `findMany`, `count`
- `create`, `update`, `updateMany`, `delete`, `deleteMany`
- `transaction`
- `select`, `include`, nested create inputs
- `distinct`, `orderBy`, `skip`, `take`
- `aggregate` и `groupBy`
- scalar и compound `WhereUniqueInput`

### 🔗 Relations и схема

- `@id`, `@unique`, `@@id`, `@@unique`, `@@index`
- `@map`, `@@map`, `@updatedAt`, defaults, enums
- one-to-one и one-to-many relations
- named relations и self-relations
- compound references
- implicit many-to-many, включая сценарии с compound keys
- referential actions: `onDelete` и `onUpdate`

### 🐘 PostgreSQL

- runtime adapter на базе `package:postgres`
- bootstrap из `schema.prisma` через `openFromSchemaPath(...)`
- schema introspection
- DDL и migration workflow
- `diff`, `apply`, `rollback`, `status`, история миграций
- SQL pushdown для aggregate и group-by
- поддержка части native types и enum workflows

### 🪶 SQLite

- embedded runtime на базе `sqlite3`
- bootstrap из `schema.prisma` через `openFromSchemaPath(...)`
- schema introspection
- `diff`, `apply`, `rollback`, история миграций
- rebuild-based migrations для изменений, которые SQLite не умеет выразить через `ALTER TABLE`
- поддержка части native types для SQLite-поверхности

### 🧪 Для тестов и локальной разработки

- `InMemoryDatabaseAdapter` в core-пакете
- schema-driven runtime semantics, включая `@updatedAt`, если adapter создается со schema metadata
- быстрые тестовые сценарии без поднятия реальной базы

## 🧭 Миграции

Предпочтительный пользовательский flow идет через единый CLI из core-пакета:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

Важно:

- dispatcher читает `datasource.provider` и сам делегирует выполнение в `comon_orm_postgresql` или `comon_orm_sqlite`
- `openAndApplyFromSchemaPath(...)` это удобный bootstrap для локальной разработки, а не рекомендуемая стратегия для shared/prod окружений
- destructive changes и warning-bearing migration plans требуют ручной проверки

Подробности вынесены в [MIGRATIONS.md](MIGRATIONS.md).

## 📱 Платформы

Текущий фокус проекта это Dart VM и server-side use cases.

| Платформа / сценарий | Статус | Комментарий |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Основной сценарий | Это главная целевая платформа репозитория сейчас |
| Flutter mobile / desktop | ⚠️ Смешанная поддержка | `comon_orm` core можно использовать, SQLite подходит для VM-based embedded сценариев, а PostgreSQL реалистичен только в нишевых архитектурах с прямым подключением |
| Dart Web / Flutter Web | ⚠️ Core + Flutter SQLite path | `comon_orm` core безопасно импортируется на web, а `comon_orm_sqlite_flutter` теперь является целевым SQLite runtime путем для browser/mobile/desktop сценариев; PostgreSQL по-прежнему не browser target |

Если коротко: у репозитория теперь есть web-safe core layer, VM-ориентированные PostgreSQL/SQLite пакеты для server/tooling сценариев и отдельный Flutter-first SQLite пакет для mobile, desktop и web embedding.

## 📚 С чего начать

- Нужны parser, validator, codegen или in-memory runtime: смотрите `packages/comon_orm/README.md`
- Нужен PostgreSQL runtime: смотрите `packages/comon_orm_postgresql/README.md`
- Нужен SQLite runtime: смотрите `packages/comon_orm_sqlite/README.md`
- Нужен Flutter-oriented SQLite runtime: смотрите `packages/comon_orm_sqlite_flutter/README.md`
- Нужен пример приложения: смотрите `examples/postgres/README.md`
- Нужен Flutter SQLite пример приложения: смотрите `examples/flutter_sqlite/README.md`
- Нужен migration workflow: смотрите [MIGRATIONS.md](MIGRATIONS.md)
- Нужна схема и справка по DSL: смотрите [SCHEMA_REFERENCE.md](SCHEMA_REFERENCE.md)
- Нужен release flow: смотрите [RELEASING.md](RELEASING.md)

## 🧱 Текущие границы проекта

`comon_orm` вдохновлен Prisma, но не заявляет full Prisma parity.

Что это означает на практике:

- поддерживается уже довольно широкая полезная поверхность для реальной работы
- часть advanced Prisma features еще не реализована
- покрытие `@db.*` сейчас выборочное и зависит от provider-а
- отдельные provider-specific edge cases все еще возможны

Лучше воспринимать проект как прагматичный schema-first ORM для Dart с реальными migrations и generated client, а не как попытку повторить Prisma один в один.

## 🛠️ Разработка monorepo

Этот репозиторий использует Dart pub workspace из корня.

Базовая проверка перед публикацией:

```bash
dart pub get

dart run tool/format_all.dart
dart run tool/analyze_all.dart
dart run tool/test_all.dart
dart run tool/dry_run_all.dart

dart run tool/pre_publish.dart
```

Доступные root helpers:

- `dart run tool/format_all.dart`
- `dart run tool/analyze_all.dart`
- `dart run tool/test_all.dart`
- `dart run tool/dry_run_all.dart`
- `dart run tool/pre_publish.dart`

В VS Code доступны те же task-ы:

- `format: all packages`
- `analyze: all packages`
- `test: all packages`
- `publish: dry-run all`
- `pre-publish`
