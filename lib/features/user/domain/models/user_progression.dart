import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progression.freezed.dart';
part 'user_progression.g.dart';

@freezed
class UserProgression with _$UserProgression {
  const factory UserProgression({
    required String userId,
    @Default(1) int level,
    @Default(0) int experience,
    @Default(0) int coins,
    @Default(0) int gems,
  }) = _UserProgression;

  factory UserProgression.fromJson(Map<String, dynamic> json) =>
      _$UserProgressionFromJson(json);
}

// empty() lives outside the freezed class to avoid const factory conflicts
extension UserProgressionX on UserProgression {
  static UserProgression empty(String userId) =>
      UserProgression(userId: userId);
}