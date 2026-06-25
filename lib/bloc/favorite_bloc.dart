import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(const FavoriteState()) {
    on<ToggleFavoriteEvent>((event, emit) {
      final currentFavorites = Set<String>.from(state.favorites);
      if (currentFavorites.contains(event.movieTitle)) {
        currentFavorites.remove(event.movieTitle);
      } else {
        currentFavorites.add(event.movieTitle);
      }
      emit(FavoriteState(favorites: currentFavorites));
    });
  }
}
