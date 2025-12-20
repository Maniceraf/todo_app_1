import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final int priority;
  @HiveField(5)
  final int status;
  @HiveField(6)
  final String categoryId;
  @HiveField(7)
  final DateTime createdAt;
  @HiveField(8)
  final DateTime? updatedAt;

  Task(
      {required this.id,
      required this.title,
      required this.description,
      required this.date,
      required this.priority,
      required this.status,
      required this.categoryId,
      required this.createdAt,
      this.updatedAt});

  @override
  String toString() {
    return 'Task(id: $id, title: $title, description: $description, date: $date, priority: $priority, status: $status, categoryId: $categoryId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  copyWith({required int status}) {}
}
