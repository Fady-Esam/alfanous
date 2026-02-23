import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/favorites_repository.dart';
import 'favorites_states.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit({required FavoritesRepository repository})
    : _repository = repository,
      super(const FavoritesState(favoriteGids: {}));

  Future<void> loadFavorites() async {
    try {
      final gids = await _repository.getAllFavoriteGids();
      if (!isClosed) {
        emit(FavoritesState(favoriteGids: gids));
      }
    } catch (_) {}
  }

  Future<void> toggleFavorite(int gid) async {
    try {
      final isCurrentlyFav = state.isFavorite(gid);
      final newSet = Set<int>.from(state.favoriteGids);

      if (isCurrentlyFav) {
        newSet.remove(gid);
      } else {
        newSet.add(gid);
      }
      emit(FavoritesState(favoriteGids: newSet));

      final nowFav = await _repository.toggleFavorite(gid);

      if (nowFav != !isCurrentlyFav && !isClosed) {
        final syncedSet = await _repository.getAllFavoriteGids();
        emit(FavoritesState(favoriteGids: syncedSet));
      }
    } catch (_) {
      if (!isClosed) {
        final syncedSet = await _repository.getAllFavoriteGids();
        emit(FavoritesState(favoriteGids: syncedSet));
      }
    }
  }
}
