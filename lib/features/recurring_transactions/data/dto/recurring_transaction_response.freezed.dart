// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transaction_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecurringTransactionResponse {

 String get id; String get userId; String get accountId; String get categoryId; String get type; num get amount; String get frequency; DateTime get nextRunDate; String get status; String? get name; String? get description; DateTime? get startDate; DateTime? get endDate; DateTime? get lastRunAt; String? get classification; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of RecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTransactionResponseCopyWith<RecurringTransactionResponse> get copyWith => _$RecurringTransactionResponseCopyWithImpl<RecurringTransactionResponse>(this as RecurringTransactionResponse, _$identity);

  /// Serializes this RecurringTransactionResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTransactionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextRunDate, nextRunDate) || other.nextRunDate == nextRunDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,accountId,categoryId,type,amount,frequency,nextRunDate,status,name,description,startDate,endDate,lastRunAt,classification,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringTransactionResponse(id: $id, userId: $userId, accountId: $accountId, categoryId: $categoryId, type: $type, amount: $amount, frequency: $frequency, nextRunDate: $nextRunDate, status: $status, name: $name, description: $description, startDate: $startDate, endDate: $endDate, lastRunAt: $lastRunAt, classification: $classification, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RecurringTransactionResponseCopyWith<$Res>  {
  factory $RecurringTransactionResponseCopyWith(RecurringTransactionResponse value, $Res Function(RecurringTransactionResponse) _then) = _$RecurringTransactionResponseCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String accountId, String categoryId, String type, num amount, String frequency, DateTime nextRunDate, String status, String? name, String? description, DateTime? startDate, DateTime? endDate, DateTime? lastRunAt, String? classification, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$RecurringTransactionResponseCopyWithImpl<$Res>
    implements $RecurringTransactionResponseCopyWith<$Res> {
  _$RecurringTransactionResponseCopyWithImpl(this._self, this._then);

  final RecurringTransactionResponse _self;
  final $Res Function(RecurringTransactionResponse) _then;

/// Create a copy of RecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? categoryId = null,Object? type = null,Object? amount = null,Object? frequency = null,Object? nextRunDate = null,Object? status = null,Object? name = freezed,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? lastRunAt = freezed,Object? classification = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextRunDate: null == nextRunDate ? _self.nextRunDate : nextRunDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTransactionResponse].
extension RecurringTransactionResponsePatterns on RecurringTransactionResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTransactionResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTransactionResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTransactionResponse value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTransactionResponse value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String categoryId,  String type,  num amount,  String frequency,  DateTime nextRunDate,  String status,  String? name,  String? description,  DateTime? startDate,  DateTime? endDate,  DateTime? lastRunAt,  String? classification,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTransactionResponse() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.status,_that.name,_that.description,_that.startDate,_that.endDate,_that.lastRunAt,_that.classification,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String accountId,  String categoryId,  String type,  num amount,  String frequency,  DateTime nextRunDate,  String status,  String? name,  String? description,  DateTime? startDate,  DateTime? endDate,  DateTime? lastRunAt,  String? classification,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionResponse():
return $default(_that.id,_that.userId,_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.status,_that.name,_that.description,_that.startDate,_that.endDate,_that.lastRunAt,_that.classification,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String accountId,  String categoryId,  String type,  num amount,  String frequency,  DateTime nextRunDate,  String status,  String? name,  String? description,  DateTime? startDate,  DateTime? endDate,  DateTime? lastRunAt,  String? classification,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionResponse() when $default != null:
return $default(_that.id,_that.userId,_that.accountId,_that.categoryId,_that.type,_that.amount,_that.frequency,_that.nextRunDate,_that.status,_that.name,_that.description,_that.startDate,_that.endDate,_that.lastRunAt,_that.classification,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecurringTransactionResponse implements RecurringTransactionResponse {
  const _RecurringTransactionResponse({required this.id, required this.userId, required this.accountId, required this.categoryId, required this.type, required this.amount, required this.frequency, required this.nextRunDate, required this.status, this.name, this.description, this.startDate, this.endDate, this.lastRunAt, this.classification, required this.createdAt, required this.updatedAt});
  factory _RecurringTransactionResponse.fromJson(Map<String, dynamic> json) => _$RecurringTransactionResponseFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String accountId;
@override final  String categoryId;
@override final  String type;
@override final  num amount;
@override final  String frequency;
@override final  DateTime nextRunDate;
@override final  String status;
@override final  String? name;
@override final  String? description;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override final  DateTime? lastRunAt;
@override final  String? classification;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of RecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTransactionResponseCopyWith<_RecurringTransactionResponse> get copyWith => __$RecurringTransactionResponseCopyWithImpl<_RecurringTransactionResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecurringTransactionResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTransactionResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.accountId, accountId) || other.accountId == accountId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.frequency, frequency) || other.frequency == frequency)&&(identical(other.nextRunDate, nextRunDate) || other.nextRunDate == nextRunDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.classification, classification) || other.classification == classification)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,accountId,categoryId,type,amount,frequency,nextRunDate,status,name,description,startDate,endDate,lastRunAt,classification,createdAt,updatedAt);

@override
String toString() {
  return 'RecurringTransactionResponse(id: $id, userId: $userId, accountId: $accountId, categoryId: $categoryId, type: $type, amount: $amount, frequency: $frequency, nextRunDate: $nextRunDate, status: $status, name: $name, description: $description, startDate: $startDate, endDate: $endDate, lastRunAt: $lastRunAt, classification: $classification, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RecurringTransactionResponseCopyWith<$Res> implements $RecurringTransactionResponseCopyWith<$Res> {
  factory _$RecurringTransactionResponseCopyWith(_RecurringTransactionResponse value, $Res Function(_RecurringTransactionResponse) _then) = __$RecurringTransactionResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String accountId, String categoryId, String type, num amount, String frequency, DateTime nextRunDate, String status, String? name, String? description, DateTime? startDate, DateTime? endDate, DateTime? lastRunAt, String? classification, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$RecurringTransactionResponseCopyWithImpl<$Res>
    implements _$RecurringTransactionResponseCopyWith<$Res> {
  __$RecurringTransactionResponseCopyWithImpl(this._self, this._then);

  final _RecurringTransactionResponse _self;
  final $Res Function(_RecurringTransactionResponse) _then;

/// Create a copy of RecurringTransactionResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? accountId = null,Object? categoryId = null,Object? type = null,Object? amount = null,Object? frequency = null,Object? nextRunDate = null,Object? status = null,Object? name = freezed,Object? description = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? lastRunAt = freezed,Object? classification = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_RecurringTransactionResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,accountId: null == accountId ? _self.accountId : accountId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,frequency: null == frequency ? _self.frequency : frequency // ignore: cast_nullable_to_non_nullable
as String,nextRunDate: null == nextRunDate ? _self.nextRunDate : nextRunDate // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,classification: freezed == classification ? _self.classification : classification // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
