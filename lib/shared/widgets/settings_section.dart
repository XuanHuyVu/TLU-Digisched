import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account_setting.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cài đặt",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              _buildSettingOption(
                context,
                icon: Icons.account_circle,
                label: "Cài đặt tài khoản",
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                  );
                },
              ),
              _buildSettingOption(
                context,
                icon: Icons.help_outline,
                label: "Trợ giúp",
                onTap: () {
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
