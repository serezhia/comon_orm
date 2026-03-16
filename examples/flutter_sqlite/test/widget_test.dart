import 'package:flutter/material.dart';
import 'package:comon_orm_flutter_sqlite_example/main.dart';
import 'package:comon_orm_flutter_sqlite_example/generated/comon_orm_client.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTodoStore implements ExampleTodoStore {
  final List<Todo> _todos = <Todo>[];
  int _nextId = 1;

  @override
  Future<void> addTodo(String title) async {
    _todos.add(
      Todo(
        id: _nextId++,
        title: title,
        done: false,
        createdAt: DateTime.utc(2026, 3, 15),
      ),
    );
  }

  @override
  Future<void> clearCompleted() async {
    _todos.removeWhere((todo) => todo.done == true);
  }

  @override
  Future<void> close() async {}

  @override
  Future<List<Todo>> listTodos() async {
    final copy = _todos
        .map(
          (todo) => Todo(
            id: todo.id,
            title: todo.title,
            done: todo.done,
            createdAt: todo.createdAt,
          ),
        )
        .toList(growable: false);
    copy.sort((left, right) {
      final leftDone = left.done ?? false;
      final rightDone = right.done ?? false;
      final doneCompare = leftDone == rightDone ? 0 : (leftDone ? 1 : -1);
      if (doneCompare != 0) {
        return doneCompare;
      }
      return (right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
          .compareTo(left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0));
    });
    return copy;
  }

  @override
  Future<void> toggleTodo(Todo todo) async {
    final index = _todos.indexWhere((row) => row.id == todo.id);
    if (index == -1) {
      return;
    }
    final current = _todos[index];
    _todos[index] = Todo(
      id: current.id,
      title: current.title,
      done: !(current.done ?? false),
      createdAt: current.createdAt,
    );
  }
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 20,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  final visibleTexts = find
      .byType(Text)
      .evaluate()
      .map((element) => element.widget)
      .whereType<Text>()
      .map(
        (widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '<rich>',
      )
      .toList(growable: false);

  fail(
    'Timed out waiting for finder: $finder\n'
    'Visible texts: ${visibleTexts.join(' | ')}',
  );
}

void main() {
  testWidgets('adds and toggles a todo item', (tester) async {
    final store = _FakeTodoStore();

    await tester.pumpWidget(ExampleApp(storeLoader: () async => store));

    final emptyState = find.text(
      'No tasks yet. Add one to initialize the local flow.',
    );
    await _pumpUntilFound(tester, emptyState);

    expect(emptyState, findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Ship Flutter example');
    await tester.tap(find.text('Add'));

    final createdTodo = find.text('Ship Flutter example');
    await _pumpUntilFound(tester, createdTodo);

    expect(createdTodo, findsOneWidget);

    await tester.tap(find.byType(Checkbox));

    final completedIcon = find.byIcon(Icons.task_alt);
    await _pumpUntilFound(tester, completedIcon);

    expect(completedIcon, findsOneWidget);
  });

  testWidgets('clears completed todos and keeps open ones', (tester) async {
    final store = _FakeTodoStore();

    await tester.pumpWidget(ExampleApp(storeLoader: () async => store));

    final emptyState = find.text(
      'No tasks yet. Add one to initialize the local flow.',
    );
    await _pumpUntilFound(tester, emptyState);

    await tester.enterText(find.byType(TextField), 'Done item');
    await tester.tap(find.text('Add'));
    await _pumpUntilFound(tester, find.text('Done item'));

    await tester.enterText(find.byType(TextField), 'Keep item');
    await tester.tap(find.text('Add'));
    await _pumpUntilFound(tester, find.text('Keep item'));

    await tester.tap(find.byType(Checkbox).first);
    await _pumpUntilFound(tester, find.byIcon(Icons.task_alt));

    await tester.tap(find.text('Clear completed'));
    await tester.pump();

    expect(find.text('Done item'), findsNothing);
    expect(find.text('Keep item'), findsOneWidget);
  });
}
