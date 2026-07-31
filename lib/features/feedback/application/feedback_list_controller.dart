import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/riverpod/load_more_guard.dart';
import 'package:saveapenny/features/feedback/data/feedback_repository.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';

part 'feedback_list_controller.freezed.dart';
part 'feedback_list_controller.g.dart';

@freezed
abstract class FeedbackListState with _$FeedbackListState {
  const factory FeedbackListState({
    required List<Feedback> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    FeedbackType? typeFilter,
  }) = _FeedbackListState;
}

@Riverpod(keepAlive: true)
class FeedbackListController extends _$FeedbackListController
    with LoadMoreGuard<FeedbackListState> {
  static const int _pageSize = 20;

  @override
  Future<FeedbackListState> build() {
    return _fetchPage(page: 0, typeFilter: null);
  }

  Future<void> refresh() async {
    final current = _readAsyncData(state);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      return _fetchPage(page: 0, typeFilter: current?.typeFilter);
    });
  }

  Future<void> setTypeFilter(FeedbackType? typeFilter) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(page: 0, typeFilter: typeFilter),
    );
  }

  Future<void> loadMore() {
    return guardedLoadMore(
      hasNext: (current) => current.hasNext,
      fetchNext: (current) =>
          _fetchPage(page: current.page + 1, typeFilter: current.typeFilter),
      merge: (current, next) =>
          next.copyWith(items: <Feedback>[...current.items, ...next.items]),
    );
  }

  Future<void> deleteFeedback(String feedbackId) async {
    final current = _readAsyncData(state);

    try {
      await ref.read(feedbackRepositoryProvider).delete(feedbackId);
      state = AsyncData(
        await _fetchPage(page: 0, typeFilter: current?.typeFilter),
      );
    } on Failure catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } on Object catch (error, stackTrace) {
      final failure = Failure.unknown(message: error.toString());
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(failure, stackTrace);
      }
      Error.throwWithStackTrace(failure, stackTrace);
    }
  }

  Future<FeedbackListState> _fetchPage({
    required int page,
    required FeedbackType? typeFilter,
  }) async {
    final response = await ref
        .read(feedbackRepositoryProvider)
        .list(page: page, size: _pageSize, type: typeFilter);

    return FeedbackListState(
      items: response.items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
      typeFilter: typeFilter,
    );
  }

  FeedbackListState? _readAsyncData(AsyncValue<FeedbackListState> value) {
    return value is AsyncData<FeedbackListState> ? value.value : null;
  }
}
