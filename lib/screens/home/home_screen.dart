import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';

// 1. Décommenter et vérifier les imports des onglets
import 'tabs/dashboard_tab.dart';
import 'tabs/projects_tab.dart';
import 'tabs/tasks_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final AuthProvider _authProvider = AuthProvider();

  final List<String> _titles = [
    "Tableau de bord",
    "Mes Projets",
    "Mes Tâches",
    "Profil"
  ];

  void _handleLogout() async {
    await _authProvider.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  // Utilisation de .isNotEmpty pour éviter l'erreur sur l'index [0]
                  (user?.name != null && user!.name.isNotEmpty)
                      ? user.name[0].toUpperCase()
                      : "U",
                  style: TextStyle(fontSize: 24, color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
              accountName: Text(user?.name ?? "Utilisateur"),
              accountEmail: Text(user?.email ?? ""),
            ),
            _buildDrawerItem(0, Icons.dashboard, "Dashboard"),
            _buildDrawerItem(1, Icons.folder, "Projets"),
            _buildDrawerItem(2, Icons.list, "Tâches"),
            _buildDrawerItem(3, Icons.person, "Profil"),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),

      // 2. Remplacer les placeholders par les vrais widgets d'onglets
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DashboardTab(), // Affiche la Partie 4.2
          ProjectsTab(),  // Affiche la Partie 4.3
          TasksTab(),     // Affiche la Partie 4.4
          ProfileTab(),   // Affiche la Partie 4.5
        ],
      ),

      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {

        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projets"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tâches"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: _currentIndex == index ? AppColors.primary : null),
      title: Text(label, style: TextStyle(color: _currentIndex == index ? AppColors.primary : null)),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context);
      },
    );
  }
}