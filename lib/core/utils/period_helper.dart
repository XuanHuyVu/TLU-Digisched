import '../../config/constants/constants.dart';

// ✅ Tối ưu: Cache regex as static final
final _periodNumberRegex = RegExp(r'\d+');

int extractPeriodNumber(String? raw) {
  if (raw == null) return 0;
  final match = _periodNumberRegex.firstMatch(raw);
  return match == null ? 0 : int.tryParse(match.group(0)!) ?? 0;
}

// ✅ Tối ưu: Cache parsed time ranges để không split mỗi lần
final Map<String, (String, String)> _timeRangeCache = {};

String periodTimeRange(int start, int end) {
  final s = Constants.timeOfPeriod[start];
  final e = Constants.timeOfPeriod[end];
  if (s == null || e == null) return "—";
  
  // Cache start time
  final startKey = 'start_$start';
  if (!_timeRangeCache.containsKey(startKey)) {
    final parts = s.split(' - ');
    _timeRangeCache[startKey] = (parts.first, parts.last);
  }
  
  // Cache end time
  final endKey = 'end_$end';
  if (!_timeRangeCache.containsKey(endKey)) {
    final parts = e.split(' - ');
    _timeRangeCache[endKey] = (parts.first, parts.last);
  }
  
  final startHHmm = _timeRangeCache[startKey]!.$1;
  final endHHmm = _timeRangeCache[endKey]!.$2;
  return "$startHHmm - $endHHmm";
}

String buildPeriodHeader({int? start, int? end, String? fallback,}) {
  if (start != null && end != null) {
    return 'Tiết $start → $end (${periodTimeRange(start, end)})';
  }
  return fallback ?? '—';
}