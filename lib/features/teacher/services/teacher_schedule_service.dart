import 'dart:convert';
import 'package:http/http.dart' as http;

class TeacherScheduleService {
  final String baseUrl;
  final Future<Map<String, String>> Function()? authHeaders;

  TeacherScheduleService({
    this.baseUrl = 'http://10.0.2.2:8080',
    this.authHeaders,
  });

  /// Đánh dấu điểm danh (Hoàn thành)
  Future<Map<String, dynamic>> markAsDone(int scheduleDetailId) async {
    final url = Uri.parse(
      '$baseUrl/api/teacher/teaching-schedule-details/$scheduleDetailId/attendance',
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authHeaders != null) ...(await authHeaders!()),
    };

    final res = await http.put(url, headers: headers, body: jsonEncode({}));
    // ignore: avoid_print
    print('[PUT] $url -> ${res.statusCode} ${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  /// Gửi yêu cầu NGHỈ DẠY
  Future<Map<String, dynamic>> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/teacher/class-cancel');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authHeaders != null) ...(await authHeaders!()),
    };

    final body = jsonEncode({
      'teachingScheduleDetailId': detailId,
      'reason': reason,
      if (fileUrl != null && fileUrl.isNotEmpty) 'fileUrl': fileUrl,
    });

    final res = await http.post(url, headers: headers, body: body);
    // ignore: avoid_print
    print('[POST] $url -> ${res.statusCode} ${res.body}');
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
