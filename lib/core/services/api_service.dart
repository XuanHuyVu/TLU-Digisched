// lib/core/services/api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Dùng 10.0.2.2 cho Android emulator, localhost cho web
  static String get baseUrl => kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> getJson(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body);
    }
    throw Exception('GET $path failed ${res.statusCode}: ${res.body}');
  }
}
