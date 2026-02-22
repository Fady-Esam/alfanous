import 'package:flutter/material.dart';

import '../../../../../data/repositories/quran_repository.dart';
import '../aya/aya_card.dart';

class SearchResultsList extends StatelessWidget {
  final List<SearchResultItem> results;

  const SearchResultsList({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return AyaCard(item: results[index], index: index);
      },
    );
  }
}
