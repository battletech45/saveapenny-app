// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transaction_history_entry_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringTransactionHistoryEntryResponse {

 String get id; String get recurringTransactionId; String get status; DateTime get scheduledDate; DateTime get executedAt; String? get transactionId; String? get failureReason;
/// Create a copy of RecurringTransactionHistoryEntryResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTransactionHistoryEntryResponseCopyWith<RecurringTransactionHistoryEntryResponse> get copyWith => _$RecurringTransactionHistoryEntryResponseCopyWithImpl<RecurringTransactionHistoryEntryResponse>(this as RecurringTransactionHistoryEntryResponse, _$identity);

  /// Serializes this RecurringTransactionHistoryEntryResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTransactionHistoryEntryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recurringTransactionId,status,scheduledDate,executedAt,transactionId,failureReason);

@override
String toString() {
  return 'RecurringTransactionHistoryEntryResponse(id: $id, recurringTransactionId: $recurringTransactionId, status: $status, scheduledDate: $scheduledDate, executedAt: $executedAt, transactionId: $transactionId, failureReason: $failureReason)';
}


}

/// @nodoc
abstract mixin class $RecurringTransactionHistoryEntryResponseCopyWith<$Res>  {
  factory $RecurringTransactionHistoryEntryResponseCopyWith(RecurringTransactionHistoryEntryResponse value, $Res Function(RecurringTransactionHistoryEntryResponse) _then) = _$RecurringTransactionHistoryEntryResponseCopyWithImpl;
@useResult
$Res call({
 String id, String recurringTransactionId, String status, DateTime scheduledDate, DateTime executedAt, String? transactionId, String? failureReason
});




}
/// @nodoc
class _$RecurringTransactionHistoryEntryResponseCopyWithImpl<$Res>
    implements $RecurringTransactionHistoryEntryResponseCopyWith<$Res> {
  _$RecurringTransactionHistoryEntryResponseCopyWithImpl(this._self, this._then);

  final RecurringTransactionHistoryEntryResponse _self;
  final $Res Function(RecurringTransactionHistoryEntryResponse) _then;

/// Create a copy of RecurringTransactionHistoryEntryResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? recurringTransactionId = null,Object? status = null,Object? scheduledDate = null,Object? executedAt = null,Object? transactionId = freezed,Object? failureReason = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recurringTransactionId: null == recurringTransactionId ? _self.recurringTransactionId : recurringTransactionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTransactionHistoryEntryResponse].
extension RecurringTransactionHistoryEntryResponsePatterns on RecurringTransactionHistoryEntryResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTransactionHistoryEntryResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTransactionHistoryEntryResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTransactionHistoryEntryResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String recurringTransactionId,  String status,  DateTime scheduledDate,  DateTime executedAt,  String? transactionId,  String? failureReason)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse() when $default != null:
return $default(_that.id,_that.recurringTransactionId,_that.status,_that.scheduledDate,_that.executedAt,_that.transactionId,_that.failureReason);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String recurringTransactionId,  String status,  DateTime scheduledDate,  DateTime executedAt,  String? transactionId,  String? failureReason)  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse():
return $default(_that.id,_that.recurringTransactionId,_that.status,_that.scheduledDate,_that.executedAt,_that.transactionId,_that.failureReason);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String recurringTransactionId,  String status,  DateTime scheduledDate,  DateTime executedAt,  String? transactionId,  String? failureReason)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryEntryResponse() when $default != null:
return $default(_that.id,_that.recurringTransactionId,_that.status,_that.scheduledDate,_that.executedAt,_that.transactionId,_that.failureReason);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringTransactionHistoryEntryResponse implements RecurringTransactionHistoryEntryResponse {
  const _RecurringTransactionHistoryEntryResponse({required this.id, required this.recurringTransactionId, required this.status, required this.scheduledDate, required this.executedAt, this.transactionId, this.failureReason});
  factory _RecurringTransactionHistoryEntryResponse.fromJson(Map<String, dynamic> json) => _$RecurringTransactionHistoryEntryResponseFromJson(json);

@override final  String id;
@override final  String recurringTransactionId;
@override final  String status;
@override final  DateTime scheduledDate;
@override final  DateTime executedAt;
@override final  String? transactionId;
@override final  String? failureReason;

/// Create a copy of RecurringTransactionHistoryEntryResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTransactionHistoryEntryResponseCopyWith<_RecurringTransactionHistoryEntryResponse> get copyWith => __$RecurringTransactionHistoryEntryResponseCopyWithImpl<_RecurringTransactionHistoryEntryResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringTransactionHistoryEntryResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTransactionHistoryEntryResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.recurringTransactionId, recurringTransactionId) || other.recurringTransactionId == recurringTransactionId)&&(identical(other.status, status) || other.status == status)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.executedAt, executedAt) || other.executedAt == executedAt)&&(identical(other.transactionId, transactionId) || other.transactionId == transactionId)&&(identical(other.failureReason, failureReason) || other.failureReason == failureReason));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,recurringTransactionId,status,scheduledDate,executedAt,transactionId,failureReason);

@override
String toString() {
  return 'RecurringTransactionHistoryEntryResponse(id: $id, recurringTransactionId: $recurringTransactionId, status: $status, scheduledDate: $scheduledDate, executedAt: $executedAt, transactionId: $transactionId, failureReason: $failureReason)';
}


}

/// @nodoc
abstract mixin class _$RecurringTransactionHistoryEntryResponseCopyWith<$Res> implements $RecurringTransactionHistoryEntryResponseCopyWith<$Res> {
  factory _$RecurringTransactionHistoryEntryResponseCopyWith(_RecurringTransactionHistoryEntryResponse value, $Res Function(_RecurringTransactionHistoryEntryResponse) _then) = __$RecurringTransactionHistoryEntryResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String recurringTransactionId, String status, DateTime scheduledDate, DateTime executedAt, String? transactionId, String? failureReason
});




}
/// @nodoc
class __$RecurringTransactionHistoryEntryResponseCopyWithImpl<$Res>
    implements _$RecurringTransactionHistoryEntryResponseCopyWith<$Res> {
  __$RecurringTransactionHistoryEntryResponseCopyWithImpl(this._self, this._then);

  final _RecurringTransactionHistoryEntryResponse _self;
  final $Res Function(_RecurringTransactionHistoryEntryResponse) _then;

/// Create a copy of RecurringTransactionHistoryEntryResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? recurringTransactionId = null,Object? status = null,Object? scheduledDate = null,Object? executedAt = null,Object? transactionId = freezed,Object? failureReason = freezed,}) {
  return _then(_RecurringTransactionHistoryEntryResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,recurringTransactionId: null == recurringTransactionId ? _self.recurringTransactionId : recurringTransactionId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,scheduledDate: null == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime,executedAt: null == executedAt ? _self.executedAt : executedAt // ignore: cast_nullable_to_non_nullable
as DateTime,transactionId: freezed == transactionId ? _self.transactionId : transactionId // ignore: cast_nullable_to_non_nullable
as String?,failureReason: freezed == failureReason ? _self.failureReason : failureReason // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
