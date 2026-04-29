import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/constants/constants.dart';
import '../config/constants/api_endpoints.dart';

class ApiService {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.token);
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> getJson(String path) async {
    final res = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}$path'),
      headers: await _headers(),
    );
    
    if (res.statusCode == 401) {
      debugPrint('❌ 401 Unauthorized - Token expired or invalid');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.token);
      await prefs.remove(Constants.user);
      throw Exception('Token đã hết hạn hoặc không hợp lệ. Vui lòng đăng nhập lại.');
    }
    
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    
    throw Exception('GET $path failed ${res.statusCode}: ${res.body}');
  }
}
