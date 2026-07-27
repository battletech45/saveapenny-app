import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// Inline "N of M used" upsell banner for capped free-tier flows (budgets,
/// goals). Purely informational UX — the backend is the enforcement layer
/// (see `PaywallGate`/`docs/MONETIZATION_IMPLEMENTATION_PLAN.md`). Renders
/// nothing when the plan has no cap (`max == null`, i.e. Plus) or the cap
/// hasn't been reached yet.
class PlanLimitBanner extends StatelessWidget {
  const PlanLimitBanner({
    super.key,
    required this.used,
    required this.max,
    required this.message,
  });

  final int used;
  final int? max;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cap = max;
    if (cap == null || used < cap) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);

    return _Banner(
      leading: Text(
        l10n.planLimitUsageLabel(used, cap),
        style: context.textTheme.label.copyWith(
          color: context.colors.textSecondary,
        ),
      ),
      message: message,
      ctaLabel: l10n.planLimitReachedCta,
    );
  }
}

/// Inline banner for a boolean-locked capability within an otherwise
/// available flow (e.g. automated recurring processing, full report
/// history) — the manual/limited baseline stays usable.
class PlanLockedFeatureBanner extends StatelessWidget {
  const PlanLockedFeatureBanner({
    super.key,
    required this.isUnlocked,
    required this.message,
  });

  final bool isUnlocked;
  final String message;

  @override
  Widget build(BuildContext context) {
    if (isUnlocked) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);

    return _Banner(
      leading: null,
      message: message,
      ctaLabel: l10n.planLimitReachedCta,
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.leading,
    required this.message,
    required this.ctaLabel,
  });

  final Widget? leading;
  final String message;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (leading != null) ...<Widget>[
                      leading!,
                      const SizedBox(height: AppSpacing.xs),
                    ],
                    Text(message, style: context.textTheme.body),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              TextButton(
                onPressed: () => context.push('/upgrade'),
                child: Text(ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
