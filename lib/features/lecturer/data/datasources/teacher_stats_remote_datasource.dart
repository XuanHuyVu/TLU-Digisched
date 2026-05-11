import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../../config/constants/api_endpoints.dart';
import '../../../../config/constants/constants.dart';
import '../models/lecturer_statistics_model.dart';

class TeacherStatsRemoteDataSource {
  final http.Client _client;

  TeacherStatsRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.token);
  }

  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Constants.id);
  }

  Future<LecturerStatisticsModel> getStats({int? semesterId}) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      final userId = await _getUserId();
      if (userId == null) throw Exception('Không tìm thấy thông tin người dùng.');
      final queryParams = {'lecturerId': userId.toString()};
      if (semesterId != null) queryParams['semesterId'] = semesterId.toString();
      final uri = Uri.parse(ApiEndpoints.lecturerStatistics).replace(queryParameters: queryParams,);
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
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'];
        return LecturerStatisticsModel.fromJson(data);
      } else {
        throw Exception('Lỗi tải thống kê: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể tải thống kê: $e');
    }
  }
}
