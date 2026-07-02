// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_recurring_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpcomingRecurringTransactionResponse
_$UpcomingRecurringTransactionResponseFromJson(Map<String, dynamic> json) =>
    _UpcomingRecurringTransactionResponse(
      recurringTransactionId: json['recurringTransactionId'] as String,
      name: json['name'] as String?,
      amount: json['amount'] as num,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    );

Map<String, dynamic> _$UpcomingRecurringTransactionResponseToJson(
  _UpcomingRecurringTransactionResponse instance,
) => <String, dynamic>{
  'recurringTransactionId': instance.recurringTransactionId,
  'name': ?instance.name,
  'amount': instance.amount,
  'scheduledDate': instance.scheduledDate.toIso8601String(),
};
