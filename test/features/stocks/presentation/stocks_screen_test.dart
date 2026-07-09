import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
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
import 'package:saveapenny/features/stocks/presentation/stocks_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FailingStocksRepository implements StocksRepository {
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
    return Future<StockHoldingSummary>.error(
      const Failure.api(code: ApiErrorCode.stockDisabled, message: 'Disabled.'),
    );
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
    return Future<PaginatedData<StockHolding>>.error(
      const Failure.api(code: ApiErrorCode.stockDisabled, message: 'Disabled.'),
    );
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

void main() {
  testWidgets('stocks screen shows feature-disabled copy', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        stocksRepositoryProvider.overrideWith(
          (ref) => _FailingStocksRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const StocksScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feature unavailable'), findsOneWidget);
    expect(
      find.text('This feature is currently disabled on the server.'),
      findsOneWidget,
    );
  });
}
