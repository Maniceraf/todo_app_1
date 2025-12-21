import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/entities/task.dart';
import 'package:task_manager/data/repositories/interafaces/i_task_repository.dart';

class TaskRepository implements ITaskRepository {
  static const String _boxName = 'tasks';

  Box get _box => Hive.box(_boxName);

  @override
  Future<Task> createTask(Task task) async {
    await _box.put(task.id, task);
    return task;
  }

  @override
  List<Task> getAllTasks() {
    return _box.values.cast<Task>().toList();
  }

  @override
  List<Task> getTasksByCategory(String categoryId) {
    return _box.values
        .cast<Task>()
        .where((task) => task.categoryId == categoryId)
        .toList();
  }

  @override
  Task? getTask(String id) {
    return _box.get(id);
  }

  @override
  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteTasksByCategory(String categoryId) async {
    final tasks = getTasksByCategory(categoryId);
    for (var task in tasks) {
      await _box.delete(task.id);
    }
  }

  @override
  Stream<void> watchTasks() {
    return _box.watch().map((_) {});
  }
}
