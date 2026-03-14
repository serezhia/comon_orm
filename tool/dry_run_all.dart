import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runDartCommandAcrossMembers(
    root: Directory.current,
    members: publishableMembers,
    command: <String>['pub', 'publish', '--dry-run', ...arguments],
    action: 'Running publish dry-run',
    successMessage: 'All publishable package dry-runs passed.',
  );
}
