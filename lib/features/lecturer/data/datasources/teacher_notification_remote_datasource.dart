import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../config/constants/api_endpoints.dart';

class TeacherNotificationRemoteDataSource {
  final http.Client _client;

  TeacherNotificationRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final uri = Uri.parse(ApiEndpoints.teacherNotifications);
      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        if (kDebugMode) {
          print('✅ Notifications loaded: ${jsonList.length} items');
        }
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Lỗi tải thông báo: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      throw Exception('Không thể tải thông báo: $e');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      final uri = Uri.parse(
        '${ApiEndpoints.teacherNotificationsRead}$notificationId',
      );

      if (kDebugMode) {
        print('📡 Marking notification as read: $uri');
      }

      final response = await _client
          .put(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Đánh dấu đã đọc thất bại: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('✅ Notification marked as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      throw Exception('Không thể đánh dấu đã đọc: $e');
    }
  }
}
