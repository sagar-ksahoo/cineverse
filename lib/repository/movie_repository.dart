import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../data/local_db/database_service.dart';
import '../data/network/api_service.dart';
import '../models/movie.dart';


/// The "contract" for our repository, defining all its capabilities.
abstract class MovieRepository {
  Future<List<Movie>> getTrendingMovies();
  Future<List<Movie>> getNowPlayingMovies();
  Future<Movie> getMovieDetails(int movieId);
  Future<List<Movie>> searchMovies(String query);
  Future<void> addBookmark(Movie movie);
  Future<void> removeBookmark(int movieId);
  Future<bool> isBookmarked(int movieId);
  Future<List<Movie>> getBookmarkedMovies();

  Future<List<Movie>> getPopularMovies();
  Future<List<Movie>> getTopRatedMovies();
}

/// The implementation of the repository.
class MovieRepositoryImpl implements MovieRepository {
  final ApiService _apiService;
  // The DatabaseService is nullable, as it will be null when running on the web.
  final DatabaseService? _dbService;

  MovieRepositoryImpl()
      : _apiService = ApiService(_createDioClient()),
        // Conditionally initialize the database service.
        // If the app is running on the web (kIsWeb is true), _dbService will be null.
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

    // Add an interceptor to automatically inject the API key into every request.
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

  // --- Network Methods ---

  @override
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await _apiService.getTrendingMovies();
      return response.results;
    } on DioException catch (e) {
      debugPrint("Error fetching trending movies: $e");
      return [];
    }
  }

  @override
  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      final response = await _apiService.getNowPlayingMovies();
      return response.results;
    } on DioException catch (e) {
      debugPrint("Error fetching now playing movies: $e");
      return [];
    }
  }

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
    // If on web, do nothing. Otherwise, call the database.
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
    // If on web, always return false (not bookmarked).
    if (kIsWeb || _dbService == null) return Future.value(false);
    return _dbService!.isBookmarked(movieId);
  }

  @override
  Future<List<Movie>> getBookmarkedMovies() {
    // If on web, always return an empty list.
    if (kIsWeb || _dbService == null) return Future.value([]);
    return _dbService!.getBookmarkedMovies();
  }

  // see all section for popular and top rated movies

  @override
  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await _apiService.getPopularMovies();
      return response.results;
    } on DioException catch (e) {
      debugPrint("Error fetching popular movies: $e");
      return [];
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final response = await _apiService.getTopRatedMovies();
      return response.results;
    } on DioException catch (e) {
      debugPrint("Error fetching top rated movies: $e");
      return [];
    }
  }

}
