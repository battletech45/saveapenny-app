// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_recurring_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpcomingRecurringTransaction {

 String get recurringTransactionId; String? get name; num get amount; DateTime get scheduledDate;
/// Create a copy of UpcomingRecurringTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingRecurringTransactionCopyWith<UpcomingRecurringTransaction> get copyWith => _$UpcomingRecurringTransactionCopyWithImpl<UpcomingRecurringTransaction>(this as UpcomingRecurringTransaction, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingRecurringTransaction&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}


@override
int get hashCode => Object.hash(runtimeType,recurringTransactionId,name,amount,scheduledDate);

@override
String toString() {
  return 'UpcomingRecurringTransaction(recurringTransactionId: $recurringTransactionId, name: $name, amount: $amount, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class $UpcomingRecurringTransactionCopyWith<$Res>  {
  factory $UpcomingRecurringTransactionCopyWith(UpcomingRecurringTransaction value, $Res Function(UpcomingRecurringTransaction) _then) = _$UpcomingRecurringTransactionCopyWithImpl;
@useResult
$Res call({
 String recurringTransactionId, String? name, num amount, DateTime scheduledDate
});




}
/// @nodoc
class _$UpcomingRecurringTransactionCopyWithImpl<$Res>
    implements $UpcomingRecurringTransactionCopyWith<$Res> {
  _$UpcomingRecurringTransactionCopyWithImpl(this._self, this._then);

  final UpcomingRecurringTransaction _self;
  final $Res Function(UpcomingRecurringTransaction) _then;

/// Create a copy of UpcomingRecurringTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recurringTransactionId = null,Object? name = freezed,Object? amount = null,Object? scheduledDate = null,}) {
  return _then(_self.copyWith(
recurringTransactionId: null == recurringTransactionId ? _self.recurringTransactionId : recurringTransactionId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [UpcomingRecurringTransaction].
extension UpcomingRecurringTransactionPatterns on UpcomingRecurringTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingRecurringTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingRecurringTransaction value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingRecurringTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recurringTransactionId,  String? name,  num amount,  DateTime scheduledDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction() when $default != null:
return $default(_that.recurringTransactionId,_that.name,_that.amount,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recurringTransactionId,  String? name,  num amount,  DateTime scheduledDate)  $default,) {final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction():
return $default(_that.recurringTransactionId,_that.name,_that.amount,_that.scheduledDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recurringTransactionId,  String? name,  num amount,  DateTime scheduledDate)?  $default,) {final _that = this;
switch (_that) {
case _UpcomingRecurringTransaction() when $default != null:
return $default(_that.recurringTransactionId,_that.name,_that.amount,_that.scheduledDate);case _:
  return null;

}
}

}

/// @nodoc


class _UpcomingRecurringTransaction implements UpcomingRecurringTransaction {
  const _UpcomingRecurringTransaction({required this.recurringTransactionId, this.name, required this.amount, required this.scheduledDate});
  

@override final  String recurringTransactionId;
@override final  String? name;
@override final  num amount;
@override final  DateTime scheduledDate;

/// Create a copy of UpcomingRecurringTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingRecurringTransactionCopyWith<_UpcomingRecurringTransaction> get copyWith => __$UpcomingRecurringTransactionCopyWithImpl<_UpcomingRecurringTransaction>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingRecurringTransaction&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}


@override
int get hashCode => Object.hash(runtimeType,recurringTransactionId,name,amount,scheduledDate);

@override
String toString() {
  return 'UpcomingRecurringTransaction(recurringTransactionId: $recurringTransactionId, name: $name, amount: $amount, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class _$UpcomingRecurringTransactionCopyWith<$Res> implements $UpcomingRecurringTransactionCopyWith<$Res> {
  factory _$UpcomingRecurringTransactionCopyWith(_UpcomingRecurringTransaction value, $Res Function(_UpcomingRecurringTransaction) _then) = __$UpcomingRecurringTransactionCopyWithImpl;
@override @useResult
$Res call({
 String recurringTransactionId, String? name, num amount, DateTime scheduledDate
});




}
/// @nodoc
class __$UpcomingRecurringTransactionCopyWithImpl<$Res>
    implements _$UpcomingRecurringTransactionCopyWith<$Res> {
  __$UpcomingRecurringTransactionCopyWithImpl(this._self, this._then);

  final _UpcomingRecurringTransaction _self;
  final $Res Function(_UpcomingRecurringTransaction) _then;

/// Create a copy of UpcomingRecurringTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recurringTransactionId = null,Object? name = freezed,Object? amount = null,Object? scheduledDate = null,}) {
  return _then(_UpcomingRecurringTransaction(
recurringTransactionId: null == recurringTransactionId ? _self.recurringTransactionId : recurringTransactionId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
