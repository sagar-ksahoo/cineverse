import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  // Use a Future to handle the asynchronous data fetching
  late Future<Movie> _movieDetailsFuture;
  final MovieRepository _repository = MovieRepositoryImpl();
  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  @override
  void initState() {
    super.initState();
    // Fetch the movie details when the page loads
    _movieDetailsFuture = _repository.getMovieDetails(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use a FutureBuilder to handle the loading, error, and data states
      body: FutureBuilder<Movie>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            // If data is loaded, build the rich UI
            return _buildMovieDetails(context, movie);
          } else {
            return const Center(child: Text("No movie details found."));
          }
        },
      ),
    );
  }

  // Helper method to build the main UI
  Widget _buildMovieDetails(BuildContext context, Movie movie) {
    return CustomScrollView(
      slivers: [
        // The collapsing app bar with the backdrop image
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              movie.title,
              style: const TextStyle(shadows: [Shadow(blurRadius: 10)]),
            ),
            background: movie.backdropPath != null
                ? Image.network(
                    '$imageBaseUrl${movie.backdropPath}',
                    fit: BoxFit.cover,
                  )
                : Container(color: Colors.grey[800]),
          ),
        ),
        // The rest of the content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info row: Year, Runtime, Genres
                Row(
                  children: [
                    Text(movie.year),
                    const Text(" • "),
                    if (movie.runtime != null) ...[
                      Text("${movie.runtime} min"),
                      const Text(" • "),
                    ],
                    // Display first genre if available
                    if (movie.genres != null && movie.genres!.isNotEmpty)
                      Expanded(
                        child: Text(
                          movie.genres!.first.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      movie.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Overview
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  movie.overview,
                  style: TextStyle(height: 1.5, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
