import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_summary.freezed.dart';

@freezed
abstract class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required DateTime startDate,
    required DateTime endDate,
    required num totalIncome,
    required num totalExpense,
    required num netSavings,
  }) = _MonthlySummary;
}
