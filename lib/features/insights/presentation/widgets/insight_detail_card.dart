import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InsightDetailCard extends StatelessWidget {
  const InsightDetailCard({super.key, required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InsightSeverityBadge(severity: insight.severity),
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
            InsightDetailInfoRow(
              label: l10n.insightsTypeLabel,
              value: insightTypeLabel(context, insight.type),
            ),
            const SizedBox(height: AppSpacing.sm),
            InsightDetailInfoRow(
              label: l10n.insightsSeverityLabel,
              value: insightSeverityLabel(context, insight.severity),
            ),
            const SizedBox(height: AppSpacing.sm),
            InsightDetailInfoRow(
              label: l10n.insightsGeneratedAtLabel,
              value: formatInsightDateTime(context, insight.generatedAt),
            ),
            const SizedBox(height: AppSpacing.sm),
            InsightDetailInfoRow(
              label: l10n.insightsReadStatusLabel,
              value: insight.read
                  ? l10n.insightsReadStatusRead
                  : l10n.insightsReadStatusUnread,
            ),
            if (insight.metadata != null &&
                insight.metadata!.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              InsightDetailInfoRow(
                label: l10n.insightsMetadataLabel,
                value: insight.metadata!,
              ),
            ],
            if (insight.categoryId != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              InsightDetailInfoRow(
                label: l10n.insightsCategoryIdLabel,
                value: insight.categoryId!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class InsightDetailInfoRow extends StatelessWidget {
  const InsightDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

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
