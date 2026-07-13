import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/insights/application/insights_controller.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/presentation/insight_detail_screen.dart';
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
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
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
                _FilterCard(
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
                  _InlineEmptyState(
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
                        background: const _DismissBackground(),
                        confirmDismiss: (_) =>
                            _dismissInsight(context, controller, item.id),
                        child: _InsightTile(
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
          SnackBar(content: Text(_insightFailureMessage(context, failure))),
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
      GoRouter.of(context).go('/insights/${insight.id}');
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(_insightFailureMessage(context, failure))),
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
          SnackBar(content: Text(_insightFailureMessage(context, failure))),
        );
      return false;
    }
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.unreadOnly,
    required this.selectedType,
    required this.selectedSeverity,
    required this.onUnreadChanged,
    required this.onTypeChanged,
    required this.onSeverityChanged,
  });

  final bool unreadOnly;
  final InsightType? selectedType;
  final InsightSeverity? selectedSeverity;
  final ValueChanged<bool> onUnreadChanged;
  final ValueChanged<InsightType?> onTypeChanged;
  final ValueChanged<InsightSeverity?> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.insightsFilterTitle,
                        style: context.textTheme.title,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.insightsFilterSubtitle,
                        style: context.textTheme.label.copyWith(
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Switch(value: unreadOnly, onChanged: onUnreadChanged),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<InsightType?>(
              initialValue: selectedType,
              decoration: InputDecoration(labelText: l10n.insightsTypeLabel),
              items: <DropdownMenuItem<InsightType?>>[
                DropdownMenuItem<InsightType?>(
                  value: null,
                  child: Text(l10n.insightsFilterAllTypes),
                ),
                ...InsightType.values.map(
                  (type) => DropdownMenuItem<InsightType?>(
                    value: type,
                    child: Text(insightTypeLabel(context, type)),
                  ),
                ),
              ],
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<InsightSeverity?>(
              initialValue: selectedSeverity,
              decoration: InputDecoration(
                labelText: l10n.insightsSeverityLabel,
              ),
              items: <DropdownMenuItem<InsightSeverity?>>[
                DropdownMenuItem<InsightSeverity?>(
                  value: null,
                  child: Text(l10n.insightsFilterAllSeverities),
                ),
                ...InsightSeverity.values.map(
                  (severity) => DropdownMenuItem<InsightSeverity?>(
                    value: severity,
                    child: Text(insightSeverityLabel(context, severity)),
                  ),
                ),
              ],
              onChanged: onSeverityChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight, required this.onTap});

  final Insight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm().format(insight.generatedAt);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SeverityBadge(severity: insight.severity),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: context.textTheme.body.copyWith(
                        fontWeight: insight.read
                            ? AppFontWeight.regular
                            : AppFontWeight.semibold,
                      ),
                    ),
                  ),
                  if (!insight.read)
                    Container(
                      width: AppSpacing.sm,
                      height: AppSpacing.sm,
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                insight.summary,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              if (insight.detail != null &&
                  insight.detail!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(insight.detail!, style: context.textTheme.label),
              ],
              if (insight.metadata != null &&
                  insight.metadata!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  insight.metadata!,
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  _InfoChip(label: insightTypeLabel(context, insight.type)),
                  _InfoChip(label: formattedDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (
      Color background,
      Color foreground,
      IconData icon,
      String label,
    ) = switch (severity) {
      InsightSeverity.info => (
        context.colors.surfaceSubtle,
        context.finance.info,
        Icons.lightbulb_outline_rounded,
        l10n.insightsSeverityInfo,
      ),
      InsightSeverity.warning => (
        context.finance.warningSurface,
        context.finance.warning,
        Icons.warning_amber_rounded,
        l10n.insightsSeverityWarning,
      ),
      InsightSeverity.critical => (
        context.finance.expenseSurface,
        context.finance.expense,
        Icons.priority_high_rounded,
        l10n.insightsSeverityCritical,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: context.textTheme.label.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: context.textTheme.label.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.finance.expenseSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.visibility_off_outlined,
            color: context.finance.expense,
          ),
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _insightFailureMessage(BuildContext context, Failure failure) {
  return insightFailureMessage(context, failure);
}
