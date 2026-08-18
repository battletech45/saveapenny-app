import 'package:flutter/material.dart';

import 'package:saveapenny/core/formatting/money_formatter.dart';
import 'package:saveapenny/core/theme/app_theme.dart';
import 'package:saveapenny/core/theme/tokens.dart';
import 'package:saveapenny/core/ui/animated_money.dart';
import 'package:saveapenny/core/ui/stat_pill.dart';
import 'package:saveapenny/features/reports/domain/net_worth_snapshot.dart';
import 'package:saveapenny/l10n/generated/app_localizations.dart';

class NetWorthHero extends StatelessWidget {
  const NetWorthHero({super.key, required this.netWorth});

  final NetWorthSnapshot netWorth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.dashboardNetWorthLabel,
              style: context.textTheme.label.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: AnimatedMoney(
                amount: netWorth.netWorth,
                currencyCode: 'TRY',
                style: context.textTheme.displayMoney,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Expanded(
                  child: StatPill(
                    label: l10n.dashboardAssetsLabel,
                    value: MoneyFormatter.format(
                      context: context,
                      amount: netWorth.totalAssets,
                      currencyCode: 'TRY',
                    ).text,
                    icon: Icons.arrow_upward_rounded,
                    tone: StatPillTone.income,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: StatPill(
                    label: l10n.dashboardLiabilitiesLabel,
                    value: MoneyFormatter.format(
                      context: context,
                      amount: netWorth.totalLiabilities,
                      currencyCode: 'TRY',
                    ).text,
                    icon: Icons.arrow_downward_rounded,
                    tone: StatPillTone.expense,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
