import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_list_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockSummaryCard extends StatelessWidget {
  const StockSummaryCard({super.key, required this.summary});

  final StockHoldingSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasLiveValuation = summary.totalProfitLoss != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksSummaryTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.xl),
            MoneyRow(
              label: l10n.stocksTotalInvestedLabel,
              amount: summary.totalInvested,
              currencyCode: _summaryCurrency(summary),
            ),
            const SizedBox(height: AppSpacing.md),
            MoneyRow(
              label: l10n.stocksCurrentValueLabel,
              amount: hasLiveValuation ? summary.totalCurrentValue : null,
              currencyCode: _summaryCurrency(summary),
            ),
            const SizedBox(height: AppSpacing.md),
            MoneyRow(
              label: l10n.stocksProfitLossLabel,
              amount: summary.totalProfitLoss,
              currencyCode: _summaryCurrency(summary),
            ),
            if (!hasLiveValuation && summary.holdingCount > 0) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.commonNotAvailable,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            InfoPill(
              label: l10n.stocksHoldingCountLabel,
              value: summary.holdingCount.toString(),
            ),
          ],
        ),
      ),
    );
  }

  String _summaryCurrency(StockHoldingSummary summary) {
    return summary.holdings.isEmpty ? 'USD' : summary.holdings.first.currency;
  }
}
