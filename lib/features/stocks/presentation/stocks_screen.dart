import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/app_bottom_sheet.dart';
import 'package:saveapenny/core/ui/failure_view.dart';
import 'package:saveapenny/core/ui/inline_empty_view.dart';
import 'package:saveapenny/core/ui/loading_view.dart';
import 'package:saveapenny/features/stocks/application/stock_holdings_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_holding.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_holding_card.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_holding_form_sheet.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_lookup_card.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_summary_card.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StocksScreen extends ConsumerWidget {
  const StocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stocksState = ref.watch(stockHoldingsControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stocksTitle)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'stocksFab',
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
                StockSummaryCard(summary: data.summary),
                const SizedBox(height: AppSpacing.lg),
                StockLookupCard(
                  onLookup: (symbol) =>
                      unawaited(GoRouter.of(context).push('/stocks/$symbol')),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.stocksTitle, style: context.textTheme.title),
                const SizedBox(height: AppSpacing.sm),
                if (data.items.isEmpty)
                  InlineEmptyView(
                    title: l10n.stocksEmptyTitle,
                    message: l10n.stocksEmptyMessage,
                    action: ElevatedButton(
                      onPressed: () => _showHoldingSheet(context),
                      child: Text(l10n.stocksAddCta),
                    ),
                  )
                else
                  ...data.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: StockHoldingCard(
                        holding: item,
                        onOpen: () =>
                            unawaited(GoRouter.of(context).push('/stocks/${item.symbol}')),
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
