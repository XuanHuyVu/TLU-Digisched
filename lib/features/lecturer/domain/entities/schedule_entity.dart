
import '../../../../core/utils/period_helper.dart';

enum ScheduleStatus { upcoming, ongoing, done, canceled, expired, unknown }

class ScheduleEntity {
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

  const ScheduleEntity({
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

  int get periodsCount =>
      (periodStart > 0 && periodEnd >= periodStart)
          ? (periodEnd - periodStart + 1)
          : 1;

  String get periodText {
    final a = periodStartRaw;
    final b = periodEndRaw;
    if ((a ?? '').isNotEmpty && (b ?? '').isNotEmpty) return '$a – $b';
    if (periodStart > 0 && periodEnd > 0) {
      return 'Tiết $periodStart – Tiết $periodEnd';
    }
    return '- – -';
  }

  String get timeRange {
    if (periodStart <= 0 || periodEnd <= 0) return '';
    return periodTimeRange(periodStart, periodEnd);
  }

  ScheduleEntity copyWith({
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
    return ScheduleEntity(
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
