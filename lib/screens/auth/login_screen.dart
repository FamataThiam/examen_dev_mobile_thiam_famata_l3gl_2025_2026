import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'package:sunu_task/screens/home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Utilisation d'une instance unique pour l'authentification
  final AuthProvider _authProvider = AuthProvider();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Appel direct à la méthode du provider [cite: 209]
      final success = await _authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Navigation en cas de succès [cite: 212]
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        } else {
          // Affichage de l'erreur stockée dans le provider [cite: 213]
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_authProvider.error ?? "Identifiants incorrects")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur technique : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              CustomTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Email obligatoire";
                  if (!value.contains('@') || !value.contains('.')) return "Email invalide";
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: "Mot de passe",
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Mot de passe obligatoire";
                  if (value.length < 6) return "Minimum 6 caractères";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              CustomButton(
                text: "Se connecter", // [cite: 206]
                isLoading: _isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(AppStrings.noAccount),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text("S'inscrire"), // [cite: 207]
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}