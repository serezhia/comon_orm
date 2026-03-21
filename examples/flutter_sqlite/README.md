# Flutter SQLite Example

Пример Flutter-приложения на `comon_orm_sqlite_flutter` с локальной SQLite-базой.

## Что внутри

- локальный SQLite database path через `sqflite`
- normal runtime path через `GeneratedComonOrmClientFlutterSqlite.open(...)`
- отдельный test/setup bootstrap через `SqliteFlutterBootstrap` и `SqliteFlutterSchemaApplier`
- generated client в `lib/generated/comon_orm_client.dart`
- compiled runtime metadata в `GeneratedComonOrmClient.runtimeSchema`
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

Для первичной локальной подготовки схемы можно отдельно выполнить:

```bash
cd examples/flutter_sqlite
dart run ../../packages/comon_orm/bin/comon_orm.dart check
dart run ../../packages/comon_orm/bin/comon_orm.dart generate
dart run ../../packages/comon_orm/bin/comon_orm.dart db push
```

Если локальную базу нужно полностью пересоздать во время разработки, вместо `db push` можно использовать `dart run ../../packages/comon_orm/bin/comon_orm.dart migrate reset`.

Пример при старте:

- если локальная база уже существует, открывает ее напрямую из generated metadata
- если базы нет, завершится с ошибкой и попросит предварительно создать локальную базу через tooling/setup flow
- показывает список задач и позволяет добавлять, переключать и удалять completed-задачи

Runtime приложения теперь целиком generated-only: `GeneratedComonOrmClientFlutterSqlite.open(...)`. Bootstrap в integration/setup сценариях идет отдельно через `SqliteFlutterBootstrap` и `SqliteFlutterSchemaApplier`.

В реальном offline-first приложении между этими двумя шагами теперь можно вставить и явный local upgrade layer через `SqliteFlutterMigrator`.

Типовой startup flow для такого проекта:

```dart
final migrator = SqliteFlutterMigrator(
	currentVersion: 2,
	migrations: <SqliteFlutterMigration>[
		SqliteFlutterMigration.sql(
			fromVersion: 1,
			toVersion: 2,
			debugName: 'add_first_name',
			statements: <String>[
				'ALTER TABLE users ADD COLUMN first_name TEXT NOT NULL DEFAULT "";',
			],
		),
	],
);

await upgradeSqliteFlutterDatabase(
	databasePath: 'app.db',
	migrator: migrator,
);

final db = await GeneratedComonOrmClientFlutterSqlite.open(
	databasePath: 'app.db',
);
```

Если миграция rebuild-heavy, можно использовать `SqliteFlutterMigration.rebuildTable(...)` и описать только создание replacement table плюс перенос данных.

Для production-проекта это всё равно не замена нормальному migration workflow.

Эта demo-schema специально остается CRUD-simple: здесь нет relations и unique selectors сверх `id`, поэтому advanced surfaces вроде nested `connectOrCreate` показать не на чем. При этом сам checked-in generated client для этой схемы уже включает те же bulk и cursor entry points, что и остальные generated clients в репозитории, включая `createMany(...)`, `createMany(skipDuplicates: true)`, `updateMany(...)`, `findMany(cursor: ...)` и `findFirst(cursor: ...)`.
