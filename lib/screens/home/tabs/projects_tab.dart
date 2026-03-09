import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/auth_provider.dart';
// Importez votre widget ProjectCard et votre écran de formulaire
// import 'package:sunu_task/widgets/project_card.dart';
// import 'package:sunu_task/screens/projects/project_form_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // On utilise un ListenableBuilder pour reconstruire quand la liste change
      body: ListenableBuilder(
        listenable: _projectProvider,
        builder: (context, _) {
          if (_projectProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = _projectProvider.projects;

          // GESTION DE L'ÉTAT VIDE
          if (projects.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.folder_off_outlined,
                      size: 80,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Aucun projet pour le moment",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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

          // AFFICHAGE DE LA LISTE
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              // Si vous n'avez pas encore ProjectCard, vous pouvez utiliser ListTile
              // ou un widget personnalisé temporaire
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    width: 12,
                    decoration: BoxDecoration(
                      color: project.color, // Utilise la couleur du modèle
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  title: Text(
                    project.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    project.description ?? "Pas de description",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigation vers le détail du projet (Partie 4.1 du PDF)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToCreateProject(BuildContext context) {
    // Naviguer vers le formulaire de création (Partie 4.3)
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectFormScreen()));

    // Pour le moment, un simple message de test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ouverture du formulaire de création...")),
    );
  }
}