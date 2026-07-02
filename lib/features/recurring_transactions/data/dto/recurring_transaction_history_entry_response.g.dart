// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_history_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringTransactionHistoryEntryResponse
_$RecurringTransactionHistoryEntryResponseFromJson(Map<String, dynamic> json) =>
    _RecurringTransactionHistoryEntryResponse(
      id: json['id'] as String,
      recurringTransactionId: json['recurringTransactionId'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      executedAt: DateTime.parse(json['executedAt'] as String),
      transactionId: json['transactionId'] as String?,
      failureReason: json['failureReason'] as String?,
    );

Map<String, dynamic> _$RecurringTransactionHistoryEntryResponseToJson(
  _RecurringTransactionHistoryEntryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'recurringTransactionId': instance.recurringTransactionId,
  'status': instance.status,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
  'executedAt': instance.executedAt.toIso8601String(),
  'transactionId': ?instance.transactionId,
  'failureReason': ?instance.failureReason,
};
