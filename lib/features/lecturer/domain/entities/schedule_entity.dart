
import '../../../../core/utils/period_helper.dart';
import '../../../../core/enums/session_type.dart';

enum ScheduleStatus { upcoming, ongoing, done, canceled, expired, unknown }

class ScheduleEntity {
  final int id;
  final int? scheduleEntryId;
  final DateTime? sessionDate;
  final int? dayOfWeek;
  final int startPeriod;
  final int endPeriod;
  final SessionType sessionType;
  final int? roomId;
  final String? roomCode;
  final String? roomBuilding;
  final String roomName;
  final String? notes;
  final ScheduleStatus status;
  final String subjectName;
  final String classCode;

  const ScheduleEntity({
    required this.id,
    this.scheduleEntryId,
    required this.sessionDate,
    this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
    required this.sessionType,
    this.roomId,
    this.roomCode,
    this.roomBuilding,
    required this.roomName,
    this.notes,
    required this.status,
    required this.subjectName,
    required this.classCode,
  });

  int get periodsCount =>
      (startPeriod > 0 && endPeriod >= startPeriod)
          ? (endPeriod - startPeriod + 1)
          : 1;

  String get periodText {
    if (startPeriod > 0 && endPeriod > 0) {
      return 'Tiết $startPeriod – Tiết $endPeriod';
    }
    return '- – -';
  }

  String get timeRange {
    if (startPeriod <= 0 || endPeriod <= 0) return '';
    return periodTimeRange(startPeriod, endPeriod);
  }

  ScheduleEntity copyWith({
    int? id,
    int? scheduleEntryId,
    DateTime? sessionDate,
    int? dayOfWeek,
    int? startPeriod,
    int? endPeriod,
    SessionType? sessionType,
    int? roomId,
    String? roomCode,
    String? roomBuilding,
    String? roomName,
    String? notes,
    ScheduleStatus? status,
    String? subjectName,
    String? classCode,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      scheduleEntryId: scheduleEntryId ?? this.scheduleEntryId,
      sessionDate: sessionDate ?? this.sessionDate,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startPeriod: startPeriod ?? this.startPeriod,
      endPeriod: endPeriod ?? this.endPeriod,
      sessionType: sessionType ?? this.sessionType,
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      roomBuilding: roomBuilding ?? this.roomBuilding,
      roomName: roomName ?? this.roomName,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      subjectName: subjectName ?? this.subjectName,
      classCode: classCode ?? this.classCode,
    );
  }
}
