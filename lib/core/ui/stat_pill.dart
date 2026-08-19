import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';

/// Semantic tone for a [StatPill] — controls its color, independent of the
/// finance income/expense palette (a pill can be neutral, or echo a finance
/// semantic when the value it carries is genuinely a warning/error).
enum StatPillTone { neutral, income, expense, warning, info }

/// A bordered label/value chip. Consolidates the repeated
/// `BudgetMetricPill`/`GoalMetricPill`/`AccountInfoPill`/`RecurringInfoPill`
/// pattern into one shared component.
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.tone = StatPillTone.neutral,
  });

  final String label;
  final String value;
  final IconData? icon;
  final StatPillTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color fg, Color bg) = _colorsFor(context, tone);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: tone == StatPillTone.neutral
            ? Border.all(color: context.colors.border)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, size: 14, color: fg),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: context.textTheme.label.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                maxLines: 1,
                style: context.textTheme.money.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(BuildContext context, StatPillTone tone) {
    switch (tone) {
      case StatPillTone.neutral:
        return (context.colors.textPrimary, context.colors.surfaceSubtle);
      case StatPillTone.income:
        return (context.finance.income, context.finance.incomeSurface);
      case StatPillTone.expense:
        return (context.finance.expense, context.finance.expenseSurface);
      case StatPillTone.warning:
        return (context.finance.warning, context.finance.warningSurface);
      case StatPillTone.info:
        return (context.finance.info, context.colors.surfaceSubtle);
    }
  }
}
