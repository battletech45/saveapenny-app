import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/domain/stock_holding.dart';

part 'stock_holding_summary.freezed.dart';

@freezed
abstract class StockHoldingSummary with _$StockHoldingSummary {
  const factory StockHoldingSummary({
    required num totalInvested,
    required num totalCurrentValue,
    num? totalProfitLoss,
    num? totalProfitLossPercent,
    required int holdingCount,
    required List<StockHolding> holdings,
  }) = _StockHoldingSummary;
}
