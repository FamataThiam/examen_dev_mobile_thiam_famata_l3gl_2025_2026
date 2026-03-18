import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/User.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  // ===============================
  // SINGLETON
  // ===============================

  /// Instance unique partagée dans toute l'app
  static final AuthProvider instance = AuthProvider._internal();

  /// Constructeur privé
  AuthProvider._internal();

  /// Constructeur factory : retourne toujours la même instance
  factory AuthProvider() => instance;

  // ===============================
  // VARIABLES PRIVÉES
  // ===============================

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ===============================
  // GETTERS PUBLICS
  // ===============================

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ===============================
  // INITIALISATION
  // ===============================

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.init();
    _currentUser = StorageService.instance.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  // ===============================
  // CONNEXION
  // ===============================

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await StorageService.instance.init();

    List<User> users = StorageService.instance.getUsers();

    try {
      User user = users.firstWhere(
            (u) => u.email == email && u.password == password,
      );

      _currentUser = user;
      await StorageService.instance.saveCurrentUser(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Email ou mot de passe incorrect";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===============================
  // INSCRIPTION
  // ===============================

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await StorageService.instance.init();

    List<User> users = StorageService.instance.getUsers();

    bool emailExists = users.any((u) => u.email == email);
    if (emailExists) {
      _error = "Un utilisateur avec cet email existe déjà";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    String id = const Uuid().v4();

    User newUser = User(
      id: id,
      name: name,
      email: email,
      password: password,
      avatar: null,
      createdAt: DateTime.now(),
    );

    users.add(newUser);
    await StorageService.instance.saveUsers(users);

    _currentUser = newUser;
    await StorageService.instance.saveCurrentUser(newUser);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // ===============================
  // DÉCONNEXION
  // ===============================

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = null;
    await StorageService.instance.clearCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  // ===============================
  // MISE À JOUR DU PROFIL
  // ===============================

  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser == null) return;

    await StorageService.instance.init();

    List<User> users = StorageService.instance.getUsers();

    int index = users.indexWhere((u) => u.id == _currentUser!.id);

    if (index != -1) {
      users[index] = users[index].copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );

      _currentUser = users[index];

      await StorageService.instance.saveUsers(users);
      await StorageService.instance.saveCurrentUser(_currentUser!);

      notifyListeners();
    }
  }

  // ===============================
  // EFFACER ERREUR
  // ===============================

  void clearError() {
    _error = null;
    notifyListeners();
  }
}