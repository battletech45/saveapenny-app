import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/network/api_error_code.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/charts.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
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

IconData insightTypeIcon(InsightType type) {
  return switch (type) {
    InsightType.spendingPattern => Icons.receipt_long_outlined,
    InsightType.anomaly => Icons.crisis_alert_rounded,
    InsightType.trend => Icons.show_chart_rounded,
    InsightType.recommendation => Icons.tips_and_updates_outlined,
    InsightType.prediction => Icons.auto_graph_rounded,
  };
}

List<MetadataPillData> parseInsightMetadataPills(String? metadata) {
  final decoded = _decodeMetadata(metadata);
  if (decoded is! Map<String, dynamic>) {
    return const <MetadataPillData>[];
  }

  return decoded.entries
      .where((entry) => _isScalar(entry.value))
      .map(
        (entry) => MetadataPillData(
          label: entry.key,
          value: _metadataValue(entry.value),
        ),
      )
      .take(6)
      .toList(growable: false);
}

List<TrendPoint> parseInsightSparklinePoints(Insight insight) {
  if (insight.type != InsightType.trend &&
      insight.type != InsightType.prediction) {
    return const <TrendPoint>[];
  }
  final decoded = _decodeMetadata(insight.metadata);
  final values = <num>[];
  _collectNumericSeries(decoded, values);
  if (values.length < 2) {
    return const <TrendPoint>[];
  }
  return <TrendPoint>[
    for (var i = 0; i < values.length; i++)
      TrendPoint(i.toDouble(), values[i].toDouble()),
  ];
}

Object? _decodeMetadata(String? metadata) {
  if (metadata == null || metadata.isEmpty) {
    return null;
  }
  try {
    return jsonDecode(metadata);
  } on FormatException {
    return null;
  }
}

bool _isScalar(Object? value) {
  return value == null || value is String || value is num || value is bool;
}

String _metadataValue(Object? value) {
  if (value == null) {
    return '--';
  }
  return value.toString();
}

void _collectNumericSeries(Object? value, List<num> values) {
  if (value is List) {
    final numeric = value.whereType<num>().toList(growable: false);
    if (numeric.length >= 2) {
      values.addAll(numeric);
      return;
    }
    for (final item in value) {
      _collectNumericSeries(item, values);
    }
    return;
  }
  if (value is Map) {
    for (final item in value.values) {
      _collectNumericSeries(item, values);
      if (values.length >= 2) {
        return;
      }
    }
  }
}

class MetadataPillData {
  const MetadataPillData({required this.label, required this.value});

  final String label;
  final String value;
}

class InsightTypeIcon extends StatelessWidget {
  const InsightTypeIcon({super.key, required this.type});

  final InsightType type;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Icon(
          insightTypeIcon(type),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class InsightMetadataPills extends StatelessWidget {
  const InsightMetadataPills({super.key, required this.pills});

  final List<MetadataPillData> pills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        for (final pill in pills)
          StatPill(label: pill.label, value: pill.value),
      ],
    );
  }
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
