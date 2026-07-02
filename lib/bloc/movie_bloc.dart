import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'movie_event.dart';
import 'movie_state.dart';
import '../main.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  static const String _cacheKey = 'cached_movies';
  final Dio _dio = Dio();

  MovieBloc() : super(MovieInitial()) {
    on<FetchMoviesEvent>(_onFetchMovies);
  }

  Future<void> _onFetchMovies(
    FetchMoviesEvent event,
    Emitter<MovieState> emit,
  ) async {
    // If already loading or reached max, do not fetch
    if (state is MovieLoading) return;
    if (state is MovieLoaded && (state as MovieLoaded).hasReachedMax) return;

    final isInitial = state is MovieInitial;
    List<Movie> currentMovies = [];
    int nextPage = 1;

    if (state is MovieLoaded) {
      currentMovies = (state as MovieLoaded).movies;
      nextPage = (state as MovieLoaded).currentPage + 1;
    } else {
      emit(MovieLoading());
    }

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      bool isConnected = false;
      // ignore: unnecessary_type_check
      if (connectivityResult is List) {
        isConnected = !connectivityResult.contains(ConnectivityResult.none);
        // ignore: dead_code
      } else {
        isConnected = connectivityResult != ConnectivityResult.none;
      }

      if (isConnected) {
        final apiKey = dotenv.env['API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          emit(const MovieError('API_KEY is missing in .env file'));
          return;
        }

        final response = await _dio.get(
          'https://api.themoviedb.org/3/movie/now_playing',
          queryParameters: {
            'api_key': apiKey,
            'language': 'en-US',
            'page': nextPage,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> results = response.data['results'];
          final totalPages = response.data['total_pages'] ?? 1;
          final newMovies = results.map((json) => Movie.fromJson(json)).toList();
          final hasReachedMax = nextPage >= totalPages || newMovies.isEmpty;

          final allMovies = isInitial ? newMovies : currentMovies + newMovies;

          // Cache all accumulated movies to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final String encodedData = jsonEncode(allMovies.map((m) => m.toJson()).toList());
          await prefs.setString(_cacheKey, encodedData);

          emit(MovieLoaded(
            movies: allMovies,
            currentPage: nextPage,
            hasReachedMax: hasReachedMax,
          ));
        } else {
          if (isInitial) {
            emit(MovieError('Failed to fetch movies: ${response.statusCode}'));
          }
        }
      } else {
        // Offline Fallback
        if (isInitial) {
          final prefs = await SharedPreferences.getInstance();
          final cachedData = prefs.getString(_cacheKey);

          if (cachedData != null) {
            final List<dynamic> decodedList = jsonDecode(cachedData);
            final movies = decodedList.map((json) => Movie.fromJson(json)).toList();
            emit(MovieLoaded(
              movies: movies,
              currentPage: 1,
              hasReachedMax: true, // Offline has no more pages to load
            ));
          } else {
            emit(const MovieError('No internet connection and no cached data available.'));
          }
        } else {
          // If already loaded and user scrolls offline, just set reached max to true (no more offline pages)
          if (state is MovieLoaded) {
            emit((state as MovieLoaded).copyWith(hasReachedMax: true));
          }
        }
      }
    } catch (e) {
      if (isInitial) {
        emit(MovieError('An error occurred: $e'));
      }
    }
  }
}
