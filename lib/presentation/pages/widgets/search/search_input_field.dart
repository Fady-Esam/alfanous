import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

class SearchInputField extends StatelessWidget {
  final Animation<double> barElevation;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  const SearchInputField({
    super.key,
    required this.barElevation,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: barElevation,
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withAlpha(
                  (barElevation.value * 8).toInt(),
                ),
                blurRadius: barElevation.value * 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
        child: TextField(
          controller: searchController,
          focusNode: searchFocusNode,
          autofocus: false,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: GoogleFonts.amiri(color: AppColors.textPrimary, fontSize: 18),
          cursorColor: AppColors.accent,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'ابحث في القرآن الكريم…',
            hintStyle: GoogleFonts.amiri(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
            hintTextDirection: TextDirection.rtl,
            filled: true,
            fillColor: AppColors.searchBarBg,

            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),

            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (_, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: onClearSearch,
                  tooltip: 'مسح',
                );
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.divider, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
