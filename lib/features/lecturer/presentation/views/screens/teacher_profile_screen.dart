import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../shared/widgets/settings_section.dart';
import '../../notifiers/teacher_profile_notifier.dart';
import '../../notifiers/avatar_notifier.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherProfileNotifier>().load();
      context.read<AvatarNotifier>().loadAvatar();
    });
  }

  Future<void> _pickAvatar() async {
    final avatarNotifier = context.read<AvatarNotifier>();
    await avatarNotifier.pickAvatar();
    
    if (mounted && avatarNotifier.avatarBase64 != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật avatar thành công!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _removeAvatar() async {
    final avatarNotifier = context.read<AvatarNotifier>();
    await avatarNotifier.removeAvatar();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã xoá avatar"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF4A90E2), elevation: 0),
      body: Consumer<TeacherProfileNotifier>(
        builder: (context, notifier, child) {
          if (notifier.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (notifier.error != null) {
            final errorMessage = notifier.error.toString();
            if (errorMessage.contains('Token đã hết hạn') || 
                errorMessage.contains('unauthorized')) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleTokenExpired(context);
              });
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_clock, size: 64, color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Phiên đăng nhập đã hết hạn',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Đang chuyển về màn hình đăng nhập...'),
                  ],
                ),
              );
            }
            return Center(child: Text("Lỗi: ${notifier.error}"));
          }

          final profile = notifier.profile;
          if (profile == null) {
            return const Center(child: Text("Không có dữ liệu"));
          }
          const Color backgroundColor = Color(0xFF4A90E2);
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: backgroundColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 28,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        Consumer<AvatarNotifier>(
                          builder: (context, avatarNotifier, child) {
                            final avatarBase64 = avatarNotifier.avatarBase64;
                            
                            return Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.blue.shade300,
                                  backgroundImage:
                                      avatarBase64 != null
                                          ? MemoryImage(base64Decode(avatarBase64))
                                          : null,
                                  child:
                                      avatarBase64 == null
                                          ? Text(
                                            _getInitials(profile.fullName),
                                            style: GoogleFonts.montserrat(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 26,
                                            ),
                                          )
                                          : null,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder:
                                          (context) => Container(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.photo_library,
                                                  ),
                                                  title: const Text(
                                                    "Chọn ảnh mới",
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    _pickAvatar();
                                                  },
                                                ),
                                                if (avatarBase64 != null)
                                                  ListTile(
                                                    leading: const Icon(
                                                      Icons.delete,
                                                    ),
                                                    title: const Text(
                                                      "Xóa ảnh",
                                                    ),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _removeAvatar();
                                                    },
                                                  ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons.cancel,
                                                  ),
                                                  title: const Text("Hủy"),
                                                  onTap:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    );
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                            const SizedBox(height: 16),
                            Text(
                              profile.fullName,
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Khoa: ${profile.faculty?.name ?? ''}",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text(
                                    "Thông tin cá nhân",
                                    style: GoogleFonts.montserrat(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Divider(
                                  thickness: 1.2,
                                  height: 24,
                                  color: Colors.blueGrey,
                                ),
                                _buildInfoRow(
                                  Icons.email,
                                  "Email",
                                  profile.email,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.cake,
                                  "Ngày sinh",
                                  _formatDate(profile.dateOfBirth),
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.phone,
                                  "Số điện thoại",
                                  profile.phoneNumber,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.wc,
                                  "Giới tính",
                                  profile.gender,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.badge,
                                  "Mã giảng viên",
                                  profile.teacherCode,
                                ),
                                const Divider(height: 20),
                                _buildInfoRow(
                                  Icons.school,
                                  "Bộ môn",
                                  profile.department?.name ?? '',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),
                      const SettingsSection(),
                      const SizedBox(height: 26),
                    ],
                  ),
                ),
              );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    final displayValue =
        (value == null || value.trim().isEmpty) ? "Chưa cập nhật" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              displayValue,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Chưa cập nhật";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.map((e) => e[0]).take(3).join().toUpperCase();
  }

  Future<void> _handleTokenExpired(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login',
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
