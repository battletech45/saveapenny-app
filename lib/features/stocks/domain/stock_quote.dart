import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_quote.freezed.dart';

@freezed
abstract class StockQuote with _$StockQuote {
  const factory StockQuote({
    required String symbol,
    num? open,
    num? high,
    num? low,
    num? price,
    int? volume,
    DateTime? latestTradingDay,
    num? previousClose,
    num? change,
    num? changePercent,
  }) = _StockQuote;
}
