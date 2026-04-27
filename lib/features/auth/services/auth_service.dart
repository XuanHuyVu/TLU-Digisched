import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/core/constants/constants.dart';
import 'package:tlu_digisched/shared/models/user_entity.dart';

class AuthService {
  static const _authKeys = ['token', 'username', 'role', 'id'];

  static Future<void> _clearAuthKeys(SharedPreferences prefs) async {
    for (final key in _authKeys) {
      await prefs.remove(key);
    }
  }

  static Future<UserEntity> login(String email, String password) async {
    final uri = Uri.parse('${Constants.baseUrl}/auth/login');

    try {
      debugPrint('🔐 Login request to: $uri');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      debugPrint('🔐 Login response status: ${response.statusCode}');
      debugPrint('🔐 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['data']?['accessToken'] as String?;
        if (accessToken == null) throw Exception('No access token in response');

        final decodedToken = JwtDecoder.decode(accessToken);
        debugPrint('🔐 Decoded token: $decodedToken');
        
        final uid = decodedToken['uid'] as int?;
        final role = decodedToken['role'] as String?;
        final userEmail = decodedToken['sub'] as String?;

        if (uid == null || role == null || userEmail == null) {
          throw Exception('Invalid token structure');
        }

        final user = UserEntity(
          username: userEmail,
          token: accessToken,
          role: role,
          id: uid,
        );

        final prefs = await SharedPreferences.getInstance();
        await _clearAuthKeys(prefs);
        await prefs.setString('token', user.token);
        await prefs.setString('username', user.username);
        await prefs.setString('role', user.role);
        await prefs.setInt('id', user.id);

        debugPrint('🔐 Login successful! User: ${user.username}, Role: ${user.role}');
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Connection timeout. Please check your network and try again.');
    } catch (e) {
      debugPrint('❌ Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  static Future<UserEntity?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final username = prefs.getString('username');
      final role = prefs.getString('role');
      final id = prefs.getInt('id');

      if (token == null || username == null || role == null || id == null) {
        return null;
      }

      return UserEntity(
        username: username,
        token: token,
        role: role,
        id: id,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearAuthKeys(prefs);
    } catch (e) {
      rethrow;
    }
  }
}
