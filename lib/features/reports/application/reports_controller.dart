import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/features/reports/data/reports_repository.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';

part 'reports_controller.freezed.dart';
part 'reports_controller.g.dart';

@freezed
abstract class ReportsState with _$ReportsState {
  const factory ReportsState({
    required DateTime month,
    required MonthlySummary monthlySummary,
    required NetWorthSnapshot currentNetWorth,
    required List<NetWorthSnapshot> netWorthTrend,
    required List<CategorySpending> categorySpending,
    required List<CashFlowPoint> cashFlow,
  }) = _ReportsState;
}

@Riverpod(keepAlive: true)
class ReportsController extends _$ReportsController {
  @override
  Future<ReportsState> build() {
    return _fetch(_currentMonth());
  }

  Future<void> refresh() async {
    final month = _readAsyncData(state)?.month ?? _currentMonth();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(month));
  }

  Future<void> previousMonth() async {
    final current = _readAsyncData(state)?.month ?? _currentMonth();
    final previous = DateTime.utc(current.year, current.month - 1);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(previous));
  }

  Future<void> nextMonth() async {
    final current = _readAsyncData(state)?.month ?? _currentMonth();
    final next = DateTime.utc(current.year, current.month + 1);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(next));
  }

  Future<ReportsState> _fetch(DateTime month) async {
    final repository = ref.read(reportsRepositoryProvider);
    final range = _monthRange(month);
    final trendDates = _trendSnapshotDates(month, count: 6);

    final monthlySummaryFuture = repository.monthlySummary(
      from: range.start,
      to: range.end,
    );
    final categorySpendingFuture = repository.categorySpending(
      from: range.start,
      to: range.end,
    );
    final cashFlowFuture = repository.cashFlow(
      from: range.start,
      to: range.end,
    );
    final netWorthTrendFuture = Future.wait(
      trendDates.map(
        (snapshotDate) =>
            repository.netWorthSnapshot(snapshotDate: snapshotDate),
      ),
    );

    final monthlySummary = await monthlySummaryFuture;
    final categorySpending = await categorySpendingFuture;
    final cashFlow = await cashFlowFuture;
    final netWorthTrend = await netWorthTrendFuture;

    return ReportsState(
      month: DateTime.utc(month.year, month.month),
      monthlySummary: monthlySummary,
      currentNetWorth: netWorthTrend.last,
      netWorthTrend: netWorthTrend,
      categorySpending: categorySpending,
      cashFlow: cashFlow,
    );
  }

  DateTime _currentMonth() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month);
  }

  ReportsState? _readAsyncData(AsyncValue<ReportsState> value) {
    return value is AsyncData<ReportsState> ? value.value : null;
  }
}

({DateTime start, DateTime end}) _monthRange(DateTime month) {
  final start = DateTime.utc(month.year, month.month);
  final end = DateTime.utc(month.year, month.month + 1, 0);
  return (start: start, end: end);
}

List<DateTime> _trendSnapshotDates(DateTime month, {required int count}) {
  return List<DateTime>.generate(count, (index) {
    final snapshotMonth = DateTime.utc(
      month.year,
      month.month - (count - index - 1),
    );

    return DateTime.utc(snapshotMonth.year, snapshotMonth.month + 1, 0);
  }, growable: false);
}
