import 'package:flutter/cupertino.dart';
import 'package:sunu_task/models/User.dart';

class AuthProvider extends ChangeNotifier{
  // Propriétés privées
  User? _currentUser;
  bool _isLoading = false;
  String? _error;



}