import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/feedback/application/feedback_detail_controller.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_shared.dart';
import 'package:saveapenny/features/users/presentation/widgets/profile_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class FeedbackDetailScreen extends ConsumerWidget {
  const FeedbackDetailScreen({super.key, required this.feedbackId});

  final String feedbackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feedbackState = ref.watch(
      feedbackDetailControllerProvider(feedbackId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.feedbackDetailTitle),
        actions: <Widget>[
          IconButton(
            onPressed: feedbackState.isLoading
                ? null
                : () => _confirmDelete(context, ref),
            tooltip: l10n.feedbackDeleteCta,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: feedbackState.when(
          data: (feedback) => RefreshIndicator(
            onRefresh: () => ref
                .read(feedbackDetailControllerProvider(feedbackId).notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          feedbackTypeLabel(context, feedback.type),
                          style: context.textTheme.headline,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ProfileInfoRow(
                          label: l10n.feedbackRatingLabel,
                          value: feedbackRatingLabel(context, feedback.rating),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ProfileInfoRow(
                          label: l10n.feedbackSubmittedAtLabel,
                          value: formatFeedbackDateTime(
                            context,
                            feedback.createdAt,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ProfileInfoRow(
                          label: l10n.feedbackUpdatedAtLabel,
                          value: formatFeedbackDateTime(
                            context,
                            feedback.updatedAt,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          l10n.feedbackMessageLabel,
                          style: context.textTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(feedback.message, style: context.textTheme.body),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(feedbackDetailControllerProvider(feedbackId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.feedbackDeleteTitle),
          content: Text(l10n.feedbackDeleteMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.feedbackDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(feedbackDetailControllerProvider(feedbackId).notifier)
          .delete();
      if (!context.mounted) {
        return;
      }
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.feedbackDeleteSuccessMessage)),
        );
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(feedbackFailureMessage(context, failure))),
        );
    }
  }
}
