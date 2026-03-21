# comon_orm Migration Project Matrix

Use this file first when the task is mainly about choosing the correct migration strategy for a project type.

## Project Types

### 1. Backend Or Shared Database

Examples:

- PostgreSQL service database
- shared SQLite database on Dart VM
- staging database
- production database

Owner:

- CLI and VM migration tooling

Correct path:

- `check`
- `generate`
- `migrate dev`
- review artifacts
- `migrate status`
- `migrate deploy`

Do not use:

- Flutter app-side upgrade code as the main migration system

### 2. Flutter App With Disposable Local Cache

Examples:

- synchronized cache
- derived local data
- query cache
- locally reproducible state

Owner:

- explicit setup/bootstrap or reset flow

Correct path:

- prefer reset and rebuild over complex migration code
- use additive local upgrade code only when it removes real startup friction

Default recommendation:

- reset is usually better than migration

### 3. Flutter Offline-First App With Important Local Data

Examples:

- local source of truth
- unsynced user drafts
- user-generated content that cannot be recreated safely

Owner:

- app-side versioned Dart-coded migration layer

Correct path:

- still plan the schema change through normal CLI review flow
- implement the local upgrade in Dart code
- run the upgrade before normal generated runtime open

### 4. Flutter Web Over Remote API Only

Owner:

- backend migration tooling

Correct path:

- the web app does not migrate the backend database

### 5. Flutter Web With Browser-Local Storage

Owner:

- app-side versioned upgrade layer

Correct path:

- same mental model as local Flutter SQLite, but with web storage/runtime constraints

## Decision Shortcuts

- If data is shared and important, use CLI-reviewed migrations.
- If data is local and disposable, prefer reset.
- If data is local and important, use versioned Dart-coded upgrades.
- If the app only talks to a backend API, the app is not the migration host.
