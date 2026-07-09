import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/stocks/application/stock_holdings_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding_summary.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_holding_form_sheet.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StocksScreen extends ConsumerWidget {
  const StocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stocksState = ref.watch(stockHoldingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => GoRouter.of(context).go('/home'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(l10n.stocksTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showHoldingSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.stocksAddCta),
      ),
      body: SafeArea(
        child: stocksState.when(
          data: (data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(stockHoldingsControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                _SummaryCard(summary: data.summary),
                const SizedBox(height: AppSpacing.lg),
                _LookupCard(
                  onLookup: (symbol) =>
                      GoRouter.of(context).go('/stocks/$symbol'),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.stocksTitle, style: context.textTheme.title),
                const SizedBox(height: AppSpacing.sm),
                if (data.items.isEmpty)
                  _InlineEmptyState(
                    title: l10n.stocksEmptyTitle,
                    message: l10n.stocksEmptyMessage,
                  )
                else
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _HoldingCard(
                        holding: item,
                        onOpen: () =>
                            GoRouter.of(context).go('/stocks/${item.symbol}'),
                        onEdit: () =>
                            _showHoldingSheet(context, existing: item),
                        onDelete: () => _confirmDelete(context, ref, item),
                      ),
                    ),
                  ),
                if (data.hasNext) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => ref
                        .read(stockHoldingsControllerProvider.notifier)
                        .loadMore(),
                    child: Text(l10n.goalsLoadMoreCta),
                  ),
                ],
              ],
            ),
          ),
          loading: () => const LoadingView(),
          error: (error, _) => FailureView(
            failure: error as Failure,
            onRetry: () =>
                ref.read(stockHoldingsControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Future<void> _showHoldingSheet(
    BuildContext context, {
    StockHolding? existing,
  }) {
    return showAppModalBottomSheet<void>(
      context: context,
      builder: (context) => StockHoldingFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    StockHolding holding,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.stocksDeleteTitle),
          content: Text(l10n.stocksDeleteMessage(holding.symbol)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonBack),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.stocksDeleteCta),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(stockHoldingsControllerProvider.notifier)
          .deleteHolding(holding.id);
    } on Failure catch (failure) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(stockFailureMessage(context, failure))),
        );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

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
            _MoneyRow(
              label: l10n.stocksTotalInvestedLabel,
              amount: summary.totalInvested,
              currencyCode: _summaryCurrency(summary),
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
              label: l10n.stocksCurrentValueLabel,
              amount: hasLiveValuation ? summary.totalCurrentValue : null,
              currencyCode: _summaryCurrency(summary),
            ),
            const SizedBox(height: AppSpacing.md),
            _MoneyRow(
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
            _InfoPill(
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

class _LookupCard extends StatelessWidget {
  const _LookupCard({required this.onLookup});

  final ValueChanged<String> onLookup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksLookupTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.stocksLookupSubtitle,
              style: context.textTheme.body.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _showLookupDialog(context),
              child: Text(l10n.stocksLookupCta),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLookupDialog(BuildContext context) async {
    final symbol = await showDialog<String>(
      context: context,
      builder: (context) => const _StockLookupDialog(),
    );

    if (symbol == null || symbol.isEmpty || !context.mounted) {
      return;
    }

    onLookup(symbol);
  }
}

class _StockLookupDialog extends StatefulWidget {
  const _StockLookupDialog();

  @override
  State<_StockLookupDialog> createState() => _StockLookupDialogState();
}

class _StockLookupDialogState extends State<_StockLookupDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.stocksLookupTitle),
      content: TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: l10n.stocksLookupLabel,
          hintText: l10n.stocksLookupHint,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonBack),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim().toUpperCase()),
          child: Text(l10n.stocksLookupCta),
        ),
      ],
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
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
                    child: _InfoPill(
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
                    child: _InfoPill(
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

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    required this.currencyCode,
  });

  final String label;
  final num? amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final money = amount == null
        ? null
        : MoneyFormatter.format(
            context: context,
            amount: amount!,
            currencyCode: currencyCode,
          );

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: context.textTheme.label.copyWith(
              color: context.colors.textSecondary,
            ),
          ),
        ),
        Text(
          money?.text ?? AppLocalizations.of(context).commonNotAvailable,
          style: context.textTheme.money.copyWith(
            color: money?.color ?? context.colors.textSecondary,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(value, style: context.textTheme.body),
          ],
        ),
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
