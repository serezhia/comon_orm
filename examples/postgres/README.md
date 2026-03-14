# PostgreSQL Dart Frog Example

Пример `dart_frog`-приложения на PostgreSQL, использующий `comon_orm` и `comon_orm_postgresql`.

## Что внутри

- `User` с полями `id`, `name`, `role`
- `Todo` с полями `id`, `title`, `status`, `createdAt`, `userId`
- native PostgreSQL enums: `UserRole` (`admin`, `developer`, `manager`) и `TodoStatus` (`pending`, `inProgress`, `done`)
- CRUD для `/users` и `/todos`
- Автоприменение схемы при старте приложения

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
dart run ../../packages/comon_orm/bin/comon_orm.dart generate schema.prisma
dart pub global activate dart_frog_cli
dart_frog dev
```

`generate` теперь использует `generator client { output = "lib/generated" }` из schema, а приложение читает PostgreSQL URL из `datasource db { url = env("DATABASE_URL") }`.

По умолчанию схема применяется автоматически через `openAndApplyFromSchemaPath(...)`. Это удобно для локального старта примера, но не является production-практикой. Если это не нужно, установите `AUTO_APPLY_SCHEMA=false`.

Общий guide по миграциям и различию между local bootstrap и production migration flow лежит в `MIGRATIONS.md` в корне репозитория.

## Миграции

```bash
dart run comon_orm migrate diff \
  --schema schema.prisma \
  --name 20260314_init \
  --out prisma/migrations

dart run comon_orm migrate apply \
  --schema schema.prisma \
  --name 20260314_init

dart run comon_orm migrate status \
  --schema schema.prisma \
  --from prisma/migrations

dart run comon_orm migrate rollback \
  --schema schema.prisma \
  --from prisma/migrations \
  --allow-warnings
```

`status` сверяет локальные миграции с `_comon_orm_migrations` в базе и показывает checksum drift, отсутствующие локально миграции и другие расхождения.

`apply` и `rollback` блокируются по умолчанию, если план содержит предупреждения о возможной потере данных. Это касается, например, удаления колонок, enum values, смены типов или rebuild-сценариев. Если вы осознанно принимаете риск, запускайте команду с `--allow-warnings`.

Важно: `diff` здесь создаёт migration artifact для ревью и истории, а `apply` затем строит план заново из live DB и текущей `schema.prisma`. Не относитесь к этому как к строгому replay уже сгенерированного `migration.sql`.

В базе теперь хранится не только история применения, но и metadata для восстановления: provider, checksum, warnings, rebuild flag и snapshots схемы до и после миграции. Поэтому rollback может восстановиться даже без локального `before.prisma`, если миграция уже была записана новым форматом.

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
