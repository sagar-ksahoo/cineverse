import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:cineverse/view/detail/widgets/cast_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:share_plus/share_plus.dart';

class MovieDetailPage extends StatefulWidget {
  // The basic movie object passed from the previous screen.
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MovieRepository _repository = MovieRepositoryImpl();
  static final String imageBaseUrl = dotenv.env['TMDB_IMAGE_BASE_URL']!;

  // This will hold the full movie details when they are loaded.
  Movie? _detailedMovie;
  bool _isBookmarked = false;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    // Use the basic movie info immediately.
    _detailedMovie = widget.movie;
    // Now, try to fetch the full details and bookmark status.
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    // Check initial bookmark status using the ID we already have.
    _repository.isBookmarked(widget.movie.id).then((isBookmarked) {
      if (mounted) setState(() => _isBookmarked = isBookmarked);
    });

    // Try to fetch full details from the network.
    try {
      final fullDetails = await _repository.getMovieDetails(widget.movie.id);
      if (mounted) {
        setState(() {
          _detailedMovie = fullDetails;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint("Could not fetch full movie details: $e");
      // If it fails, we stop loading but keep the basic info.
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  void _toggleBookmark() {
    // Use the detailed movie if available, otherwise the basic one.
    final movieToBookmark = _detailedMovie ?? widget.movie;
    if (_isBookmarked) {
      _repository.removeBookmark(movieToBookmark.id);
    } else {
      _repository.addBookmark(movieToBookmark);
    }
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  void _shareMovie() {
    final movieToShare = _detailedMovie ?? widget.movie;
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is not available on the web.')),
      );
    } else {
      final String deepLink = 'cineverse://movie/${movieToShare.id}';
      final String shareText =
          'Check out this movie: ${movieToShare.title}!\nFind it in the Cineverse app: $deepLink';
      Share.share(shareText);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We no longer need a FutureBuilder for the whole screen.
    // We build the UI immediately with the data we have.
    return Scaffold(
      body: _buildMovieDetails(context, _detailedMovie!),
    );
  }

  Widget _buildMovieDetails(BuildContext context, Movie movie) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareMovie,
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
                // Use backdropPath if available, otherwise fallback to posterPath.
                Image.network(
                  '$imageBaseUrl${movie.backdropPath ?? movie.posterPath}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey[800]),
                ),
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
                // ... Title, Metadata, Poster/Overview sections are the same ...
                
                // --- UPDATED WATCHLIST BUTTON ---
                ElevatedButton.icon(
                  icon: Icon(_isBookmarked ? Icons.check : Icons.add),
                  label: Text(_isBookmarked ? "On Watchlist" : "Add to Watchlist"),
                  onPressed: _toggleBookmark, // No longer needs movie parameter
                  // ... style is the same ...
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                
                // --- UPDATED TOP CAST SECTION ---
                // Conditionally show the cast based on loading status.
                _isLoadingDetails
                    ? const Center(child: CircularProgressIndicator())
                    : (movie.credits != null && movie.credits!.cast.isNotEmpty)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                          )
                        : const SizedBox.shrink(), // Show nothing if cast isn't loaded
              ],
            ),
          ),
        ),
      ],
    );
  }
}
