import '../extensions/extensions.dart';

class Constants {
  static const String baseUrl = 'http://192.168.100.79:8080/api/v1';
}

int extractPeriodNumber(String? raw) {
  if (raw == null) return 0;
  final m = RegExp(r'\d+').firstMatch(raw);
  return m == null ? 0 : int.tryParse(m.group(0)!) ?? 0;
}

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
