import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Project.dart';
import '../../models/Task.dart';
import '../../providers/project_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards/task_card.dart';
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
    // Chargement initial des tâches de l'utilisateur
    final userId = _authProvider.currentUser?.id;
    if (userId != null) {
      _taskProvider.loadTasks(userId);
    }
  }

  /// Dialogue de confirmation de suppression utilisant AppStrings
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
                Navigator.pop(context); // Ferme le dialogue
                Navigator.pop(context); // Retourne à la liste
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

  /// Badge de statistique utilisant les couleurs de statut de AppColors
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
    // Filtrage manuel des tâches par ID de projet
    final projectTasks = _taskProvider.tasks
        .where((t) => t.projectId == widget.project.id)
        .toList();

    // Calcul des compteurs par statut
    final todoCount = projectTasks.where((t) => t.status == TaskStatus.todo).length;
    final progressCount = projectTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final doneCount = projectTasks.where((t) => t.status == TaskStatus.done).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.projects), // "Projets"
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// En-tête du projet avec la couleur dynamique du projet
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: const Border(
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

          /// Section Statistiques
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

          /// Liste des tâches
          Expanded(
            child: projectTasks.isEmpty
                ? const Center(
              child: Text(
                AppStrings.noTasks,
                style: TextStyle(color: AppColors.textDisable),
              ),
            )
                : ListView.builder(
              itemCount: projectTasks.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                return TaskCard(task: projectTasks[index]);
              },
            ),
          ),
        ],
      ),

      /// Bouton d'ajout de tâche
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Action pour ajouter une tâche (ex: TaskFormScreen)
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}