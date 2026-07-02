// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_budget_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateBudgetRequest _$CreateBudgetRequestFromJson(Map<String, dynamic> json) =>
    _CreateBudgetRequest(
      categoryId: json['categoryId'] as String,
      amount: json['amount'] as num,
      period: json['period'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );

Map<String, dynamic> _$CreateBudgetRequestToJson(
  _CreateBudgetRequest instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'period': instance.period,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
};
