import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:task_manager/app/add_update_category.dart';
import 'package:task_manager/app/create_update_task.dart';
import 'package:task_manager/app/entities/category.dart';
import 'package:task_manager/app/entities/task.dart';
import 'package:task_manager/app/models/task_header_model.dart';
import 'package:task_manager/app/services/category_service.dart';
import 'package:task_manager/app/services/task_service.dart';
import 'package:task_manager/app/shared/common_enum.dart';
import 'package:task_manager/app/shared/common_helper.dart';
import 'package:task_manager/app/shared/date_helper.dart';

class TaskListPage extends StatefulWidget {
  final String categoryId;
  const TaskListPage({super.key, required this.categoryId});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Category category;
  final CategoryService _categoryService = CategoryService();
  final TaskService _taskService = TaskService();
  StreamSubscription? _categorySubscription;

  List<dynamic> tasks = [];

  ViewProcessStatus _viewProcessStatus = ViewProcessStatus.loading;

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadTasks();

    // listen to changes in the category box
    _categorySubscription = Hive.box('categories').watch().listen((event) {
      if (!mounted) return;

      if (event.deleted) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }
      _loadCategory();
    });

    _categorySubscription = Hive.box('tasks').watch().listen((event) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    try {
      var items = _taskService.getTasksByCategory(widget.categoryId.toString());
      List<dynamic> fn = [];
      if (items.isEmpty) {
        setState(() {
          _viewProcessStatus = ViewProcessStatus.empty;
        });
      } else {
        var today = DateTime.now();

        var lateTasks =
            items.where((x) => x.status == 0 && x.date.isLate(today));
        if (lateTasks.isNotEmpty) {
          fn.add(TaskHeaderModel(header: "Late", color: Colors.orange));
          fn.addAll(lateTasks);
          fn.add("");
        }

        var todayTasks =
            items.where((x) => x.status == 0 && x.date.isToday(today));
        if (todayTasks.isNotEmpty) {
          fn.add(TaskHeaderModel(header: "Today", color: Colors.red));
          fn.addAll(todayTasks);
          fn.add("");
        }

        var futureTasks =
            items.where((x) => x.status == 0 && x.date.isFuture(today));
        if (futureTasks.isNotEmpty) {
          fn.add(TaskHeaderModel(header: "Future", color: Colors.blue));
          fn.addAll(futureTasks);
          fn.add("");
        }

        var doneTasks = items.where((x) => x.status == 1);
        if (doneTasks.isNotEmpty) {
          fn.add(TaskHeaderModel(header: "Done", color: Colors.green));
          fn.addAll(doneTasks);
          fn.add("");
        }

        setState(() {
          tasks = fn;
          _viewProcessStatus = ViewProcessStatus.loaded;
        });
      }
    } catch (e) {
      setState(() {
        _viewProcessStatus = ViewProcessStatus.error;
      });
    }
  }

  Future<void> _loadCategory() async {
    if (!mounted) return;

    try {
      var item = _categoryService.getCategory(widget.categoryId.toString());

      if (item != null) {
        item.taskCount = _taskService
            .getTasksByCategory(widget.categoryId.toString())
            .length;
        setState(() {
          category = item;
        });
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorsHelper().colors[category.color]!,
          ),
          Column(children: [
            TaskInfoUi(
                category: category,
                taskService: _taskService,
                categoryService: _categoryService),
            _buildListView()
          ])
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    ));
  }

  Widget _buildListView() {
    return Expanded(
        child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Builder(builder: (context) {
        switch (_viewProcessStatus) {
          case ViewProcessStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ViewProcessStatus.loaded:
            return _buildTaskList();
          case ViewProcessStatus.error:
            return _buildViewError();
          case ViewProcessStatus.empty:
            return _buildViewEmpty();
        }
      }),
    ));
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateUpdateTaskForm(
                      categoryId: widget.categoryId,
                    )));
      },
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    );
  }

  Widget _buildViewError() {
    return const Center(child: Text('Error'));
  }

  Widget _buildViewEmpty() {
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
        Text('No tasks found'),
      ],
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        var item = tasks[index];
        if (item is TaskHeaderModel) {
          return _buildTaskItemHeader(item);
        } else if (item is Task) {
          return _buildTaskItem(item);
        } else {
          return const SizedBox(
            height: 30,
          );
        }
      },
    );
  }

  Widget _buildTaskItemHeader(TaskHeaderModel header) {
    return Column(
      children: [
        Text(
          header.header,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: header.color,
          ),
          textAlign: TextAlign.center,
        ),
        Divider(
          color: Colors.grey[300]!,
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: task.status == 0 ? Colors.orange[50] : Colors.green[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        child: ListTile(
          title: Text(task.title,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          subtitle: Text(task.date.formatDate(),
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          leading: Checkbox(
              value: task.status == 1,
              onChanged: (value) {
                final updatedTask = Task(
                  id: task.id,
                  title: task.title,
                  description: task.description,
                  date: task.date,
                  priority: task.priority,
                  status: value ?? false ? 1 : 0,
                  categoryId: task.categoryId,
                  createdAt: task.createdAt,
                  updatedAt: DateTime.now(),
                );
                _taskService.updateTask(updatedTask);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }),
          trailing: IconButton(
              onPressed: () {
                _taskService.deleteTask(task.id);
              },
              icon: const Icon(Icons.delete)),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateUpdateTaskForm(
                        categoryId: widget.categoryId,
                        task: task,
                      )));
        },
      ),
    );
  }
}

class TaskInfoUi extends StatelessWidget {
  final Category category;
  final TaskService taskService;
  final CategoryService categoryService;
  const TaskInfoUi(
      {super.key,
      required this.category,
      required this.taskService,
      required this.categoryService});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: ColorsHelper().colors[category.color]!.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child:
                        const Icon(Icons.delete_outline, color: Colors.white),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: const Text('Delete Category'),
                                content: const Text(
                                    'Are you sure you want to delete this category?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        categoryService
                                            .deleteCategory(category.id);
                                        taskService
                                            .deleteTasksByCategory(category.id);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete')),
                                ],
                              ));
                    },
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    child: const Icon(Icons.edit, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  AddUpdateCategory(category: category)));
                    },
                  )
                ],
              ))
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    IconsHelper().icons[category.icon]!,
                    color: ColorsHelper().colors[category.color]!,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  category.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "${category.taskCount} Tasks",
                  style: TextStyle(
                      color:
                          category.taskCount > 0 ? Colors.white : Colors.white,
                      fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
