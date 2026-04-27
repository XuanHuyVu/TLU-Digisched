import '../../config/constants/constants.dart';

int extractPeriodNumber(String? raw) {
  if (raw == null) return 0;
  final match = RegExp(r'\d+').firstMatch(raw);
  return match == null ? 0 : int.tryParse(match.group(0)!) ?? 0;
}

String periodTimeRange(int start, int end) {
  final s = Constants.timeOfPeriod[start];
  final e = Constants.timeOfPeriod[end];
  if (s == null || e == null) return "—";
  final startHHmm = s.split(' - ').first;
  final endHHmm = e.split(' - ').last;
  return "$startHHmm - $endHHmm";
}

String buildPeriodHeader({int? start, int? end, String? fallback,}) {
  if (start != null && end != null) {
    return 'Tiết $start → $end (${periodTimeRange(start, end)})';
  }
  return fallback ?? '—';
}