import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/data/repositories/interafaces/i_category_repository.dart';

class CategoryRepository implements ICategoryRepository {
  static const String _boxName = 'categories';

  Box get _box => Hive.box(_boxName);

  @override
  Future<Category> createCategory(Category category) async {
    await _box.put(category.id, category);
    return category;
  }

  @override
  List<Category> getAllCategories() {
    final categories = _box.values.cast<Category>().toList();
    return categories;
  }

  @override
  Category? getCategory(String id) {
    return _box.get(id);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _box.put(category.id, category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _box.delete(id);
  }

  /// Additional method not in interface - for testing/debugging
  Future<void> deleteAll() async {
    await _box.clear();
  }

  @override
  Stream<void> watchCategories() {
    return _box.watch().map((_) {});
  }
}
