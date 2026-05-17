import '../../domain/entities/schedule_entity.dart';
import '../../../../core/enums/session_type.dart';

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
      return 'UNKNOWN';
  }
}

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    super.scheduleEntryId,
    required super.sessionDate,
    super.dayOfWeek,
    required super.startPeriod,
    required super.endPeriod,
    required super.sessionType,
    super.roomId,
    super.roomCode,
    super.roomBuilding,
    required super.roomName,
    super.notes,
    required super.status,
    required super.subjectName,
    required super.classCode,
    super.isCompleted,
    super.completedAt,
    super.isMakeupAttendance,
    super.makeupReason,
    super.makeupFileUrl,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['sessionDate'] != null) {
      parsedDate = DateTime.tryParse(json['sessionDate']);
    }
    
    DateTime? parsedCompletedAt;
    if (json['completedAt'] != null) {
      parsedCompletedAt = DateTime.tryParse(json['completedAt']);
    }
    
    ScheduleStatus finalStatus;
    if (json['isCompleted'] == true) {
      finalStatus = ScheduleStatus.done;
    } else {
      finalStatus = statusFromApi(json['status']);
    }
    
    return ScheduleModel(
      id: json['id'] ?? 0,
      scheduleEntryId: json['scheduleEntryId'],
      sessionDate: parsedDate,
      dayOfWeek: json['dayOfWeek'],
      startPeriod: json['startPeriod'] ?? 0,
      endPeriod: json['endPeriod'] ?? 0,
      sessionType: SessionType.fromString(json['sessionType']),
      roomId: json['roomId'],
      roomCode: json['roomCode'],
      roomBuilding: json['roomBuilding'],
      roomName: json['roomName'] ?? '',
      notes: json['notes'],
      status: finalStatus,
      subjectName: json['subjectName'] ?? '',
      classCode: json['classCode'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: parsedCompletedAt,
      isMakeupAttendance: json['isMakeupAttendance'] ?? false,
      makeupReason: json['makeupReason'],
      makeupFileUrl: json['makeupFileUrl'],
    );
  }
}
