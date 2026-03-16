import 'dart:async';

import 'package:comon_orm/comon_orm.dart';
import 'package:comon_orm_flutter_sqlite_example/generated/comon_orm_client.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExampleApp());
}

typedef ExampleTodoStoreLoader = Future<ExampleTodoStore> Function();

abstract class ExampleTodoStore {
  Future<List<Todo>> listTodos();

  Future<void> addTodo(String title);

  Future<void> toggleTodo(Todo todo);

  Future<void> clearCompleted();

  Future<void> close();
}

class SqliteExampleTodoStore implements ExampleTodoStore {
  SqliteExampleTodoStore(this.client);

  final GeneratedComonOrmClient client;

  @override
  Future<List<Todo>> listTodos() {
    return client.todo.findMany(
      orderBy: const <TodoOrderByInput>[
        TodoOrderByInput(done: SortOrder.asc),
        TodoOrderByInput(createdAt: SortOrder.desc),
      ],
    );
  }

  @override
  Future<void> addTodo(String title) async {
    await client.todo.create(
      data: TodoCreateInput(title: title, createdAt: DateTime.now().toUtc()),
    );
  }

  @override
  Future<void> toggleTodo(Todo todo) async {
    await client.todo.update(
      where: TodoWhereUniqueInput(id: todo.id),
      data: TodoUpdateInput(done: !(todo.done ?? false)),
    );
  }

  @override
  Future<void> clearCompleted() async {
    await client.todo.deleteMany(where: const TodoWhereInput(done: true));
  }

  @override
  Future<void> close() {
    return client.close();
  }
}

class ExampleTodoViewData {
  const ExampleTodoViewData({
    required this.id,
    required this.title,
    required this.done,
    required this.createdAt,
  });

  final int id;
  final String title;
  final bool done;
  final DateTime? createdAt;

  factory ExampleTodoViewData.fromTodo(Todo todo) {
    return ExampleTodoViewData(
      id: todo.id ?? 0,
      title: todo.title ?? '',
      done: todo.done ?? false,
      createdAt: todo.createdAt,
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key, this.storeLoader});

  final ExampleTodoStoreLoader? storeLoader;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final TextEditingController _controller = TextEditingController();

  ExampleTodoStore? _store;
  List<ExampleTodoViewData> _todos = const <ExampleTodoViewData>[];
  String? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    final store = _store;
    if (store != null) {
      unawaited(store.close());
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final store = await (widget.storeLoader ?? _openStore)();
      _store = store;
      await _reloadTodos();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<ExampleTodoStore> _openStore() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath = p.join(
      databaseDirectory,
      'comon_orm_flutter_example.db',
    );

    final client = await _openClient(databasePath: databasePath);
    return SqliteExampleTodoStore(client);
  }

  Future<GeneratedComonOrmClient> _openClient({
    required String databasePath,
  }) async {
    if (!await databaseExists(databasePath)) {
      throw StateError(
        'Missing SQLite database at $databasePath. '
        'This example now expects a pre-provisioned local database created '
        'through tooling before runtime startup.',
      );
    }

    return GeneratedComonOrmClientFlutterSqlite.open(
      databasePath: databasePath,
    );
  }

  Future<void> _reloadTodos() async {
    final store = _store;
    if (store == null) {
      return;
    }

    final todos = await store.listTodos();

    if (!mounted) {
      return;
    }

    setState(() {
      _todos = todos.map(ExampleTodoViewData.fromTodo).toList(growable: false);
      _loading = false;
      _error = null;
    });
  }

  Future<void> _addTodo() async {
    final title = _controller.text.trim();
    final store = _store;
    if (title.isEmpty || store == null || _saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await store.addTodo(title);
      _controller.clear();
      await _reloadTodos();
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _toggleTodo(ExampleTodoViewData todo) async {
    final store = _store;
    if (store == null) {
      return;
    }

    await store.toggleTodo(
      Todo(
        id: todo.id,
        title: todo.title,
        done: todo.done,
        createdAt: todo.createdAt,
      ),
    );
    await _reloadTodos();
  }

  Future<void> _clearCompleted() async {
    final store = _store;
    if (store == null) {
      return;
    }

    await store.clearCompleted();
    await _reloadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final total = _todos.length;
    final done = _todos.where((todo) => todo.done).length;
    final open = total - done;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'comon_orm Flutter SQLite Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0C7C59)),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[Color(0xFFF7F3E9), Color(0xFFD8E2DC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.78),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'comon_orm + Flutter SQLite',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Schema-first local task list backed by SQLite.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: <Widget>[
                                _StatChip(label: 'Total', value: '$total'),
                                _StatChip(label: 'Open', value: '$open'),
                                _StatChip(label: 'Done', value: '$done'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      decoration: const InputDecoration(
                                        labelText: 'New task',
                                        hintText: 'Add something useful',
                                      ),
                                      onSubmitted: (_) => _addTodo(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  FilledButton(
                                    onPressed: _saving ? null : _addTodo,
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  TextButton(
                                    onPressed: done == 0
                                        ? null
                                        : _clearCompleted,
                                    child: const Text('Clear completed'),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: _reloadTodos,
                                    tooltip: 'Refresh',
                                    icon: const Icon(Icons.refresh),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(child: _buildBody()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!, textAlign: TextAlign.center));
    }

    if (_todos.isEmpty) {
      return const Center(
        child: Text('No tasks yet. Add one to initialize the local flow.'),
      );
    }

    return ListView.separated(
      itemCount: _todos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final todo = _todos[index];
        final done = todo.done;
        return Material(
          color: done ? const Color(0xFFDDEFE7) : const Color(0xFFFFFBF2),
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            leading: Checkbox(value: done, onChanged: (_) => _toggleTodo(todo)),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text('id=${todo.id}'),
            trailing: done
                ? const Icon(Icons.task_alt, color: Color(0xFF0C7C59))
                : const Icon(Icons.pending_actions),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF173F35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
