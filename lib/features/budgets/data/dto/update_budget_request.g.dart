// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_budget_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateBudgetRequest _$UpdateBudgetRequestFromJson(Map<String, dynamic> json) =>
    _UpdateBudgetRequest(
      categoryId: json['categoryId'] as String,
      amount: json['amount'] as num,
      period: json['period'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );

Map<String, dynamic> _$UpdateBudgetRequestToJson(
  _UpdateBudgetRequest instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'period': instance.period,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
};
