import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../config/constants/api_endpoints.dart';
import '../../../../core/utils/token_validator.dart';

class TeacherProfileRemoteDataSource {
  final http.Client _client;

  TeacherProfileRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    if (token == null) throw Exception('Không tìm thấy token, vui lòng đăng nhập lại');
    if (!TokenValidator.isTokenValid(token)) throw Exception('Token đã hết hạn, vui lòng đăng nhập lại');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(ApiEndpoints.teacherProfile);
      final response = await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          final data = responseData['data'];
          return data as Map<String, dynamic>;
        } else {
          return responseData as Map<String, dynamic>;
        }
      } else {
        String errorMessage = 'Không thể tải profile: ${response.statusCode}';
        final errorData = jsonDecode(response.body);
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message']?.toString() ?? errorMessage;
          if (errorData.containsKey('error')) {
            errorMessage += ' - ${errorData['error']}';
          }
        }
        throw Exception(errorMessage);
      }
    } catch (ex) {
      throw Exception('Không thể tải profile: $ex');
    }
  }
}
