import 'package:equatable/equatable.dart';

import '../../../data/repositories/quran_repository.dart';

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
  final List<SearchResultItem> results;

  final int totalCount;

  final bool hasReachedMax;

  final bool isFetchingMore;

  final String query;

  int get loadedCount => results.length;

  bool get isEmpty => results.isEmpty;

  const SearchSuccess({
    required this.results,
    required this.totalCount,
    required this.hasReachedMax,
    required this.isFetchingMore,
    required this.query,
  });

  @override
  List<Object?> get props => [
    results,
    totalCount,
    hasReachedMax,
    isFetchingMore,
    query,
  ];
}

final class SearchError extends SearchState {
  final String message;

  final Object? exception;

  const SearchError({required this.message, this.exception});

  @override
  List<Object?> get props => [message];
}
