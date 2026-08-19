import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/cached_fetch.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
import 'package:saveapenny/features/accounts/data/accounts_api.dart';
import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/accounts/data/dto/create_account_request.dart';
import 'package:saveapenny/features/accounts/data/dto/update_account_request.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';

part 'accounts_repository.g.dart';

const String _listCacheKey = 'accounts:list';

class AccountsRepositoryImpl implements AccountsRepository {
  const AccountsRepositoryImpl(this._accountsApi, this._cache);

  final AccountsApi _accountsApi;
  final ResponseCacheStore _cache;

  @override
  Future<List<Account>> list() async {
    final items = await cachedFetch<List<AccountResponse>>(
      cache: _cache,
      key: _listCacheKey,
      call: () async => (await _accountsApi.list()).items,
      toJson: (items) => <String, dynamic>{
        'items': items.map((item) => item.toJson()).toList(),
      },
      fromJson: (json) => (json['items']! as List<dynamic>)
          .map((item) => AccountResponse.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
    return items
        .map((AccountResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<DateTime?> lastSyncedAt() => _cache.writtenAt(_listCacheKey);

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) async {
    final response = await _accountsApi.create(
      CreateAccountRequest(
        name: name,
        type: _accountTypeToWire(type),
        currency: currency,
        initialBalance: initialBalance,
        creditLimit: creditLimit,
        apr: apr,
        statementDay: statementDay,
      ),
    );
    // The cached list page is now stale relative to the backend; drop it
    // rather than patch it in place, so the next list() re-fetches (or, if
    // offline, honestly reports a miss instead of showing pre-mutation data).
    await _cache.invalidate(_listCacheKey);

    return response.toDomain();
  }

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) async {
    final response = await _accountsApi.update(
      accountId: accountId,
      request: UpdateAccountRequest(
        name: name,
        type: _accountTypeToWire(type),
        currency: currency,
      ),
    );
    await _cache.invalidate(_listCacheKey);

    return response.toDomain();
  }

  @override
  Future<void> delete(String accountId) async {
    await _accountsApi.delete(accountId);
    await _cache.invalidate(_listCacheKey);
  }
}

String _accountTypeToWire(AccountType type) {
  return switch (type) {
    AccountType.cash => 'CASH',
    AccountType.bank => 'BANK',
    AccountType.credit => 'CREDIT',
    AccountType.savings => 'SAVINGS',
    AccountType.investment => 'INVESTMENT',
  };
}

@Riverpod(keepAlive: true)
AccountsRepository accountsRepository(Ref ref) {
  return AccountsRepositoryImpl(
    ref.watch(accountsApiProvider),
    ref.watch(responseCacheStoreProvider),
  );
}
