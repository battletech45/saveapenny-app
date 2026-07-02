import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_transaction_request.freezed.dart';
part 'update_transaction_request.g.dart';

@freezed
abstract class UpdateTransactionRequest with _$UpdateTransactionRequest {
  const factory UpdateTransactionRequest({
    required String accountId,
    required String categoryId,
    required String type,
    required num amount,
    required String currency,
    String? description,
    required String transactionDate,
  }) = _UpdateTransactionRequest;

  factory UpdateTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionRequestFromJson(json);
}
