import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_flow_point.freezed.dart';

@freezed
abstract class CashFlowPoint with _$CashFlowPoint {
  const factory CashFlowPoint({
    required DateTime date,
    required num incomeAmount,
    required num expenseAmount,
    required num netAmount,
  }) = _CashFlowPoint;
}
