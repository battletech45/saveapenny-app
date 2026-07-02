import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';
import 'package:saveapenny/features/budgets/presentation/budgets_screen.dart';
import 'package:saveapenny/features/budgets/presentation/widgets/budget_form_sheet.dart';
import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeCategoriesRepository implements CategoriesRepository {
  _FakeCategoriesRepository({required this.categories});

  final List<Category> categories;

  @override
  Future<List<Category>> list() async => categories;

  @override
  Future<Category> create({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String categoryId) {
    throw UnimplementedError();
  }

  @override
  Future<Category> update({
    required String categoryId,
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
  }) {
    throw UnimplementedError();
  }
}

class _FakeBudgetsRepository implements BudgetsRepository {
  _FakeBudgetsRepository({
    required this.budgets,
    required this.statuses,
    this.onCreate,
    this.onDelete,
  });

  final List<Budget> budgets;
  final Map<String, BudgetStatus> statuses;
  final Future<Budget> Function({
    required String categoryId,
    required num amount,
    required BudgetPeriod period,
    required DateTime startDate,
    required DateTime endDate,
  })?
  onCreate;
  final Future<void> Function(String budgetId)? onDelete;

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
    return onDelete!(budgetId);
  }

  @override
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) async {
    return PaginatedData<Budget>(
      items: budgets,
      page: page,
      size: size,
      totalItems: budgets.length,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<BudgetStatus> status(String budgetId) async => statuses[budgetId]!;

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

Category _category({
  required String id,
  required String name,
  required CategoryType type,
}) {
  return Category(
    id: id,
    name: name,
    type: type,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
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

Future<void> _pumpWidget(
  WidgetTester tester, {
  required ProviderContainer container,
  required Widget child,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'budget form shows duplicate-budget failure copy on submit error',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          categoriesRepositoryProvider.overrideWith(
            (ref) => _FakeCategoriesRepository(
              categories: <Category>[
                _category(
                  id: 'c-1',
                  name: 'Groceries',
                  type: CategoryType.expense,
                ),
              ],
            ),
          ),
          budgetsRepositoryProvider.overrideWith(
            (ref) => _FakeBudgetsRepository(
              budgets: const <Budget>[],
              statuses: const <String, BudgetStatus>{},
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

      await _pumpWidget(
        tester,
        container: container,
        child: const BudgetFormSheet(),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Groceries').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '500');
      final submitButton = find.widgetWithText(ElevatedButton, 'Create budget');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text(
          'A budget already exists for this category, period, and date range.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('budget form shows local invalid date-range copy', (
    WidgetTester tester,
  ) async {
    final existing = _budget(id: 'b-1').copyWith(
      startDate: DateTime.parse('2026-06-30T00:00:00Z'),
      endDate: DateTime.parse('2026-06-01T00:00:00Z'),
    );
    final container = ProviderContainer(
      overrides: [
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(
            categories: <Category>[
              _category(
                id: 'c-1',
                name: 'Groceries',
                type: CategoryType.expense,
              ),
            ],
          ),
        ),
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(
            budgets: <Budget>[existing],
            statuses: <String, BudgetStatus>{
              'b-1': _status(BudgetHealth.warning),
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: BudgetFormSheet(existing: existing),
    );

    expect(
      find.text('Start date must be on or before the end date.'),
      findsOneWidget,
    );
  });

  testWidgets('budgets screen shows not-found failure copy when delete fails', (
    WidgetTester tester,
  ) async {
    final budget = _budget(id: 'b-1');
    final container = ProviderContainer(
      overrides: [
        budgetsRepositoryProvider.overrideWith(
          (ref) => _FakeBudgetsRepository(
            budgets: <Budget>[budget],
            statuses: <String, BudgetStatus>{
              'b-1': _status(BudgetHealth.exceeded),
            },
            onDelete: (budgetId) async {
              throw const Failure.api(
                code: ApiErrorCode.budgetNotFound,
                message: 'Budget not found.',
              );
            },
          ),
        ),
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(categories: const <Category>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpWidget(
      tester,
      container: container,
      child: const BudgetsScreen(),
    );

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      find.text('The requested resource could not be found.'),
      findsOneWidget,
    );
  });
}
