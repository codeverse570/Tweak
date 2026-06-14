// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_progression.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProgression _$UserProgressionFromJson(Map<String, dynamic> json) {
  return _UserProgression.fromJson(json);
}

/// @nodoc
mixin _$UserProgression {
  String get userId => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  int get experience => throw _privateConstructorUsedError;
  int get coins => throw _privateConstructorUsedError;
  int get gems => throw _privateConstructorUsedError;

  /// Serializes this UserProgression to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgression
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressionCopyWith<UserProgression> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressionCopyWith<$Res> {
  factory $UserProgressionCopyWith(
    UserProgression value,
    $Res Function(UserProgression) then,
  ) = _$UserProgressionCopyWithImpl<$Res, UserProgression>;
  @useResult
  $Res call({String userId, int level, int experience, int coins, int gems});
}

/// @nodoc
class _$UserProgressionCopyWithImpl<$Res, $Val extends UserProgression>
    implements $UserProgressionCopyWith<$Res> {
  _$UserProgressionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgression
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? level = null,
    Object? experience = null,
    Object? coins = null,
    Object? gems = null,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            level:
                null == level
                    ? _value.level
                    : level // ignore: cast_nullable_to_non_nullable
                        as int,
            experience:
                null == experience
                    ? _value.experience
                    : experience // ignore: cast_nullable_to_non_nullable
                        as int,
            coins:
                null == coins
                    ? _value.coins
                    : coins // ignore: cast_nullable_to_non_nullable
                        as int,
            gems:
                null == gems
                    ? _value.gems
                    : gems // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressionImplCopyWith<$Res>
    implements $UserProgressionCopyWith<$Res> {
  factory _$$UserProgressionImplCopyWith(
    _$UserProgressionImpl value,
    $Res Function(_$UserProgressionImpl) then,
  ) = __$$UserProgressionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, int level, int experience, int coins, int gems});
}

/// @nodoc
class __$$UserProgressionImplCopyWithImpl<$Res>
    extends _$UserProgressionCopyWithImpl<$Res, _$UserProgressionImpl>
    implements _$$UserProgressionImplCopyWith<$Res> {
  __$$UserProgressionImplCopyWithImpl(
    _$UserProgressionImpl _value,
    $Res Function(_$UserProgressionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProgression
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? level = null,
    Object? experience = null,
    Object? coins = null,
    Object? gems = null,
  }) {
    return _then(
      _$UserProgressionImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        level:
            null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                    as int,
        experience:
            null == experience
                ? _value.experience
                : experience // ignore: cast_nullable_to_non_nullable
                    as int,
        coins:
            null == coins
                ? _value.coins
                : coins // ignore: cast_nullable_to_non_nullable
                    as int,
        gems:
            null == gems
                ? _value.gems
                : gems // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressionImpl implements _UserProgression {
  const _$UserProgressionImpl({
    required this.userId,
    this.level = 1,
    this.experience = 0,
    this.coins = 0,
    this.gems = 0,
  });

  factory _$UserProgressionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressionImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int level;
  @override
  @JsonKey()
  final int experience;
  @override
  @JsonKey()
  final int coins;
  @override
  @JsonKey()
  final int gems;

  @override
  String toString() {
    return 'UserProgression(userId: $userId, level: $level, experience: $experience, coins: $coins, gems: $gems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.coins, coins) || other.coins == coins) &&
            (identical(other.gems, gems) || other.gems == gems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, level, experience, coins, gems);

  /// Create a copy of UserProgression
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressionImplCopyWith<_$UserProgressionImpl> get copyWith =>
      __$$UserProgressionImplCopyWithImpl<_$UserProgressionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressionImplToJson(this);
  }
}

abstract class _UserProgression implements UserProgression {
  const factory _UserProgression({
    required final String userId,
    final int level,
    final int experience,
    final int coins,
    final int gems,
  }) = _$UserProgressionImpl;

  factory _UserProgression.fromJson(Map<String, dynamic> json) =
      _$UserProgressionImpl.fromJson;

  @override
  String get userId;
  @override
  int get level;
  @override
  int get experience;
  @override
  int get coins;
  @override
  int get gems;

  /// Create a copy of UserProgression
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressionImplCopyWith<_$UserProgressionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
