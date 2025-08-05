import 'dart:async';

import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository _repository = MovieRepositoryImpl();

  List<Movie> _results = [];
  List<Movie> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // This will be used for the live search later
  Timer? _debounce;

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    notifyListeners();

    _results = await _repository.searchMovies(query);

    _isLoading = false;
    notifyListeners();
  }

  void clearResults() {
    _results = [];
  }
}
