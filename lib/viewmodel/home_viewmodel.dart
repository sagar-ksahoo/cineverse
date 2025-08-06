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


  HomeViewModel() {
    loadMovies();
  }

  Future<void> loadMovies() async {
    _trendingMovies = await _repository.getTrendingMovies();
    _nowPlayingMovies = await _repository.getNowPlayingMovies();
    _popularMovies = await _repository.getPopularMovies();
    _topRatedMovies = await _repository.getTopRatedMovies();
    notifyListeners();

   
    try {
      final freshTrending = await _repository.getTrendingMovies();
      final freshNowPlaying = await _repository.getNowPlayingMovies();
      final freshPopular = await _repository.getPopularMovies();
      final freshTopRated = await _repository.getTopRatedMovies();

      _trendingMovies = freshTrending;
      _nowPlayingMovies = freshNowPlaying;
      _popularMovies = freshPopular;
      _topRatedMovies = freshTopRated;

      notifyListeners();
    } catch (e) {
      debugPrint("Failed to fetch fresh data, using cache: $e");
    }
  }
}
