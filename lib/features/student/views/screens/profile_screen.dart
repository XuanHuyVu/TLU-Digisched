import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/profile_model.dart';
import '../../services/profile_service.dart';
import 'package:tlu_schedule_pro/core/services/avatar_service.dart';
import 'package:tlu_schedule_pro/shared/widgets/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileModel> futureProfile;
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    futureProfile = ProfileService().fetchProfile();
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

  String formatDate(String isoDate) {
    try {
      final parsedDate = DateTime.parse(isoDate);
      return "${parsedDate.day.toString().padLeft(2, '0')}/"
          "${parsedDate.month.toString().padLeft(2, '0')}/"
          "${parsedDate.year}";
    } catch (_) {
      return isoDate;
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return parts.map((e) => e[0]).take(3).join().toUpperCase();
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
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16)),
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

  Widget _buildAvatarWithEditButton(ProfileModel user) {
    return Stack(
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
            _getInitials(user.fullName),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
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
                      onTap: () => Navigator.pop(context),
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
              child: Icon(Icons.edit, color: Colors.indigo, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<ProfileModel>(
        future: futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final user = snapshot.data!;
          const Color backgroundColor = Color(0xFF4A90E2);

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: backgroundColor,
                    padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                    child: Column(
                      children: [
                        _buildAvatarWithEditButton(user),
                        const SizedBox(height: 16),
                        Text(user.fullName,
                            style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 0.7),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 6),
                        Text("Mã SV: ${user.studentCode}",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(user.email ?? "Chưa cập nhật email",
                            style: GoogleFonts.poppins(
                                color: Colors.white70, fontSize: 16),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
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
                              child: Text("Thông tin sinh viên",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                            const Divider(
                                thickness: 1.2,
                                height: 24,
                                color: Colors.blueGrey),
                            _buildInfoRow(Icons.person, "Họ tên", user.fullName),
                            _buildInfoRow(Icons.wc, "Giới tính", user.gender),
                            _buildInfoRow(Icons.calendar_today, "Ngày sinh",
                                formatDate(user.dateOfBirth)),
                            _buildInfoRow(Icons.email, "Email", user.email),
                            _buildInfoRow(
                                Icons.phone, "Số điện thoại", user.phoneNumber),
                            _buildInfoRow(Icons.class_, "Lớp", user.className),
                            _buildInfoRow(Icons.school, "Khoa", user.facultyName),
                            _buildInfoRow(
                                Icons.computer, "Ngành học", user.majorName),
                            _buildInfoRow(Icons.access_time, "Năm vào học",
                                user.enrollmentYear.toString()),
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
}
