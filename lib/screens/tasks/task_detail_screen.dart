import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Task.dart';
import '../../models/Project.dart';
import '../../providers/task_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final Project project;

  const TaskDetailScreen({super.key, required this.task, required this.project});

  @override
  Widget build(BuildContext context) {
    final TaskProvider taskProvider = TaskProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.task),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(project: project, task: task)))),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () async {
              await taskProvider.deleteTask(task.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Text(task.description ?? AppStrings.taskDescription, style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            const Divider(height: 40),

            // Changement rapide de statut
            const Text(AppStrings.taskStatus, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<TaskStatus>(
              value: task.status,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
              onChanged: (newStatus) {
                if (newStatus != null) taskProvider.updateTask(task.copyWith(status: newStatus));
              },
            ),

            const SizedBox(height: 25),
            _buildInfoRow(Icons.flag, AppStrings.taskPriority, task.priority.name, _getPriorityColor(task.priority)),
            const SizedBox(height: 15),
            _buildInfoRow(Icons.calendar_today, AppStrings.taskDueDate, task.dueDate != null ? "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}" : "Non définie", AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textDisable)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        )
      ],
    );
  }

  Color _getPriorityColor(TaskPriority p) {
    if (p == TaskPriority.high) return AppColors.priorityHigh;
    if (p == TaskPriority.medium) return AppColors.priorityMedium;
    return AppColors.priorityLow;
  }
}