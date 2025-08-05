import 'dart:async'; // 1. Import the async library for Timer

import 'package:cineverse/models/movie.dart';
import 'package:cineverse/repository/movie_repository.dart';
import 'package:flutter/foundation.dart';

class SearchViewModel extends ChangeNotifier {
  final MovieRepository _repository = MovieRepositoryImpl();

  List<Movie> _results = [];
  List<Movie> get results => _results;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 2. Add a nullable Timer property for debouncing
  Timer? _debounce;

  // NEW METHOD for live search
  void onSearchChanged(String query) {
    // If a timer is already active, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer. The search will only happen after 500ms of no typing.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // When the timer finishes, call the search method
      searchMovies(query);
    });
  }

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

  // 3. Add the dispose method to cancel the timer when the ViewModel is destroyed
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}