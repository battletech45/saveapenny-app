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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: package.packageType == PackageType.annual
              ? Theme.of(context).colorScheme.primary
              : context.colors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: <Widget>[
            if (package.packageType == PackageType.annual) ...<Widget>[
              Icon(
                Icons.workspace_premium_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(product.title, style: context.textTheme.title),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    product.priceString,
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  if (product.description.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      product.description,
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: isBusy ? null : onSelected,
              child: isBusy
                  ? const SizedBox(
                      width: AppSpacing.lg,
                      height: AppSpacing.lg,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context).paywallUpgradeCta),
            ),
          ],
        ),
      ),
    );
  }
}
