// Golden file test for ClientGenerator output.
//
// Generates a client from a small canonical schema and compares the result
// byte-for-byte against a stored golden file. When the codegen intentionally
// changes, update the golden by running:
//
//   cd packages/comon_orm
//   UPDATE_GOLDENS=1 dart test test/codegen/golden_output_test.dart
import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:test/test.dart';

/// Canonical schema used for golden output comparison.
/// Keep this schema small and stable — its generated output is the golden.
const _goldenSchema = '''
model User {
  id    Int    @id @default(autoincrement())
  name  String
  email String @unique
  posts Post[]
}

model Post {
  id      Int    @id @default(autoincrement())
  title   String
  userId  Int
  user    User   @relation(fields: [userId], references: [id])
}
''';

void main() {
  group('ClientGenerator golden output', () {
    test('generated client matches golden file', () {
      final schema = const SchemaParser().parse(_goldenSchema);
      final output = const ClientGenerator().generateClient(schema);

      // The golden file lives at test/codegen/golden/simple_schema.g.dart
      // relative to the package root (CWD when running `dart test`).
      final goldenFile = File(
        '${Directory.current.path}/test/codegen/golden/simple_schema.g.dart',
      );

      if (Platform.environment['UPDATE_GOLDENS'] == '1') {
        goldenFile.createSync(recursive: true);
        goldenFile.writeAsStringSync(output);
        // ignore: avoid_print
        print('Golden file written: ${goldenFile.path}');
        return;
      }

      if (!goldenFile.existsSync()) {
        fail(
          'Golden file not found at ${goldenFile.path}.\n'
          'Create it by running:\n'
          '  cd packages/comon_orm && '
          'UPDATE_GOLDENS=1 dart test test/codegen/golden_output_test.dart',
        );
      }

      final golden = goldenFile.readAsStringSync();
      if (output == golden) return;

      // Find the first differing line to make failures actionable.
      final generatedLines = output.split('\n');
      final goldenLines = golden.split('\n');
      final minLen = generatedLines.length < goldenLines.length
          ? generatedLines.length
          : goldenLines.length;

      for (var i = 0; i < minLen; i++) {
        if (generatedLines[i] != goldenLines[i]) {
          fail(
            'Golden output differs at line ${i + 1}.\n'
            '  expected: ${goldenLines[i]}\n'
            '  actual:   ${generatedLines[i]}\n\n'
            'Update with: cd packages/comon_orm && '
            'UPDATE_GOLDENS=1 dart test test/codegen/golden_output_test.dart',
          );
        }
      }

      fail(
        'Golden file line count differs: '
        'golden ${goldenLines.length} lines, generated ${generatedLines.length} lines.\n'
        'Update with: cd packages/comon_orm && '
        'UPDATE_GOLDENS=1 dart test test/codegen/golden_output_test.dart',
      );
    });
  });
}
