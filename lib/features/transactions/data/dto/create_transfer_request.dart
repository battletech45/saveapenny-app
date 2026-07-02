import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_transfer_request.freezed.dart';
part 'create_transfer_request.g.dart';

@freezed
abstract class CreateTransferRequest with _$CreateTransferRequest {
  const factory CreateTransferRequest({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required String transactionDate,
  }) = _CreateTransferRequest;

  factory CreateTransferRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTransferRequestFromJson(json);
}
