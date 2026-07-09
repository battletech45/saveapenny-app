import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/stocks/data/stocks_repository.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';

part 'stock_financials_controller.g.dart';

enum StockFinancialStatementType { incomeStatement, balanceSheet, cashFlow }

@Riverpod(keepAlive: true)
class StockFinancialStatementController
    extends _$StockFinancialStatementController {
  @override
  Future<StockFinancialStatement> build(
    String symbol,
    StockFinancialStatementType type,
  ) {
    return _fetch(symbol, type);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(symbol, type));
  }

  Future<StockFinancialStatement> _fetch(
    String symbol,
    StockFinancialStatementType type,
  ) {
    final repository = ref.read(stocksRepositoryProvider);

    return switch (type) {
      StockFinancialStatementType.incomeStatement => repository.incomeStatement(
        symbol,
      ),
      StockFinancialStatementType.balanceSheet => repository.balanceSheet(
        symbol,
      ),
      StockFinancialStatementType.cashFlow => repository.cashFlow(symbol),
    };
  }
}
