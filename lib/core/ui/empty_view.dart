import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.title,
    this.message,
    this.action,
    this.icon = Icons.inbox_outlined,
  });

  final String? title;
  final String? message;
  final Widget? action;

  /// Per-feature glyph — defaults to the generic inbox icon, but every
  /// feature's empty state should pass something that reflects its content
  /// (e.g. `Icons.receipt_long_outlined` for transactions).
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    icon,
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
          ),
        );
      },
    );
  }
}
