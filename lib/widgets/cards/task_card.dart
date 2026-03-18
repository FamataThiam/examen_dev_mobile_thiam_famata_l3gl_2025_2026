import 'package:flutter/material.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';


extension TaskStatusExtension on TaskStatus {
  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return AppStrings.statusTodo;
      case TaskStatus.inProgress:
        return AppStrings.statusInProgress;
      case TaskStatus.done:
        return AppStrings.statusDone;
    }
  }
}


extension TaskPriorityExtension on TaskPriority {
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.label_important;
      case TaskPriority.low:
        return Icons.label_important_outline;
    }
  }

  String get label {
    switch (this) {
      case TaskPriority.high:
        return AppStrings.priorityHigh;
      case TaskPriority.medium:
        return AppStrings.priorityMedium;
      case TaskPriority.low:
        return AppStrings.priorityLow;
    }
  }
}


class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    bool hasDescription = task.description != null && task.description!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ligne contenant l'icône, le titre et le badge
              Row(
                children: [
                  Icon(
                    task.priority.icon,
                    color: task.priority.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.title.isEmpty ? AppStrings.taskTitle : task.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: task.status.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.status.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),


              Stack(
                children: [

                  Visibility(
                    visible: hasDescription,
                    child: Text(
                      task.description ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),

                  Visibility(
                    visible: !hasDescription,
                    child: Text(
                      AppStrings.taskDescription,
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),


              Visibility(
                visible: task.dueDate != null,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate != null
                          ? "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}"
                          : "",
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),


              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  onSelected: (value) {

                    if (value == AppStrings.edit) {
                      if (onEdit != null) onEdit!();
                    }

                    else if (value == AppStrings.delete) {
                      if (onDelete != null) onDelete!();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: AppStrings.edit,
                      child: Text(AppStrings.editTask),
                    ),
                    PopupMenuItem<String>(
                      value: AppStrings.delete,
                      child: Text(AppStrings.deleteTask),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}