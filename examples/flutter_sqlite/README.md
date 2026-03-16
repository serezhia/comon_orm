# Flutter SQLite Example

Пример Flutter-приложения на `comon_orm_sqlite_flutter` с локальной SQLite-базой.

## Что внутри

- загрузка `schema.prisma` как Flutter asset
- локальный SQLite database path через `sqflite`
- bootstrap через `openAndApplyFromSchemaSource(...)`
- generated client в `lib/generated/comon_orm_client.dart`
- базовые CRUD-операции для списка задач
- widget tests для базового smoke flow и очистки completed-задач
- integration test с живым SQLite adapter и generated client

Пример намеренно использует generated client, как и остальные examples в репозитории. UI работает через типизированные `Todo`, `TodoCreateInput`, `TodoUpdateInput` и delegate API, а не через сырые `FindManyQuery` / `CreateQuery` вызовы в самом приложении.

## Запуск

```bash
cd examples/flutter_sqlite
flutter pub get
flutter run

flutter test
flutter test integration_test
```

Пример при старте:

- читает `schema.prisma`
- открывает локальную базу
- применяет схему при локальном старте
- показывает список задач и позволяет добавлять, переключать и удалять completed-задачи

Для этого примера `openAndApplyFromSchemaSource(...)` используется осознанно как local bootstrap flow. Для production-проекта это не замена нормальному migration workflow.
