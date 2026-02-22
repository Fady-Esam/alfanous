import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/aya_model.dart';
import '../cubit/settings_cubit.dart';
import 'diacritic_highlight_text.dart';

class AyahCardWidget extends StatelessWidget {
  final AyaModel aya;

  final List<String> highlightTerms;

  final bool isHighlight;

  const AyahCardWidget({
    super.key,
    required this.aya,
    this.highlightTerms = const [],
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return _CardBody(
      aya: aya,
      highlightTerms: highlightTerms,
      isHighlight: isHighlight,
    );
  }
}

class _CardBody extends StatelessWidget {
  final AyaModel aya;
  final List<String> highlightTerms;
  final bool isHighlight;

  const _CardBody({
    required this.aya,
    required this.highlightTerms,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.fontType != curr.fontType ||
          prev.fontSizeMultiplier != curr.fontSizeMultiplier,
      builder: (context, settings) {
        final baseFs = 20.0 * settings.fontSizeMultiplier;
        final font = settings.fontType;

        final baseStyle = TextStyle(
          fontFamily: font,
          color: isHighlight ? AppColors.textPrimary : AppColors.textPrimary.withAlpha(220),
          fontSize: baseFs,
          height: 2.0,
          fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
        );

        final hlStyle = TextStyle(
          fontFamily: font,
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
              color: isHighlight ? AppColors.highlightBorder : AppColors.divider,
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
                    _AyaBadge(number: aya.ayaId, highlighted: isHighlight),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'آية ${aya.ayaId}',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: isHighlight ? AppColors.accent : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: isHighlight
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isHighlight)
                      const Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.accent,
                        size: 18,
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

                _MetaChips(aya: aya),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AyaBadge extends StatelessWidget {
  final int number;
  final bool highlighted;
  const _AyaBadge({required this.number, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: highlighted
              ? [const Color(0xFFD4AF37), const Color(0xFF8B6914)]
              : [const Color(0xFF2A3D55), const Color(0xFF1A2840)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: highlighted
            ? [BoxShadow(color: AppColors.accent.withAlpha(77), blurRadius: 8)]
            : [],
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: highlighted ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MetaChips extends StatelessWidget {
  final AyaModel aya;
  const _MetaChips({required this.aya});

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
