import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_card_details_request.freezed.dart';
part 'credit_card_details_request.g.dart';

@freezed
abstract class CreditCardDetailsRequest with _$CreditCardDetailsRequest {
  const factory CreditCardDetailsRequest({
    required num creditLimit,
    required num apr,
    required int statementDay,
  }) = _CreditCardDetailsRequest;

  factory CreditCardDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$CreditCardDetailsRequestFromJson(json);
}
