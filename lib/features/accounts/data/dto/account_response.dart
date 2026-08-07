import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/accounts/domain/account.dart';

part 'account_response.freezed.dart';
part 'account_response.g.dart';

@freezed
abstract class CreditCardSummaryResponse with _$CreditCardSummaryResponse {
  const factory CreditCardSummaryResponse({
    required num creditLimit,
    required num apr,
    required int statementDay,
    required int gracePeriodDays,
    required num availableCredit,
    num? currentStatementBalance,
    num? minimumPaymentDue,
    DateTime? statementDate,
    DateTime? paymentDueDate,
    String? statementStatus,
  }) = _CreditCardSummaryResponse;

  factory CreditCardSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditCardSummaryResponseFromJson(json);
}

extension CreditCardSummaryResponseX on CreditCardSummaryResponse {
  CreditCardSummary toDomain() {
    return CreditCardSummary(
      creditLimit: creditLimit,
      apr: apr,
      statementDay: statementDay,
      gracePeriodDays: gracePeriodDays,
      availableCredit: availableCredit,
      currentStatementBalance: currentStatementBalance,
      minimumPaymentDue: minimumPaymentDue,
      statementDate: statementDate,
      paymentDueDate: paymentDueDate,
      statementStatus: statementStatus == null
          ? null
          : statementStatusFromWire(statementStatus!),
    );
  }
}

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
    CreditCardSummaryResponse? creditCard,
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
      creditCard: creditCard?.toDomain(),
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

StatementStatus statementStatusFromWire(String value) {
  return switch (value) {
    'PAID' => StatementStatus.paid,
    'MISSED' => StatementStatus.missed,
    _ => StatementStatus.open,
  };
}
