import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_holding_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';

part 'stock_holding_summary_response.freezed.dart';
part 'stock_holding_summary_response.g.dart';

@freezed
abstract class StockHoldingSummaryResponse with _$StockHoldingSummaryResponse {
  const factory StockHoldingSummaryResponse({
    @JsonKey(fromJson: stockNum) required num totalInvested,
    @JsonKey(fromJson: stockNum) required num totalCurrentValue,
    @JsonKey(fromJson: stockNumOrNull) num? totalProfitLoss,
    @JsonKey(fromJson: stockNumOrNull) num? totalProfitLossPercent,
    required int holdingCount,
    required List<StockHoldingResponse> holdings,
  }) = _StockHoldingSummaryResponse;

  factory StockHoldingSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$StockHoldingSummaryResponseFromJson(json);
}

extension StockHoldingSummaryResponseX on StockHoldingSummaryResponse {
  StockHoldingSummary toDomain() {
    return StockHoldingSummary(
      totalInvested: totalInvested,
      totalCurrentValue: totalCurrentValue,
      totalProfitLoss: totalProfitLoss,
      totalProfitLossPercent: totalProfitLossPercent,
      holdingCount: holdingCount,
      holdings: holdings.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}
