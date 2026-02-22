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
      final results = await _repository.searchAyat(trimmed);
      emit(SearchSuccess(results: results));
    } catch (e, stackTrace) {
      print('[SearchCubit] Search failed: $e\n$stackTrace');

      emit(SearchError(message: _humanReadableError(e), exception: e));
    }
  }

  void clear() => emit(const SearchInitial());

  String _humanReadableError(Object e) {
    if (e is FormatException) {
      return 'Invalid search query format. Please try again.';
    }

    final msg = e.toString();
    if (msg.toLowerCase().contains('database')) {
      return 'Database error. Please restart the app.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
