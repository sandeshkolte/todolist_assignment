import 'package:flutter/material.dart';
import 'package:tutorial_2026/services/supabase_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService service = TaskService();

  List tasks = [];
  bool loading = false;

  Future fetchTasks() async {
    loading = true;
    notifyListeners();

    tasks = await service.getTasks();

    loading = false;
    notifyListeners();
  }

  Future addTask(String title) async {
    await service.addTask(title);

    await fetchTasks();
  }

  Future deleteTask(int id) async {
    await service.deleteTask(id);

    await fetchTasks();
  }

  Future toggleTask(int id, bool completed) async {
    await service.toggleTask(id, completed);

    await fetchTasks();
  }

  Future updateTask(int id, String newTitle) async {
    await service.updateTask(id, newTitle);

    await fetchTasks();
  }
}
