import 'package:equatable/equatable.dart';
import '../main.dart';

abstract class MovieState extends Equatable {
  const MovieState();
  
  @override
  List<Object?> get props => [];
}

class MovieInitial extends MovieState {}

class MovieLoading extends MovieState {}

class MovieLoaded extends MovieState {
  final List<Movie> movies;
  final int currentPage;
  final bool hasReachedMax;

  const MovieLoaded({
    required this.movies,
    this.currentPage = 1,
    this.hasReachedMax = false,
  });

  MovieLoaded copyWith({
    List<Movie>? movies,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return MovieLoaded(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [movies, currentPage, hasReachedMax];
}

class MovieError extends MovieState {
  final String message;

  const MovieError(this.message);

  @override
  List<Object?> get props => [message];
}
