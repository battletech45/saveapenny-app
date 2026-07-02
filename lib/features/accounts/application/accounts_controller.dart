import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';

part 'accounts_controller.g.dart';

@Riverpod(keepAlive: true)
class AccountsController extends _$AccountsController {
  @override
  Future<List<Account>> build() {
    return ref.read(accountsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(accountsRepositoryProvider).list(),
    );
  }

  Future<void> sync() async {
    final current = state is AsyncData<List<Account>>
        ? (state as AsyncData<List<Account>>).value
        : null;

    try {
      state = AsyncData(await ref.read(accountsRepositoryProvider).list());
    } on Object catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        return;
      }

      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
  }) async {
    final current = state is AsyncData<List<Account>>
        ? (state as AsyncData<List<Account>>).value
        : const <Account>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final created = await ref
          .read(accountsRepositoryProvider)
          .create(
            name: name,
            type: type,
            currency: currency,
            initialBalance: initialBalance,
          );
      return <Account>[...current, created];
    });
  }

  Future<void> updateAccount({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) async {
    final current = state is AsyncData<List<Account>>
        ? (state as AsyncData<List<Account>>).value
        : const <Account>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updated = await ref
          .read(accountsRepositoryProvider)
          .update(
            accountId: accountId,
            name: name,
            type: type,
            currency: currency,
          );
      return current
          .map((Account account) => account.id == accountId ? updated : account)
          .toList(growable: false);
    });
  }

  Future<void> deleteAccount(String accountId) async {
    final current = state is AsyncData<List<Account>>
        ? (state as AsyncData<List<Account>>).value
        : const <Account>[];
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountsRepositoryProvider).delete(accountId);
      return current
          .where((Account account) => account.id != accountId)
          .toList(growable: false);
    });
  }
}
