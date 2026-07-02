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
    emit(MovieLoading());

    try {
      final connectivityResult = await Connectivity().checkConnectivity();

      // connectivity_plus 7.x returns a List<ConnectivityResult> or a single result depending on exact version.
      // But typically it's just checking if it's connected. Let's handle both.
      bool isConnected = false;
      // ignore: unnecessary_type_check
      if (connectivityResult is List) {
        isConnected = !connectivityResult.contains(ConnectivityResult.none);
        // ignore: dead_code
      } else {
        isConnected = connectivityResult != ConnectivityResult.none;
      }

      if (isConnected) {
        // Fetch from API
        final apiKey = dotenv.env['API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          emit(const MovieError('API_KEY is missing in .env file'));
          return;
        }

        final response = await _dio.get(
          'https://api.themoviedb.org/3/movie/now_playing',
          queryParameters: {'api_key': apiKey, 'language': 'en-US', 'page': 1},
        );

        if (response.statusCode == 200) {
          final List<dynamic> results = response.data['results'];
          final movies = results.map((json) => Movie.fromJson(json)).toList();

          // Cache to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final String encodedData = jsonEncode(results);
          await prefs.setString(_cacheKey, encodedData);

          emit(MovieLoaded(movies));
        } else {
          emit(
            MovieError(
              'Failed to fetch movies from API: ${response.statusCode}',
            ),
          );
        }
      } else {
        // Fetch from Local Cache
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(_cacheKey);

        if (cachedData != null) {
          final List<dynamic> results = jsonDecode(cachedData);
          final movies = results.map((json) => Movie.fromJson(json)).toList();
          emit(MovieLoaded(movies));
        } else {
          emit(
            const MovieError(
              'No internet connection and no cached data available.',
            ),
          );
        }
      }
    } catch (e) {
      emit(MovieError('An error occurred: $e'));
    }
  }
}
