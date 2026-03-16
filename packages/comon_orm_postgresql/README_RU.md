[English](README.md) | **Русский**

# comon_orm_postgresql

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm_postgresql` это PostgreSQL runtime package для `comon_orm`.

Используйте его, когда в схеме указано `provider = "postgresql"` и вам нужен реальный adapter, schema introspection и migrations поверх PostgreSQL-совместимой инфраструктуры.

## ✨ Что дает пакет

- runtime `DatabaseAdapter` на базе `package:postgres`
- generated-metadata-first runtime bootstrap из connection config
- schema apply и introspection для поддерживаемой PostgreSQL-поверхности
- migration planning, apply, rollback, history и status helpers
- provider implementation, который использует `dart run comon_orm migrate ...`

## 🚀 Быстрый старт

Добавьте зависимости:

```yaml
dependencies:
	comon_orm: ^0.0.1-alpha.1
	comon_orm_postgresql: ^0.0.1-alpha.1
```

Пример с generated client:

```dart
import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final db = await GeneratedComonOrmClientPostgresql.open();

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

Это preferred runtime path после того, как схема базы уже применена.

```dart
final db = await GeneratedComonOrmClientPostgresql.open();
```

## Runtime Paths

- Runtime path: `GeneratedComonOrmClientPostgresql.open(...)`
- Tooling/setup path: schema-driven migrate/apply flow через CLI и schema tools

## 🎯 Ключевые фичи

### 🐘 PostgreSQL runtime

- pooled sessions из `package:postgres`
- compiled-metadata runtime bootstrap через `openFromGeneratedSchema(...)`
- SQL-backed выполнение generated client операций
- pushdown для aggregate и group-by

### 🧭 Миграции

- `diff`, `apply`, `rollback`, `status` и история миграций
- schema-aware warnings для рискованных изменений
- introspection-backed planning и provider-specific DDL generation
- поддержка enum workflows, mapped names, foreign keys и relation diffs в поддерживаемой поверхности

### 🔍 Introspection и schema apply

- интроспекция живой PostgreSQL схемы обратно в понятия `schema.prisma`
- применение поддерживаемых schema changes к базе
- сохранение migration metadata, используемой unified workflow

## 🧭 Рекомендуемый migration flow

Обычно миграции лучше запускать через unified CLI из core-пакета:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate status --schema schema.prisma --from prisma/migrations
```

Важно:

- dispatcher читает `datasource.provider` и автоматически делегирует выполнение в этот пакет
- preferred application runtime path теперь это `GeneratedComonOrmClient.runtimeSchema` плюс `openFromGeneratedSchema(...)`
- schema apply остается в tooling/setup flow, а не в runtime adapter convenience API
- destructive enum transitions и другие рискованные изменения требуют ручной проверки

## 📱 Платформы

| Платформа / сценарий | Статус | Комментарий |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Основной сценарий | Это главная поддерживаемая цель |
| Flutter mobile / desktop | ⚠️ Скорее нишевый VM-сценарий | Реалистично только в специальных архитектурах, где PostgreSQL runtime вообще уместен |
| Dart Web / Flutter Web | ❌ Не поддерживается | PostgreSQL runtime flow не является browser target |

## 🧱 Границы пакета

- Пакет ориентирован именно на PostgreSQL semantics, а не на generic SQL.
- Поддерживаемая поверхность уже практична, но это не full Prisma parity.
- Совместимость с CockroachDB не обещается.
