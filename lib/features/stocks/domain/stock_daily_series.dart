import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_daily_series.freezed.dart';

@freezed
abstract class StockDailyPoint with _$StockDailyPoint {
  const factory StockDailyPoint({
    required DateTime date,
    num? open,
    num? high,
    num? low,
    num? close,
    int? volume,
  }) = _StockDailyPoint;
}

@freezed
abstract class StockDailySeries with _$StockDailySeries {
  const factory StockDailySeries({
    required String symbol,
    required List<StockDailyPoint> dataPoints,
  }) = _StockDailySeries;
}
