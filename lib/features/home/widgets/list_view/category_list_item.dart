import 'package:flutter/material.dart';
import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/data/entities/category.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;

  const CategoryListItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(category.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppConstants.colors[category.color]!,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(AppConstants.icons[category.icon]!, color: Colors.white),
        ),
        subtitle: Text("${category.taskCount} Tasks",
            style: TextStyle(
                fontSize: 14,
                color: category.taskCount > 0 ? Colors.red : Colors.grey[500])),
        trailing: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: category.taskCount > 0
                ? category.completedTaskCount.toDouble() /
                    category.taskCount.toDouble()
                : 0.0,
            color: AppConstants.colors[category.color]!,
            backgroundColor: Colors.grey[300]!,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
        ),
      ),
    );
  }
}
