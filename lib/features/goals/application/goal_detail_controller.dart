import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/goals/application/goals_controller.dart';
import 'package:saveapenny/features/goals/data/goals_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';
import 'package:saveapenny/features/goals/domain/goal_detail.dart';
import 'package:saveapenny/features/goals/domain/goal_run.dart';

part 'goal_detail_controller.freezed.dart';
part 'goal_detail_controller.g.dart';

@freezed
abstract class GoalDetailState with _$GoalDetailState {
  const factory GoalDetailState({
    required GoalDetail goal,
    required List<GoalRun> runs,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _GoalDetailState;
}

@Riverpod(keepAlive: true)
class GoalDetailController extends _$GoalDetailController {
  static const int _pageSize = 20;

  bool _isLoadingMore = false;

  @override
  Future<GoalDetailState> build(String goalId) {
    return _fetch(goalId: goalId, page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(goalId: goalId, page: 0));
  }

  Future<void> loadMoreRuns() async {
    final current = _readAsyncData(state);
    if (current == null || !current.hasNext || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = await _fetch(goalId: goalId, page: current.page + 1);
      state = AsyncData(
        nextPage.copyWith(runs: <GoalRun>[...current.runs, ...nextPage.runs]),
      );
    } on Failure {
      state = AsyncData(current);
    } on Object {
      state = AsyncData(current);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> updateGoal({
    String? title,
    num? targetAmount,
    String? currency,
    DateTime? targetDate,
    String? linkedAccountId,
    Map<String, dynamic>? inputs,
  }) async {
    final current = _readAsyncData(state);

    try {
      await ref
          .read(goalsRepositoryProvider)
          .update(
            goalId: goalId,
            title: title,
            targetAmount: targetAmount,
            currency: currency,
            targetDate: targetDate,
            linkedAccountId: linkedAccountId,
            inputs: inputs,
          );
      state = AsyncData(await _fetch(goalId: goalId, page: 0));
      unawaited(ref.read(goalsControllerProvider.notifier).refresh());
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

  Future<void> updateStatus(GoalStatus status) async {
    final current = _readAsyncData(state);

    try {
      await ref
          .read(goalsRepositoryProvider)
          .updateStatus(goalId: goalId, status: status);
      state = AsyncData(await _fetch(goalId: goalId, page: 0));
      unawaited(ref.read(goalsControllerProvider.notifier).refresh());
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

  Future<void> createScenario({
    required String name,
    required Map<String, dynamic> inputs,
    bool? isBaseline,
  }) async {
    final current = _readAsyncData(state);

    try {
      await ref
          .read(goalsRepositoryProvider)
          .createScenario(
            goalId: goalId,
            name: name,
            inputs: inputs,
            isBaseline: isBaseline,
          );
      state = AsyncData(await _fetch(goalId: goalId, page: 0));
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

  Future<GoalDetailState> _fetch({
    required String goalId,
    required int page,
  }) async {
    final repository = ref.read(goalsRepositoryProvider);
    final detailFuture = repository.getById(goalId);
    final runsFuture = repository.listRuns(goalId, page: page, size: _pageSize);

    final detail = await detailFuture;
    final runs = await runsFuture;

    return GoalDetailState(
      goal: detail,
      runs: runs.items,
      page: runs.page,
      size: runs.size,
      totalItems: runs.totalItems,
      totalPages: runs.totalPages,
      hasNext: runs.hasNext,
      hasPrevious: runs.hasPrevious,
    );
  }

  GoalDetailState? _readAsyncData(AsyncValue<GoalDetailState> value) {
    return value is AsyncData<GoalDetailState> ? value.value : null;
  }
}
