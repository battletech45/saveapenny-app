import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';

part 'accounts_controller.g.dart';

@Riverpod(keepAlive: true)
class AccountsController extends _$AccountsController {
  Future<List<Account>>? _inFlightFetch;

  @override
  Future<List<Account>> build() {
    return ref.read(accountsRepositoryProvider).list();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> sync() async {
    final current = state is AsyncData<List<Account>>
        ? (state as AsyncData<List<Account>>).value
        : null;

    try {
      state = AsyncData(await _fetch());
    } on Object catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
        return;
      }

      state = AsyncError(error, stackTrace);
    }
  }

  // Coalesces concurrent refresh/sync callers onto a single in-flight
  // request instead of each firing its own GET and racing on `state`.
  Future<List<Account>> _fetch() {
    return _inFlightFetch ??= ref
        .read(accountsRepositoryProvider)
        .list()
        .whenComplete(() => _inFlightFetch = null);
  }

  Future<void> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
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
            creditLimit: creditLimit,
            apr: apr,
            statementDay: statementDay,
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

/// Re-evaluates whenever [accountsControllerProvider]'s state changes,
/// which is exactly when a fresh `list()` call may have written through to
/// the offline cache. Backs [CacheStalenessLabel] on the accounts screen.
@riverpod
Future<DateTime?> accountsLastSyncedAt(Ref ref) {
  ref.watch(accountsControllerProvider);
  return ref.read(accountsRepositoryProvider).lastSyncedAt();
}
