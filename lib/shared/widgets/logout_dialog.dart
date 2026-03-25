import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      title: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.help_outline,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Xác nhận đăng xuất',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ],
      ),
          content: Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            style: GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),

      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        SizedBox(
          width: 140,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text('Đăng xuất', style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(true),

          ),
        ),
        SizedBox(
          width: 140,
          height: 40,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor: Colors.white,
            ),
            child: Text('Hủy bỏ', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
