import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

class BismAllahBanner extends StatelessWidget {
  final int suraId;

  const BismAllahBanner({super.key, required this.suraId});

  @override
  Widget build(BuildContext context) {
    if (suraId == 9) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.8),
      ),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.amiri(
          color: AppColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1.4,
        ),
      ),
    );
  }
}
