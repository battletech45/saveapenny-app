import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/stocks/application/stock_indicators_controller.dart';
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

typedef _IndicatorCall = ({String symbol, int timePeriod});

class _FakeStocksRepository implements StocksRepository {
  _FakeStocksRepository({this.onSma, this.onEma, this.onRsi});

  final Future<StockTechnicalIndicator> Function(_IndicatorCall call)? onSma;
  final Future<StockTechnicalIndicator> Function(_IndicatorCall call)? onEma;
  final Future<StockTechnicalIndicator> Function(_IndicatorCall call)? onRsi;

  @override
  Future<StockTechnicalIndicator> sma({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return onSma!((symbol: symbol, timePeriod: timePeriod));
  }

  @override
  Future<StockTechnicalIndicator> ema({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return onEma!((symbol: symbol, timePeriod: timePeriod));
  }

  @override
  Future<StockTechnicalIndicator> rsi({
    required String symbol,
    required int timePeriod,
    String interval = 'daily',
    String seriesType = 'close',
  }) {
    return onRsi!((symbol: symbol, timePeriod: timePeriod));
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
  Future<StockHolding> getHolding(String holdingId) {
    throw UnimplementedError();
  }

  @override
  Future<StockHoldingSummary> holdingSummary() {
    throw UnimplementedError();
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

StockTechnicalIndicator _indicator(String symbol, String name) {
  return StockTechnicalIndicator(
    symbol: symbol,
    indicator: name,
    dataPoints: const [],
  );
}

void main() {
  test('build requests SMA with the default 20-period window', () async {
    _IndicatorCall? capturedCall;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onSma: (call) async {
              capturedCall = call;
              return _indicator(call.symbol, 'SMA');
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final indicator = await container.read(
      stockIndicatorControllerProvider('IBM', StockIndicatorType.sma).future,
    );

    expect(indicator.indicator, 'SMA');
    expect(capturedCall, (symbol: 'IBM', timePeriod: 20));
  });

  test('build requests EMA with the default 20-period window', () async {
    _IndicatorCall? capturedCall;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onEma: (call) async {
              capturedCall = call;
              return _indicator(call.symbol, 'EMA');
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final indicator = await container.read(
      stockIndicatorControllerProvider('IBM', StockIndicatorType.ema).future,
    );

    expect(indicator.indicator, 'EMA');
    expect(capturedCall, (symbol: 'IBM', timePeriod: 20));
  });

  test('build requests RSI with the default 14-period window', () async {
    _IndicatorCall? capturedCall;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onRsi: (call) async {
              capturedCall = call;
              return _indicator(call.symbol, 'RSI');
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final indicator = await container.read(
      stockIndicatorControllerProvider('IBM', StockIndicatorType.rsi).future,
    );

    expect(indicator.indicator, 'RSI');
    expect(capturedCall, (symbol: 'IBM', timePeriod: 14));
  });

  test('a repository failure surfaces as an AsyncError', () async {
    // Disable Riverpod's default build-error retry/backoff so the failure
    // surfaces on the first attempt instead of being retried indefinitely.
    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onSma: (call) => Future<StockTechnicalIndicator>.error(
              const Failure.rateLimited(
                code: ApiErrorCode.stockRateLimitExceeded,
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(
        stockIndicatorControllerProvider('IBM', StockIndicatorType.sma).future,
      ),
      throwsA(isA<RateLimitedFailure>()),
    );
  });

  test('refresh reloads the indicator', () async {
    var callCount = 0;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onSma: (call) async {
              callCount += 1;
              return StockTechnicalIndicator(
                symbol: call.symbol,
                indicator: 'SMA-$callCount',
                dataPoints: const [],
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(
      stockIndicatorControllerProvider('IBM', StockIndicatorType.sma).future,
    );
    await container
        .read(
          stockIndicatorControllerProvider(
            'IBM',
            StockIndicatorType.sma,
          ).notifier,
        )
        .refresh();

    final state = container
        .read(stockIndicatorControllerProvider('IBM', StockIndicatorType.sma))
        .value;
    expect(state?.indicator, 'SMA-2');
    expect(callCount, 2);
  });
}
