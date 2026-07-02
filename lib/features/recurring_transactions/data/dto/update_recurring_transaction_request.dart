import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_recurring_transaction_request.freezed.dart';
part 'update_recurring_transaction_request.g.dart';

@freezed
abstract class UpdateRecurringTransactionRequest
    with _$UpdateRecurringTransactionRequest {
  const factory UpdateRecurringTransactionRequest({
    required String accountId,
    required String categoryId,
    required String type,
    required num amount,
    required String frequency,
    required String nextRunDate,
    required String status,
    String? name,
    String? description,
    String? startDate,
    String? endDate,
    String? classification,
  }) = _UpdateRecurringTransactionRequest;

  factory UpdateRecurringTransactionRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateRecurringTransactionRequestFromJson(json);
}
