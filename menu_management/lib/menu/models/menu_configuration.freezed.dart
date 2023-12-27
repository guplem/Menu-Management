// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

MenuConfiguration _$MenuConfigurationFromJson(Map<String, dynamic> json) {
  return _MenuConfiguration.fromJson(json);
}

/// @nodoc
mixin _$MenuConfiguration {
  MealTime get mealTime => throw _privateConstructorUsedError;
  bool get requiresMeal => throw _privateConstructorUsedError;
  int get availableCookingTimeMinutes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenuConfigurationCopyWith<MenuConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuConfigurationCopyWith<$Res> {
  factory $MenuConfigurationCopyWith(
          MenuConfiguration value, $Res Function(MenuConfiguration) then) =
      _$MenuConfigurationCopyWithImpl<$Res, MenuConfiguration>;
  @useResult
  $Res call(
      {MealTime mealTime, bool requiresMeal, int availableCookingTimeMinutes});

  $MealTimeCopyWith<$Res> get mealTime;
}

/// @nodoc
class _$MenuConfigurationCopyWithImpl<$Res, $Val extends MenuConfiguration>
    implements $MenuConfigurationCopyWith<$Res> {
  _$MenuConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealTime = null,
    Object? requiresMeal = null,
    Object? availableCookingTimeMinutes = null,
  }) {
    return _then(_value.copyWith(
      mealTime: null == mealTime
          ? _value.mealTime
          : mealTime // ignore: cast_nullable_to_non_nullable
              as MealTime,
      requiresMeal: null == requiresMeal
          ? _value.requiresMeal
          : requiresMeal // ignore: cast_nullable_to_non_nullable
              as bool,
      availableCookingTimeMinutes: null == availableCookingTimeMinutes
          ? _value.availableCookingTimeMinutes
          : availableCookingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MealTimeCopyWith<$Res> get mealTime {
    return $MealTimeCopyWith<$Res>(_value.mealTime, (value) {
      return _then(_value.copyWith(mealTime: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MenuConfigurationImplCopyWith<$Res>
    implements $MenuConfigurationCopyWith<$Res> {
  factory _$$MenuConfigurationImplCopyWith(_$MenuConfigurationImpl value,
          $Res Function(_$MenuConfigurationImpl) then) =
      __$$MenuConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MealTime mealTime, bool requiresMeal, int availableCookingTimeMinutes});

  @override
  $MealTimeCopyWith<$Res> get mealTime;
}

/// @nodoc
class __$$MenuConfigurationImplCopyWithImpl<$Res>
    extends _$MenuConfigurationCopyWithImpl<$Res, _$MenuConfigurationImpl>
    implements _$$MenuConfigurationImplCopyWith<$Res> {
  __$$MenuConfigurationImplCopyWithImpl(_$MenuConfigurationImpl _value,
      $Res Function(_$MenuConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealTime = null,
    Object? requiresMeal = null,
    Object? availableCookingTimeMinutes = null,
  }) {
    return _then(_$MenuConfigurationImpl(
      mealTime: null == mealTime
          ? _value.mealTime
          : mealTime // ignore: cast_nullable_to_non_nullable
              as MealTime,
      requiresMeal: null == requiresMeal
          ? _value.requiresMeal
          : requiresMeal // ignore: cast_nullable_to_non_nullable
              as bool,
      availableCookingTimeMinutes: null == availableCookingTimeMinutes
          ? _value.availableCookingTimeMinutes
          : availableCookingTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuConfigurationImpl extends _MenuConfiguration
    with DiagnosticableTreeMixin {
  const _$MenuConfigurationImpl(
      {required this.mealTime,
      this.requiresMeal = true,
      this.availableCookingTimeMinutes = 60})
      : super._();

  factory _$MenuConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuConfigurationImplFromJson(json);

  @override
  final MealTime mealTime;
  @override
  @JsonKey()
  final bool requiresMeal;
  @override
  @JsonKey()
  final int availableCookingTimeMinutes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MenuConfiguration(mealTime: $mealTime, requiresMeal: $requiresMeal, availableCookingTimeMinutes: $availableCookingTimeMinutes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MenuConfiguration'))
      ..add(DiagnosticsProperty('mealTime', mealTime))
      ..add(DiagnosticsProperty('requiresMeal', requiresMeal))
      ..add(DiagnosticsProperty(
          'availableCookingTimeMinutes', availableCookingTimeMinutes));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuConfigurationImpl &&
            (identical(other.mealTime, mealTime) ||
                other.mealTime == mealTime) &&
            (identical(other.requiresMeal, requiresMeal) ||
                other.requiresMeal == requiresMeal) &&
            (identical(other.availableCookingTimeMinutes,
                    availableCookingTimeMinutes) ||
                other.availableCookingTimeMinutes ==
                    availableCookingTimeMinutes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, mealTime, requiresMeal, availableCookingTimeMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuConfigurationImplCopyWith<_$MenuConfigurationImpl> get copyWith =>
      __$$MenuConfigurationImplCopyWithImpl<_$MenuConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuConfigurationImplToJson(
      this,
    );
  }
}

abstract class _MenuConfiguration extends MenuConfiguration {
  const factory _MenuConfiguration(
      {required final MealTime mealTime,
      final bool requiresMeal,
      final int availableCookingTimeMinutes}) = _$MenuConfigurationImpl;
  const _MenuConfiguration._() : super._();

  factory _MenuConfiguration.fromJson(Map<String, dynamic> json) =
      _$MenuConfigurationImpl.fromJson;

  @override
  MealTime get mealTime;
  @override
  bool get requiresMeal;
  @override
  int get availableCookingTimeMinutes;
  @override
  @JsonKey(ignore: true)
  _$$MenuConfigurationImplCopyWith<_$MenuConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
