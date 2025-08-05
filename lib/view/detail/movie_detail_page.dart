import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:cineverse/view/detail/widgets/cast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  late Future<Movie> _movieDetailsFuture;
  final MovieRepository _repository = MovieRepositoryImpl();
  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;
  bool _isBookmarked = false;

  // This initState method is crucial and was missing from the last version.
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Fetches movie details and checks the initial bookmark status.
  void _fetchData() {
    _movieDetailsFuture = _repository.getMovieDetails(widget.movie.id);
    _repository.isBookmarked(widget.movie.id).then((isBookmarked) {
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    });
  }

  /// Toggles the bookmark status in the database and updates the UI.
  void _toggleBookmark(Movie movie) {
    if (_isBookmarked) {
      _repository.removeBookmark(movie.id);
    } else {
      _repository.addBookmark(movie);
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  /// Shares the movie title and a fake deep link.
  void _shareMovie(Movie movie) {
    final String deepLink = 'cineverse://movie/${movie.id}';
    final String shareText =
        'Check out this movie: ${movie.title}!\nFind it in the Cineverse app: $deepLink';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Movie>(
        future: _movieDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final movie = snapshot.data!;
            return _buildMovieDetails(context, movie);
          } else {
            return const Center(child: Text("No movie details found."));
          }
        },
      ),
    );
  }

  /// Builds the rich UI for the movie details.
  Widget _buildMovieDetails(BuildContext context, Movie movie) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareMovie(movie),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              movie.title,
              style: const TextStyle(shadows: [Shadow(blurRadius: 10)]),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (movie.backdropPath != null)
                  Image.network(
                    '$imageBaseUrl${movie.backdropPath}',
                    fit: BoxFit.cover,
                  )
                else
                  Container(color: Colors.grey[800]),
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
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // All the UI sections (Title, Metadata, Overview, Button, Cast)
                // remain the same as the previous complete version.
                Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(movie.year, style: TextStyle(color: Colors.grey[400])),
                    if (movie.runtime != null) ...[
                       const Text(" • ", style: TextStyle(color: Colors.grey)),
                      Text("${movie.runtime} min", style: TextStyle(color: Colors.grey[400])),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(movie.posterPath != null)
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
                ElevatedButton.icon(
                  icon: Icon(_isBookmarked ? Icons.check : Icons.add),
                  label: Text(_isBookmarked ? "On Watchlist" : "Add to Watchlist"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBookmarked ? Colors.grey[700] : Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  onPressed: () => _toggleBookmark(movie),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                if (movie.credits != null && movie.credits!.cast.isNotEmpty) ...[
                  Text("Top Cast", style: Theme.of(context).textTheme.titleLarge),
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
