import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/presentation/accounts_screen.dart';
import 'package:saveapenny/features/auth/application/auth_controller.dart';
import 'package:saveapenny/features/auth/presentation/login_screen.dart';
import 'package:saveapenny/features/auth/presentation/register_screen.dart';
import 'package:saveapenny/features/budgets/presentation/budgets_screen.dart';
import 'package:saveapenny/features/categories/presentation/categories_screen.dart';
import 'package:saveapenny/features/goals/presentation/goal_detail_screen.dart';
import 'package:saveapenny/features/goals/presentation/goals_screen.dart';
import 'package:saveapenny/features/notifications/presentation/notifications_screen.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/recurring_transactions_screen.dart';
import 'package:saveapenny/features/reports/presentation/reports_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stock_detail_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stocks_screen.dart';
import 'package:saveapenny/features/transactions/presentation/transactions_screen.dart';
import 'package:saveapenny/features/users/presentation/profile_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

enum PhaseZeroPreviewState { loading, empty, error, data }

@Riverpod(keepAlive: true)
class AuthSessionController extends _$AuthSessionController {
  @override
  AuthStatus build() {
    unawaited(_initialize());
    return AuthStatus.checking;
  }

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthStatus.unauthenticated;
  }

  Future<void> _initialize() async {
    final tokenStore = ref.read(secureTokenStoreProvider);
    final accessToken = await tokenStore.readAccessToken();

    state = accessToken != null && accessToken.isNotEmpty
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }
}

@Riverpod(keepAlive: true)
class PhaseZeroPreviewController extends _$PhaseZeroPreviewController {
  @override
  PhaseZeroPreviewState build() {
    return PhaseZeroPreviewState.data;
  }

  void setState(PhaseZeroPreviewState nextState) {
    state = nextState;
  }
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authStatus = ref.watch(authSessionControllerProvider);

  return GoRouter(
    initialLocation: '/boot',
    routes: <RouteBase>[
      GoRoute(path: '/boot', builder: (context, state) => const _BootScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(
        path: '/goals/:goalId',
        builder: (context, state) =>
            GoalDetailScreen(goalId: state.pathParameters['goalId']!),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/recurring-transactions',
        builder: (context, state) => const RecurringTransactionsScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/stocks',
        builder: (context, state) => const StocksScreen(),
      ),
      GoRoute(
        path: '/stocks/:symbol',
        builder: (context, state) =>
            StockDetailScreen(symbol: state.pathParameters['symbol']!),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const _HomeScreen()),
    ],
    redirect: (context, state) {
      final isBooting = state.matchedLocation == '/boot';
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';

      if (authStatus == AuthStatus.checking) {
        return isBooting ? null : '/boot';
      }

      if (authStatus == AuthStatus.unauthenticated &&
          !isLoggingIn &&
          !isRegistering) {
        return '/login';
      }

      if (authStatus == AuthStatus.authenticated &&
          (isLoggingIn || isRegistering || isBooting)) {
        return '/home';
      }

      if (authStatus == AuthStatus.unauthenticated && isBooting) {
        return '/login';
      }

      return null;
    },
  );
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: LoadingView()));
  }
}

class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final previewState = ref.watch(phaseZeroPreviewControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final previewBalance = MoneyFormatter.format(
      context: context,
      amount: 2450.75,
      currencyCode: 'TRY',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          IconButton(
            onPressed: authState.isLoading
                ? null
                : () async {
                    await ref.read(authControllerProvider.notifier).logout();
                  },
            tooltip: l10n.homeSignOutCta,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.phaseZeroPlaceholderTitle,
                      style: context.textTheme.title,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.phaseZeroPlaceholderBody,
                      style: context.textTheme.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      l10n.phaseZeroBalanceLabel,
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        previewBalance.text,
                        style: context.textTheme.displayMoney.copyWith(
                          color: previewBalance.color,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.profileHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.profileHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/accounts'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.accountsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.accountsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/categories'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.categoriesHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.categoriesHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/goals'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.goalsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.goalsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/budgets'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.budgetsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.budgetsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/transactions'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.transactionsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.transactionsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/recurring-transactions'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.recurringTransactionsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.recurringTransactionsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/reports'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.reportsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.reportsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/stocks'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.stocksHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.stocksHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => GoRouter.of(context).go('/notifications'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.notificationsHomeCardTitle,
                              style: context.textTheme.title,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.notificationsHomeCardSubtitle,
                              style: context.textTheme.body.copyWith(
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.phaseZeroPreviewStatesTitle,
              style: context.textTheme.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<PhaseZeroPreviewState>(
                segments: <ButtonSegment<PhaseZeroPreviewState>>[
                  ButtonSegment<PhaseZeroPreviewState>(
                    value: PhaseZeroPreviewState.loading,
                    label: Text(l10n.phaseZeroStateLoading),
                  ),
                  ButtonSegment<PhaseZeroPreviewState>(
                    value: PhaseZeroPreviewState.empty,
                    label: Text(l10n.phaseZeroStateEmpty),
                  ),
                  ButtonSegment<PhaseZeroPreviewState>(
                    value: PhaseZeroPreviewState.error,
                    label: Text(l10n.phaseZeroStateError),
                  ),
                  ButtonSegment<PhaseZeroPreviewState>(
                    value: PhaseZeroPreviewState.data,
                    label: Text(l10n.phaseZeroStateData),
                  ),
                ],
                selected: <PhaseZeroPreviewState>{previewState},
                onSelectionChanged: (selection) {
                  ref
                      .read(phaseZeroPreviewControllerProvider.notifier)
                      .setState(selection.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 200,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _PreviewStateBody(state: previewState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewStateBody extends ConsumerWidget {
  const _PreviewStateBody({required this.state});

  final PhaseZeroPreviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return switch (state) {
      PhaseZeroPreviewState.loading => const LoadingView(),
      PhaseZeroPreviewState.empty => const EmptyView(),
      PhaseZeroPreviewState.error => FailureView(
        failure: const Failure.network(),
        onRetry: () async {
          ref
              .read(phaseZeroPreviewControllerProvider.notifier)
              .setState(PhaseZeroPreviewState.data);
        },
      ),
      PhaseZeroPreviewState.data => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.phaseZeroDataTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.phaseZeroDataMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    };
  }
}
