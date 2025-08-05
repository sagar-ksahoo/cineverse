// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreditsResponse _$CreditsResponseFromJson(Map<String, dynamic> json) =>
    CreditsResponse(
      cast: (json['cast'] as List<dynamic>)
          .map((e) => Cast.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CreditsResponseToJson(CreditsResponse instance) =>
    <String, dynamic>{
      'cast': instance.cast.map((e) => e.toJson()).toList(),
    };
