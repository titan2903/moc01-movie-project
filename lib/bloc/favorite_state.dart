import 'package:equatable/equatable.dart';

class FavoriteState extends Equatable {
  final Set<String> favorites;

  const FavoriteState({this.favorites = const {}});

  FavoriteState copyWith({Set<String>? favorites}) {
    return FavoriteState(
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object> get props => [favorites.toList()..sort()];
}
