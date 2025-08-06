import 'package:cineverse/data/local_db/database_service.dart';
import 'package:cineverse/data/network/api_service.dart';
import 'package:cineverse/models/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/movie_response.dart';

/// The "contract" for our repository, defining all its capabilities.
abstract class MovieRepository {
  Future<List<Movie>> getTrendingMovies();
  Future<List<Movie>> getNowPlayingMovies();
  Future<List<Movie>> getPopularMovies();
  Future<List<Movie>> getTopRatedMovies();
  Future<Movie> getMovieDetails(int movieId);
  Future<List<Movie>> searchMovies(String query);
  Future<void> addBookmark(Movie movie);
  Future<void> removeBookmark(int movieId);
  Future<bool> isBookmarked(int movieId);
  Future<List<Movie>> getBookmarkedMovies();
}

/// The implementation of the repository.
class MovieRepositoryImpl implements MovieRepository {
  final ApiService _apiService;
  final DatabaseService? _dbService;

  MovieRepositoryImpl()
      : _apiService = ApiService(_createDioClient()),
        _dbService = kIsWeb ? null : DatabaseService();

  /// A static method to create and configure our Dio client in one place.
  static Dio _createDioClient() {
    final apiKey = dotenv.env['TMDB_API_KEY'];
    final baseUrl = dotenv.env['TMDB_BASE_URL'];

    if (apiKey == null || baseUrl == null) {
      throw Exception(".env file is missing required keys (TMDB_API_KEY or TMDB_BASE_URL)");
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        contentType: "application/json",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters['api_key'] = apiKey;
          return handler.next(options);
        },
      ),
    );

    return dio;
  }

  /// A generic helper method to handle the "try network, fallback to cache" logic.
  Future<List<Movie>> _getMovies(
      String category, Future<MovieResponse> Function() apiCall) async {
    if (kIsWeb || _dbService == null) {
      final response = await apiCall();
      return response.results;
    }

    try {
      final response = await apiCall();
      final freshMovies = response.results;
      await _dbService!.cacheMovies(freshMovies, category);
      return freshMovies;
    } on DioException catch (e) {
      debugPrint("Network failed, loading from cache for category: $category. Error: $e");
      return await _dbService!.getCachedMovies(category);
    }
  }

  // --- Network Methods with Caching ---

  @override
  Future<List<Movie>> getTrendingMovies() {
    return _getMovies('trending', _apiService.getTrendingMovies);
  }

  @override
  Future<List<Movie>> getNowPlayingMovies() {
    return _getMovies('now_playing', _apiService.getNowPlayingMovies);
  }

  @override
  Future<List<Movie>> getPopularMovies() {
    return _getMovies('popular', _apiService.getPopularMovies);
  }

  @override
  Future<List<Movie>> getTopRatedMovies() {
    return _getMovies('top_rated', _apiService.getTopRatedMovies);
  }

  // --- Network Methods without Caching ---

  @override
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      return await _apiService.getMovieDetails(movieId);
    } on DioException catch (e) {
      debugPrint("Error fetching movie details: $e");
      rethrow;
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await _apiService.searchMovies(query: query);
      return response.results;
    } on DioException catch (e) {
      debugPrint("Error searching movies: $e");
      return [];
    }
  }

  // --- Database (Bookmark) Methods ---

  @override
  Future<void> addBookmark(Movie movie) {
    if (kIsWeb || _dbService == null) return Future.value();
    return _dbService!.addBookmark(movie);
  }

  @override
  Future<void> removeBookmark(int movieId) {
    if (kIsWeb || _dbService == null) return Future.value();
    return _dbService!.removeBookmark(movieId);
  }

  @override
  Future<bool> isBookmarked(int movieId) {
    if (kIsWeb || _dbService == null) return Future.value(false);
    return _dbService!.isBookmarked(movieId);
  }

  @override
  Future<List<Movie>> getBookmarkedMovies() {
    if (kIsWeb || _dbService == null) return Future.value([]);
    return _dbService!.getBookmarkedMovies();
  }
}
