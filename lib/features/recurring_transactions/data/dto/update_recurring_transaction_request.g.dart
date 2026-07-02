// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_recurring_transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateRecurringTransactionRequest _$UpdateRecurringTransactionRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateRecurringTransactionRequest(
  accountId: json['accountId'] as String,
  categoryId: json['categoryId'] as String,
  type: json['type'] as String,
  amount: json['amount'] as num,
  frequency: json['frequency'] as String,
  nextRunDate: json['nextRunDate'] as String,
  status: json['status'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  classification: json['classification'] as String?,
);

Map<String, dynamic> _$UpdateRecurringTransactionRequestToJson(
  _UpdateRecurringTransactionRequest instance,
) => <String, dynamic>{
  'accountId': instance.accountId,
  'categoryId': instance.categoryId,
  'type': instance.type,
  'amount': instance.amount,
  'frequency': instance.frequency,
  'nextRunDate': instance.nextRunDate,
  'status': instance.status,
  'name': ?instance.name,
  'description': ?instance.description,
  'startDate': ?instance.startDate,
  'endDate': ?instance.endDate,
  'classification': ?instance.classification,
};
