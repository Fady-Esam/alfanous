
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quran_repository.dart';
import 'search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  final QuranRepository _repository;

  SearchCubit({required QuranRepository repository})
    : _repository = repository,
      super(const SearchInitial());

  Future<void> search(String query) async {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query: trimmed));

    try {
      final totalCount = await _repository.getTotalSearchCount(trimmed);
      final results = await _repository.searchAyat(trimmed);
      if (isClosed) return;

      emit(
        SearchSuccess(
          results: results,
          totalCount: totalCount,
          hasReachedMax: results.length < 50,
          isFetchingMore: false,
          query: trimmed,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      print('[SearchCubit] Search failed: $e');

      emit(SearchError(message: 'حدث خطأ أثناء البحث.', exception: e));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! SearchSuccess ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) {
      return;
    }

    emit(
      SearchSuccess(
        results: currentState.results,
        totalCount: currentState.totalCount,
        hasReachedMax: currentState.hasReachedMax,
        isFetchingMore: true,
        query: currentState.query,
      ),
    );

    try {
      final additionalResults = await _repository.searchAyat(
        currentState.query,
        offset: currentState.results.length,
      );

      if (isClosed) return;

      emit(
        SearchSuccess(
          results: List.of(currentState.results)..addAll(additionalResults),
          totalCount: currentState.totalCount,
          hasReachedMax: additionalResults.length < 50,
          isFetchingMore: false,
          query: currentState.query,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          SearchSuccess(
            results: currentState.results,
            totalCount: currentState.totalCount,
            hasReachedMax: currentState.hasReachedMax,
            isFetchingMore: false,
            query: currentState.query,
          ),
        );
      }
    }
  }

  void clear() => emit(const SearchInitial());
}
