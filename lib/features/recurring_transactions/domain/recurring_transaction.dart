import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction.freezed.dart';

enum RecurringTransactionType { income, expense }

enum RecurringFrequency { daily, weekly, monthly, yearly }

enum RecurringStatus { active, paused, expired, failed }

enum RecurringClassification {
  paycheck,
  subscription,
  rent,
  utility,
  loanPayment,
  savingsContribution,
  other,
}

@freezed
abstract class RecurringTransaction with _$RecurringTransaction {
  const factory RecurringTransaction({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    required RecurringStatus status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastRunAt,
    RecurringClassification? classification,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecurringTransaction;
}
