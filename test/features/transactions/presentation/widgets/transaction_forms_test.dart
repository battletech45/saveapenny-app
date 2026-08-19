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
import 'package:saveapenny/features/transactions/data/transactions_repository.dart';
import 'package:saveapenny/features/transactions/domain/transaction.dart';
import 'package:saveapenny/features/transactions/domain/transactions_repository.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transaction_form_sheet.dart';
import 'package:saveapenny/features/transactions/presentation/widgets/transfer_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class _FakeAccountsRepository implements AccountsRepository {
  _FakeAccountsRepository({required this.accounts});

  final List<Account> accounts;

  @override
  Future<List<Account>> list() async => accounts;

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

class _FakeTransactionsRepository implements TransactionsRepository {
  _FakeTransactionsRepository({
    required this.items,
    this.onCreate,
    this.onCreateTransfer,
  });

  final List<Transaction> items;
  final Future<Transaction> Function({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  })?
  onCreate;
  final Future<void> Function({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  })?
  onCreateTransfer;

  @override
  Future<PaginatedData<Transaction>> list({
    DateTime? from,
    DateTime? to,
    TransactionType? type,
    String? accountId,
    String? categoryId,
    num? minAmount,
    num? maxAmount,
    String? keyword,
    int page = 0,
    int size = 20,
    String sort = 'transactionDate,desc',
  }) async {
    return PaginatedData<Transaction>(
      items: items,
      page: page,
      size: size,
      totalItems: items.length,
      totalPages: 1,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<Transaction> create({
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    return onCreate!(
      accountId: accountId,
      categoryId: categoryId,
      type: type,
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
    );
  }

  @override
  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required String categoryId,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    return onCreateTransfer!(
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      categoryId: categoryId,
      amount: amount,
      currency: currency,
      description: description,
      transactionDate: transactionDate,
    );
  }

  @override
  Future<void> delete(String transactionId) {
    throw UnimplementedError();
  }

  @override
  Future<Transaction> update({
    required String transactionId,
    required String accountId,
    required String categoryId,
    required TransactionType type,
    required num amount,
    required String currency,
    String? description,
    required DateTime transactionDate,
  }) {
    throw UnimplementedError();
  }
}

Account _account({
  required String id,
  required String name,
  required String currency,
  bool active = true,
}) {
  return Account(
    id: id,
    name: name,
    type: AccountType.bank,
    currency: currency,
    balance: 100,
    initialBalance: 100,
    active: active,
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

Future<void> _pumpSheet(
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
  testWidgets('transaction form filters categories when type changes', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            accounts: <Account>[
              _account(id: 'a-1', name: 'Main bank', currency: 'TRY'),
            ],
          ),
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
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(items: const <Transaction>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(
      tester,
      container: container,
      child: const TransactionFormSheet(),
    );

    expect(find.widgetWithText(ChoiceChip, 'Groceries'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Salary'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Groceries'));
    await tester.pumpAndSettle();

    await _selectDropdown<TransactionType>(tester, 0, 'Income');

    expect(find.widgetWithText(ChoiceChip, 'Salary'), findsOneWidget);
    expect(find.widgetWithText(ChoiceChip, 'Groceries'), findsNothing);
  });

  testWidgets(
    'transaction form shows inline failure and stays open on submit error',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              accounts: <Account>[
                _account(id: 'a-1', name: 'Main bank', currency: 'TRY'),
              ],
            ),
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
          transactionsRepositoryProvider.overrideWith(
            (ref) => _FakeTransactionsRepository(
              items: const <Transaction>[],
              onCreate:
                  ({
                    required accountId,
                    required categoryId,
                    required type,
                    required amount,
                    required currency,
                    description,
                    required transactionDate,
                  }) async {
                    throw const Failure.api(
                      code: ApiErrorCode.validationFailed,
                      message: 'Invalid transaction.',
                    );
                  },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpSheet(
        tester,
        container: container,
        child: const TransactionFormSheet(),
      );

      await _selectDropdown<String>(tester, 0, 'Main bank');

      await tester.tap(find.widgetWithText(ChoiceChip, 'Groceries'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '24.5');
      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Add transaction',
      );
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Record an income or expense against one of your accounts.'),
        findsOneWidget,
      );
      expect(
        find.text('Some fields need attention before you can continue.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('transfer form only offers expense categories', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        accountsRepositoryProvider.overrideWith(
          (ref) => _FakeAccountsRepository(
            accounts: <Account>[
              _account(id: 'a-1', name: 'Main bank', currency: 'TRY'),
              _account(id: 'a-2', name: 'Savings', currency: 'TRY'),
            ],
          ),
        ),
        categoriesRepositoryProvider.overrideWith(
          (ref) => _FakeCategoriesRepository(
            categories: <Category>[
              _category(
                id: 'c-1',
                name: 'Transfers',
                type: CategoryType.expense,
              ),
              _category(id: 'c-2', name: 'Salary', type: CategoryType.income),
            ],
          ),
        ),
        transactionsRepositoryProvider.overrideWith(
          (ref) => _FakeTransactionsRepository(items: const <Transaction>[]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await _pumpSheet(
      tester,
      container: container,
      child: const TransferFormSheet(),
    );

    await tester.tap(find.byType(AppDropdownField<String>).at(2));
    await tester.pumpAndSettle();

    expect(find.text('Transfers').last, findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });

  testWidgets(
    'transfer form blocks currency mismatch before calling repository',
    (WidgetTester tester) async {
      var transferCalls = 0;
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              accounts: <Account>[
                _account(id: 'a-1', name: 'Main bank', currency: 'TRY'),
                _account(id: 'a-2', name: 'USD wallet', currency: 'USD'),
              ],
            ),
          ),
          categoriesRepositoryProvider.overrideWith(
            (ref) => _FakeCategoriesRepository(
              categories: <Category>[
                _category(
                  id: 'c-1',
                  name: 'Transfers',
                  type: CategoryType.expense,
                ),
              ],
            ),
          ),
          transactionsRepositoryProvider.overrideWith(
            (ref) => _FakeTransactionsRepository(
              items: const <Transaction>[],
              onCreateTransfer:
                  ({
                    required fromAccountId,
                    required toAccountId,
                    required categoryId,
                    required amount,
                    required currency,
                    description,
                    required transactionDate,
                  }) async {
                    transferCalls += 1;
                  },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpSheet(
        tester,
        container: container,
        child: const TransferFormSheet(),
      );

      await _selectDropdown<String>(tester, 0, 'Main bank');

      await _selectDropdown<String>(tester, 1, 'USD wallet');

      await _selectDropdown<String>(tester, 2, 'Transfers');

      await tester.enterText(find.byType(TextFormField).first, '50');
      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Complete transfer',
      );
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(transferCalls, 0);
      expect(
        find.text('Transfers require matching account currencies.'),
        findsOneWidget,
      );
      expect(find.text('Transfer money'), findsOneWidget);
    },
  );

  testWidgets(
    'transfer form shows specific inline failure copy on submit error',
    (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          accountsRepositoryProvider.overrideWith(
            (ref) => _FakeAccountsRepository(
              accounts: <Account>[
                _account(id: 'a-1', name: 'Main bank', currency: 'TRY'),
                _account(id: 'a-2', name: 'Savings', currency: 'TRY'),
              ],
            ),
          ),
          categoriesRepositoryProvider.overrideWith(
            (ref) => _FakeCategoriesRepository(
              categories: <Category>[
                _category(
                  id: 'c-1',
                  name: 'Transfers',
                  type: CategoryType.expense,
                ),
              ],
            ),
          ),
          transactionsRepositoryProvider.overrideWith(
            (ref) => _FakeTransactionsRepository(
              items: const <Transaction>[],
              onCreateTransfer:
                  ({
                    required fromAccountId,
                    required toAccountId,
                    required categoryId,
                    required amount,
                    required currency,
                    description,
                    required transactionDate,
                  }) async {
                    throw const Failure.api(
                      code: ApiErrorCode.invalidTransfer,
                      message: 'Transfer failed.',
                    );
                  },
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpSheet(
        tester,
        container: container,
        child: const TransferFormSheet(),
      );

      await _selectDropdown<String>(tester, 0, 'Main bank');

      await _selectDropdown<String>(tester, 1, 'Savings');

      await _selectDropdown<String>(tester, 2, 'Transfers');

      await tester.enterText(find.byType(TextFormField).first, '50');
      final submitButton = find.widgetWithText(
        ElevatedButton,
        'Complete transfer',
      );
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Transfer money'), findsOneWidget);
      expect(
        find.text(
          'This transfer can no longer be reversed with the current account balances.',
        ),
        findsOneWidget,
      );
    },
  );
}
