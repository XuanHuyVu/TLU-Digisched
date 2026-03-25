// lib/core/constants/constants.dart

class AppConst {
  static const String baseUrl = 'http://10.0.2.2:8080/api/'; // có dấu / ở cuối

  // KHÔNG có dấu "/" đầu
  static String teacherSchedules(int teacherId) =>
      'teacher/schedules/$teacherId';
}

/// Ánh xạ TIẾT -> KHUNG GIỜ
const Map<int, String> tietToTime = {
  1:  "07:00 - 07:50",
  2:  "07:55 - 08:45",
  3:  "08:50 - 09:40",
  4:  "09:45 - 10:35",
  5:  "10:40 - 11:30",
  6:  "11:35 - 12:25",
  7:  "12:55 - 13:45",
  8:  "13:50 - 14:40",
  9:  "14:45 - 15:35",
  10: "15:40 - 16:30",
  11: "16:35 - 17:25",
  12: "17:30 - 18:20",
  13: "18:50 - 19:40",
  14: "19:45 - 20:35",
  15: "20:40 - 21:30",
};

/// Lấy số tiết từ chuỗi kiểu "Tiết 1", "T1", "1", ...
int extractPeriodNumber(String? raw) {
  if (raw == null) return 0;
  final m = RegExp(r'\d+').firstMatch(raw);
  return m == null ? 0 : int.tryParse(m.group(0)!) ?? 0;
}

/// "HH:mm - HH:mm" theo tiết bắt đầu/kết thúc
String periodTimeRange(int start, int end) {
  final s = tietToTime[start];
  final e = tietToTime[end];
  if (s == null || e == null) return "—";
  final startHHmm = s.split(' - ').first;
  final endHHmm   = e.split(' - ').last;
  return "$startHHmm - $endHHmm";
}

/// Header ví dụ: "Tiết 1 → 3 (07:00 - 09:40)"
String buildPeriodHeader({int? start, int? end, String? fallback}) {
  if (start != null && end != null) {
    return 'Tiết $start → $end (${periodTimeRange(start, end)})';
  }
  return fallback ?? '—';
}

/// Format dd/MM/yyyy (không cần intl)
String _two(int n) => n.toString().padLeft(2, '0');
String formatDdMMyyyy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// Format YYYY-MM-DD (nếu cần)
extension DateX on DateTime {
  String toYMD() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }
}
