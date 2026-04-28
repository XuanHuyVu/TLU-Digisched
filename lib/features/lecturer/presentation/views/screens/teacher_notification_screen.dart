import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/notification_entity.dart';
import '../../notifiers/teacher_notification_notifier.dart';
import '../../notifiers/teacher_service_locator.dart';

class TeacherNotificationScreen extends StatefulWidget {
  const TeacherNotificationScreen({super.key});

  @override
  State<TeacherNotificationScreen> createState() =>
      _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {
  late final Map<String, dynamic> _notifiers;

  @override
  void initState() {
    super.initState();
    _initializeNotifiers();
  }

  Future<void> _initializeNotifiers() async {
    final prefs = await SharedPreferences.getInstance();
    _notifiers = await TeacherServiceLocator.setup(prefs);
    final notificationNotifier =
        _notifiers['notificationNotifier'] as TeacherNotificationNotifier;
    await notificationNotifier.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future.value(),
      builder: (context, snapshot) {
        return DefaultTabController(
          length: 3,
          child: ChangeNotifierProvider.value(
            value:
                _notifiers['notificationNotifier']
                    as TeacherNotificationNotifier? ??
                TeacherNotificationNotifier(
                  fetchNotificationsUseCase: null as dynamic,
                  markNotificationAsReadUseCase: null as dynamic,
                ),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color(0xFF4A90E2),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  splashRadius: 24,
                  tooltip: 'Quay lại Trang Chủ',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  'Thông báo',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                bottom: const TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Tất cả'),
                    Tab(text: 'Đã đọc'),
                    Tab(text: 'Chưa đọc'),
                  ],
                ),
              ),
              body: Consumer<TeacherNotificationNotifier>(
                builder: (context, notifier, child) {
                  if (notifier.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (notifier.error != null) {
                    return Center(child: Text('Lỗi: ${notifier.error}'));
                  }

                  final all = notifier.notifications;
                  final read = all.where((n) => n.isRead).toList();
                  final unread = all.where((n) => !n.isRead).toList();

                  return TabBarView(
                    children: [
                      _NotificationListView(
                        notifications: all,
                        notifier: notifier,
                      ),
                      _NotificationListView(
                        notifications: read,
                        notifier: notifier,
                      ),
                      _NotificationListView(
                        notifications: unread,
                        notifier: notifier,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotificationListView extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final TeacherNotificationNotifier notifier;

  const _NotificationListView({
    required this.notifications,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(child: Text('Không có thông báo.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final n = notifications[index];
        return Card(
          color: n.isRead ? Colors.white : Colors.blue[50],
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading:
                n.isRead
                    ? const Icon(Icons.calendar_today)
                    : Stack(
                      children: [
                        const Icon(Icons.calendar_today),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
            title: Text(
              n.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.content),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(n.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            isThreeLine: true,
            trailing:
                !n.isRead
                    ? IconButton(
                      icon: const Icon(Icons.done),
                      onPressed: () => notifier.markAsRead(n.id),
                    )
                    : null,
            onTap: () {
              if (!n.isRead) {
                notifier.markAsRead(n.id);
              }
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
