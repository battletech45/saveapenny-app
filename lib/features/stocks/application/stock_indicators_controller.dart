import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/stocks/data/stocks_repository.dart';
import 'package:saveapenny/features/stocks/domain/stock_technical_indicator.dart';

part 'stock_indicators_controller.g.dart';

enum StockIndicatorType { sma, ema, rsi }

@Riverpod(keepAlive: true)
class StockIndicatorController extends _$StockIndicatorController {
  @override
  Future<StockTechnicalIndicator> build(
    String symbol,
    StockIndicatorType type,
  ) {
    return _fetch(symbol, type);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(symbol, type));
  }

  Future<StockTechnicalIndicator> _fetch(
    String symbol,
    StockIndicatorType type,
  ) {
    final repository = ref.read(stocksRepositoryProvider);

    return switch (type) {
      StockIndicatorType.sma => repository.sma(symbol: symbol, timePeriod: 20),
      StockIndicatorType.ema => repository.ema(symbol: symbol, timePeriod: 20),
      StockIndicatorType.rsi => repository.rsi(symbol: symbol, timePeriod: 14),
    };
  }
}
