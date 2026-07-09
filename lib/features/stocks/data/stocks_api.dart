import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/stocks/data/dto/create_stock_holding_request.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_daily_series_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_financial_statement_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_holding_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_holding_summary_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_news_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_overview_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_quote_response.dart';
import 'package:saveapenny/features/stocks/data/dto/stock_technical_indicator_response.dart';
import 'package:saveapenny/features/stocks/data/dto/update_stock_holding_request.dart';

part 'stocks_api.g.dart';

class StocksApi {
  const StocksApi(this._apiClient);

  final ApiClient _apiClient;

  Future<StockQuoteResponse> quote(String symbol) {
    return _apiClient.send<StockQuoteResponse>(
      call: (dio) => dio.get<dynamic>(
        '/stocks/quote',
        queryParameters: <String, Object?>{'symbol': symbol},
      ),
      fromData: (data) => StockQuoteResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockDailySeriesResponse> dailySeries(
    String symbol, {
    String outputSize = 'compact',
  }) {
    return _apiClient.send<StockDailySeriesResponse>(
      call: (dio) => dio.get<dynamic>(
        '/stocks/daily',
        queryParameters: <String, Object?>{
          'symbol': symbol,
          'outputSize': outputSize,
        },
      ),
      fromData: (data) => StockDailySeriesResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockNewsResponse> news(String symbol) {
    return _apiClient.send<StockNewsResponse>(
      call: (dio) => dio.get<dynamic>(
        '/stocks/news',
        queryParameters: <String, Object?>{'symbol': symbol},
      ),
      fromData: (data) => StockNewsResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockOverviewResponse> overview(String symbol) {
    return _apiClient.send<StockOverviewResponse>(
      call: (dio) => dio.get<dynamic>(
        '/stocks/overview',
        queryParameters: <String, Object?>{'symbol': symbol},
      ),
      fromData: (data) => StockOverviewResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockFinancialStatementResponse> incomeStatement(String symbol) {
    return _statement('/stocks/income-statement', symbol);
  }

  Future<StockFinancialStatementResponse> balanceSheet(String symbol) {
    return _statement('/stocks/balance-sheet', symbol);
  }

  Future<StockFinancialStatementResponse> cashFlow(String symbol) {
    return _statement('/stocks/cash-flow', symbol);
  }

  Future<StockTechnicalIndicatorResponse> sma({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return _indicator(
      '/stocks/sma',
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
  }

  Future<StockTechnicalIndicatorResponse> ema({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return _indicator(
      '/stocks/ema',
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
  }

  Future<StockTechnicalIndicatorResponse> rsi({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return _indicator(
      '/stocks/rsi',
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
  }

  Future<PaginatedData<StockHoldingResponse>> listHoldings({
    int page = 0,
    int size = 20,
    String sort = 'purchaseDate,desc',
  }) {
    return _apiClient.send<PaginatedData<StockHoldingResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/stocks/holdings',
        queryParameters: <String, Object?>{
          'page': page,
          'size': size,
          'sort': sort,
        },
      ),
      fromData: (data) => PaginatedData<StockHoldingResponse>.fromJson(
        _readJsonMap(data),
        (item) => StockHoldingResponse.fromJson(_readJsonMap(item)),
      ),
    );
  }

  Future<StockHoldingSummaryResponse> holdingSummary() {
    return _apiClient.send<StockHoldingSummaryResponse>(
      call: (dio) => dio.get<dynamic>('/stocks/holdings/summary'),
      fromData: (data) =>
          StockHoldingSummaryResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockHoldingResponse> getHolding(String holdingId) {
    return _apiClient.send<StockHoldingResponse>(
      call: (dio) => dio.get<dynamic>('/stocks/holdings/$holdingId'),
      fromData: (data) => StockHoldingResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockHoldingResponse> createHolding(
    CreateStockHoldingRequest request,
  ) {
    return _apiClient.send<StockHoldingResponse>(
      call: (dio) =>
          dio.post<dynamic>('/stocks/holdings', data: request.toJson()),
      fromData: (data) => StockHoldingResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockHoldingResponse> updateHolding({
    required String holdingId,
    required UpdateStockHoldingRequest request,
  }) {
    return _apiClient.send<StockHoldingResponse>(
      call: (dio) => dio.put<dynamic>(
        '/stocks/holdings/$holdingId',
        data: request.toJson(),
      ),
      fromData: (data) => StockHoldingResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<void> deleteHolding(String holdingId) {
    return _apiClient.send<void>(
      call: (dio) => dio.delete<dynamic>('/stocks/holdings/$holdingId'),
      fromData: (_) {},
    );
  }

  Future<StockFinancialStatementResponse> _statement(
    String path,
    String symbol,
  ) {
    return _apiClient.send<StockFinancialStatementResponse>(
      call: (dio) => dio.get<dynamic>(
        path,
        queryParameters: <String, Object?>{'symbol': symbol},
      ),
      fromData: (data) =>
          StockFinancialStatementResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<StockTechnicalIndicatorResponse> _indicator(
    String path, {
    required String symbol,
    required int timePeriod,
    required String interval,
    required String seriesType,
  }) {
    return _apiClient.send<StockTechnicalIndicatorResponse>(
      call: (dio) => dio.get<dynamic>(
        path,
        queryParameters: <String, Object?>{
          'symbol': symbol,
          'timePeriod': timePeriod.toString(),
          'interval': interval,
          'seriesType': seriesType,
        },
      ),
      fromData: (data) =>
          StockTechnicalIndicatorResponse.fromJson(_readJsonMap(data)),
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
StocksApi stocksApi(Ref ref) {
  return StocksApi(ref.watch(apiClientProvider));
}
