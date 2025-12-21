import 'package:task_manager/data/entities/task.dart';

abstract class ITaskRepository {
  List<Task> getAllTasks();
  List<Task> getTasksByCategory(String categoryId);
  Task? getTask(String id);
  Future<Task> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<void> deleteTasksByCategory(String categoryId);
  Stream<void> watchTasks();
}
