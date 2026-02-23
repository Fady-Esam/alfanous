import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../cubit/search_cubit/search_cubit.dart';

class SearchPromptView extends StatelessWidget {
  const SearchPromptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFF5DEB3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ٱبۡدَأۡ بِٱلۡبَحۡثِ',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'اكتب كلمة أو جزءاً من آية للبحث عنها\nفي القرآن الكريم',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 40),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              HintChip(text: 'رحمة'),
              HintChip(text: 'صبر'),
              HintChip(text: 'الجنة'),
              HintChip(text: 'النور'),
            ],
          ),
        ],
      ),
    );
  }
}

class HintChip extends StatelessWidget {
  final String text;
  const HintChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<SearchCubit>().search(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          text,
          style: GoogleFonts.amiri(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
