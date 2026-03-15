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
- local `openAndApply...` helpers для schema-driven bootstrap

Следом планируется:

- более широкое runtime покрытие тестами для relation и aggregate сценариев
- альтернативные runtime backend-ы, если проект позже захочет поддерживать что-то кроме текущего `sqflite` path

Фазы реализации зафиксированы в [PLAN.md](PLAN.md).

## Быстрый старт

Добавьте зависимости:

```yaml
dependencies:
  comon_orm: ^0.0.1-alpha
  comon_orm_sqlite_flutter: ^0.0.1-alpha
```

Разрешите database path из `schema.prisma`, примените схему и используйте adapter:

```dart
import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';

Future<void> main() async {
  final adapter = await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaPath(
    schemaPath: 'schema.prisma',
  );

  try {
    final created = await adapter.create(
      const CreateQuery(
        model: 'User',
        data: <String, Object?>{'email': 'alice@example.com'},
      ),
    );

    print(created['email']);
  } finally {
    await adapter.close();
  }
}
```

## Границы текущей версии

- Существующий `comon_orm_sqlite` остается source of truth для CLI, migrations и introspection.
- Flutter и web runtime поддержка добавляется здесь поэтапно, а не через встраивание этих ограничений в VM-ориентированный SQLite package.
- Пакет теперь участвует в root pub workspace и monorepo validation scripts.
