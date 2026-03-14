import 'dart:io';

import 'workspace_runner.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runRootDartCommand(
    root: Directory.current,
    command: <String>[
      'format',
      ...arguments,
      'tool',
      'packages',
      'examples/postgres',
    ],
    action: 'Formatting workspace Dart files',
  );
}
