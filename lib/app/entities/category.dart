import 'package:hive/hive.dart';

part 'category.g.dart'; // Thêm dòng này

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int color;

  @HiveField(3)
  int icon;

  @HiveField(4)
  DateTime createdAt;

  int taskCount;
  int completedTaskCount;

  Category(
      {required this.id,
      required this.name,
      required this.color,
      required this.icon,
      required this.createdAt,
      this.taskCount = 0,
      this.completedTaskCount = 0});

  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, icon: $icon, createdAt: $createdAt)';
  }
}
