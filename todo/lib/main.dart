import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/todo.dart';
import 'providers/todo_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdapter());
  final box = await Hive.openBox<Todo>('todos');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider(box)),
      ],
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog({Todo? todo}) {
    final titleCtrl = TextEditingController(text: todo?.title ?? '');
    final noteCtrl = TextEditingController(text: todo?.note ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(todo == null ? 'Add Todo' : 'Edit Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final provider = Provider.of<TodoProvider>(context, listen: false);
              // Close dialog immediately, then perform async work. This avoids
              // using BuildContext across the async gap.
              Navigator.of(context).pop();
              if (todo == null) {
                await provider.add(title, note: noteCtrl.text);
              } else {
                await provider.update(todo, title: title, note: noteCtrl.text);
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);

    List<Todo> filtered() {
      final q = _searchController.text.trim().toLowerCase();
      if (q.isEmpty) return provider.items;
      return provider.items.where((t) => t.title.toLowerCase().contains(q) || (t.note ?? '').toLowerCase().contains(q)).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Clear all todos?'),
                      content: const Text('This will delete all todos permanently.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')),
                        ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes')),
                      ],
                    ),
                  ) ??
                  false;
              if (confirmed) {
                await provider.clearAll();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search todos',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.extended(
                  onPressed: () => _showAddEditDialog(),
                  label: const Text('Add'),
                  icon: const Icon(Icons.add),
                )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: provider.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.inbox, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No todos yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered().length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final t = filtered()[index];
                        return ListTile(
                          leading: Checkbox(
                            value: t.done,
                            onChanged: (v) => provider.toggleDone(t, v ?? false),
                          ),
                          title: Text(
                            t.title,
                            style: TextStyle(decoration: t.done ? TextDecoration.lineThrough : null),
                          ),
                          subtitle: t.note == null || t.note!.isEmpty ? null : Text(t.note!),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditDialog(todo: t)),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: const Text('Delete todo?'),
                                          content: const Text('This cannot be undone.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('No')),
                                            ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Yes')),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                  if (ok) await provider.delete(t);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

