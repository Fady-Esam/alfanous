import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../cubit/search_cubit/search_cubit.dart';
import '../../../cubit/search_cubit/search_states.dart';
import '../../settings_page.dart';

const _kAnimationDuration = Duration(milliseconds: 350);

class SearchHeader extends StatelessWidget {
  final FocusNode searchFocusNode;

  const SearchHeader({super.key, required this.searchFocusNode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            color: AppColors.textSecondary,
            iconSize: 24,
            splashRadius: 24,
            onPressed: () {
              searchFocusNode.unfocus();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
            tooltip: 'الإعدادات',
          ),

          Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFF8B6914)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withAlpha(80),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'ق',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'الفانوس',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.amiri(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          BlocBuilder<SearchCubit, SearchState>(
            buildWhen: (prev, curr) =>
                curr is SearchSuccess || prev is SearchSuccess,
            builder: (_, state) {
              if (state is! SearchSuccess || state.isEmpty) {
                return const SizedBox(width: 48);
              }
              return AnimatedOpacity(
                opacity: 1.0,
                duration: _kAnimationDuration,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent, width: 0.8),
                  ),
                  child: Text(
                    '${state.totalCount} آية',
                    style: GoogleFonts.amiri(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
