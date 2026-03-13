import 'package:flutter/material.dart';
import 'package:sunu_task/models/Task.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/screens/tasks/task_detail_screen.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  final TaskProvider _taskProvider = TaskProvider();
  final ProjectProvider _projectProvider = ProjectProvider();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListenableBuilder(
              listenable: _taskProvider,
              builder: (context, _) {
                final tasks = _taskProvider.tasks;

                if (_taskProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (tasks.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _buildTaskCard(task);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            DropdownButton<TaskStatus?>(
              value: _taskProvider.statusFilter,
              hint: const Text("Tous les statuts"),
              underline: const SizedBox(),
              onChanged: (val) => _taskProvider.setStatusFilter(val),
              items: [
                const DropdownMenuItem(value: null, child: Text("Tous les statuts")),
                ...TaskStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name))),
              ],
            ),
            const SizedBox(width: 16),
            DropdownButton<TaskPriority?>(
              value: _taskProvider.priorityFilter,
              hint: const Text("Toutes priorités"),
              underline: const SizedBox(),
              onChanged: (val) => _taskProvider.setPriorityFilter(val),
              items: [
                const DropdownMenuItem(value: null, child: Text("Toutes priorités")),
                ...TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name))),
              ],
            ),
            const SizedBox(width: 8),
            if (_taskProvider.statusFilter != null || _taskProvider.priorityFilter != null)
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _taskProvider.clearFilters(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // ✅ Navigation vers TaskDetailScreen au tap
        onTap: () {
          // Trouver le projet associé à la tâche
          final project = _projectProvider.projects
              .where((p) => p.id == task.projectId)
              .firstOrNull;

          if (project != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task, project: project),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Projet introuvable")),
            );
          }
        },
        child: ListTile(
          leading: Icon(
            _getStatusIcon(task.status),
            color: _getStatusColor(task.status),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.status == TaskStatus.done
                  ? TextDecoration.lineThrough
                  : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          trailing: Checkbox(
            value: task.status == TaskStatus.done,
            onChanged: (val) {
              final newStatus = val! ? TaskStatus.done : TaskStatus.todo;
              _taskProvider.updateTaskStatus(task.id, newStatus);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune tâche trouvée",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text("Ajustez vos filtres ou créez une tâche.",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done: return AppColors.statusDone;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo: return Icons.radio_button_unchecked;
      case TaskStatus.inProgress: return Icons.pending_actions;
      case TaskStatus.done: return Icons.check_circle;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low: return AppColors.priorityLow;
    }
  }
}