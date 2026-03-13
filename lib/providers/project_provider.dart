import 'package:flutter/cupertino.dart';
import '../models/Project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  // ===============================
  // SINGLETON
  // ===============================

  static final ProjectProvider instance = ProjectProvider._internal();
  ProjectProvider._internal();
  factory ProjectProvider() => instance;

  // ===============================

  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allProjects = await StorageService.instance.getProjects();
      _projects = allProjects.where((p) => p.userId == userId).toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des projets : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.saveProject(project);
      _projects.add(project);
    } catch (e) {
      _error = 'Erreur lors de la création du projet : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.saveProject(project);

      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }

      if (_selectedProject?.id == project.id) {
        _selectedProject = project;
      }
    } catch (e) {
      _error = 'Erreur lors de la mise à jour du projet : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);

      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
    } catch (e) {
      _error = 'Erreur lors de la suppression du projet : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}