// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budgets_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BudgetListItem {

 Budget get budget; BudgetStatus get status;
/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetListItemCopyWith<BudgetListItem> get copyWith => _$BudgetListItemCopyWithImpl<BudgetListItem>(this as BudgetListItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetListItem&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,budget,status);

@override
String toString() {
  return 'BudgetListItem(budget: $budget, status: $status)';
}


}

/// @nodoc
abstract mixin class $BudgetListItemCopyWith<$Res>  {
  factory $BudgetListItemCopyWith(BudgetListItem value, $Res Function(BudgetListItem) _then) = _$BudgetListItemCopyWithImpl;
@useResult
$Res call({
 Budget budget, BudgetStatus status
});


$BudgetCopyWith<$Res> get budget;$BudgetStatusCopyWith<$Res> get status;

}
/// @nodoc
class _$BudgetListItemCopyWithImpl<$Res>
    implements $BudgetListItemCopyWith<$Res> {
  _$BudgetListItemCopyWithImpl(this._self, this._then);

  final BudgetListItem _self;
  final $Res Function(BudgetListItem) _then;

/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? budget = null,Object? status = null,}) {
  return _then(_self.copyWith(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetStatus,
  ));
}
/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res> get budget {
  
  return $BudgetCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res> get status {
  
  return $BudgetStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}


/// Adds pattern-matching-related methods to [BudgetListItem].
extension BudgetListItemPatterns on BudgetListItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetListItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetListItem value)  $default,){
final _that = this;
switch (_that) {
case _BudgetListItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetListItem value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetListItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Budget budget,  BudgetStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetListItem() when $default != null:
return $default(_that.budget,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Budget budget,  BudgetStatus status)  $default,) {final _that = this;
switch (_that) {
case _BudgetListItem():
return $default(_that.budget,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Budget budget,  BudgetStatus status)?  $default,) {final _that = this;
switch (_that) {
case _BudgetListItem() when $default != null:
return $default(_that.budget,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetListItem implements BudgetListItem {
  const _BudgetListItem({required this.budget, required this.status});
  

@override final  Budget budget;
@override final  BudgetStatus status;

/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetListItemCopyWith<_BudgetListItem> get copyWith => __$BudgetListItemCopyWithImpl<_BudgetListItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetListItem&&(identical(other.budget, budget) || other.budget == budget)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,budget,status);

@override
String toString() {
  return 'BudgetListItem(budget: $budget, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BudgetListItemCopyWith<$Res> implements $BudgetListItemCopyWith<$Res> {
  factory _$BudgetListItemCopyWith(_BudgetListItem value, $Res Function(_BudgetListItem) _then) = __$BudgetListItemCopyWithImpl;
@override @useResult
$Res call({
 Budget budget, BudgetStatus status
});


@override $BudgetCopyWith<$Res> get budget;@override $BudgetStatusCopyWith<$Res> get status;

}
/// @nodoc
class __$BudgetListItemCopyWithImpl<$Res>
    implements _$BudgetListItemCopyWith<$Res> {
  __$BudgetListItemCopyWithImpl(this._self, this._then);

  final _BudgetListItem _self;
  final $Res Function(_BudgetListItem) _then;

/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? budget = null,Object? status = null,}) {
  return _then(_BudgetListItem(
budget: null == budget ? _self.budget : budget // ignore: cast_nullable_to_non_nullable
as Budget,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BudgetStatus,
  ));
}

/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetCopyWith<$Res> get budget {
  
  return $BudgetCopyWith<$Res>(_self.budget, (value) {
    return _then(_self.copyWith(budget: value));
  });
}/// Create a copy of BudgetListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BudgetStatusCopyWith<$Res> get status {
  
  return $BudgetStatusCopyWith<$Res>(_self.status, (value) {
    return _then(_self.copyWith(status: value));
  });
}
}

/// @nodoc
mixin _$BudgetsState {

 List<BudgetListItem> get items; int get page; int get size; int get totalItems; int get totalPages; bool get hasNext; bool get hasPrevious;
/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetsStateCopyWith<BudgetsState> get copyWith => _$BudgetsStateCopyWithImpl<BudgetsState>(this as BudgetsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetsState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'BudgetsState(items: $items, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class $BudgetsStateCopyWith<$Res>  {
  factory $BudgetsStateCopyWith(BudgetsState value, $Res Function(BudgetsState) _then) = _$BudgetsStateCopyWithImpl;
@useResult
$Res call({
 List<BudgetListItem> items, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class _$BudgetsStateCopyWithImpl<$Res>
    implements $BudgetsStateCopyWith<$Res> {
  _$BudgetsStateCopyWithImpl(this._self, this._then);

  final BudgetsState _self;
  final $Res Function(BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetListItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrevious: null == hasPrevious ? _self.hasPrevious : hasPrevious // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetsState].
extension BudgetsStatePatterns on BudgetsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetsState value)  $default,){
final _that = this;
switch (_that) {
case _BudgetsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetsState value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BudgetListItem> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BudgetListItem> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)  $default,) {final _that = this;
switch (_that) {
case _BudgetsState():
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BudgetListItem> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,) {final _that = this;
switch (_that) {
case _BudgetsState() when $default != null:
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
  return null;

}
}

}

/// @nodoc


class _BudgetsState implements BudgetsState {
  const _BudgetsState({required final  List<BudgetListItem> items, required this.page, required this.size, required this.totalItems, required this.totalPages, required this.hasNext, required this.hasPrevious}): _items = items;
  

 final  List<BudgetListItem> _items;
@override List<BudgetListItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int page;
@override final  int size;
@override final  int totalItems;
@override final  int totalPages;
@override final  bool hasNext;
@override final  bool hasPrevious;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetsStateCopyWith<_BudgetsState> get copyWith => __$BudgetsStateCopyWithImpl<_BudgetsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetsState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'BudgetsState(items: $items, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class _$BudgetsStateCopyWith<$Res> implements $BudgetsStateCopyWith<$Res> {
  factory _$BudgetsStateCopyWith(_BudgetsState value, $Res Function(_BudgetsState) _then) = __$BudgetsStateCopyWithImpl;
@override @useResult
$Res call({
 List<BudgetListItem> items, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class __$BudgetsStateCopyWithImpl<$Res>
    implements _$BudgetsStateCopyWith<$Res> {
  __$BudgetsStateCopyWithImpl(this._self, this._then);

  final _BudgetsState _self;
  final $Res Function(_BudgetsState) _then;

/// Create a copy of BudgetsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_BudgetsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<BudgetListItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrevious: null == hasPrevious ? _self.hasPrevious : hasPrevious // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
