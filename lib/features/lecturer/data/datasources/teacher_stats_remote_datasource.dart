// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import '../../../../config/constants/api_endpoints.dart';
//
// class TeacherStatsRemoteDataSource {
//   final http.Client _client;
//
//   TeacherStatsRemoteDataSource({http.Client? client})
//     : _client = client ?? http.Client();
//
//   static Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   Future<Map<String, dynamic>> getStats() async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
//       }
//
//       final uri = Uri.parse(ApiEndpoints.teacherStats);
//
//       if (kDebugMode) {
//         print('📡 Fetching stats from: $uri');
//       }
//
//       final response = await _client
//           .get(
//             uri,
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 15));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (kDebugMode) {
//           print('✅ Stats loaded successfully');
//         }
//         return data;
//       } else {
//         throw Exception('Lỗi tải thống kê: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('❌ Error: $e');
//       }
//       throw Exception('Không thể tải thống kê: $e');
//     }
//   }
// }
