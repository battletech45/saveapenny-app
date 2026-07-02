import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/budgets/domain/budget_status.dart';

part 'budget_status_response.freezed.dart';
part 'budget_status_response.g.dart';

@freezed
abstract class BudgetStatusResponse with _$BudgetStatusResponse {
  const factory BudgetStatusResponse({
    required String category,
    required num budgetAmount,
    required num spentAmount,
    required num remainingAmount,
    required num usagePercentage,
    required String status,
  }) = _BudgetStatusResponse;

  factory BudgetStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetStatusResponseFromJson(json);
}

extension BudgetStatusResponseX on BudgetStatusResponse {
  BudgetStatus toDomain() {
    return BudgetStatus(
      category: category,
      budgetAmount: budgetAmount,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      usagePercentage: usagePercentage,
      status: _budgetHealthFromWire(status),
    );
  }
}

BudgetHealth _budgetHealthFromWire(String value) {
  return switch (value.toUpperCase()) {
    'ON_TRACK' => BudgetHealth.onTrack,
    'WARNING' => BudgetHealth.warning,
    'EXCEEDED' => BudgetHealth.exceeded,
    _ => throw FormatException('Unsupported budget status: $value'),
  };
}
