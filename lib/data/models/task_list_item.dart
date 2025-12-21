// Tạo sealed class hoặc union type
import 'dart:ui';

import 'package:task_manager/data/entities/task.dart';

sealed class TaskListItem {}

class TaskHeaderItem extends TaskListItem {
  final String header;
  final Color color;
  TaskHeaderItem(this.header, this.color);
}

class TaskItem extends TaskListItem {
  final Task task;
  TaskItem(this.task);
}

class TaskSpacerItem extends TaskListItem {}
