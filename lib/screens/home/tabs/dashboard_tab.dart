import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/models/Task.dart'; // Assurez-vous de l'import pour TaskStatus
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final AuthProvider _authProvider = AuthProvider();
  final ProjectProvider _projectProvider = ProjectProvider();
  final TaskProvider _taskProvider = TaskProvider();

  @override
  void initState() {
    super.initState();
    // Charger les données dès l'ouverture de l'onglet
    _loadData();
  }

  void _loadData() {
    final user = _authProvider.currentUser;
    if (user != null) {
      _projectProvider.loadProjects(user.id);
      // Note: Pour charger toutes les tâches, vous devrez peut-être
      // créer une méthode loadAllUserTasks dans votre TaskProvider
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Bonjour";
    if (hour < 18) return "Bon après-midi";
    return "Bonsoir";
  }

  Future<void> _handleRefresh() async {
    final user = _authProvider.currentUser;
    if (user != null) {
      await _projectProvider.loadProjects(user.id);
      // await _taskProvider.loadTasks(projectId); // Si nécessaire
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authProvider.currentUser;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Message de bienvenue [cite: 237]
            Text(
              "${_getGreeting()}, ${user?.name ?? 'Utilisateur'}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Voici l'état de vos projets aujourd'hui.",
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // 2. Cartes de statistiques avec ListenableBuilder [cite: 237, 248]
            ListenableBuilder(
              listenable: Listenable.merge([_projectProvider, _taskProvider]),
              builder: (context, _) {
                final projectsCount = _projectProvider.projectCount.toString();
                final stats = _taskProvider.taskCountByStatus;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard("Projets", projectsCount, Icons.folder, Colors.blue),
                    _buildStatCard("À faire", "${stats[TaskStatus.todo] ?? 0}", Icons.assignment_outlined, Colors.orange),
                    _buildStatCard("En cours", "${stats[TaskStatus.inProgress] ?? 0}", Icons.trending_up, Colors.purple),
                    _buildStatCard("Terminés", "${stats[TaskStatus.done] ?? 0}", Icons.check_circle_outline, Colors.green),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              "Projets récents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 3. Liste des projets récents [cite: 237]
            ListenableBuilder(
              listenable: _projectProvider,
              builder: (context, _) {
                if (_projectProvider.projects.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text("Aucun projet créé."),
                      ],
                    ),
                  );
                }

                final recentProjects = _projectProvider.projects.reversed.take(3).toList();
                return Column(
                  children: recentProjects.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: p.color.withOpacity(0.2),
                        child: Icon(Icons.folder, color: p.color),
                      ),
                      title: Text(p.name),
                      // Si p.description est null, il affichera une chaîne vide ""
                      subtitle: Text(p.description ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigation vers le détail du projet à venir
                      },
                    ),
                  )).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}