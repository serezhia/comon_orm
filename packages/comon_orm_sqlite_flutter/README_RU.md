[English](README.md) | **Русский**

# comon_orm_sqlite_flutter

`comon_orm_sqlite_flutter` это Flutter-ориентированный SQLite package для `comon_orm`.

Он нужен для Flutter mobile, desktop и web сценариев поверх экосистемы `sqflite`, при этом `comon_orm_sqlite` остается сфокусированным на Dart VM, CLI workflow, migrations и introspection.

## Почему Это Отдельный Пакет

Этот пакет вынесен отдельно намеренно.

Существующий `comon_orm_sqlite` уже владеет текущим `sqlite3`-based VM runtime, CLI entrypoints, migration helpers, introspection и file-system-oriented workflow. Для Flutter и browser target нужен другой runtime bootstrap и более жесткое отделение от VM-only частей.

Если держать все в одном SQLite package, он начинает одновременно обслуживать runtime embedding, CLI tooling и migration workflow для слишком разных платформ.

На практике разделение такое:

- `comon_orm_sqlite`: Dart VM, CLI, migrations, introspection, local tooling
- `comon_orm_sqlite_flutter`: Flutter-oriented runtime embedding для mobile, desktop и web

Это решение принято для явных platform boundaries, а не потому, что SQLite сам по себе недоступен на web.

## Текущий статус

Пакет находится в активной разработке.

Сейчас он уже дает:

- schema-aware разрешение SQLite datasource для Flutter приложений
- выбор database factory по умолчанию для mobile, desktop и web
- open helpers с поддержкой injected `DatabaseFactory`
- рабочий `DatabaseAdapter` поверх `sqflite_common`
- generated-metadata runtime bootstrap через `openFromGeneratedSchema(...)`
- explicit setup/bootstrap helper-ы вне adapter runtime surface для подготовки локальной базы
- облегченный app-side migration API для versioned local SQLite upgrades на Dart-коде

Следом планируется:

- более широкое runtime покрытие тестами для relation и aggregate сценариев
- альтернативные runtime backend-ы, если проект позже захочет поддерживать что-то кроме текущего `sqflite` path

## Быстрый старт

Добавьте зависимости:

```yaml
dependencies:
  comon_orm: ^0.0.2-alpha
  comon_orm_sqlite_flutter: ^0.0.2-alpha
```

Открыть Flutter SQLite runtime напрямую через generated client helper:

```dart
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

import 'generated/comon_orm_client.dart';

Future<void> main() async {
  final db = await GeneratedComonOrmClientFlutterSqlite.open(
    databasePath: 'app.db',
  );

  try {
    final created = await db.todo.create(
      data: TodoCreateInput(
        title: 'Ship Flutter runtime metadata',
        createdAt: DateTime.now().toUtc(),
      ),
    );

    print(created.title);
  } finally {
    await db.close();
  }
}
```

Такой путь оставляет обычный runtime startup только на generated metadata. Local bootstrap базы живет в явных setup helper-ах вне adapter runtime surface.

## Runtime Paths

- Runtime path: `GeneratedComonOrmClientFlutterSqlite.open(...)`
- Setup path: `SqliteFlutterBootstrap` плюс `SqliteFlutterSchemaApplier` для явной подготовки локальной базы вне обычного runtime startup
- Local upgrade path: `SqliteFlutterMigrator` плюс `upgradeSqliteFlutterDatabase(...)` для versioned app-side SQLite upgrades до runtime open

## Локальные Flutter-Миграции

Теперь пакет также экспортирует легкий migration layer для локальных Flutter SQLite баз.

Он нужен для app-side upgrade сценариев, когда база живет на устройстве и migration logic должна оставаться в Dart-коде.

Использовать его стоит для:

- additive local schema changes
- backfill существующих локальных строк
- rebuild-heavy миграций, где данные нужно переносить в replacement table
- offline-first приложений с важными локальными SQLite данными

Это не замена reviewed migrations для shared database сценариев.

Правильный startup shape выглядит так:

```dart
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

import 'generated/comon_orm_client.dart';

final migrator = SqliteFlutterMigrator(
  currentVersion: 3,
  migrations: <SqliteFlutterMigration>[
    SqliteFlutterMigration.sql(
      fromVersion: 1,
      toVersion: 2,
      debugName: 'add_user_names',
      statements: <String>[
        'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
        'ALTER TABLE users ADD COLUMN last_name TEXT NOT NULL DEFAULT "";',
      ],
    ),
    SqliteFlutterMigration.rebuildTable(
      fromVersion: 2,
      toVersion: 3,
      debugName: 'rebuild_todos',
      tableName: 'todos',
      createReplacementTableSql: '''
        CREATE TABLE todos_new (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          note TEXT,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        );
      ''',
      replacementTableName: 'todos_new',
      copyData: (tx, sourceTable, targetTable) async {
        final oldRows = await tx.rawQuery(
          'SELECT id, title, description, is_done, created_at, updated_at FROM $sourceTable;',
        );
        for (final row in oldRows) {
          await tx.insert(targetTable, <String, Object?>{
            'id': row['id'],
            'title': row['title'],
            'note': row['description'],
            'status': row['is_done'] == 1 ? 'done' : 'todo',
            'created_at': row['created_at'],
            'updated_at': row['updated_at'],
          });
        }
      },
    ),
  ],
);

Future<void> main() async {
  await upgradeSqliteFlutterDatabase(
    databasePath: 'app.db',
    migrator: migrator,
  );

  final db = await GeneratedComonOrmClientFlutterSqlite.open(
    databasePath: 'app.db',
  );

  try {
    print(await db.todo.count());
  } finally {
    await db.close();
  }
}
```

Практические правила:

- reviewed CLI migrations остаются путем для shared, staging и production баз
- если локальные данные disposable, reset обычно лучше сложной migration logic
- `SqliteFlutterMigration.sql(...)` подходит для простых additive steps
- `SqliteFlutterMigration.rebuildTable(...)` или custom migration callback подходят для rebuild-heavy local upgrades
- сначала upgrade, потом runtime open

## Границы текущей версии

- Существующий `comon_orm_sqlite` остается source of truth для CLI, migrations и introspection.
- Flutter и web runtime поддержка добавляется здесь поэтапно, а не через встраивание этих ограничений в VM-ориентированный SQLite package.
- Пакет теперь участвует в root pub workspace и monorepo validation scripts.
