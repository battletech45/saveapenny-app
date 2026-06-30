import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, this.title, this.message, this.action});

  final String? title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.inbox_outlined,
              color: context.colors.textTertiary,
              size: AppSpacing.giant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title ?? l10n.emptyStateTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message ?? l10n.emptyStateMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
