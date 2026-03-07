import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  TaskStatus? _statusFilter;
  TaskPriority? _priorityFilter;

  bool _isLoading = false;

  // ===== Getters =====

  bool get isLoading => _isLoading;

  TaskStatus? get statusFilter => _statusFilter;
  TaskPriority? get priorityFilter => _priorityFilter;

  /// Retourne les tâches filtrées et triées
  List<Task> get tasks {
    List<Task> filtered = List.from(_tasks);

    if (_statusFilter != null) {
      filtered = filtered.where((t) => t.status == _statusFilter).toList();
    }

    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    filtered.sort(_taskComparator);

    return filtered;
  }

  /// Compteur par statut
  Map<TaskStatus, int> get taskCountByStatus {
    Map<TaskStatus, int> count = {
      TaskStatus.todo: 0,
      TaskStatus.inProgress: 0,
      TaskStatus.done: 0,
    };

    for (var task in _tasks) {
      count[task.status] = (count[task.status] ?? 0) + 1;
    }

    return count;
  }

  // ===== TRI =====

  int _taskComparator(Task a, Task b) {
    int statusCompare = _statusOrder(a.status).compareTo(_statusOrder(b.status));

    if (statusCompare != 0) return statusCompare;

    return _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority));
  }

  int _statusOrder(TaskStatus status) {
    switch (status) {
      case TaskStatus.inProgress:
        return 0;
      case TaskStatus.todo:
        return 1;
      case TaskStatus.done:
        return 2;
    }
  }

  int _priorityOrder(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.low:
        return 2;
    }
  }

  // ===== CRUD =====

  Future<void> loadTasks(String projectId) async {
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
      if (index != -1) {
        _tasks[index] = task;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
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

    Task updated = _tasks[index].copyWith(status: status);

    await updateTask(updated);
  }

  // ===== FILTRES =====

  void setStatusFilter(TaskStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(TaskPriority? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    notifyListeners();
  }
}