import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/data/repositories/interafaces/i_category_repository.dart';
import 'package:task_manager/data/repositories/interafaces/i_task_repository.dart';
import 'package:task_manager/data/repositories/implementations/category_repository.dart';
import 'package:task_manager/data/repositories/implementations/task_repository.dart';

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  return CategoryRepository();
});

final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  return TaskRepository();
});
