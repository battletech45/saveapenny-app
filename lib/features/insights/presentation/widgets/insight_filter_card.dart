import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_dropdown_field.dart';
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
            AppDropdownField<InsightType?>(
              label: l10n.insightsTypeLabel,
              value: selectedType,
              options: <AppDropdownOption<InsightType?>>[
                AppDropdownOption<InsightType?>(
                  value: null,
                  label: l10n.insightsFilterAllTypes,
                ),
                ...InsightType.values.map(
                  (type) => AppDropdownOption<InsightType?>(
                    value: type,
                    label: insightTypeLabel(context, type),
                  ),
                ),
              ],
              onChanged: onTypeChanged,
            ),
            const SizedBox(height: AppSpacing.md),
            AppDropdownField<InsightSeverity?>(
              label: l10n.insightsSeverityLabel,
              value: selectedSeverity,
              options: <AppDropdownOption<InsightSeverity?>>[
                AppDropdownOption<InsightSeverity?>(
                  value: null,
                  label: l10n.insightsFilterAllSeverities,
                ),
                ...InsightSeverity.values.map(
                  (severity) => AppDropdownOption<InsightSeverity?>(
                    value: severity,
                    label: insightSeverityLabel(context, severity),
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
