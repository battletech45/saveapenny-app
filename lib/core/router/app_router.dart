import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/core/ui/app_shell.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/core/ui/navigation_hub_screen.dart';
import 'package:saveapenny/features/accounts/presentation/accounts_screen.dart';
import 'package:saveapenny/features/assistant/presentation/assistant_screen.dart';
import 'package:saveapenny/features/auth/presentation/login_screen.dart';
import 'package:saveapenny/features/auth/presentation/register_screen.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/presentation/widgets/paywall_gate.dart';
import 'package:saveapenny/features/budgets/presentation/budgets_screen.dart';
import 'package:saveapenny/features/categories/presentation/categories_screen.dart';
import 'package:saveapenny/features/credit_cards/presentation/credit_card_detail_screen.dart';
import 'package:saveapenny/features/dashboard/presentation/dashboard_screen.dart';
import 'package:saveapenny/features/feedback/presentation/feedback_detail_screen.dart';
import 'package:saveapenny/features/feedback/presentation/feedback_screen.dart';
import 'package:saveapenny/features/goals/presentation/goal_detail_screen.dart';
import 'package:saveapenny/features/goals/presentation/goals_screen.dart';
import 'package:saveapenny/features/imports/presentation/imports_screen.dart';
import 'package:saveapenny/features/insights/presentation/insight_detail_screen.dart';
import 'package:saveapenny/features/insights/presentation/insights_screen.dart';
import 'package:saveapenny/features/notifications/presentation/notifications_screen.dart';
import 'package:saveapenny/features/ocr/presentation/ocr_screen.dart';
import 'package:saveapenny/features/onboarding/application/onboarding_controller.dart';
import 'package:saveapenny/features/onboarding/presentation/onboarding_screen.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/recurring_transactions_screen.dart';
import 'package:saveapenny/features/reports/presentation/reports_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stock_detail_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stocks_screen.dart';
import 'package:saveapenny/features/transactions/presentation/transactions_screen.dart';
import 'package:saveapenny/features/upgrade/presentation/upgrade_screen.dart';
import 'package:saveapenny/features/users/presentation/profile_screen.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

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
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/upgrade',
        builder: (context, state) => const UpgradeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/money',
                builder: (context, state) => NavigationHubScreen(
                  title: AppLocalizations.of(context).navTransactions,
                  items: <NavigationHubItem>[
                    NavigationHubItem(
                      icon: Icons.receipt_long_rounded,
                      label: AppLocalizations.of(context).transactionsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/transactions')),
                    ),
                    NavigationHubItem(
                      icon: Icons.repeat_rounded,
                      label: AppLocalizations.of(
                        context,
                      ).recurringTransactionsTitle,
                      onTap: () => unawaited(
                        GoRouter.of(context).push('/recurring-transactions'),
                      ),
                    ),
                    NavigationHubItem(
                      icon: Icons.upload_file_rounded,
                      label: AppLocalizations.of(context).importsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/imports')),
                    ),
                    NavigationHubItem(
                      icon: Icons.document_scanner_rounded,
                      label: AppLocalizations.of(context).ocrTitle,
                      onTap: () => unawaited(GoRouter.of(context).push('/ocr')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/plan',
                builder: (context, state) => NavigationHubScreen(
                  title: AppLocalizations.of(context).navPlan,
                  items: <NavigationHubItem>[
                    NavigationHubItem(
                      icon: Icons.pie_chart_outline_rounded,
                      label: AppLocalizations.of(context).budgetsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/budgets')),
                    ),
                    NavigationHubItem(
                      icon: Icons.flag_rounded,
                      label: AppLocalizations.of(context).goalsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/goals')),
                    ),
                    NavigationHubItem(
                      icon: Icons.lightbulb_outline_rounded,
                      label: AppLocalizations.of(context).insightsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/insights')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => NavigationHubScreen(
                  title: AppLocalizations.of(context).navPortfolio,
                  items: <NavigationHubItem>[
                    NavigationHubItem(
                      icon: Icons.trending_up_rounded,
                      label: AppLocalizations.of(context).stocksTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/stocks')),
                    ),
                    NavigationHubItem(
                      icon: Icons.bar_chart_rounded,
                      label: AppLocalizations.of(context).reportsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/reports')),
                    ),
                  ],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/more',
                builder: (context, state) => NavigationHubScreen(
                  title: AppLocalizations.of(context).navMore,
                  items: <NavigationHubItem>[
                    NavigationHubItem(
                      icon: Icons.account_balance_outlined,
                      label: AppLocalizations.of(context).accountsTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/accounts')),
                    ),
                    NavigationHubItem(
                      icon: Icons.category_outlined,
                      label: AppLocalizations.of(context).categoriesTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/categories')),
                    ),
                    NavigationHubItem(
                      icon: Icons.auto_awesome_rounded,
                      label: AppLocalizations.of(context).assistantTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/assistant')),
                    ),
                    NavigationHubItem(
                      icon: Icons.person_outline_rounded,
                      label: AppLocalizations.of(context).profileTitle,
                      onTap: () =>
                          unawaited(GoRouter.of(context).push('/profile')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // Sub-routes defined at root level — push full-screen over the shell.
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/feedback',
        builder: (context, state) => const FeedbackScreen(),
      ),
      GoRoute(
        path: '/feedback/:feedbackId',
        builder: (context, state) => FeedbackDetailScreen(
          feedbackId: state.pathParameters['feedbackId']!,
        ),
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
        path: '/imports',
        builder: (context, state) => const PaywallGate(
          feature: 'csv_import',
          isUnlocked: _isCsvImportUnlocked,
          child: ImportsScreen(),
        ),
      ),
      GoRoute(
        path: '/ocr',
        builder: (context, state) => const PaywallGate(
          feature: 'ocr',
          isUnlocked: _isOcrUnlocked,
          child: OcrScreen(),
        ),
      ),
      GoRoute(
        path: '/budgets',
        builder: (context, state) => const BudgetsScreen(),
      ),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(
        path: '/goals/:goalId',
        builder: (context, state) =>
            GoalDetailScreen(goalId: state.pathParameters['goalId']!),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const PaywallGate(
          feature: 'insights',
          isUnlocked: _isInsightsUnlocked,
          child: InsightsScreen(),
        ),
      ),
      GoRoute(
        path: '/insights/:insightId',
        builder: (context, state) => PaywallGate(
          feature: 'insights',
          isUnlocked: _isInsightsUnlocked,
          child: InsightDetailScreen(
            insightId: state.pathParameters['insightId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/stocks',
        builder: (context, state) => const PaywallGate(
          feature: 'stocks',
          isUnlocked: _isStocksUnlocked,
          child: StocksScreen(),
        ),
      ),
      GoRoute(
        path: '/stocks/:symbol',
        builder: (context, state) => PaywallGate(
          feature: 'stocks',
          isUnlocked: _isStocksUnlocked,
          child: StockDetailScreen(symbol: state.pathParameters['symbol']!),
        ),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/accounts',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/accounts/:accountId/credit',
        builder: (context, state) => CreditCardDetailScreen(
          accountId: state.pathParameters['accountId']!,
        ),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) => const PaywallGate(
          feature: 'assistant',
          isUnlocked: _isAssistantUnlocked,
          child: AssistantScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    redirect: (context, state) {
      final isBooting = state.matchedLocation == '/boot';
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isOnboarding = state.matchedLocation == '/onboarding';

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

      final onboarding = ref.watch(onboardingControllerProvider);
      if (authStatus == AuthStatus.authenticated && !isOnboarding) {
        final hasOnboarded = onboarding.asData?.value;
        if (hasOnboarded == false) {
          return '/onboarding';
        }
      }

      if (authStatus == AuthStatus.authenticated &&
          isOnboarding &&
          onboarding.asData?.value == true) {
        return '/home';
      }

      if (authStatus == AuthStatus.unauthenticated && isBooting) {
        return '/login';
      }

      return null;
    },
  );
}

bool _isAssistantUnlocked(FeatureAccess features) => features.assistant;
bool _isInsightsUnlocked(FeatureAccess features) => features.insights;
bool _isStocksUnlocked(FeatureAccess features) => features.stocks;
bool _isOcrUnlocked(FeatureAccess features) => features.ocr;
bool _isCsvImportUnlocked(FeatureAccess features) => features.csvImport;

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: LoadingView()));
  }
}
