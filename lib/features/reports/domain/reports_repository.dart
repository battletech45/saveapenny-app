import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';

abstract interface class ReportsRepository {
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  });

  Future<List<CategorySpending>> categorySpending({
    required DateTime from,
    required DateTime to,
  });

  Future<List<CashFlowPoint>> cashFlow({
    required DateTime from,
    required DateTime to,
  });

  Future<NetWorthSnapshot> netWorthSnapshot({required DateTime snapshotDate});

  /// When the last successful [netWorthSnapshot] call was written to the
  /// offline cache — `null` if nothing has ever been cached. Only the
  /// net worth/monthly summary pair is cached (the Dashboard's hero data);
  /// [categorySpending]/[cashFlow] are not yet — see
  /// docs/adr/0003-offline-read-cache.md Phase 3.
  Future<DateTime?> lastSyncedAt();
}
