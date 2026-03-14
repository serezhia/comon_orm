import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runDartCommandAcrossMembers(
    root: Directory.current,
    members: workspaceMembers,
    command: <String>['test', ...arguments],
    action: 'Running tests',
    shouldSkip: (packageDir) =>
        !Directory(joinPath(packageDir.path, 'test')).existsSync(),
    skipMessage: (member) => 'Skipping $member (no test directory).',
    successMessage: 'All workspace package tests passed.',
    emptyMessage: 'No workspace packages with tests were found.',
  );
}
