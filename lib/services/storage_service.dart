import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Project.dart';
import '../models/Task.dart';
import '../models/User.dart';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========

  /// Instance Unique (privee)
  static StorageService? _instance;

  /// Getter pour acceder a l'instance
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Constructeur prive
  StorageService._();

  //===== SharedPreferences ==========

  /**
   * SharedPreferences utilise des opérations asynchrones
   * car il lit/ecrtit sur le disque
   *
   * Le mot-cle await attend que l'operation se termine
   * La fonction doit etre marque async et retourner un Future
   * Les variables doivent être marqué par late
   */
  late SharedPreferences _prefs;

  /// Indicateur d'initialisation
  bool _initialized = false;

  /// Initialisation de SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Clés de Stockage pour Onboarding =========
  static const String _keyOnboardingConmplete = 'onboarding_complete';

  /// Retourne true si l'onboarding est terminé
  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

  /// Sauvegarde l'état de l'onboarding
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }

  // ======== Clés de stockage pour les utilisateurs =========
  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';

  /// Sauvegarde la liste des utilisateurs
  Future<void> saveUsers(List<User> users) async {
    // Convertir chaque User en Map puis en JSON String
    List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
    await _prefs.setStringList(_keyUsers, usersJson);
  }

  /// Récupère tous les utilisateurs sauvegardés
  List<User> getUsers() {
    List<String>? usersJson = _prefs.getStringList(_keyUsers);
    if (usersJson == null) return [];
    return usersJson
        .map((u) => User.fromMap(jsonDecode(u) as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarde l'utilisateur courant
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  /// Récupère l'utilisateur courant
  User? getCurrentUser() {
    String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson) as Map<String, dynamic>);
  }

  /// Supprime l'utilisateur courant
  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }




  // ======== Tâches =========
  static const String _keyTasks = 'tasks';

  /// Récupère toutes les tâches
  Future<List<Task>> getTasks() async {
    await init(); // s'assure que _prefs est prêt
    List<String>? tasksJson = _prefs.getStringList(_keyTasks);
    if (tasksJson == null) return [];
    return tasksJson
        .map((t) => Task.fromMap(jsonDecode(t) as Map<String, dynamic>))
        .toList();
  }

  /// Récupère les tâches d'un projet
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    List<Task> tasks = await getTasks();
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  /// Récupère les tâches d'un utilisateur
  Future<List<Task>> getTasksByUserId(String userId) async {
    List<Task> tasks = await getTasks();
    return tasks.where((t) => t.userId == userId).toList();
  }

  /// Sauvegarde une tâche (création ou mise à jour)
  Future<void> saveTask(Task task) async {
    await init();
    List<Task> tasks = await getTasks();

    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      // Mise à jour
      tasks[index] = task;
    } else {
      // Création
      tasks.add(task);
    }

    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  /// Supprime une tâche par son id
  Future<void> deleteTask(String taskId) async {
    await init();
    List<Task> tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);

    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  /// Supprime toutes les tâches d'un projet (cascade)
  Future<void> deleteTasksByProjectId(String projectId) async {
    await init();
    List<Task> tasks = await getTasks();
    tasks.removeWhere((t) => t.projectId == projectId);

    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  // ===== Projects =====
  static const String _keyProjects = 'projects';

  /// Récupère tous les projets
  Future<List<Project>> getProjects() async {
    await init();
    final projectsJson = _prefs.getStringList(_keyProjects);
    if (projectsJson == null) return [];
    return projectsJson
        .map((p) => Project.fromMap(jsonDecode(p)))
        .toList();
  }

  /// Sauvegarde ou met à jour un projet
  Future<void> saveProject(Project project) async {
    await init();
    List<Project> projects = await getProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await _prefs.setStringList(
        _keyProjects, projects.map((p) => jsonEncode(p.toMap())).toList());
  }

  /// Supprime un projet
  Future<void> deleteProject(String projectId) async {
    await init();
    List<Project> projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setStringList(
        _keyProjects, projects.map((p) => jsonEncode(p.toMap())).toList());
  }

}