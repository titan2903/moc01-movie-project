import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/favorite_bloc.dart';
import 'bloc/favorite_event.dart';
import 'bloc/favorite_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteBloc(),
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
  final String title;
  final String releaseDate;
  final double rating;
  final String synopsis;

  const Movie({
    required this.title,
    required this.releaseDate,
    required this.rating,
    required this.synopsis,
  });
}

class MovieProjectScreen extends StatefulWidget {
  const MovieProjectScreen({super.key});

  @override
  State<MovieProjectScreen> createState() => _MovieProjectScreenState();
}

class _MovieProjectScreenState extends State<MovieProjectScreen> {
  late Future<List<Movie>> _moviesFuture;

  static const List<Movie> _movies = [
    Movie(
      title: 'Inception',
      releaseDate: '2010-07-15',
      rating: 8.4,
      synopsis: 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O., but his tragic past may doom the project.',
    ),
    Movie(
      title: 'Interstellar',
      releaseDate: '2014-11-07',
      rating: 8.6,
      synopsis: 'When Earth becomes uninhabitable, a team of explorers travels through a wormhole in space in an attempt to ensure humanity\'s survival, searching for a new home among the stars.',
    ),
    Movie(
      title: 'Tenet',
      releaseDate: '2020-08-22',
      rating: 7.4,
      synopsis: 'Armed with only one word, Tenet, and fighting for the survival of the entire world, a Protagonist journeys through a twilight world of international espionage on a mission that will unfold in something beyond real time.',
    ),
    Movie(
      title: 'The Dark Knight Rises',
      releaseDate: '2012-07-16',
      rating: 9.0,
      synopsis: 'Eight years after the Joker\'s reign of anarchy, Batman, with the help of the enigmatic Catwoman, is forced from his exile to save Gotham City from the brutal guerrilla terrorist Bane.',
    ),
    Movie(
      title: 'Avatar: The Way of Water',
      releaseDate: '2022-12-14',
      rating: 7.6,
      synopsis: 'Jake Sully lives with his newfound family formed on the extrasolar moon Pandora. Once a familiar threat returns to finish what was previously started, Jake must work with Neytiri and the army of the Na\'vi race to protect their home.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate loading movies from a network API
    _moviesFuture = Future.delayed(const Duration(seconds: 2), () => _movies);
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
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading movies.'));
          }

          final movies = snapshot.data!;
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: movies.length,
              itemBuilder: (context, index) {
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
                              builder: (context) => MovieDetailScreen(
                                movie: movie,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Gray Movie Poster Placeholder
                              Container(
                                width: 75,
                                height: 110,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E2E6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.movie_creation_outlined,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Movie Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          movie.rating.toString(),
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
                                  isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: isFavorited
                                      ? const Color(0xFFFF3B30)
                                      : const Color(0xFF8E8E93),
                                ),
                                onPressed: () {
                                  context.read<FavoriteBloc>().add(ToggleFavoriteEvent(movie.title));
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
        },
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final isFavorited = state.favorites.contains(movie.title);

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9FC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A1A), size: 20),
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
              child: Container(color: const Color(0xFFE5E5EA), height: 1.0),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? const Color(0xFFFF3B30) : const Color(0xFF8E8E93),
                ),
                onPressed: () {
                  context.read<FavoriteBloc>().add(ToggleFavoriteEvent(movie.title));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large Poster Header Placeholder
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E2E6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.movie_creation_outlined,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Title
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Metadata row
                      Row(
                        children: [
                          // Release Date Icon & Text
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF8E8E93),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.releaseDate,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Rating Icon & Text
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFCC00),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toString(),
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
                        movie.synopsis,
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
                            context.read<FavoriteBloc>().add(ToggleFavoriteEvent(movie.title));
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
                                    ? const Color(0xFFFF3B30).withOpacity(0.5)
                                    : const Color(0xFFE5E5EA),
                                width: 1.5,
                              ),
                            ),
                          ),
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            size: 20,
                          ),
                          label: Text(
                            isFavorited ? 'Remove from Favorites' : 'Add to Favorites',
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
}
