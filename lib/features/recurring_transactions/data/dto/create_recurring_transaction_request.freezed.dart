// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_recurring_transaction_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateRecurringTransactionRequest {

 String get accountId; String get categoryId; String get type; num get amount; String get frequency; String get nextRunDate; String? get name; String? get description; String? get startDate; String? get endDate; String? get classification;
/// Create a copy of CreateRecurringTransactionRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRecurringTransactionRequestCopyWith<CreateRecurringTransactionRequest> get copyWith => _$CreateRecurringTransactionRequestCopyWithImpl<CreateRecurringTransactionRequest>(this as CreateRecurringTransactionRequest, _$identity);

  /// Serializes this CreateRecurringTransactionRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRecurringTransactionRequest&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextRunDate, nextRunDate) || other.nextRunDate == nextRunDate)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.classification, classification) || other.classification == classification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,type,amount,frequency,nextRunDate,name,description,startDate,endDate,classification);

@override
String toString() {
  return 'CreateRecurringTransactionRequest(accountId: $accountId, categoryId: $categoryId, type: $type, amount: $amount, frequency: $frequency, nextRunDate: $nextRunDate, name: $name, description: $description, startDate: $startDate, endDate: $endDate, classification: $classification)';
}


}

/// @nodoc
abstract mixin class $CreateRecurringTransactionRequestCopyWith<$Res>  {
  factory $CreateRecurringTransactionRequestCopyWith(CreateRecurringTransactionRequest value, $Res Function(CreateRecurringTransactionRequest) _then) = _$CreateRecurringTransactionRequestCopyWithImpl;
@useResult
$Res call({
 String accountId, String categoryId, String type, num amount, String frequency, String nextRunDate, String? name, String? description, String? startDate, String? endDate, String? classification
});




}
/// @nodoc
class _$CreateRecurringTransactionRequestCopyWithImpl<$Res>
    implements $CreateRecurringTransactionRequestCopyWith<$Res> {
  _$CreateRecurringTransactionRequestCopyWithImpl(this._self, this._then);

  final CreateRecurringTransactionRequest _self;
  final $Res Function(CreateRecurringTransactionRequest) _then;

/// Create a copy of CreateRecurringTransactionRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? accountId = null,Object? categoryId = null,Object? type = null,Object? amount = null,Object? frequency = null,Object? nextRunDate = null,Object? name = freezed,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? classification = freezed,}) {
  return _then(_self.copyWith(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextRunDate: null == nextRunDate ? _self.nextRunDate : nextRunDate // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRecurringTransactionRequest].
extension CreateRecurringTransactionRequestPatterns on CreateRecurringTransactionRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRecurringTransactionRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRecurringTransactionRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRecurringTransactionRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String accountId,  String categoryId,  String type,  num amount,  String frequency,  String nextRunDate,  String? name,  String? description,  String? startDate,  String? endDate,  String? classification)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest() when $default != null:
return $default(_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.name,_that.description,_that.startDate,_that.endDate,_that.classification);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String accountId,  String categoryId,  String type,  num amount,  String frequency,  String nextRunDate,  String? name,  String? description,  String? startDate,  String? endDate,  String? classification)  $default,) {final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest():
return $default(_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.name,_that.description,_that.startDate,_that.endDate,_that.classification);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String accountId,  String categoryId,  String type,  num amount,  String frequency,  String nextRunDate,  String? name,  String? description,  String? startDate,  String? endDate,  String? classification)?  $default,) {final _that = this;
switch (_that) {
case _CreateRecurringTransactionRequest() when $default != null:
return $default(_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.name,_that.description,_that.startDate,_that.endDate,_that.classification);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRecurringTransactionRequest implements CreateRecurringTransactionRequest {
  const _CreateRecurringTransactionRequest({required this.accountId, required this.categoryId, required this.type, required this.amount, required this.frequency, required this.nextRunDate, this.name, this.description, this.startDate, this.endDate, this.classification});
  factory _CreateRecurringTransactionRequest.fromJson(Map<String, dynamic> json) => _$CreateRecurringTransactionRequestFromJson(json);

@override final  String accountId;
@override final  String categoryId;
@override final  String type;
@override final  num amount;
@override final  String frequency;
@override final  String nextRunDate;
@override final  String? name;
@override final  String? description;
@override final  String? startDate;
@override final  String? endDate;
@override final  String? classification;

/// Create a copy of CreateRecurringTransactionRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRecurringTransactionRequestCopyWith<_CreateRecurringTransactionRequest> get copyWith => __$CreateRecurringTransactionRequestCopyWithImpl<_CreateRecurringTransactionRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRecurringTransactionRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRecurringTransactionRequest&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextRunDate, nextRunDate) || other.nextRunDate == nextRunDate)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.classification, classification) || other.classification == classification));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,accountId,categoryId,type,amount,frequency,nextRunDate,name,description,startDate,endDate,classification);

@override
String toString() {
  return 'CreateRecurringTransactionRequest(accountId: $accountId, categoryId: $categoryId, type: $type, amount: $amount, frequency: $frequency, nextRunDate: $nextRunDate, name: $name, description: $description, startDate: $startDate, endDate: $endDate, classification: $classification)';
}


}

/// @nodoc
abstract mixin class _$CreateRecurringTransactionRequestCopyWith<$Res> implements $CreateRecurringTransactionRequestCopyWith<$Res> {
  factory _$CreateRecurringTransactionRequestCopyWith(_CreateRecurringTransactionRequest value, $Res Function(_CreateRecurringTransactionRequest) _then) = __$CreateRecurringTransactionRequestCopyWithImpl;
@override @useResult
$Res call({
 String accountId, String categoryId, String type, num amount, String frequency, String nextRunDate, String? name, String? description, String? startDate, String? endDate, String? classification
});




}
/// @nodoc
class __$CreateRecurringTransactionRequestCopyWithImpl<$Res>
    implements _$CreateRecurringTransactionRequestCopyWith<$Res> {
  __$CreateRecurringTransactionRequestCopyWithImpl(this._self, this._then);

  final _CreateRecurringTransactionRequest _self;
  final $Res Function(_CreateRecurringTransactionRequest) _then;

/// Create a copy of CreateRecurringTransactionRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? accountId = null,Object? categoryId = null,Object? type = null,Object? amount = null,Object? frequency = null,Object? nextRunDate = null,Object? name = freezed,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? classification = freezed,}) {
  return _then(_CreateRecurringTransactionRequest(
accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextRunDate: null == nextRunDate ? _self.nextRunDate : nextRunDate // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
