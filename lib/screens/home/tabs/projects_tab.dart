import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/models/Project.dart';

import '../../../widgets/cards/project_card.dart';
import '../../projects/project_detail_screen.dart';
import '../../projects/project_form_screen.dart';


class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> {
  final ProjectProvider _projectProvider = ProjectProvider();
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    final user = _authProvider.currentUser;
    if (user != null) {
      _projectProvider.loadProjects(user.id);
    }
  }

  // Dialogue de confirmation pour la suppression
  void _confirmDelete(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le projet"),
        content: Text("Voulez-vous vraiment supprimer '${project.name}' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await _projectProvider.deleteProject(project.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Supprimer", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _projectProvider,
        builder: (context, _) {
          if (_projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = _projectProvider.projects;

          if (projects.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];

              // Utilisation de ProjectCard pour avoir accès aux boutons de menu (Edit/Delete)
              return ProjectCard(
                project: project,
                taskCount: 0, // Idéalement à calculer via TaskProvider
                onTap: () {
                  // Action : Cliquer sur la carte pour voir les détails
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(project: project),
                    ),
                  );
                },
                onEdit: (p) {
                  // Action : Cliquer sur "Modifier" dans le menu de la carte
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(project: p),
                    ),
                  );
                },
                onDelete: (p) => _confirmDelete(context, p),
              );
            },
          );
        },
      ),
      // Bouton flottant pour la création rapide
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _navigateToCreateProject(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text("Aucun projet pour le moment",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Commencez par créer votre premier projet pour organiser vos tâches.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateProject(context),
              icon: const Icon(Icons.add),
              label: const Text("Créer un projet"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProjectFormScreen()),
    );
  }
}