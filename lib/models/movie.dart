import 'package:json_annotation/json_annotation.dart';

part 'movie.g.dart';

// Add explicitToJson: true here
@JsonSerializable(explicitToJson: true)
class Movie {
  final int id;
  final String title;
  final String overview;

  @JsonKey(name: 'poster_path')
  final String? posterPath;

  @JsonKey(name: 'release_date')
  final String? releaseDate;

  @JsonKey(name: 'vote_average')
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.releaseDate,
    required this.rating,
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