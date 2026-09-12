// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shopping_pdf_document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ShoppingPdfProductOption {

/// Names the product and the size of one pack, for example "Espaguetis (6x125grams)".
 String get label;/// The store link of the product. It is empty when the product carries no link.
 String get link;/// The packs to buy of this product alone.
 int get packs;/// True for the product that wastes the least, which is the one that the app recommends.
 bool get isRecommended;
/// Create a copy of ShoppingPdfProductOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingPdfProductOptionCopyWith<ShoppingPdfProductOption> get copyWith => _$ShoppingPdfProductOptionCopyWithImpl<ShoppingPdfProductOption>(this as ShoppingPdfProductOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingPdfProductOption&&(identical(other.label, label) || other.label == label)&&(identical(other.link, link) || other.link == link)&&(identical(other.packs, packs) || other.packs == packs)&&(identical(other.isRecommended, isRecommended) || other.isRecommended == isRecommended));
}


@override
int get hashCode => Object.hash(runtimeType,label,link,packs,isRecommended);

@override
String toString() {
  return 'ShoppingPdfProductOption(label: $label, link: $link, packs: $packs, isRecommended: $isRecommended)';
}


}

/// @nodoc
abstract mixin class $ShoppingPdfProductOptionCopyWith<$Res>  {
  factory $ShoppingPdfProductOptionCopyWith(ShoppingPdfProductOption value, $Res Function(ShoppingPdfProductOption) _then) = _$ShoppingPdfProductOptionCopyWithImpl;
@useResult
$Res call({
 String label, String link, int packs, bool isRecommended
});




}
/// @nodoc
class _$ShoppingPdfProductOptionCopyWithImpl<$Res>
    implements $ShoppingPdfProductOptionCopyWith<$Res> {
  _$ShoppingPdfProductOptionCopyWithImpl(this._self, this._then);

  final ShoppingPdfProductOption _self;
  final $Res Function(ShoppingPdfProductOption) _then;

/// Create a copy of ShoppingPdfProductOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? link = null,Object? packs = null,Object? isRecommended = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,packs: null == packs ? _self.packs : packs // ignore: cast_nullable_to_non_nullable
as int,isRecommended: null == isRecommended ? _self.isRecommended : isRecommended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingPdfProductOption].
extension ShoppingPdfProductOptionPatterns on ShoppingPdfProductOption {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingPdfProductOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingPdfProductOption() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingPdfProductOption value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfProductOption():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingPdfProductOption value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfProductOption() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String link,  int packs,  bool isRecommended)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingPdfProductOption() when $default != null:
return $default(_that.label,_that.link,_that.packs,_that.isRecommended);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String link,  int packs,  bool isRecommended)  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfProductOption():
return $default(_that.label,_that.link,_that.packs,_that.isRecommended);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String link,  int packs,  bool isRecommended)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfProductOption() when $default != null:
return $default(_that.label,_that.link,_that.packs,_that.isRecommended);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingPdfProductOption implements ShoppingPdfProductOption {
  const _ShoppingPdfProductOption({required this.label, required this.link, required this.packs, required this.isRecommended});
  

/// Names the product and the size of one pack, for example "Espaguetis (6x125grams)".
@override final  String label;
/// The store link of the product. It is empty when the product carries no link.
@override final  String link;
/// The packs to buy of this product alone.
@override final  int packs;
/// True for the product that wastes the least, which is the one that the app recommends.
@override final  bool isRecommended;

/// Create a copy of ShoppingPdfProductOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingPdfProductOptionCopyWith<_ShoppingPdfProductOption> get copyWith => __$ShoppingPdfProductOptionCopyWithImpl<_ShoppingPdfProductOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingPdfProductOption&&(identical(other.label, label) || other.label == label)&&(identical(other.link, link) || other.link == link)&&(identical(other.packs, packs) || other.packs == packs)&&(identical(other.isRecommended, isRecommended) || other.isRecommended == isRecommended));
}


@override
int get hashCode => Object.hash(runtimeType,label,link,packs,isRecommended);

@override
String toString() {
  return 'ShoppingPdfProductOption(label: $label, link: $link, packs: $packs, isRecommended: $isRecommended)';
}


}

/// @nodoc
abstract mixin class _$ShoppingPdfProductOptionCopyWith<$Res> implements $ShoppingPdfProductOptionCopyWith<$Res> {
  factory _$ShoppingPdfProductOptionCopyWith(_ShoppingPdfProductOption value, $Res Function(_ShoppingPdfProductOption) _then) = __$ShoppingPdfProductOptionCopyWithImpl;
@override @useResult
$Res call({
 String label, String link, int packs, bool isRecommended
});




}
/// @nodoc
class __$ShoppingPdfProductOptionCopyWithImpl<$Res>
    implements _$ShoppingPdfProductOptionCopyWith<$Res> {
  __$ShoppingPdfProductOptionCopyWithImpl(this._self, this._then);

  final _ShoppingPdfProductOption _self;
  final $Res Function(_ShoppingPdfProductOption) _then;

/// Create a copy of ShoppingPdfProductOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? link = null,Object? packs = null,Object? isRecommended = null,}) {
  return _then(_ShoppingPdfProductOption(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,link: null == link ? _self.link : link // ignore: cast_nullable_to_non_nullable
as String,packs: null == packs ? _self.packs : packs // ignore: cast_nullable_to_non_nullable
as int,isRecommended: null == isRecommended ? _self.isRecommended : isRecommended // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ShoppingPdfMealNeed {

/// Names the week of the menu, for example "Week 1".
 String get weekLabel;/// Names the day, for example "Wednesday 6 Aug", or "Saturday" for a menu with no start date.
 String get dayLabel;/// Names the meal slot, for example "Lunch".
 String get mealName; String get recipeName; int get people;/// False when the meal eats the leftovers of an earlier cook event. Such a meal still needs
/// the ingredient, because the earlier cook buys the food for it.
 bool get isCookEvent;/// The amount that this meal needs, for example "200 grams".
 String get amounts;
/// Create a copy of ShoppingPdfMealNeed
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingPdfMealNeedCopyWith<ShoppingPdfMealNeed> get copyWith => _$ShoppingPdfMealNeedCopyWithImpl<ShoppingPdfMealNeed>(this as ShoppingPdfMealNeed, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingPdfMealNeed&&(identical(other.weekLabel, weekLabel) || other.weekLabel == weekLabel)&&(identical(other.dayLabel, dayLabel) || other.dayLabel == dayLabel)&&(identical(other.mealName, mealName) || other.mealName == mealName)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.isCookEvent, isCookEvent) || other.isCookEvent == isCookEvent)&&(identical(other.amounts, amounts) || other.amounts == amounts));
}


@override
int get hashCode => Object.hash(runtimeType,weekLabel,dayLabel,mealName,recipeName,people,isCookEvent,amounts);

@override
String toString() {
  return 'ShoppingPdfMealNeed(weekLabel: $weekLabel, dayLabel: $dayLabel, mealName: $mealName, recipeName: $recipeName, people: $people, isCookEvent: $isCookEvent, amounts: $amounts)';
}


}

/// @nodoc
abstract mixin class $ShoppingPdfMealNeedCopyWith<$Res>  {
  factory $ShoppingPdfMealNeedCopyWith(ShoppingPdfMealNeed value, $Res Function(ShoppingPdfMealNeed) _then) = _$ShoppingPdfMealNeedCopyWithImpl;
@useResult
$Res call({
 String weekLabel, String dayLabel, String mealName, String recipeName, int people, bool isCookEvent, String amounts
});




}
/// @nodoc
class _$ShoppingPdfMealNeedCopyWithImpl<$Res>
    implements $ShoppingPdfMealNeedCopyWith<$Res> {
  _$ShoppingPdfMealNeedCopyWithImpl(this._self, this._then);

  final ShoppingPdfMealNeed _self;
  final $Res Function(ShoppingPdfMealNeed) _then;

/// Create a copy of ShoppingPdfMealNeed
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekLabel = null,Object? dayLabel = null,Object? mealName = null,Object? recipeName = null,Object? people = null,Object? isCookEvent = null,Object? amounts = null,}) {
  return _then(_self.copyWith(
weekLabel: null == weekLabel ? _self.weekLabel : weekLabel // ignore: cast_nullable_to_non_nullable
as String,dayLabel: null == dayLabel ? _self.dayLabel : dayLabel // ignore: cast_nullable_to_non_nullable
as String,mealName: null == mealName ? _self.mealName : mealName // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,isCookEvent: null == isCookEvent ? _self.isCookEvent : isCookEvent // ignore: cast_nullable_to_non_nullable
as bool,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingPdfMealNeed].
extension ShoppingPdfMealNeedPatterns on ShoppingPdfMealNeed {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingPdfMealNeed value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingPdfMealNeed value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingPdfMealNeed value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String weekLabel,  String dayLabel,  String mealName,  String recipeName,  int people,  bool isCookEvent,  String amounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed() when $default != null:
return $default(_that.weekLabel,_that.dayLabel,_that.mealName,_that.recipeName,_that.people,_that.isCookEvent,_that.amounts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String weekLabel,  String dayLabel,  String mealName,  String recipeName,  int people,  bool isCookEvent,  String amounts)  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed():
return $default(_that.weekLabel,_that.dayLabel,_that.mealName,_that.recipeName,_that.people,_that.isCookEvent,_that.amounts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String weekLabel,  String dayLabel,  String mealName,  String recipeName,  int people,  bool isCookEvent,  String amounts)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfMealNeed() when $default != null:
return $default(_that.weekLabel,_that.dayLabel,_that.mealName,_that.recipeName,_that.people,_that.isCookEvent,_that.amounts);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingPdfMealNeed implements ShoppingPdfMealNeed {
  const _ShoppingPdfMealNeed({required this.weekLabel, required this.dayLabel, required this.mealName, required this.recipeName, required this.people, required this.isCookEvent, required this.amounts});
  

/// Names the week of the menu, for example "Week 1".
@override final  String weekLabel;
/// Names the day, for example "Wednesday 6 Aug", or "Saturday" for a menu with no start date.
@override final  String dayLabel;
/// Names the meal slot, for example "Lunch".
@override final  String mealName;
@override final  String recipeName;
@override final  int people;
/// False when the meal eats the leftovers of an earlier cook event. Such a meal still needs
/// the ingredient, because the earlier cook buys the food for it.
@override final  bool isCookEvent;
/// The amount that this meal needs, for example "200 grams".
@override final  String amounts;

/// Create a copy of ShoppingPdfMealNeed
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingPdfMealNeedCopyWith<_ShoppingPdfMealNeed> get copyWith => __$ShoppingPdfMealNeedCopyWithImpl<_ShoppingPdfMealNeed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingPdfMealNeed&&(identical(other.weekLabel, weekLabel) || other.weekLabel == weekLabel)&&(identical(other.dayLabel, dayLabel) || other.dayLabel == dayLabel)&&(identical(other.mealName, mealName) || other.mealName == mealName)&&(identical(other.recipeName, recipeName) || other.recipeName == recipeName)&&(identical(other.people, people) || other.people == people)&&(identical(other.isCookEvent, isCookEvent) || other.isCookEvent == isCookEvent)&&(identical(other.amounts, amounts) || other.amounts == amounts));
}


@override
int get hashCode => Object.hash(runtimeType,weekLabel,dayLabel,mealName,recipeName,people,isCookEvent,amounts);

@override
String toString() {
  return 'ShoppingPdfMealNeed(weekLabel: $weekLabel, dayLabel: $dayLabel, mealName: $mealName, recipeName: $recipeName, people: $people, isCookEvent: $isCookEvent, amounts: $amounts)';
}


}

/// @nodoc
abstract mixin class _$ShoppingPdfMealNeedCopyWith<$Res> implements $ShoppingPdfMealNeedCopyWith<$Res> {
  factory _$ShoppingPdfMealNeedCopyWith(_ShoppingPdfMealNeed value, $Res Function(_ShoppingPdfMealNeed) _then) = __$ShoppingPdfMealNeedCopyWithImpl;
@override @useResult
$Res call({
 String weekLabel, String dayLabel, String mealName, String recipeName, int people, bool isCookEvent, String amounts
});




}
/// @nodoc
class __$ShoppingPdfMealNeedCopyWithImpl<$Res>
    implements _$ShoppingPdfMealNeedCopyWith<$Res> {
  __$ShoppingPdfMealNeedCopyWithImpl(this._self, this._then);

  final _ShoppingPdfMealNeed _self;
  final $Res Function(_ShoppingPdfMealNeed) _then;

/// Create a copy of ShoppingPdfMealNeed
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekLabel = null,Object? dayLabel = null,Object? mealName = null,Object? recipeName = null,Object? people = null,Object? isCookEvent = null,Object? amounts = null,}) {
  return _then(_ShoppingPdfMealNeed(
weekLabel: null == weekLabel ? _self.weekLabel : weekLabel // ignore: cast_nullable_to_non_nullable
as String,dayLabel: null == dayLabel ? _self.dayLabel : dayLabel // ignore: cast_nullable_to_non_nullable
as String,mealName: null == mealName ? _self.mealName : mealName // ignore: cast_nullable_to_non_nullable
as String,recipeName: null == recipeName ? _self.recipeName : recipeName // ignore: cast_nullable_to_non_nullable
as String,people: null == people ? _self.people : people // ignore: cast_nullable_to_non_nullable
as int,isCookEvent: null == isCookEvent ? _self.isCookEvent : isCookEvent // ignore: cast_nullable_to_non_nullable
as bool,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$ShoppingPdfIngredientEntry {

 String get ingredientName;/// The amount to buy, for example "500 grams + 2 pieces".
 String get amounts;/// True when the reader must freeze the item on the day of the trip (ADR 0015).
 bool get freezeOnArrival; List<ShoppingPdfProductOption> get products; List<ShoppingPdfMealNeed> get meals;
/// Create a copy of ShoppingPdfIngredientEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingPdfIngredientEntryCopyWith<ShoppingPdfIngredientEntry> get copyWith => _$ShoppingPdfIngredientEntryCopyWithImpl<ShoppingPdfIngredientEntry>(this as ShoppingPdfIngredientEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingPdfIngredientEntry&&(identical(other.ingredientName, ingredientName) || other.ingredientName == ingredientName)&&(identical(other.amounts, amounts) || other.amounts == amounts)&&(identical(other.freezeOnArrival, freezeOnArrival) || other.freezeOnArrival == freezeOnArrival)&&const DeepCollectionEquality().equals(other.products, products)&&const DeepCollectionEquality().equals(other.meals, meals));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientName,amounts,freezeOnArrival,const DeepCollectionEquality().hash(products),const DeepCollectionEquality().hash(meals));

@override
String toString() {
  return 'ShoppingPdfIngredientEntry(ingredientName: $ingredientName, amounts: $amounts, freezeOnArrival: $freezeOnArrival, products: $products, meals: $meals)';
}


}

/// @nodoc
abstract mixin class $ShoppingPdfIngredientEntryCopyWith<$Res>  {
  factory $ShoppingPdfIngredientEntryCopyWith(ShoppingPdfIngredientEntry value, $Res Function(ShoppingPdfIngredientEntry) _then) = _$ShoppingPdfIngredientEntryCopyWithImpl;
@useResult
$Res call({
 String ingredientName, String amounts, bool freezeOnArrival, List<ShoppingPdfProductOption> products, List<ShoppingPdfMealNeed> meals
});




}
/// @nodoc
class _$ShoppingPdfIngredientEntryCopyWithImpl<$Res>
    implements $ShoppingPdfIngredientEntryCopyWith<$Res> {
  _$ShoppingPdfIngredientEntryCopyWithImpl(this._self, this._then);

  final ShoppingPdfIngredientEntry _self;
  final $Res Function(ShoppingPdfIngredientEntry) _then;

/// Create a copy of ShoppingPdfIngredientEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientName = null,Object? amounts = null,Object? freezeOnArrival = null,Object? products = null,Object? meals = null,}) {
  return _then(_self.copyWith(
ingredientName: null == ingredientName ? _self.ingredientName : ingredientName // ignore: cast_nullable_to_non_nullable
as String,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,freezeOnArrival: null == freezeOnArrival ? _self.freezeOnArrival : freezeOnArrival // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfProductOption>,meals: null == meals ? _self.meals : meals // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfMealNeed>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingPdfIngredientEntry].
extension ShoppingPdfIngredientEntryPatterns on ShoppingPdfIngredientEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingPdfIngredientEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingPdfIngredientEntry value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingPdfIngredientEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ingredientName,  String amounts,  bool freezeOnArrival,  List<ShoppingPdfProductOption> products,  List<ShoppingPdfMealNeed> meals)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry() when $default != null:
return $default(_that.ingredientName,_that.amounts,_that.freezeOnArrival,_that.products,_that.meals);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ingredientName,  String amounts,  bool freezeOnArrival,  List<ShoppingPdfProductOption> products,  List<ShoppingPdfMealNeed> meals)  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry():
return $default(_that.ingredientName,_that.amounts,_that.freezeOnArrival,_that.products,_that.meals);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ingredientName,  String amounts,  bool freezeOnArrival,  List<ShoppingPdfProductOption> products,  List<ShoppingPdfMealNeed> meals)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfIngredientEntry() when $default != null:
return $default(_that.ingredientName,_that.amounts,_that.freezeOnArrival,_that.products,_that.meals);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingPdfIngredientEntry implements ShoppingPdfIngredientEntry {
  const _ShoppingPdfIngredientEntry({required this.ingredientName, required this.amounts, this.freezeOnArrival = false, final  List<ShoppingPdfProductOption> products = const [], final  List<ShoppingPdfMealNeed> meals = const []}): _products = products,_meals = meals;
  

@override final  String ingredientName;
/// The amount to buy, for example "500 grams + 2 pieces".
@override final  String amounts;
/// True when the reader must freeze the item on the day of the trip (ADR 0015).
@override@JsonKey() final  bool freezeOnArrival;
 final  List<ShoppingPdfProductOption> _products;
@override@JsonKey() List<ShoppingPdfProductOption> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  List<ShoppingPdfMealNeed> _meals;
@override@JsonKey() List<ShoppingPdfMealNeed> get meals {
  if (_meals is EqualUnmodifiableListView) return _meals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_meals);
}


/// Create a copy of ShoppingPdfIngredientEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingPdfIngredientEntryCopyWith<_ShoppingPdfIngredientEntry> get copyWith => __$ShoppingPdfIngredientEntryCopyWithImpl<_ShoppingPdfIngredientEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingPdfIngredientEntry&&(identical(other.ingredientName, ingredientName) || other.ingredientName == ingredientName)&&(identical(other.amounts, amounts) || other.amounts == amounts)&&(identical(other.freezeOnArrival, freezeOnArrival) || other.freezeOnArrival == freezeOnArrival)&&const DeepCollectionEquality().equals(other._products, _products)&&const DeepCollectionEquality().equals(other._meals, _meals));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientName,amounts,freezeOnArrival,const DeepCollectionEquality().hash(_products),const DeepCollectionEquality().hash(_meals));

@override
String toString() {
  return 'ShoppingPdfIngredientEntry(ingredientName: $ingredientName, amounts: $amounts, freezeOnArrival: $freezeOnArrival, products: $products, meals: $meals)';
}


}

/// @nodoc
abstract mixin class _$ShoppingPdfIngredientEntryCopyWith<$Res> implements $ShoppingPdfIngredientEntryCopyWith<$Res> {
  factory _$ShoppingPdfIngredientEntryCopyWith(_ShoppingPdfIngredientEntry value, $Res Function(_ShoppingPdfIngredientEntry) _then) = __$ShoppingPdfIngredientEntryCopyWithImpl;
@override @useResult
$Res call({
 String ingredientName, String amounts, bool freezeOnArrival, List<ShoppingPdfProductOption> products, List<ShoppingPdfMealNeed> meals
});




}
/// @nodoc
class __$ShoppingPdfIngredientEntryCopyWithImpl<$Res>
    implements _$ShoppingPdfIngredientEntryCopyWith<$Res> {
  __$ShoppingPdfIngredientEntryCopyWithImpl(this._self, this._then);

  final _ShoppingPdfIngredientEntry _self;
  final $Res Function(_ShoppingPdfIngredientEntry) _then;

/// Create a copy of ShoppingPdfIngredientEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientName = null,Object? amounts = null,Object? freezeOnArrival = null,Object? products = null,Object? meals = null,}) {
  return _then(_ShoppingPdfIngredientEntry(
ingredientName: null == ingredientName ? _self.ingredientName : ingredientName // ignore: cast_nullable_to_non_nullable
as String,amounts: null == amounts ? _self.amounts : amounts // ignore: cast_nullable_to_non_nullable
as String,freezeOnArrival: null == freezeOnArrival ? _self.freezeOnArrival : freezeOnArrival // ignore: cast_nullable_to_non_nullable
as bool,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfProductOption>,meals: null == meals ? _self._meals : meals // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfMealNeed>,
  ));
}


}

/// @nodoc
mixin _$ShoppingPdfTripSection {

 String get title; List<ShoppingPdfIngredientEntry> get ingredients;
/// Create a copy of ShoppingPdfTripSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingPdfTripSectionCopyWith<ShoppingPdfTripSection> get copyWith => _$ShoppingPdfTripSectionCopyWithImpl<ShoppingPdfTripSection>(this as ShoppingPdfTripSection, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingPdfTripSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.ingredients, ingredients));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(ingredients));

@override
String toString() {
  return 'ShoppingPdfTripSection(title: $title, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class $ShoppingPdfTripSectionCopyWith<$Res>  {
  factory $ShoppingPdfTripSectionCopyWith(ShoppingPdfTripSection value, $Res Function(ShoppingPdfTripSection) _then) = _$ShoppingPdfTripSectionCopyWithImpl;
@useResult
$Res call({
 String title, List<ShoppingPdfIngredientEntry> ingredients
});




}
/// @nodoc
class _$ShoppingPdfTripSectionCopyWithImpl<$Res>
    implements $ShoppingPdfTripSectionCopyWith<$Res> {
  _$ShoppingPdfTripSectionCopyWithImpl(this._self, this._then);

  final ShoppingPdfTripSection _self;
  final $Res Function(ShoppingPdfTripSection) _then;

/// Create a copy of ShoppingPdfTripSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? ingredients = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self.ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfIngredientEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingPdfTripSection].
extension ShoppingPdfTripSectionPatterns on ShoppingPdfTripSection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingPdfTripSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingPdfTripSection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingPdfTripSection value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfTripSection():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingPdfTripSection value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfTripSection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<ShoppingPdfIngredientEntry> ingredients)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingPdfTripSection() when $default != null:
return $default(_that.title,_that.ingredients);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<ShoppingPdfIngredientEntry> ingredients)  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfTripSection():
return $default(_that.title,_that.ingredients);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<ShoppingPdfIngredientEntry> ingredients)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfTripSection() when $default != null:
return $default(_that.title,_that.ingredients);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingPdfTripSection implements ShoppingPdfTripSection {
  const _ShoppingPdfTripSection({required this.title, final  List<ShoppingPdfIngredientEntry> ingredients = const []}): _ingredients = ingredients;
  

@override final  String title;
 final  List<ShoppingPdfIngredientEntry> _ingredients;
@override@JsonKey() List<ShoppingPdfIngredientEntry> get ingredients {
  if (_ingredients is EqualUnmodifiableListView) return _ingredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ingredients);
}


/// Create a copy of ShoppingPdfTripSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingPdfTripSectionCopyWith<_ShoppingPdfTripSection> get copyWith => __$ShoppingPdfTripSectionCopyWithImpl<_ShoppingPdfTripSection>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingPdfTripSection&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._ingredients, _ingredients));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_ingredients));

@override
String toString() {
  return 'ShoppingPdfTripSection(title: $title, ingredients: $ingredients)';
}


}

/// @nodoc
abstract mixin class _$ShoppingPdfTripSectionCopyWith<$Res> implements $ShoppingPdfTripSectionCopyWith<$Res> {
  factory _$ShoppingPdfTripSectionCopyWith(_ShoppingPdfTripSection value, $Res Function(_ShoppingPdfTripSection) _then) = __$ShoppingPdfTripSectionCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ShoppingPdfIngredientEntry> ingredients
});




}
/// @nodoc
class __$ShoppingPdfTripSectionCopyWithImpl<$Res>
    implements _$ShoppingPdfTripSectionCopyWith<$Res> {
  __$ShoppingPdfTripSectionCopyWithImpl(this._self, this._then);

  final _ShoppingPdfTripSection _self;
  final $Res Function(_ShoppingPdfTripSection) _then;

/// Create a copy of ShoppingPdfTripSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? ingredients = null,}) {
  return _then(_ShoppingPdfTripSection(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,ingredients: null == ingredients ? _self._ingredients : ingredients // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfIngredientEntry>,
  ));
}


}

/// @nodoc
mixin _$ShoppingPdfDocument {

 String get title; List<ShoppingPdfTripSection> get trips;
/// Create a copy of ShoppingPdfDocument
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShoppingPdfDocumentCopyWith<ShoppingPdfDocument> get copyWith => _$ShoppingPdfDocumentCopyWithImpl<ShoppingPdfDocument>(this as ShoppingPdfDocument, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShoppingPdfDocument&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.trips, trips));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(trips));

@override
String toString() {
  return 'ShoppingPdfDocument(title: $title, trips: $trips)';
}


}

/// @nodoc
abstract mixin class $ShoppingPdfDocumentCopyWith<$Res>  {
  factory $ShoppingPdfDocumentCopyWith(ShoppingPdfDocument value, $Res Function(ShoppingPdfDocument) _then) = _$ShoppingPdfDocumentCopyWithImpl;
@useResult
$Res call({
 String title, List<ShoppingPdfTripSection> trips
});




}
/// @nodoc
class _$ShoppingPdfDocumentCopyWithImpl<$Res>
    implements $ShoppingPdfDocumentCopyWith<$Res> {
  _$ShoppingPdfDocumentCopyWithImpl(this._self, this._then);

  final ShoppingPdfDocument _self;
  final $Res Function(ShoppingPdfDocument) _then;

/// Create a copy of ShoppingPdfDocument
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? trips = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,trips: null == trips ? _self.trips : trips // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfTripSection>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShoppingPdfDocument].
extension ShoppingPdfDocumentPatterns on ShoppingPdfDocument {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShoppingPdfDocument value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShoppingPdfDocument() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShoppingPdfDocument value)  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfDocument():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShoppingPdfDocument value)?  $default,){
final _that = this;
switch (_that) {
case _ShoppingPdfDocument() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  List<ShoppingPdfTripSection> trips)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShoppingPdfDocument() when $default != null:
return $default(_that.title,_that.trips);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  List<ShoppingPdfTripSection> trips)  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfDocument():
return $default(_that.title,_that.trips);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  List<ShoppingPdfTripSection> trips)?  $default,) {final _that = this;
switch (_that) {
case _ShoppingPdfDocument() when $default != null:
return $default(_that.title,_that.trips);case _:
  return null;

}
}

}

/// @nodoc


class _ShoppingPdfDocument implements ShoppingPdfDocument {
  const _ShoppingPdfDocument({required this.title, final  List<ShoppingPdfTripSection> trips = const []}): _trips = trips;
  

@override final  String title;
 final  List<ShoppingPdfTripSection> _trips;
@override@JsonKey() List<ShoppingPdfTripSection> get trips {
  if (_trips is EqualUnmodifiableListView) return _trips;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trips);
}


/// Create a copy of ShoppingPdfDocument
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShoppingPdfDocumentCopyWith<_ShoppingPdfDocument> get copyWith => __$ShoppingPdfDocumentCopyWithImpl<_ShoppingPdfDocument>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShoppingPdfDocument&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._trips, _trips));
}


@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_trips));

@override
String toString() {
  return 'ShoppingPdfDocument(title: $title, trips: $trips)';
}


}

/// @nodoc
abstract mixin class _$ShoppingPdfDocumentCopyWith<$Res> implements $ShoppingPdfDocumentCopyWith<$Res> {
  factory _$ShoppingPdfDocumentCopyWith(_ShoppingPdfDocument value, $Res Function(_ShoppingPdfDocument) _then) = __$ShoppingPdfDocumentCopyWithImpl;
@override @useResult
$Res call({
 String title, List<ShoppingPdfTripSection> trips
});




}
/// @nodoc
class __$ShoppingPdfDocumentCopyWithImpl<$Res>
    implements _$ShoppingPdfDocumentCopyWith<$Res> {
  __$ShoppingPdfDocumentCopyWithImpl(this._self, this._then);

  final _ShoppingPdfDocument _self;
  final $Res Function(_ShoppingPdfDocument) _then;

/// Create a copy of ShoppingPdfDocument
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? trips = null,}) {
  return _then(_ShoppingPdfDocument(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,trips: null == trips ? _self._trips : trips // ignore: cast_nullable_to_non_nullable
as List<ShoppingPdfTripSection>,
  ));
}


}

// dart format on
