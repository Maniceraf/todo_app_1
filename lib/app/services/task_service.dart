import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/app/entities/task.dart';

class TaskService {
  static const String _boxName = 'tasks';

  Box get _box => Hive.box(_boxName);

  // Create
  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
  }

  // Read all
  List<Task> getAllTasks() {
    return _box.values.cast<Task>().toList();
  }

  // Read by category
  List<Task> getTasksByCategory(String categoryId) {
    return _box.values
        .cast<Task>()
        .where((task) => task.categoryId == categoryId)
        .toList();
  }

  // Read one
  Task? getTask(int id) {
    return _box.get(id);
  }

  // Update
  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  // Delete
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  // Delete all by category
  Future<void> deleteTasksByCategory(String categoryId) async {
    final tasks = getTasksByCategory(categoryId);
    for (var task in tasks) {
      await _box.delete(task.id);
    }
  }

  // Stream for reactive updates
  Stream<BoxEvent> watchTasks() {
    return _box.watch();
  }
}
