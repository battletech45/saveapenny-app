import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';

part 'budgets_controller.freezed.dart';
part 'budgets_controller.g.dart';

@freezed
abstract class BudgetListItem with _$BudgetListItem {
  const factory BudgetListItem({
    required Budget budget,
    required BudgetStatus status,
  }) = _BudgetListItem;
}

@freezed
abstract class BudgetsState with _$BudgetsState {
  const factory BudgetsState({
    required List<BudgetListItem> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _BudgetsState;
}

@Riverpod(keepAlive: true)
class BudgetsController extends _$BudgetsController {
  static const int _pageSize = 20;

  bool _isLoadingMore = false;

  @override
  Future<BudgetsState> build() {
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
        nextPage.copyWith(
          items: <BudgetListItem>[...current.items, ...nextPage.items],
        ),
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
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _runMutation(() {
      return ref
          .read(budgetsRepositoryProvider)
          .create(
            categoryId: categoryId,
            amount: amount,
            period: period,
            startDate: startDate,
            endDate: endDate,
          );
    });
  }

  Future<void> updateBudget({
    required String budgetId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _runMutation(() {
      return ref
          .read(budgetsRepositoryProvider)
          .update(
            budgetId: budgetId,
            categoryId: categoryId,
            amount: amount,
            period: period,
            startDate: startDate,
            endDate: endDate,
          );
    });
  }

  Future<void> deleteBudget(String budgetId) async {
    final current = _readAsyncData(state);

    try {
      await ref.read(budgetsRepositoryProvider).delete(budgetId);
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

  Future<BudgetsState> _fetchPage({required int page}) async {
    final response = await ref
        .read(budgetsRepositoryProvider)
        .list(page: page, size: _pageSize);
    final items = await Future.wait(
      response.items.map((budget) async {
        final status = await ref
            .read(budgetsRepositoryProvider)
            .status(budget.id);
        return BudgetListItem(budget: budget, status: status);
      }),
    );

    return BudgetsState(
      items: items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  BudgetsState? _readAsyncData(AsyncValue<BudgetsState> value) {
    return value is AsyncData<BudgetsState> ? value.value : null;
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
