// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_recurring_transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateRecurringTransactionRequest _$CreateRecurringTransactionRequestFromJson(
  Map<String, dynamic> json,
) => _CreateRecurringTransactionRequest(
  accountId: json['accountId'] as String,
  categoryId: json['categoryId'] as String,
  type: json['type'] as String,
  amount: json['amount'] as num,
  frequency: json['frequency'] as String,
  nextRunDate: json['nextRunDate'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  classification: json['classification'] as String?,
);

Map<String, dynamic> _$CreateRecurringTransactionRequestToJson(
  _CreateRecurringTransactionRequest instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'categoryId': instance.categoryId,
  'type': instance.type,
  'amount': instance.amount,
  'frequency': instance.frequency,
  'nextRunDate': instance.nextRunDate,
  'name': ?instance.name,
  'description': ?instance.description,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
  'classification': ?instance.classification,
};
