import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/User.dart';
import '../services/storage_service.dart';

/// AuthProvider gère :
/// - L’authentification (login / register)
/// - La session utilisateur
/// - La mise à jour du profil
/// - La déconnexion
///
/// ChangeNotifier permet d’informer automatiquement
/// les widgets qui écoutent ce provider lorsqu’un état change.
class AuthProvider extends ChangeNotifier {
  // ===============================
  // VARIABLES PRIVÉES
  // ===============================

  /// Utilisateur actuellement connecté
  User? _currentUser;

  /// Indique si une opération est en cours (login/register...)
  bool _isLoading = false;

  /// Message d’erreur éventuel
  String? _error;

  // ===============================
  // GETTERS PUBLICS
  // ===============================

  /// Retourne l’utilisateur courant
  User? get currentUser => _currentUser;

  /// Retourne true si un utilisateur est connecté
  bool get isAuthenticated => _currentUser != null;

  /// Indique si une opération est en cours
  bool get isLoading => _isLoading;

  /// Retourne le message d’erreur
  String? get error => _error;

  // ===============================
  // INITIALISATION
  // ===============================

  /// Charge l'utilisateur sauvegardé depuis le stockage local
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await StorageService.instance.init();

    // Récupère l’utilisateur sauvegardé (si existe)
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

    // Récupérer tous les utilisateurs enregistrés
    List<User> users = StorageService.instance.getUsers();

    //  Chercher un utilisateur correspondant
    try {
      User user = users.firstWhere(
            (u) => u.email == email && u.password == password,
      );

      //  Si trouvé → sauvegarder comme utilisateur courant
      _currentUser = user;
      await StorageService.instance.saveCurrentUser(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      //  Si non trouvé
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

    //  Vérifier si email existe déjà
    bool emailExists = users.any((u) => u.email == email);

    if (emailExists) {
      _error = "Un utilisateur avec cet email existe déjà";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Générer un ID unique
    String id = const Uuid().v4();

    //  Créer le nouvel utilisateur
    User newUser = User(
      id: id,
      name: name,
      email: email,
      password: password,
      avatar: null,
      createdAt: DateTime.now(),
    );

    //  Ajouter à la liste
    users.add(newUser);

    // Sauvegarder dans le stockage
    await StorageService.instance.saveUsers(users);

    //Définir comme utilisateur courant
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

    // Supprimer utilisateur courant du stockage
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

    // Trouver index utilisateur
    int index = users.indexWhere((u) => u.id == _currentUser!.id);

    if (index != -1) {
      // Mise à jour du profil
      users[index] = users[index].copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
      );

      _currentUser = users[index];

      // Sauvegarde les modifications
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