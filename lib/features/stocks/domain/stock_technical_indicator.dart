import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_technical_indicator.freezed.dart';

@freezed
abstract class StockTechnicalIndicatorPoint
    with _$StockTechnicalIndicatorPoint {
  const factory StockTechnicalIndicatorPoint({
    required DateTime date,
    num? value,
  }) = _StockTechnicalIndicatorPoint;
}

@freezed
abstract class StockTechnicalIndicator with _$StockTechnicalIndicator {
  const factory StockTechnicalIndicator({
    required String symbol,
    required String indicator,
    required List<StockTechnicalIndicatorPoint> dataPoints,
  }) = _StockTechnicalIndicator;
}
