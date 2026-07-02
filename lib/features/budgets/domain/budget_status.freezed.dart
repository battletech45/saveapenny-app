// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetStatus {

 String get category; num get budgetAmount; num get spentAmount; num get remainingAmount; num get usagePercentage; BudgetHealth get status;
/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<BudgetStatus> get copyWith => _$BudgetStatusCopyWithImpl<BudgetStatus>(this as BudgetStatus, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetStatus&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.usagePercentage, usagePercentage) || other.usagePercentage == usagePercentage)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,category,budgetAmount,spentAmount,remainingAmount,usagePercentage,status);

@override
String toString() {
  return 'BudgetStatus(category: $category, budgetAmount: $budgetAmount, spentAmount: $spentAmount, remainingAmount: $remainingAmount, usagePercentage: $usagePercentage, status: $status)';
}


}

/// @nodoc
abstract mixin class $BudgetStatusCopyWith<$Res>  {
  factory $BudgetStatusCopyWith(BudgetStatus value, $Res Function(BudgetStatus) _then) = _$BudgetStatusCopyWithImpl;
@useResult
$Res call({
 String category, num budgetAmount, num spentAmount, num remainingAmount, num usagePercentage, BudgetHealth status
});




}
/// @nodoc
class _$BudgetStatusCopyWithImpl<$Res>
    implements $BudgetStatusCopyWith<$Res> {
  _$BudgetStatusCopyWithImpl(this._self, this._then);

  final BudgetStatus _self;
  final $Res Function(BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? budgetAmount = null,Object? spentAmount = null,Object? remainingAmount = null,Object? usagePercentage = null,Object? status = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as num,spentAmount: null == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as num,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,usagePercentage: null == usagePercentage ? _self.usagePercentage : usagePercentage // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetHealth,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetStatus].
extension BudgetStatusPatterns on BudgetStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetStatus value)  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetStatus value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  BudgetHealth status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  BudgetHealth status)  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String category,  num budgetAmount,  num spentAmount,  num remainingAmount,  num usagePercentage,  BudgetHealth status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetStatus() when $default != null:
return $default(_that.category,_that.budgetAmount,_that.spentAmount,_that.remainingAmount,_that.usagePercentage,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetStatus implements BudgetStatus {
  const _BudgetStatus({required this.category, required this.budgetAmount, required this.spentAmount, required this.remainingAmount, required this.usagePercentage, required this.status});
  

@override final  String category;
@override final  num budgetAmount;
@override final  num spentAmount;
@override final  num remainingAmount;
@override final  num usagePercentage;
@override final  BudgetHealth status;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetStatusCopyWith<_BudgetStatus> get copyWith => __$BudgetStatusCopyWithImpl<_BudgetStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetStatus&&(identical(other.category, category) || other.category == category)&&(identical(other.budgetAmount, budgetAmount) || other.budgetAmount == budgetAmount)&&(identical(other.spentAmount, spentAmount) || other.spentAmount == spentAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.usagePercentage, usagePercentage) || other.usagePercentage == usagePercentage)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,category,budgetAmount,spentAmount,remainingAmount,usagePercentage,status);

@override
String toString() {
  return 'BudgetStatus(category: $category, budgetAmount: $budgetAmount, spentAmount: $spentAmount, remainingAmount: $remainingAmount, usagePercentage: $usagePercentage, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetStatusCopyWith<$Res> implements $BudgetStatusCopyWith<$Res> {
  factory _$BudgetStatusCopyWith(_BudgetStatus value, $Res Function(_BudgetStatus) _then) = __$BudgetStatusCopyWithImpl;
@override @useResult
$Res call({
 String category, num budgetAmount, num spentAmount, num remainingAmount, num usagePercentage, BudgetHealth status
});




}
/// @nodoc
class __$BudgetStatusCopyWithImpl<$Res>
    implements _$BudgetStatusCopyWith<$Res> {
  __$BudgetStatusCopyWithImpl(this._self, this._then);

  final _BudgetStatus _self;
  final $Res Function(_BudgetStatus) _then;

/// Create a copy of BudgetStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? budgetAmount = null,Object? spentAmount = null,Object? remainingAmount = null,Object? usagePercentage = null,Object? status = null,}) {
  return _then(_BudgetStatus(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,budgetAmount: null == budgetAmount ? _self.budgetAmount : budgetAmount // ignore: cast_nullable_to_non_nullable
as num,spentAmount: null == spentAmount ? _self.spentAmount : spentAmount // ignore: cast_nullable_to_non_nullable
as num,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as num,usagePercentage: null == usagePercentage ? _self.usagePercentage : usagePercentage // ignore: cast_nullable_to_non_nullable
as num,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetHealth,
  ));
}


}

// dart format on
