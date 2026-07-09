import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';

part 'stock_quote_response.freezed.dart';
part 'stock_quote_response.g.dart';

@freezed
abstract class StockQuoteResponse with _$StockQuoteResponse {
  const factory StockQuoteResponse({
    required String symbol,
    @JsonKey(fromJson: stockNumOrNull) num? open,
    @JsonKey(fromJson: stockNumOrNull) num? high,
    @JsonKey(fromJson: stockNumOrNull) num? low,
    @JsonKey(fromJson: stockNumOrNull) num? price,
    @JsonKey(fromJson: stockIntOrNull) int? volume,
    @JsonKey(fromJson: stockDateOrNull) DateTime? latestTradingDay,
    @JsonKey(fromJson: stockNumOrNull) num? previousClose,
    @JsonKey(fromJson: stockNumOrNull) num? change,
    @JsonKey(fromJson: stockNumOrNull) num? changePercent,
  }) = _StockQuoteResponse;

  factory StockQuoteResponse.fromJson(Map<String, dynamic> json) =>
      _$StockQuoteResponseFromJson(json);
}

extension StockQuoteResponseX on StockQuoteResponse {
  StockQuote toDomain() {
    return StockQuote(
      symbol: symbol,
      open: open,
      high: high,
      low: low,
      price: price,
      volume: volume,
      latestTradingDay: latestTradingDay,
      previousClose: previousClose,
      change: change,
      changePercent: changePercent,
    );
  }
}
