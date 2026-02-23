import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/repositories/quran_repository.dart';
import '../../../cubit/search_cubit/search_cubit.dart';
import '../../../cubit/search_cubit/search_states.dart';
import '../aya/aya_card.dart';

class SearchResultsList extends StatefulWidget {
  final List<SearchResultItem> results;
  final FocusNode searchFocusNode;

  const SearchResultsList({
    super.key,
    required this.results,
    required this.searchFocusNode,
  });

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SearchCubit>().state;
    final hasReachedMax = state is SearchSuccess && state.hasReachedMax;
    final isFetchingMore = state is SearchSuccess && state.isFetchingMore;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      physics: const BouncingScrollPhysics(),

      itemCount: widget.results.length + (hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= widget.results.length) {
          if (!isFetchingMore) return const SizedBox.shrink();

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ),
          );
        }
        return AyaCard(
          item: widget.results[index],
          index: index,
          searchFocusNode: widget.searchFocusNode,
        );
      },
    );
  }
}
