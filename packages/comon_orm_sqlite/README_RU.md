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
- bootstrap adapter-а напрямую из `schema.prisma`

## 🚀 Быстрый старт

Добавьте зависимости:

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_sqlite: ^0.0.1-alpha
```

Пример с generated client:

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

Для local bootstrap, который еще и создает отсутствующие таблицы, можно использовать:

```dart
final adapter = await SqliteDatabaseAdapter.openAndApplyFromSchemaPath(
	schemaPath: 'schema.prisma',
);
```

## 🎯 Ключевые фичи

### 🪶 Embedded SQLite runtime

- runtime adapter поверх `sqlite3`
- file-backed и in-memory сценарии
- bootstrap через `openFromSchemaPath(...)`
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
- `openAndApplyFromSchemaPath(...)` удобен для локальной разработки, но это не то же самое, что reviewable migration workflow
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
