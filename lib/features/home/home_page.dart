import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/providers/repository_providers.dart';
import 'package:task_manager/core/widgets/common/empty_state.dart';
import 'package:task_manager/core/widgets/common/error_state.dart';
import 'package:task_manager/core/widgets/common/loading_indicator.dart';
import 'package:task_manager/data/repositories/interafaces/i_category_repository.dart';
import 'package:task_manager/data/repositories/interafaces/i_task_repository.dart';
import 'package:task_manager/features/category/add_update_category.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/core/enums/view_state.dart';
import 'package:task_manager/features/home/widgets/grid_view/category_grid_view.dart';
import 'package:task_manager/features/home/widgets/list_view/category_list_view.dart';
import 'package:task_manager/data/entities/task.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ICategoryRepository _categoryRepository;
  late ITaskRepository _taskRepository;
  StreamSubscription? _categorySubscription;
  StreamSubscription? _taskSubscription;

  List<Category> categories = [];
  List<Task> tasks = [];
  bool isGrid = false;
  ViewProcessStatus _viewProcessStatus = ViewProcessStatus.loading;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _categoryRepository = ref.read(categoryRepositoryProvider);
    _taskRepository = ref.read(taskRepositoryProvider);

    _categorySubscription = _categoryRepository.watchCategories().listen((_) {
      _loadCategories();
    });

    _taskSubscription = _taskRepository.watchTasks().listen((_) {
      _loadCategories();
    });

    _loadUserName();
    _loadCategories();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      try {
        categories = _categoryRepository.getAllCategories();
        tasks = _taskRepository.getAllTasks();
        for (var category in categories) {
          category.taskCount =
              tasks.where((task) => task.categoryId == category.id).length;
          category.completedTaskCount = tasks
              .where(
                  (task) => task.categoryId == category.id && task.status == 1)
              .length;
        }
        if (categories.isEmpty) {
          _viewProcessStatus = ViewProcessStatus.empty;
        } else {
          _viewProcessStatus = ViewProcessStatus.loaded;
        }
      } catch (e) {
        _viewProcessStatus = ViewProcessStatus.error;
      }
    });
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    _taskSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[50],
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text('Hi, $userName',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Lists",
                      style:
                          TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    _viewProcessStatus == ViewProcessStatus.loaded
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isGrid = !isGrid;
                              });
                            },
                            child: _buildViewIcon(isGrid),
                          )
                        : const SizedBox.shrink()
                  ],
                )
              ],
            ),
          ),
          Expanded(
              child: Container(
                  width: double.infinity,
                  color: Colors.grey[50],
                  child: Builder(builder: (context) {
                    switch (_viewProcessStatus) {
                      case ViewProcessStatus.loading:
                        return const LoadingIndicator();
                      case ViewProcessStatus.loaded:
                        if (isGrid) {
                          return CategoryGridView(categories: categories);
                        } else {
                          return CategoryListView(categories: categories);
                        }
                      case ViewProcessStatus.error:
                        return _buildErrorView();
                      case ViewProcessStatus.empty:
                        return _buildEmptyView();
                    }
                  })))
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    ));
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddUpdateCategory()));
      },
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildViewIcon(bool isGrid) {
    return Icon(isGrid ? Icons.menu_open : Icons.grid_view, size: 30);
  }

  Widget _buildEmptyView() {
    return const EmptyState(
      message: 'No categories found',
      imagePath: 'assets/images/empty.png',
    );
  }

  Widget _buildErrorView() {
    return const ErrorState(
      message: 'Error',
    );
  }
}
