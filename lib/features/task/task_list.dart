import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/providers/repository_providers.dart';
import 'package:task_manager/core/widgets/common/empty_state.dart';
import 'package:task_manager/core/widgets/common/error_state.dart';
import 'package:task_manager/core/widgets/common/loading_indicator.dart';
import 'package:task_manager/data/models/task_list_item.dart';
import 'package:task_manager/data/repositories/interafaces/i_category_repository.dart';
import 'package:task_manager/data/repositories/interafaces/i_task_repository.dart';
import 'package:task_manager/features/category/add_update_category.dart';
import 'package:task_manager/features/task/create_update_task.dart';
import 'package:task_manager/data/entities/category.dart';
import 'package:task_manager/data/entities/task.dart';
import 'package:task_manager/core/constants/app_constants.dart';
import 'package:task_manager/core/enums/view_state.dart';
import 'package:task_manager/core/extensions/date_extension.dart';

class TaskListPage extends ConsumerStatefulWidget {
  final String categoryId;
  const TaskListPage({super.key, required this.categoryId});

  @override
  ConsumerState<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends ConsumerState<TaskListPage> {
  late Category category;
  late ICategoryRepository _categoryRepository;
  late ITaskRepository _taskRepository;
  StreamSubscription? _categorySubscription;
  StreamSubscription? _taskSubscription;

  List<TaskListItem> _tasks = [];

  ViewProcessStatus _viewProcessStatus = ViewProcessStatus.loading;

  @override
  void initState() {
    super.initState();
    _categoryRepository = ref.read(categoryRepositoryProvider);
    _taskRepository = ref.read(taskRepositoryProvider);

    _loadCategory();
    _loadTasks();

    // Use repository's watch method instead of directly accessing Hive
    _categorySubscription = _categoryRepository.watchCategories().listen((_) {
      if (!mounted) return;

      // Check if category still exists
      final cat = _categoryRepository.getCategory(widget.categoryId);
      if (cat == null) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }
      _loadCategory();
    });

    _taskSubscription = _taskRepository.watchTasks().listen((_) {
      if (!mounted) return;
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    try {
      var items =
          _taskRepository.getTasksByCategory(widget.categoryId.toString());

      if (items.isEmpty) {
        setState(() {
          _viewProcessStatus = ViewProcessStatus.empty;
        });
      } else {
        var today = DateTime.now();
        List<TaskListItem> tasks = [];

        var lateTasks =
            items.where((x) => x.status == 0 && x.date.isLate(today));
        if (lateTasks.isNotEmpty) {
          tasks.add(TaskHeaderItem("Late", Colors.orange));
          tasks.addAll(lateTasks.map((x) => TaskItem(x)));
          tasks.add(TaskSpacerItem());
        }

        var todayTasks =
            items.where((x) => x.status == 0 && x.date.isToday(today));
        if (todayTasks.isNotEmpty) {
          tasks.add(TaskHeaderItem("Today", Colors.red));
          tasks.addAll(todayTasks.map((x) => TaskItem(x)));
          tasks.add(TaskSpacerItem());
        }

        var futureTasks =
            items.where((x) => x.status == 0 && x.date.isFuture(today));
        if (futureTasks.isNotEmpty) {
          tasks.add(TaskHeaderItem("Future", Colors.blue));
          tasks.addAll(futureTasks.map((x) => TaskItem(x)));
          tasks.add(TaskSpacerItem());
        }

        var doneTasks = items.where((x) => x.status == 1);
        if (doneTasks.isNotEmpty) {
          tasks.add(TaskHeaderItem("Done", Colors.green));
          tasks.addAll(doneTasks.map((x) => TaskItem(x)));
          tasks.add(TaskSpacerItem());
        }

        setState(() {
          _tasks = tasks;
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
      var item = _categoryRepository.getCategory(widget.categoryId.toString());

      if (item != null) {
        item.taskCount = _taskRepository
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
    _taskSubscription?.cancel();
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
            color: AppConstants.colors[category.color]!,
          ),
          Column(children: [
            TaskInfoUi(
                category: category,
                taskRepository: _taskRepository,
                categoryRepository: _categoryRepository),
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
            return const LoadingIndicator();
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
    return const ErrorState(
      message: 'Error',
    );
  }

  Widget _buildViewEmpty() {
    return const EmptyState(
      message: 'No tasks found',
      imagePath: 'assets/images/empty.png',
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        var item = _tasks[index];
        if (item is TaskHeaderItem) {
          return _buildTaskItemHeader(item);
        } else if (item is TaskItem) {
          return _buildTaskItem(item);
        } else {
          return const SizedBox(
            height: 30,
          );
        }
      },
    );
  }

  Widget _buildTaskItemHeader(TaskHeaderItem header) {
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

  Widget _buildTaskItem(TaskItem item) {
    var task = item.task;
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
                _taskRepository.updateTask(updatedTask);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }),
          trailing: IconButton(
              onPressed: () {
                _taskRepository.deleteTask(task.id);
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
  final ITaskRepository taskRepository;
  final ICategoryRepository categoryRepository;
  const TaskInfoUi(
      {super.key,
      required this.category,
      required this.taskRepository,
      required this.categoryRepository});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      color: AppConstants.colors[category.color]!.withOpacity(0.5),
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
                                        categoryRepository
                                            .deleteCategory(category.id);
                                        taskRepository
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
                    AppConstants.icons[category.icon]!,
                    color: AppConstants.colors[category.color]!,
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
