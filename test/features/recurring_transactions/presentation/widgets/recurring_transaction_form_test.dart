import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/categories/data/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/categories_repository.dart';
import 'package:saveapenny/features/categories/domain/category.dart';
import 'package:saveapenny/features/recurring_transactions/data/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transaction_history_entry.dart';
import 'package:saveapenny/features/recurring_transactions/domain/recurring_transactions_repository.dart';
import 'package:saveapenny/features/recurring_transactions/domain/upcoming_recurring_transaction.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/widgets/recurring_transaction_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({required this.accounts});

  final List<Account> accounts;

  @override
  Future<List<Account>> list() async => accounts;

  @override
  Future<DateTime?> lastSyncedAt() async => null;

  @override
  Future<Account> create({
    required String name,
    required AccountType type,
    required String currency,
    required num initialBalance,
    num? creditLimit,
    num? apr,
    int? statementDay,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String accountId) {
    throw UnimplementedError();
  }

  @override
  Future<Account> update({
    required String accountId,
    required String name,
    required AccountType type,
    required String currency,
  }) {
    throw UnimplementedError();
  }
}

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

class _FakeRecurringTransactionsRepository
    implements RecurringTransactionsRepository {
  _FakeRecurringTransactionsRepository({this.onCreate});

  final Future<RecurringTransaction> Function({
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
  })?
  onCreate;

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
  }) {
    return onCreate!(
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      frequency: frequency,
      nextRunDate: nextRunDate,
      name: name,
      description: description,
      startDate: startDate,
      endDate: endDate,
      classification: classification,
    );
  }

  @override
  Future<void> delete(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<RecurringTransaction> get(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<RecurringTransactionHistoryEntry>> history(
    String recurringTransactionId, {
    int page = 0,
    int size = 20,
    String sort = 'scheduledDate,desc',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaginatedData<RecurringTransaction>> list({
    int page = 0,
    int size = 20,
    String sort = 'nextRunDate,asc',
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RecurringTransaction> pause(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<RecurringTransaction> resume(String recurringTransactionId) {
    throw UnimplementedError();
  }

  @override
  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10}) {
    throw UnimplementedError();
  }

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
  }) {
    throw UnimplementedError();
  }
}

Account _account() {
  return Account(
    id: 'a-1',
    name: 'Main bank',
    type: AccountType.bank,
    currency: 'TRY',
    balance: 100,
    initialBalance: 100,
    active: true,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
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

RecurringTransaction _incomeExisting() {
  return RecurringTransaction(
    id: 'r-1',
    userId: 'u-1',
    accountId: 'a-1',
    categoryId: 'c-2',
    type: RecurringTransactionType.income,
    amount: 500,
    frequency: RecurringFrequency.monthly,
    nextRunDate: DateTime.now(),
    status: RecurringStatus.active,
    createdAt: DateTime.parse('2026-06-09T12:00:00Z'),
    updatedAt: DateTime.parse('2026-06-09T12:00:00Z'),
  );
}

Future<void> _pumpSheet(
  WidgetTester tester,
  ProviderContainer container, {
  RecurringTransaction? existing,
  bool advancedRecurringUnlocked = true,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RecurringTransactionFormSheet(
            existing: existing,
            advancedRecurringUnlocked: advancedRecurringUnlocked,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDropdown<T>(
  WidgetTester tester,
  int index,
  String optionText,
) async {
  await tester.tap(find.byType(AppDropdownField<T>).at(index));
  await tester.pumpAndSettle();
  await tester.tap(find.text(optionText).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('form renders existing income configuration when editing', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(accounts: <Account>[_account()]),
        ),
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(
            categories: <Category>[
              _category(
                id: 'c-1',
                name: 'Groceries',
                type: CategoryType.expense,
              ),
              _category(id: 'c-2', name: 'Salary', type: CategoryType.income),
            ],
          ),
        ),
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(tester, container, existing: _incomeExisting());

    expect(find.text('Edit recurring transaction'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('form shows specific failure copy on submit error', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(accounts: <Account>[_account()]),
        ),
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
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(
            onCreate:
                ({
                  required accountId,
                  required categoryId,
                  required type,
                  required amount,
                  required frequency,
                  required nextRunDate,
                  name,
                  description,
                  startDate,
                  endDate,
                  classification,
                }) async {
                  throw const Failure.api(
                    code: ApiErrorCode.invalidRecurringTransactionNextRunDate,
                    message: 'Invalid next run date.',
                  );
                },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(tester, container);

    await _selectDropdown<String>(tester, 0, 'Main bank');

    await _selectDropdown<String>(tester, 1, 'Groceries');

    await tester.enterText(find.byType(TextFormField).first, '49.99');
    final submitButton = find.widgetWithText(
      ElevatedButton,
      'Create recurring entry',
    );
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Next run date must be today or later.'), findsOneWidget);
  });

  testWidgets('form hides advanced fields when recurring automation is locked', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(accounts: <Account>[_account()]),
        ),
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
        recurringTransactionsRepositoryProvider.overrideWith(
          (ref) => _FakeRecurringTransactionsRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(tester, container, advancedRecurringUnlocked: false);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Automated recurring processing requires Plus. You can still track entries manually.',
      ),
      findsOneWidget,
    );
    expect(find.text('Start date'), findsNothing);
    expect(find.text('End date'), findsNothing);
    expect(find.text('Classification'), findsNothing);
  });
}
