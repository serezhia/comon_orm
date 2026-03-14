import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  final root = Directory.current;
  final steps = <({String action, List<String> command})>[
    (
      action: 'Resolving workspace dependencies',
      command: <String>['pub', 'get'],
    ),
    (
      action: 'Formatting all Dart files',
      command: <String>['run', 'tool/format_all.dart'],
    ),
    (
      action: 'Analyzing all workspace packages',
      command: <String>['run', 'tool/analyze_all.dart'],
    ),
    (
      action: 'Running all workspace tests',
      command: <String>['run', 'tool/test_all.dart'],
    ),
    (
      action: 'Running publish dry-runs',
      command: <String>['run', 'tool/dry_run_all.dart', ...arguments],
    ),
  ];

  for (final step in steps) {
    final code = await runRootDartCommand(
      root: root,
      command: step.command,
      action: step.action,
    );
    if (code != 0) {
      exitCode = code;
      return;
    }
  }

  stdout.writeln('Pre-publish checks passed.');
}
