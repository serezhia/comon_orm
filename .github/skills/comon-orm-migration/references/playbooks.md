# Migration Playbooks

Use this file after you know the project type.

## Playbook: Disposable Local Cache

Recommended default:

- reset the database

Reason:

- cheaper and safer than maintaining complex migration code for data that can be recreated

## Playbook: Offline-First Local SQLite

Recommended default:

- use versioned Dart-coded migrations

Reason:

- local data matters and may not be reproducible from the server

Suggested flow:

1. review the schema change through the normal CLI migration workflow
2. classify it as additive or rebuild
3. implement the local migration in Dart code through `SqliteFlutterMigration.sql(...)`, `SqliteFlutterMigration.rebuildTable(...)`, or `SqliteFlutterMigration(...)`
4. run the local upgrade before runtime open
5. verify data preservation

## Playbook: Shared PostgreSQL Or Shared SQLite

Recommended default:

- use CLI-reviewed migrations only

Reason:

- rollout, review, status, and history matter more than app-side convenience

## Playbook: Flutter Web Over Backend API

Recommended default:

- backend owns migrations

Reason:

- the frontend is not the database migration host

## Playbook: Browser-Local Storage

Recommended default:

- use the same local-upgrade mental model as offline-first Flutter apps

Reason:

- browser-local storage still needs explicit versioned upgrades when data matters

## Final Sanity Check

Before finishing a migration recommendation, confirm all of these:

- who owns the database
- whether data is disposable
- whether reset is acceptable
- whether the change is additive or rebuild-heavy
- whether runtime open was kept separate from upgrade execution
