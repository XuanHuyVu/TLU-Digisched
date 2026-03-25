import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../viewmodels/teacher_profile_viewmodel.dart';
import '../../../../shared/widgets/settings_section.dart';
import '../../../../shared/widgets/logout_dialog.dart';
import 'package:tlu_schedule_pro/core/services/avatar_service.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final savedBase64 = await AvatarService.loadAvatar();
    if (mounted) {
      setState(() => _avatarBase64 = savedBase64);
    }
  }

  Future<void> _pickAvatar() async {
    final newAvatar = await AvatarService.pickAvatar();
    if (newAvatar != null) {
      if (mounted) {
        setState(() => _avatarBase64 = newAvatar);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật avatar thành công!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    await AvatarService.removeAvatar();
    if (mounted) {
      setState(() => _avatarBase64 = null);
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        // ❌ bỏ title và nút đăng xuất
      ),
      body: ChangeNotifierProvider(
        create: (_) => TeacherProfileViewModel()..fetchProfile(),
        child: Consumer<TeacherProfileViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(child: Text("Lỗi: ${vm.error}"));
            }

            final profile = vm.profile;
            if (profile == null) {
              return const Center(child: Text("Không có dữ liệu"));
            }

            final Color backgroundColor = const Color(0xFF4A90E2);

            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header xanh + avatar + tên + khoa
                    Container(
                      width: double.infinity,
                      color: backgroundColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 20),
                      child: Column(
                        children: [
                          // ✅ Avatar có chỉnh sửa giống sinh viên
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.blue.shade300,
                                backgroundImage: _avatarBase64 != null
                                    ? MemoryImage(base64Decode(_avatarBase64!))
                                    : null,
                                child: _avatarBase64 == null
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
                                          top: Radius.circular(20)),
                                    ),
                                    builder: (context) => Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading:
                                            const Icon(Icons.photo_library),
                                            title: const Text("Chọn ảnh mới"),
                                            onTap: () {
                                              Navigator.pop(context);
                                              _pickAvatar();
                                            },
                                          ),
                                          if (_avatarBase64 != null)
                                            ListTile(
                                              leading: const Icon(Icons.delete),
                                              title: const Text("Xóa ảnh"),
                                              onTap: () {
                                                Navigator.pop(context);
                                                _removeAvatar();
                                              },
                                            ),
                                          ListTile(
                                            leading: const Icon(Icons.cancel),
                                            title: const Text("Hủy"),
                                            onTap: () =>
                                                Navigator.pop(context),
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
                                    child: Icon(Icons.edit,
                                        color: Colors.indigo, size: 20),
                                  ),
                                ),
                              ),
                            ],
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
                                color: Colors.white70, fontSize: 18),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Card thông tin cá nhân
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 24, horizontal: 20),
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
                                  color: Colors.blueGrey),
                              _buildInfoRow(Icons.email, "Email", profile.email),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.cake, "Ngày sinh",
                                  _formatDate(profile.dateOfBirth)),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.phone, "Số điện thoại",
                                  profile.phoneNumber),
                              const Divider(height: 20),
                              _buildInfoRow(
                                  Icons.wc, "Giới tính", profile.gender),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.badge, "Mã giảng viên",
                                  profile.teacherCode),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.school, "Bộ môn",
                                  profile.department?.name ?? ''),
                              const Divider(height: 20),
                              _buildInfoRow(Icons.info, "Trạng thái",
                                  _mapStatus(profile.status)),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Phần Cài đặt
                    const SettingsSection(),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            );
          },
        ),
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
                  fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              displayValue,
              style: GoogleFonts.poppins(
                  fontSize: 15, color: Colors.black87),
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

  String _mapStatus(String? status) {
    if (status == null) return "Chưa cập nhật";
    switch (status.toUpperCase()) {
      case "ACTIVE":
        return "Đang công tác";
      case "INACTIVE":
        return "Ngừng công tác";
      default:
        return status;
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.map((e) => e[0]).take(3).join().toUpperCase();
  }
}
