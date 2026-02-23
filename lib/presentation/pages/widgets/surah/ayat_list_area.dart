import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/aya_model.dart';
import '../../../cubit/surah_cubit/surah_cubit.dart';
import '../../../cubit/surah_cubit/surah_states.dart';
import '../aya/ayah_card_widget.dart';
import 'error_view.dart';

class AyatListArea extends StatefulWidget {
  final int suraId;
  final int? highlightAyaId;
  final String searchQuery;

  const AyatListArea({
    super.key,
    required this.suraId,
    this.highlightAyaId,
    required this.searchQuery,
  });

  @override
  State<AyatListArea> createState() => _AyatListAreaState();
}

class _AyatListAreaState extends State<AyatListArea> {
  final ItemScrollController _itemScroll = ItemScrollController();
  final ItemPositionsListener _itemPos = ItemPositionsListener.create();

  bool _didScroll = false;

  void _scrollToHighlight(List<AyaModel> ayat) {
    if (_didScroll || widget.highlightAyaId == null) return;

    final targetIdx = ayat.indexWhere((a) => a.ayaId == widget.highlightAyaId);
    if (targetIdx < 0) return;

    _didScroll = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));

      if (!mounted || !_itemScroll.isAttached) return;

      _itemScroll.scrollTo(
        index: targetIdx,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurahCubit, SurahState>(
      builder: (context, state) {
        return switch (state) {
          SurahInitial() || SurahLoading() => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              strokeWidth: 3,
            ),
          ),
          SurahLoaded(:final ayat) => _buildPositionedList(ayat),
          SurahError(:final message) => ErrorView(
            message: message,
            onRetry: () => context.read<SurahCubit>().loadSurah(widget.suraId),
          ),
        };
      },
    );
  }

  Widget _buildPositionedList(List<AyaModel> ayat) {
    _scrollToHighlight(ayat);

    return ScrollablePositionedList.builder(
      itemCount: ayat.length,
      itemScrollController: _itemScroll,
      itemPositionsListener: _itemPos,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 40),
      itemBuilder: (ctx, i) {
        final aya = ayat[i];
        final isTarget = aya.ayaId == widget.highlightAyaId;

        return AyahCardWidget(
          aya: aya,
          highlightTerms: widget.searchQuery.isNotEmpty
              ? [widget.searchQuery]
              : const [],
          isHighlight: isTarget,
        );
      },
    );
  }
}
