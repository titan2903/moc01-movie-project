import 'package:equatable/equatable.dart';

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchMovieDetailEvent extends MovieDetailEvent {
  final int movieId;

  const FetchMovieDetailEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}
