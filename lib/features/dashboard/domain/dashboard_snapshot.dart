import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';

part 'dashboard_snapshot.freezed.dart';

@freezed
abstract class DashboardSnapshot with _$DashboardSnapshot {
  const factory DashboardSnapshot({
    required NetWorthSnapshot netWorth,
    required MonthlySummary monthlySummary,
    required List<Account> accounts,
    required List<BudgetStatus> atRiskBudgets,
    required List<UpcomingRecurringTransaction> upcomingBills,
  }) = _DashboardSnapshot;
}
