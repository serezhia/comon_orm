import 'dart:io';

import 'package:comon_orm_postgresql/comon_orm_postgresql.dart';

Future<void> main(List<String> args) async {
  exitCode = await PostgresqlMigrationCli().run(args);
}
