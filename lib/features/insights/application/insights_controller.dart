import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/riverpod/load_more_guard.dart';
import 'package:saveapenny/features/insights/data/insights_repository.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';

part 'insights_controller.freezed.dart';
part 'insights_controller.g.dart';

@freezed
abstract class InsightsState with _$InsightsState {
  const factory InsightsState({
    required List<Insight> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
    required bool unreadOnly,
    InsightType? type,
    InsightSeverity? severity,
    required bool isGenerating,
  }) = _InsightsState;
}

@Riverpod(keepAlive: true)
class InsightsController extends _$InsightsController
    with LoadMoreGuard<InsightsState> {
  static const int _pageSize = 20;

  @override
  Future<InsightsState> build() {
    return _fetchPage(page: 0, unreadOnly: false);
  }

  Future<void> refresh() async {
    final current = _readAsyncData(state);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(
        page: 0,
        unreadOnly: current?.unreadOnly ?? false,
        type: current?.type,
        severity: current?.severity,
      ),
    );
  }

  Future<void> setUnreadOnly({required bool unreadOnly}) async {
    final current = _readAsyncData(state);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(
        page: 0,
        unreadOnly: unreadOnly,
        type: current?.type,
        severity: current?.severity,
      ),
    );
  }

  Future<void> setFilters({
    required InsightType? type,
    required InsightSeverity? severity,
  }) async {
    final current = _readAsyncData(state);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(
        page: 0,
        unreadOnly: current?.unreadOnly ?? false,
        type: type,
        severity: severity,
      ),
    );
  }

  Future<void> loadMore() {
    return super.guardedLoadMore(
      hasNext: (current) => current.hasNext,
      fetchNext: (current) => _fetchPage(
        page: current.page + 1,
        unreadOnly: current.unreadOnly,
        type: current.type,
        severity: current.severity,
      ),
      merge: (current, next) => next.copyWith(
        items: <Insight>[...current.items, ...next.items],
        isGenerating: current.isGenerating,
      ),
    );
  }

  Future<void> markRead(String insightId) async {
    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final previous = current;
    state = AsyncData(_markReadLocally(current, insightId));

    try {
      await ref.read(insightsRepositoryProvider).markRead(insightId);
    } on Failure {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<void> dismiss(String insightId) async {
    final current = _readAsyncData(state);
    if (current == null) {
      return;
    }

    final previous = current;
    state = AsyncData(_dismissLocally(current, insightId));

    try {
      await ref.read(insightsRepositoryProvider).dismiss(insightId);
    } on Failure {
      state = AsyncData(previous);
      rethrow;
    }
  }

  Future<int> generate() async {
    final current = _readAsyncData(state);
    if (current == null) {
      throw const Failure.unknown();
    }

    state = AsyncData(current.copyWith(isGenerating: true));

    try {
      final generatedCount = await ref
          .read(insightsRepositoryProvider)
          .generate();
      final refreshed = await _fetchPage(
        page: 0,
        unreadOnly: current.unreadOnly,
        type: current.type,
        severity: current.severity,
        isGenerating: false,
      );
      state = AsyncData(refreshed);
      return generatedCount;
    } on Failure {
      state = AsyncData(current.copyWith(isGenerating: false));
      rethrow;
    }
  }

  Future<InsightsState> _fetchPage({
    required int page,
    required bool unreadOnly,
    InsightType? type,
    InsightSeverity? severity,
    bool isGenerating = false,
  }) async {
    final response = await ref
        .read(insightsRepositoryProvider)
        .list(
          type: type,
          severity: severity,
          page: page,
          size: _pageSize,
          isRead: unreadOnly ? false : null,
        );

    return InsightsState(
      items: response.items
          .where((item) => !item.dismissed)
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
      unreadOnly: unreadOnly,
      type: type,
      severity: severity,
      isGenerating: isGenerating,
    );
  }

  InsightsState _markReadLocally(InsightsState current, String insightId) {
    final updatedItems = current.items
        .where((item) => current.unreadOnly ? item.id != insightId : true)
        .map((item) => item.id == insightId ? item.copyWith(read: true) : item)
        .toList(growable: false);

    return current.copyWith(
      items: updatedItems,
      totalItems: current.unreadOnly
          ? (current.totalItems > 0 ? current.totalItems - 1 : 0)
          : current.totalItems,
    );
  }

  InsightsState _dismissLocally(InsightsState current, String insightId) {
    final updatedItems = current.items
        .where((item) => item.id != insightId)
        .toList(growable: false);

    return current.copyWith(
      items: updatedItems,
      totalItems: current.totalItems > 0 ? current.totalItems - 1 : 0,
    );
  }

  InsightsState? _readAsyncData(AsyncValue<InsightsState> value) {
    return value is AsyncData<InsightsState> ? value.value : null;
  }
}
