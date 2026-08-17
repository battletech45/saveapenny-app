import 'package:freezed_annotation/freezed_annotation.dart';

part 'account.freezed.dart';

enum AccountType { cash, bank, credit, savings, investment }

enum StatementStatus { open, paid, missed }

@freezed
abstract class CreditCardSummary with _$CreditCardSummary {
  const factory CreditCardSummary({
    required num creditLimit,
    required num apr,
    required int statementDay,
    required int gracePeriodDays,
    required num availableCredit,
    // Null until the first billing cycle closes and an open statement
    // exists (backend only populates these from the current statement).
    num? currentStatementBalance,
    num? minimumPaymentDue,
    DateTime? statementDate,
    DateTime? paymentDueDate,
    StatementStatus? statementStatus,
  }) = _CreditCardSummary;
}

@freezed
abstract class Account with _$Account {
  const factory Account({
    required String id,
    required String name,
    required AccountType type,
    required String currency,
    required num balance,
    required num initialBalance,
    required bool active,
    required DateTime createdAt,
    required DateTime updatedAt,
    CreditCardSummary? creditCard,
  }) = _Account;
}
