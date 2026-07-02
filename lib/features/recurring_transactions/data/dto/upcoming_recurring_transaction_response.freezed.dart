// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upcoming_recurring_transaction_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpcomingRecurringTransactionResponse {

 String get recurringTransactionId; String? get name; num get amount; DateTime get scheduledDate;
/// Create a copy of UpcomingRecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpcomingRecurringTransactionResponseCopyWith<UpcomingRecurringTransactionResponse> get copyWith => _$UpcomingRecurringTransactionResponseCopyWithImpl<UpcomingRecurringTransactionResponse>(this as UpcomingRecurringTransactionResponse, _$identity);

  /// Serializes this UpcomingRecurringTransactionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpcomingRecurringTransactionResponse&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recurringTransactionId,name,amount,scheduledDate);

@override
String toString() {
  return 'UpcomingRecurringTransactionResponse(recurringTransactionId: $recurringTransactionId, name: $name, amount: $amount, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class $UpcomingRecurringTransactionResponseCopyWith<$Res>  {
  factory $UpcomingRecurringTransactionResponseCopyWith(UpcomingRecurringTransactionResponse value, $Res Function(UpcomingRecurringTransactionResponse) _then) = _$UpcomingRecurringTransactionResponseCopyWithImpl;
@useResult
$Res call({
 String recurringTransactionId, String? name, num amount, DateTime scheduledDate
});




}
/// @nodoc
class _$UpcomingRecurringTransactionResponseCopyWithImpl<$Res>
    implements $UpcomingRecurringTransactionResponseCopyWith<$Res> {
  _$UpcomingRecurringTransactionResponseCopyWithImpl(this._self, this._then);

  final UpcomingRecurringTransactionResponse _self;
  final $Res Function(UpcomingRecurringTransactionResponse) _then;

/// Create a copy of UpcomingRecurringTransactionResponse
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


/// Adds pattern-matching-related methods to [UpcomingRecurringTransactionResponse].
extension UpcomingRecurringTransactionResponsePatterns on UpcomingRecurringTransactionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpcomingRecurringTransactionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransactionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpcomingRecurringTransactionResponse value)  $default,){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransactionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpcomingRecurringTransactionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _UpcomingRecurringTransactionResponse() when $default != null:
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
case _UpcomingRecurringTransactionResponse() when $default != null:
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
case _UpcomingRecurringTransactionResponse():
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
case _UpcomingRecurringTransactionResponse() when $default != null:
return $default(_that.recurringTransactionId,_that.name,_that.amount,_that.scheduledDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpcomingRecurringTransactionResponse implements UpcomingRecurringTransactionResponse {
  const _UpcomingRecurringTransactionResponse({required this.recurringTransactionId, this.name, required this.amount, required this.scheduledDate});
  factory _UpcomingRecurringTransactionResponse.fromJson(Map<String, dynamic> json) => _$UpcomingRecurringTransactionResponseFromJson(json);

@override final  String recurringTransactionId;
@override final  String? name;
@override final  num amount;
@override final  DateTime scheduledDate;

/// Create a copy of UpcomingRecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpcomingRecurringTransactionResponseCopyWith<_UpcomingRecurringTransactionResponse> get copyWith => __$UpcomingRecurringTransactionResponseCopyWithImpl<_UpcomingRecurringTransactionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpcomingRecurringTransactionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpcomingRecurringTransactionResponse&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recurringTransactionId,name,amount,scheduledDate);

@override
String toString() {
  return 'UpcomingRecurringTransactionResponse(recurringTransactionId: $recurringTransactionId, name: $name, amount: $amount, scheduledDate: $scheduledDate)';
}


}

/// @nodoc
abstract mixin class _$UpcomingRecurringTransactionResponseCopyWith<$Res> implements $UpcomingRecurringTransactionResponseCopyWith<$Res> {
  factory _$UpcomingRecurringTransactionResponseCopyWith(_UpcomingRecurringTransactionResponse value, $Res Function(_UpcomingRecurringTransactionResponse) _then) = __$UpcomingRecurringTransactionResponseCopyWithImpl;
@override @useResult
$Res call({
 String recurringTransactionId, String? name, num amount, DateTime scheduledDate
});




}
/// @nodoc
class __$UpcomingRecurringTransactionResponseCopyWithImpl<$Res>
    implements _$UpcomingRecurringTransactionResponseCopyWith<$Res> {
  __$UpcomingRecurringTransactionResponseCopyWithImpl(this._self, this._then);

  final _UpcomingRecurringTransactionResponse _self;
  final $Res Function(_UpcomingRecurringTransactionResponse) _then;

/// Create a copy of UpcomingRecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recurringTransactionId = null,Object? name = freezed,Object? amount = null,Object? scheduledDate = null,}) {
  return _then(_UpcomingRecurringTransactionResponse(
recurringTransactionId: null == recurringTransactionId ? _self.recurringTransactionId : recurringTransactionId // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
