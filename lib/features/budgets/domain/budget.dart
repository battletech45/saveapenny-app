import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

enum BudgetPeriod { monthly, yearly }

@freezed
abstract class Budget with _$Budget {
  const factory Budget({
    required String id,
    required String userId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Budget;
}
