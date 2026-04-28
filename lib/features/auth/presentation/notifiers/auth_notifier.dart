import 'package:flutter/material.dart';
import '../../../../core/utils/token_validator.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_token_usecase.dart';
import '../../domain/usecases/load_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

class AuthNotifier extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final LoadUserUseCase loadUserUseCase;
  final GetTokenUseCase getTokenUseCase;

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isTokenValid = false;

  AuthNotifier({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.loadUserUseCase,
    required this.getTokenUseCase,
  });

  User? get user => _user;
  bool get isLoggedIn => _user != null && _isTokenValid;
  bool get isTeacher => _user?.role == 'LECTURER';
  bool get isStudent => _user?.role == 'STUDENT';
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTokenValid => _isTokenValid;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _isTokenValid = true;
    notifyListeners();
    try {
      _user = await loginUseCase(email, password);
      if (_user != null) _isTokenValid = TokenValidator.isTokenValid(_user!.token);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
      _isTokenValid = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserFromStorage() async {
    try {
      _user = await loadUserUseCase();
      if (_user != null && _user!.token.isNotEmpty) {
        _isTokenValid = TokenValidator.isTokenValid(_user!.token);
        if (!_isTokenValid) {
          _user = null;
          await logoutUseCase();
        } else {
          if (TokenValidator.isTokenExpiringSoon(_user!.token)) {
            debugPrint('⚠️ Token expiring soon!');
          }
        }
      }
    } catch (e) {
      _user = null;
      _isTokenValid = false;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await logoutUseCase();
      _user = null;
      _isTokenValid = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    return await getTokenUseCase();
  }

  bool isTokenExpiringSoon({int minutesBefore = 5}) {
    if (_user == null) return false;
    return TokenValidator.isTokenExpiringSoon(
      _user!.token,
      minutesBefore: minutesBefore,
    );
  }
}
