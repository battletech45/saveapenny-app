import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/accounts/application/accounts_controller.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.onList, this.onCreate});

  final Future<List<Account>> Function()? onList;
  final Future<Account> Function(
    String name,
    AccountType type,
    String currency,
    num initialBalance,
  )?
  onCreate;

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
    return onCreate!(name, type, currency, initialBalance);
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

void main() {
  test('create appends a new account to the current state', () async {
    final existing = Account(
      id: 'a-1',
      name: 'Main bank',
      type: AccountType.bank,
      currency: 'TRY',
      balance: 100,
      initialBalance: 100,
      active: true,
      createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
      updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
    );
    final created = existing.copyWith(id: 'a-2', name: 'Cash wallet');

    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            onList: () async => <Account>[existing],
            onCreate: (name, type, currency, initialBalance) async => created,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(accountsControllerProvider.future);
    await container
        .read(accountsControllerProvider.notifier)
        .create(
          name: 'Cash wallet',
          type: AccountType.cash,
          currency: 'TRY',
          initialBalance: 50,
        );

    expect(container.read(accountsControllerProvider).value, <Account>[
      existing,
      created,
    ]);
  });

  test('create exposes the primary validation failure path', () async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            onList: () async => const <Account>[],
            onCreate: (name, type, currency, initialBalance) async {
              throw const Failure.api(
                code: ApiErrorCode.validationFailed,
                message: 'Invalid account',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(accountsControllerProvider.future);
    await container
        .read(accountsControllerProvider.notifier)
        .create(
          name: '',
          type: AccountType.bank,
          currency: 'TRY',
          initialBalance: 0,
        );

    expect(container.read(accountsControllerProvider).hasError, isTrue);
  });

  test(
    'concurrent sync calls are coalesced into a single repository request',
    () async {
      var listCallCount = 0;
      final listCompleters = <Completer<List<Account>>>[];

      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              onList: () {
                listCallCount += 1;
                final completer = Completer<List<Account>>();
                listCompleters.add(completer);
                return completer.future;
              },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final initialBuild = container.read(accountsControllerProvider.future);
      listCompleters.first.complete(const <Account>[]);
      await initialBuild;
      listCallCount = 0;

      final notifier = container.read(accountsControllerProvider.notifier);
      final first = notifier.sync();
      final second = notifier.sync();

      expect(listCallCount, 1);

      listCompleters.last.complete(const <Account>[]);
      await first;
      await second;

      expect(listCallCount, 1);
    },
  );
}
