import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/formatting/relative_time_formatter.dart';
import 'package:saveapenny/core/network/connectivity_service.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

/// "Updated Xh ago", shown next to screens backed by
/// [ResponseCacheStore]-fallback data — only while offline, so it never
/// competes with a normal live screen for attention. See
/// docs/adr/0003-offline-read-cache.md.
class CacheStalenessLabel extends ConsumerWidget {
  const CacheStalenessLabel({super.key, required this.lastSyncedAt});

  final DateTime? lastSyncedAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final syncedAt = lastSyncedAt;
    if (isOnline || syncedAt == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final relative = RelativeTimeFormatter.bucket(syncedAt);
    final label = switch (relative.unit) {
      RelativeTimeUnit.justNow => l10n.lastSyncedJustNow,
      RelativeTimeUnit.minutes => l10n.lastSyncedMinutes(relative.count),
      RelativeTimeUnit.hours => l10n.lastSyncedHours(relative.count),
      RelativeTimeUnit.days => l10n.lastSyncedDays(relative.count),
    };

    return Text(
      label,
      style: context.textTheme.label.copyWith(
        color: context.colors.textTertiary,
      ),
    );
  }
}
