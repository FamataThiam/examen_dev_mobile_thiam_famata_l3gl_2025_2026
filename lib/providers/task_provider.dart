import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  // ===============================
  // SINGLETON
  // ===============================
  static final TaskProvider instance = TaskProvider._internal();
  TaskProvider._internal();
  factory TaskProvider() => instance;

  // ===============================
  List<Task> _tasks = [];
  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;
  bool _isLoading = false;

  // Contexte de chargement actif
  String? _currentProjectId;
  String? _currentUserId;

  bool get isLoading => _isLoading;
  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Toutes les tâches sans filtre (pour ProjectDetailScreen)
  List<Task> get allTasks => List.unmodifiable(_tasks);

  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);
    if (_statusFilter != null) filtered = filtered.where((t) => t.status == _statusFilter).toList();
    if (_priorityFilter != null) filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    filtered.sort(_taskComparator);
    return filtered;
  }

  Map<TaskStatus, int> get taskCountByStatus {
    final count = {TaskStatus.todo: 0, TaskStatus.inProgress: 0, TaskStatus.done: 0};
    for (var task in _tasks) count[task.status] = (count[task.status] ?? 0) + 1;
    return count;
  }

  int _taskComparator(Task a, Task b) {
    final s = _statusOrder(a.status).compareTo(_statusOrder(b.status));
    if (s != 0) return s;
    return _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority));
  }

  int _statusOrder(TaskStatus s) {
    switch (s) {
      case TaskStatus.inProgress: return 0;
      case TaskStatus.todo: return 1;
      case TaskStatus.done: return 2;
    }
  }

  int _priorityOrder(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return 0;
      case TaskPriority.medium: return 1;
      case TaskPriority.low: return 2;
    }
  }

  // ===== CHARGEMENT =====

  /// Charge les tâches d'un projet spécifique
  Future<void> loadTasks(String projectId) async {
    _currentProjectId = projectId;
    _currentUserId = null;
    _isLoading = true;
    notifyListeners();
    try {
      final allTasks = await StorageService.instance.getTasks();
      _tasks = allTasks.where((t) => t.projectId == projectId).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge toutes les tâches d'un utilisateur (Dashboard, TasksTab)
  Future<void> loadAllUserTasks(String userId) async {
    _currentUserId = userId;
    _currentProjectId = null;
    _isLoading = true;
    notifyListeners();
    try {
      final allTasks = await StorageService.instance.getTasks();
      _tasks = allTasks.where((t) => t.userId == userId).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recharge selon le contexte actif
  Future<void> reload() async {
    if (_currentProjectId != null) await loadTasks(_currentProjectId!);
    else if (_currentUserId != null) await loadAllUserTasks(_currentUserId!);
  }

  // ===== CRUD =====

  Future<void> createTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await StorageService.instance.saveTask(task);
      _tasks.add(task);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    notifyListeners();
    try {
      await StorageService.instance.saveTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) _tasks[index] = task;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await StorageService.instance.deleteCommentsByTaskId(taskId);
      await StorageService.instance.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    await updateTask(_tasks[index].copyWith(status: status));
  }



  void setStatusFilter(TaskStatus? status) { _statusFilter = status; notifyListeners(); }
  void setPriorityFilter(TaskPriority? priority) { _priorityFilter = priority; notifyListeners(); }
  void clearFilters() { _statusFilter = null; _priorityFilter = null; notifyListeners(); }
}