import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_card_payment.freezed.dart';

enum CreditCardPaymentType { minimumDue, fullBalance, custom }

@freezed
abstract class CreditCardPaymentResult with _$CreditCardPaymentResult {
  const factory CreditCardPaymentResult({
    required String transactionId,
    required String creditAccountId,
    required String sourceAccountId,
    required num amountPaid,
    required num remainingBalance,
    required DateTime paidAt,
  }) = _CreditCardPaymentResult;
}
