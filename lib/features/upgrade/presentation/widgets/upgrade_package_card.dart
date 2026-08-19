import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class UpgradePackageCard extends StatelessWidget {
  const UpgradePackageCard({
    super.key,
    required this.package,
    required this.isBusy,
    required this.onSelected,
  });

  final Package package;
  final bool isBusy;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final featured = package.packageType == PackageType.annual;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: featured ? PremiumSurface.gradient(context) : null,
        color: featured ? null : context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: featured
              ? Theme.of(context).colorScheme.primary
              : context.colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: featured
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Icon(
                      featured
                          ? Icons.workspace_premium_rounded
                          : Icons.lock_open_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.title,
                        style: context.textTheme.title.copyWith(
                          color: featured
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.priceString,
                        style: context.textTheme.headline.copyWith(
                          color: featured
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.description.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                product.description,
                style: context.textTheme.body.copyWith(
                  color: featured
                      ? Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.76)
                      : context.colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton(
              onPressed: isBusy ? null : onSelected,
              style: featured
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              child: isBusy
                  ? const SizedBox(
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context).paywallUpgradeCta),
            ),
            if (featured) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withValues(alpha: 0.16),
              ),
              const SizedBox(height: AppSpacing.md),
              Icon(
                Icons.verified_rounded,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
