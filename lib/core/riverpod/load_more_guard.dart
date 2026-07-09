import 'dart:developer' as developer;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';

/// Shared "load next page" behavior for paginated `AsyncNotifier`s.
///
/// Centralizes the guard-against-concurrent-calls / merge-on-success /
/// revert-on-failure shape that was previously copy-pasted per feature.
mixin LoadMoreGuard<TState> {
  bool _isLoadingMore = false;

  AsyncValue<TState> get state;
  set state(AsyncValue<TState> value);

  /// Fetches the next page via [fetchNext] and folds it into the current
  /// state via [merge]. No-ops if already loading, there's no current data,
  /// or [hasNext] reports there's nothing left to load.
  Future<void> guardedLoadMore({
    required bool Function(TState current) hasNext,
    required Future<TState> Function(TState current) fetchNext,
    required TState Function(TState current, TState next) merge,
  }) async {
    final current = _readData(state);
    if (current == null || !hasNext(current) || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final next = await fetchNext(current);
      state = AsyncData<TState>(merge(current, next));
    } on Failure catch (error, stackTrace) {
      state = AsyncData<TState>(current);
      _logSwallowedLoadMoreError(error, stackTrace);
    } on Object catch (error, stackTrace) {
      state = AsyncData<TState>(current);
      _logSwallowedLoadMoreError(error, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  TState? _readData(AsyncValue<TState> value) {
    return value is AsyncData<TState> ? value.value : null;
  }

  void _logSwallowedLoadMoreError(Object error, StackTrace stackTrace) {
    // loadMore intentionally keeps the current page visible instead of
    // surfacing an error screen, so failures (including unexpected bugs,
    // not just network Failures) must still be logged instead of vanishing.
    developer.log(
      'loadMore failed and was swallowed to keep current page visible',
      name: 'LoadMoreGuard',
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
  }
}
