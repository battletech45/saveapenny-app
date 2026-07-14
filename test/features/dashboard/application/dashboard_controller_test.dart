import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';
import 'package:saveapenny/features/dashboard/application/dashboard_controller.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/features/reports/data/reports_repository.dart';
import 'package:saveapenny/features/reports/domain/cash_flow_point.dart';
import 'package:saveapenny/features/reports/domain/category_spending.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/features/reports/domain/reports_repository.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({this.onList});

  final Future<List<Account>> Function()? onList;

  @override
  Future<List<Account>> list() => onList!();

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
  }) => throw UnimplementedError();

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String accountId) => throw UnimplementedError();
}

class _FakeBudgetsRepository implements BudgetsRepository {
  _FakeBudgetsRepository({this.onList, this.onStatus});

  final Future<PaginatedData<Budget>> Function()? onList;
  final Future<BudgetStatus> Function(String budgetId)? onStatus;

  @override
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) => onList!();

  @override
  Future<BudgetStatus> status(String budgetId) => onStatus!(budgetId);

  @override
  Future<Budget> create({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) => throw UnimplementedError();

  @override
  Future<Budget> update({
    required String budgetId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String budgetId) => throw UnimplementedError();
}

class _FakeRecurringTransactionsRepository
    implements RecurringTransactionsRepository {
  _FakeRecurringTransactionsRepository({this.onUpcoming});

  final Future<List<UpcomingRecurringTransaction>> Function({int limit})?
  onUpcoming;

  @override
  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10}) =>
      onUpcoming!(limit: limit);

  @override
  Future<PaginatedData<RecurringTransaction>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  }) => throw UnimplementedError();

  @override
  Future<RecurringTransaction> get(String recurringTransactionId) =>
      throw UnimplementedError();

  @override
  Future<RecurringTransaction> create({
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) => throw UnimplementedError();

  @override
  Future<RecurringTransaction> update({
    required String recurringTransactionId,
    required String accountId,
    required String categoryId,
    required RecurringTransactionType type,
    required num amount,
    required RecurringFrequency frequency,
    required DateTime nextRunDate,
    required RecurringStatus status,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    RecurringClassification? classification,
  }) => throw UnimplementedError();

  @override
  Future<void> delete(String recurringTransactionId) =>
      throw UnimplementedError();

  @override
  Future<RecurringTransaction> pause(String recurringTransactionId) =>
      throw UnimplementedError();

  @override
  Future<RecurringTransaction> resume(String recurringTransactionId) =>
      throw UnimplementedError();

  @override
  Future<PaginatedData<RecurringTransactionHistoryEntry>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) => throw UnimplementedError();
}

class _FakeReportsRepository implements ReportsRepository {
  _FakeReportsRepository({this.onNetWorth, this.onMonthlySummary});

  final Future<NetWorthSnapshot> Function({required DateTime snapshotDate})?
  onNetWorth;
  final Future<MonthlySummary> Function({
    required DateTime from,
    required DateTime to,
  })?
  onMonthlySummary;

  @override
  Future<NetWorthSnapshot> netWorthSnapshot({required DateTime snapshotDate}) =>
      onNetWorth!(snapshotDate: snapshotDate);

  @override
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) => onMonthlySummary!(from: from, to: to);

  @override
  Future<List<CategorySpending>> categorySpending({
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();

  @override
  Future<List<CashFlowPoint>> cashFlow({
    required DateTime from,
    required DateTime to,
  }) => throw UnimplementedError();
}

Account _account() {
  return Account(
    id: 'a-1',
    name: 'Main bank',
    type: AccountType.bank,
    currency: 'TRY',
    balance: 1000,
    initialBalance: 1000,
    active: true,
    createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
    updatedAt: DateTime.parse('2026-01-01T00:00:00Z'),
  );
}

Budget _budget({required String id}) {
  return Budget(
    id: id,
    userId: 'u-1',
    categoryId: 'c-1',
    amount: 500,
    period: BudgetPeriod.monthly,
    startDate: DateTime.parse('2026-06-01T00:00:00Z'),
    endDate: DateTime.parse('2026-06-30T00:00:00Z'),
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

BudgetStatus _status(BudgetHealth health) {
  return BudgetStatus(
    category: 'Groceries',
    budgetAmount: 500,
    spentAmount: 420,
    remainingAmount: 80,
    usagePercentage: 84,
    status: health,
  );
}

PaginatedData<Budget> _budgetPage(List<Budget> items) {
  return PaginatedData<Budget>(
    items: items,
    page: 0,
    size: 5,
    totalItems: items.length,
    totalPages: 1,
    hasNext: false,
    hasPrevious: false,
  );
}

void main() {
  test('build composes net worth, cash flow, accounts, at-risk budgets, and upcoming bills', () async {
    final onTrackBudget = _budget(id: 'b-onTrack');
    final warningBudget = _budget(id: 'b-warning');

    final container = ProviderContainer(
      overrides: [
        reportsRepositoryProvider.overrideWith(
          (ref) => _FakeReportsRepository(
            onNetWorth: ({required snapshotDate}) async => NetWorthSnapshot(
              snapshotDate: snapshotDate,
              totalAssets: 5000,
              totalLiabilities: 500,
              netWorth: 4500,
            ),
            onMonthlySummary: ({required from, required to}) async => MonthlySummary(
              startDate: from,
              endDate: to,
              totalIncome: 1200,
              totalExpense: 800,
              netSavings: 400,
            ),
          ),
        ),
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(onList: () async => <Account>[_account()]),
        ),
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(
            onList: () async => _budgetPage(<Budget>[onTrackBudget, warningBudget]),
            onStatus: (budgetId) async => budgetId == onTrackBudget.id
                ? _status(BudgetHealth.onTrack)
                : _status(BudgetHealth.warning),
          ),
        ),
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onUpcoming: ({limit = 10}) async => <UpcomingRecurringTransaction>[
              UpcomingRecurringTransaction(
                recurringTransactionId: 'r-1',
                name: 'Netflix',
                amount: 149,
                scheduledDate: DateTime.parse('2026-07-18T00:00:00Z'),
              ),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final snapshot = await container.read(dashboardControllerProvider.future);

    expect(snapshot.netWorth.netWorth, 4500);
    expect(snapshot.monthlySummary.totalIncome, 1200);
    expect(snapshot.accounts, hasLength(1));
    expect(snapshot.atRiskBudgets, hasLength(1));
    expect(snapshot.atRiskBudgets.single.status, BudgetHealth.warning);
    expect(snapshot.upcomingBills, hasLength(1));
    expect(snapshot.upcomingBills.single.name, 'Netflix');
  });

  test('build surfaces a thrown Failure as AsyncError', () async {
    final container = ProviderContainer(
      // Riverpod 3's default retry policy would otherwise retry this
      // always-failing fake with backoff for ~6s per attempt instead of
      // surfacing the error immediately.
      retry: (retryCount, error) => null,
      overrides: [
        reportsRepositoryProvider.overrideWith(
          (ref) => _FakeReportsRepository(
            onNetWorth: ({required snapshotDate}) async {
              throw const Failure.network();
            },
            onMonthlySummary: ({required from, required to}) async => MonthlySummary(
              startDate: from,
              endDate: to,
              totalIncome: 0,
              totalExpense: 0,
              netSavings: 0,
            ),
          ),
        ),
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(onList: () async => <Account>[]),
        ),
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(onList: () async => _budgetPage(<Budget>[])),
        ),
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onUpcoming: ({limit = 10}) async => <UpcomingRecurringTransaction>[],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(dashboardControllerProvider.future),
      throwsA(isA<Failure>()),
    );
  });
}
