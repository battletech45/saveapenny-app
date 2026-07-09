import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
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
import 'package:saveapenny/features/stocks/data/stocks_api.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';
import 'package:saveapenny/features/stocks/domain/stocks_repository.dart';

part 'stocks_repository.g.dart';

class StocksRepositoryImpl implements StocksRepository {
  const StocksRepositoryImpl(this._stocksApi);

  final StocksApi _stocksApi;

  @override
  Future<StockQuote> quote(String symbol) async {
    final response = await _stocksApi.quote(symbol);
    return response.toDomain();
  }

  @override
  Future<StockDailySeries> dailySeries(
    String symbol, {
    String outputSize = 'compact',
  }) async {
    final response = await _stocksApi.dailySeries(
      symbol,
      outputSize: outputSize,
    );
    return response.toDomain();
  }

  @override
  Future<StockNews> news(String symbol) async {
    final response = await _stocksApi.news(symbol);
    return response.toDomain();
  }

  @override
  Future<StockOverview> overview(String symbol) async {
    final response = await _stocksApi.overview(symbol);
    return response.toDomain();
  }

  @override
  Future<StockFinancialStatement> incomeStatement(String symbol) async {
    final response = await _stocksApi.incomeStatement(symbol);
    return response.toDomain();
  }

  @override
  Future<StockFinancialStatement> balanceSheet(String symbol) async {
    final response = await _stocksApi.balanceSheet(symbol);
    return response.toDomain();
  }

  @override
  Future<StockFinancialStatement> cashFlow(String symbol) async {
    final response = await _stocksApi.cashFlow(symbol);
    return response.toDomain();
  }

  @override
  Future<StockTechnicalIndicator> sma({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final response = await _stocksApi.sma(
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
    return response.toDomain();
  }

  @override
  Future<StockTechnicalIndicator> ema({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final response = await _stocksApi.ema(
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
    return response.toDomain();
  }

  @override
  Future<StockTechnicalIndicator> rsi({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) async {
    final response = await _stocksApi.rsi(
      symbol: symbol,
      timePeriod: timePeriod,
      interval: interval,
      seriesType: seriesType,
    );
    return response.toDomain();
  }

  @override
  Future<PaginatedData<StockHolding>> listHoldings({
    int page = 0,
    int size = 20,
    String sort = 'purchaseDate,desc',
  }) async {
    final response = await _stocksApi.listHoldings(
      page: page,
      size: size,
      sort: sort,
    );

    return PaginatedData<StockHolding>(
      items: response.items
          .map((StockHoldingResponse item) => item.toDomain())
          .toList(growable: false),
      page: response.page,
      size: response.size,
      totalItems: response.totalItems,
      totalPages: response.totalPages,
      hasNext: response.hasNext,
      hasPrevious: response.hasPrevious,
    );
  }

  @override
  Future<StockHoldingSummary> holdingSummary() async {
    final response = await _stocksApi.holdingSummary();
    return response.toDomain();
  }

  @override
  Future<StockHolding> getHolding(String holdingId) async {
    final response = await _stocksApi.getHolding(holdingId);
    return response.toDomain();
  }

  @override
  Future<StockHolding> createHolding({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    final response = await _stocksApi.createHolding(
      CreateStockHoldingRequest(
        symbol: symbol,
        quantity: quantity.toString(),
        purchasePrice: purchasePrice.toString(),
        currency: currency,
        purchaseDate: purchaseDate.toIso8601String().split('T').first,
        notes: notes,
      ),
    );
    return response.toDomain();
  }

  @override
  Future<StockHolding> updateHolding({
    required String holdingId,
    num? quantity,
    num? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    String? notes,
  }) async {
    final response = await _stocksApi.updateHolding(
      holdingId: holdingId,
      request: UpdateStockHoldingRequest(
        quantity: quantity?.toString(),
        purchasePrice: purchasePrice?.toString(),
        currency: currency,
        purchaseDate: purchaseDate?.toIso8601String().split('T').first,
        notes: notes,
      ),
    );
    return response.toDomain();
  }

  @override
  Future<void> deleteHolding(String holdingId) {
    return _stocksApi.deleteHolding(holdingId);
  }
}

@Riverpod(keepAlive: true)
StocksRepository stocksRepository(Ref ref) {
  return StocksRepositoryImpl(ref.watch(stocksApiProvider));
}
