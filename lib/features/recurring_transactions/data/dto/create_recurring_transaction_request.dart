import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_recurring_transaction_request.freezed.dart';
part 'create_recurring_transaction_request.g.dart';

@freezed
abstract class CreateRecurringTransactionRequest
    with _$CreateRecurringTransactionRequest {
  const factory CreateRecurringTransactionRequest({
    required String accountId,
    required String categoryId,
    required String type,
    required num amount,
    required String frequency,
    required String nextRunDate,
    String? name,
    String? description,
    String? startDate,
    String? endDate,
    String? classification,
  }) = _CreateRecurringTransactionRequest;

  factory CreateRecurringTransactionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateRecurringTransactionRequestFromJson(json);
}
