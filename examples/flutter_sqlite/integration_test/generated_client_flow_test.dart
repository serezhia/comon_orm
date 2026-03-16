import 'dart:io';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_flutter_sqlite_example/generated/comon_orm_client.dart';
import 'package:comon_orm_sqlite_flutter/comon_orm_sqlite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'runs generated client CRUD flow against a real sqlite database',
    (tester) async {
      sqfliteFfiInit();

      final schema = await rootBundle.loadString('schema.prisma');
      final tempRoot = await Directory.systemTemp.createTemp(
        'comon_orm_flutter_sqlite_example_',
      );
      final databasePath = p.join(tempRoot.path, 'integration.db');

      final adapter =
          await SqliteFlutterDatabaseAdapter.openAndApplyFromSchemaSource(
            source: schema,
            filePath: 'schema.prisma',
            databasePath: databasePath,
            databaseFactory: databaseFactoryFfi,
          );
      final client = GeneratedComonOrmClient(adapter: adapter);

      try {
        final createdOpen = await client.todo.create(
          data: TodoCreateInput(
            title: 'Ship integration test',
            done: false,
            createdAt: DateTime.utc(2026, 3, 15, 10, 0, 0),
          ),
        );
        final createdDone = await client.todo.create(
          data: TodoCreateInput(
            title: 'Already done',
            done: true,
            createdAt: DateTime.utc(2026, 3, 15, 9, 0, 0),
          ),
        );

        expect(createdOpen.id, isNotNull);
        expect(createdDone.id, isNotNull);

        final allTodos = await client.todo.findMany(
          orderBy: const <TodoOrderByInput>[
            TodoOrderByInput(done: SortOrder.asc),
            TodoOrderByInput(createdAt: SortOrder.desc),
          ],
        );

        expect(allTodos, hasLength(2));
        expect(allTodos.first.title, 'Ship integration test');
        expect(allTodos.last.title, 'Already done');

        final fetched = await client.todo.findUnique(
          where: TodoWhereUniqueInput(id: createdOpen.id),
        );
        expect(fetched, isNotNull);
        expect(fetched!.done, isFalse);

        final updated = await client.todo.update(
          where: TodoWhereUniqueInput(id: createdOpen.id),
          data: const TodoUpdateInput(done: true),
        );
        expect(updated.done, isTrue);

        expect(
          await client.todo.count(where: const TodoWhereInput(done: true)),
          2,
        );

        final deleted = await client.todo.deleteMany(
          where: const TodoWhereInput(done: true),
        );
        expect(deleted, 2);

        final remaining = await client.todo.findMany();
        expect(remaining, isEmpty);
      } finally {
        await adapter.close();
        if (tempRoot.existsSync()) {
          tempRoot.deleteSync(recursive: true);
        }
      }
    },
  );
}
