import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:flutter/foundation.dart';

// The ViewModel extends ChangeNotifier to notify the UI of state changes.
class HomeViewModel extends ChangeNotifier {
  // It depends on the repository to get data.
  final MovieRepository _repository = MovieRepositoryImpl();

  // These lists will hold our data and be displayed by the UI.
  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _trendingMovies;

  List<Movie> _nowPlayingMovies = [];
  List<Movie> get nowPlayingMovies => _nowPlayingMovies;

  List<Movie> _popularMovies = [];
  List<Movie> get popularMovies => _popularMovies;

  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _topRatedMovies;

  // A flag to indicate whether we are currently fetching data.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    // Fetch movies as soon as the ViewModel is created.
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    // Set loading state to true and notify the UI.
    _isLoading = true;
    notifyListeners();

    // Fetch both lists of movies in parallel for efficiency.
    final results = await Future.wait([
      _repository.getTrendingMovies(),
      _repository.getNowPlayingMovies(),
      _repository.getPopularMovies(),
      _repository.getTopRatedMovies(),
    ]);

    // Assign the results to our state variables.
    _trendingMovies = results[0];
    _nowPlayingMovies = results[1];

    // Set loading state to false and notify the UI again.
    _isLoading = false;
    notifyListeners();
  }
}