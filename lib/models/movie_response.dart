import 'package:cineverse/models/movie.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_response.g.dart';

// Add explicitToJson: true here
@JsonSerializable(explicitToJson: true)
class MovieResponse {
  final List<Movie> results;

  MovieResponse({required this.results});

  factory MovieResponse.fromJson(Map<String, dynamic> json) =>
      _$MovieResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MovieResponseToJson(this);
}