// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetResponse {

 String get id; String get userId; String get categoryId; num get amount; String get period; DateTime get startDate; DateTime get endDate; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of BudgetResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetResponseCopyWith<BudgetResponse> get copyWith => _$BudgetResponseCopyWithImpl<BudgetResponse>(this as BudgetResponse, _$identity);

  /// Serializes this BudgetResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,categoryId,amount,period,startDate,endDate,createdAt,updatedAt);

@override
String toString() {
  return 'BudgetResponse(id: $id, userId: $userId, categoryId: $categoryId, amount: $amount, period: $period, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BudgetResponseCopyWith<$Res>  {
  factory $BudgetResponseCopyWith(BudgetResponse value, $Res Function(BudgetResponse) _then) = _$BudgetResponseCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String categoryId, num amount, String period, DateTime startDate, DateTime endDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$BudgetResponseCopyWithImpl<$Res>
    implements $BudgetResponseCopyWith<$Res> {
  _$BudgetResponseCopyWithImpl(this._self, this._then);

  final BudgetResponse _self;
  final $Res Function(BudgetResponse) _then;

/// Create a copy of BudgetResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? categoryId = null,Object? amount = null,Object? period = null,Object? startDate = null,Object? endDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetResponse].
extension BudgetResponsePatterns on BudgetResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetResponse value)  $default,){
final _that = this;
switch (_that) {
case _BudgetResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetResponse value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String categoryId,  num amount,  String period,  DateTime startDate,  DateTime endDate,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetResponse() when $default != null:
return $default(_that.id,_that.userId,_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String categoryId,  num amount,  String period,  DateTime startDate,  DateTime endDate,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _BudgetResponse():
return $default(_that.id,_that.userId,_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String categoryId,  num amount,  String period,  DateTime startDate,  DateTime endDate,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _BudgetResponse() when $default != null:
return $default(_that.id,_that.userId,_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetResponse implements BudgetResponse {
  const _BudgetResponse({required this.id, required this.userId, required this.categoryId, required this.amount, required this.period, required this.startDate, required this.endDate, required this.createdAt, required this.updatedAt});
  factory _BudgetResponse.fromJson(Map<String, dynamic> json) => _$BudgetResponseFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String categoryId;
@override final  num amount;
@override final  String period;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of BudgetResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetResponseCopyWith<_BudgetResponse> get copyWith => __$BudgetResponseCopyWithImpl<_BudgetResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,categoryId,amount,period,startDate,endDate,createdAt,updatedAt);

@override
String toString() {
  return 'BudgetResponse(id: $id, userId: $userId, categoryId: $categoryId, amount: $amount, period: $period, startDate: $startDate, endDate: $endDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BudgetResponseCopyWith<$Res> implements $BudgetResponseCopyWith<$Res> {
  factory _$BudgetResponseCopyWith(_BudgetResponse value, $Res Function(_BudgetResponse) _then) = __$BudgetResponseCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String categoryId, num amount, String period, DateTime startDate, DateTime endDate, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$BudgetResponseCopyWithImpl<$Res>
    implements _$BudgetResponseCopyWith<$Res> {
  __$BudgetResponseCopyWithImpl(this._self, this._then);

  final _BudgetResponse _self;
  final $Res Function(_BudgetResponse) _then;

/// Create a copy of BudgetResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? categoryId = null,Object? amount = null,Object? period = null,Object? startDate = null,Object? endDate = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_BudgetResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
