import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:saveapenny/core/error/failure.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/features/stocks/application/stock_financials_controller.dart';
import 'package:saveapenny/features/stocks/domain/stock_financial_statement.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockFinancialsSection extends StatefulWidget {
  const StockFinancialsSection({super.key, required this.symbol});

  final String symbol;

  @override
  State<StockFinancialsSection> createState() => _StockFinancialsSectionState();
}

class _StockFinancialsSectionState extends State<StockFinancialsSection> {
  bool _enabled = false;
  StockFinancialStatementType _selected =
      StockFinancialStatementType.incomeStatement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_enabled) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.stocksFinancialsTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.stocksFinancialsSubtitle,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => setState(() => _enabled = true),
                child: Text(l10n.stocksFinancialsLoadCta),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(
          stockFinancialStatementControllerProvider(widget.symbol, _selected),
        );

        return state.when(
          data: (data) => _FinancialsCard(
            selected: _selected,
            onSelected: (value) => setState(() => _selected = value),
            statement: data,
          ),
          loading: () => SectionLoadingCard(title: l10n.stocksFinancialsTitle),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.stocksFinancialsTitle,
                    style: context.textTheme.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FinancialSelector(
                    selected: _selected,
                    onSelected: (value) => setState(() => _selected = value),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    stockFailureMessage(context, error as Failure),
                    style: context.textTheme.body.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FinancialsCard extends StatelessWidget {
  const _FinancialsCard({
    required this.selected,
    required this.onSelected,
    required this.statement,
  });

  final StockFinancialStatementType selected;
  final ValueChanged<StockFinancialStatementType> onSelected;
  final StockFinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksFinancialsTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.md),
            _FinancialSelector(selected: selected, onSelected: onSelected),
            const SizedBox(height: AppSpacing.lg),
            _StatementPreview(
              title: _financialLabel(l10n, selected),
              statement: statement,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementPreview extends StatelessWidget {
  const _StatementPreview({required this.title, required this.statement});

  final String title;
  final StockFinancialStatement statement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final report = statement.annualReports.isNotEmpty
        ? statement.annualReports.first
        : statement.quarterlyReports.isNotEmpty
        ? statement.quarterlyReports.first
        : null;

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
            Text(title, style: context.textTheme.body),
            const SizedBox(height: AppSpacing.xs),
            if (report == null)
              Text(
                l10n.stocksFinancialsEmptyMessage,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              )
            else ...<Widget>[
              Text(
                report.fiscalDateEnding,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  ...report.fields.entries
                      .take(3)
                      .map(
                        (entry) => StatPill(
                          label: entry.key,
                          value: entry.value,
                          icon: _financialTrendIcon(statement, entry.key),
                          tone: _financialTrendTone(statement, entry.key),
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

IconData _financialTrendIcon(StockFinancialStatement statement, String key) {
  final trend = _financialTrend(statement, key);
  if (trend > 0) {
    return Icons.trending_up_rounded;
  }
  if (trend < 0) {
    return Icons.trending_down_rounded;
  }
  return Icons.trending_flat_rounded;
}

StatPillTone _financialTrendTone(
  StockFinancialStatement statement,
  String key,
) {
  final trend = _financialTrend(statement, key);
  if (trend > 0) {
    return StatPillTone.income;
  }
  if (trend < 0) {
    return StatPillTone.expense;
  }
  return StatPillTone.neutral;
}

num _financialTrend(StockFinancialStatement statement, String key) {
  final reports = statement.annualReports.length >= 2
      ? statement.annualReports
      : statement.quarterlyReports;
  if (reports.length < 2) {
    return 0;
  }
  final current = num.tryParse(reports.first.fields[key] ?? '');
  final previous = num.tryParse(reports[1].fields[key] ?? '');
  if (current == null || previous == null) {
    return 0;
  }
  return current - previous;
}

class _FinancialSelector extends StatelessWidget {
  const _FinancialSelector({required this.selected, required this.onSelected});

  final StockFinancialStatementType selected;
  final ValueChanged<StockFinancialStatementType> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<StockFinancialStatementType>(
        segments: <ButtonSegment<StockFinancialStatementType>>[
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.incomeStatement,
            label: Text(l10n.stocksIncomeStatementTitle),
          ),
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.balanceSheet,
            label: Text(l10n.stocksBalanceSheetTitle),
          ),
          ButtonSegment<StockFinancialStatementType>(
            value: StockFinancialStatementType.cashFlow,
            label: Text(l10n.stocksCashFlowTitle),
          ),
        ],
        selected: <StockFinancialStatementType>{selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

String _financialLabel(
  AppLocalizations l10n,
  StockFinancialStatementType type,
) {
  return switch (type) {
    StockFinancialStatementType.incomeStatement =>
      l10n.stocksIncomeStatementTitle,
    StockFinancialStatementType.balanceSheet => l10n.stocksBalanceSheetTitle,
    StockFinancialStatementType.cashFlow => l10n.stocksCashFlowTitle,
  };
}
