import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/stocks/application/stock_holdings_controller.dart';
import 'package:saveapenny/features/stocks/data/stocks_repository.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';
import 'package:saveapenny/features/stocks/domain/stocks_repository.dart';

class _FakeStocksRepository implements StocksRepository {
  _FakeStocksRepository({
    this.onListHoldings,
    this.onHoldingSummary,
    this.onCreateHolding,
  });

  final Future<PaginatedData<StockHolding>> Function()? onListHoldings;
  final Future<StockHoldingSummary> Function()? onHoldingSummary;
  final Future<StockHolding> Function({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  })?
  onCreateHolding;

  @override
  Future<StockHolding> createHolding({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  }) {
    return onCreateHolding!(
      symbol: symbol,
      quantity: quantity,
      purchasePrice: purchasePrice,
      currency: currency,
      purchaseDate: purchaseDate,
      notes: notes,
    );
  }

  @override
  Future<StockFinancialStatement> balanceSheet(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<StockFinancialStatement> cashFlow(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteHolding(String holdingId) {
    throw UnimplementedError();
  }

  @override
  Future<StockDailySeries> dailySeries(
    String symbol, {
    String outputSize = 'compact',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StockTechnicalIndicator> ema({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StockHolding> getHolding(String holdingId) {
    throw UnimplementedError();
  }

  @override
  Future<StockHoldingSummary> holdingSummary() {
    return onHoldingSummary!();
  }

  @override
  Future<StockFinancialStatement> incomeStatement(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<StockHolding>> listHoldings({
    int page = 0,
    int size = 20,
    String sort = 'purchaseDate,desc',
  }) {
    return onListHoldings!();
  }

  @override
  Future<StockNews> news(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<StockOverview> overview(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<StockQuote> quote(String symbol) {
    throw UnimplementedError();
  }

  @override
  Future<StockTechnicalIndicator> rsi({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StockTechnicalIndicator> sma({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StockHolding> updateHolding({
    required String holdingId,
    num? quantity,
    num? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    String? notes,
  }) {
    throw UnimplementedError();
  }
}

StockHolding _holding({required String id}) {
  return StockHolding(
    id: id,
    symbol: 'IBM',
    quantity: 7.14285714,
    purchasePrice: 140,
    currency: 'USD',
    purchaseDate: DateTime.parse('2025-04-25T00:00:00Z'),
    notes: 'First position',
    investedAmount: 1000,
    currentPrice: 175,
    currentValue: 1250,
    profitLoss: 250,
    profitLossPercent: 25,
    latestTradingDay: DateTime.parse('2026-06-20T00:00:00Z'),
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-10T12:00:00Z'),
  );
}

StockHoldingSummary _summary(List<StockHolding> holdings) {
  return StockHoldingSummary(
    totalInvested: 1000,
    totalCurrentValue: 1250,
    totalProfitLoss: 250,
    totalProfitLossPercent: 25,
    holdingCount: holdings.length,
    holdings: holdings,
  );
}

PaginatedData<StockHolding> _page(List<StockHolding> items) {
  return PaginatedData<StockHolding>(
    items: items,
    page: 0,
    size: 20,
    totalItems: items.length,
    totalPages: 1,
    hasNext: false,
    hasPrevious: false,
  );
}

void main() {
  test('build loads the first holdings page and summary', () async {
    final existing = _holding(id: 'h-1');

    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onListHoldings: () async => _page(<StockHolding>[existing]),
            onHoldingSummary: () async => _summary(<StockHolding>[existing]),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(stockHoldingsControllerProvider.future);

    expect(state.items.single, existing);
    expect(state.summary.holdingCount, 1);
  });

  test('create preserves current list when the mutation fails', () async {
    final existing = _holding(id: 'h-1');

    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onListHoldings: () async => _page(<StockHolding>[existing]),
            onHoldingSummary: () async => _summary(<StockHolding>[existing]),
            onCreateHolding:
                ({
                  required symbol,
                  required quantity,
                  required purchasePrice,
                  required currency,
                  required purchaseDate,
                  notes,
                }) => Future<StockHolding>.error(
                  const Failure.api(
                    code: ApiErrorCode.duplicateStockHolding,
                    message: 'Duplicate holding.',
                  ),
                ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(stockHoldingsControllerProvider.future);

    await expectLater(
      container
          .read(stockHoldingsControllerProvider.notifier)
          .createHolding(
            symbol: 'IBM',
            quantity: 1,
            purchasePrice: 140,
            currency: 'USD',
            purchaseDate: DateTime.parse('2025-04-25T00:00:00Z'),
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(stockHoldingsControllerProvider).value?.items.single,
      existing,
    );
  });
}
