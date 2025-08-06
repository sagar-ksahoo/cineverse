import 'package:cineverse/models/movie.dart';
import '../repository/movie_repository.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final MovieRepository _repository = MovieRepositoryImpl();

  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _trendingMovies;

  List<Movie> _nowPlayingMovies = [];
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;

  List<Movie> _popularMovies = [];
  List<Movie> get popularMovies => _popularMovies;

  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _topRatedMovies;

  // We no longer need a single isLoading flag.
  // The UI will show cached data instead of a spinner.

  HomeViewModel() {
    // Start the data loading process when the ViewModel is created.
    loadMovies();
  }

  Future<void> loadMovies() async {
    // 1. Load data from the cache first to show something immediately.
    // We don't need to set a loading flag because this should be very fast.
    _trendingMovies = await _repository.getTrendingMovies();
    _nowPlayingMovies = await _repository.getNowPlayingMovies();
    _popularMovies = await _repository.getPopularMovies();
    _topRatedMovies = await _repository.getTopRatedMovies();
    // Notify the UI to display the cached data.
    notifyListeners();

    // 2. Then, fetch fresh data from the network in the background.
    // This will automatically update the cache if successful.
    // We wrap this in a try-catch in case the network is offline.
    try {
      final freshTrending = await _repository.getTrendingMovies();
      final freshNowPlaying = await _repository.getNowPlayingMovies();
      final freshPopular = await _repository.getPopularMovies();
      final freshTopRated = await _repository.getTopRatedMovies();

      // Update the state with the fresh data
      _trendingMovies = freshTrending;
      _nowPlayingMovies = freshNowPlaying;
      _popularMovies = freshPopular;
      _topRatedMovies = freshTopRated;

      // Notify the UI one last time to show the fresh data.
      notifyListeners();
    } catch (e) {
      // If the network fails, we just print a debug message.
      // The user will continue to see the cached data, so there's no error to show.
      debugPrint("Failed to fetch fresh data, using cache: $e");
    }
  }
}
