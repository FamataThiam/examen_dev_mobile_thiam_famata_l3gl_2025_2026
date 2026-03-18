import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../core/constants/app_colors.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isAuthor;
  final VoidCallback? onDelete;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.isAuthor,
    this.onDelete,
  }) : super(key: key);

  /// Retourne une date relative : "il y a X min", "il y a X h", "hier", ou "jj/mm/aaaa"
  String _relativeDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "il y a ${diff.inHours} h";
    if (diff.inDays == 1) return "hier";

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              comment.userName.isNotEmpty
                  ? comment.userName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Contenu
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + date
                  Row(
                    children: [
                      Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _relativeDate(comment.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Bouton suppression (auteur uniquement)
                      if (isAuthor && onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: AppColors.error,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Contenu du commentaire
                  Text(
                    comment.content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}