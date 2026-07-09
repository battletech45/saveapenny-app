import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_financial_statement.freezed.dart';

@freezed
abstract class StockFinancialReportItem with _$StockFinancialReportItem {
  const factory StockFinancialReportItem({
    required String fiscalDateEnding,
    String? reportedCurrency,
    required Map<String, String> fields,
  }) = _StockFinancialReportItem;
}

@freezed
abstract class StockFinancialStatement with _$StockFinancialStatement {
  const factory StockFinancialStatement({
    required String symbol,
    required List<StockFinancialReportItem> annualReports,
    required List<StockFinancialReportItem> quarterlyReports,
  }) = _StockFinancialStatement;
}
