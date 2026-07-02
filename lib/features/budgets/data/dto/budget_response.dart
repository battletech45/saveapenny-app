import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/budgets/domain/budget.dart';

part 'budget_response.freezed.dart';
part 'budget_response.g.dart';

@freezed
abstract class BudgetResponse with _$BudgetResponse {
  const factory BudgetResponse({
    required String id,
    required String userId,
    required String categoryId,
    required num amount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetResponse;

  factory BudgetResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetResponseFromJson(json);
}

extension BudgetResponseX on BudgetResponse {
  Budget toDomain() {
    return Budget(
      id: id,
      userId: userId,
      categoryId: categoryId,
      amount: amount,
      period: _budgetPeriodFromWire(period),
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

BudgetPeriod _budgetPeriodFromWire(String value) {
  return switch (value.toUpperCase()) {
    'MONTHLY' => BudgetPeriod.monthly,
    'YEARLY' => BudgetPeriod.yearly,
    _ => throw FormatException('Unsupported budget period: $value'),
  };
}
