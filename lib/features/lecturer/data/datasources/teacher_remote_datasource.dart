import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../../config/constants/api_endpoints.dart';

class TeacherRemoteDataSource {
  final http.Client _client;

  TeacherRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();

    if (token == null) {
      throw Exception('Không tìm thấy token, vui lòng đăng nhập lại');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // TODO: Temporarily commented out - statistics endpoint not ready
  // Future<Map<String, dynamic>> fetchHomeData(int teacherId) async {
  //   try {
  //     final headers = await _getHeaders();
  //     final uri = Uri.parse('${ApiEndpoints.baseUrl}/lecturer/schedules/statistics');

  //     final response = await _client
  //         .get(uri, headers: headers)
  //         .timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       return data['data'] ?? {};
  //     } else {
  //       throw Exception('Failed to load statistics: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Không thể tải thống kê: $e');
  //   }
  // }

  Future<List<Map<String, dynamic>>> fetchScheduleEntries(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/lecturer/schedules/$scheduleId/entries');

      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final entries = data['data'] ?? [];
        return List<Map<String, dynamic>>.from(entries);
      } else {
        throw Exception('Failed to load entries: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải chi tiết lịch dạy: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchScheduleDetails(int entryId) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/lecturer/schedules/entries/$entryId/schedule-details');
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final details = data['data'] ?? [];
        return List<Map<String, dynamic>>.from(details);
      } else {
        throw Exception('Failed to load schedule details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải lịch dạy chi tiết: $e');
    }
  }

  Future<void> markScheduleAsDone(int scheduleDetailId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiEndpoints.teacherScheduleDetails}$scheduleDetailId/attendance',);
      final response = await _client
          .put(url, headers: headers, body: jsonEncode({}))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (kDebugMode) {
          print('✅ Schedule marked as done');
        }
      } else {
        throw Exception('Failed to mark as done: ${response.statusCode}');
      }
    } catch (ex) {
      throw Exception('Không thể đánh dấu làm xong: $ex');
    }
  }

  Future<void> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(ApiEndpoints.teacherClassCancel);

      if (kDebugMode) {
        print('📡 Requesting class cancel: $url');
      }

      final body = jsonEncode({
        'teachingScheduleDetailId': detailId,
        'reason': reason,
        if (fileUrl != null && fileUrl.isNotEmpty) 'fileUrl': fileUrl,
      });

      final response = await _client
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (kDebugMode) {
          print('✅ Class cancel requested');
        }
      } else {
        throw Exception('Failed to request cancel: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      throw Exception('Không thể yêu cầu hủy lớp: $e');
    }
  }
}
