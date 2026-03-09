import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_colors.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/auth/login_screen.dart';
// Importez les onglets une fois créés
// import 'tabs/dashboard_tab.dart';
// import 'tabs/projects_tab.dart';
// import 'tabs/tasks_tab.dart';
// import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Instance de l'auth provider pour récupérer l'utilisateur courant
  final AuthProvider _authProvider = AuthProvider();

  // Liste des titres pour l'AppBar selon l'onglet
  final List<String> _titles = [
    "Tableau de bord",
    "Mes Projets",
    "Mes Tâches",
    "Profil"
  ];

  // Fonction pour gérer la déconnexion
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

      // 4.1 — NavigationDrawer
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name[0].toUpperCase() ?? "U",
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

      // 4.1 — IndexedStack pour préserver l'état des onglets
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(child: Text("DashboardTab à venir")), // Remplacer par DashboardTab()
          Center(child: Text("ProjectsTab à venir")),  // Remplacer par ProjectsTab()
          Center(child: Text("TasksTab à venir")),     // Remplacer par TasksTab()
          Center(child: Text("ProfileTab à venir")),   // Remplacer par ProfileTab()
        ],
      ),

      // 4.1 — FloatingActionButton (visible sur Dashboard et Projets)
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // Logique de création à implémenter
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,

      // 4.1 — BottomNavigationBar
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

  // Helper pour construire les items du Drawer
  Widget _buildDrawerItem(int index, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: _currentIndex == index ? AppColors.primary : null),
      title: Text(label, style: TextStyle(color: _currentIndex == index ? AppColors.primary : null)),
      selected: _currentIndex == index,
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.pop(context); // Ferme le drawer
      },
    );
  }
}