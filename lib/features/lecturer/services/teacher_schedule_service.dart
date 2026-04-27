import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/constants/api_endpoints.dart';

class TeacherScheduleService {
  final Future<Map<String, String>> Function()? authHeaders;

  TeacherScheduleService({
    this.authHeaders,
  });

  Future<Map<String, dynamic>> markAsDone(int scheduleDetailId) async {
    final url = Uri.parse('${ApiEndpoints.teacherScheduleDetails}$scheduleDetailId/attendance',);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authHeaders != null) ...(await authHeaders!()),
    };

    final res = await http.put(url, headers: headers, body: jsonEncode({}));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }

  Future<Map<String, dynamic>> requestClassCancel({
    required int detailId,
    required String reason,
    String? fileUrl,
  }) async {
    final url = Uri.parse(ApiEndpoints.teacherClassCancel);
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
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.body.isEmpty ? <String, dynamic>{} : json.decode(res.body);
    }
    throw Exception('HTTP ${res.statusCode}: ${res.body}');
  }
}
