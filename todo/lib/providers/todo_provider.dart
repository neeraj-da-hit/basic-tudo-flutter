import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo/models/todo.dart';
import 'package:uuid/uuid.dart';

class TodoProvider extends ChangeNotifier {
  final Box<Todo> _box;
  List<Todo> _items = [];

  TodoProvider(this._box) {
    _load();
  }

  List<Todo> get items => List.unmodifiable(_items);

  void _load() {
    _items = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> add(String title, {String? note}) async {
    final id = const Uuid().v4();
    final t = Todo(id: id, title: title, note: note);
    await _box.put(id, t);
    _load();
  }

  Future<void> update(Todo todo, {required String title, String? note}) async {
    todo.title = title;
    todo.note = note;
    await todo.save();
    _load();
  }

  Future<void> toggleDone(Todo todo, bool done) async {
    todo.done = done;
    await todo.save();
    _load();
  }

  Future<void> delete(Todo todo) async {
    await todo.delete();
    _load();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _load();
  }
}
