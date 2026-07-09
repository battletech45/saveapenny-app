import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';

part 'stock_daily_series_response.freezed.dart';
part 'stock_daily_series_response.g.dart';

@freezed
abstract class DailyPointResponse with _$DailyPointResponse {
  const factory DailyPointResponse({
    @JsonKey(fromJson: stockDate) required DateTime date,
    @JsonKey(fromJson: stockNumOrNull) num? open,
    @JsonKey(fromJson: stockNumOrNull) num? high,
    @JsonKey(fromJson: stockNumOrNull) num? low,
    @JsonKey(fromJson: stockNumOrNull) num? close,
    @JsonKey(fromJson: stockIntOrNull) int? volume,
  }) = _DailyPointResponse;

  factory DailyPointResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyPointResponseFromJson(json);
}

@freezed
abstract class StockDailySeriesResponse with _$StockDailySeriesResponse {
  const factory StockDailySeriesResponse({
    required String symbol,
    required List<DailyPointResponse> dataPoints,
  }) = _StockDailySeriesResponse;

  factory StockDailySeriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StockDailySeriesResponseFromJson(json);
}

extension DailyPointResponseX on DailyPointResponse {
  StockDailyPoint toDomain() {
    return StockDailyPoint(
      date: date,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    );
  }
}

extension StockDailySeriesResponseX on StockDailySeriesResponse {
  StockDailySeries toDomain() {
    return StockDailySeries(
      symbol: symbol,
      dataPoints: dataPoints
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }
}
