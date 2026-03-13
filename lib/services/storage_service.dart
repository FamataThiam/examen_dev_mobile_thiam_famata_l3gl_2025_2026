import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Project.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../models/comment.dart';

/**
 * Pattern Singleton:
 * Pour avoir une seule instance
 */
class StorageService {
  //===== Singleton ==========

  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  //===== SharedPreferences ==========

  late SharedPreferences _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  // ======== Onboarding =========
  static const String _keyOnboardingConmplete = 'onboarding_complete';

  bool get isOnboardingComplete {
    return _prefs.getBool(_keyOnboardingConmplete) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingConmplete, value);
  }

  // ======== Utilisateurs =========
  static const String _keyUsers = 'users';
  static const String _keyCurrentUser = 'current_user';

  Future<void> saveUsers(List<User> users) async {
    List<String> usersJson = users.map((u) => jsonEncode(u.toMap())).toList();
    await _prefs.setStringList(_keyUsers, usersJson);
  }

  List<User> getUsers() {
    List<String>? usersJson = _prefs.getStringList(_keyUsers);
    if (usersJson == null) return [];
    return usersJson
        .map((u) => User.fromMap(jsonDecode(u) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_keyCurrentUser, jsonEncode(user.toMap()));
  }

  User? getCurrentUser() {
    String? userJson = _prefs.getString(_keyCurrentUser);
    if (userJson == null) return null;
    return User.fromMap(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> clearCurrentUser() async {
    await _prefs.remove(_keyCurrentUser);
  }

  // ======== Projets =========
  static const String _keyProjects = 'projects';

  Future<List<Project>> getProjects() async {
    await init();
    final projectsJson = _prefs.getStringList(_keyProjects);
    if (projectsJson == null) return [];
    return projectsJson
        .map((p) => Project.fromMap(jsonDecode(p)))
        .toList();
  }

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

  Future<void> deleteProject(String projectId) async {
    await init();
    List<Project> projects = await getProjects();
    projects.removeWhere((p) => p.id == projectId);
    await _prefs.setStringList(
        _keyProjects, projects.map((p) => jsonEncode(p.toMap())).toList());
  }

  // ======== Tâches =========
  static const String _keyTasks = 'tasks';

  Future<List<Task>> getTasks() async {
    await init();
    List<String>? tasksJson = _prefs.getStringList(_keyTasks);
    if (tasksJson == null) return [];
    return tasksJson
        .map((t) => Task.fromMap(jsonDecode(t) as Map<String, dynamic>))
        .toList();
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    List<Task> tasks = await getTasks();
    return tasks.where((t) => t.projectId == projectId).toList();
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    List<Task> tasks = await getTasks();
    return tasks.where((t) => t.userId == userId).toList();
  }

  Future<void> saveTask(Task task) async {
    await init();
    List<Task> tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index] = task;
    } else {
      tasks.add(task);
    }
    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  Future<void> deleteTask(String taskId) async {
    await init();
    List<Task> tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  Future<void> deleteTasksByProjectId(String projectId) async {
    await init();
    List<Task> tasks = await getTasks();
    tasks.removeWhere((t) => t.projectId == projectId);
    List<String> tasksJson = tasks.map((t) => jsonEncode(t.toMap())).toList();
    await _prefs.setStringList(_keyTasks, tasksJson);
  }

  // ======== Commentaires =========
  static const String _commentsKey = 'comments';

  Future<List<Comment>> _getAllComments() async {
    await init();
    final raw = _prefs.getString(_commentsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Comment.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveComment(Comment comment) async {
    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.id == comment.id);
    if (index != -1) {
      allComments[index] = comment;
    } else {
      allComments.add(comment);
    }
    final encoded = jsonEncode(allComments.map((c) => c.toMap()).toList());
    await _prefs.setString(_commentsKey, encoded);
  }

  Future<List<Comment>> getCommentsByTaskId(String taskId) async {
    final all = await _getAllComments();
    if (taskId.isEmpty) return all;
    return all.where((c) => c.taskId == taskId).toList();
  }

  Future<void> deleteComment(String commentId) async {
    final all = await _getAllComments();
    all.removeWhere((c) => c.id == commentId);
    final encoded = jsonEncode(all.map((c) => c.toMap()).toList());
    await _prefs.setString(_commentsKey, encoded);
  }

  Future<void> deleteCommentsByTaskId(String taskId) async {
    final all = await _getAllComments();
    all.removeWhere((c) => c.taskId == taskId);
    final encoded = jsonEncode(all.map((c) => c.toMap()).toList());
    await _prefs.setString(_commentsKey, encoded);
  }
}