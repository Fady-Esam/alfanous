import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/aya_model.dart';

class MetaChips extends StatelessWidget {
  final AyaModel aya;
  const MetaChips({required this.aya});

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      if (aya.juzId != null) 'الجزء ${aya.juzId}',
      if (aya.hizbId != null) 'الحزب ${aya.hizbId}',
      if (aya.pageId != null) 'صفحة ${aya.pageId}',
      if (aya.suraTypeEn != null) aya.suraTypeEn!,
    ];
    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: chips.map(_chip).toList(),
    );
  }

  Widget _chip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider, width: 0.6),
    ),
    child: Text(
      label,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.amiri(color: AppColors.textSecondary, fontSize: 11),
    ),
  );
}
