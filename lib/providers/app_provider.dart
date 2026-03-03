import 'package:flutter/cupertino.dart';

import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  // CHANGENOTIFIER permet automatiquement d'informer les widgets qui l'écoutent
  // DECLARATIONS DES VARIABLES
  bool _isOnboardingComplete = false;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;



  // INIATILISE L'ETAT DU PROVIDERS AU DEMARRAGE
  Future<void> init() async {
    _isLoading = true; /// LE Chargement commence
    notifyListeners(); /// révient tous les widgets écoutant ce provider que l’état a changé (ici pour montrer un loader)

    /// récupère depuis le stockage si l’utilisateur a déjà terminé l’onboarding.
    _isOnboardingComplete = StorageService.instance.isOnboardingComplete;

    _isInitialized = true; /// Signale que l'initialisation est termiée
    /// cache le loader et rafraîchit l’UI
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    /// sauvegarde dans le stockage local que l’onboarding est terminé.
    await StorageService.instance.setOnboardingComplete(true);
    _isOnboardingComplete = true; /// met à jour l’état local.
    notifyListeners(); /// informe les widgets écoutant que l’état a changé (ex. rediriger vers l’écran principal)
  }

  Future<void> resetOnboarding() async {
    // Permet de réinitialiser l’onboarding
    _isOnboardingComplete = false;
    notifyListeners();
  }
}