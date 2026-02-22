import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/search_cubit.dart';
import 'search_prompt_view.dart';
import 'search_loading_view.dart';
import 'no_result_view.dart';
import 'search_results_list.dart';
import 'search_error_view.dart';

const _kAnimationDuration = Duration(milliseconds: 350);

class SearchBody extends StatelessWidget {
  const SearchBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: _kAnimationDuration,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: switch (state) {
            SearchInitial() => const SearchPromptView(key: ValueKey('prompt')),
            SearchLoading() => const SearchLoadingView(
              key: ValueKey('loading'),
            ),
            SearchSuccess(:final results) when results.isEmpty => NoResultsView(
              key: const ValueKey('empty'),
              query: results.isEmpty ? '' : '',
            ),
            SearchSuccess(:final results) => SearchResultsList(
              key: const ValueKey('results'),
              results: results,
            ),
            SearchError(:final message) => SearchErrorView(
              key: const ValueKey('error'),
              message: message,
            ),
          },
        );
      },
    );
  }
}
