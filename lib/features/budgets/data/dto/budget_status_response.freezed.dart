// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_status_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetStatusResponse {

 String get category; num get budgetAmount; num get spentAmount; num get remainingAmount; num get usagePercentage; String get status;
/// Create a copy of BudgetStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStatusResponseCopyWith<BudgetStatusResponse> get copyWith => _$BudgetStatusResponseCopyWithImpl<BudgetStatusResponse>(this as BudgetStatusResponse, _$identity);

  /// Serializes this BudgetStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetStatusResponse&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.usagePercentage, usagePercentage) || other.usagePercentage == usagePercentage)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,budgetAmount,spentAmount,remainingAmount,usagePercentage,status);

@override
String toString() {
  return 'BudgetStatusResponse(category: $category, budgetAmount: $budgetAmount, spentAmount: $spentAmount, remainingAmount: $remainingAmount, usagePercentage: $usagePercentage, status: $status)';
}


}

/// @nodoc
abstract mixin class $BudgetStatusResponseCopyWith<$Res>  {
  factory $BudgetStatusResponseCopyWith(BudgetStatusResponse value, $Res Function(BudgetStatusResponse) _then) = _$BudgetStatusResponseCopyWithImpl;
@useResult
$Res call({
 String category, num budgetAmount, num spentAmount, num remainingAmount, num usagePercentage, String status
});




}
/// @nodoc
class _$BudgetStatusResponseCopyWithImpl<$Res>
    implements $BudgetStatusResponseCopyWith<$Res> {
  _$BudgetStatusResponseCopyWithImpl(this._self, this._then);

  final BudgetStatusResponse _self;
  final $Res Function(BudgetStatusResponse) _then;

/// Create a copy of BudgetStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? budgetAmount = null,Object? spentAmount = null,Object? remainingAmount = null,Object? usagePercentage = null,Object? status = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as num,spentAmount: null == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as num,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,usagePercentage: null == usagePercentage ? _self.usagePercentage : usagePercentage // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetStatusResponse].
extension BudgetStatusResponsePatterns on BudgetStatusResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetStatusResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _BudgetStatusResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetStatusResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetStatusResponse() when $default != null:
return $default(_that.category,_that.budgetAmount,_that.spentAmount,_that.remainingAmount,_that.usagePercentage,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  String status)  $default,) {final _that = this;
switch (_that) {
case _BudgetStatusResponse():
return $default(_that.category,_that.budgetAmount,_that.spentAmount,_that.remainingAmount,_that.usagePercentage,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  String status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetStatusResponse() when $default != null:
return $default(_that.category,_that.budgetAmount,_that.spentAmount,_that.remainingAmount,_that.usagePercentage,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetStatusResponse implements BudgetStatusResponse {
  const _BudgetStatusResponse({required this.category, required this.budgetAmount, required this.spentAmount, required this.remainingAmount, required this.usagePercentage, required this.status});
  factory _BudgetStatusResponse.fromJson(Map<String, dynamic> json) => _$BudgetStatusResponseFromJson(json);

@override final  String category;
@override final  num budgetAmount;
@override final  num spentAmount;
@override final  num remainingAmount;
@override final  num usagePercentage;
@override final  String status;

/// Create a copy of BudgetStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStatusResponseCopyWith<_BudgetStatusResponse> get copyWith => __$BudgetStatusResponseCopyWithImpl<_BudgetStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetStatusResponse&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.usagePercentage, usagePercentage) || other.usagePercentage == usagePercentage)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,budgetAmount,spentAmount,remainingAmount,usagePercentage,status);

@override
String toString() {
  return 'BudgetStatusResponse(category: $category, budgetAmount: $budgetAmount, spentAmount: $spentAmount, remainingAmount: $remainingAmount, usagePercentage: $usagePercentage, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetStatusResponseCopyWith<$Res> implements $BudgetStatusResponseCopyWith<$Res> {
  factory _$BudgetStatusResponseCopyWith(_BudgetStatusResponse value, $Res Function(_BudgetStatusResponse) _then) = __$BudgetStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 String category, num budgetAmount, num spentAmount, num remainingAmount, num usagePercentage, String status
});




}
/// @nodoc
class __$BudgetStatusResponseCopyWithImpl<$Res>
    implements _$BudgetStatusResponseCopyWith<$Res> {
  __$BudgetStatusResponseCopyWithImpl(this._self, this._then);

  final _BudgetStatusResponse _self;
  final $Res Function(_BudgetStatusResponse) _then;

/// Create a copy of BudgetStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? budgetAmount = null,Object? spentAmount = null,Object? remainingAmount = null,Object? usagePercentage = null,Object? status = null,}) {
  return _then(_BudgetStatusResponse(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as num,spentAmount: null == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as num,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,usagePercentage: null == usagePercentage ? _self.usagePercentage : usagePercentage // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
