import 'dart:io';

const workspaceMembers = <String>[
  'packages/comon_orm',
  'packages/comon_orm_postgresql',
  'packages/comon_orm_sqlite',
  'examples/postgres',
];

const publishableMembers = <String>[
  'packages/comon_orm',
  'packages/comon_orm_postgresql',
  'packages/comon_orm_sqlite',
];

Future<int> runDartCommandAcrossMembers({
  required Directory root,
  required List<String> members,
  required List<String> command,
  required String action,
  bool Function(Directory packageDir)? shouldSkip,
  String Function(String member)? skipMessage,
  String successMessage = 'All commands passed.',
  String emptyMessage = 'Nothing to run.',
}) async {
  final failures = <String>[];
  var ranAny = false;

  for (final member in members) {
    final packageDir = Directory(joinPath(root.path, member));
    if (shouldSkip != null && shouldSkip(packageDir)) {
      stdout.writeln(skipMessage?.call(member) ?? 'Skipping $member.');
      continue;
    }

    ranAny = true;
    stdout.writeln('==> $action in $member');

    final result = await Process.start(
      Platform.resolvedExecutable,
      command,
      workingDirectory: packageDir.path,
      mode: ProcessStartMode.inheritStdio,
    );

    final code = await result.exitCode;
    if (code != 0) {
      failures.add('$member (exit code $code)');
    }
  }

  if (!ranAny) {
    stderr.writeln(emptyMessage);
    return 1;
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Failures:');
    for (final failure in failures) {
      stderr.writeln('- $failure');
    }
    return 1;
  }

  stdout.writeln(successMessage);
  return 0;
}

Future<int> runRootDartCommand({
  required Directory root,
  required List<String> command,
  required String action,
}) async {
  stdout.writeln('==> $action');
  final result = await Process.start(
    Platform.resolvedExecutable,
    command,
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );
  return result.exitCode;
}

String joinPath(String left, String right) {
  if (left.endsWith(Platform.pathSeparator)) {
    return '$left$right';
  }
  return '$left${Platform.pathSeparator}$right';
}
