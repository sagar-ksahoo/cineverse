import 'package:cineverse/models/movie_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/movie.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET("/trending/movie/week")
  Future<MovieResponse> getTrendingMovies();

  @GET("/movie/now_playing")
  Future<MovieResponse> getNowPlayingMovies();

  @GET("/movie/{movie_id}")
  Future<Movie> getMovieDetails(
    @Path("movie_id") int movieId, {
    @Query("append_to_response") String appendToResponse = "credits",
  });

  @GET("/search/movie")
  Future<MovieResponse> searchMovies({
    @Query("query") required String query,
  });

  @GET("/movie/popular")
  Future<MovieResponse> getPopularMovies();

  @GET("/movie/top_rated")
  Future<MovieResponse> getTopRatedMovies();


}