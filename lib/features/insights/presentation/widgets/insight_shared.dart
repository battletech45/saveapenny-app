import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

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

String formatInsightDateTime(BuildContext context, DateTime value) {
  return DateFormat.yMMMd(
    Localizations.localeOf(context).toLanguageTag(),
  ).add_Hm().format(value);
}

class InsightSeverityBadge extends StatelessWidget {
  const InsightSeverityBadge({super.key, required this.severity});

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

class InsightInfoChip extends StatelessWidget {
  const InsightInfoChip({super.key, required this.label});

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

class InsightInlineEmptyState extends StatelessWidget {
  const InsightInlineEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

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

class InsightDismissBackground extends StatelessWidget {
  const InsightDismissBackground({super.key});

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
