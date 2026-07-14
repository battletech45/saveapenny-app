import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';
import 'package:saveapenny/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/reports/data/reports_repository.dart';

part 'dashboard_controller.g.dart';

const int _atRiskBudgetSampleSize = 5;
const int _upcomingBillsLimit = 5;

@Riverpod(keepAlive: true)
class DashboardController extends _$DashboardController {
  @override
  Future<DashboardSnapshot> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<DashboardSnapshot> _load() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);

    final reports = ref.read(reportsRepositoryProvider);
    final accounts = ref.read(accountsRepositoryProvider);
    final budgets = ref.read(budgetsRepositoryProvider);
    final recurring = ref.read(recurringTransactionsRepositoryProvider);

    final netWorthFuture = reports.netWorthSnapshot(snapshotDate: now);
    final monthlySummaryFuture = reports.monthlySummary(
      from: monthStart,
      to: now,
    );
    final accountsFuture = accounts.list();
    final budgetsPageFuture = budgets.list(
      period: BudgetPeriod.monthly,
      size: _atRiskBudgetSampleSize,
    );
    final upcomingBillsFuture = recurring.upcoming(limit: _upcomingBillsLimit);

    final netWorth = await netWorthFuture;
    final monthlySummary = await monthlySummaryFuture;
    final accountList = await accountsFuture;
    final budgetsPage = await budgetsPageFuture;
    final upcomingBills = await upcomingBillsFuture;

    // budgets_api exposes only a per-budget status lookup, so the at-risk
    // strip fans out over the (small, size-capped) active budget list rather
    // than calling a bulk endpoint that doesn't exist yet.
    final atRiskBudgets = await _atRiskBudgets(budgets, budgetsPage);

    return DashboardSnapshot(
      netWorth: netWorth,
      monthlySummary: monthlySummary,
      accounts: accountList,
      atRiskBudgets: atRiskBudgets,
      upcomingBills: upcomingBills,
    );
  }

  Future<List<BudgetStatus>> _atRiskBudgets(
    BudgetsRepository budgets,
    PaginatedData<Budget> budgetsPage,
  ) async {
    final statuses = await Future.wait<BudgetStatus>(
      budgetsPage.items.map((budget) => budgets.status(budget.id)),
    );

    return statuses
        .where((status) => status.status != BudgetHealth.onTrack)
        .toList(growable: false);
  }
}
