import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/credit_cards/application/credit_cards_controller.dart';
import 'package:saveapenny/features/credit_cards/data/credit_cards_repository.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_cards_repository.dart';

class _FakeAccountsRepository implements AccountsRepository {
  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String accountId) => throw UnimplementedError();

  @override
  Future<List<Account>> list() async => const <Account>[];

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) => throw UnimplementedError();
}

class _FakeCreditCardsRepository implements CreditCardsRepository {
  _FakeCreditCardsRepository({required this.statements, this.onMakePayment});

  final List<CreditCardStatement> statements;
  final Future<CreditCardPaymentResult> Function()? onMakePayment;

  @override
  Future<CreditCardStatementPage> listStatements({
    required String accountId,
    int page = 0,
    int size = 20,
  }) async {
    return CreditCardStatementPage(
      items: statements,
      page: page,
      hasNext: false,
    );
  }

  @override
  Future<CreditCardPaymentResult> makePayment({
    required String accountId,
    required String sourceAccountId,
    required CreditCardPaymentType paymentType,
    num? amount,
  }) {
    return onMakePayment!();
  }

  @override
  Future<CreditCardSummary> updateDetails({
    required String accountId,
    required num creditLimit,
    required num apr,
    required int statementDay,
  }) {
    throw UnimplementedError();
  }
}

CreditCardStatement _statement({required num newBalance}) {
  return CreditCardStatement(
    id: 'st-1',
    accountId: 'acc-1',
    statementDate: DateTime.parse('2026-06-01'),
    dueDate: DateTime.parse('2026-06-22'),
    previousBalance: 100,
    newBalance: newBalance,
    interestCharged: 5,
    minimumPaymentDue: 25,
    amountPaid: 0,
    status: StatementStatus.open,
  );
}

void main() {
  test('build loads the first page of statements for the account', () async {
    final container = ProviderContainer(
      overrides: [
        creditCardsRepositoryProvider.overrideWith(
          (ref) => _FakeCreditCardsRepository(
            statements: <CreditCardStatement>[_statement(newBalance: 250)],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      creditCardDetailControllerProvider('acc-1').future,
    );

    expect(state.statements, hasLength(1));
    expect(state.statements.first.newBalance, 250);
  });

  test('makePayment refreshes statements on success', () async {
    final container = ProviderContainer(
      overrides: [
        creditCardsRepositoryProvider.overrideWith(
          (ref) => _FakeCreditCardsRepository(
            statements: <CreditCardStatement>[_statement(newBalance: 100)],
            onMakePayment: () async => CreditCardPaymentResult(
              transactionId: 'txn-1',
              creditAccountId: 'acc-1',
              sourceAccountId: 'acc-2',
              amountPaid: 150,
              remainingBalance: 100,
              paidAt: DateTime.parse('2026-06-09T12:00:00Z'),
            ),
          ),
        ),
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(creditCardDetailControllerProvider('acc-1').future);
    await container
        .read(creditCardDetailControllerProvider('acc-1').notifier)
        .makePayment(
          sourceAccountId: 'acc-2',
          paymentType: CreditCardPaymentType.fullBalance,
        );

    final state = container.read(creditCardDetailControllerProvider('acc-1'));
    expect(state.hasError, isFalse);
    expect(state.value!.statements.first.newBalance, 100);
  });

  test(
    'makePayment rethrows the mapped Failure and keeps current state',
    () async {
      final container = ProviderContainer(
        overrides: [
          creditCardsRepositoryProvider.overrideWith(
            (ref) => _FakeCreditCardsRepository(
              statements: <CreditCardStatement>[_statement(newBalance: 250)],
              onMakePayment: () async {
                throw const Failure.api(
                  code: ApiErrorCode.invalidCreditCardPayment,
                  message: 'Amount exceeds the outstanding balance.',
                );
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(creditCardDetailControllerProvider('acc-1').future);

      await expectLater(
        () => container
            .read(creditCardDetailControllerProvider('acc-1').notifier)
            .makePayment(
              sourceAccountId: 'acc-2',
              paymentType: CreditCardPaymentType.custom,
              amount: 999999,
            ),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.code,
            'code',
            ApiErrorCode.invalidCreditCardPayment,
          ),
        ),
      );

      final state = container.read(creditCardDetailControllerProvider('acc-1'));
      expect(state.hasError, isFalse);
      expect(state.value!.statements.first.newBalance, 250);
    },
  );
}
