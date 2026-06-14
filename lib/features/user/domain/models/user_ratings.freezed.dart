// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_ratings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserRatings _$UserRatingsFromJson(Map<String, dynamic> json) {
  return _UserRatings.fromJson(json);
}

/// @nodoc
mixin _$UserRatings {
  String get userId => throw _privateConstructorUsedError;
  int get ciRating => throw _privateConstructorUsedError;
  int get physicsRating => throw _privateConstructorUsedError;
  int get mathRating => throw _privateConstructorUsedError;

  /// Serializes this UserRatings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserRatings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserRatingsCopyWith<UserRatings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRatingsCopyWith<$Res> {
  factory $UserRatingsCopyWith(
    UserRatings value,
    $Res Function(UserRatings) then,
  ) = _$UserRatingsCopyWithImpl<$Res, UserRatings>;
  @useResult
  $Res call({String userId, int ciRating, int physicsRating, int mathRating});
}

/// @nodoc
class _$UserRatingsCopyWithImpl<$Res, $Val extends UserRatings>
    implements $UserRatingsCopyWith<$Res> {
  _$UserRatingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserRatings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? ciRating = null,
    Object? physicsRating = null,
    Object? mathRating = null,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            ciRating:
                null == ciRating
                    ? _value.ciRating
                    : ciRating // ignore: cast_nullable_to_non_nullable
                        as int,
            physicsRating:
                null == physicsRating
                    ? _value.physicsRating
                    : physicsRating // ignore: cast_nullable_to_non_nullable
                        as int,
            mathRating:
                null == mathRating
                    ? _value.mathRating
                    : mathRating // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserRatingsImplCopyWith<$Res>
    implements $UserRatingsCopyWith<$Res> {
  factory _$$UserRatingsImplCopyWith(
    _$UserRatingsImpl value,
    $Res Function(_$UserRatingsImpl) then,
  ) = __$$UserRatingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, int ciRating, int physicsRating, int mathRating});
}

/// @nodoc
class __$$UserRatingsImplCopyWithImpl<$Res>
    extends _$UserRatingsCopyWithImpl<$Res, _$UserRatingsImpl>
    implements _$$UserRatingsImplCopyWith<$Res> {
  __$$UserRatingsImplCopyWithImpl(
    _$UserRatingsImpl _value,
    $Res Function(_$UserRatingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserRatings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? ciRating = null,
    Object? physicsRating = null,
    Object? mathRating = null,
  }) {
    return _then(
      _$UserRatingsImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        ciRating:
            null == ciRating
                ? _value.ciRating
                : ciRating // ignore: cast_nullable_to_non_nullable
                    as int,
        physicsRating:
            null == physicsRating
                ? _value.physicsRating
                : physicsRating // ignore: cast_nullable_to_non_nullable
                    as int,
        mathRating:
            null == mathRating
                ? _value.mathRating
                : mathRating // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRatingsImpl implements _UserRatings {
  const _$UserRatingsImpl({
    required this.userId,
    this.ciRating = 800,
    this.physicsRating = 800,
    this.mathRating = 800,
  });

  factory _$UserRatingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRatingsImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int ciRating;
  @override
  @JsonKey()
  final int physicsRating;
  @override
  @JsonKey()
  final int mathRating;

  @override
  String toString() {
    return 'UserRatings(userId: $userId, ciRating: $ciRating, physicsRating: $physicsRating, mathRating: $mathRating)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRatingsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.ciRating, ciRating) ||
                other.ciRating == ciRating) &&
            (identical(other.physicsRating, physicsRating) ||
                other.physicsRating == physicsRating) &&
            (identical(other.mathRating, mathRating) ||
                other.mathRating == mathRating));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, ciRating, physicsRating, mathRating);

  /// Create a copy of UserRatings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRatingsImplCopyWith<_$UserRatingsImpl> get copyWith =>
      __$$UserRatingsImplCopyWithImpl<_$UserRatingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRatingsImplToJson(this);
  }
}

abstract class _UserRatings implements UserRatings {
  const factory _UserRatings({
    required final String userId,
    final int ciRating,
    final int physicsRating,
    final int mathRating,
  }) = _$UserRatingsImpl;

  factory _UserRatings.fromJson(Map<String, dynamic> json) =
      _$UserRatingsImpl.fromJson;

  @override
  String get userId;
  @override
  int get ciRating;
  @override
  int get physicsRating;
  @override
  int get mathRating;

  /// Create a copy of UserRatings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserRatingsImplCopyWith<_$UserRatingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
