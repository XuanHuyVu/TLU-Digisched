import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tlu_schedule_pro/core/extensions/extensions.dart';
import '../../models/student_schedule_model.dart';

class ScheduleCard extends StatelessWidget {
  final StudentScheduleModel schedule;

  const ScheduleCard({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            left: BorderSide(color: Color(0xFF4A90E2), width: 12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.subjectName,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (schedule.classSectionName.isNotEmpty)
                Text(
                  '(${schedule.classSectionName})',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.person_outline, schedule.teacherName),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.location_on_outlined, schedule.roomCode),
              const SizedBox(height: 4),
              _buildInfoRow(
                Icons.access_time_outlined,
                '${schedule.periodStart} - ${schedule.periodEnd}',
              ),
              const SizedBox(height: 4),
              _buildInfoRow(Icons.book_outlined, schedule.vietnameseType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}