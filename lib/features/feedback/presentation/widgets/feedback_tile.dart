import 'package:flutter/material.dart' hide Feedback;

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/star_rating.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class FeedbackTile extends StatelessWidget {
  const FeedbackTile({
    super.key,
    required this.feedback,
    required this.onTap,
    required this.onDelete,
  });

  final Feedback feedback;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _FeedbackTypeIcon(type: feedback.type),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          feedbackTypeLabel(context, feedback.type),
                          style: context.textTheme.body,
                        ),
                        FeedbackStatusBadge(status: feedback.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      feedback.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.body,
                    ),
                    if (feedback.rating != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      StarRating(value: feedback.rating!, starSize: 18),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      formatFeedbackDateTime(context, feedback.createdAt),
                      style: context.textTheme.label.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: l10n.feedbackDeleteCta,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedbackTypeIcon extends StatelessWidget {
  const _FeedbackTypeIcon({required this.type});

  final FeedbackType type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      FeedbackType.general => Icons.feedback_outlined,
      FeedbackType.featureRequest => Icons.tips_and_updates_outlined,
      FeedbackType.bugReport => Icons.bug_report_outlined,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
