import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/billing/application/entitlement_controller.dart';
import 'package:saveapenny/features/billing/domain/feature_access.dart';
import 'package:saveapenny/features/billing/presentation/widgets/paywall_prompt.dart';

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
        return PaywallPrompt(feature: feature);
      },
      loading: () => const LoadingView(),
      error: (_, _) => PaywallPrompt(feature: feature),
    );
  }
}
