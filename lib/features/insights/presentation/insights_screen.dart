import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/insights/application/insights_controller.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_filter_card.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_shared.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_tile.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final insightsState = ref.watch(insightsControllerProvider);
    final controller = ref.read(insightsControllerProvider.notifier);
    final current = insightsState.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.insightsTitle),
        actions: <Widget>[
          IconButton(
            onPressed: current == null || current.isGenerating
                ? null
                : () => _generateInsights(context, controller),
            tooltip: l10n.insightsGenerateCta,
            icon: current?.isGenerating == true
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: insightsState.when(
          data: (data) => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                InsightFilterCard(
                  unreadOnly: data.unreadOnly,
                  selectedType: data.type,
                  selectedSeverity: data.severity,
                  onUnreadChanged: (value) =>
                      controller.setUnreadOnly(unreadOnly: value),
                  onTypeChanged: (value) => controller.setFilters(
                    type: value,
                    severity: data.severity,
                  ),
                  onSeverityChanged: (value) =>
                      controller.setFilters(type: data.type, severity: value),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (data.items.isEmpty)
                  InsightInlineEmptyState(
                    title: data.unreadOnly
                        ? l10n.insightsUnreadEmptyTitle
                        : l10n.insightsEmptyTitle,
                    message: data.unreadOnly
                        ? l10n.insightsUnreadEmptyMessage
                        : l10n.insightsEmptyMessage,
                  )
                else ...<Widget>[
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        background: const InsightDismissBackground(),
                        confirmDismiss: (_) =>
                            _dismissInsight(context, controller, item.id),
                        child: InsightTile(
                          insight: item,
                          onTap: () => _openInsight(context, controller, item),
                        ),
                      ),
                    ),
                  ),
                  if (data.hasNext) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: controller.loadMore,
                      child: Text(l10n.insightsLoadMoreCta),
                    ),
                  ],
                ],
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: controller.refresh,
          ),
        ),
      ),
    );
  }

  Future<void> _generateInsights(
    BuildContext context,
    InsightsController controller,
  ) async {
    try {
      final generatedCount = await controller.generate();
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).insightsGenerateSuccessMessage(generatedCount),
            ),
          ),
        );
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(insightFailureMessage(context, failure))),
        );
    }
  }

  Future<void> _openInsight(
    BuildContext context,
    InsightsController controller,
    Insight insight,
  ) async {
    try {
      if (!insight.read) {
        await controller.markRead(insight.id);
      }
      if (!context.mounted) {
        return;
      }
      await GoRouter.of(context).push('/insights/${insight.id}');
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(insightFailureMessage(context, failure))),
        );
    }
  }

  Future<bool> _dismissInsight(
    BuildContext context,
    InsightsController controller,
    String insightId,
  ) async {
    try {
      await controller.dismiss(insightId);
      return true;
    } on Failure catch (failure) {
      if (!context.mounted) {
        return false;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(insightFailureMessage(context, failure))),
        );
      return false;
    }
  }
}
