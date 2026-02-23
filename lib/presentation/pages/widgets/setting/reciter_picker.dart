import 'package:alfanous/presentation/pages/widgets/setting/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/reciter_names.dart';
import '../../../../core/services/settings_service.dart';
import '../../../cubit/settings_cubit/settings_cubit.dart';

class ReciterPicker extends StatelessWidget {
  final String current;
  const ReciterPicker({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'القارئ الحالي',
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(color: AppColors.textPrimary, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current,
                dropdownColor: AppColors.surfaceHigh,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                isExpanded: true,
                menuMaxHeight: 400,
                borderRadius: BorderRadius.circular(12),
                style: GoogleFonts.amiri(color: AppColors.textPrimary, fontSize: 16),
                items: SettingsService.availableReciters.map((r) {
                  return DropdownMenuItem<String>(
                    value: r,
                    alignment: Alignment.centerRight,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          r == current
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: r == current ? AppColors.accent : AppColors.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          reciterNames[r] ?? r,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            color: r == current ? AppColors.accent : AppColors.textPrimary,
                            fontWeight: r == current
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    context.read<SettingsCubit>().setSelectedReciter(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
