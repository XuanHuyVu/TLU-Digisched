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
      _error = _extractErrorMessage(e.toString());
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
          debugPrint('❌ Token is expired or invalid');
          _user = null;
          await logoutUseCase();
        } else {
          debugPrint('✅ Token is valid');
          if (TokenValidator.isTokenExpiringSoon(_user!.token)) {
            debugPrint('⚠️ Token expiring soon!');
          }
        }
      } else {
        debugPrint('❌ No user or empty token found in storage');
        _user = null;
        _isTokenValid = false;
      }
    } catch (e) {
      debugPrint('❌ Error loading user from storage: $e');
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

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(String errorString) {
    // Remove "Exception: " prefix if present
    String message = errorString.replaceFirst('Exception: ', '');
    
    // Check for specific error patterns
    if (message.contains('Connection timeout')) {
      return 'Kết nối timeout. Vui lòng kiểm tra kết nối mạng và thử lại.';
    }
    
    if (message.contains('Failed host lookup') || 
        message.contains('Network is unreachable')) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }
    
    if (message.contains('Connection refused')) {
      return 'Server không phản hồi. Vui lòng thử lại sau.';
    }
    
    if (message.contains('Invalid token structure') || 
        message.contains('No access token')) {
      return 'Lỗi server. Vui lòng liên hệ quản trị viên.';
    }
    
    if (message.contains('Sai tài khoản') || 
        message.contains('Sai mật khẩu') ||
        message.contains('Invalid credentials') ||
        message.contains('Unauthorized')) {
      return 'Sai tài khoản hoặc mật khẩu.';
    }
    
    // Default message for other errors
    return message.isNotEmpty ? message : 'Lỗi đăng nhập. Vui lòng thử lại.';
  }
}
