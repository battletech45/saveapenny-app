import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/transactions/application/transactions_controller.dart';
import 'package:saveapenny/features/transactions/data/transactions_repository.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/domain/transactions_repository.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.onList});

  final Future<List<Account>> Function()? onList;

  @override
  Future<DateTime?> lastSyncedAt() async => null;

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> list() {
    return onList!();
  }

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) {
    throw UnimplementedError();
  }
}

class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository({
    this.onList,
    this.onCreate,
    this.onUpdate,
    this.onCreateTransfer,
    this.onDelete,
  });

  final Future<PaginatedData<Transaction>> Function()? onList;
  final Future<Transaction> Function({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  })?
  onCreate;
  final Future<Transaction> Function({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  })?
  onUpdate;
  final Future<void> Function({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  })?
  onCreateTransfer;
  final Future<void> Function(String transactionId)? onDelete;

  @override
  Future<Transaction> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    return onCreate!(
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
    );
  }

  @override
  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    return onCreateTransfer!(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
    );
  }

  @override
  Future<void> delete(String transactionId) {
    return onDelete!(transactionId);
  }

  @override
  Future<PaginatedData<Transaction>> list({
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    num? minAmount,
    num? maxAmount,
    String? keyword,
    int page = 0,
    int size = 20,
    String sort = 'transactionDate,desc',
  }) {
    return onList!();
  }

  @override
  Future<Transaction> update({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    return onUpdate!(
      transactionId: transactionId,
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
    );
  }
}

Transaction _transaction({
  required String id,
  required TransactionType type,
  required num amount,
  String? description,
}) {
  return Transaction(
    id: id,
    userId: 'u-1',
    accountId: 'a-1',
    categoryId: 'c-1',
    type: type,
    amount: amount,
    currency: 'TRY',
    description: description,
    transactionDate: DateTime.parse('2026-06-09T00:00:00Z'),
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

PaginatedData<Transaction> _page(
  List<Transaction> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<Transaction>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

Account _account({required String id, required num balance}) {
  return Account(
    id: id,
    name: 'Main bank',
    type: AccountType.bank,
    currency: 'TRY',
    balance: balance,
    initialBalance: 100,
    active: true,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

void main() {
  test('build loads the first page into state', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
      description: 'Lunch',
    );

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async => _page(<Transaction>[existing]),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(transactionsControllerProvider.future);

    expect(state.items, <Transaction>[existing]);
    expect(state.page, 0);
    expect(state.hasNext, isFalse);
  });

  test('loadMore appends the next page', () async {
    final first = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );
    final second = _transaction(
      id: 't-2',
      type: TransactionType.income,
      amount: 100,
    );
    var listCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async {
              listCallCount += 1;
              return switch (listCallCount) {
                1 => _page(<Transaction>[first], hasNext: true),
                2 => _page(<Transaction>[second], page: 1, hasPrevious: true),
                _ => throw StateError('Unexpected list call'),
              };
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(transactionsControllerProvider.future);
    await container.read(transactionsControllerProvider.notifier).loadMore();

    expect(
      container.read(transactionsControllerProvider).value?.items,
      <Transaction>[first, second],
    );
  });

  test('loadMore preserves current list when the next page fails', () async {
    final first = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );
    var listCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async {
              listCallCount += 1;
              if (listCallCount == 1) {
                return _page(<Transaction>[first], hasNext: true);
              }

              throw const Failure.api(
                code: ApiErrorCode.validationFailed,
                message: 'Page fetch failed.',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(transactionsControllerProvider.future);
    await container.read(transactionsControllerProvider.notifier).loadMore();

    final state = container.read(transactionsControllerProvider).value;
    expect(state?.items, <Transaction>[first]);
    expect(container.read(transactionsControllerProvider).hasError, isFalse);
  });

  test('create refreshes the first page after a successful mutation', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );
    final created = _transaction(
      id: 't-2',
      type: TransactionType.income,
      amount: 500,
      description: 'Salary',
    );
    var listCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async {
              listCallCount += 1;
              return listCallCount == 1
                  ? _page(<Transaction>[existing])
                  : _page(<Transaction>[created, existing]);
            },
            onCreate:
                ({
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required currency,
                  description,
                  required transactionDate,
                }) async => created,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(transactionsControllerProvider.future);
    await container
        .read(transactionsControllerProvider.notifier)
        .create(
          accountId: 'a-1',
          categoryId: 'c-1',
          type: TransactionType.income,
          amount: 500,
          currency: 'TRY',
          description: 'Salary',
          transactionDate: DateTime.parse('2026-06-10T00:00:00Z'),
        );

    expect(
      container.read(transactionsControllerProvider).value?.items,
      <Transaction>[created, existing],
    );
  });

  test('create syncs accounts after a successful mutation', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );
    final updatedAccount = _account(id: 'a-1', balance: 600);
    var accountListCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async => _page(<Transaction>[existing]),
            onCreate:
                ({
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required currency,
                  description,
                  required transactionDate,
                }) async => existing,
          ),
        ),
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            onList: () async {
              accountListCallCount += 1;
              return accountListCallCount == 1
                  ? <Account>[_account(id: 'a-1', balance: 100)]
                  : <Account>[updatedAccount];
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(accountsControllerProvider.future);
    await container.read(transactionsControllerProvider.future);

    await container
        .read(transactionsControllerProvider.notifier)
        .create(
          accountId: 'a-1',
          categoryId: 'c-1',
          type: TransactionType.income,
          amount: 500,
          currency: 'TRY',
          description: 'Salary',
          transactionDate: DateTime.parse('2026-06-10T00:00:00Z'),
        );

    expect(container.read(accountsControllerProvider).value, <Account>[
      updatedAccount,
    ]);
  });

  test('create preserves current list when the mutation fails', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
      description: 'Lunch',
    );

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async => _page(<Transaction>[existing]),
            onCreate:
                ({
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required currency,
                  description,
                  required transactionDate,
                }) async {
                  throw const Failure.api(
                    code: ApiErrorCode.validationFailed,
                    message: 'Invalid transaction.',
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(transactionsControllerProvider.future);

    await expectLater(
      container
          .read(transactionsControllerProvider.notifier)
          .create(
            accountId: 'a-1',
            categoryId: 'c-1',
            type: TransactionType.expense,
            amount: 25,
            currency: 'TRY',
            description: 'Lunch',
            transactionDate: DateTime.parse('2026-06-10T00:00:00Z'),
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(transactionsControllerProvider).value?.items,
      <Transaction>[existing],
    );
  });

  test('update preserves current list when the mutation fails', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async => _page(<Transaction>[existing]),
            onUpdate:
                ({
                  required transactionId,
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required currency,
                  description,
                  required transactionDate,
                }) async {
                  throw const Failure.api(
                    code: ApiErrorCode.validationFailed,
                    message: 'Update failed.',
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(transactionsControllerProvider.future);

    await expectLater(
      container
          .read(transactionsControllerProvider.notifier)
          .updateTransaction(
            transactionId: existing.id,
            accountId: 'a-1',
            categoryId: 'c-1',
            type: TransactionType.expense,
            amount: 30,
            currency: 'TRY',
            description: 'Updated',
            transactionDate: DateTime.parse('2026-06-10T00:00:00Z'),
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(transactionsControllerProvider).value?.items,
      <Transaction>[existing],
    );
  });

  test(
    'createTransfer preserves current list when the mutation fails',
    () async {
      final existing = _transaction(
        id: 't-1',
        type: TransactionType.transfer,
        amount: 50,
      );

      final container = ProviderContainer(
        overrides: [
          transactionsRepositoryProvider.overrideWith(
            (ref) => _FakeTransactionsRepository(
              onList: () async => _page(<Transaction>[existing]),
              onCreateTransfer:
                  ({
                    required fromAccountId,
                    required toAccountId,
                    required categoryId,
                    required amount,
                    required currency,
                    description,
                    required transactionDate,
                  }) async {
                    throw const Failure.api(
                      code: ApiErrorCode.invalidTransfer,
                      message: 'Transfer failed.',
                    );
                  },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(transactionsControllerProvider.future);

      await expectLater(
        container
            .read(transactionsControllerProvider.notifier)
            .createTransfer(
              fromAccountId: 'a-1',
              toAccountId: 'a-2',
              categoryId: 'c-1',
              amount: 50,
              currency: 'TRY',
              description: 'Move money',
              transactionDate: DateTime.parse('2026-06-10T00:00:00Z'),
            ),
        throwsA(isA<ApiFailure>()),
      );

      expect(
        container.read(transactionsControllerProvider).value?.items,
        <Transaction>[existing],
      );
    },
  );

  test(
    'delete preserves current list when repository deletion fails',
    () async {
      final existing = _transaction(
        id: 't-1',
        type: TransactionType.expense,
        amount: 25,
        description: 'Lunch',
      );

      final container = ProviderContainer(
        overrides: [
          transactionsRepositoryProvider.overrideWith(
            (ref) => _FakeTransactionsRepository(
              onList: () async => _page(<Transaction>[existing]),
              onDelete: (transactionId) async {
                throw const Failure.api(
                  code: ApiErrorCode.insufficientBalance,
                  message: 'Cannot reverse transfer.',
                );
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(transactionsControllerProvider.future);

      await expectLater(
        container
            .read(transactionsControllerProvider.notifier)
            .deleteTransaction(existing.id),
        throwsA(isA<ApiFailure>()),
      );

      final state = container.read(transactionsControllerProvider).value;
      expect(state?.items, <Transaction>[existing]);
    },
  );

  test('delete syncs accounts after a successful mutation', () async {
    final existing = _transaction(
      id: 't-1',
      type: TransactionType.expense,
      amount: 25,
    );
    var accountListCallCount = 0;

    final container = ProviderContainer(
      overrides: [
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(
            onList: () async => _page(<Transaction>[]),
            onDelete: (transactionId) async {},
          ),
        ),
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            onList: () async {
              accountListCallCount += 1;
              return accountListCallCount == 1
                  ? <Account>[_account(id: 'a-1', balance: 75)]
                  : <Account>[_account(id: 'a-1', balance: 100)];
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(accountsControllerProvider.future);
    await container.read(transactionsControllerProvider.future);
    await container
        .read(transactionsControllerProvider.notifier)
        .deleteTransaction(existing.id);

    expect(container.read(accountsControllerProvider).value, <Account>[
      _account(id: 'a-1', balance: 100),
    ]);
  });
}
