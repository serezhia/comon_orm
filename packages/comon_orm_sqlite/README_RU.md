[English](README.md) | **Русский**

# comon_orm_sqlite

[![DeepWiki](https://img.shields.io/badge/DeepWiki-comon__orm-0EA5E9?logo=bookstack&logoColor=white)](https://deepwiki.com/serezhia/comon_orm)

`comon_orm_sqlite` это SQLite runtime package для `comon_orm`.

Используйте его, когда в схеме указано `provider = "sqlite"` и нужен embedded database workflow со schema-aware runtime behavior, introspection и migrations.

## ✨ Что дает пакет

- runtime `DatabaseAdapter` на базе `sqlite3`
- file-backed и in-memory SQLite workflows
- schema application и introspection для поддерживаемой SQLite-поверхности
- migration planning, apply, rollback, history и status helpers
- generated-metadata-first runtime bootstrap для file-backed и in-memory adapter-ов

## 🚀 Быстрый старт

Добавьте зависимости:

```yaml
dependencies:
	comon_orm: ^0.0.1-alpha.1
	comon_orm_sqlite: ^0.0.1-alpha.1
```

Пример с generated client:

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

Это preferred runtime path после того, как база уже создана или обновлена отдельно.

```dart
final db = await GeneratedComonOrmClientSqlite.open();
```

## Runtime Paths

- Runtime path: `GeneratedComonOrmClient.openInMemory()` или `GeneratedComonOrmClientSqlite.open(...)`
- Tooling/setup path: schema-driven migrate/apply flow через CLI и schema tools

## 🎯 Ключевые фичи

### 🪶 Embedded SQLite runtime

- runtime adapter поверх `sqlite3`
- file-backed и in-memory сценарии
- compiled-metadata runtime bootstrap через `openFromGeneratedSchema(...)`
- хороший fit для local tools, desktop utilities, тестов и легковесных приложений

### 🧭 Миграции

- `diff`, `apply`, `rollback`, `status` и история миграций
- rebuild-aware planning для ограничений SQLite
- schema-aware warnings для destructive changes
- migration metadata, совместимая с unified CLI flow

### 🔍 Introspection и schema apply

- интроспекция поддерживаемой SQLite схемы обратно в понятия `schema.prisma`
- применение поддерживаемых schema changes к базе
- сохранение mapped names и relation metadata в пределах поддерживаемой поверхности

## 🧭 Рекомендуемый migration flow

Предпочтительный flow идет через unified core CLI:

```bash
dart run comon_orm migrate diff --schema schema.prisma --name 20260315_init
dart run comon_orm migrate apply --schema schema.prisma --name 20260315_init
dart run comon_orm migrate rollback --schema schema.prisma --from prisma/migrations
```

Важно:

- dispatcher читает `datasource.provider` и автоматически делегирует выполнение в этот пакет
- preferred application runtime path теперь это `GeneratedComonOrmClient.runtimeSchema` плюс `openFromGeneratedSchema(...)`
- schema apply остается в tooling/setup flow, а не в runtime adapter convenience API
- часть schema transitions требует rebuild, потому что SQLite не умеет выразить их через `ALTER TABLE`

## 📱 Платформы

| Платформа / сценарий | Статус | Комментарий |
| --- | --- | --- |
| Dart CLI / server / backend | ✅ Основной сценарий | Это главная поддерживаемая цель |
| Flutter mobile / desktop | ⚠️ Разумно в некоторых архитектурах | SQLite может хорошо лечь в local-first или embedded сценарии, но пакет все равно документирован прежде всего вокруг Dart VM workflows |
| Dart Web / Flutter Web | ❌ Не поддерживается | Этот SQLite runtime не является browser-targeted package |

## 🧱 Границы пакета

- Некоторые schema changes по-прежнему требуют rebuild, поэтому warnings важны.
- У SQLite более узкая native type surface, чем у PostgreSQL.
- Enum support использует SQLite-compatible storage, а не native enum types.
