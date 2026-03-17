import 'dart:io';

import 'package:comon_orm/src/cli/schema_cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await ComonOrmCli().run(arguments);
}
