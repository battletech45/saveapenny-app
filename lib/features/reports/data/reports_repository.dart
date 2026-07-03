import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/reports/data/dto/cash_flow_point_response.dart';
import 'package:saveapenny/features/reports/data/dto/category_spending_response.dart';
import 'package:saveapenny/features/reports/data/dto/monthly_summary_response.dart';
import 'package:saveapenny/features/reports/data/dto/net_worth_snapshot_response.dart';
import 'package:saveapenny/features/reports/data/reports_api.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/features/reports/domain/reports_repository.dart';

part 'reports_repository.g.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._reportsApi);

  final ReportsApi _reportsApi;

  @override
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _reportsApi.monthlySummary(from: from, to: to);
    return response.toDomain();
  }

  @override
  Future<List<CategorySpending>> categorySpending({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _reportsApi.categorySpending(from: from, to: to);
    return response
        .map((CategorySpendingResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<List<CashFlowPoint>> cashFlow({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _reportsApi.cashFlow(from: from, to: to);
    return response
        .map((CashFlowPointResponse item) => item.toDomain())
        .toList(growable: false);
  }

  @override
  Future<NetWorthSnapshot> netWorthSnapshot({
    required DateTime snapshotDate,
  }) async {
    final response = await _reportsApi.netWorthSnapshot(
      snapshotDate: snapshotDate,
    );
    return response.toDomain();
  }
}

@Riverpod(keepAlive: true)
ReportsRepository reportsRepository(Ref ref) {
  return ReportsRepositoryImpl(ref.watch(reportsApiProvider));
}
