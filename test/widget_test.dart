import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:saveapenny/app.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_envelope.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/router/app_router.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/features/accounts/data/accounts_repository.dart';
import 'package:saveapenny/features/accounts/domain/account.dart';
import 'package:saveapenny/features/accounts/domain/accounts_repository.dart';
import 'package:saveapenny/features/auth/data/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_repository.dart';
import 'package:saveapenny/features/auth/domain/auth_session.dart';
import 'package:saveapenny/features/budgets/data/budgets_repository.dart';
import 'package:saveapenny/features/budgets/domain/budget.dart';
import 'package:saveapenny/features/budgets/domain/budget_status.dart';
import 'package:saveapenny/features/budgets/domain/budgets_repository.dart';
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

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Empty-data dashboard dependencies so any test that lands on the
/// authenticated `/home` shell resolves [dashboardControllerProvider]
/// without hitting real network calls. Content of the dashboard itself is
/// covered by dashboard_controller_test.dart; these tests only care about
/// routing/localization/auth around it.
///
/// Left untyped (no `List<Override>` annotation) because `Override` is not
/// re-exported by `package:flutter_riverpod/flutter_riverpod.dart` — only by
/// `package:riverpod/misc.dart`, which isn't otherwise needed here. Type
/// inference resolves it correctly without spelling the name.
final _dashboardDependencyOverrides = [
  reportsRepositoryProvider.overrideWith(
    (ref) => const _EmptyReportsRepository(),
  ),
  accountsRepositoryProvider.overrideWith(
    (ref) => const _EmptyAccountsRepository(),
  ),
  budgetsRepositoryProvider.overrideWith(
    (ref) => const _EmptyBudgetsRepository(),
  ),
  recurringTransactionsRepositoryProvider.overrideWith(
    (ref) => const _EmptyRecurringTransactionsRepository(),
  ),
];

class _EmptyReportsRepository implements ReportsRepository {
  const _EmptyReportsRepository();

  @override
  Future<NetWorthSnapshot> netWorthSnapshot({
    required DateTime snapshotDate,
  }) async {
    return NetWorthSnapshot(
      snapshotDate: snapshotDate,
      totalAssets: 0,
      totalLiabilities: 0,
      netWorth: 0,
    );
  }

  @override
  Future<MonthlySummary> monthlySummary({
    required DateTime from,
    required DateTime to,
  }) async {
    return MonthlySummary(
      startDate: from,
      endDate: to,
      totalIncome: 0,
      totalExpense: 0,
      netSavings: 0,
    );
  }

  @override
  Future<List<CategorySpending>> categorySpending({
    required DateTime from,
    required DateTime to,
  }) async => <CategorySpending>[];

  @override
  Future<List<CashFlowPoint>> cashFlow({
    required DateTime from,
    required DateTime to,
  }) async => <CashFlowPoint>[];
}

class _EmptyAccountsRepository implements AccountsRepository {
  const _EmptyAccountsRepository();

  @override
  Future<List<Account>> list() async => <Account>[];

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

class _EmptyBudgetsRepository implements BudgetsRepository {
  const _EmptyBudgetsRepository();

  @override
  Future<PaginatedData<Budget>> list({
    BudgetPeriod? period,
    int page = 0,
    int size = 20,
    String sort = 'startDate,desc',
  }) async {
    return PaginatedData<Budget>(
      items: const <Budget>[],
      page: 0,
      size: 5,
      totalItems: 0,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  Future<BudgetStatus> status(String budgetId) => throw UnimplementedError();

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

class _EmptyRecurringTransactionsRepository
    implements RecurringTransactionsRepository {
  const _EmptyRecurringTransactionsRepository();

  @override
  Future<List<UpcomingRecurringTransaction>> upcoming({int limit = 10}) async =>
      <UpcomingRecurringTransaction>[];

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

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.onLogin, this.onRegister});

  final Future<AuthSession> Function(String email, String password)? onLogin;
  final Future<AuthSession> Function(
    String email,
    String password,
    String fullName,
  )?
  onRegister;

  @override
  Future<AuthSession> login({required String email, required String password}) {
    return onLogin!(email, password);
  }

  @override
  Future<void> logout() {
    return Future<void>.value();
  }

  @override
  Future<AuthSession> refresh() {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
  }) {
    return onRegister!(email, password, fullName);
  }
}

void main() {
  testWidgets('app routes unauthenticated users to login on startup', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('login screen navigates to register screen', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Set up your account'), findsOneWidget);
    expect(find.text('Full name'), findsOneWidget);
  });

  testWidgets('login password visibility toggle shows and hides the password', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(_passwordEditableText(tester).obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();

    expect(_passwordEditableText(tester).obscureText, isTrue);
  });

  testWidgets(
    'register password visibility toggle shows and hides the password',
    (WidgetTester tester) async {
      final storage = _MockFlutterSecureStorage();
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureTokenStoreProvider.overrideWith(
              (ref) => SecureTokenStore(storage: storage),
            ),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();

      expect(_passwordEditableText(tester).obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(_passwordEditableText(tester).obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(_passwordEditableText(tester).obscureText, isTrue);
    },
  );

  testWidgets('login completes the guarded flow to the dashboard', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onLogin: (email, password) async => const AuthSession(
              accessToken: 'access-1',
              refreshToken: 'refresh-1',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
          ),
        ),
        ..._dashboardDependencyOverrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'altay@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    // Sign-out now lives on the profile screen rather than the dashboard's
    // app bar, so the logout half of this cycle is covered separately once
    // that screen has its own widget test.
    // "Home" now appears twice: the dashboard app bar title and the shell's
    // bottom nav destination label.
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('register success authenticates and routes to home', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onRegister: (email, password, fullName) async => const AuthSession(
              accessToken: 'access-1',
              refreshToken: 'refresh-1',
              tokenType: 'Bearer',
              expiresIn: 900,
            ),
          ),
        ),
        ..._dashboardDependencyOverrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Altay Yilmaz');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'altay@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'secret');
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('register surfaces invalid password failure copy', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => null);

    final container = ProviderContainer(
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        authRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(
            onRegister: (email, password, fullName) async {
              throw const Failure.api(
                code: ApiErrorCode.invalidPassword,
                message: 'Weak password',
              );
            },
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Altay Yilmaz');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'altay@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '123');
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();

    expect(
      find.text('The password does not meet the server requirements.'),
      findsOneWidget,
    );
    expect(find.text('Set up your account'), findsOneWidget);
  });

  testWidgets('session expiry routes an authenticated user back to login', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        ..._dashboardDependencyOverrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);

    container.read(authSessionControllerProvider.notifier).setUnauthenticated();
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('app boots authenticated users to the dashboard shell', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [
          secureTokenStoreProvider.overrideWith(
            (ref) => SecureTokenStore(storage: storage),
          ),
          ..._dashboardDependencyOverrides,
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('authenticated shell localizes the dashboard app bar title', (
    WidgetTester tester,
  ) async {
    final storage = _MockFlutterSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'access-token');

    tester.binding.platformDispatcher.localeTestValue = const Locale('tr');
    tester.binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('tr'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    final container = ProviderContainer(
      retry: (retryCount, error) => null,
      overrides: [
        secureTokenStoreProvider.overrideWith(
          (ref) => SecureTokenStore(storage: storage),
        ),
        ..._dashboardDependencyOverrides,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const App()),
    );
    await tester.pumpAndSettle();

    // Dashboard body content (net worth, accounts, etc.) depends on live
    // repositories and is covered by dashboard_controller_test.dart and
    // future dashboard widget tests instead — this only pins that routing
    // + localization land on the authenticated shell's app bar. "Ana
    // Sayfa" appears twice: the app bar title and the bottom nav label.
    expect(find.text('Ana Sayfa'), findsWidgets);
  });
}

EditableText _passwordEditableText(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText).last);
}
