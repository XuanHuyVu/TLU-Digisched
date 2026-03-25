import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tlu_schedule_pro/features/teacher/models/teacher_notification_model.dart';
import 'package:tlu_schedule_pro/features/teacher/services/teacher_notification_service.dart';
import 'teacher_schedule_screen.dart';

class TeacherNotificationScreen extends StatefulWidget {
  const TeacherNotificationScreen({super.key});

  @override
  State<TeacherNotificationScreen> createState() =>
      _TeacherNotificationScreenState();
}

class _TeacherNotificationScreenState extends State<TeacherNotificationScreen> {
  late Future<List<TeacherNotification>> _futureNotifications;
  final TeacherNotificationService _notificationService =
  TeacherNotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    _futureNotifications = _notificationService.fetchNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A90E2),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            splashRadius: 24,
            tooltip: 'Quay lại Trang Chủ',
            onPressed: () {
              Navigator.of(context).pop();
            },
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
          actions: [

            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'Tìm kiếm',
              onPressed: () {
                // Logic tìm kiếm nếu cần
              },
            ),
          ],
        ),
        body: FutureBuilder<List<TeacherNotification>>(
          future: _futureNotifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            final all = snapshot.data ?? [];
            final read = all.where((n) => n.isRead).toList();
            final unread = all.where((n) => !n.isRead).toList();

            return TabBarView(
              children: [
                TeacherNotificationList(
                  notifications: all,
                  notificationService: _notificationService,
                  refreshParent: _refreshNotifications,
                ),
                TeacherNotificationList(
                  notifications: read,
                  notificationService: _notificationService,
                  refreshParent: _refreshNotifications,
                ),
                TeacherNotificationList(
                  notifications: unread,
                  notificationService: _notificationService,
                  refreshParent: _refreshNotifications,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TeacherNotificationList extends StatefulWidget {
  final List<TeacherNotification> notifications;
  final TeacherNotificationService notificationService;
  final VoidCallback refreshParent;

  const TeacherNotificationList({
    super.key,
    required this.notifications,
    required this.notificationService,
    required this.refreshParent,
  });

  @override
  State<TeacherNotificationList> createState() =>
      _TeacherNotificationListState();
}

class _TeacherNotificationListState extends State<TeacherNotificationList> {
  late List<TeacherNotification> data;

  @override
  void initState() {
    super.initState();
    data = List.from(widget.notifications);
  }

  @override
  void didUpdateWidget(covariant TeacherNotificationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications != oldWidget.notifications) {
      data = List.from(widget.notifications);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Không có thông báo.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: data.length,
      itemBuilder: (context, index) {
        final n = data[index];
        return Card(
          color: n.isRead ? Colors.white : Colors.blue[50],
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: n.isRead
                ? const Icon(Icons.calendar_today)
                : Stack(
              children: [
                const Icon(Icons.calendar_today),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                      radius: 5, backgroundColor: Colors.red),
                ),
              ],
            ),
            title: Text(n.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation(context, n);
                    break;
                  case 'mark_read':
                    _markAsRead(context, n);
                    break;
                  case 'mark_unread':
                    _markAsUnread(context, n);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Xóa'),
                ),
                if (!n.isRead)
                  const PopupMenuItem<String>(
                    value: 'mark_read',
                    child: Text('Đánh dấu đã đọc'),
                  ),
                if (n.isRead)
                  const PopupMenuItem<String>(
                    value: 'mark_unread',
                    child: Text('Đánh dấu chưa đọc'),
                  ),
              ],
            ),
            onTap: () {
              // Hành động khi nhấn thông báo nếu cần
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

  void _showDeleteConfirmation(
      BuildContext context, TeacherNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Gọi API xóa nếu có
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa thông báo')),
              );
              widget.refreshParent();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _markAsRead(
      BuildContext context, TeacherNotification notification) async {
    try {
      await widget.notificationService.markAsRead(notification.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đánh dấu là đã đọc')),
      );

      setState(() {
        final i = data.indexWhere((element) => element.id == notification.id);
        if (i != -1) {
          data[i] = data[i].copyWith(isRead: true);
        }
      });

      widget.refreshParent();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  void _markAsUnread(
      BuildContext context, TeacherNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đánh dấu là chưa đọc (chức năng chưa có)')),
    );
  }
}
