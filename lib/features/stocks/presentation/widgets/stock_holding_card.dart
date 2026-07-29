import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_list_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockHoldingCard extends StatelessWidget {
  const StockHoldingCard({
    super.key,
    required this.holding,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final StockHolding holding;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(holding.symbol, style: context.textTheme.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${holding.quantity} ${l10n.stocksQuantityLabel.toLowerCase()}',
                          style: context.textTheme.label.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                        return;
                      }
                      onDelete();
                    },
                    itemBuilder: (context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(l10n.stocksEditCta),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text(l10n.stocksDeleteCta),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: InfoPill(
                      label: l10n.stocksPurchasePriceLabel,
                      value: MoneyFormatter.format(
                        context: context,
                        amount: holding.purchasePrice,
                        currencyCode: holding.currency,
                      ).text,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InfoPill(
                      label: l10n.stocksCurrentValueLabel,
                      value: holding.currentValue == null
                          ? l10n.commonNotAvailable
                          : MoneyFormatter.format(
                              context: context,
                              amount: holding.currentValue!,
                              currencyCode: holding.currency,
                            ).text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _ProfitLossRow(holding: holding),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfitLossRow extends StatelessWidget {
  const _ProfitLossRow({required this.holding});

  final StockHolding holding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            l10n.stocksProfitLossLabel,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Text(
          holding.profitLoss == null
              ? l10n.commonNotAvailable
              : MoneyFormatter.format(
                  context: context,
                  amount: holding.profitLoss!,
                  currencyCode: holding.currency,
                ).text,
          style: context.textTheme.money.copyWith(
            color: holding.profitLoss == null
                ? context.colors.textSecondary
                : context.finance.forAmount(holding.profitLoss!),
          ),
        ),
      ],
    );
  }
}
