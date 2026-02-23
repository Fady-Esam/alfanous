import 'package:equatable/equatable.dart';


class FavoritesState extends Equatable {
  
  final Set<int> favoriteGids;

  const FavoritesState({required this.favoriteGids});

  bool isFavorite(int gid) => favoriteGids.contains(gid);

  @override
  List<Object?> get props => [favoriteGids];
}

