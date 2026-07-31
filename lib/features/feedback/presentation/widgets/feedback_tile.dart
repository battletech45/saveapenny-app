import 'package:flutter/material.dart' hide Feedback;

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        title: Text(feedbackTypeLabel(context, feedback.type)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              feedback.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.body,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              formatFeedbackDateTime(context, feedback.createdAt),
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'delete',
              child: Text(l10n.feedbackDeleteCta),
            ),
          ],
        ),
      ),
    );
  }
}
