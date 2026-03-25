class TeacherNotification {
  final int id;
  final String title;
  final String content;
  final String type;
  final int relatedScheduleChangeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRead;

  TeacherNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.relatedScheduleChangeId,
    required this.createdAt,
    required this.updatedAt,
    required this.isRead,
  });

  factory TeacherNotification.fromJson(Map<String, dynamic> json) {
    return TeacherNotification(
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

  TeacherNotification copyWith({
    int? id,
    String? title,
    String? content,
    String? type,
    int? relatedScheduleChangeId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRead,
  }) {
    return TeacherNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      relatedScheduleChangeId:
      relatedScheduleChangeId ?? this.relatedScheduleChangeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
