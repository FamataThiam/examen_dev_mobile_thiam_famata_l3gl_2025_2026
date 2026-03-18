import 'dart:ui';

class Project {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final Color color;
  final DateTime createdDate;

  Project({
    required this.id,
    required this.name,
    required this.userId,
    this.description,
    required this.color,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  Project copyWith({
    String? id,
    String? name,
    String? userId,
    String? description,
    Color? color,
    DateTime? createdDate,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      color: color ?? this.color,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'description': description,
      'color': color.value,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      userId: map['userId'] as String,
      description: map['description'] as String?,
      color: Color(map['color'] as int),
      createdDate: DateTime.parse(map['createdDate'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Project && other.id == id);

  @override
  int get hashCode => id.hashCode;
}