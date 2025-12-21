import 'package:flutter/material.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/features/home/widgets/list_view/category_list_item.dart';
import 'package:task_manager/features/task/task_list.dart';

class CategoryListView extends StatelessWidget {
  final List<Category> categories;
  const CategoryListView({super.key, required this.categories});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            child: CategoryListItem(category: category),
          );
        });
  }
}
