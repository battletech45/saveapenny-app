import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_holding.freezed.dart';

@freezed
abstract class StockHolding with _$StockHolding {
  const factory StockHolding({
    required String id,
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
    num? investedAmount,
    num? currentPrice,
    num? currentValue,
    num? profitLoss,
    num? profitLossPercent,
    DateTime? latestTradingDay,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _StockHolding;
}
