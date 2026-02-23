import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'ayat_list_area.dart';
import 'bism_allah_banner.dart';
import 'surah_sliver_app_bar.dart';

class SurahView extends StatelessWidget {
  final int suraId;
  final String suraName;
  final int? highlightAyaId;
  final String searchQuery;

  const SurahView({
    super.key,
    required this.suraId,
    required this.suraName,
    this.highlightAyaId,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SurahSliverAppBar(
            suraId: suraId,
            suraName: suraName,
            highlightAyaId: highlightAyaId,
          ),
        ],
        body: Column(
          children: [
            BismAllahBanner(suraId: suraId),
            Expanded(
              child: AyatListArea(
                suraId: suraId,
                highlightAyaId: highlightAyaId,
                searchQuery: searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
