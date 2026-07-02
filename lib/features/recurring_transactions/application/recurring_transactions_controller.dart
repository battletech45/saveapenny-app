import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';

part 'recurring_transactions_controller.freezed.dart';
part 'recurring_transactions_controller.g.dart';

@freezed
abstract class RecurringTransactionsState with _$RecurringTransactionsState {
  const factory RecurringTransactionsState({
    required List<RecurringTransaction> items,
    required List<UpcomingRecurringTransaction> upcoming,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _RecurringTransactionsState;
}

@freezed
abstract class RecurringTransactionHistoryState
    with _$RecurringTransactionHistoryState {
  const factory RecurringTransactionHistoryState({
    required List<RecurringTransactionHistoryEntry> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _RecurringTransactionHistoryState;
}

@Riverpod(keepAlive: true)
class RecurringTransactionsController
    extends _$RecurringTransactionsController {
  static const int _pageSize = 20;
  static const int _upcomingLimit = 5;

  bool _isLoadingMore = false;

  @override
  Future<RecurringTransactionsState> build() {
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
          items: <RecurringTransaction>[...current.items, ...nextPage.items],
          upcoming: current.upcoming,
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
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) async {
    await _runMutation(() {
      return ref
          .read(recurringTransactionsRepositoryProvider)
          .create(
            accountId: accountId,
            categoryId: categoryId,
            type: type,
            amount: amount,
            frequency: frequency,
            nextRunDate: nextRunDate,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            classification: classification,
          );
    });
  }

  Future<void> updateRecurringTransaction({
    required String recurringTransactionId,
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    required RecurringStatus status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) async {
    await _runMutation(() {
      return ref
          .read(recurringTransactionsRepositoryProvider)
          .update(
            recurringTransactionId: recurringTransactionId,
            accountId: accountId,
            categoryId: categoryId,
            type: type,
            amount: amount,
            frequency: frequency,
            nextRunDate: nextRunDate,
            status: status,
            name: name,
            description: description,
            startDate: startDate,
            endDate: endDate,
            classification: classification,
          );
    });
  }

  Future<void> pause(String recurringTransactionId) async {
    await _runMutation(
      () => ref
          .read(recurringTransactionsRepositoryProvider)
          .pause(recurringTransactionId),
    );
  }

  Future<void> resume(String recurringTransactionId) async {
    await _runMutation(
      () => ref
          .read(recurringTransactionsRepositoryProvider)
          .resume(recurringTransactionId),
    );
  }

  Future<void> deleteRecurringTransaction(String recurringTransactionId) async {
    final current = _readAsyncData(state);

    try {
      await ref
          .read(recurringTransactionsRepositoryProvider)
          .delete(recurringTransactionId);
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

  Future<RecurringTransactionsState> _fetchPage({required int page}) async {
    final repository = ref.read(recurringTransactionsRepositoryProvider);
    final response = await repository.list(page: page, size: _pageSize);
    final upcoming = page == 0
        ? await repository.upcoming(limit: _upcomingLimit)
        : _readAsyncData(state)?.upcoming ??
              const <UpcomingRecurringTransaction>[];

    return RecurringTransactionsState(
      items: response.items,
      upcoming: upcoming,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  RecurringTransactionsState? _readAsyncData(
    AsyncValue<RecurringTransactionsState> value,
  ) {
    return value is AsyncData<RecurringTransactionsState> ? value.value : null;
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

@Riverpod(keepAlive: true)
class RecurringTransactionHistoryController
    extends _$RecurringTransactionHistoryController {
  static const int _pageSize = 20;

  bool _isLoadingMore = false;

  @override
  Future<RecurringTransactionHistoryState> build(
    String recurringTransactionId,
  ) {
    return _fetchPage(recurringTransactionId: recurringTransactionId, page: 0);
  }

  Future<void> refresh() async {
    final recurringTransactionId = this.recurringTransactionId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchPage(recurringTransactionId: recurringTransactionId, page: 0),
    );
  }

  Future<void> loadMore() async {
    final current = _readHistoryAsyncData(state);
    if (current == null || !current.hasNext || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = await _fetchPage(
        recurringTransactionId: recurringTransactionId,
        page: current.page + 1,
      );
      state = AsyncData(
        nextPage.copyWith(
          items: <RecurringTransactionHistoryEntry>[
            ...current.items,
            ...nextPage.items,
          ],
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

  Future<RecurringTransactionHistoryState> _fetchPage({
    required String recurringTransactionId,
    required int page,
  }) async {
    final response = await ref
        .read(recurringTransactionsRepositoryProvider)
        .history(recurringTransactionId, page: page, size: _pageSize);

    return RecurringTransactionHistoryState(
      items: response.items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  RecurringTransactionHistoryState? _readHistoryAsyncData(
    AsyncValue<RecurringTransactionHistoryState> value,
  ) {
    return value is AsyncData<RecurringTransactionHistoryState>
        ? value.value
        : null;
  }
}
