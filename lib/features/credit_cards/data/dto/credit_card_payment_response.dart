import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';

part 'credit_card_payment_response.freezed.dart';
part 'credit_card_payment_response.g.dart';

@freezed
abstract class CreditCardPaymentResponse with _$CreditCardPaymentResponse {
  const factory CreditCardPaymentResponse({
    required String transactionId,
    required String creditAccountId,
    required String sourceAccountId,
    required num amountPaid,
    required num remainingBalance,
    required DateTime paidAt,
  }) = _CreditCardPaymentResponse;

  factory CreditCardPaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$CreditCardPaymentResponseFromJson(json);
}

extension CreditCardPaymentResponseX on CreditCardPaymentResponse {
  CreditCardPaymentResult toDomain() {
    return CreditCardPaymentResult(
      transactionId: transactionId,
      creditAccountId: creditAccountId,
      sourceAccountId: sourceAccountId,
      amountPaid: amountPaid,
      remainingBalance: remainingBalance,
      paidAt: paidAt,
    );
  }
}
