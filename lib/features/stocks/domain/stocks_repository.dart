import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';

abstract interface class StocksRepository {
  Future<StockQuote> quote(String symbol);

  Future<StockDailySeries> dailySeries(
    String symbol, {
    String outputSize = 'compact',
  });

  Future<StockNews> news(String symbol);

  Future<StockOverview> overview(String symbol);

  Future<StockFinancialStatement> incomeStatement(String symbol);

  Future<StockFinancialStatement> balanceSheet(String symbol);

  Future<StockFinancialStatement> cashFlow(String symbol);

  Future<StockTechnicalIndicator> sma({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  });

  Future<StockTechnicalIndicator> ema({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  });

  Future<StockTechnicalIndicator> rsi({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  });

  Future<PaginatedData<StockHolding>> listHoldings({
    int page = 0,
    int size = 20,
    String sort = 'purchaseDate,desc',
  });

  Future<StockHoldingSummary> holdingSummary();

  Future<StockHolding> getHolding(String holdingId);

  Future<StockHolding> createHolding({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  });

  Future<StockHolding> updateHolding({
    required String holdingId,
    num? quantity,
    num? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    String? notes,
  });

  Future<void> deleteHolding(String holdingId);
}
