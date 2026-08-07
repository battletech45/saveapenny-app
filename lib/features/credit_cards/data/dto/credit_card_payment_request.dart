import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/credit_cards/domain/credit_card_payment.dart';

part 'credit_card_payment_request.freezed.dart';
part 'credit_card_payment_request.g.dart';

@freezed
abstract class CreditCardPaymentRequest with _$CreditCardPaymentRequest {
  const factory CreditCardPaymentRequest({
    required String sourceAccountId,
    required String paymentType,
    num? amount,
  }) = _CreditCardPaymentRequest;

  factory CreditCardPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreditCardPaymentRequestFromJson(json);
}

String creditCardPaymentTypeToWire(CreditCardPaymentType type) {
  return switch (type) {
    CreditCardPaymentType.minimumDue => 'MINIMUM_DUE',
    CreditCardPaymentType.fullBalance => 'FULL_BALANCE',
    CreditCardPaymentType.custom => 'CUSTOM',
  };
}
