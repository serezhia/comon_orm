# Releasing

This repository publishes four packages in a fixed order:

1. `comon_orm`
2. `comon_orm_postgresql`
3. `comon_orm_sqlite`
4. `comon_orm_sqlite_flutter`

The package family currently ships as `0.0.1-alpha.2`. Local monorepo development runs inside the root Dart workspace declared in `pubspec.yaml`, and repository validation is orchestrated through Melos.

## Pre-release checklist

1. Update versions in all package `pubspec.yaml` files.
2. Add release notes to each package `CHANGELOG.md`.
3. Verify package README content still matches the shipped API.
4. Run repository validation from the workspace root:

```bash
dart pub get
dart run melos bootstrap
dart run melos run format -- --set-exit-if-changed
dart run melos run analyze
dart run melos run test
dart run melos run publish:dry-run
```

If you want to run the phases separately, use:

- `dart run melos run format`
- `dart run melos run analyze`
- `dart run melos run test`
- `dart run melos run publish:dry-run`

## Release sequence

### 1. Publish core package

From `packages/comon_orm`:

```bash
dart pub publish --dry-run
dart pub publish
```

### 2. Publish PostgreSQL package

From `packages/comon_orm_postgresql`:

```bash
dart pub publish --dry-run
dart pub publish
```

### 3. Publish SQLite package

From `packages/comon_orm_sqlite`:

```bash
dart pub publish --dry-run
dart pub publish
```

### 4. Publish Flutter SQLite package

From `packages/comon_orm_sqlite_flutter`:

```bash
flutter pub publish --dry-run
flutter pub publish
```

## Constraint alignment

If the published `comon_orm` version changed since the last coordinated release, update the version constraint in:

- `packages/comon_orm_postgresql/pubspec.yaml`
- `packages/comon_orm_sqlite/pubspec.yaml`
- `packages/comon_orm_sqlite_flutter/pubspec.yaml`

If you need to validate a package outside the shared workspace resolution, create a temporary `pubspec_overrides.yaml` next to that package with:

```yaml
resolution:
```

That tells `dart pub get` in that package directory to resolve independently.

## Notes

- The root workspace does not change the published dependency graph. Outside the workspace, hosted constraints are used normally.
- A temporary `pubspec_overrides.yaml` with `resolution:` is the documented way to resolve a single package outside the workspace when needed.
- Prefer coordinated releases for the first public alpha line so the package family stays on aligned versions.
