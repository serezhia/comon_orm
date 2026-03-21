import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current.absolute;
  final failures = <String>[];

  final rootTargets = _collectDartFiles(root, const <String>['tool']);
  if (rootTargets.isNotEmpty) {
    final code = await _runFormat(
      root,
      rootTargets,
      arguments,
      'Formatting root tooling',
    );
    if (code != 0) {
      failures.add('root tooling (exit code $code)');
    }
  }

  for (final member in workspaceMembers) {
    final packageDir = Directory(joinPath(root.path, member)).absolute;
    final targets = _collectDartFiles(packageDir, const <String>[
      'bin',
      'lib',
      'test',
      'tool',
      'example',
      'web',
    ]);
    if (targets.isEmpty) {
      stdout.writeln('Skipping $member (no format targets).');
      continue;
    }

    final code = await _runFormat(
      packageDir,
      targets,
      arguments,
      'Formatting $member',
    );
    if (code != 0) {
      failures.add('$member (exit code $code)');
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Failures:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Workspace formatting passed.');
}

Future<int> _runFormat(
  Directory workingDirectory,
  List<String> targets,
  List<String> arguments,
  String action,
) async {
  stdout.writeln('==> $action');
  final command = <String>['format', ...arguments, ...targets];
  final result = await Process.start(
    packageCommandExecutable(workingDirectory, command),
    command,
    workingDirectory: workingDirectory.path,
    mode: ProcessStartMode.inheritStdio,
  );
  return result.exitCode;
}

List<String> _collectDartFiles(Directory root, List<String> directories) {
  final files = <String>[];

  for (final relativeDir in directories) {
    final directory = Directory(joinPath(root.path, relativeDir));
    if (!directory.existsSync()) {
      continue;
    }

    for (final entity in directory.listSync(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }
      if (_shouldSkip(entity.path)) {
        continue;
      }
      files.add(entity.path);
    }
  }

  files.sort();
  return files;
}

bool _shouldSkip(String path) {
  final normalized = path.replaceAll('\\', '/');
  return normalized.contains('/generated/') ||
      normalized.contains('/test/codegen/golden/');
}
