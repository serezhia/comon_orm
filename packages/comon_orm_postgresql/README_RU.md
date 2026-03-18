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
- и generated-helper openers, и `PostgresqlDatabaseAdapter.openFrom...(...)` внутри используют pooled sessions из `package:postgres`

## Pooling подключений

PostgreSQL runtime paths в этом пакете по умолчанию используют pool.

- `GeneratedComonOrmClientPostgresql.open(...)` резолвит metadata и открывает pooled adapter для generated client
- `PostgresqlDatabaseAdapter.openFromUrl(...)` и `openFromGeneratedSchema(...)` тоже создают внутренний `package:postgres` pool
- `PostgresqlDatabaseAdapter.connect(...)` подходит, когда удобнее передать структурированный host/database/user/SSL config вместо URL

Пример с явным созданием pooled adapter:

```dart
import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
	final connectionUrl = Platform.environment['DATABASE_URL'];
	if (connectionUrl == null || connectionUrl.isEmpty) {
		stderr.writeln('Set DATABASE_URL before running this example.');
		exitCode = 64;
		return;
	}

	final adapter = await PostgresqlDatabaseAdapter.openFromGeneratedSchema(
		schema: GeneratedComonOrmClient.runtimeSchema,
		connectionUrl: connectionUrl,
	);
	final db = GeneratedComonOrmClient(adapter: adapter);

	try {
		final users = await db.user.findMany();
		print(users.length);
	} finally {
		await db.close();
	}
}
```

Пример со структурированными настройками подключения:

```dart
final adapter = await PostgresqlDatabaseAdapter.connect(
	config: const PostgresqlConnectionConfig(
		host: 'localhost',
		database: 'app',
		username: 'postgres',
		password: 'postgres',
	),
	schema: yourSchemaDocument,
);
```

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
dart run comon_orm check
dart run comon_orm generate
dart run comon_orm migrate dev --name 20260315_init
dart run comon_orm migrate status
dart run comon_orm migrate deploy
```

Важно:

- dispatcher читает `datasource.provider` и автоматически делегирует выполнение в этот пакет
- preferred application runtime path теперь это `GeneratedComonOrmClient.runtimeSchema` плюс `openFromGeneratedSchema(...)`
- schema apply остается в tooling/setup flow, а не в runtime adapter convenience API
- destructive enum transitions и другие рискованные изменения требуют ручной проверки
- `db push` подходит для прототипов или disposable database, но для shared PostgreSQL flow лучше использовать `migrate dev` и `migrate deploy`

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
