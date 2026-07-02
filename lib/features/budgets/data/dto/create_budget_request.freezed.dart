// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_budget_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateBudgetRequest {

 String get categoryId; num get amount; String get period; String get startDate; String get endDate;
/// Create a copy of CreateBudgetRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateBudgetRequestCopyWith<CreateBudgetRequest> get copyWith => _$CreateBudgetRequestCopyWithImpl<CreateBudgetRequest>(this as CreateBudgetRequest, _$identity);

  /// Serializes this CreateBudgetRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateBudgetRequest&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,period,startDate,endDate);

@override
String toString() {
  return 'CreateBudgetRequest(categoryId: $categoryId, amount: $amount, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $CreateBudgetRequestCopyWith<$Res>  {
  factory $CreateBudgetRequestCopyWith(CreateBudgetRequest value, $Res Function(CreateBudgetRequest) _then) = _$CreateBudgetRequestCopyWithImpl;
@useResult
$Res call({
 String categoryId, num amount, String period, String startDate, String endDate
});




}
/// @nodoc
class _$CreateBudgetRequestCopyWithImpl<$Res>
    implements $CreateBudgetRequestCopyWith<$Res> {
  _$CreateBudgetRequestCopyWithImpl(this._self, this._then);

  final CreateBudgetRequest _self;
  final $Res Function(CreateBudgetRequest) _then;

/// Create a copy of CreateBudgetRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? amount = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateBudgetRequest].
extension CreateBudgetRequestPatterns on CreateBudgetRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateBudgetRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateBudgetRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateBudgetRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateBudgetRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateBudgetRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateBudgetRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  num amount,  String period,  String startDate,  String endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateBudgetRequest() when $default != null:
return $default(_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  num amount,  String period,  String startDate,  String endDate)  $default,) {final _that = this;
switch (_that) {
case _CreateBudgetRequest():
return $default(_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  num amount,  String period,  String startDate,  String endDate)?  $default,) {final _that = this;
switch (_that) {
case _CreateBudgetRequest() when $default != null:
return $default(_that.categoryId,_that.amount,_that.period,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateBudgetRequest implements CreateBudgetRequest {
  const _CreateBudgetRequest({required this.categoryId, required this.amount, required this.period, required this.startDate, required this.endDate});
  factory _CreateBudgetRequest.fromJson(Map<String, dynamic> json) => _$CreateBudgetRequestFromJson(json);

@override final  String categoryId;
@override final  num amount;
@override final  String period;
@override final  String startDate;
@override final  String endDate;

/// Create a copy of CreateBudgetRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateBudgetRequestCopyWith<_CreateBudgetRequest> get copyWith => __$CreateBudgetRequestCopyWithImpl<_CreateBudgetRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateBudgetRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateBudgetRequest&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.period, period) || other.period == period)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,amount,period,startDate,endDate);

@override
String toString() {
  return 'CreateBudgetRequest(categoryId: $categoryId, amount: $amount, period: $period, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$CreateBudgetRequestCopyWith<$Res> implements $CreateBudgetRequestCopyWith<$Res> {
  factory _$CreateBudgetRequestCopyWith(_CreateBudgetRequest value, $Res Function(_CreateBudgetRequest) _then) = __$CreateBudgetRequestCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, num amount, String period, String startDate, String endDate
});




}
/// @nodoc
class __$CreateBudgetRequestCopyWithImpl<$Res>
    implements _$CreateBudgetRequestCopyWith<$Res> {
  __$CreateBudgetRequestCopyWithImpl(this._self, this._then);

  final _CreateBudgetRequest _self;
  final $Res Function(_CreateBudgetRequest) _then;

/// Create a copy of CreateBudgetRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? amount = null,Object? period = null,Object? startDate = null,Object? endDate = null,}) {
  return _then(_CreateBudgetRequest(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as num,period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
