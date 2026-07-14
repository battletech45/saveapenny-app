# SaveAPenny — Production & Monetization Playbook

Client-side playbook for taking the app from feature-complete to store-ready.
Every module works. Nobody has designed what it feels like to open the app.
This is the gap between a working codebase and a product someone pays for —
and a concrete plan to close it.

## Where it stands

Most apps at this stage have the opposite problem — pretty screens over a
shaky backend contract. SaveAPenny inverted it: a disciplined `Failure`-typed
network layer, a fully specified design system with income/expense semantics,
tabular money, dark mode, and 4pt spacing already codified in `tokens.dart` —
and fourteen features (accounts, transactions, budgets, categories, goals,
recurring transactions, reports, stocks, imports, insights, OCR, assistant,
notifications, users) built to that spec, each with tests.

What's missing isn't craft, it's **direction** — the app doesn't yet tell a
new user what it's for in the first five seconds, doesn't group its 19 routes
into something a thumb can navigate, and has no mechanism to turn any of this
into revenue.

Snapshot:
- 14 feature verticals shipped end-to-end
- 1 "dashboard" screen, and it's a placeholder
- 0 monetization hooks in the codebase
- 0 analytics / crash reporting wired

## Priority zero: fix the home screen before anything else

Everything below matters, but this is the single highest-leverage change
available, and it requires no new backend work — every number it needs
already exists in a repository that's already built.

**The home route is a development scaffold, not a product.** `_HomeScreen` in
`lib/core/router/app_router.dart` is named "Phase Zero preview" in its own
source (`PhaseZeroPreviewState`, `phaseZeroPlaceholderTitle`). It renders a
hard-coded balance (`2450.75 TRY`, never read from `accounts`), a vertical
stack of fourteen identical "go to X" cards in router-registration order, and
a segmented control that lets you preview loading/empty/error states for
nothing in particular. This is what every user sees immediately after
registering.

- No net worth or account balance actually pulled from `AccountsRepository`
- No signal on what needs attention — an over-budget category, a bill due
  tomorrow, a goal falling behind
- No sense of hierarchy: Assistant, Profile, and Categories all get the same
  visual weight as Transactions
- The loading/empty/error segmented-button demo is debug tooling left in a
  production route

**What to build instead:** a real dashboard — hero net worth in
`displayMoney` style pulled from `reports/net_worth_snapshot`, a this-month
income/expense pair from `monthly_summary`, an "attention" strip surfacing
over-budget categories (`budget_status` already models this) and upcoming
bills (`upcoming_recurring_transaction`), then a scannable list of accounts —
not a router directory.

**Why it's cheap to build:** every data point above is already served by an
existing, tested repository (`reports`, `budgets`, `recurring_transactions`,
`accounts`). This is an aggregation and layout problem — one new
`DashboardController` composing four existing `FutureProvider`s — not a new
backend integration.

### Implementation spec: `features/dashboard/`

New feature slice, following the existing layered convention (no `data/`
layer of its own — it composes other features' repositories, which the
architecture doc's "collapse for small features" allowance covers).

```
features/dashboard/
  domain/
    dashboard_snapshot.dart        # freezed aggregate, see below
  application/
    dashboard_controller.dart      # @riverpod FutureProvider-style AsyncNotifier
  presentation/
    dashboard_screen.dart
    widgets/
      net_worth_hero.dart
      cash_flow_summary_card.dart
      attention_strip.dart
      upcoming_bills_list.dart
      account_row.dart
```

**`domain/dashboard_snapshot.dart`** — one freezed aggregate the controller
returns, so the screen has a single `AsyncValue` to `.when()` on:

```dart
@freezed
abstract class DashboardSnapshot with _$DashboardSnapshot {
  const factory DashboardSnapshot({
    required NetWorthSnapshot netWorth,       // features/reports/domain/net_worth_snapshot.dart
    required MonthlySummary monthlySummary,   // features/reports/domain/monthly_summary.dart
    required List<Account> accounts,          // features/accounts/domain/account.dart
    required List<BudgetStatus> atRiskBudgets, // features/budgets/domain/budget_status.dart
    required List<UpcomingRecurringTransaction> upcomingBills, // features/recurring_transactions/domain
  }) = _DashboardSnapshot;
}
```

**`application/dashboard_controller.dart`** — mirror the existing
`AsyncNotifier` + `AsyncValue.guard` convention from §7 of `CLAUDE.md`:

```dart
@riverpod
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

    final results = await Future.wait(<Future<Object?>>[
      reports.netWorthSnapshot(snapshotDate: now),
      reports.monthlySummary(from: monthStart, to: now),
      accounts.list(),
      budgets.list(period: BudgetPeriod.monthly, size: 5), // free-tier cap is 3 anyway
      recurring.upcoming(limit: 5),
    ]);

    final budgetList = results[3] as PaginatedData<Budget>;
    // budgets_api has no bulk "all statuses" endpoint — fan out per budget.
    // Bounded by the size:5 above, so this is at most 5 requests, acceptable
    // for a dashboard load. Flag to backend team as a future
    // GET /budgets/status?period=... batch endpoint if this feature grows.
    final statuses = await Future.wait(
      budgetList.items.map((b) => budgets.status(b.id)),
    );

    return DashboardSnapshot(
      netWorth: results[0] as NetWorthSnapshot,
      monthlySummary: results[1] as MonthlySummary,
      accounts: results[2] as List<Account>,
      atRiskBudgets: statuses
          .where((s) => s.status != BudgetHealth.onTrack)
          .toList(growable: false),
      upcomingBills: results[4] as List<UpcomingRecurringTransaction>,
    );
  }
}
```

**Known caveat:** there is no bulk budget-status endpoint today
(`BudgetsApi.status(String budgetId)` is the only call). The fan-out above is
fine at the free-tier cap of 3–5 active budgets; revisit if budgets scale up.

**`presentation/dashboard_screen.dart`** — screen design, top to bottom:

```
┌─────────────────────────────────────┐
│  Home                          🔔②  │  ← AppBar: title + notif icon w/ badge
├─────────────────────────────────────┤
│  NET WORTH                          │  ← label, textTheme.label, textSecondary
│                         ₺48,250.00  │  ← displayMoney, right-aligned, hero
├─────────────────────────────────────┤
│ ┌───────────────┐ ┌───────────────┐ │
│ │ Income   ↑     │ │ Expense  ↓    │ │  ← CashFlowSummaryCard, 2-col row
│ │ +₺12,400.00    │ │ −₺7,180.50    │ │     income/expense tokens, money style
│ └───────────────┘ └───────────────┘ │
├─────────────────────────────────────┤
│ ⚠ Groceries 92%   ⛔ Dining 118%  →  │  ← AttentionStrip, horiz scroll chips
├─────────────────────────────────────┤
│  Upcoming                           │  ← title
│  Netflix         Jul 18    −₺149.00 │  ← UpcomingBillsList, up to 5 rows
│  Rent            Jul 20  −₺18,500.00│
├─────────────────────────────────────┤
│  Accounts                           │  ← title
│  🏦 Bank · TRY            ₺32,400   │  ← AccountRow × N, tappable
│  💵 Cash · TRY             ₺2,850   │
└─────────────────────────────────────┘
                                  (+)    ← FAB → TransactionFormSheet
```

```dart
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshot = ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => GoRouter.of(context).go('/notifications'),
            icon: const Icon(Icons.notifications_outlined),
            tooltip: l10n.navHome,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTransactionFormSheet(context), // existing helper
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: snapshot.when(
          loading: () => const LoadingView(),
          error: (err, _) => FailureView(
            failure: err as Failure,
            onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
          ),
          data: (data) => RefreshIndicator(
            onRefresh: () => ref.read(dashboardControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                NetWorthHero(netWorth: data.netWorth),
                const SizedBox(height: AppSpacing.xl),
                CashFlowSummaryCard(summary: data.monthlySummary),
                const SizedBox(height: AppSpacing.lg),
                if (data.atRiskBudgets.isNotEmpty) ...<Widget>[
                  AttentionStrip(budgets: data.atRiskBudgets),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (data.upcomingBills.isNotEmpty) ...<Widget>[
                  Text(l10n.dashboardUpcomingBillsTitle, style: context.textTheme.title),
                  const SizedBox(height: AppSpacing.sm),
                  UpcomingBillsList(bills: data.upcomingBills),
                  const SizedBox(height: AppSpacing.xl),
                ],
                Text(l10n.dashboardAccountsTitle, style: context.textTheme.title),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Column(
                    children: <Widget>[
                      for (final account in data.accounts)
                        AccountRow(account: account),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.giant), // clears the FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart
// widgets/net_worth_hero.dart
class NetWorthHero extends StatelessWidget {
  const NetWorthHero({super.key, required this.netWorth});

  final NetWorthSnapshot netWorth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatted = MoneyFormatter.format(
      context: context,
      amount: netWorth.netWorth,
      currencyCode: 'TRY', // TODO: derive from primary/default account once multi-currency lands
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.dashboardNetWorthLabel,
              style: context.textTheme.label.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                formatted.text,
                style: context.textTheme.displayMoney.copyWith(color: formatted.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart
// widgets/cash_flow_summary_card.dart
class CashFlowSummaryCard extends StatelessWidget {
  const CashFlowSummaryCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _CashFlowTile(
            label: l10n.dashboardMonthlyIncomeLabel,
            amount: summary.totalIncome,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _CashFlowTile(
            label: l10n.dashboardMonthlyExpenseLabel,
            amount: -summary.totalExpense, // force negative sign per design-system rule
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }
}

class _CashFlowTile extends StatelessWidget {
  const _CashFlowTile({required this.label, required this.amount, required this.icon});

  final String label;
  final num amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final formatted = MoneyFormatter.format(context: context, amount: amount, currencyCode: 'TRY');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: 16, color: formatted.color),
                const SizedBox(width: AppSpacing.xs),
                Text(label, style: context.textTheme.label.copyWith(color: context.colors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(formatted.text, style: context.textTheme.money.copyWith(color: formatted.color, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
```

```dart
// widgets/attention_strip.dart
class AttentionStrip extends StatelessWidget {
  const AttentionStrip({super.key, required this.budgets});

  final List<BudgetStatus> budgets; // pre-filtered to warning/exceeded by the controller

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: budgets.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final exceeded = budget.status == BudgetHealth.exceeded;
          final bg = exceeded ? context.finance.expenseSurface : context.finance.warningSurface;
          final fg = exceeded ? context.finance.expense : context.finance.warning;

          return ActionChip(
            backgroundColor: bg,
            side: BorderSide.none,
            avatar: Icon(exceeded ? Icons.error_rounded : Icons.warning_rounded, size: 16, color: fg),
            label: Text(
              '${budget.category} ${budget.usagePercentage.round()}%',
              style: context.textTheme.label.copyWith(color: fg),
            ),
            onPressed: () => GoRouter.of(context).go('/budgets'),
          );
        },
      ),
    );
  }
}
```

```dart
// widgets/upcoming_bills_list.dart
class UpcomingBillsList extends StatelessWidget {
  const UpcomingBillsList({super.key, required this.bills});

  final List<UpcomingRecurringTransaction> bills;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Column(
        children: <Widget>[
          for (final bill in bills)
            ListTile(
              onTap: () => GoRouter.of(context).go('/recurring-transactions'),
              title: Text(bill.name ?? l10n.recurringTransactionUnnamed, style: context.textTheme.body),
              subtitle: Text(
                DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format(bill.scheduledDate),
                style: context.textTheme.label.copyWith(color: context.colors.textSecondary),
              ),
              trailing: Text(
                MoneyFormatter.format(context: context, amount: -bill.amount, currencyCode: 'TRY').text,
                style: context.textTheme.money.copyWith(color: context.finance.expense),
              ),
            ),
        ],
      ),
    );
  }
}
```

```dart
// widgets/account_row.dart
class AccountRow extends StatelessWidget {
  const AccountRow({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final formatted = MoneyFormatter.format(context: context, amount: account.balance, currencyCode: account.currency);
    return ListTile(
      onTap: () => GoRouter.of(context).go('/accounts'),
      leading: CircleAvatar(
        backgroundColor: context.colors.surfaceSubtle,
        child: Icon(_iconFor(account.type), color: context.colors.textSecondary),
      ),
      title: Text(account.name, style: context.textTheme.body),
      subtitle: Text(
        '${_labelFor(account.type)} · ${account.currency}',
        style: context.textTheme.label.copyWith(color: context.colors.textSecondary),
      ),
      trailing: Text(formatted.text, style: context.textTheme.money.copyWith(color: formatted.color)),
    );
  }

  IconData _iconFor(AccountType type) => switch (type) {
    AccountType.cash => Icons.payments_outlined,
    AccountType.bank => Icons.account_balance_outlined,
    AccountType.credit => Icons.credit_card_outlined,
    AccountType.savings => Icons.savings_outlined,
    AccountType.investment => Icons.trending_up_outlined,
  };

  String _labelFor(AccountType type) => switch (type) {
    AccountType.cash => 'Cash',
    AccountType.bank => 'Bank',
    AccountType.credit => 'Credit',
    AccountType.savings => 'Savings',
    AccountType.investment => 'Investment',
  }; // TODO: replace with l10n.accountType* lookups, not hardcoded English
}
```

**l10n:** add `dashboardNetWorthLabel`, `dashboardMonthlyIncomeLabel`,
`dashboardMonthlyExpenseLabel`, `dashboardUpcomingBillsTitle`,
`dashboardAccountsTitle` to both `lib/l10n/app_en.arb` and `app_tr.arb`
(camelCase key convention, matches existing `homeTitle`/`commonRetry` style).
Delete every `phaseZero*` key once `_HomeScreen` is removed.

**Acceptance criteria:**
- [ ] `/home` route resolves to `DashboardScreen`, not `_HomeScreen`
- [ ] Net worth, monthly income/expense, and account balances are read from
      live repositories, not hardcoded values
- [ ] Loading/empty/error states use `LoadingView`/`EmptyView`/`FailureView`,
      no debug state-picker in production build
- [ ] Attention strip only renders when at least one budget is `warning` or
      `exceeded`
- [ ] `flutter analyze` clean, `dashboard_controller_test.dart` covers happy
      path + one thrown-`Failure` path (mock all four repositories)

## Navigation shell: nineteen flat routes need to become five destinations

`app_router.dart` registers every screen as a sibling `GoRoute` with no
shell — navigating anywhere is `context.go('/x')`, which replaces the stack
rather than switching tabs. There is no persistent bottom navigation anywhere
in the app.

**Move to a `StatefulShellRoute`.** `go_router: ^17.3.0` is already in
`pubspec.yaml` — it supports this natively, no dependency change required.
Group the 19 routes into a 4-tab persistent shell, each preserving its own
navigation stack:

| Tab | Owns | Reasoning |
|---|---|---|
| **Home** | dashboard, notifications entry | the "what's going on" surface |
| **Transactions** | transactions, recurring, imports, OCR entry | everything about money moving |
| **Plan** | budgets, goals, insights | forward-looking, premium-leaning |
| **Portfolio** | stocks, reports | the analytical / investing surface |
| **More** | accounts, categories, assistant, profile, settings | configuration, not daily-use |

This also fixes a quieter problem: `flutter_secure_storage` holds the
session, but nothing today gives the user a consistent "where am I" — five
destinations with icons and a persistent selection state solve that for
free.

### Implementation spec: shell route in `app_router.dart`

Replace the flat `routes: <RouteBase>[...]` list (currently lines 88–161)
with a `StatefulShellRoute.indexedStack`, keeping every existing screen
class unchanged — only the routing wrapper changes:

```dart
GoRoute(path: '/boot', builder: (context, state) => const _BootScreen()),
GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
GoRoute(
  path: '/upgrade',
  builder: (context, state) => UpgradeScreen(from: state.uri.queryParameters['from']),
),
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) =>
      AppShell(navigationShell: navigationShell),
  branches: <StatefulShellBranch>[
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
    ]),
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
      GoRoute(path: '/recurring-transactions', builder: (context, state) => const RecurringTransactionsScreen()),
      GoRoute(path: '/imports', builder: (context, state) => const ImportsScreen()),
      GoRoute(path: '/ocr', builder: (context, state) => const OcrScreen()),
    ]),
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/budgets', builder: (context, state) => const BudgetsScreen()),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(path: '/goals/:goalId', builder: (context, state) => GoalDetailScreen(goalId: state.pathParameters['goalId']!)),
      GoRoute(path: '/insights', builder: (context, state) => const InsightsScreen()),
      GoRoute(path: '/insights/:insightId', builder: (context, state) => InsightDetailScreen(insightId: state.pathParameters['insightId']!)),
    ]),
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/stocks', builder: (context, state) => const StocksScreen()),
      GoRoute(path: '/stocks/:symbol', builder: (context, state) => StockDetailScreen(symbol: state.pathParameters['symbol']!)),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
    ]),
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
      GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
      GoRoute(path: '/assistant', builder: (context, state) => const AssistantScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
    ]),
  ],
),
```

The `redirect` callback (currently lines 162–187) is unchanged — it operates
on `state.matchedLocation`, which still resolves correctly under a shell
route.

**New file `core/ui/app_shell.dart`:**

```
┌─────────────────────────────────────┐
│                                      │
│         navigationShell             │  ← active branch's own Navigator
│      (current tab's screen)         │
│                                      │
├─────────────────────────────────────┤
│  🏠      🧾      🚩      📈      ⋯  │  ← NavigationBar, 5 destinations
│ Home  Transact. Plan  Portfolio More│     selected = filled icon + label
└─────────────────────────────────────┘
```

```dart
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home_rounded), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.receipt_long_outlined), selectedIcon: const Icon(Icons.receipt_long_rounded), label: l10n.navTransactions),
          NavigationDestination(icon: const Icon(Icons.flag_outlined), selectedIcon: const Icon(Icons.flag_rounded), label: l10n.navPlan),
          NavigationDestination(icon: const Icon(Icons.trending_up_outlined), selectedIcon: const Icon(Icons.trending_up_rounded), label: l10n.navPortfolio),
          NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), label: l10n.navMore),
        ],
      ),
    );
  }
}
```

`NavigationBar` is Material 3 and already available (no new dependency) —
confirm `ThemeData(useMaterial3: true)` is set in `AppTheme.light()`/`dark()`
(default in current Flutter, but verify since `app_theme.dart` predates this
plan). Style via `NavigationBarThemeData` in `app_theme.dart` referencing
`AppColors`/tokens, not inline colors, per the design-system hard rule.

**l10n:** add `navHome`, `navTransactions`, `navPlan`, `navPortfolio`,
`navMore` to both ARB files.

**Acceptance criteria:**
- [ ] Switching tabs preserves each branch's own navigation stack (e.g.
      drilling into a goal, switching to Transactions, switching back to
      Plan returns to the goal detail screen, not the goals list)
- [ ] `/boot`, `/login`, `/register` remain outside the shell
- [ ] Deep link to e.g. `/goals/:goalId` selects the correct tab and stack
- [ ] Existing route-level tests / `integration_test/auth_flow_test.dart`
      still pass unmodified (the redirect contract didn't change)

## Screen-by-screen polish, against the spec you already wrote

`DESIGN_SYSTEM.md` is genuinely well specified. The gap is enforcement —
auditing that every screen actually uses it, and filling the handful of
experience gaps the spec doesn't cover yet.

- **Onboarding (missing entirely).** Today, `AuthController` routes straight
  from `register` success to `/home` with zero accounts and zero categories.
  Gate a new `/onboarding` route with a `hasOnboarded` bool in
  `flutter_secure_storage` (add a key next to the existing token storage in
  `SecureTokenStore`) so it only shows once, inserted into `app_router.dart`'s
  redirect logic: authenticated + `!hasOnboarded` → `/onboarding`. Full spec
  below.
- **Empty states (audit).** `core/ui/empty_view.dart` already accepts a
  `title`, `message`, and `action` widget — the mechanism is right. Grep
  every `EmptyView(` call site (`accounts`, `budgets`, `categories`, `goals`,
  `transactions`, `recurring_transactions`, `stocks`) and confirm each one
  passes a non-null `action` (typically an `ElevatedButton` opening that
  feature's existing form sheet) instead of relying on the generic
  `l10n.emptyStateTitle`/`emptyStateMessage` defaults — those defaults say
  nothing about what the screen is for.
- **Money motion (nice-to-have).** `MoneyFormatter.format` (in
  `core/formatting/money_formatter.dart`) returns static `FormattedMoney`
  text today. Add `core/ui/animated_money.dart`: an `ImplicitlyAnimatedWidget`
  or `TweenAnimationBuilder<num>` over `AppDuration.slow` (300ms,
  `Curves.easeInOutCubic` per the spec) that re-runs `MoneyFormatter.format`
  each frame with the interpolated value. Use it for `NetWorthHero` on the
  new dashboard specifically — that's the one number users will watch change.
- **Forms and sheets (audit).** Confirm every `*_form_sheet.dart` (budget,
  category, goal, recurring transaction, stock holding, transaction,
  transfer — 7 files under `features/*/presentation/widgets/`) hits the 48×48
  touch-target minimum on buttons/icon-buttons and the outlined-input
  focus/error states from `DESIGN_SYSTEM.md`, at both 1.0× and 1.3× text
  scale (`MediaQuery.textScalerOf` override in a widget test, or device
  accessibility settings manually). None of this is new code — it's a
  checklist pass with fixes as `flutter analyze`-clean small diffs per file.

### Implementation spec: `features/onboarding/`

```
features/onboarding/
  application/
    onboarding_controller.dart   # @riverpod, wraps SecureTokenStore's hasOnboarded flag
  presentation/
    onboarding_screen.dart
    widgets/
      onboarding_page.dart
```

```
┌─────────────────────────────────────┐
│                                      │
│                                      │
│         [ illustration/icon ]       │  ← Icon at giant size, finance.info tint
│                                      │
│         See where it goes           │  ← headline, textTheme.headline
│                                      │
│   Track every account and expense   │  ← body, textSecondary, centered
│   in one place, in TRY or any       │
│   currency you use.                 │
│                                      │
│                                      │
│         ●  ○  ○                     │  ← PageView dot indicator
│                                      │
│  [ Skip ]              [ Next → ]   │  ← tertiary + primary button row
└─────────────────────────────────────┘
```
Three pages share this layout, differing only in icon/headline/body:
1. "See where it goes" — accounts + transactions overview
2. "Plan without the spreadsheet" — budgets + goals
3. "Know before it happens" — insights + assistant (soft-sells Plus, without naming price yet)

The 3rd page's primary button reads `l10n.onboardingGetStarted` and, instead
of "Next", opens the existing `AccountFormSheet` (`accounts/presentation`)
directly — the user's very first action is creating one real account, not
landing on an empty dashboard.

```dart
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(icon: Icons.account_balance_wallet_outlined, headlineKey: 'onboardingPage1Headline', bodyKey: 'onboardingPage1Body'),
    _OnboardingPageData(icon: Icons.flag_outlined, headlineKey: 'onboardingPage2Headline', bodyKey: 'onboardingPage2Body'),
    _OnboardingPageData(icon: Icons.insights_outlined, headlineKey: 'onboardingPage3Headline', bodyKey: 'onboardingPage3Body'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: <Widget>[
                  for (final page in _pages) OnboardingPage(data: page),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (var i = 0; i < _pages.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          width: i == _page ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _page ? context.colors.textPrimary : context.colors.border,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      if (!isLast)
                        TextButton(
                          onPressed: () => _complete(context),
                          child: Text(l10n.onboardingSkip),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => isLast ? _complete(context) : _controller.nextPage(
                          duration: AppDuration.base,
                          curve: Curves.easeInOutCubic,
                        ),
                        child: Text(isLast ? l10n.onboardingGetStarted : l10n.commonContinue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    await ref.read(onboardingControllerProvider.notifier).markOnboarded();
    if (context.mounted) GoRouter.of(context).go('/home');
  }
}
```

`onboarding_controller.dart` is a thin wrapper — no async loading state
needed, so a plain `@riverpod` function-notifier is enough:

```dart
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  void build() {}

  Future<void> markOnboarded() {
    return ref.read(secureTokenStoreProvider).setHasOnboarded(true);
  }
}
```

**l10n:** `onboardingPage1Headline/Body` through `onboardingPage3Headline/Body`,
`onboardingSkip`, `onboardingGetStarted` — both ARB files.

**Acceptance criteria:**
- [ ] Shows exactly once per account (persisted flag, not per-session)
- [ ] "Skip" and "Get started" both land on `/home` (skip does not open the account sheet)
- [ ] Dot indicator and buttons meet the 48×48 touch target rule
- [ ] Existing `register` → `/home` redirect test updated to expect `/onboarding` first on a fresh account

## Monetization: freemium, with the premium tier already half-built

The backend already ships feature flags — `ASSISTANT_DISABLED`,
`STOCK_DISABLED`, `INSIGHTS_DISABLED`, `GOAL_PROGRESS_DISABLED` — that exist
to answer "does this feature exist right now." A subscription entitlement is
a different question — "does *this user's plan* unlock it" — and the two
should sit side by side, not be conflated.

| Capability | Free | SaveAPenny Plus |
|---|---|---|
| Accounts, transactions, categories | Unlimited | Unlimited |
| Budgets | Up to 3 active | Unlimited |
| Goals + scenarios | 1 active goal | Unlimited + what-if simulation |
| Reports history | Last 3 months | Full history + export |
| Recurring transactions | Manual entry only | Automated scheduling |
| Receipt OCR | — | Unlimited scans |
| AI assistant | — | Included |
| Automated insights | — | Included |
| Stock portfolio tracking | — | Included |
| CSV import | — | Included |

**Billing stack.** Add `purchases_flutter` (RevenueCat) to `pubspec.yaml`
rather than raw `in_app_purchase` — it absorbs StoreKit 2 / Play Billing v6
differences and receipt validation, and reports subscription events you'll
want for the analytics funnel below.

### Implementation spec: `core/billing/`

```
core/billing/
  entitlement.dart              # freezed: Entitlement { plan: Plan, expiresAt, isActive }
  entitlement_controller.dart   # @riverpod(keepAlive: true), same shape as AuthSessionController
  paywall_gate.dart             # shared gating widget
```

```dart
enum Plan { free, plus }

@freezed
abstract class Entitlement with _$Entitlement {
  const factory Entitlement({required Plan plan, DateTime? expiresAt}) = _Entitlement;
}

@Riverpod(keepAlive: true)
class EntitlementController extends _$EntitlementController {
  @override
  Future<Entitlement> build() async {
    final customerInfo = await Purchases.getCustomerInfo();
    final isPlus = customerInfo.entitlements.active.containsKey('plus');
    return Entitlement(plan: isPlus ? Plan.plus : Plan.free);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => build());
  }
}
```

`PaywallGate` wraps a feature's entry point (screen or a specific action) the
same way `FailureView`/`EmptyView` wrap async states — it's a peer component,
not a special case:

```dart
class PaywallGate extends ConsumerWidget {
  const PaywallGate({super.key, required this.feature, required this.child, this.teaser});

  final String feature; // for analytics: which paywall was shown
  final Widget child;
  final Widget? teaser; // shown instead of a hard lock, see placement below

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementControllerProvider);
    return entitlement.when(
      data: (e) => e.plan == Plan.plus ? child : (teaser ?? _UpgradeCard(feature: feature)),
      loading: () => const LoadingView(),
      error: (_, __) => child, // fail open: never block a paying-looking user on a billing hiccup
    );
  }
}
```

**`_UpgradeCard`** — the in-place teaser `PaywallGate` falls back to when a
screen doesn't supply its own `teaser`:

```
┌─────────────────────────────────────┐
│                                      │
│              ✨                     │  ← accent-tinted icon, not a lock
│                                      │
│      This is a Plus feature         │  ← title
│                                      │
│  Unlock the AI assistant, receipt   │  ← body, textSecondary
│  scanning, and automated insights   │
│  with SaveAPenny Plus.              │
│                                      │
│  [       See Plus plans →      ]    │  ← primary button, full width
│                                      │
└─────────────────────────────────────┘
```

```dart
class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.feature});

  final String feature;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.auto_awesome_rounded, size: AppSpacing.giant, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.paywallTitle, style: context.textTheme.title, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.paywallBody, style: context.textTheme.body.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => GoRouter.of(context).push('/upgrade?from=$feature'),
                child: Text(l10n.paywallCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Dedicated `/upgrade` screen** — reached from any `_UpgradeCard` CTA or a
"Go Plus" entry in the More tab / profile screen. This is where the actual
purchase happens, so it needs the plan comparison, not just a single teaser
line:

```
┌─────────────────────────────────────┐
│  ←                                   │
│                                      │
│           SaveAPenny Plus            │  ← headline, centered
│      Everything, automated.          │  ← subtitle
│                                      │
│  ✓ Unlimited budgets & goals         │  ← checklist, one line per
│  ✓ Full report history + export      │     Free vs Plus table row
│  ✓ Automated recurring transactions  │
│  ✓ Receipt scanning (OCR)            │
│  ✓ AI assistant                      │
│  ✓ Automated insights                │
│  ✓ Stock portfolio tracking          │
│                                      │
│ ┌─────────────┐  ┌─────────────────┐│
│ │   Monthly    │  │  Annual  -40%  ││  ← plan toggle, annual pre-selected
│ │   ₺129/mo    │  │  ₺899/yr ✓     ││     (SegmentedButton, not two cards
│ └─────────────┘  └─────────────────┘│      fighting for primary color)
│                                      │
│      7-day free trial included      │  ← label, textSecondary, only on annual
│                                      │
│  [      Start free trial       ]    │  ← primary, full width, 48pt
│                                      │
│   Restore purchases · Terms         │  ← text buttons, label size
└─────────────────────────────────────┘
```

```dart
class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key, this.from});

  final String? from; // which paywall referred here, for analytics

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  _Plan _selected = _Plan.annual;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final purchase = ref.watch(purchaseControllerProvider); // AsyncNotifier<void>, tracks in-flight purchase

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text(l10n.upgradeHeadline, style: context.textTheme.headline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.upgradeSubtitle, style: context.textTheme.body.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            for (final line in _kPlusFeatureKeys)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.check_rounded, size: 18, color: context.finance.income),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(line(l10n), style: context.textTheme.body)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
            SegmentedButton<_Plan>(
              segments: <ButtonSegment<_Plan>>[
                ButtonSegment(value: _Plan.monthly, label: Text(l10n.upgradeMonthly)),
                ButtonSegment(value: _Plan.annual, label: Text(l10n.upgradeAnnualDiscounted)),
              ],
              selected: <_Plan>{_selected},
              onSelectionChanged: (s) => setState(() => _selected = s.first),
            ),
            if (_selected == _Plan.annual) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.upgradeTrialIncluded, style: context.textTheme.label.copyWith(color: context.colors.textSecondary), textAlign: TextAlign.center),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: purchase.isLoading ? null : () => ref.read(purchaseControllerProvider.notifier).purchase(_selected),
                child: purchase.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_selected == _Plan.annual ? l10n.upgradeStartTrial : l10n.upgradeSubscribe),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => ref.read(entitlementControllerProvider.notifier).refresh(),
                child: Text(l10n.upgradeRestorePurchases),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

`purchase.isLoading` disabling the button (rather than hiding/re-enabling
based on a boolean flag) matches the existing pattern in `AuthController`'s
logout button in the current `_HomeScreen`. `purchaseControllerProvider`
wraps `Purchases.purchasePackage(...)` and, on success, calls
`ref.invalidate(entitlementControllerProvider)` so `PaywallGate`s across the
app immediately reflect the new plan.

**l10n:** `upgradeHeadline`, `upgradeSubtitle`, `upgradeMonthly`,
`upgradeAnnualDiscounted`, `upgradeTrialIncluded`, `upgradeStartTrial`,
`upgradeSubscribe`, `upgradeRestorePurchases`, `paywallTitle`, `paywallBody`,
`paywallCta` — both ARB files. `_kPlusFeatureKeys` is a `List<String
Function(AppLocalizations)>` pulling one localized line per row of the
Free/Plus table above (`upgradeFeatureUnlimitedBudgets`, etc.) — keep it in
sync with that table by hand since it's presentation copy, not derived data.

**Acceptance criteria:**
- [ ] Route registered at `/upgrade` (outside the shell — it's a modal-style
      flow, push not a tab) with optional `from` query param for analytics
- [ ] Annual pre-selected by default (higher AOV); trial copy only shows for annual
- [ ] Successful purchase invalidates `entitlementControllerProvider` and
      pops back to whichever `PaywallGate` sent the user here, now showing `child`
- [ ] "Restore purchases" works without requiring a fresh purchase attempt
- [ ] Purchase failure surfaces a `SnackBar`/dialog with a retry, never a
      silent no-op on the disabled button

**Paywall placement.** Soft paywall, not hard block, on Assistant, Insights,
Stocks, and OCR (the four screens registered in `app_router.dart` at
`/assistant`, `/insights`, `/stocks`, `/ocr`) — wrap each screen's `build`
with `PaywallGate(feature: 'assistant', teaser: <one free reply / one teased
insight>, child: <the real screen>)` so a user sees real value once before
being asked to pay, rather than a locked icon on first tap.

**Relationship to server feature flags:** `ApiErrorCode.assistantDisabled` /
`stockDisabled` / `insightsDisabled` (in `api_error_code.dart`) answer "is
this feature live on the backend at all" and are handled today via
`FailureView`'s existing `isFeatureDisabled` branch — leave that path
untouched. `PaywallGate` sits in front of it and answers a different
question ("does this user's plan unlock it"); a request can fail either
check independently.

**Pricing and trial.** Bilingual TR/EN plus ISO-4217-aware accounts point at
Turkey as a primary market alongside global — price in both USD and TRY
tiers rather than a single US-anchored price. A reasonable starting point:
monthly at a standard finance-utility rate with an annual plan discounted
roughly 40%, plus a 7-day free trial gated to the annual plan to lift
trial-to-paid conversion. Treat the actual numbers as a hypothesis to test,
not a fixed answer.

## New dependencies required

Add to `pubspec.yaml` `dependencies:` (check `pub.dev` for the current stable
line at implementation time — pin the same way existing deps are pinned,
`^major.minor.patch`):

| Package | For | Notes |
|---|---|---|
| `purchases_flutter` | Billing (RevenueCat) | requires native RevenueCat dashboard setup + App Store Connect / Play Console product IDs before it can be tested end-to-end |
| `sentry_flutter` **or** `firebase_crashlytics` | Crash reporting | pick one; Sentry needs no Firebase project, Crashlytics is free if already on Firebase for push |
| `firebase_analytics` **or** `posthog_flutter` | Analytics | if push notifications go through FCM, Firebase Analytics is close to free to add alongside it |
| `firebase_messaging` | Push notifications | only if push is in scope for this phase; otherwise defer to the "Ongoing" roadmap row |

No changes needed to existing dependencies (`go_router`, `flutter_riverpod`,
etc. are all already sufficient versions for everything specified above).

## Store readiness: what's missing before a submission

- [ ] **App icon & splash screen** — `flutter_launcher_icons` and
  `flutter_native_splash` are already dev dependencies, but their config
  blocks are commented out in `pubspec.yaml` (lines 65–77). The app currently
  ships the default Flutter icon.
- [ ] **Crash reporting** — nothing in `pubspec.yaml` reports crashes today
  (no `sentry_flutter` / `firebase_crashlytics`). Add one before beta.
- [ ] **Analytics** — no event tracking exists. At minimum, instrument
  signup, first transaction created, paywall viewed, and purchase completed —
  the four events that let you see whether the dashboard/onboarding/paywall
  changes above actually work.
- [ ] **Push notifications** — the `notifications` feature is pull-only
  today (list + read state, no `firebase_messaging`/APNs). Push is
  high-leverage here specifically: budget-exceeded and bill-due alerts drive
  re-opens and are natural upsell moments toward Plus.
- [ ] **Privacy policy & data disclosure** — required by both stores given
  financial transaction data and IAP; map what's actually collected (email,
  transaction data, secure tokens) to Apple's App Privacy labels and Play's
  Data Safety form.
- [ ] **Subscription compliance** — Apple requires subscriptions sold in the
  app to go through IAP (guideline 3.1.1); RevenueCat handles this correctly
  by construction, a custom payment sheet would not.
- [ ] **Store screenshots** — worth capturing only after the dashboard
  rebuild; screenshots of the current placeholder home would undersell the
  app.

## Suggested order of work

| When | Work |
|---|---|
| Weeks 1–2 | Dashboard rebuild + bottom-nav shell — no new backend work, pure aggregation of existing repositories and a `StatefulShellRoute` restructure. Highest-leverage single change. |
| Week 3 | Onboarding + empty-state audit — close the "empty app on day one" gap and confirm every empty view carries a real call to action. |
| Weeks 4–6 | Billing integration — RevenueCat wiring, `EntitlementController`, and paywall UI on Assistant / Insights / Stocks / OCR. |
| Week 7 | Instrumentation — analytics, crash reporting, real app icon and splash assets. |
| Ongoing | Push notifications for retention, privacy/compliance review, and screenshots captured against the finished dashboard. |

---

Grounded in the current state of `saveapenny-app` as of this review —
`app_router.dart`, `DESIGN_SYSTEM.md`, `tokens.dart`, and `pubspec.yaml`.
Re-check package versions before implementing; this is a plan, not a diff.
