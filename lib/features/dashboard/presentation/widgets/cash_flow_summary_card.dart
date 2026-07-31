import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/cash_flow_tile.dart';
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
          child: CashFlowTile(
            label: l10n.dashboardMonthlyIncomeLabel,
            amount: summary.totalIncome,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: CashFlowTile(
            label: l10n.dashboardMonthlyExpenseLabel,
            amount: -summary.totalExpense,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
      ],
    );
  }
}
