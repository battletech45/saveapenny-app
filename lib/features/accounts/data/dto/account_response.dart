import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/accounts/domain/account.dart';

part 'account_response.freezed.dart';
part 'account_response.g.dart';

@freezed
abstract class AccountResponse with _$AccountResponse {
  const factory AccountResponse({
    required String id,
    required String name,
    required String type,
    required String currency,
    required num balance,
    required num initialBalance,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AccountResponse;

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);
}

extension AccountResponseX on AccountResponse {
  Account toDomain() {
    return Account(
      id: id,
      name: name,
      type: _accountTypeFromWire(type),
      currency: currency,
      balance: balance,
      initialBalance: initialBalance,
      active: active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

AccountType _accountTypeFromWire(String value) {
  return switch (value) {
    'BANK' => AccountType.bank,
    'CREDIT' => AccountType.credit,
    'SAVINGS' => AccountType.savings,
    'INVESTMENT' => AccountType.investment,
    _ => AccountType.cash,
  };
}
