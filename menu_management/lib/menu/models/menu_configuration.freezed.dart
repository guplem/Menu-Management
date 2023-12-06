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
  return _Configuration.fromJson(json);
}

/// @nodoc
mixin _$MenuConfiguration {
  MealTime get mealTime => throw _privateConstructorUsedError;
  bool get requiresMeal => throw _privateConstructorUsedError;
  int get availableCookingTime => throw _privateConstructorUsedError;

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
  $Res call({MealTime mealTime, bool requiresMeal, int availableCookingTime});

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
    Object? availableCookingTime = null,
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
      availableCookingTime: null == availableCookingTime
          ? _value.availableCookingTime
          : availableCookingTime // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ConfigurationImplCopyWith<$Res>
    implements $MenuConfigurationCopyWith<$Res> {
  factory _$$ConfigurationImplCopyWith(
          _$ConfigurationImpl value, $Res Function(_$ConfigurationImpl) then) =
      __$$ConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MealTime mealTime, bool requiresMeal, int availableCookingTime});

  @override
  $MealTimeCopyWith<$Res> get mealTime;
}

/// @nodoc
class __$$ConfigurationImplCopyWithImpl<$Res>
    extends _$MenuConfigurationCopyWithImpl<$Res, _$ConfigurationImpl>
    implements _$$ConfigurationImplCopyWith<$Res> {
  __$$ConfigurationImplCopyWithImpl(
      _$ConfigurationImpl _value, $Res Function(_$ConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealTime = null,
    Object? requiresMeal = null,
    Object? availableCookingTime = null,
  }) {
    return _then(_$ConfigurationImpl(
      mealTime: null == mealTime
          ? _value.mealTime
          : mealTime // ignore: cast_nullable_to_non_nullable
              as MealTime,
      requiresMeal: null == requiresMeal
          ? _value.requiresMeal
          : requiresMeal // ignore: cast_nullable_to_non_nullable
              as bool,
      availableCookingTime: null == availableCookingTime
          ? _value.availableCookingTime
          : availableCookingTime // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConfigurationImpl
    with DiagnosticableTreeMixin
    implements _Configuration {
  const _$ConfigurationImpl(
      {required this.mealTime,
      this.requiresMeal = true,
      this.availableCookingTime = 60});

  factory _$ConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConfigurationImplFromJson(json);

  @override
  final MealTime mealTime;
  @override
  @JsonKey()
  final bool requiresMeal;
  @override
  @JsonKey()
  final int availableCookingTime;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MenuConfiguration(mealTime: $mealTime, requiresMeal: $requiresMeal, availableCookingTime: $availableCookingTime)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MenuConfiguration'))
      ..add(DiagnosticsProperty('mealTime', mealTime))
      ..add(DiagnosticsProperty('requiresMeal', requiresMeal))
      ..add(DiagnosticsProperty('availableCookingTime', availableCookingTime));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConfigurationImpl &&
            (identical(other.mealTime, mealTime) ||
                other.mealTime == mealTime) &&
            (identical(other.requiresMeal, requiresMeal) ||
                other.requiresMeal == requiresMeal) &&
            (identical(other.availableCookingTime, availableCookingTime) ||
                other.availableCookingTime == availableCookingTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, mealTime, requiresMeal, availableCookingTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConfigurationImplCopyWith<_$ConfigurationImpl> get copyWith =>
      __$$ConfigurationImplCopyWithImpl<_$ConfigurationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConfigurationImplToJson(
      this,
    );
  }
}

abstract class _Configuration implements MenuConfiguration {
  const factory _Configuration(
      {required final MealTime mealTime,
      final bool requiresMeal,
      final int availableCookingTime}) = _$ConfigurationImpl;

  factory _Configuration.fromJson(Map<String, dynamic> json) =
      _$ConfigurationImpl.fromJson;

  @override
  MealTime get mealTime;
  @override
  bool get requiresMeal;
  @override
  int get availableCookingTime;
  @override
  @JsonKey(ignore: true)
  _$$ConfigurationImplCopyWith<_$ConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
