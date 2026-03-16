[English](README.md) | **Русский**

# comon_orm

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/anomalyco/opencode)

`comon_orm` это schema-first ORM toolkit для Dart, вдохновленный Prisma.

Главная идея простая: вы описываете модели в `schema.prisma`, генерируете типизированный Dart client и работаете дальше уже через generated API, а не через ручные map-ы, SQL-строки и неявные runtime-конвенции.

## ✨ Пакеты

| Что | Для чего |
| --- | --- |
| `packages/comon_orm` | core: parser, validator, formatter, codegen, query models, in-memory adapter, migration metadata |
| `packages/comon_orm_postgresql` | runtime adapter, introspection и migrations для PostgreSQL |
| `packages/comon_orm_sqlite` | runtime adapter, introspection и rebuild-based migrations для SQLite |
| `packages/comon_orm_sqlite_flutter` | Flutter-oriented SQLite runtime adapter на базе экосистемы `sqflite`, плюс легкие app-side local migration helper-ы |
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

Этот путь предполагает, что схема базы уже создана через migrations или отдельный local bootstrap. Для PostgreSQL сценарий такой же, меняется только adapter:

```dart
final db = await GeneratedComonOrmClientPostgresql.open();
```

Сводка по runtime surface:

- Runtime path: generated metadata через `GeneratedComonOrmClient.openInMemory()`, `GeneratedComonOrmClientSqlite.open(...)` и `GeneratedComonOrmClientPostgresql.open(...)`
- Tooling path: schema-driven `generate`, `check`, `format`, `migrate`, `introspect` и schema-apply flow остаются на `schema.prisma`
- Setup path: provider-specific bootstrap/setup helper-ы могут подготавливать локальную базу вне adapter runtime surfaces, когда одного runtime metadata пути недостаточно
- Flutter local upgrade path: `SqliteFlutterMigrator` и `upgradeSqliteFlutterDatabase(...)` дают явный app-side путь для local SQLite upgrades до `GeneratedComonOrmClientFlutterSqlite.open(...)`

## 🎯 Ключевые фичи

### 🧬 Schema-first workflow

- `schema.prisma` как источник истины
- parsing, validation и canonical formatting
- разрешение `generator client { output = ... }`
- явный выбор SQLite helper-а через `generator client { sqliteHelper = "vm" | "flutter" }`
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
- compiled-metadata runtime bootstrap через `openFromGeneratedSchema(...)`
- schema introspection
- DDL и migration workflow
- `diff`, `apply`, `rollback`, `status`, история миграций
- SQL pushdown для aggregate и group-by
- поддержка части native types и enum workflows

### 🪶 SQLite

- embedded runtime на базе `sqlite3`
- compiled-metadata runtime bootstrap через `openFromGeneratedSchema(...)`
- schema introspection
- `diff`, `apply`, `rollback`, история миграций
- rebuild-based migrations для изменений, которые SQLite не умеет выразить через `ALTER TABLE`
- поддержка части native types для SQLite-поверхности

### 🧪 Для тестов и локальной разработки

- `InMemoryDatabaseAdapter` в core-пакете
- schema-driven runtime semantics, включая `@updatedAt`, если adapter создается из generated metadata или parsed schema metadata
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
- preferred application runtime path теперь это `GeneratedComonOrmClient.runtimeSchema` плюс `openFromGeneratedSchema(...)`
- schema apply теперь относится к tooling/setup flow, а не к обычным runtime adapter entrypoint-ам
- Flutter/local-first SQLite upgrades теперь также можно выражать как явные Dart-coded local migrations через `comon_orm_sqlite_flutter`, но этот путь относится к app-local базам, а не к shared reviewed rollout
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

Для Flutter/local-first SQLite правильное разделение теперь такое:

- reviewed CLI migrations для shared database и operational rollout
- explicit app-side local upgrades для device-local SQLite файлов, когда данные нужно мигрировать in-place
- reset или rebuild для disposable local cache, когда migration code не стоит своей сложности

## 📚 С чего начать

- Нужны parser, validator, codegen или in-memory runtime: смотрите `packages/comon_orm/README.md`
- Нужен PostgreSQL runtime: смотрите `packages/comon_orm_postgresql/README.md`
- Нужен SQLite runtime: смотрите `packages/comon_orm_sqlite/README.md`
- Нужен Flutter-oriented SQLite runtime: смотрите `packages/comon_orm_sqlite_flutter/README.md`
- Нужен пример приложения: смотрите `examples/postgres/README.md`
- Нужен Flutter SQLite пример приложения: смотрите `examples/flutter_sqlite/README.md`
- Нужен migration workflow: смотрите [MIGRATIONS.md](MIGRATIONS.md)
- Нужна схема и справка по DSL: смотрите [SCHEMA_REFERENCE.md](SCHEMA_REFERENCE.md)
- Нужен текущий roadmap по refactor и Prisma-like DX: смотрите [REFACTOR_PLAN.md](REFACTOR_PLAN.md)
- Нужен release flow: смотрите [RELEASING.md](RELEASING.md)

## 🧱 Текущие границы проекта

`comon_orm` вдохновлен Prisma, но не заявляет full Prisma parity.

Что это означает на практике:

- поддерживается уже довольно широкая полезная поверхность для реальной работы
- часть advanced Prisma features еще не реализована
- покрытие `@db.*` сейчас выборочное и зависит от provider-а
- отдельные provider-specific edge cases все еще возможны

Лучше воспринимать проект как прагматичный schema-first ORM для Dart с реальными migrations и generated client, а не как попытку повторить Prisma один в один.

## 🧩 Prisma-like Compatibility Snapshot

Уже сильная часть проекта:

- типизированный generated client с delegate-ами, моделями, input-ами, `select` и `include`
- CRUD flow с `findUnique`, `findFirst`, `findMany`, `count`, `create`, `update`, `updateMany`, `delete` и `deleteMany`, включая generated `distinct` для `findMany(...)` и `findFirst(...)`
- transactions, aggregates и `groupBy`
- compound id и compound unique selectors
- nested create flow
- generated-metadata-first runtime startup для in-memory, SQLite, PostgreSQL и Flutter SQLite путей
- полноценный migration workflow для PostgreSQL и SQLite

Реализовано, но еще частично или зависит от provider-а:

- `upsert`, пока реализован через транзакции generated delegate поверх уже существующих `findUnique`, `create` и `update`
- `createMany`, пока реализован как транзакционный generated bulk-write helper поверх повторяющихся `create`
- `createMany(skipDuplicates: true)`, пока реализован через schema-derived unique selector checks плюс provider-aware duplicate-conflict handling на generated bulk path
- scalar field update operators: generated `set` для scalar-like полей и `increment` / `decrement` для numeric полей поддерживаются в `update(...)`, `upsert(...)` и `updateMany(...)`; bulk computed updates разрешаются транзакционно по каждой подходящей записи, а не через adapter-native arithmetic
- nested `connect`, `disconnect`, `set` и `connectOrCreate`: generated update flow поддерживает это для direct relations, включая compound direct foreign-key relations, implicit many-to-many relations и inverse one-to-one relations, когда replacement semantics валидны; `updateMany(...)` переиспользует тот же per-record relation-write path, а create-path relation writes теперь тоже откладывают эту же работу до момента, когда parent record уже создан внутри транзакции, там где это допускают semantics целевой relation
- cursor pagination: generated `findMany(cursor: ...)` теперь поддерживает и forward, и backward pagination поверх текущего ordered/distinct result set через положительные и отрицательные `take`, а generated `findFirst(cursor: ...)` переиспользует тот же cursor-slicing path; оба сценария остаются фичами generated-client layer, корректно работают с generated `distinct`, при `include` или `select` перезагружают projected rows по primary key и все еще не добавляют adapter-native cursor pushdown
- покрытие `@db.*` остается выборочным и зависит от конкретного provider-а
- часть aggregate, predicate и relation edge cases все еще различается между provider-ами
- Flutter и web поддержка намеренно уже, чем основной Dart VM/server path

Замечания по bulk semantics и provider behavior:

- `createMany(...)` и `updateMany(...)` сейчас в первую очередь держат одинаковую semantics между provider-ами, а не пытаются в adapter-native bulk SQL. Generated delegates выполняют эти сценарии транзакционно поверх уже существующих runtime primitives, поэтому PostgreSQL, SQLite, Flutter SQLite и in-memory проходят через один и тот же behavioral contract даже там, где конкретная база могла бы сделать более специальный shortcut.
- `createMany(skipDuplicates: true)` сначала использует generated unique selectors, когда input их вообще может выразить, а затем все равно считает provider duplicate-conflict errors пропускаемыми на insert path. На практике это значит, что duplicate races подавляются консистентно между SQL provider-ами, а не просачиваются наружу как adapter-specific ошибки generated delegate surface.
- cursor pagination пока остается generated-client feature. `findMany(cursor: ...)` и `findFirst(cursor: ...)` режут уже построенный ordered/distinct result set и при необходимости заново загружают projected rows по primary key; adapter-native cursor pushdown они по-прежнему не обещают.

Пример advanced generated-client flow:

```dart
final user = await db.user.create(
	data: const UserCreateInput(
		name: 'Alice',
		role: UserRole.manager,
	),
);

await db.user.update(
	where: UserWhereUniqueInput(id: user.id!),
	data: UserUpdateInput(
		todos: TodoUpdateNestedManyWithoutUserInput(
			connectOrCreate: [
				TodoConnectOrCreateWithoutUserInput(
					where: const TodoWhereUniqueInput(id: 1001),
					create: const TodoCreateWithoutUserInput(
						id: 1001,
						title: 'Ship docs',
						status: TodoStatus.inProgress,
					),
				),
			],
		),
	),
);

await db.todo.updateMany(
	where: const TodoWhereInput(status: TodoStatus.pending),
	data: const TodoUpdateInput(status: TodoStatus.done),
);

final nextTodo = await db.todo.findFirst(
	cursor: const TodoWhereUniqueInput(id: 1001),
	orderBy: const [TodoOrderByInput(id: SortOrder.asc)],
	distinct: const [TodoScalarField.id],
);
```

Еще не реализовано:

- часть required-disconnect, required-set или required-replacement relation cases, где nested write orphan-ит уже привязанные required relation targets; при этом additive/reassign direct-list `set` и unrelated direct-list `disconnect` no-op cases уже разрешены

Активный roadmap по этим пунктам вынесен в [REFACTOR_PLAN.md](REFACTOR_PLAN.md).

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
