import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';

part 'recurring_transaction_response.freezed.dart';
part 'recurring_transaction_response.g.dart';

@freezed
abstract class RecurringTransactionResponse
    with _$RecurringTransactionResponse {
  const factory RecurringTransactionResponse({
    required String id,
    required String userId,
    required String accountId,
    required String categoryId,
    required String type,
    required num amount,
    required String frequency,
    required DateTime nextRunDate,
    required String status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastRunAt,
    String? classification,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _RecurringTransactionResponse;

  factory RecurringTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionResponseFromJson(json);
}

extension RecurringTransactionResponseX on RecurringTransactionResponse {
  RecurringTransaction toDomain() {
    return RecurringTransaction(
      id: id,
      userId: userId,
      accountId: accountId,
      categoryId: categoryId,
      type: _typeFromWire(type),
      amount: amount,
      frequency: _frequencyFromWire(frequency),
      nextRunDate: nextRunDate,
      status: _statusFromWire(status),
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      lastRunAt: lastRunAt,
      classification: classification == null
          ? null
          : _classificationFromWire(classification!),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

RecurringTransactionType _typeFromWire(String value) {
  return switch (value.toUpperCase()) {
    'INCOME' => RecurringTransactionType.income,
    'EXPENSE' => RecurringTransactionType.expense,
    _ => throw FormatException(
      'Unsupported recurring transaction type: $value',
    ),
  };
}

RecurringFrequency _frequencyFromWire(String value) {
  return switch (value.toUpperCase()) {
    'DAILY' => RecurringFrequency.daily,
    'WEEKLY' => RecurringFrequency.weekly,
    'MONTHLY' => RecurringFrequency.monthly,
    'YEARLY' => RecurringFrequency.yearly,
    _ => throw FormatException('Unsupported recurring frequency: $value'),
  };
}

RecurringStatus _statusFromWire(String value) {
  return switch (value.toUpperCase()) {
    'ACTIVE' => RecurringStatus.active,
    'PAUSED' => RecurringStatus.paused,
    'EXPIRED' => RecurringStatus.expired,
    'FAILED' => RecurringStatus.failed,
    _ => throw FormatException('Unsupported recurring status: $value'),
  };
}

RecurringClassification _classificationFromWire(String value) {
  return switch (value.toUpperCase()) {
    'PAYCHECK' => RecurringClassification.paycheck,
    'SUBSCRIPTION' => RecurringClassification.subscription,
    'RENT' => RecurringClassification.rent,
    'UTILITY' => RecurringClassification.utility,
    'LOAN_PAYMENT' => RecurringClassification.loanPayment,
    'SAVINGS_CONTRIBUTION' => RecurringClassification.savingsContribution,
    'OTHER' => RecurringClassification.other,
    _ => throw FormatException('Unsupported recurring classification: $value'),
  };
}
