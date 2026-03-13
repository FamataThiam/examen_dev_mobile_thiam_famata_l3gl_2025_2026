import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/comment.dart';
import '../services/storage_service.dart';

class CommentProvider extends ChangeNotifier {
  // ===============================
  // SINGLETON
  // ===============================
  static final CommentProvider instance = CommentProvider._internal();
  CommentProvider._internal();
  factory CommentProvider() => instance;

  // ===============================
  List<Comment> _comments = [];
  bool _isLoading = false;

  /// Triés du plus récent au plus ancien
  List<Comment> get comments =>
      List.unmodifiable([..._comments]..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

  int get commentCount => _comments.length;
  bool get isLoading => _isLoading;

  Future<void> loadComments(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await StorageService.instance.getCommentsByTaskId(taskId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComment(
      String taskId, String userId, String userName, String content) async {
    _isLoading = true;
    notifyListeners();

    try {
      final comment = Comment(
        id: const Uuid().v4(),
        taskId: taskId,
        userId: userId,
        userName: userName,
        content: content,
        createdAt: DateTime.now(),
      );
      await StorageService.instance.saveComment(comment);
      _comments.add(comment);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await StorageService.instance.deleteComment(commentId);
      _comments.removeWhere((c) => c.id == commentId);
      notifyListeners();
    } catch (_) {}
  }
}