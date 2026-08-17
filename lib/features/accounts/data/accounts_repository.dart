import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/accounts/data/accounts_api.dart';
import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/accounts/data/dto/create_account_request.dart';
import 'package:saveapenny/features/accounts/data/dto/update_account_request.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';

part 'accounts_repository.g.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  const AccountsRepositoryImpl(this._accountsApi);

  final AccountsApi _accountsApi;

  @override
  Future<List<Account>> list() async {
    final page = await _accountsApi.list();
    return page.items
        .map((AccountResponse item) => item.toDomain())
        .toList(growable: false);
  }

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

    return response.toDomain();
  }

  @override
  Future<void> delete(String accountId) {
    return _accountsApi.delete(accountId);
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
  return AccountsRepositoryImpl(ref.watch(accountsApiProvider));
}
