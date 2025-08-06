import 'package:cineverse/models/genre.dart'; // Import Genre
import 'package:json_annotation/json_annotation.dart';

import 'credits_response.dart';

part 'movie.g.dart';

@JsonSerializable(explicitToJson: true)
class Movie {
  final int id;
  final String title;
  final String overview;

  final int? runtime;
  final CreditsResponse? credits; 

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'backdrop_path') // New field for the header image
  final String? backdropPath;

  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @JsonKey(name: 'vote_average')
  final double rating;

  final List<Genre>? genres; 

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate,
    required this.rating,
    this.genres,
    this.runtime,
    this.credits,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);

  Map<String, dynamic> toJson() => _$MovieToJson(this);

  String get year {
    if (releaseDate != null && releaseDate!.isNotEmpty) {
      return releaseDate!.substring(0, 4);
    }
    return 'N/A';
  }
}