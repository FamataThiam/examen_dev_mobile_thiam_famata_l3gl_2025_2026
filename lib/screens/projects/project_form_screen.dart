import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../models/Project.dart';
import '../../services/storage_service.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:sunu_task/widgets/cards/project_card.dart';

class ProjectFormScreen extends StatefulWidget {
  final Project? project; // null = création, non-null = modification

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  /// Couleur sélectionnée
  late Color _selectedColor;

  // Instances des services/providers
  final ProjectProvider _projectProvider = ProjectProvider();
  final AuthProvider _authProvider = AuthProvider();

  bool get isEdit => widget.project != null;

  @override
  void initState() {
    super.initState();

    /// Pré-remplissage en mode modification
    if (isEdit) {
      _nameController.text = widget.project!.name;
      _descriptionController.text = widget.project!.description ?? '';
      _selectedColor = widget.project!.color; // Utilise la couleur du projet
    } else {
      _selectedColor = AppColors.primary; // Couleur par défaut
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Sauvegarde du projet
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    // Récupération de l'ID de l'utilisateur actuel
    final userId = _authProvider.currentUser?.id;
    if (userId == null) return;

    final project = Project(
      id: isEdit ? widget.project!.id : const Uuid().v4(),
      userId: userId, // Obligatoire selon le modèle
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      createdDate: isEdit ? widget.project!.createdDate : DateTime.now(),
    );

    // Utilisation du provider pour mettre à jour l'UI et le stockage
    if (isEdit) {
      await _projectProvider.updateProject(project);
    } else {
      await _projectProvider.createProject(project);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Widget pour afficher un cercle de couleur
  Widget _colorItem(Color color) {
    final selected = color.value == _selectedColor.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: CircleAvatar(
        radius: selected ? 22 : 18,
        backgroundColor: color,
        child: selected
            ? const Icon(Icons.check, color: Colors.white)
            : null,
      ),
    );
  }

  /// Sélecteur de couleurs (8 cercles dans un Wrap)
  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _colorItem(AppColors.primary),
        _colorItem(AppColors.secondary),
        _colorItem(AppColors.info),
        _colorItem(AppColors.success),
        _colorItem(AppColors.warning),
        _colorItem(AppColors.error),
        _colorItem(AppColors.priorityMedium),
        _colorItem(AppColors.priorityHigh),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Projet temporaire pour l'aperçu en temps réel
    final previewProject = Project(
      id: "preview",
      userId: "preview_user",
      name: _nameController.text.isEmpty ? "Nom du projet" : _nameController.text,
      description: _descriptionController.text.isEmpty ? "Description du projet" : _descriptionController.text,
      color: _selectedColor,
      createdDate: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Modifier le projet" : "Nouveau projet"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Nom du projet (Obligatoire, min 3 car.)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom du projet",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}), // Pour rafraîchir l'aperçu
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return "Nom obligatoire";
                  if (value.trim().length < 3) return "Minimum 3 caractères";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              /// Description (Multiligne, optionnel)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}), // Pour rafraîchir l'aperçu
              ),
              const SizedBox(height: 25),

              /// Sélecteur de couleur
              const Text(
                "Couleur du projet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _buildColorSelector(),

              const SizedBox(height: 35),

              /// Aperçu en temps réel avec ProjectCard
              const Text(
                "Aperçu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ProjectCard(
                project: previewProject,
                taskCount: 0, // Paramètre requis corrigé
              ),

              const SizedBox(height: 40),

              /// Bouton de validation
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saveProject,
                  child: Text(
                    isEdit ? "Enregistrer les modifications" : "Créer le projet",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}