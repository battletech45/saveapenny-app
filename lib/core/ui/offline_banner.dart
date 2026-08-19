import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/network/connectivity_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// Persistent strip shown across every screen while [isOnlineProvider]
/// reports no connection. Informational, not an error: the app still shows
/// last-known data (see docs/adr/0003-offline-read-cache.md), so this uses
/// the warning treatment, not the expense/error one.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    if (isOnline) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: context.finance.warningSurface),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.cloud_off_rounded,
                size: 16,
                color: context.finance.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.offlineBannerMessage,
                  style: context.textTheme.label.copyWith(
                    color: context.finance.warning,
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
