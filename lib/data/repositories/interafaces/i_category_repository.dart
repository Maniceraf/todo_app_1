import 'package:task_manager/data/entities/category.dart';

abstract class ICategoryRepository {
  List<Category> getAllCategories();
  Category? getCategory(String id);
  Future<Category> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Stream<void> watchCategories();
}
