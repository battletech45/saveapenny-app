// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringTransactionResponse _$RecurringTransactionResponseFromJson(
  Map<String, dynamic> json,
) => _RecurringTransactionResponse(
  id: json['id'] as String,
  userId: json['userId'] as String,
  accountId: json['accountId'] as String,
  categoryId: json['categoryId'] as String,
  type: json['type'] as String,
  amount: json['amount'] as num,
  frequency: json['frequency'] as String,
  nextRunDate: DateTime.parse(json['nextRunDate'] as String),
  status: json['status'] as String,
  name: json['name'] as String?,
  description: json['description'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  lastRunAt: json['lastRunAt'] == null
      ? null
      : DateTime.parse(json['lastRunAt'] as String),
  classification: json['classification'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$RecurringTransactionResponseToJson(
  _RecurringTransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'accountId': instance.accountId,
  'categoryId': instance.categoryId,
  'type': instance.type,
  'amount': instance.amount,
  'frequency': instance.frequency,
  'nextRunDate': instance.nextRunDate.toIso8601String(),
  'status': instance.status,
  'name': ?instance.name,
  'description': ?instance.description,
  'startDate': ?instance.startDate?.toIso8601String(),
  'endDate': ?instance.endDate?.toIso8601String(),
  'lastRunAt': ?instance.lastRunAt?.toIso8601String(),
  'classification': ?instance.classification,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
