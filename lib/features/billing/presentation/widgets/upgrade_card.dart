import 'package:flutter/material.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/billing/presentation/widgets/billing_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// Compact upsell surface for entry points outside a full-screen paywall
/// gate (e.g. profile screen, settings).
class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: PremiumSurface.gradient(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.workspace_premium_rounded,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.upgradeCardTitle,
                    style: context.textTheme.title.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.upgradeCardMessage,
                    style: context.textTheme.body.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const BillingUpgradeTextButton(),
          ],
        ),
      ),
    );
  }
}
