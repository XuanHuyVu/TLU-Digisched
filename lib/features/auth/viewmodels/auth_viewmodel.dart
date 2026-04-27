import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/models/user_entity.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  UserEntity? _user;
  bool get isLoggedIn => _user != null;
  UserEntity? get user => _user;
  bool get isTeacher => _user?.role == 'LECTURER';
  bool get isStudent => _user?.role == 'STUDENT';
  Future<void> login(String email, String password) async {
    try {
      final u = await AuthService.login(email, password);
      _user = u;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');
    final role = prefs.getString('role');
    final id = prefs.getInt('id');
    if (token != null && username != null && role != null && id != null) {
      _user = UserEntity(
        username: username,
        token: token,
        role: role,
        id: id,
      );
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('id');
    notifyListeners();
  }
}


