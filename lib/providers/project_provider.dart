import 'package:flutter/cupertino.dart';
import '../models/Project.dart';
import '../services/storage_service.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  Project? _selectedProject;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Project> get projects => List.unmodifiable(_projects);
  Project? get selectedProject => _selectedProject;
  int get projectCount => _projects.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===== CRUD =====

  /// Charge les projets d'un utilisateur
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

  /// Crée un nouveau projet
  Future<void> createProject(Project project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await StorageService.instance.saveProject(project); // ✅ corrigé ici
      _projects.add(project);
    } catch (e) {
      _error = 'Erreur lors de la création du projet : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Met à jour un projet existant
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

  /// Supprime un projet
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

  /// Sélectionne un projet
  void selectProject(Project? project) {
    _selectedProject = project;
    notifyListeners();
  }

  /// Supprime l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}