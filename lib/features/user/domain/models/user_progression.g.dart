// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressionImpl _$$UserProgressionImplFromJson(
  Map<String, dynamic> json,
) => _$UserProgressionImpl(
  userId: json['userId'] as String,
  level: (json['level'] as num?)?.toInt() ?? 1,
  experience: (json['experience'] as num?)?.toInt() ?? 0,
  coins: (json['coins'] as num?)?.toInt() ?? 0,
  gems: (json['gems'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$UserProgressionImplToJson(
  _$UserProgressionImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'level': instance.level,
  'experience': instance.experience,
  'coins': instance.coins,
  'gems': instance.gems,
};
