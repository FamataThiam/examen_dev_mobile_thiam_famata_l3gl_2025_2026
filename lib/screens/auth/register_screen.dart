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
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les 4 champs [cite: 216]
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Instance de l'AuthProvider (à adapter selon votre setup de main.dart)
  final _authProvider = AuthProvider();
  bool _isLoading = false;

  Future<void> _register() async {
    // 1. Validation du formulaire [cite: 208, 224]
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 2. Appel de la logique register [cite: 224]
      final success = await _authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        } else {
          // 4. Affichage d'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authProvider.error ?? "Erreur d'inscription")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : $e")),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ Nom [cite: 218]
              CustomTextField(
                label: "Nom",
                controller: _nameController,
                validator: (val) => (val == null || val.length < 2)
                    ? "Nom obligatoire (min 2 caractères)" : null,
              ),
              const SizedBox(height: 20),

              // Champ Email [cite: 219]
              CustomTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Email obligatoire";
                  if (!val.contains('@') || !val.contains('.')) return "Format invalide";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ Mot de passe [cite: 220]
              CustomTextField(
                label: "Mot de passe",
                controller: _passwordController,
                obscureText: true,
                validator: (val) => (val == null || val.length < 6)
                    ? "Minimum 6 caractères" : null,
              ),
              const SizedBox(height: 20),

              // Champ Confirmation [cite: 221]
              CustomTextField(
                label: "Confirmer le mot de passe",
                controller: _confirmPasswordController,
                obscureText: true,
                validator: (val) {
                  if (val != _passwordController.text) return "Les mots de passe ne correspondent pas";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Bouton S'inscrire [cite: 222]
              CustomButton(
                text: "S'inscrire",
                isLoading: _isLoading,
                onPressed: _register,
              ),

              const SizedBox(height: 20),

              // Lien vers Login [cite: 223]
              TextButton(
                onPressed: () => Navigator.pop(context), // Retour au LoginScreen
                child: const Text("Déjà un compte ? Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}