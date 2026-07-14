import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/storage/secure_token_store.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/accounts/presentation/accounts_screen.dart';
import 'package:saveapenny/features/assistant/presentation/assistant_screen.dart';
import 'package:saveapenny/features/auth/presentation/login_screen.dart';
import 'package:saveapenny/features/auth/presentation/register_screen.dart';
import 'package:saveapenny/features/budgets/presentation/budgets_screen.dart';
import 'package:saveapenny/features/categories/presentation/categories_screen.dart';
import 'package:saveapenny/features/dashboard/presentation/dashboard_screen.dart';
import 'package:saveapenny/features/goals/presentation/goal_detail_screen.dart';
import 'package:saveapenny/features/goals/presentation/goals_screen.dart';
import 'package:saveapenny/features/imports/presentation/imports_screen.dart';
import 'package:saveapenny/features/insights/presentation/insight_detail_screen.dart';
import 'package:saveapenny/features/insights/presentation/insights_screen.dart';
import 'package:saveapenny/features/notifications/presentation/notifications_screen.dart';
import 'package:saveapenny/features/ocr/presentation/ocr_screen.dart';
import 'package:saveapenny/features/recurring_transactions/presentation/recurring_transactions_screen.dart';
import 'package:saveapenny/features/reports/presentation/reports_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stock_detail_screen.dart';
import 'package:saveapenny/features/stocks/presentation/stocks_screen.dart';
import 'package:saveapenny/features/transactions/presentation/transactions_screen.dart';
import 'package:saveapenny/features/users/presentation/profile_screen.dart';

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
        path: '/assistant',
        builder: (context, state) => const AssistantScreen(),
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
      GoRoute(
        path: '/imports',
        builder: (context, state) => const ImportsScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/insights/:insightId',
        builder: (context, state) =>
            InsightDetailScreen(insightId: state.pathParameters['insightId']!),
      ),
      GoRoute(path: '/ocr', builder: (context, state) => const OcrScreen()),
      GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
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

