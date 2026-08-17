import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/accounts/data/dto/account_response.dart';
import 'package:saveapenny/features/credit_cards/domain/credit_card_statement.dart';

part 'credit_card_statement_response.freezed.dart';
part 'credit_card_statement_response.g.dart';

@freezed
abstract class CreditCardStatementResponse with _$CreditCardStatementResponse {
  const factory CreditCardStatementResponse({
    required String id,
    required String accountId,
    required DateTime statementDate,
    required DateTime dueDate,
    required num previousBalance,
    required num newBalance,
    required num interestCharged,
    required num minimumPaymentDue,
    required num amountPaid,
    required String status,
  }) = _CreditCardStatementResponse;

  factory CreditCardStatementResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditCardStatementResponseFromJson(json);
}

extension CreditCardStatementResponseX on CreditCardStatementResponse {
  CreditCardStatement toDomain() {
    return CreditCardStatement(
      id: id,
      accountId: accountId,
      statementDate: statementDate,
      dueDate: dueDate,
      previousBalance: previousBalance,
      newBalance: newBalance,
      interestCharged: interestCharged,
      minimumPaymentDue: minimumPaymentDue,
      amountPaid: amountPaid,
      status: statementStatusFromWire(status),
    );
  }
}
