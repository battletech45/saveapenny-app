import 'package:saveapenny/features/accounts/domain/account.dart';

abstract interface class AccountsRepository {
  Future<List<Account>> list();

  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  });

  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  });

  Future<void> delete(String accountId);
}
