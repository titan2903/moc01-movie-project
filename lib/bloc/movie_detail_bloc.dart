import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'movie_detail_event.dart';
import 'movie_detail_state.dart';
import '../main.dart';
import '../constants.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final Dio _dio = Dio();

  MovieDetailBloc() : super(MovieDetailInitial()) {
    on<FetchMovieDetailEvent>(_onFetchMovieDetail);
  }

  Future<void> _onFetchMovieDetail(
    FetchMovieDetailEvent event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(MovieDetailLoading());

    final cacheKey = 'cached_movie_detail_${event.movieId}';

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
          emit(const MovieDetailError('API_KEY is missing in .env file'));
          return;
        }

        final response = await _dio.get(
          '$movieBaseUrl/movie/${event.movieId}',
          queryParameters: {'api_key': apiKey, 'language': 'en-US'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = response.data;
          final movieDetail = Movie.fromJson(data);

          // Cache to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, jsonEncode(data));

          emit(MovieDetailLoaded(movieDetail));
        } else {
          emit(
            MovieDetailError(
              'Failed to fetch movie detail: ${response.statusCode}',
            ),
          );
        }
      } else {
        // Load from Cache
        final prefs = await SharedPreferences.getInstance();
        final cachedData = prefs.getString(cacheKey);

        if (cachedData != null) {
          final Map<String, dynamic> data = jsonDecode(cachedData);
          final movieDetail = Movie.fromJson(data);
          emit(MovieDetailLoaded(movieDetail));
        } else {
          emit(
            const MovieDetailError(
              'No internet connection and no cached data available.',
            ),
          );
        }
      }
    } catch (e) {
      emit(MovieDetailError('An error occurred: $e'));
    }
  }
}
