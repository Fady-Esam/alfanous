import 'package:flutter/material.dart';

import '../../../../data/repositories/quran_repository.dart';
import '../../widgets/ayah_card_widget.dart';

class AyaCard extends StatelessWidget {
  final SearchResultItem item;
  final int index;

  const AyaCard({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final aya = item.aya;
    return AyahCardWidget(
      aya: aya,
      highlightTerms: item.highlightTerms,
      isHighlight: false,
    );
  }
}
