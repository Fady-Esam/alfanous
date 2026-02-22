library;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/aya_model.dart';
import '../../data/repositories/quran_repository.dart';

sealed class SearchState extends Equatable {
  const SearchState();
}

final class SearchInitial extends SearchState {
  const SearchInitial();

  @override
  List<Object?> get props => [];
}

final class SearchLoading extends SearchState {
  final String query;

  const SearchLoading({required this.query});

  @override
  List<Object?> get props => [query];
}

final class SearchSuccess extends SearchState {
  final List<AyaModel> results;

  final String normalizedQuery;

  int get count => results.length;

  bool get isEmpty => results.isEmpty;

  const SearchSuccess({required this.results, required this.normalizedQuery});

  @override
  List<Object?> get props => [results, normalizedQuery];
}

final class SearchError extends SearchState {
  final String message;

  final Object? exception;

  const SearchError({required this.message, this.exception});

  @override
  List<Object?> get props => [message];
}

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

      final normalizedQuery = _normalizeForHighlight(trimmed);

      emit(SearchSuccess(results: results, normalizedQuery: normalizedQuery));
    } catch (e/*, stackTrace*/) {
      //print('[SearchCubit] Search failed: $e\n$stackTrace');

      emit(SearchError(message: _humanReadableError(e), exception: e));
    }
  }

  void clear() => emit(const SearchInitial());

  String _normalizeForHighlight(String query) {
    try {
      return query.trim();
    } catch (_) {
      return query;
    }
  }

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
