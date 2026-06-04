import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Project',
      debugShowCheckedModeBanner:
          true, // Displays the DEBUG banner exactly like in the image
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF9F9FC),
        useMaterial3: true,
      ),
      home: const MovieProjectScreen(),
    );
  }
}

class Movie {
  final String title;
  final String releaseDate;
  final double rating;

  const Movie({
    required this.title,
    required this.releaseDate,
    required this.rating,
  });
}

class MovieProjectScreen extends StatelessWidget {
  const MovieProjectScreen({super.key});

  static const List<Movie> _movies = [
    Movie(title: 'Inception', releaseDate: '2010-07-15', rating: 8.4),
    Movie(title: 'Interstellar', releaseDate: '2014-11-07', rating: 8.6),
    Movie(title: 'Tenet', releaseDate: '2020-08-22', rating: 7.4),
    Movie(
      title: 'The Dark Knight Rises',
      releaseDate: '2012-07-16',
      rating: 9.0,
    ),
    Movie(
      title: 'Avatar: The Way of Water',
      releaseDate: '2022-12-14',
      rating: 7.6,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Movie Project',
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
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: _movies.length,
          itemBuilder: (context, index) {
            final movie = _movies[index];
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gray Movie Poster Placeholder
                  Container(
                    width: 75,
                    height: 110,
                    decoration: const BoxDecoration(color: Color(0xFFE2E2E6)),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
