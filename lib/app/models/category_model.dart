class CategoryModel {
  final String id;
  final String name;
  final int color;
  final int icon;
  final int taskCount;
  final DateTime createdAt;

  CategoryModel(
      {required this.id,
      required this.name,
      required this.color,
      required this.icon,
      required this.taskCount,
      required this.createdAt});
}
