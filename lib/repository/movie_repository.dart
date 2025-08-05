import 'package:cineverse/data/network/api_service.dart';
import 'package:cineverse/models/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class MovieRepository {
  Future<List<Movie>> getTrendingMovies();
  Future<List<Movie>> getNowPlayingMovies();
  Future<Movie> getMovieDetails(int movieId);
}

class MovieRepositoryImpl implements MovieRepository {
  final ApiService _apiService;

  // The constructor now correctly initializes _apiService (camelCase)
  MovieRepositoryImpl() : _apiService = ApiService(_createDioClient());

  static Dio _createDioClient() {
    final dio = Dio(BaseOptions(contentType: "application/json"));
    final apiKey = dotenv.env['TMDB_API_KEY'];

    if (apiKey == null) {
      throw Exception("TMDB_API_KEY not found in .env file");
    }

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
      // Re-throw the exception to be handled by the UI layer
      rethrow;
    }
  }

}
