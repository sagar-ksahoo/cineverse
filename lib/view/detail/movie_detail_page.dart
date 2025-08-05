import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:cineverse/view/detail/widgets/cast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  // A Future to handle fetching the detailed movie data asynchronously.
  late Future<Movie> _movieDetailsFuture;
  final MovieRepository _repository = MovieRepositoryImpl();
  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  // State variable to track if the current movie is bookmarked.
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    // When the page loads, fetch the full details and check the bookmark status.
    _fetchData();
  }

  /// Fetches movie details from the repository and checks if the movie is bookmarked.
  void _fetchData() {
    _movieDetailsFuture = _repository.getMovieDetails(widget.movie.id);
    _repository.isBookmarked(widget.movie.id).then((isBookmarked) {
      // Check if the widget is still in the tree before updating state.
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    });
  }

  /// Toggles the bookmark status for the current movie, updating the database and UI.
  void _toggleBookmark(Movie movie) {
    if (_isBookmarked) {
      _repository.removeBookmark(movie.id);
    } else {
      // We use the detailed movie object (which has all fields) for bookmarking.
      _repository.addBookmark(movie);
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FutureBuilder handles the different states of our data fetching:
      // loading, error, and success.
      body: FutureBuilder<Movie>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // If data is successfully loaded, build the rich UI.
            final movie = snapshot.data!;
            return _buildMovieDetails(context, movie);
          } else {
            return const Center(child: Text("No movie details found."));
          }
        },
      ),
    );
  }

  /// Builds the main UI for the detail page using the fetched movie data.
  Widget _buildMovieDetails(BuildContext context, Movie movie) {
    return CustomScrollView(
      slivers: [
        // A flexible, collapsing app bar with the backdrop image.
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              movie.title,
              style: const TextStyle(shadows: [Shadow(blurRadius: 10)]),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // The backdrop image.
                if (movie.backdropPath != null)
                  Image.network(
                    '$imageBaseUrl${movie.backdropPath}',
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: Colors.grey[800]),
                // A gradient overlay to ensure the back arrow and title are visible.
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.4],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // The main content area of the page.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SECTION: Title and Metadata
                Text(movie.title,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(movie.year, style: TextStyle(color: Colors.grey[400])),
                    if (movie.runtime != null) ...[
                      const Text(" • ", style: TextStyle(color: Colors.grey)),
                      Text("${movie.runtime} min",
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                if (movie.genres != null && movie.genres!.isNotEmpty)
                  Wrap(
                    spacing: 8.0,
                    children: movie.genres!
                        .map((genre) => Chip(
                              label: Text(genre.name),
                              backgroundColor: Colors.grey[800],
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 16),

                // SECTION: Poster and Overview
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movie.posterPath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '$imageBaseUrl${movie.posterPath}',
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        movie.overview,
                        style: TextStyle(height: 1.5, color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // SECTION: Add to Watchlist Button
                ElevatedButton.icon(
                  icon: Icon(_isBookmarked ? Icons.check : Icons.add),
                  label:
                      Text(_isBookmarked ? "On Watchlist" : "Add to Watchlist"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isBookmarked ? Colors.grey[700] : Colors.amber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                  onPressed: () => _toggleBookmark(movie),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // SECTION: Top Cast
                if (movie.credits != null &&
                    movie.credits!.cast.isNotEmpty) ...[
                  Text("Top Cast",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: movie.credits!.cast.length,
                      itemBuilder: (context, index) {
                        return CastCard(castMember: movie.credits!.cast[index]);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
