import 'package:flutter/material.dart';
import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/data/entities/category.dart';

class CategoryGridItem extends StatelessWidget {
  final Category category;

  const CategoryGridItem({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            AppConstants.icons[category.icon]!,
            color: AppConstants.colors[category.color]!,
            size: 50,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text("${category.taskCount} Tasks",
                  style: TextStyle(
                      fontSize: 14,
                      color: category.taskCount > 0
                          ? Colors.red
                          : Colors.grey[500])),
            ],
          )
        ],
      ),
    );
  }
}
