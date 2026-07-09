import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';

part 'stock_overview_response.freezed.dart';
part 'stock_overview_response.g.dart';

@freezed
abstract class StockOverviewResponse with _$StockOverviewResponse {
  const factory StockOverviewResponse({
    required String symbol,
    String? name,
    String? description,
    String? exchange,
    String? currency,
    String? country,
    String? sector,
    String? industry,
    @JsonKey(fromJson: stockNumOrNull) num? marketCapitalization,
    @JsonKey(fromJson: stockNumOrNull) num? ebitda,
    @JsonKey(fromJson: stockNumOrNull) num? peRatio,
    @JsonKey(fromJson: stockNumOrNull) num? pegRatio,
    @JsonKey(fromJson: stockNumOrNull) num? bookValue,
    @JsonKey(fromJson: stockNumOrNull) num? dividendPerShare,
    @JsonKey(fromJson: stockNumOrNull) num? dividendYield,
    @JsonKey(fromJson: stockNumOrNull) num? eps,
    @JsonKey(fromJson: stockNumOrNull) num? revenuePerShareTTM,
    @JsonKey(fromJson: stockNumOrNull) num? profitMargin,
    @JsonKey(fromJson: stockNumOrNull) num? operatingMarginTTM,
    @JsonKey(fromJson: stockNumOrNull) num? returnOnAssetsTTM,
    @JsonKey(fromJson: stockNumOrNull) num? returnOnEquityTTM,
    @JsonKey(fromJson: stockNumOrNull) num? revenueTTM,
    @JsonKey(fromJson: stockNumOrNull) num? grossProfitTTM,
    @JsonKey(fromJson: stockNumOrNull) num? dilutedEpsTTM,
    @JsonKey(fromJson: stockNumOrNull) num? quarterlyEarningsGrowthYOY,
    @JsonKey(fromJson: stockNumOrNull) num? quarterlyRevenueGrowthYOY,
    @JsonKey(fromJson: stockNumOrNull) num? analystTargetPrice,
    @JsonKey(fromJson: stockNumOrNull) num? trailingPE,
    @JsonKey(fromJson: stockNumOrNull) num? forwardPE,
    @JsonKey(fromJson: stockNumOrNull) num? priceToSalesRatioTTM,
    @JsonKey(fromJson: stockNumOrNull) num? priceToBookRatio,
    @JsonKey(fromJson: stockNumOrNull) num? evToRevenue,
    @JsonKey(fromJson: stockNumOrNull) num? evToEBITDA,
    @JsonKey(fromJson: stockNumOrNull) num? beta,
    @JsonKey(name: 'weekHigh52', fromJson: stockNumOrNull) num? weekHigh52,
    @JsonKey(name: 'weekLow52', fromJson: stockNumOrNull) num? weekLow52,
    @JsonKey(fromJson: stockNumOrNull) num? movingAverage50Day,
    @JsonKey(fromJson: stockNumOrNull) num? movingAverage200Day,
    @JsonKey(fromJson: stockIntOrNull) int? sharesOutstanding,
    String? dividendDate,
    String? exDividendDate,
  }) = _StockOverviewResponse;

  factory StockOverviewResponse.fromJson(Map<String, dynamic> json) =>
      _$StockOverviewResponseFromJson(json);
}

extension StockOverviewResponseX on StockOverviewResponse {
  StockOverview toDomain() {
    return StockOverview(
      symbol: symbol,
      name: name,
      description: description,
      exchange: exchange,
      currency: currency,
      country: country,
      sector: sector,
      industry: industry,
      marketCapitalization: marketCapitalization,
      ebitda: ebitda,
      peRatio: peRatio,
      pegRatio: pegRatio,
      bookValue: bookValue,
      dividendPerShare: dividendPerShare,
      dividendYield: dividendYield,
      eps: eps,
      revenuePerShareTTM: revenuePerShareTTM,
      profitMargin: profitMargin,
      operatingMarginTTM: operatingMarginTTM,
      returnOnAssetsTTM: returnOnAssetsTTM,
      returnOnEquityTTM: returnOnEquityTTM,
      revenueTTM: revenueTTM,
      grossProfitTTM: grossProfitTTM,
      dilutedEpsTTM: dilutedEpsTTM,
      quarterlyEarningsGrowthYOY: quarterlyEarningsGrowthYOY,
      quarterlyRevenueGrowthYOY: quarterlyRevenueGrowthYOY,
      analystTargetPrice: analystTargetPrice,
      trailingPE: trailingPE,
      forwardPE: forwardPE,
      priceToSalesRatioTTM: priceToSalesRatioTTM,
      priceToBookRatio: priceToBookRatio,
      evToRevenue: evToRevenue,
      evToEBITDA: evToEBITDA,
      beta: beta,
      weekHigh52: weekHigh52,
      weekLow52: weekLow52,
      movingAverage50Day: movingAverage50Day,
      movingAverage200Day: movingAverage200Day,
      sharesOutstanding: sharesOutstanding,
      dividendDate: dividendDate,
      exDividendDate: exDividendDate,
    );
  }
}
