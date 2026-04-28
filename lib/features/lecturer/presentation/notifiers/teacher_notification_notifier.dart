import 'package:flutter/foundation.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/fetch_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';

class TeacherNotificationNotifier extends ChangeNotifier {
  final FetchNotificationsUseCase fetchNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  TeacherNotificationNotifier({
    required this.fetchNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  });

  bool _loading = false;
  String? _error;
  List<NotificationEntity> _notifications = [];

  bool get loading => _loading;
  String? get error => _error;
  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await fetchNotificationsUseCase();
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final idx = _notifications.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        final notification = _notifications[idx];
        _notifications[idx] = notification.copyWith(isRead: true);
        notifyListeners();
      }

      await markNotificationAsReadUseCase(notificationId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
