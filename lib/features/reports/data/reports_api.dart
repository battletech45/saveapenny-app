import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/dio_client.dart';
import 'package:saveapenny/features/reports/data/dto/cash_flow_point_response.dart';
import 'package:saveapenny/features/reports/data/dto/category_spending_response.dart';
import 'package:saveapenny/features/reports/data/dto/monthly_summary_response.dart';
import 'package:saveapenny/features/reports/data/dto/net_worth_snapshot_response.dart';

part 'reports_api.g.dart';

class ReportsApi {
  ReportsApi(this._apiClient) : _dateFormat = DateFormat('yyyy-MM-dd');

  final ApiClient _apiClient;
  final DateFormat _dateFormat;

  Future<MonthlySummaryResponse> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) {
    return _apiClient.send<MonthlySummaryResponse>(
      call: (dio) => dio.get<dynamic>(
        '/reports/monthly-summary',
        queryParameters: <String, String>{
          'from': _dateFormat.format(from),
          'to': _dateFormat.format(to),
        },
      ),
      fromData: (data) => MonthlySummaryResponse.fromJson(_readJsonMap(data)),
    );
  }

  Future<List<CategorySpendingResponse>> categorySpending({
    required DateTime from,
    required DateTime to,
  }) {
    return _apiClient.send<List<CategorySpendingResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/reports/category-spending',
        queryParameters: <String, String>{
          'from': _dateFormat.format(from),
          'to': _dateFormat.format(to),
        },
      ),
      fromData: (data) {
        if (data is! List<Object?>) {
          throw const FormatException('Expected a JSON array.');
        }

        return data
            .map(
              (item) => CategorySpendingResponse.fromJson(_readJsonMap(item)),
            )
            .toList(growable: false);
      },
    );
  }

  Future<List<CashFlowPointResponse>> cashFlow({
    required DateTime from,
    required DateTime to,
  }) {
    return _apiClient.send<List<CashFlowPointResponse>>(
      call: (dio) => dio.get<dynamic>(
        '/reports/cash-flow',
        queryParameters: <String, String>{
          'from': _dateFormat.format(from),
          'to': _dateFormat.format(to),
        },
      ),
      fromData: (data) {
        if (data is! List<Object?>) {
          throw const FormatException('Expected a JSON array.');
        }

        return data
            .map((item) => CashFlowPointResponse.fromJson(_readJsonMap(item)))
            .toList(growable: false);
      },
    );
  }

  Future<NetWorthSnapshotResponse> netWorthSnapshot({
    required DateTime snapshotDate,
  }) {
    return _apiClient.send<NetWorthSnapshotResponse>(
      call: (dio) => dio.get<dynamic>(
        '/reports/net-worth',
        queryParameters: <String, String>{
          'snapshotDate': _dateFormat.format(snapshotDate),
        },
      ),
      fromData: (data) => NetWorthSnapshotResponse.fromJson(_readJsonMap(data)),
    );
  }
}

Map<String, dynamic> _readJsonMap(Object? data) {
  if (data is Map<Object?, Object?>) {
    return data.map((key, value) => MapEntry(key.toString(), value));
  }

  throw const FormatException('Expected a JSON object.');
}

@Riverpod(keepAlive: true)
ReportsApi reportsApi(Ref ref) {
  return ReportsApi(ref.watch(apiClientProvider));
}
