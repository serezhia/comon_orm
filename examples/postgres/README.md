# PostgreSQL Dart Frog Example

Пример `dart_frog`-приложения на PostgreSQL, использующий `comon_orm` и `comon_orm_postgresql`.

## Что внутри

- `User` с полями `id`, `name`, `role`
- `Todo` с полями `id`, `title`, `status`, `createdAt`, `userId`
- native PostgreSQL enums: `UserRole` (`admin`, `developer`, `manager`) и `TodoStatus` (`pending`, `inProgress`, `done`)
- CRUD для `/users` и `/todos`
- generated-only runtime startup через compiled metadata

## Запуск PostgreSQL через Docker

```bash
docker run --rm -d \
  --name comon-orm-example-pg \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_DB=comon_orm_example \
  -p 5432:5432 \
  postgres:16-alpine
```

## Запуск приложения

```bash
dart pub get
export DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/comon_orm_example?sslmode=disable
dart run ../../packages/comon_orm/bin/comon_orm.dart generate
dart pub global activate dart_frog_cli
dart_frog dev
```

`generate` теперь использует `generator client { output = "lib/generated" }` из schema, а приложение читает PostgreSQL URL из `datasource db { url = env("DATABASE_URL") }`.

Runtime path теперь всегда идет через compiled metadata: приложение открывает adapter через `GeneratedComonOrmClient.runtimeSchema` и `openFromGeneratedSchema(...)`, без повторной загрузки `schema.prisma` на обычном старте.

Перед запуском нужно заранее подготовить схему базы через `migrate dev` для локальной разработки или через `migrate deploy` для уже подготовленных migration artifacts.

Общий guide по миграциям и различию между local bootstrap и production migration flow теперь вынесен в документацию сайта: `site/content/docs/migrations`.

## Миграции

```bash
dart run comon_orm check
dart run comon_orm generate

dart run comon_orm migrate dev --name 20260314_init

dart run comon_orm migrate status

dart run comon_orm migrate deploy
```

Для прототипов без migration history можно использовать и `dart run comon_orm db push`, но для shared PostgreSQL flow предпочтительнее `migrate dev` плюс `migrate deploy`.

`status` сверяет локальные миграции с `_comon_orm_migrations` в базе и показывает checksum drift, отсутствующие локально миграции и другие расхождения.

`migrate dev` и `migrate deploy` блокируются по умолчанию, если план содержит предупреждения о возможной потере данных. Это касается, например, удаления колонок, enum values, смены типов или rebuild-сценариев. Если вы осознанно принимаете риск, запускайте команду с `--allow-warnings` после ревью.

Если нужно именно сравнить два состояния схемы без создания новой миграции, используйте `migrate diff --from-* --to-* --script` как диагностический инструмент.

В базе теперь хранится не только история применения, но и metadata для восстановления: provider, checksum, warnings, rebuild flag и snapshots схемы до и после миграции. Поэтому rollback может восстановиться даже без локального `before.prisma`, если миграция уже была записана новым форматом.

## Advanced generated-client flow

Этот demo intentionally оставляет HTTP routes простыми, но checked-in generated client здесь уже включает тот же advanced surface, что и основной ORM flow:

- nested `connect`, `disconnect`, `set` и `connectOrCreate` для relation writes
- `updateMany(...)` для массовых enum/scalar апдейтов
- generated-layer `findFirst(cursor: ...)` и forward/backward `findMany(cursor: ...)`

Минимальный пример прямо на schema этого demo:

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
```

## Маршруты

- `GET /`
- `GET /users`
- `POST /users`
- `GET /users/:id`
- `PATCH /users/:id`
- `DELETE /users/:id`
- `GET /todos`
- `POST /todos`
- `GET /todos/:id`
- `PATCH /todos/:id`
- `DELETE /todos/:id`

## Примеры запросов

```bash
curl -X POST http://127.0.0.1:8080/users 
  -H "content-type: application/json" 
  -d "{\"name\":\"Alice\",\"role\":\"manager\",\"todos\":[{\"title\":\"Buy milk\",\"status\":\"pending\"},{\"title\":\"Write docs\",\"status\":\"inProgress\"}]}"

curl http://127.0.0.1:8080/users

curl http://127.0.0.1:8080/users?role=manager

curl -X POST http://127.0.0.1:8080/todos ^
  -H "content-type: application/json" ^
  -d "{\"title\":\"Ship example\",\"status\":\"done\",\"userId\":1}"

curl http://127.0.0.1:8080/todos?userId=1&status=done

curl -X PATCH http://127.0.0.1:8080/todos/1 ^
  -H "content-type: application/json" ^
  -d "{\"status\":\"done\"}"

curl -X PATCH http://127.0.0.1:8080/users/1 ^
  -H "content-type: application/json" ^
  -d "{\"role\":\"admin\"}"

curl -X DELETE http://127.0.0.1:8080/users/1
```
