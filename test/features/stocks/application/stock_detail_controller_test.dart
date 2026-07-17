import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/stocks/application/stock_detail_controller.dart';
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
    required this.onQuote,
    this.onOverview,
    this.onDailySeries,
    this.onNews,
  });

  final Future<StockQuote> Function(String symbol) onQuote;
  final Future<StockOverview> Function(String symbol)? onOverview;
  final Future<StockDailySeries> Function(String symbol)? onDailySeries;
  final Future<StockNews> Function(String symbol)? onNews;

  @override
  Future<StockQuote> quote(String symbol) => onQuote(symbol);

  @override
  Future<StockOverview> overview(String symbol) {
    return onOverview == null
        ? Future<StockOverview>.error(const Failure.unknown())
        : onOverview!(symbol);
  }

  @override
  Future<StockDailySeries> dailySeries(
    String symbol, {
    String outputSize = 'compact',
  }) {
    return onDailySeries == null
        ? Future<StockDailySeries>.error(const Failure.unknown())
        : onDailySeries!(symbol);
  }

  @override
  Future<StockNews> news(String symbol) {
    return onNews == null
        ? Future<StockNews>.error(const Failure.unknown())
        : onNews!(symbol);
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

StockQuote _quote() => const StockQuote(symbol: 'IBM', price: 175);

void main() {
  test('build loads the quote and optional sections', () async {
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onQuote: (symbol) async => _quote(),
            onOverview: (symbol) async =>
                const StockOverview(symbol: 'IBM', name: 'IBM Corp'),
            onDailySeries: (symbol) async =>
                const StockDailySeries(symbol: 'IBM', dataPoints: []),
            onNews: (symbol) async => const StockNews(items: 0, articles: []),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(
      stockDetailControllerProvider('IBM').future,
    );

    expect(state.quote.symbol, 'IBM');
    expect(state.overview?.name, 'IBM Corp');
    expect(state.dailySeries?.symbol, 'IBM');
    expect(state.news?.items, 0);
  });

  test(
    'a rate-limited optional section is swallowed and reported as null',
    () async {
      final container = ProviderContainer(
        overrides: [
          stocksRepositoryProvider.overrideWith(
            (ref) => _FakeStocksRepository(
              onQuote: (symbol) async => _quote(),
              onOverview: (symbol) => Future<StockOverview>.error(
                const Failure.rateLimited(
                  code: ApiErrorCode.stockRateLimitExceeded,
                ),
              ),
              onDailySeries: (symbol) async =>
                  const StockDailySeries(symbol: 'IBM', dataPoints: []),
              onNews: (symbol) async => const StockNews(items: 0, articles: []),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        stockDetailControllerProvider('IBM').future,
      );

      expect(state.overview, isNull);
      expect(state.dailySeries, isNotNull);
    },
  );

  test(
    'an unavailable-quote optional section is swallowed and reported as null',
    () async {
      final container = ProviderContainer(
        overrides: [
          stocksRepositoryProvider.overrideWith(
            (ref) => _FakeStocksRepository(
              onQuote: (symbol) async => _quote(),
              onOverview: (symbol) async => const StockOverview(symbol: 'IBM'),
              onDailySeries: (symbol) => Future<StockDailySeries>.error(
                const Failure.api(
                  code: ApiErrorCode.stockQuoteNotAvailable,
                  message: 'No data',
                ),
              ),
              onNews: (symbol) async => const StockNews(items: 0, articles: []),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        stockDetailControllerProvider('IBM').future,
      );

      expect(state.dailySeries, isNull);
    },
  );

  test(
    'an unrelated optional-section failure rethrows into AsyncError',
    () async {
      // Disable Riverpod's default build-error retry/backoff so the failure
      // surfaces on the first attempt instead of being retried indefinitely.
      final container = ProviderContainer(
        retry: (retryCount, error) => null,
        overrides: [
          stocksRepositoryProvider.overrideWith(
            (ref) => _FakeStocksRepository(
              onQuote: (symbol) async => _quote(),
              onOverview: (symbol) async => const StockOverview(symbol: 'IBM'),
              onDailySeries: (symbol) async =>
                  const StockDailySeries(symbol: 'IBM', dataPoints: []),
              onNews: (symbol) => Future<StockNews>.error(
                const Failure.api(
                  code: ApiErrorCode.validationFailed,
                  message: 'Bad request',
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(stockDetailControllerProvider('IBM').future),
        throwsA(isA<ApiFailure>()),
      );
    },
  );

  test('refresh reloads the detail state', () async {
    var callCount = 0;
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FakeStocksRepository(
            onQuote: (symbol) async {
              callCount += 1;
              return StockQuote(symbol: symbol, price: 100 + callCount);
            },
            onOverview: (symbol) async => const StockOverview(symbol: 'IBM'),
            onDailySeries: (symbol) async =>
                const StockDailySeries(symbol: 'IBM', dataPoints: []),
            onNews: (symbol) async => const StockNews(items: 0, articles: []),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(stockDetailControllerProvider('IBM').future);
    await container
        .read(stockDetailControllerProvider('IBM').notifier)
        .refresh();

    final state = container.read(stockDetailControllerProvider('IBM')).value;
    expect(state?.quote.price, 102);
    expect(callCount, 2);
  });
}
