import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';

part 'stock_holding_response.freezed.dart';
part 'stock_holding_response.g.dart';

@freezed
abstract class StockHoldingResponse with _$StockHoldingResponse {
  const factory StockHoldingResponse({
    required String id,
    required String symbol,
    @JsonKey(fromJson: stockNum) required num quantity,
    @JsonKey(fromJson: stockNum) required num purchasePrice,
    required String currency,
    @JsonKey(fromJson: stockDate) required DateTime purchaseDate,
    String? notes,
    @JsonKey(fromJson: stockNumOrNull) num? investedAmount,
    @JsonKey(fromJson: stockNumOrNull) num? currentPrice,
    @JsonKey(fromJson: stockNumOrNull) num? currentValue,
    @JsonKey(fromJson: stockNumOrNull) num? profitLoss,
    @JsonKey(fromJson: stockNumOrNull) num? profitLossPercent,
    @JsonKey(fromJson: stockDateOrNull) DateTime? latestTradingDay,
    @JsonKey(fromJson: stockDateTime) required DateTime createdAt,
    @JsonKey(fromJson: stockDateTime) required DateTime updatedAt,
  }) = _StockHoldingResponse;

  factory StockHoldingResponse.fromJson(Map<String, dynamic> json) =>
      _$StockHoldingResponseFromJson(json);
}

extension StockHoldingResponseX on StockHoldingResponse {
  StockHolding toDomain() {
    return StockHolding(
      id: id,
      symbol: symbol,
      quantity: quantity,
      purchasePrice: purchasePrice,
      currency: currency,
      purchaseDate: purchaseDate,
      notes: notes,
      investedAmount: investedAmount,
      currentPrice: currentPrice,
      currentValue: currentValue,
      profitLoss: profitLoss,
      profitLossPercent: profitLossPercent,
      latestTradingDay: latestTradingDay,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
