import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/stocks/application/stock_financials_controller.dart';
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
    this.onIncomeStatement,
    this.onBalanceSheet,
    this.onCashFlow,
  });

  final Future<StockFinancialStatement> Function(String symbol)?
  onIncomeStatement;
  final Future<StockFinancialStatement> Function(String symbol)? onBalanceSheet;
  final Future<StockFinancialStatement> Function(String symbol)? onCashFlow;

  @override
  Future<StockFinancialStatement> incomeStatement(String symbol) {
    return onIncomeStatement!(symbol);
  }

  @override
  Future<StockFinancialStatement> balanceSheet(String symbol) {
    return onBalanceSheet!(symbol);
  }

  @override
  Future<StockFinancialStatement> cashFlow(String symbol) {
    return onCashFlow!(symbol);
  }

  @override
  Future<StockHolding> createHolding({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  }) {
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
  Future<void> deleteHolding(String holdingId) {
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
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<StockHolding>> listHoldings({
    int page = 0,
    int size = 20,
    String sort = 'purchaseDate,desc',
  }) {
    throw UnimplementedError();
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

StockFinancialStatement _statement(String symbol) {
  return StockFinancialStatement(
    symbol: symbol,
    annualReports: const [],
    quarterlyReports: const [],
  );
}

void main() {
  test('build routes incomeStatement to the repository method', () async {
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onIncomeStatement: (symbol) async => _statement(symbol),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final statement = await container.read(
      stockFinancialStatementControllerProvider(
        'IBM',
        StockFinancialStatementType.incomeStatement,
      ).future,
    );

    expect(statement.symbol, 'IBM');
  });

  test('build routes balanceSheet to the repository method', () async {
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onBalanceSheet: (symbol) async => _statement(symbol),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final statement = await container.read(
      stockFinancialStatementControllerProvider(
        'IBM',
        StockFinancialStatementType.balanceSheet,
      ).future,
    );

    expect(statement.symbol, 'IBM');
  });

  test('build routes cashFlow to the repository method', () async {
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onCashFlow: (symbol) async => _statement(symbol),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final statement = await container.read(
      stockFinancialStatementControllerProvider(
        'IBM',
        StockFinancialStatementType.cashFlow,
      ).future,
    );

    expect(statement.symbol, 'IBM');
  });

  test('a repository failure surfaces as an AsyncError', () async {
    // Disable Riverpod's default build-error retry/backoff so the failure
    // surfaces on the first attempt instead of being retried indefinitely.
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onIncomeStatement: (symbol) =>
                Future<StockFinancialStatement>.error(
                  const Failure.api(
                    code: ApiErrorCode.stockProviderError,
                    message: 'Upstream failure',
                  ),
                ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(
        stockFinancialStatementControllerProvider(
          'IBM',
          StockFinancialStatementType.incomeStatement,
        ).future,
      ),
      throwsA(isA<ApiFailure>()),
    );
  });

  test('refresh reloads the financial statement', () async {
    var callCount = 0;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onIncomeStatement: (symbol) async {
              callCount += 1;
              return StockFinancialStatement(
                symbol: symbol,
                annualReports: [
                  StockFinancialReportItem(
                    fiscalDateEnding: '2025-12-31',
                    fields: {'callCount': '$callCount'},
                  ),
                ],
                quarterlyReports: const [],
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(
      stockFinancialStatementControllerProvider(
        'IBM',
        StockFinancialStatementType.incomeStatement,
      ).future,
    );
    await container
        .read(
          stockFinancialStatementControllerProvider(
            'IBM',
            StockFinancialStatementType.incomeStatement,
          ).notifier,
        )
        .refresh();

    final state = container
        .read(
          stockFinancialStatementControllerProvider(
            'IBM',
            StockFinancialStatementType.incomeStatement,
          ),
        )
        .value;
    expect(state?.annualReports.single.fields['callCount'], '2');
    expect(callCount, 2);
  });
}
