import '../../../core/extensions/extensions.dart';

/// Có thêm 'expired' để hiển thị UI
enum ScheduleStatus { upcoming, ongoing, done, canceled, expired, unknown }

// ===== Helpers map status <-> API =====
ScheduleStatus statusFromApi(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'DA_DAY':
    case 'DONE':
      return ScheduleStatus.done;
    case 'NGHI_DAY':
    case 'CANCELED':
    case 'CANCELLED':
      return ScheduleStatus.canceled;
    case 'DANG_DAY':
    case 'ONGOING':
      return ScheduleStatus.ongoing;
    case 'SAP_DAY':
    case 'UPCOMING':
      return ScheduleStatus.upcoming;
    case 'QUA_GIO':
    case 'EXPIRED':
      return ScheduleStatus.expired;
    default:
      return ScheduleStatus.unknown;
  }
}

String statusToApi(ScheduleStatus s) {
  switch (s) {
    case ScheduleStatus.done:
      return 'DA_DAY';
    case ScheduleStatus.canceled:
      return 'NGHI_DAY';
    case ScheduleStatus.ongoing:
      return 'DANG_DAY';
    case ScheduleStatus.upcoming:
      return 'SAP_DAY';
    case ScheduleStatus.expired:
    case ScheduleStatus.unknown:
    default:
      return 'UNKNOWN';
  }
}

class ScheduleModel {
  final int id;
  final DateTime? teachingDate;

  final String? periodStartRaw;
  final String? periodEndRaw;

  final int periodStart;
  final int periodEnd;

  final String type;
  final String subjectName;
  final String classCode;
  final String roomName;
  final String? chapter;
  final ScheduleStatus status;

  const ScheduleModel({
    required this.id,
    required this.teachingDate,
    required this.periodStartRaw,
    required this.periodEndRaw,
    required this.periodStart,
    required this.periodEnd,
    required this.type,
    required this.subjectName,
    required this.classCode,
    required this.roomName,
    required this.chapter,
    required this.status,
  });

  String get periodText {
    final a = periodStartRaw;
    final b = periodEndRaw;
    if ((a ?? '').isNotEmpty && (b ?? '').isNotEmpty) return '$a – $b';
    if (periodStart > 0 && periodEnd > 0) return 'Tiết $periodStart – Tiết $periodEnd';
    return '- – -';
  }

  String get timeRange {
    if (periodStart <= 0 || periodEnd <= 0) return '';
    return periodTimeRange(periodStart, periodEnd);
  }

  String get dateText => teachingDate == null ? '' : formatDdMMyyyy(teachingDate!);

  int get periodsCount =>
      (periodStart > 0 && periodEnd >= periodStart) ? (periodEnd - periodStart + 1) : 1;

  static DateTime? _parseDateFlexible(String? s) {
    if (s == null || s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(s);
    if (m != null) {
      return DateTime(
        int.parse(m.group(3)!),
        int.parse(m.group(2)!),
        int.parse(m.group(1)!),
      );
    }
    return null;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Fallback theo NGÀY nếu API không có:
  /// - Quá khứ -> expired
  /// - Hôm nay/tương lai -> upcoming (UI tự quyết ongoing/expired theo giờ)
  static ScheduleStatus _fallbackStatusByDate(DateTime? date) {
    if (date == null) return ScheduleStatus.unknown;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d.isBefore(today)) return ScheduleStatus.expired;
    return ScheduleStatus.upcoming;
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final date = _parseDateFlexible(json['teachingDate']?.toString());
    final psRaw = json['periodStart']?.toString();
    final peRaw = json['periodEnd']?.toString();
    final ps    = extractPeriodNumber(psRaw ?? json['periodStart']?.toString());
    final pe    = extractPeriodNumber(peRaw ?? json['periodEnd']?.toString());

    final subject   = (json['subjectName'] ?? '').toString();
    final classCode = (json['classCode'] ?? '').toString();
    final room      = (json['roomName'] ?? '').toString();
    final type      = (json['type'] ?? '').toString();
    final chapter   = json['chapter']?.toString();

    final id        = _toInt(json['id'] ?? json['detailId']);

    final stApi     = statusFromApi(json['status'] as String?);
    final st        = stApi == ScheduleStatus.unknown ? _fallbackStatusByDate(date) : stApi;

    return ScheduleModel(
      id: id,
      teachingDate: date,
      periodStartRaw: psRaw,
      periodEndRaw: peRaw,
      periodStart: ps,
      periodEnd: pe,
      type: type,
      subjectName: subject,
      classCode: classCode,
      roomName: room,
      chapter: chapter,
      status: st,
    );
  }

  factory ScheduleModel.fromSectionDetail({
    required Map<String, dynamic> section,
    required Map<String, dynamic> detail,
  }) {
    final subject   = (section['subject']?['name'] ?? '').toString();
    final classCode = (section['name'] ?? '').toString();
    final room      = (section['room']?['name'] ?? '').toString();
    final type      = (detail['type'] ?? '').toString();

    final date  = _parseDateFlexible(detail['teachingDate']?.toString());
    final psRaw = detail['periodStart']?.toString();
    final peRaw = detail['periodEnd']?.toString();
    final ps    = extractPeriodNumber(psRaw);
    final pe    = extractPeriodNumber(peRaw);

    final id    = _toInt(detail['id']);

    final stApi = statusFromApi(detail['status'] as String?);
    final st    = stApi == ScheduleStatus.unknown ? _fallbackStatusByDate(date) : stApi;

    return ScheduleModel(
      id: id,
      teachingDate: date,
      periodStartRaw: psRaw,
      periodEndRaw: peRaw,
      periodStart: ps,
      periodEnd: pe,
      type: type,
      subjectName: subject,
      classCode: classCode,
      roomName: room,
      chapter: null,
      status: st,
    );
  }

  ScheduleModel copyWith({
    int? id,
    DateTime? teachingDate,
    String? periodStartRaw,
    String? periodEndRaw,
    int? periodStart,
    int? periodEnd,
    String? type,
    String? subjectName,
    String? classCode,
    String? roomName,
    String? chapter,
    ScheduleStatus? status,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      teachingDate: teachingDate ?? this.teachingDate,
      periodStartRaw: periodStartRaw ?? this.periodStartRaw,
      periodEndRaw: periodEndRaw ?? this.periodEndRaw,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      type: type ?? this.type,
      subjectName: subjectName ?? this.subjectName,
      classCode: classCode ?? this.classCode,
      roomName: roomName ?? this.roomName,
      chapter: chapter ?? this.chapter,
      status: status ?? this.status,
    );
  }
}
