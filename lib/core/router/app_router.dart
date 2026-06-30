import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

enum AuthStatus { authenticated, unauthenticated }

@Riverpod(keepAlive: true)
AuthStatus authStatus(Ref ref) {
  // Phase 0 keeps routing deterministic until the real auth slice lands.
  return AuthStatus.authenticated;
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authStatus = ref.watch(authStatusProvider);

  return GoRouter(
    initialLocation: '/home',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => const _LoginScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const _HomeScreen()),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      if (authStatus == AuthStatus.unauthenticated && !isLoggingIn) {
        return '/login';
      }
      if (authStatus == AuthStatus.authenticated && isLoggingIn) {
        return '/home';
      }
      return null;
    },
  );
}

class _HomeScreen extends ConsumerWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final previewBalance = MoneyFormatter.format(
      context: context,
      amount: 2450.75,
      currencyCode: 'TRY',
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: AppSpacing.xxl),
              const Expanded(child: EmptyView()),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text(l10n.commonNotAvailable, style: context.textTheme.body),
        ),
      ),
    );
  }
}
