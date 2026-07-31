import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/feedback/application/feedback_list_controller.dart';
import 'package:saveapenny/features/feedback/domain/feedback.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_form_sheet.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_shared.dart';
import 'package:saveapenny/features/feedback/presentation/widgets/feedback_tile.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final feedbackState = ref.watch(feedbackListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.feedbackTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'feedbackFab',
        onPressed: () => _showFeedbackSheet(context),
        icon: const Icon(Icons.feedback_outlined),
        label: Text(l10n.feedbackSubmitCta),
      ),
      body: SafeArea(
        child: feedbackState.when(
          data: (data) {
            if (data.items.isEmpty) {
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(feedbackListControllerProvider.notifier).refresh(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    _FeedbackFilterCard(
                      currentFilter: data.typeFilter,
                      onChanged: (type) => ref
                          .read(feedbackListControllerProvider.notifier)
                          .setTypeFilter(type),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _FeedbackEmptyState(
                      onSubmit: () => _showFeedbackSheet(context),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(feedbackListControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: data.items.length + (data.hasNext ? 2 : 1),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _FeedbackFilterCard(
                      currentFilter: data.typeFilter,
                      onChanged: (type) => ref
                          .read(feedbackListControllerProvider.notifier)
                          .setTypeFilter(type),
                    );
                  }

                  final itemIndex = index - 1;
                  if (itemIndex == data.items.length) {
                    return OutlinedButton(
                      onPressed: () => ref
                          .read(feedbackListControllerProvider.notifier)
                          .loadMore(),
                      child: Text(l10n.feedbackLoadMoreCta),
                    );
                  }

                  final feedback = data.items[itemIndex];
                  return FeedbackTile(
                    feedback: feedback,
                    onTap: () => context.push('/feedback/${feedback.id}'),
                    onDelete: () => _confirmDelete(context, ref, feedback.id),
                  );
                },
              ),
            );
          },
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(feedbackListControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showFeedbackSheet(BuildContext context) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) =>
          const FeedbackFormSheet(sourceScreen: 'feedback_list'),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String feedbackId,
  ) async {
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
          .read(feedbackListControllerProvider.notifier)
          .deleteFeedback(feedbackId);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
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

class _FeedbackFilterCard extends StatelessWidget {
  const _FeedbackFilterCard({
    required this.currentFilter,
    required this.onChanged,
  });

  final FeedbackType? currentFilter;
  final ValueChanged<FeedbackType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.feedbackFilterTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<FeedbackType?>(
              initialValue: currentFilter,
              decoration: InputDecoration(labelText: l10n.feedbackFilterLabel),
              items: <DropdownMenuItem<FeedbackType?>>[
                DropdownMenuItem<FeedbackType?>(
                  value: null,
                  child: Text(l10n.feedbackFilterAllTypes),
                ),
                ...FeedbackType.values.map(
                  (type) => DropdownMenuItem<FeedbackType?>(
                    value: type,
                    child: Text(feedbackTypeLabel(context, type)),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackEmptyState extends StatelessWidget {
  const _FeedbackEmptyState({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.feedback_outlined,
              color: context.colors.textTertiary,
              size: AppSpacing.giant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.feedbackEmptyTitle,
              style: context.textTheme.title,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.feedbackEmptyMessage,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onSubmit,
              child: Text(l10n.feedbackSubmitFirstCta),
            ),
          ],
        ),
      ),
    );
  }
}
