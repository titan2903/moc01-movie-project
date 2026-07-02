import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'bloc/favorite_bloc.dart';
import 'bloc/favorite_event.dart';
import 'bloc/favorite_state.dart';
import 'bloc/movie_bloc.dart';
import 'bloc/movie_event.dart';
import 'bloc/movie_state.dart';
import 'bloc/movie_detail_bloc.dart';
import 'bloc/movie_detail_event.dart';
import 'bloc/movie_detail_state.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FavoriteBloc>(create: (context) => FavoriteBloc()),
        BlocProvider<MovieBloc>(create: (context) => MovieBloc()),
      ],
      child: MaterialApp(
        title: 'Movie Project',
        debugShowCheckedModeBanner: true, // Displays the DEBUG banner
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF9F9FC),
          useMaterial3: true,
        ),
        home: const MovieProjectScreen(),
      ),
    );
  }
}

class Movie {
  final int id;
  final String title;
  final String releaseDate;
  final double rating;
  final String synopsis;
  final String? posterPath;
  final String? backdropPath;
  final int? runtime;
  final List<String>? genres;
  final String? tagline;

  const Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.rating,
    required this.synopsis,
    this.posterPath,
    this.backdropPath,
    this.runtime,
    this.genres,
    this.tagline,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    List<String>? genresList;
    if (json['genres'] != null) {
      genresList = (json['genres'] as List)
          .map((genre) => (genre['name'] ?? '').toString())
          .toList();
    }

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'Unknown',
      releaseDate: json['release_date'] ?? '',
      rating: (json['vote_average'] ?? 0).toDouble(),
      synopsis: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      runtime: json['runtime'],
      genres: genresList,
      tagline: json['tagline'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'release_date': releaseDate,
      'vote_average': rating,
      'overview': synopsis,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'runtime': runtime,
      'genres': genres != null
          ? genres!.map((g) => {'name': g}).toList()
          : null,
      'tagline': tagline,
    };
  }
}

class MovieProjectScreen extends StatefulWidget {
  const MovieProjectScreen({super.key});

  @override
  State<MovieProjectScreen> createState() => _MovieProjectScreenState();
}

class _MovieProjectScreenState extends State<MovieProjectScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch movies when screen initializes
    context.read<MovieBloc>().add(FetchMoviesEvent());

    // Listen to scroll events to trigger infinite pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<MovieBloc>().add(FetchMoviesEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return maxScroll - currentScroll <= 200;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Catalog',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE5E5EA), height: 1.0),
        ),
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, snapshot) {
          if (snapshot is MovieLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot is MovieError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  snapshot.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (snapshot is MovieLoaded) {
            final movies = snapshot.movies;
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                itemCount: snapshot.hasReachedMax
                    ? movies.length
                    : movies.length + 1,
                itemBuilder: (context, index) {
                  if (index >= movies.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final movie = movies[index];
                  return BlocBuilder<FavoriteBloc, FavoriteState>(
                    builder: (context, state) {
                      final isFavorited = state.favorites.contains(movie.title);
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MovieDetailScreen(movie: movie),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Movie Poster
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: movie.posterPath != null
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                                          width: 75,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                width: 75,
                                                height: 110,
                                                color: const Color(0xFFE2E2E6),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                width: 75,
                                                height: 110,
                                                color: const Color(0xFFE2E2E6),
                                                child: const Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          width: 75,
                                          height: 110,
                                          color: const Color(0xFFE2E2E6),
                                          child: const Icon(
                                            Icons.movie_creation_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                // Movie Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        movie.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A1A1A),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        movie.releaseDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8E8E93),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Color(0xFFFFCC00),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            movie.rating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Favorite button
                                IconButton(
                                  icon: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorited
                                        ? const Color(0xFFFF3B30)
                                        : const Color(0xFF8E8E93),
                                  ),
                                  onPressed: () {
                                    context.read<FavoriteBloc>().add(
                                      ToggleFavoriteEvent(movie.title),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MovieDetailBloc()..add(FetchMovieDetailEvent(movie.id)),
      child: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, detailState) {
          if (detailState is MovieDetailLoading) {
            return const Scaffold(
              backgroundColor: Color(0xFFF9F9FC),
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (detailState is MovieDetailError) {
            return Scaffold(
              backgroundColor: const Color(0xFFF9F9FC),
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1A1A1A),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Error',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        detailState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (detailState is MovieDetailLoaded) {
            final movieDetail = detailState.movie;

            return BlocBuilder<FavoriteBloc, FavoriteState>(
              builder: (context, favState) {
                final isFavorited = favState.favorites.contains(
                  movieDetail.title,
                );
                final genresStr = movieDetail.genres?.join(', ') ?? 'N/A';
                final runtimeStr = movieDetail.runtime != null
                    ? '${movieDetail.runtime} min'
                    : 'N/A';

                return Scaffold(
                  backgroundColor: const Color(0xFFF9F9FC),
                  appBar: AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF1A1A1A),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text(
                      'Movie Details',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(1.0),
                      child: Container(
                        color: const Color(0xFFE5E5EA),
                        height: 1.0,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited
                              ? const Color(0xFFFF3B30)
                              : const Color(0xFF8E8E93),
                        ),
                        onPressed: () {
                          context.read<FavoriteBloc>().add(
                            ToggleFavoriteEvent(movieDetail.title),
                          );
                        },
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cinematic Backdrop Banner with Floating Poster
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Backdrop Image
                            Container(
                              width: double.infinity,
                              height: 220,
                              color: const Color(0xFFE2E2E6),
                              child: movieDetail.backdropPath != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          'https://image.tmdb.org/t/p/w780${movieDetail.backdropPath}',
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          const Center(
                                            child: Icon(
                                              Icons.movie_creation_outlined,
                                              color: Colors.white,
                                              size: 64,
                                            ),
                                          ),
                                    )
                                  : (movieDetail.posterPath != null
                                        ? CachedNetworkImage(
                                            imageUrl:
                                                'https://image.tmdb.org/t/p/w500${movieDetail.posterPath}',
                                            width: double.infinity,
                                            height: 220,
                                            fit: BoxFit.cover,
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => const Center(
                                                  child: Icon(
                                                    Icons
                                                        .movie_creation_outlined,
                                                    color: Colors.white,
                                                    size: 64,
                                                  ),
                                                ),
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.movie_creation_outlined,
                                              color: Colors.white,
                                              size: 64,
                                            ),
                                          )),
                            ),
                            // Bottom Gradient Overlay for transition
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFFF9F9FC).withOpacity(0.8),
                                      const Color(0xFFF9F9FC),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Floating Vertical Poster Card
                            Positioned(
                              bottom: -40,
                              left: 20,
                              child: Container(
                                width: 100,
                                height: 150,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: movieDetail.posterPath != null
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              'https://image.tmdb.org/t/p/w500${movieDetail.posterPath}',
                                          width: 100,
                                          height: 150,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: const Color(0xFFE2E2E6),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: const Color(0xFFE2E2E6),
                                                child: const Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: const Color(0xFFE2E2E6),
                                          child: const Icon(
                                            Icons.movie_creation_outlined,
                                            color: Colors.white,
                                            size: 48,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Spacer for the floating poster card
                              const SizedBox(width: 110),
                              // Title and Tagline / Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Movie Title
                                    Text(
                                      movieDetail.title,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A),
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    if (movieDetail.tagline != null &&
                                        movieDetail.tagline!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '"${movieDetail.tagline}"',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF8E8E93),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Metadata Section
                              Row(
                                children: [
                                  // Release Date
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF8E8E93),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    movieDetail.releaseDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Rating
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFCC00),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    movieDetail.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const Text(
                                    ' / 10',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Genres & Runtime Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF8E8E93),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    runtimeStr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8E8E93),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Genres: $genresStr',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF8E8E93),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Divider
                              Container(
                                height: 1,
                                color: const Color(0xFFE5E5EA),
                              ),
                              const SizedBox(height: 20),
                              // Synopsis Header
                              const Text(
                                'Synopsis',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Synopsis Text
                              Text(
                                movieDetail.synopsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Big Premium Favorite Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<FavoriteBloc>().add(
                                      ToggleFavoriteEvent(movieDetail.title),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isFavorited
                                        ? const Color(0xFFFFE5E5)
                                        : Colors.white,
                                    foregroundColor: isFavorited
                                        ? const Color(0xFFFF3B30)
                                        : const Color(0xFF1A1A1A),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isFavorited
                                            ? const Color(
                                                0xFFFF3B30,
                                              ).withOpacity(0.5)
                                            : const Color(0xFFE5E5EA),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  icon: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                  ),
                                  label: Text(
                                    isFavorited
                                        ? 'Remove from Favorites'
                                        : 'Add to Favorites',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
