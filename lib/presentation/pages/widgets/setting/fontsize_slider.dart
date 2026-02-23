import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../cubit/settings_cubit/settings_cubit.dart';

class FontSizeSlider extends StatelessWidget {
  final double value;
  const FontSizeSlider({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.format_size_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'حجم الخط',
                style: GoogleFonts.amiri(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toStringAsFixed(1)}×',
                  style: GoogleFonts.amiri(
                    color: AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accentSoft,
              valueIndicatorColor: AppColors.surface,
              valueIndicatorTextStyle: GoogleFonts.amiri(
                color: AppColors.accent,
                fontSize: 12,
              ),
            ),
            child: Slider(
              value: value,
              min: 0.7,
              max: 2.0,
              divisions: 13,
              label: '${value.toStringAsFixed(1)}×',
              onChanged: (v) =>
                  context.read<SettingsCubit>().setFontSizeMultiplier(v),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider, width: 0.6),
            ),
            child: Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18 * value,
                height: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
