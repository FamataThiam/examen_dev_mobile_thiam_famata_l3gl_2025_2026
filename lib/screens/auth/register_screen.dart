import 'package:flutter/material.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Clé pour la validation du formulaire [cite: 208]
  final _formKey = GlobalKey<FormState>();

  // Définition des contrôleurs pour les 4 champs requis [cite: 216]
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Instance de l'AuthProvider
  final _authProvider = AuthProvider();
  bool _isLoading = false;

  Future<void> _register() async {
    // 1. Déclenchement de la validation du formulaire [cite: 208]
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Appel de la méthode register du provider [cite: 224]
      // L'erreur "DateTime" est résolue en convertissant la date en String dans User.toMap()
      final success = await _authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // 3. Navigation vers HomeScreen et vidage de la pile de navigation [cite: 212]
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        } else {
          // 4. Affichage de l'erreur métier (ex: email déjà pris) [cite: 213]
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authProvider.error ?? "Erreur d'inscription")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Une erreur technique est survenue : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Validation du Nom : min 2 caractères [cite: 218]
                CustomTextField(
                  label: "Nom",
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (val) => (val == null || val.trim().length < 2)
                      ? "Nom obligatoire (min 2 caractères)" : null,
                ),
                const SizedBox(height: 20),

                // Validation de l'Email : format valide requis [cite: 219]
                CustomTextField(
                  label: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Email obligatoire";
                    if (!val.contains('@') || !val.contains('.')) return "Format email invalide";
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Validation du Mot de passe : min 6 caractères [cite: 220]
                CustomTextField(
                  label: "Mot de passe",
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) => (val == null || val.length < 6)
                      ? "Minimum 6 caractères" : null,
                ),
                const SizedBox(height: 20),

                // Validation de la Confirmation : doit correspondre au mot de passe [cite: 221]
                CustomTextField(
                  label: "Confirmer le mot de passe",
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_reset,
                  validator: (val) {
                    if (val != _passwordController.text) return "Les mots de passe ne correspondent pas";
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Utilisation du CustomButton avec état de chargement [cite: 206, 222]
                CustomButton(
                  text: "S'inscrire",
                  isLoading: _isLoading,
                  onPressed: _register,
                ),

                const SizedBox(height: 20),

                // Lien de retour vers la connexion [cite: 223]
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Déjà un compte ? Se connecter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Nettoyage des ressources pour éviter les fuites de mémoire
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}