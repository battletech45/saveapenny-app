import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/stocks/data/dto/stock_json.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';

part 'stock_financial_statement_response.freezed.dart';
part 'stock_financial_statement_response.g.dart';

@freezed
abstract class FinancialReportItemResponse with _$FinancialReportItemResponse {
  const factory FinancialReportItemResponse({
    required String fiscalDateEnding,
    String? reportedCurrency,
    @JsonKey(fromJson: stockStringMap)
    @Default(<String, String>{})
    Map<String, String> fields,
  }) = _FinancialReportItemResponse;

  factory FinancialReportItemResponse.fromJson(Map<String, dynamic> json) =>
      _$FinancialReportItemResponseFromJson(json);
}

@freezed
abstract class StockFinancialStatementResponse
    with _$StockFinancialStatementResponse {
  const factory StockFinancialStatementResponse({
    required String symbol,
    @Default(<FinancialReportItemResponse>[])
    List<FinancialReportItemResponse> annualReports,
    @Default(<FinancialReportItemResponse>[])
    List<FinancialReportItemResponse> quarterlyReports,
  }) = _StockFinancialStatementResponse;

  factory StockFinancialStatementResponse.fromJson(Map<String, dynamic> json) =>
      _$StockFinancialStatementResponseFromJson(json);
}

extension FinancialReportItemResponseX on FinancialReportItemResponse {
  StockFinancialReportItem toDomain() {
    return StockFinancialReportItem(
      fiscalDateEnding: fiscalDateEnding,
      reportedCurrency: reportedCurrency,
      fields: fields,
    );
  }
}

extension StockFinancialStatementResponseX on StockFinancialStatementResponse {
  StockFinancialStatement toDomain() {
    return StockFinancialStatement(
      symbol: symbol,
      annualReports: annualReports
          .map((item) => item.toDomain())
          .toList(growable: false),
      quarterlyReports: quarterlyReports
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }
}
