import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/stocks/data/stocks_repository.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';

part 'stock_holdings_controller.freezed.dart';
part 'stock_holdings_controller.g.dart';

@freezed
abstract class StockHoldingsState with _$StockHoldingsState {
  const factory StockHoldingsState({
    required List<StockHolding> items,
    required StockHoldingSummary summary,
    required int page,
    required int size,
    required int totalItems,
    required int totalPages,
    required bool hasNext,
    required bool hasPrevious,
  }) = _StockHoldingsState;
}

@Riverpod(keepAlive: true)
class StockHoldingsController extends _$StockHoldingsController {
  static const int _pageSize = 20;

  bool _isLoadingMore = false;

  @override
  Future<StockHoldingsState> build() {
    return _fetch(page: 0);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(page: 0));
  }

  Future<void> loadMore() async {
    final current = _readAsyncData(state);
    if (current == null || !current.hasNext || _isLoadingMore) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = await _fetch(page: current.page + 1);
      state = AsyncData(
        nextPage.copyWith(
          items: <StockHolding>[...current.items, ...nextPage.items],
        ),
      );
    } on Failure {
      state = AsyncData(current);
    } on Object {
      state = AsyncData(current);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> createHolding({
    required String symbol,
    required num quantity,
    required num purchasePrice,
    required String currency,
    required DateTime purchaseDate,
    String? notes,
  }) {
    return _runMutation(
      () => ref
          .read(stocksRepositoryProvider)
          .createHolding(
            symbol: symbol,
            quantity: quantity,
            purchasePrice: purchasePrice,
            currency: currency,
            purchaseDate: purchaseDate,
            notes: notes,
          ),
    );
  }

  Future<void> updateHolding({
    required String holdingId,
    num? quantity,
    num? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    String? notes,
  }) {
    return _runMutation(
      () => ref
          .read(stocksRepositoryProvider)
          .updateHolding(
            holdingId: holdingId,
            quantity: quantity,
            purchasePrice: purchasePrice,
            currency: currency,
            purchaseDate: purchaseDate,
            notes: notes,
          ),
    );
  }

  Future<void> deleteHolding(String holdingId) {
    return _runMutation(
      () => ref.read(stocksRepositoryProvider).deleteHolding(holdingId),
    );
  }

  Future<StockHoldingsState> _fetch({required int page}) async {
    final repository = ref.read(stocksRepositoryProvider);
    final holdingsFuture = repository.listHoldings(page: page, size: _pageSize);
    final summaryFuture = repository.holdingSummary();

    final results = await Future.wait<Object>(<Future<Object>>[
      holdingsFuture,
      summaryFuture,
    ]);
    final holdings = results[0] as PaginatedData<StockHolding>;
    final summary = results[1] as StockHoldingSummary;

    return StockHoldingsState(
      items: holdings.items,
      summary: summary,
      page: holdings.page,
      size: holdings.size,
      totalItems: holdings.totalItems,
      totalPages: holdings.totalPages,
      hasNext: holdings.hasNext,
      hasPrevious: holdings.hasPrevious,
    );
  }

  StockHoldingsState? _readAsyncData(AsyncValue<StockHoldingsState> value) {
    return value is AsyncData<StockHoldingsState> ? value.value : null;
  }

  Future<void> _runMutation(Future<Object?> Function() mutation) async {
    final current = _readAsyncData(state);

    try {
      await mutation();
      state = AsyncData(await _fetch(page: 0));
    } on Failure catch (error, stackTrace) {
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(error, stackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    } on Object catch (error, stackTrace) {
      final failure = Failure.unknown(message: error.toString());
      if (current != null) {
        state = AsyncData(current);
      } else {
        state = AsyncError(failure, stackTrace);
      }
      Error.throwWithStackTrace(failure, stackTrace);
    }
  }
}
