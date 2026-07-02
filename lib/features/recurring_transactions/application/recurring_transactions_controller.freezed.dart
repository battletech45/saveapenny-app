// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_transactions_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecurringTransactionsState {

 List<RecurringTransaction> get items; List<UpcomingRecurringTransaction> get upcoming; int get page; int get size; int get totalItems; int get totalPages; bool get hasNext; bool get hasPrevious;
/// Create a copy of RecurringTransactionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTransactionsStateCopyWith<RecurringTransactionsState> get copyWith => _$RecurringTransactionsStateCopyWithImpl<RecurringTransactionsState>(this as RecurringTransactionsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTransactionsState&&const DeepCollectionEquality().equals(other.items, items)&&const DeepCollectionEquality().equals(other.upcoming, upcoming)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),const DeepCollectionEquality().hash(upcoming),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'RecurringTransactionsState(items: $items, upcoming: $upcoming, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class $RecurringTransactionsStateCopyWith<$Res>  {
  factory $RecurringTransactionsStateCopyWith(RecurringTransactionsState value, $Res Function(RecurringTransactionsState) _then) = _$RecurringTransactionsStateCopyWithImpl;
@useResult
$Res call({
 List<RecurringTransaction> items, List<UpcomingRecurringTransaction> upcoming, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class _$RecurringTransactionsStateCopyWithImpl<$Res>
    implements $RecurringTransactionsStateCopyWith<$Res> {
  _$RecurringTransactionsStateCopyWithImpl(this._self, this._then);

  final RecurringTransactionsState _self;
  final $Res Function(RecurringTransactionsState) _then;

/// Create a copy of RecurringTransactionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? upcoming = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringTransaction>,upcoming: null == upcoming ? _self.upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as List<UpcomingRecurringTransaction>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrevious: null == hasPrevious ? _self.hasPrevious : hasPrevious // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTransactionsState].
extension RecurringTransactionsStatePatterns on RecurringTransactionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTransactionsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTransactionsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTransactionsState value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTransactionsState value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecurringTransaction> items,  List<UpcomingRecurringTransaction> upcoming,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTransactionsState() when $default != null:
return $default(_that.items,_that.upcoming,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecurringTransaction> items,  List<UpcomingRecurringTransaction> upcoming,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionsState():
return $default(_that.items,_that.upcoming,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecurringTransaction> items,  List<UpcomingRecurringTransaction> upcoming,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionsState() when $default != null:
return $default(_that.items,_that.upcoming,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringTransactionsState implements RecurringTransactionsState {
  const _RecurringTransactionsState({required final  List<RecurringTransaction> items, required final  List<UpcomingRecurringTransaction> upcoming, required this.page, required this.size, required this.totalItems, required this.totalPages, required this.hasNext, required this.hasPrevious}): _items = items,_upcoming = upcoming;
  

 final  List<RecurringTransaction> _items;
@override List<RecurringTransaction> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<UpcomingRecurringTransaction> _upcoming;
@override List<UpcomingRecurringTransaction> get upcoming {
  if (_upcoming is EqualUnmodifiableListView) return _upcoming;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcoming);
}

@override final  int page;
@override final  int size;
@override final  int totalItems;
@override final  int totalPages;
@override final  bool hasNext;
@override final  bool hasPrevious;

/// Create a copy of RecurringTransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTransactionsStateCopyWith<_RecurringTransactionsState> get copyWith => __$RecurringTransactionsStateCopyWithImpl<_RecurringTransactionsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTransactionsState&&const DeepCollectionEquality().equals(other._items, _items)&&const DeepCollectionEquality().equals(other._upcoming, _upcoming)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_upcoming),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'RecurringTransactionsState(items: $items, upcoming: $upcoming, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class _$RecurringTransactionsStateCopyWith<$Res> implements $RecurringTransactionsStateCopyWith<$Res> {
  factory _$RecurringTransactionsStateCopyWith(_RecurringTransactionsState value, $Res Function(_RecurringTransactionsState) _then) = __$RecurringTransactionsStateCopyWithImpl;
@override @useResult
$Res call({
 List<RecurringTransaction> items, List<UpcomingRecurringTransaction> upcoming, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class __$RecurringTransactionsStateCopyWithImpl<$Res>
    implements _$RecurringTransactionsStateCopyWith<$Res> {
  __$RecurringTransactionsStateCopyWithImpl(this._self, this._then);

  final _RecurringTransactionsState _self;
  final $Res Function(_RecurringTransactionsState) _then;

/// Create a copy of RecurringTransactionsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? upcoming = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_RecurringTransactionsState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringTransaction>,upcoming: null == upcoming ? _self._upcoming : upcoming // ignore: cast_nullable_to_non_nullable
as List<UpcomingRecurringTransaction>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrevious: null == hasPrevious ? _self.hasPrevious : hasPrevious // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecurringTransactionHistoryState {

 List<RecurringTransactionHistoryEntry> get items; int get page; int get size; int get totalItems; int get totalPages; bool get hasNext; bool get hasPrevious;
/// Create a copy of RecurringTransactionHistoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecurringTransactionHistoryStateCopyWith<RecurringTransactionHistoryState> get copyWith => _$RecurringTransactionHistoryStateCopyWithImpl<RecurringTransactionHistoryState>(this as RecurringTransactionHistoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecurringTransactionHistoryState&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'RecurringTransactionHistoryState(items: $items, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class $RecurringTransactionHistoryStateCopyWith<$Res>  {
  factory $RecurringTransactionHistoryStateCopyWith(RecurringTransactionHistoryState value, $Res Function(RecurringTransactionHistoryState) _then) = _$RecurringTransactionHistoryStateCopyWithImpl;
@useResult
$Res call({
 List<RecurringTransactionHistoryEntry> items, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class _$RecurringTransactionHistoryStateCopyWithImpl<$Res>
    implements $RecurringTransactionHistoryStateCopyWith<$Res> {
  _$RecurringTransactionHistoryStateCopyWithImpl(this._self, this._then);

  final RecurringTransactionHistoryState _self;
  final $Res Function(RecurringTransactionHistoryState) _then;

/// Create a copy of RecurringTransactionHistoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringTransactionHistoryEntry>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,totalItems: null == totalItems ? _self.totalItems : totalItems // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,hasNext: null == hasNext ? _self.hasNext : hasNext // ignore: cast_nullable_to_non_nullable
as bool,hasPrevious: null == hasPrevious ? _self.hasPrevious : hasPrevious // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RecurringTransactionHistoryState].
extension RecurringTransactionHistoryStatePatterns on RecurringTransactionHistoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecurringTransactionHistoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecurringTransactionHistoryState value)  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecurringTransactionHistoryState value)?  $default,){
final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RecurringTransactionHistoryEntry> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RecurringTransactionHistoryEntry> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RecurringTransactionHistoryEntry> items,  int page,  int size,  int totalItems,  int totalPages,  bool hasNext,  bool hasPrevious)?  $default,) {final _that = this;
switch (_that) {
case _RecurringTransactionHistoryState() when $default != null:
return $default(_that.items,_that.page,_that.size,_that.totalItems,_that.totalPages,_that.hasNext,_that.hasPrevious);case _:
  return null;

}
}

}

/// @nodoc


class _RecurringTransactionHistoryState implements RecurringTransactionHistoryState {
  const _RecurringTransactionHistoryState({required final  List<RecurringTransactionHistoryEntry> items, required this.page, required this.size, required this.totalItems, required this.totalPages, required this.hasNext, required this.hasPrevious}): _items = items;
  

 final  List<RecurringTransactionHistoryEntry> _items;
@override List<RecurringTransactionHistoryEntry> get items {
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

/// Create a copy of RecurringTransactionHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecurringTransactionHistoryStateCopyWith<_RecurringTransactionHistoryState> get copyWith => __$RecurringTransactionHistoryStateCopyWithImpl<_RecurringTransactionHistoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecurringTransactionHistoryState&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size)&&(identical(other.totalItems, totalItems) || other.totalItems == totalItems)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages)&&(identical(other.hasNext, hasNext) || other.hasNext == hasNext)&&(identical(other.hasPrevious, hasPrevious) || other.hasPrevious == hasPrevious));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items),page,size,totalItems,totalPages,hasNext,hasPrevious);

@override
String toString() {
  return 'RecurringTransactionHistoryState(items: $items, page: $page, size: $size, totalItems: $totalItems, totalPages: $totalPages, hasNext: $hasNext, hasPrevious: $hasPrevious)';
}


}

/// @nodoc
abstract mixin class _$RecurringTransactionHistoryStateCopyWith<$Res> implements $RecurringTransactionHistoryStateCopyWith<$Res> {
  factory _$RecurringTransactionHistoryStateCopyWith(_RecurringTransactionHistoryState value, $Res Function(_RecurringTransactionHistoryState) _then) = __$RecurringTransactionHistoryStateCopyWithImpl;
@override @useResult
$Res call({
 List<RecurringTransactionHistoryEntry> items, int page, int size, int totalItems, int totalPages, bool hasNext, bool hasPrevious
});




}
/// @nodoc
class __$RecurringTransactionHistoryStateCopyWithImpl<$Res>
    implements _$RecurringTransactionHistoryStateCopyWith<$Res> {
  __$RecurringTransactionHistoryStateCopyWithImpl(this._self, this._then);

  final _RecurringTransactionHistoryState _self;
  final $Res Function(_RecurringTransactionHistoryState) _then;

/// Create a copy of RecurringTransactionHistoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? page = null,Object? size = null,Object? totalItems = null,Object? totalPages = null,Object? hasNext = null,Object? hasPrevious = null,}) {
  return _then(_RecurringTransactionHistoryState(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<RecurringTransactionHistoryEntry>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
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
