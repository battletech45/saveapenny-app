import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/insights/application/insight_detail_controller.dart';
import 'package:saveapenny/features/insights/application/insights_controller.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InsightDetailScreen extends ConsumerWidget {
  const InsightDetailScreen({super.key, required this.insightId});

  final String insightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detailState = ref.watch(insightDetailControllerProvider(insightId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/insights'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.insightsDetailTitle),
      ),
      body: SafeArea(
        child: detailState.when(
          data: (insight) => RefreshIndicator(
            onRefresh: () => ref
                .read(insightDetailControllerProvider(insightId).notifier)
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
                        _SeverityBadge(severity: insight.severity),
                        const SizedBox(height: AppSpacing.md),
                        Text(insight.title, style: context.textTheme.headline),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          insight.summary,
                          style: context.textTheme.body.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        if (insight.detail != null &&
                            insight.detail!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            l10n.insightsDetailSectionTitle,
                            style: context.textTheme.title,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(insight.detail!, style: context.textTheme.body),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        _InfoRow(
                          label: l10n.insightsTypeLabel,
                          value: insightTypeLabel(context, insight.type),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: l10n.insightsSeverityLabel,
                          value: insightSeverityLabel(
                            context,
                            insight.severity,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: l10n.insightsGeneratedAtLabel,
                          value: DateFormat.yMMMd(
                            Localizations.localeOf(context).toLanguageTag(),
                          ).add_Hm().format(insight.generatedAt),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoRow(
                          label: l10n.insightsReadStatusLabel,
                          value: insight.read
                              ? l10n.insightsReadStatusRead
                              : l10n.insightsReadStatusUnread,
                        ),
                        if (insight.metadata != null &&
                            insight.metadata!.isNotEmpty) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          _InfoRow(
                            label: l10n.insightsMetadataLabel,
                            value: insight.metadata!,
                          ),
                        ],
                        if (insight.categoryId != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          _InfoRow(
                            label: l10n.insightsCategoryIdLabel,
                            value: insight.categoryId!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => _dismissInsight(context, ref),
                  child: Text(l10n.insightsDismissCta),
                ),
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () => ref
                .read(insightDetailControllerProvider(insightId).notifier)
                .refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _dismissInsight(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(insightsControllerProvider.notifier).dismiss(insightId);
      if (!context.mounted) {
        return;
      }
      GoRouter.of(context).go('/insights');
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
}

class _SeverityBadge extends StatelessWidget {
  const _SeverityBadge({required this.severity});

  final InsightSeverity severity;

  @override
  Widget build(BuildContext context) {
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
        insightSeverityLabel(context, severity),
      ),
      InsightSeverity.warning => (
        context.finance.warningSurface,
        context.finance.warning,
        Icons.warning_amber_rounded,
        insightSeverityLabel(context, severity),
      ),
      InsightSeverity.critical => (
        context.finance.expenseSurface,
        context.finance.expense,
        Icons.priority_high_rounded,
        insightSeverityLabel(context, severity),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: 132,
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Text(value, style: context.textTheme.body)),
      ],
    );
  }
}

String insightTypeLabel(BuildContext context, InsightType type) {
  final l10n = AppLocalizations.of(context);

  return switch (type) {
    InsightType.spendingPattern => l10n.insightsTypeSpendingPattern,
    InsightType.anomaly => l10n.insightsTypeAnomaly,
    InsightType.trend => l10n.insightsTypeTrend,
    InsightType.recommendation => l10n.insightsTypeRecommendation,
    InsightType.prediction => l10n.insightsTypePrediction,
  };
}

String insightSeverityLabel(BuildContext context, InsightSeverity severity) {
  final l10n = AppLocalizations.of(context);

  return switch (severity) {
    InsightSeverity.info => l10n.insightsSeverityInfo,
    InsightSeverity.warning => l10n.insightsSeverityWarning,
    InsightSeverity.critical => l10n.insightsSeverityCritical,
  };
}

String insightFailureMessage(BuildContext context, Failure failure) {
  final l10n = AppLocalizations.of(context);

  return switch (failure) {
    RateLimitedFailure() => l10n.failureRateLimitedMessage,
    ApiFailure(code: final code) when code == ApiErrorCode.insightNotFound =>
      l10n.failureResourceNotFoundMessage,
    ApiFailure(code: final code)
        when code == ApiErrorCode.insightGenerationFailed =>
      l10n.insightsGenerateFailureMessage,
    _ => l10n.failureGenericMessage,
  };
}
