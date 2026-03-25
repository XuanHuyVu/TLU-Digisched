// lib/core/constants/constants.dart

import '../../features/student/models/student_schedule_model.dart';

/// Tiện ích format ngày YYYY-MM-DD
extension DateX on DateTime {
  String toYMD() {
    final mm = month.toString().padLeft(2, '0');
    final dd = day.toString().padLeft(2, '0');
    return '$year-$mm-$dd';
  }
}

/// Ánh xạ TIẾT -> "HH:mm - HH:mm"
/// (Bạn chỉnh lại slot 13 nếu trường có khung giờ khác)
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
  13: "18:50 - 19:40", // <-- nếu muốn theo bản khác: "18:25 - 19:15"
  14: "19:45 - 20:35",
  15: "20:40 - 21:30",
};

/// Lấy số tiết từ chuỗi kiểu "Tiết 1", "Tiet 7", "T1", "1", ...
int extractPeriodNumber(String? raw) {
  if (raw == null) return 0;
  final m = RegExp(r'\d+').firstMatch(raw);
  return m == null ? 0 : int.tryParse(m.group(0)!) ?? 0;
}

/// Trả về "HH:mm - HH:mm" theo tiết bắt đầu/kết thúc.
/// Trả về "" nếu không map được.
String periodTimeRange(int start, int end) {
  final s = tietToTime[start];
  final e = tietToTime[end];
  if (s == null || e == null) return "";
  final startHHmm = s.split('-').first.trim(); // "HH:mm"
  final endHHmm   = e.split('-').last.trim();  // "HH:mm"
  return "$startHHmm - $endHHmm";
}

/// Format dd/MM/yyyy (không cần intl)
String _two(int n) => n.toString().padLeft(2, '0');
String formatDdMMyyyy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

extension StudentScheduleExtension on StudentScheduleModel {
  String get vietnameseType {
    switch (type) {
      case "LY_THUYET":
        return "Lý thuyết";
      case "THUC_HANH":
        return "Thực hành";
      default:
        return "Khác";
    }
  }
}