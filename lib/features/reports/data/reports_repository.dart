import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/cached_fetch.dart';
import 'package:saveapenny/core/storage/response_cache_store.dart';
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

// Keyed by the calendar period the data describes (day / month), not the
// literal query timestamp — `snapshotDate`/`to` is effectively "now" on
// every dashboard call, so an exact-match key would write but never read
// back. Partitioning by period also keeps this cache correct when
// ReportsController browses to a *different* month/day: that call gets its
// own key instead of overwriting "today"/"this month" with historical data.
class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._reportsApi, this._cache);

  final ReportsApi _reportsApi;
  final ResponseCacheStore _cache;

  @override
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await cachedFetch<MonthlySummaryResponse>(
      cache: _cache,
      key: _monthlySummaryCacheKey(from),
      call: () => _reportsApi.monthlySummary(from: from, to: to),
      toJson: (value) => value.toJson(),
      fromJson: MonthlySummaryResponse.fromJson,
    );
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
    final response = await cachedFetch<NetWorthSnapshotResponse>(
      cache: _cache,
      key: _netWorthCacheKey(snapshotDate),
      call: () => _reportsApi.netWorthSnapshot(snapshotDate: snapshotDate),
      toJson: (value) => value.toJson(),
      fromJson: NetWorthSnapshotResponse.fromJson,
    );
    return response.toDomain();
  }

  @override
  Future<DateTime?> lastSyncedAt() =>
      _cache.writtenAt(_netWorthCacheKey(DateTime.now()));
}

String _netWorthCacheKey(DateTime date) => 'reports:net-worth:${_dayKey(date)}';

String _monthlySummaryCacheKey(DateTime date) =>
    'reports:monthly-summary:${_monthKey(date)}';

String _dayKey(DateTime date) =>
    '${_pad4(date.year)}-${_pad2(date.month)}-${_pad2(date.day)}';

String _monthKey(DateTime date) => '${_pad4(date.year)}-${_pad2(date.month)}';

String _pad2(int value) => value.toString().padLeft(2, '0');

String _pad4(int value) => value.toString().padLeft(4, '0');

@Riverpod(keepAlive: true)
ReportsRepository reportsRepository(Ref ref) {
  return ReportsRepositoryImpl(
    ref.watch(reportsApiProvider),
    ref.watch(responseCacheStoreProvider),
  );
}
