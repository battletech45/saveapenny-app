import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_status.freezed.dart';

enum BudgetHealth { onTrack, warning, exceeded }

@freezed
abstract class BudgetStatus with _$BudgetStatus {
  const factory BudgetStatus({
    required String category,
    required num budgetAmount,
    required num spentAmount,
    required num remainingAmount,
    required num usagePercentage,
    required BudgetHealth status,
  }) = _BudgetStatus;
}
