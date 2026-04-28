import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/config/constants/constants.dart';
import '../../../../core/utils/token_validator.dart';
import '../../domain/entities/user.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();
  Future<String?> getToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  AuthLocalDataSourceImpl({required this.sharedPreferences});
  static const String _tokenKey = Constants.token;
  static const String _usernameKey = Constants.userName;
  static const String _roleKey = Constants.role;
  static const String _idKey = Constants.id;

  @override
  Future<void> saveUser(User user) async {
    await sharedPreferences.setString(_tokenKey, user.token);
    await sharedPreferences.setString(_usernameKey, user.username);
    await sharedPreferences.setString(_roleKey, user.role);
    await sharedPreferences.setInt(_idKey, user.id);
  }

  @override
  Future<User?> getUser() async {
    final token = sharedPreferences.getString(_tokenKey);
    final username = sharedPreferences.getString(_usernameKey);
    final role = sharedPreferences.getString(_roleKey);
    final id = sharedPreferences.getInt(_idKey);
    if (token != null && username != null && role != null && id != null) {
      if (!TokenValidator.isTokenValid(token)) {
        await clearUser();
        return null;
      }
      return User(username: username, token: token, role: role, id: id);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_usernameKey);
    await sharedPreferences.remove(_roleKey);
    await sharedPreferences.remove(_idKey);
  }

  @override
  Future<String?> getToken() async {
    return sharedPreferences.getString(_tokenKey);
  }
}
