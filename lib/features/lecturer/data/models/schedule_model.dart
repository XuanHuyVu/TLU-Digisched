import '../../domain/entities/schedule_entity.dart';

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
    required int id,
    required DateTime? teachingDate,
    required String? periodStartRaw,
    required String? periodEndRaw,
    required int periodStart,
    required int periodEnd,
    required String type,
    required String subjectName,
    required String classCode,
    required String roomName,
    required String? chapter,
    required ScheduleStatus status,
  }) : super(
         id: id,
         teachingDate: teachingDate,
         periodStartRaw: periodStartRaw,
         periodEndRaw: periodEndRaw,
         periodStart: periodStart,
         periodEnd: periodEnd,
         type: type,
         subjectName: subjectName,
         classCode: classCode,
         roomName: roomName,
         chapter: chapter,
         status: status,
       );

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      teachingDate:
          json['teachingDate'] != null
              ? DateTime.tryParse(json['teachingDate'])
              : null,
      periodStartRaw: json['periodStartRaw'],
      periodEndRaw: json['periodEndRaw'],
      periodStart: json['periodStart'] ?? 0,
      periodEnd: json['periodEnd'] ?? 0,
      type: json['type'] ?? '',
      subjectName: json['subjectName'] ?? '',
      classCode: json['classCode'] ?? '',
      roomName: json['roomName'] ?? '',
      chapter: json['chapter'],
      status: statusFromApi(json['status']),
    );
  }

  static ScheduleModel fromSectionDetail({
    required Map<String, dynamic> section,
    required Map<String, dynamic> detail,
  }) {
    return ScheduleModel(
      id: detail['id'] ?? 0,
      teachingDate:
          detail['teachingDate'] != null
              ? DateTime.tryParse(detail['teachingDate'])
              : null,
      periodStartRaw: detail['periodStartRaw'],
      periodEndRaw: detail['periodEndRaw'],
      periodStart: detail['periodStart'] ?? 0,
      periodEnd: detail['periodEnd'] ?? 0,
      type: detail['type'] ?? section['type'] ?? '',
      subjectName: section['subjectName'] ?? '',
      classCode: section['classCode'] ?? '',
      roomName: detail['roomName'] ?? '',
      chapter: detail['chapter'],
      status: statusFromApi(detail['status']),
    );
  }
}
