import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required int id,
    required String title,
    required String content,
    required String type,
    required int relatedScheduleChangeId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required bool isRead,
  }) : super(
         id: id,
         title: title,
         content: content,
         type: type,
         relatedScheduleChangeId: relatedScheduleChangeId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         isRead: isRead,
       );

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      relatedScheduleChangeId: json['relatedScheduleChangeId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isRead: json['isRead'],
    );
  }
}
