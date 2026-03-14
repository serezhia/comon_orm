import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runDartCommandAcrossMembers(
    root: Directory.current,
    members: workspaceMembers,
    command: <String>['analyze', ...arguments],
    action: 'Analyzing',
    successMessage: 'All workspace package analysis passed.',
  );
}
