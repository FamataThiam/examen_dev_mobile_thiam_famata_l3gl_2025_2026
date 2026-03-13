import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Project.dart';
import '../../models/Task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards/task_card.dart';
import '../tasks/task_form_screen.dart';
import 'project_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ProjectProvider _projectProvider = ProjectProvider();
  final TaskProvider _taskProvider = TaskProvider();
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    // ✅ Charger les tâches du projet (par projectId)
    _taskProvider.loadTasks(widget.project.id);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteProject),
        content: const Text(AppStrings.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _projectProvider.deleteProject(widget.project.id);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigue vers le formulaire de création/modification de tâche
  void _navigateToTaskForm({Task? task}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          project: widget.project,
          task: task, // null = création, non-null = modification
        ),
      ),
    );
    // ✅ Recharger les tâches au retour
    _taskProvider.loadTasks(widget.project.id);
  }

  /// Confirmation de suppression d'une tâche
  void _confirmDeleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la tâche"),
        content: Text("Voulez-vous vraiment supprimer '${task.title}' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _taskProvider.deleteTask(task.id);
            },
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.project.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectFormScreen(project: widget.project),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _confirmDelete,
          ),
        ],
      ),

      // ✅ ListenableBuilder pour se rafraîchir automatiquement
      body: ListenableBuilder(
        listenable: _taskProvider,
        builder: (context, _) {
          final projectTasks = _taskProvider.tasks
              .where((t) => t.projectId == widget.project.id)
              .toList();

          final todoCount = projectTasks.where((t) => t.status == TaskStatus.todo).length;
          final progressCount = projectTasks.where((t) => t.status == TaskStatus.inProgress).length;
          final doneCount = projectTasks.where((t) => t.status == TaskStatus.done).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du projet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.project.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.project.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.project.description ?? AppStrings.noProjectsDesc,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Statistiques
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBadge(AppStrings.statusTodo, todoCount, AppColors.statusTodo),
                    _buildStatBadge(AppStrings.statusInProgress, progressCount, AppColors.statusInProgress),
                    _buildStatBadge(AppStrings.statusDone, doneCount, AppColors.statusDone),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  AppStrings.tasks,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Liste des tâches
              Expanded(
                child: _taskProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : projectTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        AppStrings.noTasks,
                        style: TextStyle(color: AppColors.textDisable),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _navigateToTaskForm,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter une tâche"),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: projectTasks.length,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemBuilder: (context, index) {
                    final task = projectTasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () => _navigateToTaskForm(task: task),
                      onEdit: () => _navigateToTaskForm(task: task),
                      onDelete: () => _confirmDeleteTask(task),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ✅ FAB connecté
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: _navigateToTaskForm,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}