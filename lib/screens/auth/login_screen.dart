import 'package:flutter/material.dart';
import 'package:sunu_task/core/constants/app_strings.dart';
import 'package:sunu_task/widgets/common/custom_text_field.dart';
import 'package:sunu_task/widgets/common/custom_button.dart';
import 'package:sunu_task/providers/auth_provider.dart';
import 'register_screen.dart';
import 'package:sunu_task/screens/home/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Clé du formulaire
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  // -------- Fonction login --------
  Future<void> _login() async {

    // Valider formulaire
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {

      final authProvider = AuthProvider();

      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Navigation vers Home
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      }

    } catch (e) {

      // Affichage erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    } finally {

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.login),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const SizedBox(height: 20),

              // -------- EMAIL --------
              CustomTextField(
                label: "Email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Email obligatoire";
                  }

                  if (!value.contains('@')) {
                    return "Email invalide";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // -------- PASSWORD --------
              CustomTextField(
                label: "Mot de passe",
                controller: _passwordController,
                obscureText: true,

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Mot de passe obligatoire";
                  }

                  if (value.length < 6) {
                    return "Minimum 6 caractères";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              // -------- BOUTON LOGIN --------
              CustomButton(
                text: AppStrings.login,
                isLoading: _isLoading,
                onPressed: _login,
              ),

              const SizedBox(height: 20),

              // -------- LIEN REGISTER --------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text(AppStrings.noAccount),

                  GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );

                    },

                    child: const Text(
                      AppStrings.register,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )

                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}