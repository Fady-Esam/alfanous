import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../settings_page.dart';
import 'surah_header.dart';

class SurahSliverAppBar extends StatelessWidget {
  final int suraId;
  final String suraName;
  final int? highlightAyaId;

  const SurahSliverAppBar({
    super.key,
    required this.suraId,
    required this.suraName,
    this.highlightAyaId,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final expandedH = (120 * textScale).clamp(160.0, 300.0);

    return SliverAppBar(
      expandedHeight: expandedH,
      pinned: true,
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
            splashRadius: 20,
            tooltip: 'الإعدادات',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SurahHeader(
          suraId: suraId,
          suraName: suraName,
          highlightAyaId: highlightAyaId,
        ),
      ),
    );
  }
}
