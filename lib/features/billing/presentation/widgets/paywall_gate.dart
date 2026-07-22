import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// Pre-emptive client-side UX gate. This is not the enforcement layer — the
/// backend rejects premium calls independently (see [Failure] handling on
/// each feature's controller). This widget only avoids sending users into a
/// flow they cannot use.
class PaywallGate extends ConsumerWidget {
  const PaywallGate({
    super.key,
    required this.feature,
    required this.isUnlocked,
    required this.child,
  });

  final String feature;
  final bool Function(FeatureAccess features) isUnlocked;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(entitlementControllerProvider);

    return entitlement.when(
      data: (value) {
        if (isUnlocked(value.features)) {
          return child;
        }
        return _PaywallPrompt(feature: feature);
      },
      loading: () => const LoadingView(),
      error: (_, _) => child,
    );
  }
}

class _PaywallPrompt extends ConsumerStatefulWidget {
  const _PaywallPrompt({required this.feature});

  final String feature;

  @override
  ConsumerState<_PaywallPrompt> createState() => _PaywallPromptState();
}

class _PaywallPromptState extends ConsumerState<_PaywallPrompt> {
  @override
  void initState() {
    super.initState();
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logPaywallViewed(feature: widget.feature),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.lock_outline_rounded,
                  size: AppSpacing.giant,
                  color: context.colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.paywallLockedTitle,
                  style: context.textTheme.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.paywallLockedMessage,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/upgrade'),
                    child: Text(l10n.paywallUpgradeCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
