import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer_response.freezed.dart';
part 'transfer_response.g.dart';

@freezed
abstract class TransferResponse with _$TransferResponse {
  const factory TransferResponse({
    required String transactionId,
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) = _TransferResponse;

  factory TransferResponse.fromJson(Map<String, dynamic> json) =>
      _$TransferResponseFromJson(json);
}
