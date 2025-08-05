import 'package:cineverse/models/cast.dart';
import 'package:json_annotation/json_annotation.dart';

part 'credits_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CreditsResponse {
  final List<Cast> cast;

  CreditsResponse({required this.cast});

  factory CreditsResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreditsResponseToJson(this);
}