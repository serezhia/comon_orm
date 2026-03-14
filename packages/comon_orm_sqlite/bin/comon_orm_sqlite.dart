import 'dart:io';

import 'package:comon_orm_sqlite/comon_orm_sqlite.dart';

void main(List<String> args) {
  final exitCodeValue = SqliteMigrationCli().run(args);
  exitCode = exitCodeValue;
}
