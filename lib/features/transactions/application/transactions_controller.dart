import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/riverpod/load_more_guard.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/transactions/data/transactions_repository.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';

part 'transactions_controller.freezed.dart';
part 'transactions_controller.g.dart';

@freezed
abstract class TransactionsState with _$TransactionsState {
  const factory TransactionsState({
    required List<Transaction> items,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _TransactionsState;
}

@Riverpod(keepAlive: true)
class TransactionsController extends _$TransactionsController
    with LoadMoreGuard<TransactionsState> {
  static const int _pageSize = 20;

  @override
  Future<TransactionsState> build() {
    return _fetchPage(page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(page: 0));
  }

  Future<void> loadMore() {
    return super.guardedLoadMore(
      hasNext: (current) => current.hasNext,
      fetchNext: (current) => _fetchPage(page: current.page + 1),
      merge: (current, next) =>
          next.copyWith(items: <Transaction>[...current.items, ...next.items]),
    );
  }

  Future<void> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _runMutation(() {
      return ref
          .read(transactionsRepositoryProvider)
          .create(
            accountId: accountId,
            categoryId: categoryId,
            type: type,
            amount: amount,
            currency: currency,
            description: description,
            transactionDate: transactionDate,
          );
    });
  }

  Future<void> updateTransaction({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _runMutation(() {
      return ref
          .read(transactionsRepositoryProvider)
          .update(
            transactionId: transactionId,
            accountId: accountId,
            categoryId: categoryId,
            type: type,
            amount: amount,
            currency: currency,
            description: description,
            transactionDate: transactionDate,
          );
    });
  }

  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) async {
    await _runMutation(() {
      return ref
          .read(transactionsRepositoryProvider)
          .createTransfer(
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            categoryId: categoryId,
            amount: amount,
            currency: currency,
            description: description,
            transactionDate: transactionDate,
          );
    });
  }

  Future<void> deleteTransaction(String transactionId) async {
    final current = _readAsyncData(state);

    try {
      await ref.read(transactionsRepositoryProvider).delete(transactionId);
      state = AsyncData(await _fetchPage(page: 0));
      await _syncAccounts();
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

  Future<TransactionsState> _fetchPage({required int page}) async {
    final response = await ref
        .read(transactionsRepositoryProvider)
        .list(page: page, size: _pageSize);

    return TransactionsState(
      items: response.items,
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  TransactionsState? _readAsyncData(AsyncValue<TransactionsState> value) {
    return value is AsyncData<TransactionsState> ? value.value : null;
  }

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final current = _readAsyncData(state);

    try {
      await mutation();
      state = AsyncData(await _fetchPage(page: 0));
      await _syncAccounts();
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

  Future<void> _syncAccounts() async {
    try {
      await ref.read(accountsControllerProvider.notifier).sync();
    } on Object {
      // Transaction state should stay successful even if the dependent account
      // refresh misses one cycle.
    }
  }
}
