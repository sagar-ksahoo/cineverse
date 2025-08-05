import 'package:cineverse/models/movie_response.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../models/movie.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://api.themoviedb.org/3")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Notice the apiKey parameter is completely gone
  @GET("/trending/movie/week")
  Future<MovieResponse> getTrendingMovies();

  @GET("/movie/now_playing")
  Future<MovieResponse> getNowPlayingMovies();

  @GET("/movie/{movie_id}")
  Future<Movie> getMovieDetails(
    @Path("movie_id") int movieId, {
    // This tells the API to include credits in the response
    @Query("append_to_response") String appendToResponse = "credits",
  });

  @GET("/search/movie")
  Future<MovieResponse> searchMovies({
    // We still need the query parameter for search, but not the key
    @Query("query") required String query,
  });
}