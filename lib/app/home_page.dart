import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/app/add_update_category.dart';
import 'package:task_manager/app/entities/category.dart';
import 'package:task_manager/app/services/category_service.dart';
import 'package:task_manager/app/services/task_service.dart';
import 'package:task_manager/app/shared/common_enum.dart';
import 'package:task_manager/app/shared/common_helper.dart';
import 'package:task_manager/app/task_list.dart';

import 'entities/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryService _categoryService = CategoryService();
  final TaskService _taskService = TaskService();

  List<Category> categories = [];
  List<Task> tasks = [];
  bool isGrid = false;
  ViewProcessStatus _viewProcessStatus = ViewProcessStatus.loading;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCategories();

    // listen to changes in the category box
    Hive.box('categories').watch().listen((event) {
      _loadCategories();
    });

    Hive.box('tasks').watch().listen((event) {
      _loadCategories();
    });
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
        categories = _categoryService.getAllCategories();
        tasks = _taskService.getAllTasks();
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
                        return const Center(child: CircularProgressIndicator());
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: AssetImage('assets/images/empty.png'),
          height: 100,
          width: 100,
        ),
        SizedBox(height: 20),
        Text('No categories found'),
      ],
    );
  }

  Widget _buildErrorView() {
    return const Center(child: Text('Error'));
  }
}

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
            color: ColorsHelper().colors[category.color]!,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(IconsHelper().icons[category.icon]!, color: Colors.white),
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
            color: ColorsHelper().colors[category.color]!,
            backgroundColor: Colors.grey[300]!,
            valueColor: const AlwaysStoppedAnimation(Colors.green),
          ),
        ),
      ),
    );
  }
}

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
            IconsHelper().icons[category.icon]!,
            color: ColorsHelper().colors[category.color]!,
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
