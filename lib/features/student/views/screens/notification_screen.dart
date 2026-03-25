import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tlu_schedule_pro/features/student/models/notification_model.dart';
import 'package:tlu_schedule_pro/features/student/viewmodels/notification_viewmodel.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel()..fetchNotifications(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF4A90E2),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                tooltip: 'Tìm kiếm',
                onPressed: () {
                  // TODO: thêm logic tìm kiếm nếu cần
                },
              ),
            ],
          ),
          body: Consumer<NotificationViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (vm.error != null) {
                return Center(child: Text('Lỗi: ${vm.error}'));
              }

              return TabBarView(
                children: [
                  NotificationList(notifications: vm.notifications, vm: vm),
                  NotificationList(notifications: vm.read, vm: vm),
                  NotificationList(notifications: vm.unread, vm: vm),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
class NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final NotificationViewModel vm;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.vm,
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
            leading: n.isRead
                ? const Icon(Icons.calendar_today)
                : Stack(
              children: [
                const Icon(Icons.calendar_today),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
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
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation(context, n, vm);
                    break;
                  case 'mark_read':
                    vm.markAsRead(n.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã đánh dấu là đã đọc')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                if (!n.isRead)
                  const PopupMenuItem(value: 'mark_read', child: Text('Đánh dấu đã đọc')),
                if (n.isRead)
                  const PopupMenuItem(value: 'mark_unread', child: Text('Đánh dấu chưa đọc')),
              ],
            ),
            onTap: () {
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, NotificationModel n, NotificationViewModel vm) {
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
              vm.deleteNotification(n.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa thông báo')),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }
}
