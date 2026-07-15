import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CashFlowSummaryCard extends StatelessWidget {
  const CashFlowSummaryCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: _CashFlowTile(
            label: l10n.dashboardMonthlyIncomeLabel,
            amount: summary.totalIncome,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _CashFlowTile(
            label: l10n.dashboardMonthlyExpenseLabel,
            amount: -summary.totalExpense,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }
}

class _CashFlowTile extends StatelessWidget {
  const _CashFlowTile({
    required this.label,
    required this.amount,
    required this.icon,
  });

  final String label;
  final num amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final formatted = MoneyFormatter.format(
      context: context,
      amount: amount,
      currencyCode: 'TRY',
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, size: AppSpacing.lg, color: formatted.color),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: context.textTheme.label.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              formatted.text,
              style: context.textTheme.money.copyWith(color: formatted.color),
            ),
          ],
        ),
      ),
    );
  }
}
