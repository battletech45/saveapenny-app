import 'package:flutter/material.dart';

import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/features/stocks/domain/stock_overview.dart';
import 'package:saveapenny/features/stocks/presentation/widgets/stock_detail_shared.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class StockOverviewCard extends StatelessWidget {
  const StockOverviewCard({super.key, required this.overview});

  final StockOverview? overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (overview == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.stocksOverviewTitle, style: context.textTheme.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.commonNotAvailable,
                style: context.textTheme.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(l10n.stocksOverviewTitle, style: context.textTheme.title),
            const SizedBox(height: AppSpacing.sm),
            if (overview!.name != null)
              Text(overview!.name!, style: context.textTheme.headline),
            if (overview!.exchange != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              InfoRow(
                label: l10n.stocksExchangeLabel,
                value: overview!.exchange!,
              ),
            ],
            if (overview!.sector != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              InfoRow(label: l10n.stocksSectorLabel, value: overview!.sector!),
            ],
            if (overview!.industry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              InfoRow(
                label: l10n.stocksIndustryLabel,
                value: overview!.industry!,
              ),
            ],
            if (overview!.description != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.stocksDescriptionLabel,
                style: context.textTheme.label.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(overview!.description!, style: context.textTheme.body),
            ],
          ],
        ),
      ),
    );
  }
}
