// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BudgetStatusResponse _$BudgetStatusResponseFromJson(
  Map<String, dynamic> json,
) => _BudgetStatusResponse(
  category: json['category'] as String,
  budgetAmount: json['budgetAmount'] as num,
  spentAmount: json['spentAmount'] as num,
  remainingAmount: json['remainingAmount'] as num,
  usagePercentage: json['usagePercentage'] as num,
  status: json['status'] as String,
);

Map<String, dynamic> _$BudgetStatusResponseToJson(
  _BudgetStatusResponse instance,
) => <String, dynamic>{
  'category': instance.category,
  'budgetAmount': instance.budgetAmount,
  'spentAmount': instance.spentAmount,
  'remainingAmount': instance.remainingAmount,
  'usagePercentage': instance.usagePercentage,
  'status': instance.status,
};
