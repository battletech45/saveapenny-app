import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';

part 'recurring_transaction_history_entry_response.freezed.dart';
part 'recurring_transaction_history_entry_response.g.dart';

@freezed
abstract class RecurringTransactionHistoryEntryResponse
    with _$RecurringTransactionHistoryEntryResponse {
  const factory RecurringTransactionHistoryEntryResponse({
    required String id,
    required String recurringTransactionId,
    required String status,
    required DateTime scheduledDate,
    required DateTime executedAt,
    String? transactionId,
    String? failureReason,
  }) = _RecurringTransactionHistoryEntryResponse;

  factory RecurringTransactionHistoryEntryResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$RecurringTransactionHistoryEntryResponseFromJson(json);
}

extension RecurringTransactionHistoryEntryResponseX
    on RecurringTransactionHistoryEntryResponse {
  RecurringTransactionHistoryEntry toDomain() {
    return RecurringTransactionHistoryEntry(
      id: id,
      recurringTransactionId: recurringTransactionId,
      status: _executionStatusFromWire(status),
      scheduledDate: scheduledDate,
      executedAt: executedAt,
      transactionId: transactionId,
      failureReason: failureReason,
    );
  }
}

RecurringExecutionStatus _executionStatusFromWire(String value) {
  return switch (value.toUpperCase()) {
    'SUCCESS' => RecurringExecutionStatus.success,
    'FAILED' => RecurringExecutionStatus.failed,
    'SKIPPED' => RecurringExecutionStatus.skipped,
    _ => throw FormatException(
      'Unsupported recurring execution status: $value',
    ),
  };
}
