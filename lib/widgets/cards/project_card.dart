import 'package:flutter/material.dart';
import '../../models/Project.dart';


class ProjectCard extends StatelessWidget {

  final Project project;
  final int taskCount;
  final VoidCallback? onTap; // callback pour la navigation
  final void Function(Project)? onEdit; // callback modifier
  final void Function(Project)? onDelete; // callback supprimer


  const ProjectCard({
    Key? key,
    required this.project,
    required this.taskCount,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: project.color,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 12),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      '$taskCount tâches',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),


              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    if (onEdit != null) onEdit!(project);
                  } else if (value == 'delete') {
                    if (onDelete != null) onDelete!(project);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Modifier'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}