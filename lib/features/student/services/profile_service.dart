import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tlu_digisched/config/constants/api_endpoints.dart';
import '../../../config/constants/constants.dart';
import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.token);
    if (token == null) throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
    final uri = Uri.parse(ApiEndpoints.studentProfile);
    final response = await http.get(uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonObject = jsonDecode(utf8.decode(response.bodyBytes));
      return ProfileModel.fromJson(jsonObject);
    } else {
      throw Exception('Lỗi tải profile: ${response.statusCode} - ${response.body}');
    }
  }
}