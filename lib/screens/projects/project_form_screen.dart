import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/Project.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Color _selectedColor;
  final ProjectProvider _projectProvider = ProjectProvider();
  final AuthProvider _authProvider = AuthProvider();

  bool get isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color;
    } else {
      _selectedColor = AppColors.primary;
    }
  }

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      final user = _authProvider.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur : Utilisateur non connecté")),
        );
        return;
      }

      final project = Project(
        id: isEdit ? widget.project!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _selectedColor,
        userId: user.id,
        createdDate: isEdit ? widget.project!.createdDate : DateTime.now(),
      );

      try {
        if (isEdit) {
          // Utilise la méthode updateProject du provider
          await _projectProvider.updateProject(project);
        } else {
          // ATTENTION : La méthode s'appelle createProject dans votre provider
          await _projectProvider.createProject(project);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEdit ? "Projet mis à jour" : "Projet créé avec succès")),
          );

          // REDIRECTION VERS LE DASHBOARD (Retour en arrière)
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de l'enregistrement")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Preview pour la carte
    final previewProject = Project(
      id: 'preview',
      name: _nameController.text.isEmpty ? "Nom du projet" : _nameController.text,
      description: _descriptionController.text,
      color: _selectedColor,
      userId: '1',
      createdDate: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Modifier le projet" : "Nouveau projet"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom du projet", border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
                validator: (value) => (value == null || value.isEmpty) ? "Le nom est requis" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 25),
              const Text("Couleur", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildColorSelector(),
              const SizedBox(height: 30),
              const Text("Aperçu"),
              ProjectCard(project: previewProject, taskCount: 0),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveProject, // Appelle la fonction de sauvegarde
                  child: Text(isEdit ? "ENREGISTRER" : "CRÉER LE PROJET"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final colors = [AppColors.primary, Colors.red, Colors.orange, Colors.green, Colors.purple, Colors.blue];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: colors.map((color) => GestureDetector(
        onTap: () => setState(() => _selectedColor = color),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: _selectedColor == color ? Colors.black : Colors.transparent, width: 2),
          ),
        ),
      )).toList(),
    );
  }
}