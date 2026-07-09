import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/goals/data/goals_repository.dart';
import 'package:saveapenny/features/goals/domain/goal.dart';

part 'goals_controller.freezed.dart';
part 'goals_controller.g.dart';

@freezed
abstract class GoalsState with _$GoalsState {
  const factory GoalsState({
    required List<Goal> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _GoalsState;
}

@Riverpod(keepAlive: true)
class GoalsController extends _$GoalsController {
  static const int _pageSize = 20;

  bool _isLoadingMore = false;

  @override
  Future<GoalsState> build() {
    return _fetchPage(page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(page: 0));
  }

  Future<void> loadMore() async {
    final current = _readAsyncData(state);
    if (current == null || !current.hasNext || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = await _fetchPage(page: current.page + 1);
      state = AsyncData(
        nextPage.copyWith(items: <Goal>[...current.items, ...nextPage.items]),
      );
    } on Failure {
      state = AsyncData(current);
    } on Object {
      state = AsyncData(current);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> create({
    required GoalType type,
    required String title,
    required num targetAmount,
    required String currency,
    required DateTime targetDate,
    String? linkedAccountId,
    required Map<String, dynamic> inputs,
  }) async {
    await _runMutation(() {
      return ref
          .read(goalsRepositoryProvider)
          .create(
            type: type,
            title: title,
            targetAmount: targetAmount,
            currency: currency,
            targetDate: targetDate,
            linkedAccountId: linkedAccountId,
            inputs: inputs,
          );
    });
  }

  Future<void> deleteGoal(String goalId) async {
    final current = _readAsyncData(state);

    try {
      await ref.read(goalsRepositoryProvider).delete(goalId);
      state = AsyncData(await _fetchPage(page: 0));
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

  Future<GoalsState> _fetchPage({required int page}) async {
    final response = await ref
        .read(goalsRepositoryProvider)
        .list(page: page, size: _pageSize);

    return GoalsState(
      items: response.items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  GoalsState? _readAsyncData(AsyncValue<GoalsState> value) {
    return value is AsyncData<GoalsState> ? value.value : null;
  }

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final current = _readAsyncData(state);

    try {
      await mutation();
      state = AsyncData(await _fetchPage(page: 0));
    } on Failure {
      if (current != null) {
        state = AsyncData(current);
      }
      rethrow;
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
}
