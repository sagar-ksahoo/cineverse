import 'package:json_annotation/json_annotation.dart';

part 'cast.g.dart';

@JsonSerializable()
class Cast {
  final String name;
  final String? character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  Cast({required this.name, this.character, this.profilePath});

  factory Cast.fromJson(Map<String, dynamic> json) => _$CastFromJson(json);
  Map<String, dynamic> toJson() => _$CastToJson(this);
}