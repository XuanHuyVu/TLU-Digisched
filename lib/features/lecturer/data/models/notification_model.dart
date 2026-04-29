import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.type,
    required super.relatedScheduleChangeId,
    required super.createdAt,
    required super.updatedAt,
    required super.isRead,
  });

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
