import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:saveapenny/core/analytics/analytics_service.dart';
import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/billing/application/purchase_controller.dart';
import 'package:saveapenny/features/upgrade/presentation/widgets/upgrade_package_card.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class UpgradeScreen extends ConsumerStatefulWidget {
  const UpgradeScreen({super.key});

  @override
  ConsumerState<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends ConsumerState<UpgradeScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(analyticsServiceProvider).logUpgradeScreenOpened());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offerings = ref.watch(billingOfferingsProvider);
    final purchaseState = ref.watch(purchaseControllerProvider);
    final isBusy = purchaseState.isLoading;

    ref.listen(purchaseControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_purchaseErrorMessage(l10n, error))),
        );
        ref.read(purchaseControllerProvider.notifier).clearFeedback();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.upgradeTitle)),
      body: SafeArea(
        child: offerings.when(
          data: (data) {
            final packages =
                data.current?.availablePackages ?? const <Package>[];
            if (packages.isEmpty) {
              return Center(child: Text(l10n.upgradeNoOfferingsMessage));
            }
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                Text(l10n.upgradeHeading, style: context.textTheme.title),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.upgradeSubtitle,
                  style: context.textTheme.body.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                for (final package in packages) ...<Widget>[
                  UpgradePackageCard(
                    package: package,
                    isBusy: isBusy,
                    onSelected: () => _purchase(package),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: TextButton(
                    onPressed: isBusy ? null : _restore,
                    child: Text(l10n.upgradeRestoreCta),
                  ),
                ),
              ],
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error is Failure
                ? error
                : Failure.unknown(message: error.toString()),
            onRetry: () async => ref.invalidate(billingOfferingsProvider),
          ),
        ),
      ),
    );
  }

  Future<void> _purchase(Package package) async {
    final l10n = AppLocalizations.of(context);
    final succeeded = await ref
        .read(purchaseControllerProvider.notifier)
        .purchase(package);
    if (!mounted || !succeeded) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.upgradeSuccessMessage)));
    unawaited(Navigator.of(context).maybePop());
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final succeeded = await ref
        .read(purchaseControllerProvider.notifier)
        .restore();
    if (!mounted || ref.read(purchaseControllerProvider).hasError) {
      // A thrown Failure is already surfaced by the ref.listen handler above.
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? l10n.upgradeRestoreSuccessMessage
              : l10n.upgradeRestoreFailureMessage,
        ),
      ),
    );
  }

  String _purchaseErrorMessage(AppLocalizations l10n, Object error) {
    if (error is Failure) {
      return switch (error) {
        NetworkFailure() => l10n.failureNetworkMessage,
        _ => l10n.upgradePurchaseFailedMessage,
      };
    }
    return l10n.upgradePurchaseFailedMessage;
  }
}
