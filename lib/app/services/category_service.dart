// lib/app/services/category_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/app/entities/category.dart';

class CategoryService {
  static const String _boxName = 'categories';

  Box get _box => Hive.box(_boxName);

  // Create
  Future<void> addCategory(Category category) async {
    await _box.put(category.id, category);
  }

  // Read all
  List<Category> getAllCategories() {
    final categories = _box.values.cast<Category>().toList();
    return categories;
  }

  // Read one
  Category? getCategory(String id) {
    return _box.get(id);
  }

  // Update
  Future<void> updateCategory(Category category) async {
    await _box.put(category.id, category);
  }

  // Delete
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  // Delete all
  Future<void> deleteAll() async {
    await _box.clear();
  }

  // Stream for reactive updates
  Stream<BoxEvent> watchCategories() {
    return _box.watch();
  }
}
