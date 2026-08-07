import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/riverpod/load_more_guard.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_repository.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';

part 'credit_cards_controller.freezed.dart';
part 'credit_cards_controller.g.dart';

@freezed
abstract class CreditCardDetailState with _$CreditCardDetailState {
  const factory CreditCardDetailState({
    required List<CreditCardStatement> statements,
    required int page,
    required bool hasNext,
  }) = _CreditCardDetailState;
}

@riverpod
class CreditCardDetailController extends _$CreditCardDetailController
    with LoadMoreGuard<CreditCardDetailState> {
  static const int _pageSize = 20;

  @override
  Future<CreditCardDetailState> build(String accountId) {
    return _fetch(accountId: accountId, page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(accountId: accountId, page: 0));
  }

  Future<void> loadMore() {
    return guardedLoadMore(
      hasNext: (current) => current.hasNext,
      fetchNext: (current) =>
          _fetch(accountId: accountId, page: current.page + 1),
      merge: (current, next) => next.copyWith(
        statements: <CreditCardStatement>[
          ...current.statements,
          ...next.statements,
        ],
      ),
    );
  }

  Future<void> updateDetails({
    required num creditLimit,
    required num apr,
    required int statementDay,
  }) async {
    await _runMutation(() {
      return ref
          .read(creditCardsRepositoryProvider)
          .updateDetails(
            accountId: accountId,
            creditLimit: creditLimit,
            apr: apr,
            statementDay: statementDay,
          );
    });
  }

  Future<void> makePayment({
    required String sourceAccountId,
    required CreditCardPaymentType paymentType,
    num? amount,
  }) async {
    await _runMutation(() {
      return ref
          .read(creditCardsRepositoryProvider)
          .makePayment(
            accountId: accountId,
            sourceAccountId: sourceAccountId,
            paymentType: paymentType,
            amount: amount,
          );
    });
  }

  Future<CreditCardDetailState> _fetch({
    required String accountId,
    required int page,
  }) async {
    final response = await ref
        .read(creditCardsRepositoryProvider)
        .listStatements(accountId: accountId, page: page, size: _pageSize);

    return CreditCardDetailState(
      statements: response.items,
      page: response.page,
      hasNext: response.hasNext,
    );
  }

  CreditCardDetailState? _readAsyncData(
    AsyncValue<CreditCardDetailState> value,
  ) {
    return value is AsyncData<CreditCardDetailState> ? value.value : null;
  }

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final current = _readAsyncData(state);

    try {
      await mutation();
      state = AsyncData(await _fetch(accountId: accountId, page: 0));
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
      // Statement state should stay successful even if the dependent account
      // refresh misses one cycle.
    }
  }
}
