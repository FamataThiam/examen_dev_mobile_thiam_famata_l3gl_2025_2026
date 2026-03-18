import 'package:flutter/material.dart';

enum TaskStatus { todo, inProgress, done }

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String projectId;
  final String userId;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdDate;

  Task({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  // ======== copyWith =========
  Task copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdDate,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  // ======== Sérialisation =========
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.name,           // ex: "todo", "inProgress", "done"
      'priority': priority.name,       // ex: "high", "medium", "low"
      'dueDate': dueDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      status: TaskStatus.values.firstWhere(
            (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdDate: DateTime.parse(map['createdDate'] as String),
    );
  }

  // ======== Égalité =========
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Task(id: $id, title: $title, status: ${status.name}, priority: ${priority.name})';
  }
}