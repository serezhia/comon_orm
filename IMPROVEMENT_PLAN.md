# comon_orm — План улучшений (v2)

Обновлённый план на основе полного аудита кодовой базы от 2026-03-18.
Предыдущие итерации 1, 8, 9, 10 и бэклог — закрыты. Оставшееся переформулировано по реальному состоянию кода.

---

## Что закрыто

- [x] **Итерация 1** — E2E тесты, golden-file codegen, негативные кейсы парсера и валидатора
- [x] **Итерация 8** — `@ignore`/`@@ignore`, cursor pagination, расширенный `@db.*`
- [x] **Итерация 9** — Web-safe migration artifacts, Flutter/sqflite schema diff
- [x] **Итерация 10** — Limitations section, troubleshooting, architecture diagram, relation examples
- [x] **Бэклог** — Implicit M2M с compound ids, PG enum `@@map` round-trip, validator source locations + CLI check/format

---

## Что сейчас хорошо

- **Архитектура** — 4 пакета, чистый `DatabaseAdapter` интерфейс, минимальные зависимости (`crypto`, `meta`)
- **Парсер** — полноценный recursive descent + лексер, error recovery, позиции line/column
- **SQL безопасность** — 100% параметризация, injection невозможен, `_quoteIdentifier()` для идентификаторов
- **API** — полный CRUD: findUnique/findFirst/findMany/count/create/createMany/update/updateMany/upsert/delete/deleteMany/aggregate/groupBy/transaction/rawQuery/rawExecute
- **Кодогенерация** — IR-based, модульная (8+ эмиттеров), golden-тесты
- **Миграции** — diff/apply/status/rollback, warnings, checksums, snapshots, Flutter local path
- **Тесты** — 34+ файлов, E2E, golden, интеграционные
- **Документация** — двуязычная, honest limitations, feature matrix vs Prisma

---

## Текущий фактический статус операций

| Операция | PG адаптер | SQLite адаптер | Проблема |
|----------|-----------|----------------|----------|
| `createMany` | Нативный batch INSERT | Per-row INSERT в транзакции | SQLite не batch |
| `upsert` | Transaction (find + create/update) | Transaction (find + create/update) | Оба не нативные |
| `updateMany` | Нативный `UPDATE ... WHERE` | Нативный `UPDATE ... WHERE` | Ок |
| `include` | Batch по FK (per relation level) | Batch по FK (per relation level) | Не JOIN, а отдельные запросы |
| `include` (M2M/compound FK) | Per-row fallback | Per-row fallback | N+1 |
| `distinct + cursor` | Client-side fallback | Client-side fallback | Не SQL pushdown |

---

## Фаза A — Нативный SQL для bulk/upsert

> Пользователи ожидают что `upsert` и `createMany` — это один SQL statement, а не цикл в транзакции.

- [ ] **A.1** Нативный `upsert` через `ON CONFLICT` (PG)
  - `INSERT INTO ... ON CONFLICT (unique_fields) DO UPDATE SET ...`
  - Удалить transaction-based fallback из `PostgresqlDatabaseAdapter.upsert()`
  - Тест: upsert существующей записи должен выполнять один запрос, а не три
  - Файл: `packages/comon_orm_postgresql/lib/src/postgresql_database_adapter.dart`

- [ ] **A.2** Нативный `upsert` через `INSERT OR REPLACE` / `ON CONFLICT` (SQLite)
  - SQLite 3.24+ поддерживает `ON CONFLICT` clause
  - Fallback для старых версий: оставить текущий transaction-based подход
  - Файл: `packages/comon_orm_sqlite/lib/src/sqlite_database_adapter.dart`

- [ ] **A.3** Batch `createMany` для SQLite
  - Сейчас: per-row `_insertRecord()` в цикле внутри транзакции
  - Нужно: `INSERT INTO ... VALUES (...), (...), (...)` (SQLite 3.7.11+)
  - Файл: `packages/comon_orm_sqlite/lib/src/sqlite_database_adapter.dart`

- [ ] **A.4** `createMany(skipDuplicates)` через `ON CONFLICT DO NOTHING` (PG + SQLite)
  - Сейчас: schema-derived unique selector checks + ловля ошибок провайдера
  - Нужно: нативный `INSERT ... ON CONFLICT DO NOTHING`
  - Файл: оба адаптера

---

## Фаза B — JOIN для include (убить N+1)

> 3 уровня вложенности = 4+ запроса вместо одного. Самая важная performance-проблема.

- [ ] **B.1** LEFT JOIN для one-to-one и many-to-one include (один уровень)
  - При `findMany(include: ...)` с простыми single-field FK — генерировать `LEFT JOIN`
  - Результат разбирать из плоского resultset в вложенные объекты
  - Файлы: PG и SQLite адаптеры, `query_planner.dart`
  - Тест: один запрос вместо двух при `include: { author: true }`

- [ ] **B.2** JOIN для вложенных include (n уровней)
  - PG: lateral subquery или рекурсивный JOIN
  - SQLite: `IN (...)` clause батч вместо per-row queries
  - Порог: до 3 уровней — JOIN, глубже — fallback на batch

- [ ] **B.3** JOIN для implicit many-to-many
  - Сейчас: per-row fallback
  - Нужно: `LEFT JOIN join_table ON ... LEFT JOIN target ON ...`
  - Файлы: оба адаптера

- [ ] **B.4** Стратегия в `QueryPlanner`
  - Автовыбор: JOIN (простые FK) / batch IN (compound FK) / per-row (сложные случаи)
  - Адаптер получает готовый `IncludeStrategy` и не принимает решения сам
  - Файл: `packages/comon_orm/lib/src/engine/query_planner.dart`

---

## Фаза C — Рефакторинг PG адаптера

> 2700 строк в одном файле — навигация и ревью страдают.

- [ ] **C.1** Вынести SQL builder
  - `_buildWhereClause()`, `_buildOrderByClause()`, `_parameterWithCast()`, `_binaryClause()`, `_stringPatternClause()` → отдельный `postgresql_sql_builder.dart`
  - PG адаптер вызывает builder, а не содержит SQL-логику внутри себя

- [ ] **C.2** Вынести relation materializer
  - `_materializeRecordsBatch()`, `_resolveInclude()`, `_resolveImplicitManyToMany()` → `postgresql_relation_materializer.dart`
  - Чистая функция: принимает SQL результат + schema → возвращает вложенные объекты

- [ ] **C.3** Вынести transaction manager
  - `transaction()`, `_TransactionExecutor` → `postgresql_transaction.dart`
  - Адаптер делегирует, а не содержит transaction-логику

- [ ] **C.4** Аналогичный split для SQLite адаптера (~1000 строк, менее критично)
  - По тому же шаблону: sql builder + relation materializer + transaction
  - Приоритет ниже — файл пока управляемого размера

---

## Фаза D — Кодогенератор: оптимизация вывода

> Генерируем код, который никто не использует.

- [ ] **D.1** Не генерировать aggregate helpers для моделей без числовых полей
  - `sum`, `avg` бессмысленны на модели с только `String`/`Boolean` полями
  - Проверять schema: есть `Int`/`Float`/`Decimal`/`BigInt` → генерировать, нет → пропустить
  - Файл: `packages/comon_orm/lib/src/codegen/client_generator_aggregates.dart`

- [ ] **D.2** Не генерировать groupBy для моделей с одним полем (id-only)
  - groupBy по единственному `@id` полю не несёт смысла
  - Файл: `packages/comon_orm/lib/src/codegen/client_generator_group_by.dart`

- [ ] **D.3** Инкрементальная генерация (опционально, Low priority)
  - Хеш per-model, перегенерировать только изменившиеся файлы
  - Для проектов с 50+ моделями экономит секунды
  - Можно отложить

---

## Фаза E — Валидатор: предупреждения до кодогенерации

> Сейчас часть ошибок обнаруживается только в runtime. Нужно ловить раньше.

- [ ] **E.1** Типовая совместимость FK
  - `@relation(fields: [userId], references: [id])` — `userId: String` ↔ `id: Int` = ошибка
  - Файл: `packages/comon_orm/lib/src/schema/schema_validator.dart`

- [ ] **E.2** `@map`/`@@map` конфликты
  - Два поля с одинаковым `@map("same_name")` в одной модели — ошибка
  - Две модели с одинаковым `@@map("same_table")` — ошибка

- [ ] **E.3** Referential action валидация
  - `SetNull` на non-nullable поле → ошибка
  - `SetDefault` без `@default` → предупреждение

- [ ] **E.4** Query-time field validation
  - `QueryPredicate` проверяет существование поля в runtime schema до построения SQL
  - Сейчас ошибка — только при `execute`, нужно при построении запроса

---

## Фаза F — SQLite миграции: auto-rebuild

> `requiresRebuild = true` — просто флаг. Нужна автоматика.

- [ ] **F.1** Auto-rebuild в CLI миграциях
  - Когда `requiresRebuild = true`: CREATE TABLE new → INSERT INTO new SELECT ... FROM old → DROP old → ALTER TABLE RENAME
  - Обернуть в транзакцию, `PRAGMA foreign_keys = OFF` во время rebuild
  - Файл: `packages/comon_orm_sqlite/lib/src/sqlite_migration_runner.dart`
  - Тест: миграция с rename column → данные сохраняются

- [ ] **F.2** `PRAGMA foreign_keys = ON` по умолчанию
  - Включать при открытии соединения в SQLite адаптере
  - Документировать поведение и как отключить
  - Файл: `packages/comon_orm_sqlite/lib/src/sqlite_database_adapter.dart`

---

## Фаза G — Экосистема и production-readiness

> Для adoption нужен CI, pub.dev, и расширяемость.

- [ ] **G.1** GitHub Actions CI pipeline
  - Workflow: `analyze_all.dart` + `test_all.dart` + `format_all.dart` + `dry_run_all.dart`
  - Триггер: push + PR на `main`
  - Matrix: Dart stable + Dart dev
  - Файл: `.github/workflows/ci.yml`

- [ ] **G.2** Middleware / hooks система
  - Интерфейс: `DatabaseMiddleware` с `beforeQuery()` / `afterQuery()` callbacks
  - Use cases: логирование SQL, soft delete, audit trail, timing
  - Middleware оборачивает адаптер (decorator pattern), не меняет его
  - Файл: новый `packages/comon_orm/lib/src/engine/database_middleware.dart`

- [ ] **G.3** Connection pooling для PG — документация
  - `package:postgres` поддерживает пул через `Pool` / `Endpoint`
  - Как минимум: пример в README и example
  - Как максимум: helper в PG адаптере для `Pool.withConnection()`

- [ ] **G.4** `distinct + cursor` — SQL pushdown
  - Сейчас: client-side fallback
  - PG: `SELECT DISTINCT ... WHERE (cursor_field, id) > ($1, $2) ORDER BY ... LIMIT ...`
  - SQLite: аналогичный pushdown
  - Файлы: оба адаптера

- [ ] **G.5** Публикация на pub.dev
  - `dart run tool/dry_run_all.dart` → все пакеты проходят
  - Версия: `0.0.1-alpha.2` (текущая ветка)
  - Зависит от: CI зелёный (G.1)

---

## Фаза H — Обновить README и документацию

> После всех фаз — синхронизировать документацию с реальностью.

- [ ] **H.1** Обновить feature matrix в корневом README.md и README_RU.md
  - Если upsert стал нативным — убрать пометку "through transactions"
  - Если JOIN include — добавить в key features
  - Если middleware — добавить в features list

- [ ] **H.2** Обновить "Prisma-like Compatibility Snapshot" секцию
  - Пересмотреть каждый пункт "Implemented, but still partial" — что стало полным
  - Обновить bulk/provider-behavior notes

- [ ] **H.3** Обновить TROUBLESHOOTING.md
  - Добавить: middleware troubleshooting (если G.2 сделан)
  - Добавить: connection pooling FAQ (если G.3 сделан)

- [ ] **H.4** Обновить ARCHITECTURE.md
  - Добавить middleware layer в Mermaid-диаграмму (если G.2)
  - Обновить описание PG адаптера после split (если C.1–C.3)

- [ ] **H.5** Обновить IMPROVEMENT_PLAN.md
  - Отметить `[x]` все закрытые пункты
  - Убрать завершённые фазы в архив

---

## Приоритет выполнения

```
Фаза A (нативный SQL)     ← максимальный impact на пользователя
  ↓
Фаза B (JOIN include)     ← убираем N+1, главный performance fix
  ↓
Фаза E (валидатор)        ← ловим баги раньше, дешёвая фаза
  ↓
Фаза C (PG adapter split) ← нужен до того как трогать JOIN-логику глубже
  ↓
Фаза F (SQLite rebuild)   ← автоматизация миграций
  ↓
Фаза D (codegen optimize) ← nice-to-have, не блокер
  ↓
Фаза G (CI + middleware)   ← экосистема и production
  ↓
Фаза H (README update)    ← финальная синхронизация документации
```

---

## Как работать с этим планом

1. Берём следующую незакрытую фазу
2. Внутри фазы — задачи независимы, можно параллелить
3. После каждой задачи — `dart run tool/analyze_all.dart` + `dart run tool/test_all.dart`
4. Отмечаем `[x]` по факту
5. Не перепрыгиваем: A → B → E → C → F → D → G → H
