import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/features/home/widgets/grid_view/category_grid_item.dart';
import 'package:task_manager/features/task/task_list.dart';

class CategoryGridView extends StatelessWidget {
  final List<Category> categories;
  const CategoryGridView({super.key, required this.categories});
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TaskListPage(categoryId: category.id)));
            },
            child: CategoryGridItem(category: category),
          );
        });
  }
}
