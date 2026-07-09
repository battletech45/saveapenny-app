import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';

part 'stock_technical_indicator_response.freezed.dart';
part 'stock_technical_indicator_response.g.dart';

@freezed
abstract class TechnicalIndicatorDataPointResponse
    with _$TechnicalIndicatorDataPointResponse {
  const factory TechnicalIndicatorDataPointResponse({
    @JsonKey(fromJson: stockDate) required DateTime date,
    @JsonKey(fromJson: stockNumOrNull) num? value,
  }) = _TechnicalIndicatorDataPointResponse;

  factory TechnicalIndicatorDataPointResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$TechnicalIndicatorDataPointResponseFromJson(json);
}

@freezed
abstract class StockTechnicalIndicatorResponse
    with _$StockTechnicalIndicatorResponse {
  const factory StockTechnicalIndicatorResponse({
    required String symbol,
    required String indicator,
    required List<TechnicalIndicatorDataPointResponse> dataPoints,
  }) = _StockTechnicalIndicatorResponse;

  factory StockTechnicalIndicatorResponse.fromJson(Map<String, dynamic> json) =>
      _$StockTechnicalIndicatorResponseFromJson(json);
}

extension TechnicalIndicatorDataPointResponseX
    on TechnicalIndicatorDataPointResponse {
  StockTechnicalIndicatorPoint toDomain() {
    return StockTechnicalIndicatorPoint(date: date, value: value);
  }
}

extension StockTechnicalIndicatorResponseX on StockTechnicalIndicatorResponse {
  StockTechnicalIndicator toDomain() {
    return StockTechnicalIndicator(
      symbol: symbol,
      indicator: indicator,
      dataPoints: dataPoints
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }
}
