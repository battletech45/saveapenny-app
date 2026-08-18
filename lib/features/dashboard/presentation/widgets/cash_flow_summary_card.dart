import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/progress_meter.dart';
import 'package:saveapenny/features/dashboard/presentation/widgets/cash_flow_tile.dart';
import 'package:saveapenny/features/reports/domain/monthly_summary.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class CashFlowSummaryCard extends StatelessWidget {
  const CashFlowSummaryCard({super.key, required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final total = summary.totalIncome + summary.totalExpense;
    final incomeShare = total > 0 ? summary.totalIncome / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ),
        ),
        if (total > 0) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          ProgressMeter(value: incomeShare, color: context.finance.income),
        ],
      ],
    );
  }
}
