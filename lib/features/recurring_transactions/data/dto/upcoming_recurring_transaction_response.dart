import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';

part 'upcoming_recurring_transaction_response.freezed.dart';
part 'upcoming_recurring_transaction_response.g.dart';

@freezed
abstract class UpcomingRecurringTransactionResponse
    with _$UpcomingRecurringTransactionResponse {
  const factory UpcomingRecurringTransactionResponse({
    required String recurringTransactionId,
    String? name,
    required num amount,
    required DateTime scheduledDate,
  }) = _UpcomingRecurringTransactionResponse;

  factory UpcomingRecurringTransactionResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$UpcomingRecurringTransactionResponseFromJson(json);
}

extension UpcomingRecurringTransactionResponseX
    on UpcomingRecurringTransactionResponse {
  UpcomingRecurringTransaction toDomain() {
    return UpcomingRecurringTransaction(
      recurringTransactionId: recurringTransactionId,
      name: name,
      amount: amount,
      scheduledDate: scheduledDate,
    );
  }
}
