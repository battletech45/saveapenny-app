import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/charts.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_shared.dart';

class InsightTile extends StatelessWidget {
  const InsightTile({super.key, required this.insight, required this.onTap});

  final Insight insight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatInsightDateTime(context, insight.generatedAt);
    final metadataPills = parseInsightMetadataPills(insight.metadata);
    final sparklinePoints = parseInsightSparklinePoints(insight);

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
                  InsightTypeIcon(type: insight.type),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          insight.title,
                          style: context.textTheme.body.copyWith(
                            fontWeight: insight.read
                                ? AppFontWeight.regular
                                : AppFontWeight.semibold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        InsightSeverityBadge(severity: insight.severity),
                      ],
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
              if (sparklinePoints.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                SparklineChart(
                  points: sparklinePoints,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
              if (insight.metadata != null &&
                  insight.metadata!.isNotEmpty) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                if (metadataPills.isEmpty)
                  Text(
                    insight.metadata!,
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  )
                else
                  InsightMetadataPills(pills: metadataPills),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  InsightInfoChip(
                    label: insightTypeLabel(context, insight.type),
                  ),
                  InsightInfoChip(label: formattedDate),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
