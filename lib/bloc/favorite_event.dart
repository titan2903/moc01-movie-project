import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  const FavoriteEvent();

  @override
  List<Object> get props => [];
}

class ToggleFavoriteEvent extends FavoriteEvent {
  final String movieTitle;

  const ToggleFavoriteEvent(this.movieTitle);

  @override
  List<Object> get props => [movieTitle];
}
