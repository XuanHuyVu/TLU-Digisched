import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/core/constants/constants.dart';
import 'package:tlu_digisched/features/student/models/notification_model.dart';

class NotificationService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }

    final uri = Uri.parse('${Constants.baseUrl}/api/student/notifications');
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi tải thông báo: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    }

    final uri = Uri.parse('${Constants.baseUrl}/api/student/notifications/read/$notificationId');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Đánh dấu đã đọc thất bại: ${response.statusCode} - ${response.body}');
    }

  }

}
