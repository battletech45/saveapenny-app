import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/reports/domain/monthly_summary.dart';

part 'monthly_summary_response.freezed.dart';
part 'monthly_summary_response.g.dart';

@freezed
abstract class MonthlySummaryResponse with _$MonthlySummaryResponse {
  const factory MonthlySummaryResponse({
    required DateTime startDate,
    required DateTime endDate,
    required num totalIncome,
    required num totalExpense,
    required num netSavings,
  }) = _MonthlySummaryResponse;

  factory MonthlySummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryResponseFromJson(json);
}

extension MonthlySummaryResponseX on MonthlySummaryResponse {
  MonthlySummary toDomain() {
    return MonthlySummary(
      startDate: startDate,
      endDate: endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
    );
  }
}
