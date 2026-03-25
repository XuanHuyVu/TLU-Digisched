import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher_profile_model.dart';

class TeacherProfileService {
  final http.Client _client;

  TeacherProfileService({http.Client? client}) : _client = client ?? http.Client();

  /// Base URL configuration, aligned with AuthService
  static String get baseUrl => kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

  /// Prepare headers with token
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();

    if (kDebugMode) {
      print('🔍 Đang lấy token cho yêu cầu profile:');
      print('   - Token tồn tại: ${token != null}');
      print('   - Độ dài token: ${token?.length ?? 0}');
      if (token != null && token.length > 20) {
        print('   - 20 ký tự đầu của token: ${token.substring(0, 20)}...');
      }
    }

    if (token == null) {
      throw Exception('Không tìm thấy token, vui lòng đăng nhập lại');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch teacher profile
  Future<TeacherProfile> getProfile() async {
    try {
      final headers = await _headers();
      final uri = Uri.parse('$baseUrl/api/teacher/profile');

      if (kDebugMode) {
        print('📡 Gửi yêu cầu profile tới: $uri');
        print('📋 Headers: $headers');
      }

      final response = await _client.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📨 Trạng thái response: ${response.statusCode}');
        print('📦 Nội dung response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Tải profile thành công');
        }
        return TeacherProfile.fromJson(data);
      } else {
        String errorMessage = 'Không thể tải profile: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['message']?.toString() ?? errorMessage;
            if (errorData.containsKey('error')) {
              errorMessage += ' - ${errorData['error']}';
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Lỗi khi parse response lỗi: $e');
          }
        }
        if (kDebugMode) {
          print('❌ Lỗi: $errorMessage');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('❌ Hết thời gian kết nối khi tải profile: $e');
      }
      throw Exception('Hết thời gian kết nối. Vui lòng kiểm tra mạng và thử lại.');
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('❌ Lỗi mạng khi tải profile: ${e.message}');
      }
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Lỗi không xác định khi tải profile: $e');
      }
      throw Exception('Không thể tải profile: ${e.toString()}');
    }
  }

  /// Dispose client if needed
  void dispose() {
    _client.close();
  }
}