import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/features/budgets/application/budgets_controller.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';

class _FakeBudgetsRepository implements BudgetsRepository {
  _FakeBudgetsRepository({this.onList, this.onStatus, this.onCreate});

  final Future<PaginatedData<Budget>> Function()? onList;
  final Future<BudgetStatus> Function(String budgetId)? onStatus;
  final Future<Budget> Function({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  })?
  onCreate;

  @override
  Future<Budget> create({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return onCreate!(
      categoryId: categoryId,
      amount: amount,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<void> delete(String budgetId) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) {
    return onList!();
  }

  @override
  Future<BudgetStatus> status(String budgetId) {
    return onStatus!(budgetId);
  }

  @override
  Future<Budget> update({
    required String budgetId,
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    throw UnimplementedError();
  }
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

PaginatedData<Budget> _page(
  List<Budget> items, {
  int page = 0,
  bool hasNext = false,
  bool hasPrevious = false,
}) {
  return PaginatedData<Budget>(
    items: items,
    page: page,
    size: 20,
    totalItems: items.length,
    totalPages: hasNext ? page + 2 : page + 1,
    hasNext: hasNext,
    hasPrevious: hasPrevious,
  );
}

void main() {
  test('build loads the first budgets page with statuses', () async {
    final existing = _budget(id: 'b-1');

    final container = ProviderContainer(
      overrides: [
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(
            onList: () async => _page(<Budget>[existing]),
            onStatus: (budgetId) async => _status(BudgetHealth.warning),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(budgetsControllerProvider.future);

    expect(state.items, hasLength(1));
    expect(state.items.single.budget, existing);
    expect(state.items.single.status.status, BudgetHealth.warning);
  });

  test('create preserves current list when the mutation fails', () async {
    final existing = _budget(id: 'b-1');

    final container = ProviderContainer(
      overrides: [
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(
            onList: () async => _page(<Budget>[existing]),
            onStatus: (budgetId) async => _status(BudgetHealth.onTrack),
            onCreate:
                ({
                  required categoryId,
                  required amount,
                  required period,
                  required startDate,
                  required endDate,
                }) async {
                  throw const Failure.api(
                    code: ApiErrorCode.budgetAlreadyExists,
                    message: 'Duplicate budget.',
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(budgetsControllerProvider.future);

    await expectLater(
      container
          .read(budgetsControllerProvider.notifier)
          .create(
            categoryId: 'c-1',
            amount: 500,
            period: BudgetPeriod.monthly,
            startDate: DateTime.parse('2026-06-01T00:00:00Z'),
            endDate: DateTime.parse('2026-06-30T00:00:00Z'),
          ),
      throwsA(isA<ApiFailure>()),
    );

    expect(
      container.read(budgetsControllerProvider).value?.items.single.budget,
      existing,
    );
  });
}
