import 'package:flutter/material.dart';

import '../../../../../data/repositories/quran_repository.dart';
import '../../surah_page.dart';
import 'ayah_card_widget.dart';

class AyaCard extends StatelessWidget {
  final SearchResultItem item;
  final int index;
  final FocusNode searchFocusNode;

  const AyaCard({
    super.key,
    required this.item,
    required this.index,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final aya = item.aya;
    return GestureDetector(
      onTap: () {
        searchFocusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahPage(
              suraId: aya.suraId,
              suraName: aya.suraName ?? '',
              highlightAyaId: aya.ayaId,
              searchQuery: item.highlightTerms.join(' '),
            ),
          ),
        );
      },
      // AyahCardWidget owns its scoped AudioCubit + reads SettingsCubit.
      child: AyahCardWidget(
        aya: aya,
        highlightTerms: item.highlightTerms,
        isHighlight: false,
      ),
    );
  }
}
