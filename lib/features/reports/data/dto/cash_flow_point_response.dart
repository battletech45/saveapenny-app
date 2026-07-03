import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';

part 'cash_flow_point_response.freezed.dart';
part 'cash_flow_point_response.g.dart';

@freezed
abstract class CashFlowPointResponse with _$CashFlowPointResponse {
  const factory CashFlowPointResponse({
    required DateTime date,
    required num incomeAmount,
    required num expenseAmount,
    required num netAmount,
  }) = _CashFlowPointResponse;

  factory CashFlowPointResponse.fromJson(Map<String, dynamic> json) =>
      _$CashFlowPointResponseFromJson(json);
}

extension CashFlowPointResponseX on CashFlowPointResponse {
  CashFlowPoint toDomain() {
    return CashFlowPoint(
      date: date,
      incomeAmount: incomeAmount,
      expenseAmount: expenseAmount,
      netAmount: netAmount,
    );
  }
}
