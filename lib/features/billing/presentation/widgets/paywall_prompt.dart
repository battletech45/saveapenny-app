import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/billing/presentation/widgets/billing_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class PaywallPrompt extends ConsumerStatefulWidget {
  const PaywallPrompt({super.key, required this.feature});

  final String feature;

  @override
  ConsumerState<PaywallPrompt> createState() => _PaywallPromptState();
}

class _PaywallPromptState extends ConsumerState<PaywallPrompt> {
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
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: PremiumSurface.gradient(context),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Icon(
                      Icons.lock_open_outlined,
                      size: AppSpacing.giant,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
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
                const SizedBox(
                  width: double.infinity,
                  child: BillingUpgradeElevatedButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
