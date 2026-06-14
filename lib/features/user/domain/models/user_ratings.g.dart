// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ratings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRatingsImpl _$$UserRatingsImplFromJson(Map<String, dynamic> json) =>
    _$UserRatingsImpl(
      userId: json['userId'] as String,
      ciRating: (json['ciRating'] as num?)?.toInt() ?? 800,
      physicsRating: (json['physicsRating'] as num?)?.toInt() ?? 800,
      mathRating: (json['mathRating'] as num?)?.toInt() ?? 800,
    );

Map<String, dynamic> _$$UserRatingsImplToJson(_$UserRatingsImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'ciRating': instance.ciRating,
      'physicsRating': instance.physicsRating,
      'mathRating': instance.mathRating,
    };
