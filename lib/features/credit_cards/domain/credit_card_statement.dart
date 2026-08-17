import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/accounts/domain/account.dart';

part 'credit_card_statement.freezed.dart';

@freezed
abstract class CreditCardStatement with _$CreditCardStatement {
  const factory CreditCardStatement({
    required String id,
    required String accountId,
    required DateTime statementDate,
    required DateTime dueDate,
    required num previousBalance,
    required num newBalance,
    required num interestCharged,
    required num minimumPaymentDue,
    required num amountPaid,
    required StatementStatus status,
  }) = _CreditCardStatement;
}
