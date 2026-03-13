import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/Task.dart';
import '../../models/Project.dart';
import '../../providers/task_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/cards/comment_card.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Project project;

  const TaskDetailScreen({super.key, required this.task, required this.project});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final CommentProvider _commentProvider = CommentProvider();
  final TaskProvider _taskProvider = TaskProvider();
  final AuthProvider _authProvider = AuthProvider();

  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _commentProvider.loadComments(widget.task.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    final user = _authProvider.currentUser;
    if (user == null) return;

    _commentController.clear();

    await _commentProvider.addComment(
      widget.task.id,
      user.id,
      user.name,
      content,
    );

    // Scroller vers le haut (commentaires triés du plus récent au plus ancien)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return AppColors.priorityHigh;
      case TaskPriority.medium: return AppColors.priorityMedium;
      case TaskPriority.low: return AppColors.priorityLow;
    }
  }

  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo: return AppColors.statusTodo;
      case TaskStatus.inProgress: return AppColors.statusInProgress;
      case TaskStatus.done: return AppColors.statusDone;
    }
  }

  String _statusLabel(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo: return AppStrings.statusTodo;
      case TaskStatus.inProgress: return AppStrings.statusInProgress;
      case TaskStatus.done: return AppStrings.statusDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final currentUserId = _authProvider.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Détail de la tâche"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(
                    project: widget.project,
                    task: task,
                  ),
                ),
              );
              _taskProvider.loadTasks(widget.project.id);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Infos de la tâche ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(task.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _statusLabel(task.status),
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Badge priorité
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _priorityColor(task.priority).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _priorityColor(task.priority)),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: TextStyle(
                          color: _priorityColor(task.priority),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        "${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    task.description!,
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),

          // ── Section commentaires ───────────────────────────────
          Expanded(
            child: ListenableBuilder(
              listenable: _commentProvider,
              builder: (context, _) {
                final comments = _commentProvider.comments;

                return Column(
                  children: [
                    // En-tête commentaires
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Text(
                            "Commentaires",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${_commentProvider.commentCount}",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste des commentaires
                    Expanded(
                      child: _commentProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : comments.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            const Text(
                              "Aucun commentaire",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                          : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return CommentCard(
                            comment: comment,
                            isAuthor: comment.userId == currentUserId,
                            onDelete: () => _commentProvider.deleteComment(comment.id),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Formulaire d'ajout ─────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ListenableBuilder(
              listenable: _commentController,
              builder: (context, _) {
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Écrire un commentaire…",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Bouton envoi — désactivé si champ vide
                    AnimatedOpacity(
                      opacity: _commentController.text.trim().isEmpty ? 0.4 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                          onPressed: _commentController.text.trim().isEmpty ? null : _sendComment,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}