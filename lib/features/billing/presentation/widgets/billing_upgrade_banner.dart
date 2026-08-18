import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/billing/presentation/widgets/billing_shared.dart';

class BillingUpgradeBanner extends StatelessWidget {
  const BillingUpgradeBanner({
    super.key,
    required this.message,
    required this.ctaLabel,
    this.leading,
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
          gradient: PremiumSurface.gradient(context),
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
                    Text(
                      message,
                      style: context.textTheme.body.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BillingUpgradeTextButton(label: ctaLabel),
            ],
          ),
        ),
      ),
    );
  }
}
