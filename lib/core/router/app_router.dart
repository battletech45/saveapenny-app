import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/empty_view.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

part 'app_router.g.dart';

enum AuthStatus { authenticated, unauthenticated }

enum PhaseZeroPreviewState { loading, empty, error, data }

@Riverpod(keepAlive: true)
class AuthSessionController extends _$AuthSessionController {
  @override
  AuthStatus build() {
    // Phase 0 still boots into the placeholder shell until the auth slice lands.
    return AuthStatus.authenticated;
  }

  void setAuthenticated() {
    state = AuthStatus.authenticated;
  }

  void setUnauthenticated() {
    state = AuthStatus.unauthenticated;
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
    final previewState = ref.watch(phaseZeroPreviewControllerProvider);
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
              Expanded(
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
      PhaseZeroPreviewState.data => Column(
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
    };
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
