import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/insights/domain/insight.dart';
import 'package:saveapenny/features/insights/presentation/widgets/insight_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class InsightFilterCard extends StatelessWidget {
  const InsightFilterCard({
    super.key,
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
