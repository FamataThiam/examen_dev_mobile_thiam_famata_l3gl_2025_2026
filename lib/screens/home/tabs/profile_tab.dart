import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/providers/project_provider.dart';
import 'package:sunu_task/providers/task_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  // Fonction personnalisée pour formater la date : "09/03/2026"
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return "$day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    // On instancie les providers pour récupérer les données
    final authProvider = AuthProvider();
    final projectProvider = ProjectProvider();
    final taskProvider = TaskProvider();

    final user = authProvider.currentUser;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Header Profil
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : "U",
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? "Utilisateur",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "",
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),

            // 2. Date d'inscription (Formatée manuellement)
            _buildInfoTile(
                Icons.calendar_today_outlined,
                "Membre depuis",
                user != null ? _formatDate(user.createdAt) : "--/--/----"
            ),

            const SizedBox(height: 20),

            // 3. Statistiques avec ListenableBuilder
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Statistiques",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),

            ListenableBuilder(
              listenable: Listenable.merge([projectProvider, taskProvider]),
              builder: (context, _) {
                return Row(
                  children: [
                    _buildStatBox(
                        "Projets",
                        projectProvider.projectCount.toString(),
                        Icons.folder_outlined,
                        Colors.blue
                    ),
                    const SizedBox(width: 15),
                    _buildStatBox(
                        "Tâches",
                        taskProvider.tasks.length.toString(),
                        Icons.task_alt,
                        Colors.green
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // 4. Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  elevation: 0,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _handleLogout(context, authProvider),
                icon: const Icon(Icons.logout),
                label: const Text("Se déconnecter"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }
}