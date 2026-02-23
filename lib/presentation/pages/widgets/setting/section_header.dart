import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const SectionHeader({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, color: AppColors.accent, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              color: AppColors.accent,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: AppColors.divider, thickness: 0.7)),
        ],
      ),
    );
  }
}
