import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';

class TeacherInfoCard extends StatelessWidget {
  final TeacherModel teacher;
  final bool compact; // dùng layout gọn khi đặt trong card tổng quan
  const TeacherInfoCard({super.key, required this.teacher, this.compact = false});

  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return (parts.first[0] + parts.last[0]).toUpperCase();
    if (parts.isNotEmpty) return parts.first[0].toUpperCase();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final subtitlePieces = [
      if (teacher.faculty.trim().isNotEmpty) teacher.faculty.trim(),
      if ((teacher.department ?? '').trim().isNotEmpty) (teacher.department ?? '').trim(),
    ];
    final subtitle = subtitlePieces.join(' • ');

    return Row(
      children: [
        CircleAvatar(
          radius: compact ? 22 : 24,
          backgroundColor: const Color(0xFF2F6BFF),
          child: Text(
            _getInitials(teacher.name),
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teacher.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle.isEmpty ? ' ' : subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
