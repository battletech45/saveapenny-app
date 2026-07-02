import 'package:freezed_annotation/freezed_annotation.dart';

part 'upcoming_recurring_transaction.freezed.dart';

@freezed
abstract class UpcomingRecurringTransaction
    with _$UpcomingRecurringTransaction {
  const factory UpcomingRecurringTransaction({
    required String recurringTransactionId,
    String? name,
    required num amount,
    required DateTime scheduledDate,
  }) = _UpcomingRecurringTransaction;
}
