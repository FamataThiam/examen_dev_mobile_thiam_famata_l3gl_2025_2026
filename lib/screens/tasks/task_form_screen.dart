import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Project.dart';
import '../../models/Task.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Project project;
  final Task? task; // null = création, non-null = modification

  const TaskFormScreen({super.key, required this.project, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  late TaskStatus _selectedStatus;
  late TaskPriority _selectedPriority;
  DateTime? _selectedDate;

  final TaskProvider _taskProvider = TaskProvider();
  final AuthProvider _authProvider = AuthProvider();

  bool get isEdit => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description ?? '';
      _selectedStatus = widget.task!.status;
      _selectedPriority = widget.task!.priority;
      _selectedDate = widget.task!.dueDate;
    } else {
      _selectedStatus = TaskStatus.todo;
      _selectedPriority = TaskPriority.medium;
    }
  }

  /// Sélecteur de date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Widget de sélection pour Statut/Priorité
  Widget _buildSelectableItem(String label, Color color, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _authProvider.currentUser?.id;
    if (userId == null) return;

    final task = Task(
      id: isEdit ? widget.task!.id : const Uuid().v4(),
      projectId: widget.project.id,
      userId: userId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _selectedDate,
      createdDate: isEdit ? widget.task!.createdDate : DateTime.now(),
    );

    isEdit ? await _taskProvider.updateTask(task) : await _taskProvider.createTask(task);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? AppStrings.editTask : AppStrings.newTask)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: AppStrings.taskTitle, border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? AppStrings.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: AppStrings.taskDescription, border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              const Text(AppStrings.taskStatus, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSelectableItem(AppStrings.statusTodo, AppColors.statusTodo, _selectedStatus == TaskStatus.todo, () => setState(() => _selectedStatus = TaskStatus.todo)),
                  const SizedBox(width: 8),
                  _buildSelectableItem(AppStrings.statusInProgress, AppColors.statusInProgress, _selectedStatus == TaskStatus.inProgress, () => setState(() => _selectedStatus = TaskStatus.inProgress)),
                  const SizedBox(width: 8),
                  _buildSelectableItem(AppStrings.statusDone, AppColors.statusDone, _selectedStatus == TaskStatus.done, () => setState(() => _selectedStatus = TaskStatus.done)),
                ],
              ),

              const SizedBox(height: 20),
              const Text(AppStrings.taskPriority, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSelectableItem(AppStrings.priorityHigh, AppColors.priorityHigh, _selectedPriority == TaskPriority.high, () => setState(() => _selectedPriority = TaskPriority.high)),
                  const SizedBox(width: 8),
                  _buildSelectableItem(AppStrings.priorityMedium, AppColors.priorityMedium, _selectedPriority == TaskPriority.medium, () => setState(() => _selectedPriority = TaskPriority.medium)),
                  const SizedBox(width: 8),
                  _buildSelectableItem(AppStrings.priorityLow, AppColors.priorityLow, _selectedPriority == TaskPriority.low, () => setState(() => _selectedPriority = TaskPriority.low)),
                ],
              ),

              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                title: Text(_selectedDate == null ? AppStrings.taskDueDate : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
                tileColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: AppColors.border)),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.all(15)),
                  onPressed: _save,
                  child: const Text(AppStrings.save, style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}