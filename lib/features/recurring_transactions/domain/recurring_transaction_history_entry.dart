import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction_history_entry.freezed.dart';

enum RecurringExecutionStatus { success, failed, skipped }

@freezed
abstract class RecurringTransactionHistoryEntry
    with _$RecurringTransactionHistoryEntry {
  const factory RecurringTransactionHistoryEntry({
    required String id,
    required String recurringTransactionId,
    required RecurringExecutionStatus status,
    required DateTime scheduledDate,
    required DateTime executedAt,
    String? transactionId,
    String? failureReason,
  }) = _RecurringTransactionHistoryEntry;
}
