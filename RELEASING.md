# Releasing

This repository publishes three Dart packages in a fixed order:

1. `comon_orm`
2. `comon_orm_postgresql`
3. `comon_orm_sqlite`

The provider packages already use hosted dependency constraints in `pubspec.yaml`. Local monorepo development runs inside the root Dart pub workspace declared in `pubspec.yaml`.

## Pre-release checklist

1. Update versions in all three package `pubspec.yaml` files.
2. Add release notes to each package `CHANGELOG.md`.
3. Verify package README content still matches the shipped API.
4. Run validation in each package directory:

```bash
dart pub get
dart run tool/pre_publish.dart
```

If you want to run the phases separately, use:

- `dart run tool/format_all.dart`
- `dart run tool/analyze_all.dart`
- `dart run tool/test_all.dart`
- `dart run tool/dry_run_all.dart`

## Release sequence

### 1. Publish core package

From `packages/comon_orm`:

```bash
dart pub publish --dry-run
dart pub publish
```

### 2. Update provider constraints if needed

If the published `comon_orm` version changed since the last coordinated release, update the version constraint in:

- `packages/comon_orm_postgresql/pubspec.yaml`
- `packages/comon_orm_sqlite/pubspec.yaml`

If you need to validate a package outside the shared workspace resolution, create a temporary `pubspec_overrides.yaml` next to that package with:

```yaml
resolution:
```

That tells `dart pub get` in that package directory to resolve independently.

### 3. Publish provider packages

From each provider package directory:

```bash
dart pub publish --dry-run
dart pub publish
```

## Notes

- The root workspace does not change the published dependency graph. Outside the workspace, hosted constraints are used normally.
- A temporary `pubspec_overrides.yaml` with `resolution:` is the documented way to resolve a single package outside the workspace when needed.
- Prefer coordinated releases for the first public line so the package family stays on aligned versions.
