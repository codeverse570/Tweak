import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_ratings.freezed.dart';
part 'user_ratings.g.dart';

@freezed
class UserRatings with _$UserRatings {
  const factory UserRatings({
    required String userId,
    @Default(800) int ciRating,
    @Default(800) int physicsRating,
    @Default(800) int mathRating,
  }) = _UserRatings;

  factory UserRatings.fromJson(Map<String, dynamic> json) =>
      _$UserRatingsFromJson(json);
}

extension UserRatingsX on UserRatings {
  static UserRatings empty(String userId) => UserRatings(userId: userId);

  int get highestRating =>
      [ciRating, physicsRating, mathRating].reduce((a, b) => a > b ? a : b);
}