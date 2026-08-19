import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';
import 'package:saveapenny/features/dashboard/domain/dashboard_snapshot.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
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
    // Budgets/recurring aren't cached yet (docs/adr/0003-offline-read-cache.md
    // Phase 3), so a genuine offline failure here would otherwise take down
    // the whole dashboard even though the hero data above loaded fine. These
    // are secondary strips, not headline numbers — degrade to empty instead.
    //
    // These futures are created now but not awaited until after
    // netWorth/monthlySummary/accounts below (to run everything in
    // parallel), which leaves a window where a rejection has no listener
    // yet — Dart's zone would report that as an unhandled error even though
    // it's about to be awaited. `.ignore()` marks it as deliberately
    // observed-later; the real await below still sees the real value/error.
    final budgetsPageFuture = _orEmptyBudgetsPage(
      budgets.list(period: BudgetPeriod.monthly, size: _atRiskBudgetSampleSize),
    )..ignore();
    final upcomingBillsFuture = _orEmptyUpcomingBills(
      recurring.upcoming(limit: _upcomingBillsLimit),
    )..ignore();

    // Net worth, monthly summary, and accounts are cached (see
    // ReportsRepositoryImpl/AccountsRepositoryImpl) and so already degrade
    // to a last-known value on Failure.network instead of throwing.
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

  Future<PaginatedData<Budget>> _orEmptyBudgetsPage(
    Future<PaginatedData<Budget>> future,
  ) async {
    try {
      return await future;
    } on Failure catch (failure) {
      if (failure is! NetworkFailure) {
        rethrow;
      }
      return PaginatedData<Budget>(
        items: const <Budget>[],
        page: 0,
        size: _atRiskBudgetSampleSize,
        totalItems: 0,
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      );
    }
  }

  Future<List<UpcomingRecurringTransaction>> _orEmptyUpcomingBills(
    Future<List<UpcomingRecurringTransaction>> future,
  ) async {
    try {
      return await future;
    } on Failure catch (failure) {
      if (failure is! NetworkFailure) {
        rethrow;
      }
      return const <UpcomingRecurringTransaction>[];
    }
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

/// Re-evaluates whenever [dashboardControllerProvider]'s state changes.
/// Reflects the net worth hero figure specifically — the headline metric —
/// not the (uncached) budgets/recurring strips. See
/// docs/adr/0003-offline-read-cache.md.
@riverpod
Future<DateTime?> dashboardLastSyncedAt(Ref ref) {
  ref.watch(dashboardControllerProvider);
  return ref.read(reportsRepositoryProvider).lastSyncedAt();
}
