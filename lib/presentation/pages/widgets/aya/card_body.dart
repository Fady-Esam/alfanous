import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/aya_model.dart';
import '../../../cubit/favorite_cubit/favorites_cubit.dart';
import '../../../cubit/favorite_cubit/favorites_states.dart';
import '../../../cubit/settings_cubit/settings_cubit.dart';
import '../../../cubit/settings_cubit/settings_states.dart';
import 'aya_badge.dart';
import 'diacritic_highlight_text.dart';
import 'meta_chips.dart';

class CardBody extends StatelessWidget {
  final AyaModel aya;
  final List<String> highlightTerms;
  final bool isHighlight;

  const CardBody({
    required this.aya,
    required this.highlightTerms,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.fontSizeMultiplier != curr.fontSizeMultiplier,
      builder: (context, settings) {
        final baseFs = 20.0 * settings.fontSizeMultiplier;

        final baseStyle = GoogleFonts.amiri(
          color: isHighlight
              ? AppColors.textPrimary
              : AppColors.textPrimary.withAlpha(220),
          fontSize: baseFs,
          height: 2.0,
          fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
        );

        final hlStyle = GoogleFonts.amiri(
          color: AppColors.accent,
          fontSize: baseFs,
          height: 2.0,
          fontWeight: FontWeight.bold,
          backgroundColor: AppColors.accentSoft,
        );

        final displayText = aya.standardFull.isNotEmpty
            ? aya.standardFull
            : aya.standard;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isHighlight ? AppColors.highlightBg : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlight
                  ? AppColors.highlightBorder
                  : AppColors.divider,
              width: isHighlight ? 1.5 : 0.8,
            ),
            boxShadow: isHighlight
                ? [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(60),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    AyaBadge(number: aya.ayaId, highlighted: isHighlight),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'سورة ${aya.suraName ?? ''} - آية ${aya.ayaId}',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: isHighlight
                              ? AppColors.accent
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: isHighlight
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    BlocBuilder<FavoritesCubit, FavoritesState>(
                      builder: (context, favState) {
                        final isFav = favState.isFavorite(aya.gid);
                        return IconButton(
                          icon: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFav
                                ? AppColors.accent
                                : AppColors.textSecondary.withAlpha(150),
                            size: 26,
                          ),
                          onPressed: () {
                            context.read<FavoritesCubit>().toggleFavorite(
                              aya.gid,
                            );
                          },
                          tooltip: 'إضافة للمفضلة',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 24,
                        );
                      },
                    ),
                  ],
                ),

                Divider(color: AppColors.divider, height: 20, thickness: 0.6),

                highlightTerms.isNotEmpty
                    ? DiacriticHighlightText(
                        originalText: displayText,
                        highlightTerms: highlightTerms,
                        textDirection: TextDirection.rtl,
                        baseStyle: baseStyle,
                        highlightStyle: hlStyle,
                      )
                    : Text(
                        displayText,
                        textDirection: TextDirection.rtl,
                        style: baseStyle,
                      ),

                const SizedBox(height: 10),

                MetaChips(aya: aya),
              ],
            ),
          ),
        );
      },
    );
  }
}
