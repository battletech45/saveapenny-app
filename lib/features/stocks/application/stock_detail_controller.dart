import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/stocks/data/stocks_repository.dart';
import 'package:saveapenny/features/stocks/domain/stock_daily_series.dart';
import 'package:saveapenny/features/stocks/domain/stock_news.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/domain/stock_quote.dart';

part 'stock_detail_controller.freezed.dart';
part 'stock_detail_controller.g.dart';

@freezed
abstract class StockDetailState with _$StockDetailState {
  const factory StockDetailState({
    required StockQuote quote,
    StockOverview? overview,
    StockDailySeries? dailySeries,
    StockNews? news,
  }) = _StockDetailState;
}

@riverpod
class StockDetailController extends _$StockDetailController {
  @override
  Future<StockDetailState> build(String symbol) {
    return _fetch(symbol);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(symbol));
  }

  Future<StockDetailState> _fetch(String symbol) async {
    final repository = ref.read(stocksRepositoryProvider);
    final quote = await repository.quote(symbol);

    final results = await Future.wait<Object?>(<Future<Object?>>[
      _optionalSection(() => repository.overview(symbol)),
      _optionalSection(() => repository.dailySeries(symbol)),
      _optionalSection(() => repository.news(symbol)),
    ]);

    return StockDetailState(
      quote: quote,
      overview: results[0] as StockOverview?,
      dailySeries: results[1] as StockDailySeries?,
      news: results[2] as StockNews?,
    );
  }

  Future<T?> _optionalSection<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on RateLimitedFailure {
      return null;
    } on ApiFailure catch (failure) {
      if (failure.code == ApiErrorCode.stockQuoteNotAvailable ||
          failure.code == ApiErrorCode.stockProviderError) {
        return null;
      }
      rethrow;
    }
  }
}
