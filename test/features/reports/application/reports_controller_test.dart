import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/features/reports/application/reports_controller.dart';
import 'package:saveapenny/features/reports/data/reports_repository.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/features/reports/domain/reports_repository.dart';

class _FakeReportsRepository implements ReportsRepository {
  _FakeReportsRepository({
    this.onMonthlySummary,
    this.onCategorySpending,
    this.onCashFlow,
    this.onNetWorthSnapshot,
  });

  final Future<MonthlySummary> Function(DateTime from, DateTime to)?
  onMonthlySummary;
  final Future<List<CategorySpending>> Function(DateTime from, DateTime to)?
  onCategorySpending;
  final Future<List<CashFlowPoint>> Function(DateTime from, DateTime to)?
  onCashFlow;
  final Future<NetWorthSnapshot> Function(DateTime snapshotDate)?
  onNetWorthSnapshot;

  @override
  Future<List<CashFlowPoint>> cashFlow({
    required DateTime from,
    required DateTime to,
  }) {
    return onCashFlow!(from, to);
  }

  @override
  Future<List<CategorySpending>> categorySpending({
    required DateTime from,
    required DateTime to,
  }) {
    return onCategorySpending!(from, to);
  }

  @override
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) {
    return onMonthlySummary!(from, to);
  }

  @override
  Future<NetWorthSnapshot> netWorthSnapshot({required DateTime snapshotDate}) {
    return onNetWorthSnapshot!(snapshotDate);
  }
}

void main() {
  test('build loads the current dashboard state', () async {
    final container = ProviderContainer(
      overrides: [
        reportsRepositoryProvider.overrideWith(
          (ref) => _FakeReportsRepository(
            onMonthlySummary: (from, to) async => MonthlySummary(
              startDate: from,
              endDate: to,
              totalIncome: 3200,
              totalExpense: 1800,
              netSavings: 1400,
            ),
            onCategorySpending: (from, to) async => const <CategorySpending>[
              CategorySpending(
                categoryId: 'c-1',
                categoryName: 'Rent',
                totalAmount: 1200,
                usagePercentage: 66.7,
              ),
            ],
            onCashFlow: (from, to) async => <CashFlowPoint>[
              CashFlowPoint(
                date: from,
                incomeAmount: 3200,
                expenseAmount: 1800,
                netAmount: 1400,
              ),
            ],
            onNetWorthSnapshot: (snapshotDate) async => NetWorthSnapshot(
              snapshotDate: snapshotDate,
              totalAssets: 5000,
              totalLiabilities: 1200,
              netWorth: 3800,
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(reportsControllerProvider.future);

    expect(state.monthlySummary.netSavings, 1400);
    expect(state.categorySpending.single.categoryName, 'Rent');
    expect(state.cashFlow.single.netAmount, 1400);
    expect(state.netWorthTrend, hasLength(6));
    expect(state.currentNetWorth.netWorth, 3800);
  });

  test(
    'build exposes the primary failure path when summary loading fails',
    () async {
      final container = ProviderContainer(
        overrides: [
          reportsRepositoryProvider.overrideWith(
            (ref) => _FakeReportsRepository(
              onMonthlySummary: (from, to) async {
                throw const Failure.network();
              },
              onCategorySpending: (from, to) async =>
                  const <CategorySpending>[],
              onCashFlow: (from, to) async => const <CashFlowPoint>[],
              onNetWorthSnapshot: (snapshotDate) async => NetWorthSnapshot(
                snapshotDate: snapshotDate,
                totalAssets: 0,
                totalLiabilities: 0,
                netWorth: 0,
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(reportsControllerProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(reportsControllerProvider).hasError, isTrue);
      expect(
        container.read(reportsControllerProvider).error,
        isA<NetworkFailure>(),
      );
    },
  );
}
